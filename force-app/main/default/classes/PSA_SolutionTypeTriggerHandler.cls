/*
@created by       : RANJAN KISHORE
@created on       : 05/27/2021
@Purpose          : Handler class for PSA_SolutionTypeTrigger.

Change History
**************************************************************************************************************************
ModifiedBy  |    Date       |     Requested By  |   	Description                            |  Jira No.      | Tag No:
***************************************************************************************************************************
*/
public class PSA_SolutionTypeTriggerHandler extends TriggerHandler{
    
    private PSA_SolutionTypeTriggerHelper helper = new PSA_SolutionTypeTriggerHelper();
    
    //Methods related to the module to be called in before insert context
    public override void beforeInsert() { 
       helper.validateProductSplitPercentageOnInsert((List<psa_pm_Solution_Type__c>) newList);
       helper.prepopulateFieldsOnInsert((List<psa_pm_Solution_Type__c>) newList);
        
    }

    //Methods related to the module to be called in after update context
    public override void beforeUpdate() { 
    helper.validateProductSplitPercentageOnUpdate((Map<Id,psa_pm_Solution_Type__c>) newMap,(Map<Id,psa_pm_Solution_Type__c>) oldMap);   
    }

    //Methods related to the module to be called in after update context
    public override void beforeDelete() {        
    
    }

    //Methods related to the module to be called in after insert context
    public override void afterInsert() {
    
    }       
    
    //Methods related to the module to be called in before insert context
    public override void afterUpdate() {          
    
    }

    //Methods related to the module to be called in after update context
    public override void afterDelete() {        
        
    }
}