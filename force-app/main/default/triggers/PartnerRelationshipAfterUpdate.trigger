/*
Trigger:        PartnerRelationshipBeforeInsert 
@Author:        Deloitte
@Created Date:  12/21/2017
@Description:   Trigger on Partner_Relationship__c for After update 
*/

trigger PartnerRelationshipAfterUpdate on Partner_Relationship__c (after update) 
{
    if( globalApexManager.avoidRecursion(label.PRM_Trigger_PartnerRelAfterUpdate)) {
        return;
    }
    
    if(Global_Config__c.getInstance().Mute_Triggers__c != null && Global_Config__c.getInstance().Mute_Triggers__c != true){

        PartnerRelationshipTriggerHandler.partnerRelAfterUpdate(trigger.New, trigger.NewMap,trigger.old,trigger.oldmap);
        //PartnerRelationshipTriggerHandler.updateOpptyPartner(trigger.NewMap, trigger.OldMap);
    }
}