/*
* Class :        SubscriptionLineTriggerHandler
* Author:        Ambica P
* Created Date:  15 July 2020
* Description:   Handler class for Subscription Line Triggers
*/


public class SubscriptionLineTriggerHandler {
    
    public static void handleAfterInsert(List<Subscription_Line__c> lstNewSubscriptionLine){
        CreatePlanProducts.processSubscriptionLines(lstNewSubscriptionLine);
    }

}