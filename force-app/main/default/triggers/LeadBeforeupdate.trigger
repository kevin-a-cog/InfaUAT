/*
        Trigger:        LeadBeforeupdate 
        @Author:        Ambica Pyati
        @Created Date:  08/7/2017
        @Description:   handle logic on before update of lead
*/


trigger LeadBeforeupdate on Lead ( before update) {
     
    if(globalApexManager.avoidRecursion('LeadBeforeupdate')) {
                    return;
        }
    
   
    LeadTriggerHandler.LeadBeforeupdate (Trigger.oldmap, Trigger.new);


}