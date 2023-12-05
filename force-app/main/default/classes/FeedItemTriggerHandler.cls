/*
Class:          FeedItemTriggerHandler
@Author:        balajip
@Created Date:  09-Nov-21
@Description:   Handler class for FeedItem Trigger
*/ 
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy            Date          JIRA No.        Description                                                                            Tag

    Saurabh Khandelwal    10-Mar-2022   IPUE-160        Added feed Item trigger action(insert,delete) for est summary and est output           <T1>
    Cosmos                4-4-2022      Cosmos          Added CSMLoadJiraCommentToPlanCommentQueuable method
    ********************************************************************************************************************************************
*/
public class FeedItemTriggerHandler extends TriggerHandler{
    private FeedItemTriggerHelper helper = new FeedItemTriggerHelper();
	
    //Methods related to the module to be called in after insert context
    public override void afterInsert() {          
        if(globalApexManager.avoidRecursion('FeedItemTrigger',  'after', 'insert') ) {
            return;
        }
        helper.updateParentEngagement((List<FeedItem>) newList);
        helper.updateParentEstimateSummary((List<FeedItem>) newList);
        ID jobID = System.enqueueJob(new CSMLoadJiraCommentToPlanCommentQueuable((List<FeedItem>) newList));
    }

    //Methods related to the module to be called in after delete context
    public override void afterDelete() {          
        if(globalApexManager.avoidRecursion('FeedItemTrigger',  'after', 'delete') ) {
            return;
        }
        helper.checkForExistingFeed((List<FeedItem>) oldList);
    }

    //Methods related to the module to be called in after delete context
    public override void beforeDelete() {          
        if(globalApexManager.avoidRecursion('FeedItemTrigger',  'before', 'delete') ) {
            return;
        }
        helper.RemovePointsForRejectedPost((List<FeedItem>) oldList);
    }

    //Methods related to the module to be called in after update context
    public override void afterUpdate() {       
        if(globalApexManager.avoidRecursion('FeedItemTrigger',  'after', 'update') ) {
            return;
        }
        helper.updateReputationPoints((List<FeedItem>) newList);
    }
}