trigger ContactAfterInsert on Contact (After Insert) {

    if(globalApexManager.avoidRecursion('ContactAfterInsert')){
        return;
    }

    ContactTriggerHandler.ContactAfterInsert(Trigger.new, Trigger.newmap); 

}