/*
@created by       : PAVITHRA
@created on       : 11/24/2021
@Purpose          : Handler class for pse_BudgetTrigger.

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
public class pse_BudgetTriggerHandler extends TriggerHandler {

    private pse_BudgetTriggerHelper helper = new pse_BudgetTriggerHelper();
    
    //Methods related to the module to be called in after insert context
    public override void afterInsert(){
        helper.updateProjectPlannedHours((List<pse__Budget__c>) newList, (Map<Id,pse__Budget__c>) oldMap);
      
    }
        
    //Methods related to the module to be called in After Update context
    public override void afterUpdate() {
        helper.updateProjectPlannedHours((List<pse__Budget__c>) newList, (Map<Id,pse__Budget__c>) oldMap);
    }
    
    //Methods related to the module to be called in After Update context
    public override void afterDelete() {
        helper.deductProjectPlannedHours((Map<Id,pse__Budget__c>) oldMap);
    }
}