/*
@created by       : RANJAN KISHORE
@created on       : 03/02/2021
@Purpose          : Handler class for PSA_StatusReportTrigger.

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
public class PSA_MilestoneTriggerHandler  extends TriggerHandler{
    
    private PSA_MilestoneTriggerHelper helper = new PSA_MilestoneTriggerHelper();
    
    //Methods related to the module to be called in before insert context
    public override void beforeInsert() {         
      helper.populateFieldsOnInsert((List<pse__Milestone__c>) newList);
    }
    
    //Methods related to the module to be called in after insert context
    public override void afterInsert(){
       helper.updateProjectFields((List<pse__Milestone__c>) newList,(Map<Id,pse__Milestone__c>) oldMap,'INSERT');
    }
        
   //Methods related to the module to be called in After Update context
    public override void afterUpdate() {  
    	helper.updateProjectFields((List<pse__Milestone__c>) newList,(Map<Id,pse__Milestone__c>) oldMap,'UPDATE');
	}
    
	/**
	//Methods related to the module to be called in BEFORE update context
    public override void beforeUpdate() {        
       
    } 
	**/
    //Methods related to the module to be called in after Delete context
    public override void afterDelete() {        
        helper.updateProjectFields((List<pse__Milestone__c>) newList,(Map<Id,pse__Milestone__c>) oldMap,'DELETE');
    }
    /**
    //Methods related to the module to be called in Before Delete context
    public override void beforeDelete() {   

    } 
    */

}