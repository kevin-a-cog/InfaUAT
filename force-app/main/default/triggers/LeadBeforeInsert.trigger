/*
        Trigger:          LeadBeforeInsert 
        @Author:        Ambica Pyati
        @Created Date:  08/7/2017
        @Description:   handler logic on before insert of lead
*/

trigger LeadBeforeInsert on Lead (Before Insert) {

        
    if(globalApexManager.avoidRecursion('LeadBeforeInsert ')) {
                    return;
        }
    
    LeadTriggerHandler.LeadBeforeInsert (Trigger.new);


}