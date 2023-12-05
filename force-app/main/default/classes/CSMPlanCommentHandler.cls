/*
* Name			:	CSMPlanCommentHandler
* Author		:	Deva M
* Created Date	: 	08/07/2021
* Description	:	Handler class which implements interface process methods for Trigger events on Plan comment Object

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					Tag
**********************************************************************************************************
Deva M					08/07/2021		N/A				Initial version.			N/A
*/
public with sharing class CSMPlanCommentHandler extends TriggerHandler {
    private CSMPlanCommentTriggerHelper planCommentTriggerHelper = new CSMPlanCommentTriggerHelper();
    /*
    Method Name : beforeInsert
    Description : Methods related to the module to be called in before insert context
    */
    public override void beforeInsert() { 
       
    }
    /*
    Method Name : beforeInsert
    Description : Methods related to the module to be called in After insert context
    */
    public override void afterInsert() {
        planCommentTriggerHelper.processAfterInsert((List<Plan_Comment__c>) newList);
    }    
	
	/*
	 Method Name : afterUpdate
	 Description : Method related to the module to be called in After Update context.
	 Parameters	 : None
	 Return Type : None
	 */
    public override void afterUpdate() {
        planCommentTriggerHelper.processAfterUpdate((Map<Id, Plan_Comment__c>) oldMap, (List<Plan_Comment__c>) newList);
    }    
}