/*
@created by       : Ranjan kishore
@created on       : 06/14/2021
@Purpose          : Trigger to customize.

Change History
**************************************************************************************************************************
ModifiedBy  |    Date       |     Requested By  |   	Description                            |  Jira No.      | Tag No:
***************************************************************************************************************************
*/

trigger PSA_EngagementTrigger on Engagement__c (before insert, before update,before delete, after insert, after update,after delete){
Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId());
    if(bts == null || bts.PSA_EngagementTrigger__c){
    new PSA_EngagementTriggerHandler().process();
    }
}