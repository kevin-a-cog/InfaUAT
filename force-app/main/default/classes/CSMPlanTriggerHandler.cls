/*
* Name			:	CSMPlanTriggerHandler
* Author		:	Pavithra V
* Created Date	: 	08/20/2021
* Description	:	Handler class which implements interface process methods for Trigger events on Plan Object

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					Tag
**********************************************************************************************************
*/
public class CSMPlanTriggerHandler extends TriggerHandler {
    
    private CSMPlanTriggerHelper helper = new CSMPlanTriggerHelper();
    
    
    /*
    Method Name : beforeInsert
    Description : Methods related to the module to be called in before insert context
    */
    public override void beforeInsert() { 
        helper.processBeforeInsert((List<Plan__c>) newList);
    }
    
    /*
    Method Name : afterInsert
    Description : Methods related to the module to be called in After insert context
    */
    public override void afterInsert() {
        helper.processAfterInsert((List<Plan__c>) newList,(Map<Id, Plan__c>) oldMap);
    } 
    
    /*
    Method Name : afterDelete
    Description : Methods related to the module to be called in After delete context
    */
    public override void afterDelete() {     
    }    
    
    /*
    Method Name : beforeUpdate
    Description : Methods related to the module to be called in Before update context
    */
    public override void beforeUpdate() {   
        helper.processBeforeUpdate((List<Plan__c>) newList,(Map<Id,Plan__c>) oldMap);
    }  
    
    /*
    Method Name : afterUpdate
    Description : Methods related to the module to be called in after update context
    */
    public override void afterUpdate() {   
        helper.processAfterUpdate((List<Plan__c>) newList,(Map<Id,Plan__c>) oldMap);
        TrackerUtility.track((Map<Id,Plan__c>) newMap);
    }
    
     /*
    Method Name : afterUndelete
    Description : Methods related to the module to be called in after undelete context
    */
    public override void afterUndelete() {
        
    } 

}