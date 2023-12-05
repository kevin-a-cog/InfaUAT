/*
@created by       : MAHESH GANTI
@created on       : 11/15/2020
@Purpose          : Trigger Handler for Expense Report.

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.      Tag
****************************************************************************************************************************
Vivek Warrier   15-Jan-2022     Neha Kumari         Adding the Service Now Email Integration              PSA-2134      T01
*/
public class psa_ExpenseReportHandler extends TriggerHandler{
   
    private psa_em_ExpenseReportTriggerHelper helper = new psa_em_ExpenseReportTriggerHelper();
    
    //Methods related to the module to be called in before insert context
    public override void beforeInsert() {         
        helper.populateFieldsBeforeInsert((List<pse__Expense_Report__c>) newList);
        
    }

    //Methods related to the module to be called in Before update context
    public override void beforeUpdate() {        
        helper.populateFieldsBeforeUpdate((List<pse__Expense_Report__c>) oldList,(List<pse__Expense_Report__c>) newList,(Map<Id, pse__Expense_Report__c>) oldMap, (Map<Id, pse__Expense_Report__c>) newMap);
        helper.expenseRejectionChatterPost((List<pse__Expense_Report__c>) oldList,(List<pse__Expense_Report__c>) newList,(Map<Id, pse__Expense_Report__c>) oldMap, (Map<Id, pse__Expense_Report__c>) newMap);
        //helper.sendServiceNowEmail((List<pse__Expense_Report__c>) newList, (Map<Id, pse__Expense_Report__c>) oldMap);//<T01>
    }

    //Methods related to the module to be called in before delete context
    public override void beforeDelete() {        

    }

    //Methods related to the module to be called in after insert context
    public override void afterInsert() {
        //helper.updateProjectAfterSurveyInsert((List<pse__Expense_Report__c>) newList, (Map<Id, pse__Expense_Report__c>) newMap);
    }       
    
    //Methods related to the module to be called in after update context
    public override void afterUpdate() {          
        helper.handleAfterUpdateLogic((List<pse__Expense_Report__c>) newList, (Map<Id, pse__Expense_Report__c>) oldMap);
    }

    //Methods related to the module to be called in after delete context
    public override void afterDelete() {        
        
    }
}