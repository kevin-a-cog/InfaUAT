/*
Trigger:        PartnerProgramAfterInsert 
@Author:        Deloitte
@Created Date:  02/14/2017
@Description:   Trigger on Partner_Program__c for After insert 
*/
trigger PartnerProgramAfterInsert on Partner_Program__c (after insert) {
    if( globalApexManager.avoidRecursion('PartnerProgramAfterInsert')) {
        return;
    }
    PartnerProgramTriggerHandler.partnerProgramAfterInsert(trigger.new);
}