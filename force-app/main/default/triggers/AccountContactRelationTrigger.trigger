trigger AccountContactRelationTrigger on AccountContactRelation (after insert, after update) {
    public static Integer count = 0;
   //check for after insert event
    if (trigger.isAfter &&  trigger.isInsert){
        //check for recursion
        if(count < 3){
            globalApexManager.allowRun('AccountContactRelationTrigger',  'after', 'insert');
        }
        else if(globalApexManager.avoidRecursion('AccountContactRelationTrigger',  'after', 'insert') ) {
            return;
        }
        //call handler method
        AccountContactRelationTriggerHandler.handleAccountContactRealtionAfterInsert(trigger.new);
        count +=1;
    }

     //check for after update event
     if (trigger.isAfter &&  trigger.isUpdate){
        //check for recursion
        if(globalApexManager.avoidRecursion('AccountContactRelationTrigger',  'after', 'update') ) {
            return;
        }
        //Call hanlder method 
        AccountContactRelationTriggerHandler.handleAccountContactRealtionAfterUpdate(trigger.new, trigger.oldMap);
    }

}