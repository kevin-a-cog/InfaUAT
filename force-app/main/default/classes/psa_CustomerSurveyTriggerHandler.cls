/*
@created by       : MAHESH GANTI
@created on       : 10/25/2020
@Purpose          :  Handler class for Customer Survey Trigger.

Change History
***********************************************************************************************************************************************
ModifiedBy              Date            Requested By        Description                                                         Jira No.       Tag
Rohit Niranjanamath     18-Nov-2023     PSA Nov Build '23   Tech Debt: Code refactoring to align with Unit of Work Framework    PSA-3227       T1
************************************************************************************************************************************************
*/
public class psa_CustomerSurveyTriggerHandler extends TriggerHandler{
    
    private psa_pm_CustomerSurveyTriggerHelper helper = new psa_pm_CustomerSurveyTriggerHelper();
    
    //Methods related to the module to be called in before insert context
    public override void beforeInsert() {         
        
        helper.populateSurveyConsultantsBeforeInsert((List<psa_pm_IPS_Customer_Survey__c>) newList);
    }

    //Methods related to the module to be called in before update context
    public override void beforeUpdate() {  
        helper.populateSurveyFieldsBeforeInsert((List<psa_pm_IPS_Customer_Survey__c>) newList);
        helper.populateSurveyFieldsBeforeUpdate((List<psa_pm_IPS_Customer_Survey__c>) oldList,(List<psa_pm_IPS_Customer_Survey__c>) newList,(Map<Id, psa_pm_IPS_Customer_Survey__c>) oldMap, (Map<Id, psa_pm_IPS_Customer_Survey__c>) newMap);
    }

    //Methods related to the module to be called in before delete context
    public override void beforeDelete() {        

    }

    //Methods related to the module to be called in after insert context
    public override void afterInsert() {
        helper.updateProjectAfterSurveyInsert((List<psa_pm_IPS_Customer_Survey__c>) newList, (Map<Id, psa_pm_IPS_Customer_Survey__c>) newMap);
        helper.callCommitMethod((List<psa_pm_IPS_Customer_Survey__c>) newList); //<T1>
    }       
    
    //Methods related to the module to be called in after update context
    public override void afterUpdate() {          

    }

    //Methods related to the module to be called in after delete context
    public override void afterDelete() {        
        
    }
}