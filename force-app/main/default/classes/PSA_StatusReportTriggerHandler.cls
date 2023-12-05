/*
@created by       : RANJAN KISHORE
@created on       : 02/17/2021
@Purpose          : Handler class for PSA_StatusReportTrigger.

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
public class PSA_StatusReportTriggerHandler  extends TriggerHandler{
    
    private PSA_StatusReportTriggerHelper helper = new PSA_StatusReportTriggerHelper();
    
    //Methods related to the module to be called in before insert context
    public override void beforeInsert() {         
      helper.addEngagementToStatusReport((List<Status_Report__c>) newList);
    }
	/**
   //Methods related to the module to be called in BEFORE update context
    public override void beforeUpdate() {        
       
    } 

    //Methods related to the module to be called in after insert context
    public override void afterInsert(){
       
    }
   */       
   //Methods related to the module to be called in After Update context
    public override void afterUpdate() {  
       // (List<Adoption_Event__c>) newList
       helper.delStatusReportTimeCardDetailRecords((Map<Id,Status_Report__c>) newMap, (Map<Id,Status_Report__c>) oldMap);
    }
/* 
    //Methods related to the module to be called in after Delete context
    public override void afterDelete() {        
        
    }
    
    //Methods related to the module to be called in Before Delete context
    public override void beforeDelete() {   

    } 
    */

}