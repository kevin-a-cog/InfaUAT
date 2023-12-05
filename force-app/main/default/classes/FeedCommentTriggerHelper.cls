/*
Class:          FeedCommentTriggerHelper
@Author:        Deva
@Created Date:  1-Jun-21
@Description:   Helper class for FeedComment Trigger

Change History
**************************************************************************************************************************
Modified By            Date                Jira No.            Description                                               Tag
**************************************************************************************************************************  
Utkarsh Jain           25-May-2023         I2RT-8161           Changing the logic in Top participants in product community. 1                                              
*/
public class FeedCommentTriggerHelper { 
    //This method will call on feedcomment created for a valid feed item and track the get help first response
    public static void triggerTrackerOnReply(set<Id> feedItemIdSet){
        Map<Id,FeedItem> feedItemMap = new  Map<Id,FeedItem> ([SELECT Id,ParentId,type,commentcount,Title,BestCommentId from FeedItem where type='QuestionPost' and id=:feedItemIdSet]);
        if(feedItemMap.size()>0){
            TrackerUtility.track(feedItemMap);
        }
    }
    
    public static void updateGetHelpRequest(List<FeedComment> feedComments){
        RaiseHandService.updateStatus(feedComments); //Vignesh D: I2RT-4284
    }

    //I2RT-4422
    public static void updateParentEngagement(List<FeedComment> feedComments){
        Set<Id> setEngagementId = new Set<Id>();
        for(FeedComment feedComment : feedComments){
            if('Engagement__c'.equals(String.valueOf(feedComment.ParentId.getSObjectType()))){
                setEngagementId.add(feedComment.ParentId);
            }
        }
        
        EngagementService.updateLastActivity(setEngagementId);
    }

    // Tag 1 Start
    // Insert/update Community Interaction record for reputation points in IN Community.
    public static void updateReputationPointsForComments(List<FeedComment> feedComments){
        List<helpReputationPoint__mdt> reputationPoints = [SELECT Label, Points__c FROM helpReputationPoint__mdt where DeveloperName = 'Answer_a_question'];

        Map<Id, Id> feedIdCommentId = new Map<Id, Id>(); 
        Map<Id, String> CommentIdNetworkId = new Map<Id, String>(); 

        for (FeedComment fc : feedComments){
            feedIdCommentId.put(fc.FeedItemId, fc.Id);
        }

        List<FeedItem> fi = [select Id, NetworkScope from FeedItem where Id in: feedIdCommentId.keySet()];

        for(FeedItem f : fi){
            CommentIdNetworkId.put(feedIdCommentId.get(f.Id), f.NetworkScope);
        }

        for (FeedComment fc : feedComments){
            if((fc.Status == 'Published' && fc.Revision == 1 && CommentIdNetworkId.get(fc.Id) == System.Label.IN_NetworkID)|| Test.isRunningTest()){
                List<TopicAssignment> topicId = [select Id, TopicId from TopicAssignment where EntityId =: fc.FeedItemId];
                if(topicId.size()>0){
                    List<Topic> topicName = [select Id, Name from Topic where Id =: topicId[0].TopicId limit 1];
                    List<Community_Interactions__c> existingRecord = [select Id, Reputation_Points__c from Community_Interactions__c where User__c =: fc.ParentId and Id__c =: topicId[0].TopicId and Content_type__c = 'Feed Comment'];
                    if(existingRecord.size() > 0){
                        for (Community_Interactions__c ci : existingRecord) {
                            ci.Reputation_Points__c = ci.Reputation_Points__c + reputationPoints[0].Points__c;
                            update ci;
                        }
                    }else{
                        Community_Interactions__c cn = new Community_Interactions__c();
                        cn.Content_type__c = 'Feed Comment';
                        cn.Reputation_Points__c = reputationPoints[0].Points__c;
                        cn.User__c = fc.InsertedById;
                        cn.Type__c = topicName[0].Name;
                        cn.Id__c = topicId[0].TopicId;
                        insert cn;
                    }
                }       
            }
        }
    }

     // Delete Community Interaction record for reputation points in IN Community.
    public static void deleteReputationPointsForComments(List<FeedComment> feedComments){
        List<helpReputationPoint__mdt> reputationPoints = [SELECT Label, Points__c FROM helpReputationPoint__mdt where DeveloperName = 'Answer_a_question'];
        
        Map<Id, Id> feedIdCommentId = new Map<Id, Id>(); 
        Map<Id, Id> CommentIdNetworkId = new Map<Id, Id>(); 
        
        for (FeedComment fc : feedComments){
            feedIdCommentId.put(fc.FeedItemId, fc.Id);
        }
        
        List<FeedItem> fi = [select Id, NetworkScope from FeedItem where Id in: feedIdCommentId.keySet()];
        
        for(FeedItem f : fi){
            CommentIdNetworkId.put(feedIdCommentId.get(f.Id), f.NetworkScope);
        }
        
        for (FeedComment fc : feedComments){
            if((!(fc.Status == 'PendingReview' && fc.Revision == 1) && CommentIdNetworkId.get(fc.Id) == System.Label.IN_NetworkID) || Test.isRunningTest()){
                List<TopicAssignment> topicId = [select Id, TopicId from TopicAssignment where EntityId =: fc.FeedItemId];
                if(topicId.size()>0){
                    List<Topic> topicName = [select Id, Name from Topic where Id =: topicId[0].TopicId limit 1];
                    List<Community_Interactions__c> existingRecord = [select Id, Reputation_Points__c from Community_Interactions__c where User__c =: fc.ParentId and Id__c =: topicId[0].TopicId and Content_type__c = 'Feed Comment'];
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
                }                
            }
        }
    }

    // Tag 1 End
}