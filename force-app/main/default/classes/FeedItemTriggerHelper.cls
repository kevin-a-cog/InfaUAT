/*
Class:          FeedItemTriggerHelper
@Author:        balajip
@Created Date:  09-Nov-21
@Description:   Helper class for FeedItem Trigger
*/

/*
    Change History
    ***********************************************************************************************************************************************
    ModifiedBy            Date          JIRA No.        Description                                                                             Tag

    Saurabh Khandelwal    10-Mar-2022   IPUE-160        update field of est summary,output fields based on feed item insert,delete           <T1>
    Utkarsh Jain          25-May-2023   I2RT-8161       Changing the logic in Top participants in product community.                         2  
    Shashikanth           14-Jun-2023   I2RT-8533       GEMS - Chatter Post should also stop the GEMS Timer                                  <T03>
    ***********************************************************************************************************************************************
*/
public class FeedItemTriggerHelper { 
    //I2RT-4422
    public void updateParentEngagement(List<FeedItem> FeedItems){
        Set<Id> setEngagementId = new Set<Id>();
        for(FeedItem FeedItem : FeedItems){
            if('Engagement__c'.equals(String.valueOf(FeedItem.ParentId.getSObjectType()))){
                setEngagementId.add(FeedItem.ParentId);
            }
        } 
        
        EngagementService.updateLastActivity(setEngagementId);
        
        //<T03>
        list<Engagement__c> lstEngagementToUpdate = new list<Engagement__c>();  
        for(Engagement__c oEng : [Select id,Status__c,Dev_Active_Engaged_Start_Time__c From Engagement__c Where Id IN :setEngagementId]){
            if(oEng.Status__c == 'Active Engaged'){
                oEng.Dev_Active_Engaged_Start_Time__c = system.now();
                lstEngagementToUpdate.add(oEng);
            }
                
        }
        
        if(lstEngagementToUpdate.size() > 0){
            UPDATE lstEngagementToUpdate;
        }
        //</T03>
    }

    // Tag 2 Start
    public void updateReputationPoints(List<FeedItem> FeedItems){
        List<helpReputationPoint__mdt> reputationPoints = [SELECT Label, Points__c FROM helpReputationPoint__mdt where DeveloperName = 'Ask_a_question'];
        for(FeedItem FeedItem : FeedItems){
            if(FeedItem.Status == 'Published' && FeedItem.Revision == 1 && FeedItem.NetworkScope == System.Label.IN_NetworkID){
                List<TopicAssignment> topicId = [select Id, TopicId from TopicAssignment where EntityId =: FeedItem.Id];
                if(topicId.size() > 0){
                List<Topic> topicName = [select Id, Name from Topic where Id =: topicId[0].TopicId limit 1];
                List<Community_Interactions__c> existingRecord = [select Id, Reputation_Points__c from Community_Interactions__c where User__c =: FeedItem.CreatedById and Id__c =: topicId[0].TopicId and Content_type__c = 'Feed Item'];
                if(existingRecord.size() > 0){
                    for (Community_Interactions__c ci : existingRecord) {
                        ci.Reputation_Points__c = ci.Reputation_Points__c + reputationPoints[0].Points__c;
                        update ci;
                    }
                }else{
                    Community_Interactions__c cn = new Community_Interactions__c();
                    cn.Content_type__c = 'Feed Item';
                    cn.Reputation_Points__c = reputationPoints[0].Points__c;
                    cn.User__c = FeedItem.CreatedById;
                    cn.Type__c = topicName[0].Name;
                    cn.Id__c = topicId[0].TopicId;
                    insert cn;
                }   
            }
        }
    }
    }

    public void RemovePointsForRejectedPost(List<FeedItem> FeedItems){
        List<String> feedIdList = new List<String>();
        List<helpReputationPoint__mdt> reputationPoints = [SELECT Label, Points__c FROM helpReputationPoint__mdt where DeveloperName = 'Ask_a_question'];
        for(FeedItem FeedItem : FeedItems){
            if(!(FeedItem.Status == 'PendingReview' && FeedItem.Revision == 1) && FeedItem.NetworkScope == System.Label.IN_NetworkID){
                List<TopicAssignment> topicId = [select Id, TopicId from TopicAssignment where EntityId =: FeedItem.Id];
                if(topicId.size() > 0){
                List<Topic> topicName = [select Id, Name from Topic where Id =: topicId[0].TopicId limit 1];
                List<Community_Interactions__c> existingRecord = [select Id, Reputation_Points__c from Community_Interactions__c where User__c =: FeedItem.CreatedById and Id__c =: topicId[0].TopicId and Content_type__c = 'Feed Item'];
                if(existingRecord.size() > 0){
                    for (Community_Interactions__c ci : existingRecord) {
                        if(ci.Reputation_Points__c > reputationPoints[0].Points__c){
                            ci.Reputation_Points__c = ci.Reputation_Points__c - reputationPoints[0].Points__c;
                            update ci;
                        }else{
                            delete ci;
                        }
                    }
                } 
                feedIdList.add(FeedItem.Id);
            }
        }
        }
        List<FeedComment> feedComments = [Select Id, FeedItemID from FeedComment where FeedItemId in: feedIdList];
        if(feedComments.size() > 0){
            delete feedComments;
        }
    }

