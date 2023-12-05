/*
        Trigger:        ContactTriggerDeleteUndelete 
        @Created Date:  10/28/2022
        @Description:   handler logic on after delete and after undelete
*/

trigger ContactTriggerDeleteUndelete on Contact (after delete, after undelete) {
    
    if(globalApexManager.avoidRecursion('ContactTriggerDeleteUndelete')) {
        return;
    }

    if(Trigger.isAfter){

        if(Trigger.isDelete){
            ContactTriggerHandler.contactAfterDelete(Trigger.old, Trigger.oldMap);    
        }
        if(Trigger.isUndelete){
            ContactTriggerHandler.contactAfterUndelete(Trigger.new, Trigger.newMap);    
        }
    }
}