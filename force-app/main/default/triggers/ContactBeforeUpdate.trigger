/*
        Trigger:        ContactBeforeUpdate 
        @Author:        Ambica Pyati
        @Created Date:  08/7/2017
        @Description:   handler logic on before update of contact
*/

trigger ContactBeforeUpdate on Contact (Before Update) {

        
    if(globalApexManager.avoidRecursion('ContactBeforeUpdate')) {
                    return;
        }
    
    ContactTriggerHandler.ContactBeforeUpdate (Trigger.oldmap,Trigger.newmap,Trigger.new);    
}