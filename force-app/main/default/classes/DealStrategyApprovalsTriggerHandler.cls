/*
Trigger:        DealStrategyApprovalsTrigger
@Author:        Nishant B
@Created Date:  2nd Aug 2022
@Description:   To Trigger the email from Power automate
Change History
********************************************************************************************************************************************         
********************************************************************************************************************************************
*/
public class DealStrategyApprovalsTriggerHandler {
    
    public static void handleAfterInsert(list<Deal_Strategy_Approvals__c> lstTriggerNew){
        callNotificationService(lstTriggerNew, null);
    }
    
    public static void handleAfterUpdate(list<Deal_Strategy_Approvals__c> lstTriggerNew, map<Id, Deal_Strategy_Approvals__c> oldMap){
        callNotificationService(lstTriggerNew, oldMap);
    }
    
    
    private static void callNotificationService(list<Deal_Strategy_Approvals__c> lstTriggerNew, map<Id, Deal_Strategy_Approvals__c> oldMap) {
        NotificationService.notify(trigger.new, oldMap);
    }
    

}