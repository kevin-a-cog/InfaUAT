/*
    @created by       : balajip
    @created on       : 1/19/2021
    @Purpose          : RaiseHand Trigger.
    @Testclass        : 
    @JIRA             : 
     
 Change History
 ****************************************************************************************************
    ModifiedBy      Date         Jira No.    Tag     Description
    Isha Bansal     27/11/2023   I2RT-9464   T01     Populating acceptor role in a collab 
                                                      based on the collabtype
 ****************************************************************************************************
 
*/
trigger RaiseHandTrigger on Raise_Hand__c(before update, after update, after insert,before insert) {
    //Iniitialize the handler method to be called
    private RaiseHandTriggerHandler handler = new RaiseHandTriggerHandler();

    //before update
    if (trigger.isBefore && trigger.isUpdate){
        //check for recursion
        if(globalApexManager.avoidRecursion('RaiseHandTrigger', 'before', 'update') ) {
            return;
        }
        
        handler.onClose(trigger.newMap, trigger.oldMap); 
        if (trigger.isBefore && (trigger.isUpdate || trigger.isInsert)){//T01
             handler.setAcceptorRoleBasedOnType(Trigger.new); //T01
        }
    }

    //after update
    if (trigger.isAfter &&  trigger.isUpdate){
        //check for recursion
        if(globalApexManager.avoidRecursion('RaiseHandTrigger', 'after', 'update') ) {
            return;
        }

        handler.onOwnerChange(trigger.newMap, trigger.oldMap); //I2RT-4325
        handler.onClose(trigger.newMap, trigger.oldMap); 
        handler.notify(trigger.new, trigger.oldMap); 
    }
    
    //after insert
    if (trigger.isAfter &&  trigger.isInsert){
        //check for recursion
        if(globalApexManager.avoidRecursion('RaiseHandTrigger', 'after', 'insert') ) {
            return;
        }
        
        handler.routeToOmni(trigger.newMap); 
        handler.notify(trigger.new, null); 
    }
    
}