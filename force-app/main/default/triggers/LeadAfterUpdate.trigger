/*
        Trigger:        LeadAfterUpdate
        @Author:        Deloitte
        @Created Date:  02/27/2018
        @Description:   handler logic on after insert of lead
*/
trigger LeadAfterUpdate on Lead (After Update) {
     if(globalApexManager.avoidRecursion('LeadAfterUpdate')) {
                    return;
        }
    
    LeadTriggerHandler.leadAfterUpdate(Trigger.new,Trigger.newMap, Trigger.oldMap);
}