/*
@created by       : MAHESH GANTI
@created on       : 11/15/2020
@Purpose          : Trigger handler for Expense Object

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
public class psa_ExpenseTriggerHandler extends TriggerHandler{
    
    private psa_em_ExpenseTriggerHelper helper = new psa_em_ExpenseTriggerHelper();
    
    //Methods related to the module to be called in before insert context
    public override void beforeInsert() {         
        helper.populateFieldsBeforeInsert((List<pse__Expense__c>) newList);
        
    }

    //Methods related to the module to be called in before update context
    public override void beforeUpdate() {        
        helper.populateFieldsBeforeUpdate((List<pse__Expense__c>) oldList,(List<pse__Expense__c>) newList,(Map<Id, pse__Expense__c>) oldMap, (Map<Id, pse__Expense__c>) newMap);
    }

    //Methods related to the module to be called in before delete context
    public override void beforeDelete() {        

    }

    //Methods related to the module to be called in after insert context
    public override void afterInsert() {

    }       
    
    //Methods related to the module to be called in after update context
    public override void afterUpdate() {          

    }

    //Methods related to the module to be called in after delete context
    public override void afterDelete() {        
        
    }
}