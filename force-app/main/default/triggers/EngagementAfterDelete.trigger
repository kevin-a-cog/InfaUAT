trigger EngagementAfterDelete on Engagement__c (after delete) {
    if(globalApexManager.avoidRecursion('engagementAfterDelete')) 
    {
        return;
    }
    EngagementTriggerHandler.engagementAfterDelete(trigger.oldMap);

}