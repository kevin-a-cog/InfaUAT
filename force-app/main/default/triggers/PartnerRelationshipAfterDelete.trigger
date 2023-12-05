/*
Trigger:        PartnerRelationshipAfterDelete
@Author:        Deloitte
@Created Date:  11/16/2017
@Description:   Trigger on Partner_Relationship__c for After delete 
*/

trigger PartnerRelationshipAfterDelete on Partner_Relationship__c (after delete) {
    if( globalApexManager.avoidRecursion(Label.PRM_Trigger_PartnerRelationshipAfterDelete)) {
        return;
    }
    PartnerRelationshipTriggerHandler.afterDeleteSharing(trigger.old);
    PartnerRelationshipTriggerHandler.partnerRelAfterDelete(trigger.OldMap);
}