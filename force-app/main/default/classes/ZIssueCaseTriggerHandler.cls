/*
Trigger:        ZIssueCaseTriggerHandler
@Author:        balajip
@Created Date:  06 July 2021
@Description:   Handles the trigger logic on the object ZIssueCase


************************************************************************************************************************************
ModifiedBy        Date         JIRA NO     Requested By        Description                                  Tag
************************************************************************************************************************************
*/
public class ZIssueCaseTriggerHandler extends TriggerHandler{
    
    private ZIssueCaseTriggerHelper helper = new ZIssueCaseTriggerHelper();
	
    //Methods related to the module to be called in after update context
    public override void afterInsert() {          
        if(globalApexManager.avoidRecursion('ZIssueCaseTrigger',  'after', 'insert') ) {
            return;
        }
        helper.notifyCaseTeam((Map<Id, zsfjira__ZIssue_Case__c>) newMap, null);
    }
}