/*
@created by       : MAHESH GANTI
@created on       : 10/19/2020
@Purpose          : Trigger to customize.

Change History
**************************************************************************************************************************
ModifiedBy  |    Date       |     Requested By  |   	Description                            |  Jira No.      | Tag No:
***************************************************************************************************************************
*/

trigger psa_AssignmentTrigger on pse__Assignment__c (before insert, before update,before delete, after insert, after update,after delete) {
Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId());
    if(bts == null || bts.PSA_AssignmentTrigger__c){
    new psa_AssignmentTriggerHandler().process();
    }
}