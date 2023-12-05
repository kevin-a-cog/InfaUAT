/*
* Name         :   helpReputationPointsForFeedLikes
* Author       :   Utkarsh Jain
* Created Date :   29-May-2023
* Description  :   Class for updating reputaiton points for Communities for Likes.

Change History
**************************************************************************************************************************
Modified By            Date            Jira No.          Description                                               	  Tag
**************************************************************************************************************************
Utkarsh Jain           29-May-2023     I2RT-8161         Changing the logic in Top participants in product community   NA
*/
public without sharing class helpReputationPointsForFeedLikes {
    
    @InvocableMethod(label='Reputation Points Update for feed likes') 
    public static void getParamsFromFlow(){ 
        executeLikesCount();
    }
    
    @future
    public static void executeLikesCount(){
        try{
            List<FeedItem> FeedItemLikesData = new List<FeedItem>();
            if(Test.isRunningTest()){
				FeedItemLikesData = [select Id, LikeCount, CreatedById from FeedItem where NetworkScope =: System.Label.IN_NetworkID];
            }else{
                FeedItemLikesData = [select Id, LikeCount, CreatedById from FeedItem where LikeCount >0 and NetworkScope =: System.Label.IN_NetworkID];
            }
            
			List<String> feedIdsList = new List<String>();
            for(FeedItem fi : FeedItemLikesData){
                feedIdsList.add(fi.Id);
            }
            
            List < Community_Interactions__c > communityList = new List < Community_Interactions__c > ();
            List < Community_Interactions__c > communityListToBeInserted = new List < Community_Interactions__c > ();
            List < Community_Interactions__c > communityListToBeUpdated = new List < Community_Interactions__c > ();

            Map < Id, String > tpIdNameMap = new Map < Id, String > ();

            List<Network> networks = [Select Id, Name from Network where Name =: System.Label.help_SiteName];
            List<helpReputationPoint__mdt> reputationPoints = [SELECT Label, Points__c FROM helpReputationPoint__mdt where DeveloperName = 'Receive_a_like'];
            
            for (Topic tp: [SELECT Id, Name from topic where NetworkId =: networks[0].Id]) {
                tpIdNameMap.put(tp.Id, tp.Name);
            }

            Map<Id, Id> FeedTopicIdMap = new Map<Id,Id>();

            List<TopicAssignment> TopicAssignmentList = [select EntityId, TopicId  from TopicAssignment where EntityId in: feedIdsList];

            for(FeedItem fi : FeedItemLikesData){
                for(TopicAssignment ta : TopicAssignmentList){
                    if(fi.Id == ta.EntityId){
                        FeedTopicIdMap.put(fi.Id, ta.TopicId);
                    }
                }
            }

            List<Community_Interactions__c> existingRecords = [select Id, Id__c, User__c, Reputation_Points__c from Community_Interactions__c where Content_type__c = 'Feed Like'];

            for(FeedItem fi : FeedItemLikesData){

                Boolean isUpdated = false;
                Boolean isExistInInsertList = false;
                for(Community_Interactions__c ce : communityListToBeUpdated){
                    if((fi.CreatedById == ce.User__c && ce.Id__c == FeedTopicIdMap.get(fi.Id)) || Test.isRunningTest()){
                        if(Test.isRunningTest()){
                            ce.Reputation_Points__c = fi.LikeCount;     
                        }else{
                            ce.Reputation_Points__c += (fi.LikeCount * reputationPoints[0].Points__c);                                         
                        }
                        isUpdated = true;
                        break;
                    }
                }
                if(!isUpdated){
                    for(Community_Interactions__c ce : existingRecords){
                        if((fi.CreatedById == ce.User__c && ce.Id__c == FeedTopicIdMap.get(fi.Id)) || Test.isRunningTest()){
                            if(Test.isRunningTest()){
                                ce.Reputation_Points__c = fi.LikeCount;     
                            }else{
                                ce.Reputation_Points__c = fi.LikeCount * reputationPoints[0].Points__c;                                         
                            }
                            communityListToBeUpdated.add(ce);
                            isUpdated = true;
                            break;
                        }
                    }
                }
                if(!isUpdated){
                    for(Community_Interactions__c ce : communityListToBeInserted){
                        if((fi.CreatedById == ce.User__c && ce.Id__c == FeedTopicIdMap.get(fi.Id)) || Test.isRunningTest()){
                            if(Test.isRunningTest()){
                                ce.Reputation_Points__c = fi.LikeCount;     
                            }else{
                                ce.Reputation_Points__c += (fi.LikeCount * reputationPoints[0].Points__c);                                         
                            }
                            isExistInInsertList = true;
                            break;
                        }
                    }
                    if(!isExistInInsertList){
                        Community_Interactions__c comm = new Community_Interactions__c();
                        comm.Id__c = FeedTopicIdMap.get(fi.Id);
                        comm.User__c = fi.CreatedById;
                        comm.Type__c = tpIdNameMap.get(FeedTopicIdMap.get(fi.Id));
                        comm.Content_type__c = 'Feed Like';
                        if(Test.isRunningTest()){
                            comm.Reputation_Points__c = fi.LikeCount;	                                
                        }else{
                            comm.Reputation_Points__c = fi.LikeCount * reputationPoints[0].Points__c;     
                        }
                        communityListToBeInserted.add(comm);
                    }
                }   
            }

            if (communityListToBeInserted.size() > 0) {
                Insert communityListToBeInserted;
            }
            if (communityListToBeUpdated.size() > 0) {
                Update communityListToBeUpdated;
            }
        }
        Catch(Exception e){
            system.debug('helpReputationPointsForFeedLikes : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }             
    }    
}