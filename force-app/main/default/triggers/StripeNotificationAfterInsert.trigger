/*
    @created by       : cgowda
    @created on       : 08/08/22
    @Purpose          : after insert trigger for Stripe Notification API
    @Testclass        : StripeNotificationTriggerHandlerTest
    @JIRA             : PAYGIT-5
    
Change History
****************************************************************************************************************
ModifiedBy          Date            Jira No.            Description                                        Tag
****************************************************************************************************************
*/
trigger StripeNotificationAfterInsert on Stripe_Notification_API__c (after insert) {
    
    if(globalApexManager.avoidRecursion('StripeNotificationAfterInsert')){
        return;
    }
    StripeNotificationTriggerHandler.handleAfterInsert(Trigger.new);
}