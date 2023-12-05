/*
Trigger:        PartnerDistributorAfterInsert 
@Author:        Deloitte
@Created Date:  12/21/2017
@Description:   Trigger on Partner_Distributor__c for After update 
*/

trigger PartnerDistributorAfterUpdate on Partner_Distributor__c (after update) 
{
    if(globalApexManager.avoidRecursion(Label.PartnerDistributorAfterUpdate)) {
        return;
    }
    PartnerDistributorTriggerHandler.afterUpdateSharing(trigger.New, trigger.NewMap,trigger.old,trigger.oldmap);
}