/*
        Trigger:        SubscriptionAfterDelete
        @Author:        Wasim Akram
        @Created Date:  11 November 2019
        @Description:    
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
    ********************************************************************************************************************************************
   
*/
trigger SubscriptionAfterDelete on SBQQ__Subscription__c (after Delete) {

    if(globalApexManager.avoidRecursion('SubscriptionAfterDelete') ) {
        return;
    }
    
    //call handler class
    SubscriptionTriggerHandler.handleAfterDelete(Trigger.old);
  
}