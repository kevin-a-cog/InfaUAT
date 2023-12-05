/*
@created by       : Ranjan kishore
@created on       : 05/27/2021
@Purpose          : Trigger to customize.

Change History
**************************************************************************************************************************
ModifiedBy  |    Date       |     Requested By  |   	Description                            |  Jira No.      | Tag No:
***************************************************************************************************************************
*/

trigger PSA_SolutionTypeTrigger on psa_pm_Solution_Type__c (before insert, before update,before delete, after insert, after update,after delete) {
Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId());
    if(bts == null || bts.PSA_Solution_Type_Trigger__c){
    new PSA_SolutionTypeTriggerHandler().process();
    }
}