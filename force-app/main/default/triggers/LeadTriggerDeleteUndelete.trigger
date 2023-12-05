/*
        Trigger:        LeadTriggerDeleteUndelete
        @Created Date:  10/28/2022
        @Description:   Trigger for lead
*/
trigger LeadTriggerDeleteUndelete on Lead (after delete, after undelete) {

    if(globalApexManager.avoidRecursion('LeadTriggerDeleteUndelete')) {
        return;
    }

    if(Trigger.isAfter){
        if(Trigger.isDelete){
            LeadTriggerHandler.leadAfterDelete(Trigger.old, Trigger.oldMap);
        }
        if(Trigger.isUndelete){
            LeadTriggerHandler.leadAfterDelete(Trigger.new, Trigger.newMap);
        }
    }
}