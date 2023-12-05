/*
Trigger:        PartnerRelationshipBeforeInsert 
@Author:        Deloitte
@Created Date:  11/16/2017
@Description:   Trigger on Partner_Relationship__c for After insert 
*/

trigger PartnerRelationshipAfterInsert on Partner_Relationship__c (after insert) 
{
    if( globalApexManager.avoidRecursion(Label.PRM_Trigger_PartnerRelationshipAfterInsert)) {
        return;
    }
    PartnerRelationshipTriggerHandler.partnerRelAfterInsert(trigger.new, trigger.NewMap);
    PartnerRelationshipTriggerHandler.afterInsertSharing(trigger.New, trigger.NewMap);
}