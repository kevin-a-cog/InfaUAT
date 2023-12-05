/*
@created by       : Aishwarya B
@created on       : 12/07/2020
@Purpose          : Case Trigger.
@Testclass        : 
@JIRA             : 

Change History
****************************************************************************************************
ModifiedBy      Date        Jira No.    Tag     Description
****************************************************************************************************
balajip         03/09/2022  I2RT-5624   T01     to turn off recursion check at the TriggerHandler 
                                                    level so that Notification functionality can be 
                                                    invoked during recursive calls.
*/

trigger CaseTrigger on Case (after delete, after insert, after update, before delete, before insert, before update) {
    
    System.debug('CASE TRIGGER ENTRY');
    
    //T01 - setting the parameter recursionCheckNeeded as false to turn off recursion check as 
    // recursion check is done for each handler method using globalApexManager
    new CaseTriggerHandler(false).process();
}