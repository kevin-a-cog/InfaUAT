/*
@created by       : RANJAN KISHORE
@created on       : 02/17/2021
@Purpose          : Trigger to customize.

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
trigger PSA_MilestoneTrigger on pse__Milestone__c (before insert, before update,before delete, after insert, after update,after delete) {

    Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId());
    if(bts == null || bts.PSA_MilestoneTrigger__c){
    new PSA_MilestoneTriggerHandler().process();
    }
}