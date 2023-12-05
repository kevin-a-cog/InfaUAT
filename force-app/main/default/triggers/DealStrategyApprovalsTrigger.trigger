/*
Trigger:        DealStrategyApprovalsTrigger
@Author:        Nishant B
@Created Date:  2nd Aug 2022
@Description:   To Trigger the email from Power automate
Change History
********************************************************************************************************************************************         
********************************************************************************************************************************************
*/
trigger DealStrategyApprovalsTrigger on Deal_Strategy_Approvals__c (after insert, after update) {
    
    if(trigger.isAfter && trigger.isInsert) {
        DealStrategyApprovalsTriggerHandler.handleAfterInsert(trigger.new); 
    } else if(trigger.isAfter && trigger.isUpdate) {
        DealStrategyApprovalsTriggerHandler.handleAfterUpdate(trigger.new, trigger.oldmap); 
    }
    
}