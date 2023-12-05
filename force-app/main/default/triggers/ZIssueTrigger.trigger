/*
Trigger:        ZIssueTrigger
@Author:        Pavithra V
@Created Date:  16-Mar-2021
@Description:   Trigger on the object ZIssue


************************************************************************************************************************************
ModifiedBy        Date         JIRA NO     Requested By        Description                                  Tag
************************************************************************************************************************************

*/
trigger ZIssueTrigger on zsfjira__ZIssue__c (after update) {
    
    System.debug('Entering the ZIssueTrigger..');
    //Calling the handler method to check for the context/recursive check of the trigger invocation.
    new ZIssueTriggerHandler().process();
}