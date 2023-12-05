trigger EngagementAfterInsert on Engagement__c (after insert) {
    if(globalApexManager.avoidRecursion('EngagementAfterInsert')) 
        {
                        return;
        }
        
         If(Trigger.isAfter && Trigger.isInsert){
           EngagementTriggerHandler.engagementAfterInsert(Trigger.New);
         }
}