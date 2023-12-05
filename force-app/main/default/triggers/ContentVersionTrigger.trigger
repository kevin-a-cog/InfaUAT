/**
 * Change History 
 * 
 * ****************************************************************************************************************************
 * Modified By      Date            Requested By            JIRA No.        Description                                     Tag
 * ****************************************************************************************************************************
 * Vivek Warrier    18-Feb-2022     Jeff Christensen        PSA-2228        Prevention of Upload of new file version        T01
 *                                                                          when Resume is submitted
 */
trigger ContentVersionTrigger on ContentVersion (before insert, after insert){
    
    //<T01>
    if(Trigger.isBefore && Trigger.isInsert){
        ContentVersionTriggerHandler.processBeforeInsert(Trigger.New);
    }
    //</T01>
    
    if(Trigger.isAfter && Trigger.isInsert){
        ContentVersionTriggerHandler.processAfterInsert(Trigger.New);
    }

}