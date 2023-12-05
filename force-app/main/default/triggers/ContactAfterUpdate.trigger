/*
        Trigger:        ContactAfterUpdate 
        @Author:        Deloitte
        @Created Date:  10/01/2018
        @Description:   handler logic on after update of contact
*/

trigger ContactAfterUpdate on Contact (After Update) {

    
    if(globalApexManager.avoidRecursion('ContactAfterUpdate')) {
        return;
    }
       
    ContactTriggerHandler.ContactAfterUpdate(Trigger.new, Trigger.newmap, Trigger.oldmap);    
}