/*
Trigger:        PartnerRelationshipBeforeUpdate 
@Author:        Deloitte
@Created Date:  11/10/2017
@Description:   Trigger on Partner_Relationship__c for before insert 
*/
trigger PartnerRelationshipBeforeUpdate on Partner_Relationship__c (before update) 
{
    if(globalApexManager.avoidRecursion(Label.PRM_Trigger_PartnerRelationshipBeforeUpdate)) {
        return;
    }
    PartnerRelationshipTriggerHandler.partnerRelBeforeUpdate(trigger.new,trigger.newMap,trigger.oldMap);
    //PartnerRelationshipTriggerHandler.updatePartnerSourced(trigger.new);
}