    // Tag 2 End
    
    /*
     * method updateParentEstimateSummary
     * @param FeedItems: list of feedItems which initiated the trigger
     * @description: update feed internal user and feed external user field of est summary and est output based on feed item.
     */
    public void updateParentEstimateSummary(List<FeedItem> FeedItems){
        
        //fetching feed creator ids.
        Set<Id>userIds=new Set<Id>();
        Set<Id>estSummIds=new Set<Id>();
        Set<Id>estOutputIds=new Set<Id>();
        List<FeedItem>feedItemsList=new List<FeedItem>();
        for(FeedItem FeedItem : FeedItems){
            
            if('Estimation_Summary__c'.equals(String.valueOf(FeedItem.ParentId.getSObjectType()))){
                estSummIds.add(FeedItem.ParentId); 
                feedItemsList.add(FeedItem);
                userIds.add(FeedItem.CreatedById);
            }
            else if('Estimation_Output__c'.equals(String.valueOf(FeedItem.ParentId.getSObjectType()))){
                estOutputIds.add(FeedItem.ParentId);
                feedItemsList.add(FeedItem);
                userIds.add(FeedItem.CreatedById);
            }
        }
        
        if(userIds.size()>0){
            
            Map<Id,User>userIdToUserMap=new Map<Id,User>([SELECT Id,UserType FROM User WHERE Id IN : userIds]);
            
            //quering estimation summary and estimation output records.
            Map<Id,Estimation_Summary__c>estSummMap=new Map<Id,Estimation_Summary__c>([SELECT Feed_Internal_User__c,Feed_External_User__c
                                                                                       FROM Estimation_Summary__c WHERE Id IN :estSummIds ]);
            
            Map<Id,Estimation_Output__c>estOutMap=new Map<Id,Estimation_Output__c>([SELECT Feed_Internal_User__c,Feed_External_User__c
                                                                                    FROM Estimation_Output__c WHERE Id IN :estOutputIds ]);

            List<sObject>estSummAndOutList=new List<sObject>();
            
            //iterating stored feed items to check for est summ or est output field updates
            for(FeedItem feed : feedItemsList){
                
                if('Estimation_Summary__c'.equals(String.valueOf(feed.ParentId.getSObjectType()))){
                    //checking if feed is for all user.
                    if(feed.Visibility=='AllUsers'){
                        
                        if(!(estSummMap.get(feed.ParentId).Feed_Internal_User__c && estSummMap.get(feed.ParentId).Feed_External_User__c))
                        	estSummAndOutList.add(new Estimation_Summary__c(Id=feed.ParentId,Feed_Internal_User__c=true,
                                                                       Feed_External_User__c=true));
                    }
                    else if(feed.Visibility=='InternalUsers')
                    {
                        if(!estSummMap.get(feed.ParentId).Feed_Internal_User__c)
                        	estSummAndOutList.add(new Estimation_Summary__c(Id=feed.ParentId,Feed_Internal_User__c=true));
                    }                    
                    
                }
                else if('Estimation_Output__c'.equals(String.valueOf(feed.ParentId.getSObjectType()))){
                    //checking if feed is for all user.
                    if(feed.Visibility=='AllUsers'){
                        
                        if(!(estOutMap.get(feed.ParentId).Feed_Internal_User__c && estOutMap.get(feed.ParentId).Feed_External_User__c))
                        	estSummAndOutList.add(new Estimation_Output__c(Id=feed.ParentId,Feed_Internal_User__c=true,
                                                                       Feed_External_User__c=true));
                    }
                    else if(feed.Visibility=='InternalUsers')
                    {
                        if(!estOutMap.get(feed.ParentId).Feed_Internal_User__c)
                        	estSummAndOutList.add(new Estimation_Output__c(Id=feed.ParentId,Feed_Internal_User__c=true));
                    } 
                    
                }
            }
            if(estSummAndOutList.size()>0){
                update estSummAndOutList;
            }
        }
    }
    
