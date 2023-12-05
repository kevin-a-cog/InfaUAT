/*
* Name         :   helpQuestions
* Author       :   Utkarsh Jain
* Created Date :   15-JAN-2022
* Description  :   Controller used for Ask A Question LWC component.

Change History
**************************************************************************************************************************
Modified By            Date                Jira No.            Description                                               Tag
**************************************************************************************************************************
Utkarsh Jain           15-JAN-2021         Utopia-ph-3         Initial version.                                          NA
Utkarsh Jain           15-FEB-2021         I2RT-5419           Get Discussions for logged in user.                       1
Deeksha Shetty         July 1,2022         I2RT-6759           Users not able to see the components                      T2
in the Product community             
Saumya Gaikwad         Sep 29,2022         I2RT-7170	       Fixed the Missing Product Community Name                  3
                                                               tag when Image is added in description                    
Utkarsh Jain           26-OCT-2022         I2RT-7262           Production Bug - New communities are getting created      4
                                                               when the #tag is used in the discussion content
Deeksha Shetty         08 May 2023         I2RT-8345           Ask a Question - Email Notification - Issue observed      5
                                                               in New and Update Notification email template    
Utkarsh Jain           04-May-2023         I2RT-8305           New product is getting created while tagging the discussion. 6    
Utkarsh Jain           25-May-2023         I2RT-8161           Changing the logic in Top participants in product community. 7                                              
*/
public without sharing class helpQuestions {
    
    /*
    Save Question post to FeedItem Object
    param : userId - User Id
    param : networkId - Informatica Network Id.
    param : parentId - topic Id.
    param : title - title of question.
    param : body - body of question
    return : All community List. 
    */
    @AuraEnabled
    public static String saveQuestionPost(String userId, String networkId, String parentId, String title, String body,String fileList ){
        try{
            /*Tag-3 Starts*/
            map<string,string> imageurls = new map<string,string>();
            list<ContentVersion> CVList = new list<ContentVersion>();
            list<ContentVersion> docIdList = new list<ContentVersion>();
            if(body.contains('<strike'))
                body = body.replace('<strike','<s').replace('</strike>','</s>');
            if(body.contains('<em'))
                body = body.replace('<em','<i').replace('</em>','</i>');
            if(body.contains('<strong'))
                body = body.replace('<strong','<b').replace('</strong>','</b>');
            if(body.contains('<span')) 
                body = body.replace('<span','<p').replace('/span>','/p>');
            if(body.contains('<br>')) 
                body = body.replace('<br>','<p>&nbsp;</p>');
            if(body.contains('<img src')){
                for(string st1 : body.split('<')){
                    if(st1.contains('img src')){
                        string temp = st1.substringBetween('img src="', '">');
                        imageurls.put(temp,temp);
                        PageReference page = new PageReference(temp);
                        Blob b;
                        if(!Test.isRunningTest()){
                            b  = page.getContent();
                        }
                        else{
                            b = EncodingUtil.base64Decode('Test Attachment Body');
                        }
                        ContentVersion cv = new ContentVersion();
                        cv.Title = Title;
                        cv.VersionData = b;
                        cv.IsMajorVersion = true;
                        cv.PathOnClient = temp;
                        CVList.add(cv);
                    }
                }
                insert CVList; 
                docIdList = [SELECT Id, VersionData, ContentDocumentId,PathOnClient FROM ContentVersion WHERE Id in: CVList];
                for(ContentVersion cv : docIdList){
                    string tempReplacement = '<img src="sfdc://' + cv.ContentDocumentId + '"></img>';
                    string temp = '<img src="' + imageurls.get(string.valueof(cv.PathOnClient)) + '">';
                    body = body.replace(temp,tempReplacement);
                }                
            }
            /*Tag-3 Ends*/
            FeedItem feedData = new FeedItem();
            feedData.Title=title;
            feedData.ParentId=parentId;
            feedData.Body= body;
            feedData.NetworkScope=networkId;
            feedData.Type='QuestionPost';
            feedData.IsRichText=true;
            insert feedData;
            // Update Reputation points
            List<FeedItem> currentFeedItem = [select Id, status from feedItem where Id =: feedData.Id];
            if(currentFeedItem[0].Status == 'Published'){
                UpdateReputationPointsForAskAQuestion(userId, parentId);

            }

            /*Tag 5 starts*/
            if(feedData.Id != null && fileList!=null){
                uploadFile(fileList,feedData.Id);
            }
            saveQuestionPostToTopic(feedData.Id,networkId,parentId);
            /*Tag 5 ends*/
            return feedData.Id;
            
        } catch(Exception e){
            system.debug('Error in saveQuestionPost: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Error in saveQuestionPost: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString() );            
        } 
    }
    
    public static void uploadFile(String fileList, String recordId) { //String base64, String filename,
        List<attachmentToList> filesNewList = (List<attachmentToList>) JSON.deserialize(fileList, List<attachmentToList>.class);
        List<ContentVersion> cvList = new List<ContentVersion>();
        List<FeedAttachment> attachmentList = new List<FeedAttachment>();
        
        for(attachmentToList file : filesNewList){
            ContentVersion cv = createContentVersion(file.base64, file.filename);
            cvList.add(cv);
        }
        insert cvList;
        
        for(ContentVersion cv : cvList){
            FeedAttachment feedAttachment = new FeedAttachment();
            feedAttachment.FeedEntityId = recordId;
            feedAttachment.RecordId = cv.id; 
            feedAttachment.Title = cv.Title;
            feedAttachment.Type = 'CONTENT'; 
            attachmentList.add(feedAttachment);
        }
        insert attachmentList;
       
        /*ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
        if (attachmentList == null || cvList == null) { return null; }
        return JSON.serialize(attachmentList);*/
    }
    
    /*
    * Create contentversion from String base64
    * Param - String Type sttachment, file name for new content version file
    */
    
    public static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
            //insert cv;
            return cv;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    
    /*
    Save Question post to TopicAssignment Object
    param : entityId - FeedItem Id.
    param : networkId - Informatica Network Id.
    param : topicId - Community Id.
    return : All community List. 
    */
    public static String saveQuestionPostToTopic(String entityId, String networkId, String topicId){
        try{
            TopicAssignment feedData = new TopicAssignment();
            feedData.EntityId=entityId;
            feedData.NetworkId=networkId;
            feedData.TopicId=topicId;
            insert feedData;
            return feedData.Id;
            
        } catch(Exception e){
            system.debug('Error in saveQuestionPostToTopic : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        } 
    }

    // Tag 7 Start 
    /*
    Update reputation points based on theacgtion performed
    param : userId - FeedItem Id.
    param : productCommunityId - community/topic id.
    return : Void. 
    */
    public static void UpdateReputationPointsForAskAQuestion(String userId, String productCommunityId){
        try{
            List<Topic> topic = [select Id, Name from topic where Id =: productCommunityId Limit 1];
            List<Community_Interactions__c> existingRecord = [select Id, Reputation_Points__c from Community_Interactions__c where User__c =: userId and Id__c =: productCommunityId and Content_type__c = 'Feed Item'];
            List<helpReputationPoint__mdt> reputationPoints = [SELECT Label, Points__c FROM helpReputationPoint__mdt where DeveloperName = 'Ask_a_question'];
            if(existingRecord.size() > 0){
                for (Community_Interactions__c ci : existingRecord) {
                    ci.Reputation_Points__c = ci.Reputation_Points__c + reputationPoints[0].Points__c;
                    update ci;
                }
            }else{
                Community_Interactions__c cn = new Community_Interactions__c();
                cn.Content_type__c = 'Feed Item';
                cn.Reputation_Points__c = reputationPoints[0].Points__c;
                cn.User__c = userId;
                cn.Type__c = topic[0].Name;
                cn.Id__c = productCommunityId;
                insert cn;
            }
            
        } catch(Exception e){
            system.debug('Error in UpdateReputationPointsForAskAQuestion : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        } 
    }
    // Tag 7 End 
    
    // <T1> -start
    /*
    Get discussions for user
    param : userId - User Id.
    param : networkId - Informatica Network Id.
    return : All community List. 
    */
    @AuraEnabled(cacheable=true)
    public static List<DiscussionWrapper> getDiscussion(String networkId, String token){
        String userId = UserInfo.getUserId();
        List<FeedItem> feeds;
        List<DiscussionWrapper> result = new List<DiscussionWrapper>();
        List<help_Infa_Custom_Label__mdt> communityUrl = [SELECT community_url__c FROM help_Infa_Custom_Label__mdt WHERE developerName = 'community_url'];
        try{
            if(userId != ''){
                feeds = [select Id, Title, LastModifiedDate, CreatedBy.Name, Parent.Name, ParentId,  LikeCount, CommentCount from FeedItem where Id != '' and Title != '' and CreatedById =:userId and NetworkScope =:networkId order by LastModifiedDate DESC limit 999];
                for(FeedItem feed : feeds){
                    String Id = feed.Id;
                    List<TopicAssignment> topics = [select Id, TopicId, Topic.Name from TopicAssignment where EntityId =: Id];
                    DiscussionWrapper discussion = new DiscussionWrapper();
                    discussion.Id = Id;
                    discussion.Title = feed.Title;
                    if(topics.size() > 0){
                        discussion.CommunityName = topics[0].Topic.Name;
                    }
                    discussion.CreatedByName = feed.CreatedBy.Name;
                    discussion.LikeCount = feed.LikeCount;
                    discussion.CommentCount = feed.CommentCount;
                    discussion.ModifiedDate = feed.LastModifiedDate.getTime();
                    discussion.URL = communityUrl[0].community_url__c + 'question/'+ Id;
                    if(discussion.CommunityName != null && result.size() <= 8){
                        result.add(discussion);
                    }
                }
            }
            if(result.size() < 8){
                string authorizationHeader = 'Bearer '+token; //T2
                help_Infa_Custom_Label__mdt   endptDetail = [SELECT  Endpoint__c  FROM help_Infa_Custom_Label__mdt  WHERE developerName ='topDiscussions'];
                HttpResponse dataResponse = helpUtilityClass.makeHttpCallout('GET','application/json', endptDetail.Endpoint__c,
                                                                             '',authorizationHeader,'','','',token); 
                String responseString = dataResponse.getBody();
                responseString = responseString.replace('"sfprimary_product__c" :', '"sfprimaryproduct" :');
                responseString = responseString.substringAfter('results"'+' '+':');  
                responseString = responseString.substring(0,responseString.lastIndexOf('}'));  
                List<displayWrapper> resultList = (List<displayWrapper>)JSON.deserialize(responseString, List<displayWrapper>.class);
                List<rawWrapper> rawList = new List<rawWrapper>();
                
                if(!resultList.isEmpty() || test.isRunningTest()){               
                    for(displayWrapper vwrap : resultList){
                        rawList.add(vwrap.raw);
                    }
                }     
                
                for(rawWrapper rwrap : rawList){
                    DiscussionWrapper req = new DiscussionWrapper();
                    req.Id = rwrap.sfid != null ? rwrap.sfid : '';
                    req.Title = rwrap.systitle != null ? rwrap.systitle : '';
                    req.CommunityName = rwrap.athenaproduct != null ? rwrap.athenaproduct[0] : '';
                    req.CreatedByName = rwrap.sfcreatedbyname != null ? rwrap.sfcreatedbyname : '';
                    req.URL = rwrap.printableuri != null ? rwrap.printableuri : '';
                    req.LikeCount = rwrap.sflikecount != null ? rwrap.sflikecount : 0;
                    req.CommentCount = rwrap.sfcommentcount != null ? rwrap.sfcommentcount : 0;
                    req.ModifiedDate = rwrap.sflastmodifieddate;
                    if(req.CommunityName != '' && result.size()< 8){
                        result.add(req);
                    }
                }           
            }
            
            return result;
        } catch(Exception e){
            system.debug('Error in getDiscussion : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        } 
    }
    // <T1> - end
    
    // <T4> - start
    /*
    Delete Hashtag Topic
    param : List<topic> - topics list from trigger.
    return : Void
    */
    @AuraEnabled
    public static void deleteHashtagTopic(List<Topic> topic, String networkId) {
        String NetworkName = '';    
        if(NetworkId != null && !Test.isRunningTest()){
            NetworkName = ConnectApi.Communities.getCommunity(networkId).name;
        }
        String profileName = [select Name from profile where id = :UserInfo.getProfileId()].Name;
        // Tag 6 Start
        if (profileName != 'System Administrator' && NetworkName == System.Label.help_SiteName){
            delete [select id from Topic where id in :topic];
        }
        // Tag 6 End
    }
    
    // <T4> - end
    
    public class DiscussionWrapper{
        @AuraEnabled public String Id;
        @AuraEnabled public String Title;
        @AuraEnabled public String CommunityName;
        @AuraEnabled public String CreatedByName;
        @AuraEnabled public String URL;
        @AuraEnabled public Integer LikeCount;
        @AuraEnabled public Integer CommentCount;
        @AuraEnabled public Long ModifiedDate;
    }
    
    // <T1> - start
    
    public class displayWrapper {        
        @AuraEnabled public rawWrapper raw;        
    }
    
    public class rawWrapper{
        @AuraEnabled public String sfid;
        @AuraEnabled public String systitle;
        @AuraEnabled public List<String> athenaproduct;
        @AuraEnabled public String sfcreatedbyname;
        @AuraEnabled public String printableuri;
        @AuraEnabled public Integer sflikecount;
        @AuraEnabled public Integer sfcommentcount;
        @AuraEnabled public Long sflastmodifieddate;
    }
    // <T1> - end
    
    public class imageReferenceToVersion{
        @AuraEnabled public String key;
        @AuraEnabled public String value;
    }
    
    public class attachmentToList{
        @AuraEnabled public String filename;
        @AuraEnabled public String base64;
    }
    
}