/*
@created by       : Vivek Warrier
@created on       : 18-Aug-2021
@Purpose          : Billing Event Trigger Handler
@Testclass        : 
@JIRA             : 

*/
/*
Change History
**********************************************************************************************************************************************************
ModifiedBy          Date        Requested By             JIRA           Description                                                          Tag
**********************************************************************************************************************************************************

*/
public class psa_BillingEventTriggerHandler extends TriggerHandler{

    private psa_bm_BillingEventTriggerHelper helper = new psa_bm_BillingEventTriggerHelper();
    
     //Methods related to the module to be called in before insert context
    public override void beforeInsert() {         
        helper.beforeInsertActions(Trigger.New);
    }

    /*//Methods related to the module to be called in before update context
    public override void beforeUpdate() { 
       
    }

    //Methods related to the module to be called in before delete context
    public override void beforeDelete() {        
        
    }*/

    //Methods related to the module to be called in after insert context
    public override void afterInsert() {
        
    }       
    
    /*//Methods related to the module to be called in after update context
    public override void afterUpdate() {          
        
    }

    //Methods related to the module to be called in after delete context
    public override void afterDelete() {        
        
    }*/
}