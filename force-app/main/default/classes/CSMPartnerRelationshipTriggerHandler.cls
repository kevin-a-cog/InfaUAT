/*
* Name			:	CSMPartnerRelationshipTriggerHandler
* Author		:	Deva M
* Created Date	: 	08/07/2021
* Description	:	Handler class which implements interface process methods for Trigger events on partner Relation Ship Object

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					Tag
**********************************************************************************************************
Deva M					08/07/2021		N/A				Initial version.			N/A
*/
public class CSMPartnerRelationshipTriggerHandler extends TriggerHandler {
    private CSMPartnerRelationshipTriggerHelper partnerTriggerHelper = new CSMPartnerRelationshipTriggerHelper();
    /*
    Method Name : beforeInsert
    Description : Methods related to the module to be called in before insert context
    */
    public override void beforeInsert() { 
        partnerTriggerHelper.processBeforeInsert((List<Partner_Relationship__c>) newList);
    }
    /*
    Method Name : beforeInsert
    Description : Methods related to the module to be called in After insert context
    */
    public override void afterInsert() {
    }    
    /*
    Method Name : beforeInsert
    Description : Methods related to the module to be called in Before insert context
    */
    public override void beforeUpdate() {   
        partnerTriggerHelper.processBeforeUpdate((List<Partner_Relationship__c>) newList,(Map<Id,Partner_Relationship__c>) oldMap);
    }    
    /*
    Method Name : beforeInsert
    Description : Methods related to the module to be called in after insert context
    */
    public override void afterUpdate() {     
    }
     /*
    Method Name : beforeInsert
    Description : Methods related to the module to be called in after undelete context
    */
    public override void afterUndelete() {     
    }    

    public override void beforeDelete() {  
        partnerTriggerHelper.processBeforeDelete((List<Partner_Relationship__c>) oldList);
    } 
}