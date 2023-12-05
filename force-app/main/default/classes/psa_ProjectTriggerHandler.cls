/*
@created by       : MAHESH GANTI
@created on       : 10/20/2020
@Purpose          : Handler class for Project Trigger.

Change History
*******************************************************************************************************************************************************
ModifiedBy              Date            Requested By        Description                                                         Jira No.        Tag
*******************************************************************************************************************************************************
Vivek Warrier           18-Nov-2021     Neha Kumari         Adding a call to create Opty for Child Project                      PSA-2070        T1
Pavithra V              09-Dec-2021     Cosmos              To sync the project details to IPS Jumpstart Engagement             AR-1584         T2
Vivek Warrier           22-Dec-2021     Neha Kumari         Adding a call to update Project Name on AfterInsert                 PSA-2082        T3
Rohit Niranjanamath     18-Nov-2023     PSA Nov Build '23   Tech Debt: Code refactoring to align with Unit of Work Framework    PSa-3227        T4
*/
public class psa_ProjectTriggerHandler extends TriggerHandler{
    
    private psa_pm_ProjectTriggerHelper helper = new psa_pm_ProjectTriggerHelper();
    
    //Methods related to the module to be called in before insert context
    public override void beforeInsert() {         
        helper.runValidationsOnInsert((List<pse__Proj__c>) newList);
        helper.defaultProjectFieldValOnInsert((List<pse__Proj__c>) newList);
    }

    //Methods related to the module to be called in BEFORE update context
    public override void beforeUpdate() {        
        helper.runValidationsOnUpdate((List<pse__Proj__c>) oldList,(List<pse__Proj__c>) newList,(Map<Id, pse__Proj__c>) oldMap, (Map<Id, pse__Proj__c>) newMap);
        helper.defaultProjectFieldValOnUpdate((List<pse__Proj__c>) oldList,(List<pse__Proj__c>) newList,(Map<Id, pse__Proj__c>) oldMap, (Map<Id, pse__Proj__c>) newMap);
    }

    //Methods related to the module to be called in Before Delete context
    public override void beforeDelete() {   

    }

    //Methods related to the module to be called in after insert context
    public override void afterInsert(){
        helper.createChildProjectOpty((List<pse__Proj__c>) newList); //<T1>
        helper.updateProjectName((Map<Id,pse__Proj__c>) newMap,(List<pse__Proj__c>) newList); //T3
        helper.handleAfterProjInsertActions((List<pse__Proj__c>) newList, (Map<Id,pse__Proj__c>) newMap);
        helper.createProjectContactRecs((List<pse__Proj__c>) newList, (Map<Id,pse__Proj__c>) newMap);
        helper.createBudgetRecs((List<pse__Proj__c>) newList, (Map<Id,pse__Proj__c>) newMap);
        helper.checkForPMPermissions((List<pse__Proj__c>) newList, (Map<Id,pse__Proj__c>) newMap);
        helper.updateSolutionTypeRecs((List<pse__Proj__c>) newList, (Map<Id,pse__Proj__c>) newMap);
        helper.callCommitMethod((List<pse__Proj__c>) newList); //<T4>
    }
        
    
    //Methods related to the module to be called in After Update context
    public override void afterUpdate() {  
        helper.checkForResReqUpdatesOnProjUpdate((List<pse__Proj__c>) oldList,(List<pse__Proj__c>) newList,(Map<Id, pse__Proj__c>) oldMap, (Map<Id, pse__Proj__c>) newMap);
        helper.checkForPMPermissionsOnUpdate((List<pse__Proj__c>) oldList,(List<pse__Proj__c>) newList,(Map<Id, pse__Proj__c>) oldMap, (Map<Id, pse__Proj__c>) newMap);
        helper.syncProjectBackToEngagement((List<pse__Proj__c>) newList,(Map<Id, pse__Proj__c>) oldMap);/**<T2>**/
        helper.callCommitMethod((List<pse__Proj__c>) newList); //<T4>
    }

    //Methods related to the module to be called in after Delete context
    public override void afterDelete() {        
        
    }
    
}