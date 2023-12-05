trigger EngagementBeforeInsert on Engagement__c (before insert) {
    if(globalApexManager.avoidRecursion('EngagementBeforeInsert')) 
        {
                        return;
        }
        
         If(Trigger.isBefore && Trigger.isInsert){
           EngagementTriggerHandler.engagementBeforeInsert(Trigger.New);
         }
}