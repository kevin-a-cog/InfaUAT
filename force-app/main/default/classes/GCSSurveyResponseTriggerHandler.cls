/*
Trigger:        GCSSurveyResponseTriggerHandler
@Author:        balajip
@Created Date:  06 July 2021
@Description:   Handles the trigger logic on the object GCSSurveyResponse


************************************************************************************************************************************
ModifiedBy        Date         JIRA NO     Requested By        Description                                  Tag
************************************************************************************************************************************
*/
public class GCSSurveyResponseTriggerHandler extends TriggerHandler{
    
    private GCSSurveyResponseTriggerHelper helper = new GCSSurveyResponseTriggerHelper();
	
    //Methods related to the module to be called in after update context
    public override void afterInsert() {          
        if(globalApexManager.avoidRecursion('GCSSurveyResponseTrigger',  'after', 'insert') ) {
            return;
        }
        helper.notifyCaseTeam((Map<Id, GCS_Survey_Response__c>) newMap, null);
    }
}