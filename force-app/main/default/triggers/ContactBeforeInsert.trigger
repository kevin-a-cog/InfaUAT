/*
        Trigger:        ContactBeforeInsert 
        @Author:        Ambica Pyati
        @Created Date:  08/7/2017
        @Description:   handler logic on before insert of contact
*/

trigger ContactBeforeInsert on Contact (Before Insert) {

    if(globalApexManager.avoidRecursion('contactBeforeInsert ')) {
                    return;
        }
    
    ContactTriggerHandler.contactBeforeInsert (Trigger.new);
    
    }