    /*
     * method checkForExistingFeed
     * @param FeedItems: list of feedItems which initiated the trigger
     * @description: check for any feed exist on parent est summary or output when any feed is deleted otherwise set the 
     *               respective fields to false.
     */
    public void checkForExistingFeed(List<FeedItem> FeedItems){
        
        Set<Id>estSummIds=new Set<Id>();
        Set<Id>estOutputIds=new Set<Id>();
        List<sObject>recordsToBeUpdated=new List<sObject>();
        
        Map<String,Estimation_Summary__c> estSummIdToEstSummFeedMap = new Map<String,Estimation_Summary__c>();
        Map<String,Estimation_Summary__c> estSummIdToEstSummExtFeedMap = new Map<String,Estimation_Summary__c>();
        
        Map<String,Estimation_Output__c> estOutIdToEstOutFeedMap = new Map<String,Estimation_Output__c>();
        Map<String,Estimation_Output__c> estOutIdToEstOutExtFeedMap = new Map<String,Estimation_Output__c>();

        
        //checking if feed is realted to estimation summary or estimation output.
        for(FeedItem feed : FeedItems){
            if('Estimation_Summary__c'.equals(String.valueOf(feed.ParentId.getSObjectType()))){
   				estSummIds.add(feed.ParentId);
            }
            else if('Estimation_Output__c'.equals(String.valueOf(feed.ParentId.getSObjectType()))){
                estOutputIds.add(feed.ParentId);
            }
        }
        
        //checking for estimation summary.
        if(estSummIds.size()>0){

            estSummIdToEstSummFeedMap=new Map<String,Estimation_Summary__c>([SELECT Id,(SELECT Visibility FROM Feeds)
                                                                         	 FROM Estimation_Summary__c WHERE Id IN : estSummIds]);
            
            estSummIdToEstSummExtFeedMap=new Map<String,Estimation_Summary__c>([SELECT Id,Feed_External_User__c,Feed_Internal_User__c,
                                                                               (SELECT Visibility FROM Feeds WHERE Visibility='AllUsers' LIMIT 1)
                                                                         	   FROM Estimation_Summary__c WHERE Id IN : estSummIds]);
            
            for(Estimation_Summary__c estSum : estSummIdToEstSummExtFeedMap.values())
            {
                if(estSum.Feeds.size()>0){
                  //if there is feed item which has visibility = all users.
                    if(!estSum.Feed_Internal_User__c || !estSum.Feed_External_User__c)
                    {
                       recordsToBeUpdated.add(new Estimation_Summary__c(Id=estSum.Id,Feed_Internal_User__c=true,
                                                                       Feed_External_User__c=true));
                  	}
                }
                else if(estSummIdToEstSummFeedMap.get(estSum.Id).Feeds.size()>0)
                {
                    // if feed exist of only internal visibility.
                    if(estSum.Feed_External_User__c){
                        recordsToBeUpdated.add(new Estimation_Summary__c(Id=estSum.Id,Feed_External_User__c=false));
                    }
                }
                else{
                    //if there is no feed then we will false the fields.
                    if(estSum.Feed_Internal_User__c || estSum.Feed_External_User__c){
                        recordsToBeUpdated.add(new Estimation_Summary__c(Id=estSum.Id,Feed_Internal_User__c=false,
                                                                        Feed_External_User__c=false));
                    }
                }
            }
            
        }
        
        //checking for estimation summary.
        if(estOutputIds.size()>0){

            estOutIdToEstOutFeedMap=new Map<String,Estimation_Output__c>([SELECT Id,(SELECT Visibility FROM Feeds)
                                                                         	 FROM Estimation_Output__c WHERE Id IN : estOutputIds]);
            
            estOutIdToEstOutExtFeedMap=new Map<String,Estimation_Output__c>([SELECT Id,Feed_External_User__c,Feed_Internal_User__c,
                                                                               (SELECT Visibility FROM Feeds WHERE Visibility='AllUsers' LIMIT 1)
                                                                         	   FROM Estimation_Output__c WHERE Id IN : estOutputIds]);
            
          
            for(Estimation_Output__c estOut : estOutIdToEstOutExtFeedMap.values())
            {
                if(estOut.Feeds.size()>0){
                  //if there is feed item which has visibility = all users.
                    if(!estOut.Feed_Internal_User__c || !estOut.Feed_External_User__c)
                    {
                       recordsToBeUpdated.add(new Estimation_Output__c(Id=estOut.Id,Feed_Internal_User__c=true,
                                                                       Feed_External_User__c=true));
                  	}
                }
                else if(estOutIdToEstOutFeedMap.get(estOut.Id).Feeds.size()>0)
                {
                    // if feed exist of only internal visibility.
                    if(estOut.Feed_External_User__c){
                        recordsToBeUpdated.add(new Estimation_Output__c(Id=estOut.Id,Feed_External_User__c=false));
                    }
                }
                else{
                    //if there is no feed then we will false the fields.
                    if(estOut.Feed_Internal_User__c || estOut.Feed_External_User__c){
                        recordsToBeUpdated.add(new Estimation_Output__c(Id=estOut.Id,Feed_Internal_User__c=false,
                                                                        Feed_External_User__c=false));
                    }
                }
            }
            
        }
        update recordsToBeUpdated;
    }
    
}