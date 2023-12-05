trigger EngagementBeforeDelete on Engagement__c (before delete) {
    if(globalApexManager.avoidRecursion('EngagementBeforeDelete')) 
    {
        return;
    }
    if(Trigger.isBefore && Trigger.isDelete){
    CsmEngagementTriggerHelper.processBeforeDelete(trigger.old);
    }
}