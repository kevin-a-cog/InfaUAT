/*
* Class :        SubscriptionLineAfterInsert
* Author:        Ambica P
* Created Date:  15 July 2020
* Description:   After Insert Trigger on Subscription Line 
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
    ********************************************************************************************************************************************
   
*/
trigger SubscriptionLineAfterInsert on Subscription_Line__c (After insert) {
    
    if(globalApexManager.avoidRecursion('SubscriptionLineAfterInsert') ) {
        return;
    }
    
    SubscriptionLineTriggerHandler.handleAfterInsert(Trigger.New);
}