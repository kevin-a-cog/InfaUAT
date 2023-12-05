/*
        Trigger:        SubscriptionAfterUndelete
        @Author:        Wasim Akram
        @Created Date:  13 November 2019
        @Description:    
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
    ********************************************************************************************************************************************
   
*/
trigger SubscriptionAfterUndelete on SBQQ__Subscription__c (after undelete) {
if(globalApexManager.avoidRecursion('SubscriptionAfterUndelete') ) {
        return;
    }
    
    //call handler class
    SubscriptionTriggerHandler.handleAfterUndelete(Trigger.new);
  
}