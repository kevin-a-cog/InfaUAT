/*
Trigger:        PartnerRelationshipBeforeInsert 
@Author:        Deloitte
@Created Date:  11/08/2017
@Description:   Trigger on Partner_Relationship__c for before insert 
*/
trigger PartnerRelationshipBeforeInsert on Partner_Relationship__c (before insert) 
{
    if(globalApexManager.avoidRecursion(Label.PRM_Trigger_PartnerRelationshipBeforeInsert)) {
        return;
    }
    PartnerRelationshipTriggerHandler.partnerRelBeforeInsert(trigger.new);
}