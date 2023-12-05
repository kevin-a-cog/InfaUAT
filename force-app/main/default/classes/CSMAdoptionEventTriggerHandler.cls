/*
@created by       : Mahesh
@created on       : 02/17/2022
@Purpose          : Handler class for Adoption event trigger.

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
public class CSMAdoptionEventTriggerHandler extends TriggerHandler{

     private CSMAdoptionEventTriggerHelper helper = new CSMAdoptionEventTriggerHelper();
    //Methods related to the module to be called in before insert context
    public override void beforeInsert() {         
      helper.populateEngagement((List<Adoption_Event__c>) newList);
    }

  
    //Methods related to the module to be called in after insert context
    public override void afterInsert(){
       
    }
            
 
}