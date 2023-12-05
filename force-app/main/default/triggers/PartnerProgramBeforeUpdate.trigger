/*
Trigger:        PartnerProgramBeforeUpdate
@Author:        Deloitte
@Created Date:  02/14/2017
@Description:   Trigger on Partner_Program__c for Before Update
*/
trigger PartnerProgramBeforeUpdate on Partner_Program__c (Before Update) {
    if( globalApexManager.avoidRecursion('PartnerProgramBeforeUpdate')) {
        return;
    }
    PartnerProgramTriggerHandler.partnerProgramBeforeUpdate(trigger.new,trigger.newMap,trigger.oldMap);
}