/*
@created by       : RANJAN KISHORE
@created on       : 02/12/2021
@Purpose          : Handler class for PSA_AdoptionEventTrigger.

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
public class PSA_AdoptionEventTriggerHandler extends TriggerHandler{
    
    private PSA_AdoptionEventTriggerHelper helper = new PSA_AdoptionEventTriggerHelper();
    
    //Methods related to the module to be called in before insert context
    public override void beforeInsert() {         
       helper.defaultAdoptionEvtFieldsValOnInsert((List<Adoption_Event__c>) newList);
    }

   /* //Methods related to the module to be called in BEFORE update context
    public override void beforeUpdate() {        
       
    } */

    //Methods related to the module to be called in after insert context
    public override void afterInsert(){
       
    }
            
  /*  //Methods related to the module to be called in After Update context
    public override void afterUpdate() {  
       
    }

    //Methods related to the module to be called in after Delete context
    public override void afterDelete() {        
        
    }
    
    //Methods related to the module to be called in Before Delete context
    public override void beforeDelete() {   

    } 
    */
}