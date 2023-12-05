/*
Trigger:       CaseTeamTrigger
@Author:       Deva
@Created Date: 30-Jun-21
@Description: Trigger on Case_Team__c Object
*/
trigger CaseTeamTrigger on Case_Team__c (after insert,after update,before insert,before update) {
    if(globalApexManager.avoidRecursion('CaseTeamTrigger') ) { 
        return;
    }
    if(trigger.isafter && trigger.isUpdate ){
        CaseTeamTriggerHandler.handleAfterUpdate(trigger.new, trigger.oldMap);
    }
}