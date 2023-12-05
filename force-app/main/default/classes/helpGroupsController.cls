/*
* Name         :   helpGroupsController
* Author       :   Narpavi Prabu
* Created Date :   04/02/2022
* Description  :   Controller class for group landing and group related actions of IN.

Change History
**********************************************************************************************************
Modified By            Date            Jira No.        Description                                                                     Tag
**********************************************************************************************************
Narpavi Prabu      04/02/2022      N/A             Initial version.                            N/A
Deeksha Shetty    19 April,2022     I2RT-5928     'Sort By' does not sort results in asc/desc when there are filters applied            T1
Deeksha Shetty    19 July,2022      I2RT-6706      Notification criteria - Events                                                       T2  
Saumya Gaikwad    21 July,2022      I2RT-6757      Chapter Leaders Criteria To create Events                                            T3
Saumya Gaikwad    29 Sept,2022      I2RT-7170      Fixed the Missing Product Community Name                                             T4
                                                   tag when Image is added in description
Deeksha Shetty    08 May 2023       I2RT-8345      Ask a Question - Email Notification - Issue observed in New and Update               T5
                                                   Notification email template
Deeksha Shetty    14 June 2023      I2RT-7460      Text entered after “,” comma is not getting saved while creating a new Poll          T6
*/
public without sharing class helpGroupsController {
    
    
    @AuraEnabled
    public static List<GroupListWrapper> getGroupLandingDisplay(String networkId, String userId, String sortvalue){
        try{           
            ConnectApi.Community inCommunity = ConnectApi.Communities.getCommunity(networkId);
            List<GroupListWrapper> groupwraplist = new List<GroupListWrapper>();           
            Map<Id,CollaborationGroup> allgrpmap = new Map<Id,CollaborationGroup>([SELECT Id,Name, CollaborationType,CreatedDate, LastViewedDate,LastFeedModifiedDate,Description, FullPhotoUrl, MemberCount  from CollaborationGroup
                                                                                   WHERE NetworkId = :networkId AND (CollaborationType='Public' OR CollaborationType='Private') ORDER BY Name ASC]);
            
            //following group records       
            List<CollaborationGroupMember> groupfollow = [SELECT id,CollaborationGroupId,MemberId FROM CollaborationGroupMember where MemberId=:userId and CollaborationGroupId IN:allgrpmap.keyset()];
            Map<String,CollaborationGroupMember> grpfollowmap = new Map<String,CollaborationGroupMember>();
            for(CollaborationGroupMember grpmem : groupfollow)
            {
                grpfollowmap.put(grpmem.CollaborationGroupId,grpmem);
            }
            
            if(allgrpmap.size()>0){
                for(CollaborationGroup item :allgrpmap.values()){
                    if(sortvalue == 'mygroup'){
                        if(grpfollowmap.keyset().contains(item.Id) ){    
                            GroupListWrapper wrap = new GroupListWrapper();
                            wrap.Id = item.Id;
                            String titleString = item.Name;
                            Integer maxiSize = 67;
                            if(titleString.length() > maxiSize ){
                                titleString = titleString.substring(0, maxiSize);
                            }
                            
                            if(item.LastFeedModifiedDate != null)
                            {
                                Datetime dt = item.LastFeedModifiedDate;
                                String formattedDate = dt.format('MMM dd, yyyy');
                                wrap.Groupcreateddate= formattedDate;
                            }else{
                                Datetime dt = item.CreatedDate;
                                String formattedDate = dt.format('MMM dd, yyyy');
                                wrap.Groupcreateddate= formattedDate;
                            }
                            DateTime dT = item.CreatedDate;                
                            wrap.stringdate = dT.year()+'-'+dT.month() +'-'+dT.day(); //T1
                            wrap.Name = titleString;
                            wrap.MemberCount=item.MemberCount;
                            wrap.CollaborationType=item.CollaborationType;
                            wrap.Description = item.Description;             
                            wrap.Link = inCommunity.siteUrl +'/s/group/' + item.Id;
                            groupwraplist.add(wrap);      
                            
                        }                        
                    }
                    else if(sortvalue == 'allgroup'){
                        GroupListWrapper wrap = new GroupListWrapper();
                        wrap.Id = item.Id;
                        String titleString = item.Name;
                        Integer maxiSize = 67;
                        if(titleString.length() > maxiSize ){
                            titleString = titleString.substring(0, maxiSize);
                        }
                        
                        if(item.LastFeedModifiedDate !=null ){
                            Datetime dt = item.LastFeedModifiedDate;
                            String formattedDate = dt.format('MMM dd, yyyy');
                            wrap.Groupcreateddate= formattedDate;
                        }else{
                            Datetime dt = item.CreatedDate;
                            String formattedDate = dt.format('MMM dd, yyyy');
                            wrap.Groupcreateddate= formattedDate;
                        }
                        DateTime dT = item.CreatedDate;                
                        wrap.stringdate = dT.year()+'-'+dT.month() +'-'+dT.day(); //I2RT-5928
                        
                        wrap.Name = titleString;
                        wrap.MemberCount=item.MemberCount;
                        wrap.CollaborationType=item.CollaborationType;
                        wrap.Description = item.Description;                                                 
                        wrap.Link = inCommunity.siteUrl +'/s/group/' + item.Id;                  
                        groupwraplist.add(wrap);    
                        system.debug(wrap);                         
                    }                                    
                }
                
            }           
            
            return groupwraplist;
        }
        
        Catch(Exception e){
            system.debug('Error in Group Landing Display : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    
    @AuraEnabled
    public static List<GroupListWrapper> getsortbygroup(String networkId,String userId,String sortFilter,String sortIdeasVal){
        try{
            
            ConnectApi.Community inCommunity = ConnectApi.Communities.getCommunity(networkId);
            List<CollaborationGroup> grplist = new List<CollaborationGroup>();
            List<GroupListWrapper> groupwraplist = new List<GroupListWrapper>();
            
            if(sortFilter == 'Ascending'){
                grplist = [SELECT Id,Name, CollaborationType, LastViewedDate,Description,CreatedDate,LastFeedModifiedDate, FullPhotoUrl, MemberCount  from CollaborationGroup
                           WHERE NetworkId = :networkId AND (CollaborationType='Public' OR CollaborationType='Private')  ORDER BY Name ASC] ;                
            }
            else{
                grplist = [SELECT Id,Name, CollaborationType, LastViewedDate,Description,CreatedDate,LastFeedModifiedDate, FullPhotoUrl, MemberCount  from CollaborationGroup
                           WHERE NetworkId = :networkId AND (CollaborationType='Public' OR CollaborationType='Private')  ORDER BY  Name DESC] ; 
            }
            Map<Id,CollaborationGroup> allgroupmap = new Map<Id,CollaborationGroup>();
            for(CollaborationGroup grp : grplist){
                allgroupmap.put(grp.Id,grp);
            }                        
            
            
            List<CollaborationGroupMember> followgrplst = [SELECT id,CollaborationGroupId from CollaborationGroupMember where MemberId=:userId and CollaborationGroupId IN:allgroupmap.keyset()];
            Map<String,CollaborationGroupMember> followgrpmap = new Map<String,CollaborationGroupMember>();
            System.debug('followgrplst='+followgrplst);
            for(CollaborationGroupMember grpmem : followgrplst){
                followgrpmap.put(grpmem.CollaborationGroupId,grpmem);
            }
            
            if(grplist.size()>0){                
                for(CollaborationGroup item :grplist){
                    if(sortIdeasVal=='mygroup'){
                        if(followgrpmap.keyset().contains(item.Id)){
                            System.debug('Enterd here');
                            GroupListWrapper wrap = new GroupListWrapper();
                            wrap.Id = item.Id;
                            String titleString = item.Name;
                            Integer maxiSize = 67;
                            if(titleString.length() > maxiSize ){
                                titleString = titleString.substring(0, maxiSize);
                            }
                            if(item.LastFeedModifiedDate !=null){
                                Datetime dt = item.LastFeedModifiedDate;
                                String formattedDate = dt.format('MMM dd, yyyy');
                                wrap.Groupcreateddate= formattedDate;
                            }else{
                                Datetime dt = item.CreatedDate;
                                String formattedDate = dt.format('MMM dd, yyyy');
                                wrap.Groupcreateddate= formattedDate;
                            }
                            wrap.Name = titleString;
                            wrap.Description = item.Description;      
                            wrap.CollaborationType = item.CollaborationType; 
                            wrap.Link = inCommunity.siteUrl +'/s/group/' + item.Id;                
                            groupwraplist.add(wrap); 
                            
                        }
                    }
                    else if(sortIdeasVal == 'allgroup'){
                        GroupListWrapper wrap = new GroupListWrapper();
                        wrap.Id = item.Id;
                        String titleString = item.Name;
                        Integer maxiSize = 67;
                        if(titleString.length() > maxiSize ){
                            titleString = titleString.substring(0, maxiSize);
                        }
                        
                        if(item.LastFeedModifiedDate !=null ){
                            Datetime dt = item.LastFeedModifiedDate;
                            String formattedDate = dt.format('MMM dd, yyyy');
                            wrap.Groupcreateddate= formattedDate;
                        }else{
                            Datetime dt = item.CreatedDate;
                            String formattedDate = dt.format('MMM dd, yyyy');
                            wrap.Groupcreateddate= formattedDate;
                        }
                        wrap.Name = titleString;
                        wrap.Description = item.Description;   
                        wrap.CollaborationType = item.CollaborationType;  
                        wrap.MemberCount = item.MemberCount;  
                        wrap.Link = inCommunity.siteUrl +'/s/group/' + item.Id;                
                        groupwraplist.add(wrap); 
                        
                    }
                    
                }
                System.debug('groupwraplist='+groupwraplist);                
                
            }
            return groupwraplist;
        }
        Catch(Exception e){
            system.debug('Error in sort my ideas Display : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<String> getTypePicklistValues(){
        try{
            Schema.DescribeFieldResult objFieldDescribe = CollaborationGroup.CollaborationType.getDescribe();
            List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
            List<String> groupType = new List<String>();
            for (Schema.PicklistEntry objPickList : lstPickListValues) {
                if(objPickList.getValue() !='Unlisted') 
                {
                    groupType.add(objPickList.getLabel()); 
                }
                
            }
            return groupType;
            
        }
        Catch(Exception e){
            system.debug('Error in Picklist values : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
        
    }
    
    
    @AuraEnabled(Cacheable=true)
    public static filterWrappers fetchFilterValues(){
        try{                                    
            List<String> typeFilterlist = getTypePicklistValues();            
            filterWrappers wrap = new filterWrappers();
            wrap.typeFilter = typeFilterlist;  
            return wrap;            
        }
        Catch(Exception e){
            system.debug('Error in Fetch Filters : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    @AuraEnabled
    public static String joinGroup(String grpId, String user, String networId){
        try{
            CollaborationGroupMember record = new CollaborationGroupMember(
                //NetworkId=networId,
                CollaborationGroupId=grpId,
                MemberId=user);
            insert record;
        }
        catch(Exception e){
            system.debug('Error in joinGroup: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
        return 'success';
    }
    
    @AuraEnabled
    public static String unfollowgroup(String grpId, String user, String networId){
        try{
            List<CollaborationGroupMember> result = new List<CollaborationGroupMember>();
            result = [SELECT Id,CollaborationGroupId FROM CollaborationGroupMember where NetworkId =: networId and CollaborationGroupId =: grpId and MemberId =: user];
            delete result;
        }
        catch(Exception e){
            system.debug('Error in Unfollowgroup : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
        return 'success';
    }
    
    @AuraEnabled(cacheable=true)
    public static Integer getfollowingGroup(String grpId, String user, String networId){
        try{
            List<CollaborationGroupMember> result = new List<CollaborationGroupMember>();
            result = [SELECT Id FROM CollaborationGroupMember where NetworkId =: networId and CollaborationGroupId =: grpId and MemberId =: user limit 1000];
            return result.size();
        }
        catch(Exception e){
            system.debug('Error in getFollowingCommunity : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static string getgroupType(String grpId){
        try{            
            
            String grptype = [Select Id,CollaborationType from CollaborationGroup where Id=:grpId].CollaborationType;            
            return grptype;
        }
        catch(Exception e){
            system.debug('Error in getgroupType : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    @AuraEnabled
    public static Integer getgroupmember(String userId, String grpId){
        try{
            List<CollaborationGroupMember> lstgrp= new List<CollaborationGroupMember>([Select id,MemberId from CollaborationGroupMember where MemberId =: userId and CollaborationGroupId=:grpId]);
            return lstgrp.size();
            
        }
        Catch(Exception e){
            system.debug('Error in UserType : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());             
        }
    }
    
    @AuraEnabled
    public static String getUserType(String userId){
        try{
            String Usertype = [Select UserType from User where Id=:userId].UserType;
            return Usertype;
            
        }
        Catch(Exception e){
            system.debug('Error in UserType : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());             
        }
    }
    
    @AuraEnabled
    public static Integer getgroupAdmin(String userId, String grpId){
        try{
            //T3 : adding CollaborationRole = Admin condition
            List<CollaborationGroupMember> lstgrp= new List<CollaborationGroupMember>([Select id, CollaborationGroup.ownerid from CollaborationGroupMember where (CollaborationGroup.ownerid =: userId or (memberId = :userId and CollaborationRole = 'Admin')) and CollaborationGroupId =:grpId]);
            return lstgrp.size();
            
        }
        Catch(Exception e){
            system.debug('Error in UserType : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());             
        }
    }
    
    
    @AuraEnabled(cacheable=true)
    public static String getGroupName(String commId){
        if(commId == ''){
            return '';
        }
        try{
            CollaborationGroup comm = [SELECT Id, Name, Description FROM CollaborationGroup where Id =: commId];
            return comm.Name;
        } catch(Exception e){
            system.debug('Error in getCommunityName : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static String createPoll(string grpId,String choice1,string body,Object jsonOfListOfChoice){
        try{
            if( (body!=null ||body!='')){
                String jsonchoice=JSON.serialize(jsonOfListOfChoice);
                /*T6 starts*/
                List<PollWrapper> resultList = (List<PollWrapper>)JSON.deserialize(jsonchoice, List<PollWrapper>.class);
                System.debug('resultList='+resultList);
                
                /*string jsonchoice1=jsonchoice.replace('"','');
                List<String> splitjsonchoice = jsonchoice1.split(',');
                List<String> firstchoice = new List<String> ();
                List<String> secondchoice = new List<String> ();*/
                list<String> finalchoice=new List<String>();
                
                system.debug('choice1'+choice1);
                if(choice1 !=null){
                    finalchoice.add(choice1);
                }
                
                if(resultList.size()>0){
                    for(PollWrapper pw : resultList){
                        finalchoice.add(pw.ChoiceBody);
                    }
                }
                System.debug('finalchoice='+finalchoice);
                /*T6 ends*/

                /*for(String ch:splitjsonchoice){  
                    system.debug('ch'+ch);
                    if(ch.contains('ChoiceBody')){
                        firstchoice= ch.split(':');
                        System.debug('firstchoice='+firstchoice);
                        secondchoice.addall(firstchoice);
                    }
                }
                
                System.debug('secondchoice='+secondchoice);
                for (String ch1: secondchoice){
                    if(!ch1.contains('ChoiceBody')){
                        finalchoice.add(ch1);
                    }
                }*/
                
                feedelement(body,finalchoice,grpId);
                return feedpollid;
            }
            else{
                return null;
            }            
            
        }
        Catch(Exception e){
            system.debug('Error in Poll creation : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
        
    }
    
    public static ConnectApi.FeedElement feedelement(string body,List<String> finalchoice, String grpId)
    {
        ConnectApi.PollCapabilityInput pollCapability = new ConnectApi.PollCapabilityInput();
        //pollCapability.choices =jsonOfListOfChoice;
        pollCapability.choices =finalchoice;
        
        ConnectApi.FeedElementCapabilitiesInput itemCapabilities = new ConnectApi.FeedElementCapabilitiesInput();
        itemCapabilities.poll = pollCapability;
        
        ConnectApi.FeedItemInput feedItem = new ConnectApi.FeedItemInput(); 
        feedItem.feedElementType = ConnectApi.FeedElementType.FeedItem; 
        // This is the type for a normal post.
        feedItem.capabilities = itemCapabilities;
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();        
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        feedItem.body = messageBodyInput;
        
        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = body;
        messageBodyInput.messageSegments.add(textSegment);
        
        feedItem.subjectId = grpId;
        ConnectApi.FeedElement feedElement;
        if(!Test.isRunningTest()){
            feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItem);
            feedpollid = feedElement.id;
        }
        return feedElement;
    }
    
    
    @AuraEnabled
    public static String saveQuestionPost(String title, String body, String parentId,String fileList){
        try{
            /*Tag-4 Starts*/
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
            /*Tag-4 Ends*/
            FeedItem feedData = new FeedItem();
            feedData.Title=title;
            feedData.ParentId=parentId;
            feedData.Body= body;
            feedData.NetworkScope=Network.getNetworkId();
            feedData.Type='QuestionPost';
            feedData.IsRichText=true;
            insert feedData;
            
            /* T5 starts*/
            if(feedData.Id != null && fileList!=null){
                helpQuestions.uploadFile(fileList,feedData.Id);
            }
            /* T5 ends*/
            return feedData.Id;
            
        } catch(Exception e){
            system.debug('Error in saveQuestionPost: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Error in saveQuestionPost: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString() );            
        } 
    }
    
    @AuraEnabled
    public static ConnectApi.FeedElement feedelement1(string title,string body,String parentId){
        
        String bodytemp=body.replaceAll('<[^>]*>', '');
        ConnectApi.QuestionAndAnswersCapabilityInput qaCapability = new  ConnectApi.QuestionAndAnswersCapabilityInput();
        //pollCapability.choices =jsonOfListOfChoice;
        qaCapability.questionTitle =title;
        
        
        ConnectApi.FeedElementCapabilitiesInput itemCapabilities = new ConnectApi.FeedElementCapabilitiesInput();
        itemCapabilities.questionAndAnswers = qaCapability;
        
        ConnectApi.FeedItemInput feedItem = new ConnectApi.FeedItemInput(); 
        feedItem.feedElementType = ConnectApi.FeedElementType.FeedItem; 
        // This is the type for a normal post.
        feedItem.capabilities = itemCapabilities;
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();        
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        feedItem.body = messageBodyInput;
        
        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = bodytemp;
        messageBodyInput.messageSegments.add(textSegment);
        
        
        feedItem.subjectId = parentId;
        ConnectApi.FeedElement feedElement;
        if(!Test.isRunningTest()){
            feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItem);
            feedid = feedElement.id;
        }
        return FeedElement;
    }
    
    
    @AuraEnabled
    public static String createGroup(String networkId,String title,String type,String description){
        try{
            if((title != null || title!='' ) && (description != null || description != '') ){
                CollaborationGroup grp = new CollaborationGroup();
                grp.Name= title;
                grp.Description = description;
                grp.CollaborationType = type;
                grp.NetworkId=networkId;
                insert grp;
                
                return grp.id;
                
            }
            else{
                return null;
            }            
            
        }
        Catch(Exception e){
            system.debug('Error in Announcement creation : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    
    @AuraEnabled
    public static String createAnnouncement(String title,String description,String startDate,String endDate,String groupId){
        try{
            if((title != null || title!='' ) && (description != null || description != '') ){
                Alerts_Announcements__c announcement = new Alerts_Announcements__c();
                announcement.AnnouncementDescription__c = description;
                announcement.Name = title;
                announcement.Start_Date__c = Date.valueOf(startDate);
                announcement.End_Date__c = Date.valueOf(endDate);
                announcement.User_Group__c = groupId;
                announcement.RecordTypeId= Schema.SObjectType.Alerts_Announcements__c.getRecordTypeInfosByName().get('IN - Announcement').getRecordTypeId();
                insert announcement;
                return announcement.Id ;
            }
            else{
                return null;
            }            
            
        }
        Catch(Exception e){
            system.debug('Error in Announcement creation : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    @AuraEnabled
    public static String updateAnnouncement(String Id, String title,String description,String startDate,String endDate,String groupId){
        try{
            if((title != null || title!='' ) && (description != null || description != '') ){
                Alerts_Announcements__c announcement = new Alerts_Announcements__c();
                announcement.Id = Id;
                announcement.AnnouncementDescription__c = description;
                announcement.Name = title;
                announcement.Start_Date__c = Date.valueOf(startDate);
                announcement.End_Date__c = Date.valueOf(endDate);
                announcement.User_Group__c = groupId;
                update announcement;
                return announcement.Id ;
            }
            else{
                return null;
            }            
            
        }
        Catch(Exception e){
            system.debug('Error in Announcement update : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    
    @AuraEnabled
    public static help_Infa_Custom_Label__mdt leadUserGroup(){
        try {
            help_Infa_Custom_Label__mdt recordlist = [SELECT Lead_User_Group_Link__c FROM help_Infa_Custom_Label__mdt WHERE developerName = 'lead_a_user_group_link'];
            return recordlist;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static help_Infa_Custom_Label__mdt startausergroup(){
        try{
            help_Infa_Custom_Label__mdt recordlist = [SELECT developerName,Lead_User_Group_Link__c FROM help_Infa_Custom_Label__mdt WHERE developerName = 'start_a_user_group_link'];
            return recordlist;
        }
        Catch(Exception e){
            system.debug('Error in metadata : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());             
        }
    }
    
    @AuraEnabled
    public Static String sendMail(String grpId, String userId){
        try{
            String adminemail;
            String username;
            String groupname;
            String groupType;
            String useremail;
            if(grpId != null && userId !=null){
                CollaborationGroup grp =[Select id,Name,ownerId, owner.email,CollaborationType from CollaborationGroup where id=:grpId];
                User u=[select id,Name, email from User where id=:userId];
                adminemail=grp.owner.email;
                groupname=grp.Name;
                groupType=grp.CollaborationType; 
                username=u.Name;
                useremail=u.email;
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                System.debug('adminemail > ' + adminemail);
                mail.setToAddresses(new List<String>{adminemail});
                
                EmailTemplate emailTemplate =[Select Id from EmailTemplate where DeveloperName = 'help_Request_For_UG'];
                mail.setTemplateID(emailTemplate.Id);
                mail.setWhatId(grpId);
                mail.settargetobjectid(userId);
                mail.setSaveAsActivity(false);
                mail.setTreatTargetObjectAsRecipient(false);
                /*mail.setSubject('Join the Group Request'); 
                //Create  Body
                String strMetadata = ''; 
                strMetadata += 'Hi, \n'; strMetadata += 'The user requested to join the group. \n'; strMetadata +='Name:'+username+'\n';   
                strMetadata +='Email Address:'+useremail+'\n'; strMetadata +='Group Name:'+groupname+'\n'; strMetadata +='Group Type:'+groupType +'\n' ;
                system.debug(strMetadata);   mail.setHtmlBody(strMetadata);*/
                
                //Send Email
                Messaging.SendEmailResult[] er = Messaging.sendEmail(new Messaging.Email[] { mail });
                system.debug('Email Sent'+er);
            }
            
            return 'Email Sent';
            
        }
        Catch(Exception e){
            system.debug('Send Email Failed : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }              
    }
    
    @AuraEnabled(cacheable=true)
    public static List<GroupListWrapper> getJoinGroupLanding(String networkId, String sortvalue){
        try{           
            ConnectApi.Community inCommunity = ConnectApi.Communities.getCommunity(networkId);
            List<GroupListWrapper> groupwraplist = new List<GroupListWrapper>();
            Map<Id,CollaborationGroup> allgrpmap = new Map<Id,CollaborationGroup>([SELECT Id,Name, CollaborationType, LastViewedDate,Description, FullPhotoUrl, MemberCount  from CollaborationGroup
                                                                                   WHERE NetworkId = :networkId AND (CollaborationType='Public' OR CollaborationType='Private')  ORDER BY Name ASC LIMIT 9]);
            //Map<Id,CollaborationGroup> alljoingrpmap = new Map<Id,CollaborationGroup>([SELECT Id,Name, CollaborationType from CollaborationGroup WHERE NetworkId = :networkId AND (CollaborationType='Public' OR CollaborationType='Private')]);
            
            //List<FeedItem> joinGroups = [SELECT id,CollaborationGroupId,MemberId FROM FeedItem where CollaborationGroupId IN:alljoingrpmap.keyset()];
            
            //following group records       
            List<CollaborationGroupMember> groupfollow = [SELECT id,CollaborationGroupId,MemberId FROM CollaborationGroupMember where CollaborationGroupId IN:allgrpmap.keyset() LIMIT 9];
            Map<String,CollaborationGroupMember> grpfollowmap = new Map<String,CollaborationGroupMember>();
            for(CollaborationGroupMember grpmem : groupfollow){
                grpfollowmap.put(grpmem.CollaborationGroupId,grpmem);
            }
            
            if(allgrpmap.size()>0){
                for(CollaborationGroup item :allgrpmap.values()){
                    GroupListWrapper wrap = new GroupListWrapper();
                    wrap.Id = item.Id;
                    String titleString = item.Name;
                    Integer maxiSize = 67;
                    if(titleString.length() > maxiSize ){
                        titleString = titleString.substring(0, maxiSize);
                    }
                    wrap.Name = titleString;
                    wrap.MemberCount=item.MemberCount;
                    wrap.CollaborationType=item.CollaborationType;
                    wrap.Description = item.Description;   
                    wrap.Link = inCommunity.siteUrl +'/s/group/' + item.Id;                  
                    groupwraplist.add(wrap);
                    system.debug(wrap);                                   
                }
                
            }           
            
            return groupwraplist;
        }
        
        Catch(Exception e){
            system.debug('Error in idea Landing Display : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    @AuraEnabled
    public static String createGroupEvent(String strEvent, String grpId) {
        try{
            Event objEvent = new Event();
            if(strEvent <> null && strEvent <> ''){
                objEvent = (Event) JSON.deserialize(strEvent, event.class);
                User currentUser = [Select id, profile.name from user where id = :UserInfo.getUserId() limit 1];
                Boolean createRelation = false;
                if(currentUser.profile.name == 'External Identity Community'){
                    List<CollaborationGroup> groupRecord = [select id, ownerId from CollaborationGroup where id = :grpId limit 1];
                    objEvent.ownerId = groupRecord[0].ownerId;
                    createRelation = true;
                }
                System.debug('UserInfo.getUserId() > ' + UserInfo.getUserId());
                if(objEvent != null){
                    //Set event as public by default
                    objEvent.IsVisibleInSelfService = true;
                    objEvent.Event_Type__c = 'User Group';
                    objEvent.User_Group_Id__c= grpId;
                    insert objEvent;
                    system.debug('objEvent >> '+objEvent);
                    //Add current user to Event Relation
                    if(createRelation){
                        EventRelation objEventRelation = new EventRelation();
                        objEventRelation.EventId = objEvent.Id;
                        objEventRelation.RelationId = UserInfo.getUserId();
                        objEventRelation.Status ='Accepted';
                        insert objEventRelation;
                    }
                    
                }
            }
            
            return objEvent.Id;
        }
        catch (Exception e) {
            system.debug('Error in createGroupEvent : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString() + 'on line number > ' + e.getLineNumber());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }
        
    }
    
    //T3
    @InvocableMethod(label='Send SE Email Notification') 
    public static void sendMailToUser(List<GroupWrapper> gpList){
        try{
            EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName=:gpList[0].EmailTemplate];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{gpList[0].MemberMailId});
            mail.setTemplateID(template.Id);
            mail.setWhatId(gpList[0].groupid);
            mail.settargetobjectid(gpList[0].MemberId);
            mail.setSaveAsActivity(false);
            //Send Email
            Messaging.SendEmailResult[] er = Messaging.sendEmail(new Messaging.Email[] { mail });
            system.debug(er);
            
        }
        Catch(Exception e){
            system.debug('Send Email Failed : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }              
        
        
    }
    
    @AuraEnabled(cacheable=true)
    public static string getUserGroupId(String groupName, string networkId){
        String userGroupId = '';
        try{
            
            userGroupId = [SELECT Id, Name FROM CollaborationGroup where Name =:groupName and NetworkId =:networkId].Id;
            
        } catch(Exception e){
            system.debug('Error in getUserGroupId: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
        return userGroupId; 
    }
    
    //T2:Notification criteria - Events 
    @AuraEnabled
    public Static String sendMailPostEventCreation(String groupId, String eventId,String eventAction){
        try{
            List<Id> allUserIds = new List<Id>();
            String sitelabel = System.Label.IN_CommunityName;
            List<Messaging.Email> lstMails = new List<Messaging.Email>();
            String GroupName = [Select Name from CollaborationGroup where Id=:groupId ].Name;
            List<CollaborationGroupMember> groupMembersList = [SELECT MemberId FROM CollaborationGroupMember 
                                                               where CollaborationGroupId =:groupId ];
            for(CollaborationGroupMember memb : groupMembersList ){
                allUserIds.add(memb.MemberId);
            }
            List<user> getGroupMemberEmails = [Select Id, email from user where Id IN:allUserIds];            
            List<Event> objEvent1 = [Select Id,Subject,Description,StartDateTime,Type,ActivityDate,User_Group_Id__c,
                                     EndDateTime,Location,IsVisibleInSelfService,Event_Type__c from Event 
                                     where Id=:eventId];
            
            Event objEvent = objEvent1[0];
            String activitydate = objEvent.StartDateTime.format('EEE')+', '+objEvent.StartDateTime.day()+' '+objEvent.StartDateTime.format('MMM')+' '+objEvent.StartDateTime.year();
            EmailTemplate emailTemplate = [SELECT Id,HtmlValue, Body, Subject, Description FROM EmailTemplate where name = 'UG Post Event Creation'];
            OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address = 'no-reply@informatica.com'];
            
            //Set To Address
            for (User usr :getGroupMemberEmails){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSubject(GroupName+' : ' +objEvent.subject);                
                mail.setToAddresses(new List<String>{usr.email});
                mail.setOrgWideEmailAddressId(owea.Id);                
                mail.setTemplateID(emailTemplate.Id);
                mail.setSaveAsActivity(false);
                mail.setTreatTargetObjectAsRecipient(false);
                
                String htmlBody = emailTemplate.HtmlValue;
                String plainBody = emailTemplate.Body;
                
                if(eventAction=='Modify'){
                    htmlBody = htmlBody.replace('UGEventAction','The event details have been updated');
                    plainBody = plainBody.replace('UGEventAction','The event details have been updated');
                }
                else{
                    htmlBody = htmlBody.replace('UGEventAction','A new event has been created');
                    plainBody = plainBody.replace('UGEventAction','A new event has been created');
                }
                
                htmlBody = htmlBody.replace('UGName',GroupName);
                htmlBody = htmlBody.replace('EventTitle',objEvent.subject);
                htmlBody = htmlBody.replace('EventDate',activitydate);
                htmlBody = htmlBody.replace('EventDescription',objEvent.Description);
                htmlBody = htmlBody.replace('EventLocation',objEvent.Location);
                htmlBody = htmlBody.replace('EventUrl',sitelabel+'eventdetails?id=' + objEvent.Id);
                
                plainBody = plainBody.replace('UGName',GroupName);
                plainBody = plainBody.replace('EventTitle',objEvent.subject);
                plainBody = plainBody.replace('EventDate',activitydate);
                plainBody = plainBody.replace('EventDescription',objEvent.Description);
                plainBody = plainBody.replace('EventLocation',objEvent.Location);
                plainBody = plainBody.replace('EventUrl',sitelabel+'eventdetails?id=' + objEvent.Id);
                
                mail.setHtmlBody(htmlBody);
                mail.setPlainTextBody(plainBody);
                lstMails.add(mail);
            }
            //Send Email
            Messaging.sendEmail(lstMails);
            return 'Email Sent';
            
        }
        Catch(Exception e){
            system.debug('Send Email Failed : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }              
    }
    
    
    
    
    
    Public class GroupWrapper{
        @InvocableVariable(label='Group Id' )
        public String groupid;
        @InvocableVariable(label='network id' )
        public String networkid;
        @InvocableVariable(label='group type' )
        public String grouptype;
        @InvocableVariable(label='Member id')
        public String MemberId;
        @InvocableVariable(label='Member mail id')
        public String MemberMailId;
        @InvocableVariable(label='Email Template')
        public String EmailTemplate;
    }
    
    
    public class GroupListWrapper{
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String Description;
        @AuraEnabled public String CreatedDate;
        @AuraEnabled public Integer MemberCount;
        @AuraEnabled public String CollaborationType;
        @AuraEnabled public String Link;  
        @AuraEnabled public String Groupcreateddate;
        @AuraEnabled public String stringdate;
        
    }
    
    public static   String feedid;
    public static   String feedpollid;
    
    public class filterWrappers{       
        @AuraEnabled public List<String> typeFilter;
        
    }
    
    
    /* T6 */
    public class PollWrapper{
        @AuraEnabled public String ChoiceBody ;   
    }
}