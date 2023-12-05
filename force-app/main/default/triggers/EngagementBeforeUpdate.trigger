trigger EngagementBeforeUpdate on Engagement__c  (before update) {
 
    if(globalApexManager.avoidRecursion('EngagementBeforeUpdate')) {
           return;
        }
        If(Trigger.isBefore && Trigger.isUpdate){
            EngagementTriggerHandler.engagementBeforeUpdate(Trigger.New,trigger.oldMap);
          }
}