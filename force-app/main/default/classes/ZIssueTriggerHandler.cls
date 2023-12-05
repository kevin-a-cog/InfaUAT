/*
Trigger:        ZIssueTriggerHandler
@Author:        Pavithra V
@Created Date:  16 March 2021
@Description:   Handles the trigger logic on the object ZIssue


************************************************************************************************************************************
ModifiedBy        Date         JIRA NO     Requested By        Description                                  Tag
************************************************************************************************************************************
*/
public class ZIssueTriggerHandler extends TriggerHandler{
    
    private ZIssueTriggerHelper helper = new ZIssueTriggerHelper();
	
    //Methods related to the module to be called in after update context
    public override void afterUpdate() {          
        if(globalApexManager.avoidRecursion('ZIssueTrigger',  'after', 'update') ) {
            return;
        }
        helper.notifyCaseTeam((Map<Id, zsfjira__ZIssue__c>) newMap , (Map<Id, zsfjira__ZIssue__c>) oldMap);
    }
}