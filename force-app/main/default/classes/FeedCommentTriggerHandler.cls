/*
Class:          FeedCommentTriggerHandler
@Author:        Deva
@Created Date:  1-Jun-21
@Description:   Handler class for FeedComment Trigger
*/ 
public class FeedCommentTriggerHandler {
    public static void handleAfterInsert(List<FeedComment> listTriggerNew){
        set<Id> feedItemIdSet = new Set<Id>();
        for(FeedComment fd:listTriggerNew){
            if(fd.FeedItemId!=null){
                feedItemIdSet.add(fd.FeedItemId);
            }
        }
        if(feedItemIdSet.size()>0){
            FeedCommentTriggerHelper.triggerTrackerOnReply(feedItemIdSet);
        }
        FeedCommentTriggerHelper.updateGetHelpRequest(listTriggerNew); //Vignesh D: I2RT-4284

        //I2RT-4422
        FeedCommentTriggerHelper.updateParentEngagement(listTriggerNew);

        // I2RT-8161
        FeedCommentTriggerHelper.updateReputationPointsForComments(listTriggerNew); 
    }

    public static void handleAfterUpdate(List<FeedComment> listTriggerNew){
        // I2RT-8161
        FeedCommentTriggerHelper.updateReputationPointsForComments(listTriggerNew); 
    }

    public static void handleBeforeDelete(List<FeedComment> listTriggerNew){
        // I2RT-8161
        FeedCommentTriggerHelper.deleteReputationPointsForComments(listTriggerNew); 
    }
}