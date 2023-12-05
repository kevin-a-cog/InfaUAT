trigger EngagementAfterUpdate on Engagement__c (after update) {
    if(globalApexManager.avoidRecursion('EngagementAfterUpdate ')) 
    {
        return;
    }
    EngagementTriggerHandler.engagementAfterUpdate(Trigger.New, trigger.oldMap);

}