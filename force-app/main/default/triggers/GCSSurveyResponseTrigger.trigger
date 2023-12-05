/*
Trigger:        GCSSurveyResponseTrigger
@Author:        balajip
@Created Date:  06 July 2021
@Description:   Trigger on the object ZIssue Case


************************************************************************************************************************************
ModifiedBy        Date         JIRA NO     Requested By        Description                                  Tag
************************************************************************************************************************************

*/
trigger GCSSurveyResponseTrigger on GCS_Survey_Response__c (after insert) {
    
    System.debug('Entering the GCSSurveyResponseTrigger..');
    //Calling the handler method to check for the context/recursive check of the trigger invocation.
    new GCSSurveyResponseTriggerHandler().process();
}