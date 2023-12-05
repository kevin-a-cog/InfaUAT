/*
Trigger:        ZIssueCaseTrigger
@Author:        balajip
@Created Date:  06 July 2021
@Description:   Trigger on the object ZIssue Case


************************************************************************************************************************************
ModifiedBy        Date         JIRA NO     Requested By        Description                                  Tag
************************************************************************************************************************************

*/
trigger ZIssueCaseTrigger on zsfjira__ZIssue_Case__c (after insert) {
    
    System.debug('Entering the ZIssueCaseTrigger..');
    //Calling the handler method to check for the context/recursive check of the trigger invocation.
    new ZIssueCaseTriggerHandler().process();
}