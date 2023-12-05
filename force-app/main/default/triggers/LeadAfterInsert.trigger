/*
        Trigger:        LeadAfterInsert 
        @Author:        Deloitte
        @Created Date:  02/27/2018
        @Description:   handler logic on after insert of lead
*/
trigger LeadAfterInsert on Lead (After Insert) {
 if(globalApexManager.avoidRecursion('LeadAfterInsert')) {
                    return;
        }
    
    LeadTriggerHandler.leadAfterInsert(Trigger.new);

}