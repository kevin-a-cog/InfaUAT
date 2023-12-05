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
public with sharing class SurveyResponseTriggerHandler extends TriggerHandler {
    
    private CSMSurveyResponseTriggerHelper helper = new CSMSurveyResponseTriggerHelper();
    
    
    /*
    Method Name : beforeInsert
    Description : Methods related to the module to be called in before insert context
    */
    public override void beforeInsert() { 
        
    }
    
    /*
    Method Name : afterInsert
    Description : Methods related to the module to be called in After insert context
    */
    public override void afterInsert() {
        helper.processAfterInsert((List<Survey_Response__c>) newList,(Map<Id, Survey_Response__c>) oldMap);
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
        
    }  
    
    /*
    Method Name : afterUpdate
    Description : Methods related to the module to be called in after update context
    */
    public override void afterUpdate() {   
        helper.processAfterUpdate((List<Survey_Response__c>) newList,(Map<Id,Survey_Response__c>) oldMap);
    }
    
     /*
    Method Name : afterUndelete
    Description : Methods related to the module to be called in after undelete context
    */
    public override void afterUndelete() {
        
    } 

}