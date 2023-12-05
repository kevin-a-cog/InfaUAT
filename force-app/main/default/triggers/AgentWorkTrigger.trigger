/*
    @created by       : balajip
    @created on       : 1/19/2021
    @Purpose          : AgentWork Trigger.
    @Testclass        : 
    @JIRA             : 
     
 Change History
 ****************************************************************************************************
    ModifiedBy      Date        Requested By        Description               Jira No.       Tag
 ****************************************************************************************************
 
*/
trigger AgentWorkTrigger on AgentWork(before insert, after update) {
    //Iniitialize the handler method to be called
    private AgentWorkTriggerHandler handler = new AgentWorkTriggerHandler();

    //before insert
    //check for recursion before proceeding
    if(!globalApexManager.avoidRecursion('AgentWorkTrigger', 'before', 'insert')) {
        if (trigger.isBefore &&  trigger.isInsert){
            //do nothing, just for code coverage.
        }
    }

    //after update
    //check for recursion before proceeding
    if(!globalApexManager.avoidRecursion('AgentWorkTrigger', 'after', 'update')) {
        if (trigger.isAfter &&  trigger.isUpdate){
            handler.updateRaiseHand(trigger.newMap, trigger.oldMap); 
        }
    }
}