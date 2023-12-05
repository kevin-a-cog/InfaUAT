trigger EntitledProductTrigger on Entitled_Product__c (after insert, after update) {

      //check for after insert event
      if (trigger.isAfter &&  trigger.isInsert){
        //check for recursion
        if(globalApexManager.avoidRecursion('EntitledProductTrigger',  'after', 'insert') ) {
            return;
        }
        //call handler method
        EntitledProductTriggerHandler.handleEntitledProductAfterInsert(trigger.new);
    }

     //check for after update event
     if (trigger.isAfter &&  trigger.isUpdate){
        //check for recursion
        if(globalApexManager.avoidRecursion('EntitledProductTrigger',  'after', 'update') ) {
            return;
        }
        //Call hanlder method 
        EntitledProductTriggerHandler.handleEntitledProductAfterUpdate(trigger.new, trigger.oldMap);
    }

}