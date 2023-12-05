/*
    @created by       : cgowda
    @created on       : 08/08/22
    @Purpose          : TriggerHandler for Stripe Notification API
    @Testclass        : StripeNotificationTriggerHandlerTest
    @JIRA             : PAYGIT-5
    
Change History
****************************************************************************************************************
ModifiedBy          Date            Jira No.            Description                                        Tag
****************************************************************************************************************
*/
public with sharing class StripeNotificationTriggerHandler {
    /**
    * Method Name : handleAfterInsert
    * @param lstNew: list of new records, from Trigger
    * @return return : void
    * @throws exception : NA
    * @description : Invoke Notification Subscription framework to prepare payload and trigger outbound to CAI
    */
    public static void handleAfterInsert(List<Stripe_Notification_API__c> lstNew){
        NotificationService.notify(lstNew, null);
    }
}