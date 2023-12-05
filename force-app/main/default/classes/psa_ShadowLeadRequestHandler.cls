/*
@created by       : Wasim Akram
@created on       : 02/16/2023
@Purpose          : Trigger Handler for Shadow Lead Request.

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.      Tag
****************************************************************************************************************************

*/
public class psa_ShadowLeadRequestHandler extends TriggerHandler{
    private psa_ShadowLeadRequestTriggerHelper helper = new psa_ShadowLeadRequestTriggerHelper();
    
	//Methods related to the module to be called in before insert context
    public override void beforeInsert() {         
        
    }
    //Methods related to the module to be called in before update context
    public override void beforeUpdate() {         
    }
    //Methods related to the module to be called in after insert context
    public override void afterInsert() {         
        
    }
    //Methods related to the module to be called in after update context
    public override void afterUpdate() {         
            helper.validateFileAttached((List<psa_Shadow_Lead_Request__c>) oldList,(List<psa_Shadow_Lead_Request__c>) newList,(Map<Id, psa_Shadow_Lead_Request__c>) oldMap, (Map<Id, psa_Shadow_Lead_Request__c>) newMap); 
    }
}