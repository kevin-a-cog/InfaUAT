trigger EntitledProductAfterInsert on Entitled_Product__c (After Insert) {

    
        if(globalApexManager.avoidRecursion('EntitledProductAfterInsert') ) {
            return;
        }
        
        EntitledProductTriggerHandler.handleEntitledProductAfterInsert(trigger.new);
       
 

}