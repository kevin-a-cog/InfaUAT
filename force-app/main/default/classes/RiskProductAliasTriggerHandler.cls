/*
* Name			:	RiskProductAliasTriggerHandler
* Author		:	Deva M
* Created Date	: 	21/02/2022
* Description	:	Handler class which implements interface process methods for Trigger events on Risk Product Alias Object

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					Tag
**********************************************************************************************************
Deva M		        21/02/2022		N/A				Initial version.			N/A
*/
public with sharing class RiskProductAliasTriggerHandler extends TriggerHandler {
    private RiskProductAliasTriggerHelper helper = new RiskProductAliasTriggerHelper();   
    
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
        helper.processAfterInsert((List<Risk_Product_Alias__c>) newList);
    } 
    
    /*
    Method Name : afterDelete
    Description : Methods related to the module to be called in After delete context
    */
    public override void afterDelete() {     
        helper.processAfterDelete((List<Risk_Product_Alias__c>) oldList);
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
        helper.processAfterUpdate((List<Risk_Product_Alias__c>) newList,(Map<Id,Risk_Product_Alias__c>) oldMap); 
    }
    
     /*
    Method Name : afterUndelete
    Description : Methods related to the module to be called in after undelete context
    */
    public override void afterUndelete() {
        
    } 
}