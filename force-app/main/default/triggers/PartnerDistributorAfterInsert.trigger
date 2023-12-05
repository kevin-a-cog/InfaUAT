/*
Trigger:        PartnerDistributorAfterInsert 
@Author:        Deloitte
@Created Date:  12/21/2017
@Description:   Trigger on Partner_Distributor__c for After insert 
*/

trigger PartnerDistributorAfterInsert on Partner_Distributor__c (after insert) 
{
    if( globalApexManager.avoidRecursion(Label.PartnerDistributorAfterInsert)) {
        return;
    }
    PartnerDistributorTriggerHandler.afterInsertSharing(trigger.New, trigger.NewMap);
}