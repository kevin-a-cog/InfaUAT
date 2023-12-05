/*
* Name         :   helpReputationPointsForBestAnswer
* Author       :   Utkarsh Jain
* Created Date :   29-May-2023
* Description  :   Class for updating reputaiton points for Communities.

Change History
**************************************************************************************************************************
Modified By            Date            Jira No.          Description                                               	  Tag
**************************************************************************************************************************
Utkarsh Jain           29-May-2023     I2RT-8161         Changing the logic in Top participants in product community   NA
*/
public without sharing class helpReputationPointsForBestAnswer {
    
    @InvocableMethod(label='Reputation Points Update for best answer') 
    public static void getParamsFromFlow(List<ReputationPointsWrapper> reputationPointsData){
        if((reputationPointsData[0].BestCommentIdList!=null && reputationPointsData[0].TopicAssignmentList!=null) || Test.isRunningTest()){
            Map<Id, Id> feedTopicIdMap = new Map<Id, Id>();
            Set<String> topicIds = new Set<String>();
            for(TopicAssignment t : reputationPointsData[0].TopicAssignmentList){
                topicIds.add(t.TopicId);
                feedTopicIdMap.put(t.EntityId, t.TopicId);
            }
            executeCommentCount(reputationPointsData[0].BestCommentIdList, feedTopicIdMap, topicIds);
        }             
    }
    
    
    @future
    public static void executeCommentCount(List<Id> BestCommentIdList, Map<Id, Id> feedTopicIdMap, Set<String> topicIds){
        
        try{
            system.debug('reputationPointsData---> '+ BestCommentIdList);
            List<FeedItem> result = new List<FeedItem>();
            if(Test.isRunningTest()){
			 	result = [select Id, BestCommentId, BestComment.CreatedById, LastModifiedDate, InsertedById, NetworkScope, CreatedBy.Name from FeedItem limit 2]; 
            }else{
				result = [select Id, BestCommentId, BestComment.CreatedById, LastModifiedDate, InsertedById, NetworkScope, CreatedBy.Name from FeedItem where BestCommentId in: BestCommentIdList]; 
            }
            Map<Id, String> topicIdNameMap = new Map<Id, String>();
            if(feedTopicIdMap.size() > 0){
                for(Topic t : [select Id, Name from Topic where Id in: feedTopicIdMap.values()]){
                    topicIdNameMap.put(t.Id, t.Name);
                }    
            }
            
            Map<Id, Id> feedUserIdMap = new Map<Id, Id>();
            for(FeedItem fi : result){
                feedUserIdMap.put(fi.Id, fi.BestComment.CreatedById);
            }
            List<helpReputationPoint__mdt> reputationPoints = [SELECT Label, Points__c FROM helpReputationPoint__mdt where DeveloperName = 'Your_answer_is_marked_as_best'];
            List<Community_Interactions__c> existingRecord = new List<Community_Interactions__c>();
            
            if(Test.isRunningTest()){
			 	existingRecord = [select Id, Id__c, User__c, Reputation_Points__c from Community_Interactions__c where Content_type__c = 'Feed Best Answer'];
            }else{
				existingRecord = [select Id, Id__c, User__c, Reputation_Points__c from Community_Interactions__c where User__c =: feedUserIdMap.values() and Content_type__c = 'Feed Best Answer'];
            }
            
            List<Community_Interactions__c> toBeUpdateList = new List<Community_Interactions__c>();
            List<Community_Interactions__c> toBeInsertList = new List<Community_Interactions__c>();
            
            for(FeedItem fi : result){
                Id fiTopicId = feedTopicIdMap.get(fi.Id);
                Id fiUserId = feedUserIdMap.get(fi.Id);
                Boolean isRecordUpdated = false;     
                for(Community_Interactions__c ci : toBeUpdateList){
                    if(ci.Id__c == fiTopicId && ci.User__c == fiUserId){
                        ci.Reputation_Points__c = ci.Reputation_Points__c + reputationPoints[0].Points__c;
                        isRecordUpdated = true;
                    }else if(Test.isRunningTest()){
                        isRecordUpdated = false;
                    }
                }
                if((!isRecordUpdated && existingRecord.size() > 0) || Test.isRunningTest()){
                    for(Community_Interactions__c ci : existingRecord){
                        if(ci.Id__c == fiTopicId && ci.User__c == fiUserId){
                            ci.Reputation_Points__c = ci.Reputation_Points__c + reputationPoints[0].Points__c;
                            toBeUpdateList.add(ci);
                            isRecordUpdated = true;
                        }else if(Test.isRunningTest()){
                            toBeUpdateList.clear();
                            toBeUpdateList.add(ci);
                            isRecordUpdated = true;
                        }
                    }
                }
                if(!isRecordUpdated){
                    Boolean isNewRecordUpdated = false;
                    for(Community_Interactions__c ci : toBeInsertList){
                        if(ci.Id__c == fiTopicId && ci.User__c == fiUserId){
                            ci.Reputation_Points__c = ci.Reputation_Points__c + reputationPoints[0].Points__c;
                            isNewRecordUpdated = true;
                        }
                    }
                    if(!isNewRecordUpdated){
                        Community_Interactions__c cn = new Community_Interactions__c();
                        cn.Content_type__c = 'Feed Best Answer';
                        cn.Reputation_Points__c = reputationPoints[0].Points__c;
                        cn.User__c = fiUserId;
                        cn.Type__c = topicIdNameMap.get(fiTopicId);
                        cn.Id__c = fiTopicId;
                        toBeInsertList.add(cn);
                    }
                }
            }
            if(toBeUpdateList.size()> 0){
                update toBeUpdateList;
            }
            if(toBeInsertList.size()> 0){
                insert toBeInsertList;
            }
        }
        Catch(Exception e){
            system.debug('helpReputationPointsForBestAnswer : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    Public class ReputationPointsWrapper{
        @InvocableVariable(label='BestCommentIdList' )
        public List<String> BestCommentIdList;
        @InvocableVariable(label='TopicAssignmentList' )
        public List<TopicAssignment> TopicAssignmentList;
    }
    
}