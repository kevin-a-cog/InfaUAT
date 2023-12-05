trigger AccountAfterUpdate on Account (after update) {


        if(globalApexManager.avoidRecursion('AccountAfterUpdate') ) {
            return;
        }
        
        AccountTriggerHandler.handleAccountAfterUpdate(trigger.new, trigger.oldMap);
       
    

}