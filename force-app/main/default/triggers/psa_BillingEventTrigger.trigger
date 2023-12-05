trigger psa_BillingEventTrigger on pse__Billing_Event__c (before insert, before update,before delete, after insert, after update,after delete) {
    //changed from before update to after : Records become read-only and then throw error    
    /*if(globalApexManager.avoidRecursion('BillingEvent')) {
        return;
    }
    System.debug('Is currently in Future? A: ' + System.isFuture());//returns false
    System.debug('Is currently in Batch? A: ' + System.isBatch());//returns true*/
    /*String triggerNewSerialized = Json.serialize(trigger.New);
    String triggerOldMapSerialized = Json.serialize(trigger.oldmap);
    BillingEventHandler.BeforeUpdate(trigger.New,trigger.oldmap);*/
    
    /*Commenting out above code which was written for the Billing Event split, do not re-activate*/
    Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId());
    if(bts == null || bts.PSA_Billing_Event_Trigger__c){
        new psa_BillingEventTriggerHandler().process();
    }
    
}