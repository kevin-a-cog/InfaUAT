trigger EntitledProductAfterUpdate on Entitled_Product__c (After Update) {

    
    if(globalApexManager.avoidRecursion('EntitledProductAfterUpdate') ) {
        return;
    }
    
    EntitledProductTriggerHandler.handleEntitledProductAfterUpdate(trigger.new, trigger.oldMap);
   


}