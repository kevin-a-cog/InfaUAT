/*
@created by       : MAHESH GANTI
@created on       : 11/15/2020
@Purpose          : Trigger handler for Expense Object

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                             Jira No.        Tag
Wasim Akram     22-July-2022    Neha Kumari         Alert when expense budget is exceeded   PSA-469         <T1>                                     
****************************************************************************************************************************
*/
public without sharing class psa_em_ExpenseTriggerHelper {

    public class psa_em_ExpenseTriggerHelperException extends Exception {}
    @TestVisible private static Boolean isTestRun = false;
    /**
    * Method called from Before Insert Trigger to populate fields.
    * @param list<Expense> records
    * @return 
    * @throws exception - NA
    */
    public void populateFieldsBeforeInsert(List<pse__Expense__c> newList){
        
        // Also need to check IsClone functionality
        List<pse__Expense__c> expRecsToProcess = new List<pse__Expense__c>();
        for(pse__Expense__c exRec : newList){
            system.debug('**ETH-exRec.pse__Type__c**________'+exRec.pse__Type__c);
            if(exRec.pse__Type__c <> null || exRec.pse__Type__c <> ''){
                expRecsToProcess.add(exRec);
            }
        }
        
        system.debug('**ETH-expRecsToProcess**________'+expRecsToProcess);
        if(expRecsToProcess.size()>0){
            populateCommonFields(expRecsToProcess);
        }
        
    }

    /**
    * Method called from Before Update Trigger to populate fields on Update operation.
    * @param 
    * @return 
    * @throws exception - NA
    */
    public void populateFieldsBeforeUpdate(List<pse__Expense__c> oldList,List<pse__Expense__c> newList, Map<Id,pse__Expense__c> oldMap, Map<Id,pse__Expense__c> newMap){
        List<pse__Expense__c> expRecsToProcess = new List<pse__Expense__c>();
        
        for(pse__Expense__c newRec : newList){
            for(pse__Expense__c oldRec : oldList){
                if(newRec.Id == oldRec.Id){
                    system.debug('**ETH-exRec.pse__Type__c**________'+newRec.pse__Type__c);
                    system.debug('**ETH-exRec.psa_em_GL_Account_Number__c**________'+newRec.psa_em_GL_Account_Number__c);
                    // need to check if the below condition is even valid
                    if((newRec.pse__Type__c <> oldRec.pse__Type__c) ||(newRec.psa_em_GL_Account_Number__c <> oldRec.psa_em_GL_Account_Number__c) || (newRec.psa_em_GL_Account_Number__c == null)){
                        expRecsToProcess.add(newRec);
                    }
                    if((newRec.pse__Type__c <> oldRec.pse__Type__c) && (newRec.pse__Type__c == 'No Expense')){
                        expRecsToProcess.add(newRec);
                    }
                }
            }
        }
        system.debug('**ETH-expRecsToProcess**________'+expRecsToProcess);
        if(expRecsToProcess.size()>0){
            populateCommonFields(expRecsToProcess);
        }
    }

    /**
    * Core method to populate fields based on business logic and is common to both before insert and update operations.
    * @param 
    * @return 
    * @throws exception - NA
    */
    public static void populateCommonFields(List<pse__Expense__c> expListRecs){
        Map<String,String> glMap = fetchGLMap();
        system.debug('**ETH-glMap**________'+glMap);
        for(pse__Expense__c exp : expListRecs){    
            if (exp.pse__Type__c == 'No Expense'){
                exp.pse__Amount__c = 0.0;
            }
            if(glMap.size()>0 && glMap.containsKey(exp.pse__Type__c)){
                exp.psa_em_GL_Account_Number__c = glMap.get(exp.pse__Type__c); 
            }
        }
    }

    /**
    * Method to Fetch Map<ExpenseType, GL Account Number> from the Expense type GLA Mapping metadata.
    * @param 
    * @return Map<ExpenseType, GL Account Number>
    * @throws exception - NA
    */
    public static Map<String,String> fetchGLMap(){
        Map<String,String> expTypeGLAccNumMap = new Map<String,String>();

        for(Expense_Type_GLA_Mapping__mdt glMapping : [SELECT MasterLabel,DeveloperName,psa_pm_GL_Account_Number__c FROM Expense_Type_GLA_Mapping__mdt]){
            expTypeGLAccNumMap.put(glMapping.MasterLabel,glMapping.psa_pm_GL_Account_Number__c);
        }
        return expTypeGLAccNumMap;
    }
    //<T1>
     /**
    * Method to validate Expense Budget Limit during the Expense submission.
    * @param List<pse__Expense__c>,List<pse__Expense__c>,Map<Id,pse__Expense__c>,Map<Id,pse__Expense__c>
    * @return 
    * @throws exception - NA
    */
    @InvocableMethod(label='Validate Expense Budget Limit')
    public static void validateExpenseBudgetLimit(List<ID> expSubmitSet) {
        Set<Id> projSet = new Set<Id>();
        String errorMessage;
        String errorMessageVF;
        Map<Id,Decimal> mapProjectTotalExpBudget = new Map<Id,Decimal>();
        Map<Id,Decimal> mapProjectTotalExpAmount = new Map<Id,Decimal>();
        Map<Id,String> mapProjectName = new Map<Id,String>();
        String projNamesString = '';
       
        for(pse__Expense__c exp : [SELECT pse__Project__c FROM pse__Expense__c WHERE Id IN :expSubmitSet]){
                projSet.add(exp.pse__Project__c);            
        }
        if(projSet.size() > 0 || isTestRun){
            AggregateResult[] agrExpenseBudget = [SELECT SUM(pse__Expense_Amount__c) totalExpenseBudget, pse__Project__c
                                                    FROM pse__Budget__c WHERE pse__Project__c IN :projSet
                                                    AND pse__Include_In_Financials__c = TRUE AND pse__Approved__c = TRUE
                                                    GROUP BY pse__Project__c,pse__Project__r.Name];
            AggregateResult[] agrExpenseAmount = [SELECT SUM(pse__Amount__c) totalExpenseAmount, pse__Project__c, pse__Project__r.Name Name
                                                    FROM pse__Expense__c WHERE pse__Project__c IN :projSet AND pse__Billable__c = TRUE 
                                                    AND((pse__Include_In_Financials__c = TRUE AND pse__Approved__c = TRUE) OR
                                                    pse__Submitted__c = TRUE)
                                                    GROUP BY pse__Project__c,pse__Project__r.Name]; 
           
            for (AggregateResult ar : agrExpenseBudget)  {
                //Add it to a map of Project Id and Total Expense Budget for the project
                mapProjectTotalExpBudget.put((Id) ar.get('pse__Project__c'), (Decimal) ar.get('totalExpenseBudget'));
            }
            for (AggregateResult ar : agrExpenseAmount)  {
                //Add it to a map of Project Id and Total Expense Amount for the project
                mapProjectTotalExpAmount.put((Id) ar.get('pse__Project__c'), (Decimal) ar.get('totalExpenseAmount'));  
                //Store a map of Project Id and Project Name          
                mapProjectName.put((Id) ar.get('pse__Project__c'), (String) ar.get('Name'));
            }
           
            //Loop through the projects and compare the Expense Budget amount and Expense amount for the project
            projSet.clear();
            for(Id projectId : mapProjectTotalExpBudget.KeySet()){
                 if((mapProjectTotalExpBudget.get(projectId)!= null && mapProjectTotalExpAmount.get(projectId)!=null) && mapProjectTotalExpBudget.get(projectId) < mapProjectTotalExpAmount.get(projectId)){
                    //Get the project names which have exceeded the expense budget
                    projNamesString = projNamesString + mapProjectName.get(projectId) + ', ';
                    //Add the project Id to the Set for Chatter post
                    projSet.add(projectId);
                }
            }
            //Throw the validation
            if(String.isNotBlank(projNamesString)){
               projNamesString = projNamesString.trim().removeEnd(',');
               errorMessage = '* * * * * * * * * * * * * * * * * * * * [ '+ projNamesString +' '+ Label.ExpenseLimitExceededError + ' ] * * * * * * * * * * * * * * * * * * * *';
                if(ApexPages.currentPage() != null)// check if the current page is a VF page
                { 
                    errorMessageVF = projNamesString +' '+ Label.ExpenseLimitExceededError;
                    ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessageVF);
                    ApexPages.addMessage(errorMsg);
                }
                throw new psa_em_ExpenseTriggerHelperException(errorMessage);
            }        
        }
    }    
    //</T1>
}