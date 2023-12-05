/*
* Name			:	CSMPlanContactTriggerHandler
* Author		:	Deva M
* Created Date	: 	08/07/2021
* Description	:	Handler class which implements interface process methods for Trigger events on Plan contact Object

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					Tag
**********************************************************************************************************
Deva M					08/07/2021		N/A				Initial version.			N/A
*/
public class CSMPlanContactTriggerHandler extends TriggerHandler {
    private CSMPlanContactTriggerHelper planContactTriggerHelper = new CSMPlanContactTriggerHelper();
    /*
    Method Name : beforeInsert
    Description : Methods related to the module to be called in before insert context
    */
    public override void beforeInsert() { 
        //Call this below line first and call validation after that
        planContactTriggerHelper.processBeforeInsert((List<Plan_Contact__c>) newList);
    }
    /*
    Method Name : beforeInsert
    Description : Methods related to the module to be called in After insert context
    */
    public override void afterInsert() {
        planContactTriggerHelper.processAfterInsert((List<Plan_Contact__c>) newList);
    }    
    /*
    Method Name : beforeInsert
    Description : Methods related to the module to be called in Before insert context
    */
    public override void beforeUpdate() {   
        planContactTriggerHelper.processBeforeUpdate((List<Plan_Contact__c>) newList,(Map<Id,Plan_Contact__c>) oldMap);
    }    
    /*
    Method Name : beforeInsert
    Description : Methods related to the module to be called in after update context
    */
    public override void afterUpdate() {
        planContactTriggerHelper.processafterUpdate((List<Plan_Contact__c>) newList,(Map<Id,Plan_Contact__c>) oldMap);
        planContactTriggerHelper.updatePlanrecord((List<Plan_Contact__c>) newList);      
        planContactTriggerHelper.updateEngagmentrecord((List<Plan_Contact__c>) newList);
    }
     /*
    Method Name : beforeInsert
    Description : Methods related to the module to be called in after undelete context
    */
    public override void afterUndelete() {   
    }

    public override void beforeDelete() {   
        planContactTriggerHelper.processBeforeDelete((List<Plan_Contact__c>) oldList);
    }
    
  
}