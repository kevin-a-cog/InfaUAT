/*
Class:          PlanProductARRCalculationBatch 
@Author:        Ambica P
@Created Date:  15 July 2020
@Description:   Batch class for calculating PlanProduct ARR fields from Subsciption Lines
*/

/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
    ********************************************************************************************************************************************
   Narpavi Prabu    17-03-2022     AR-2415       Sarojini Bellamkonda  Added the log creation for query to check limit issue
*/


global class PlanProductARRCalculationBatch implements Database.Batchable<sObject> {
    
    global static globalApexManager GAM = new globalApexManager();
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        string query;
        try{
            query = 'SELECT Id,CurrencyISOCode,Plan_Product__c,Start_Date__c,End_Date__c,ARR__c,Contract__c,Contract__r.SBQQ__RenewalOpportunity__c,Contract__r.SBQQ__Opportunity__c,Contract__r.SBQQ__Opportunity__r.RecordtypeId FROM Subscription_Line__c WHERE Plan_Product__c!=null AND Plan_Product__r.Account_Plan__r.Status__c=\'Active\' and (Createddate =  LAST_N_DAYS:1  OR Start_Date__c = TODAY OR End_Date__c = YESTERDAY) Order By Contract__c';        
        	
        } Catch(Exception e){
                String linenumber = String.valueOf(e.getLineNumber());
                GAM.CreateLogs('PlanProductARRCalculationBatch--> Query Exception-->', e.getMessage(),'Query',linenumber );
                
           }
        return Database.getQueryLocator(query);
       
    }
    
    global void execute(Database.BatchableContext BC, List<Subscription_Line__c> scope)
    {
        set<id> planproductIds = new set<id>();
        if (scope != null && scope.size() > 0) {
            System.debug('Scope Batch'+scope);
        for(SubScription_Line__c subline : scope){
             System.debug('Subline Plan Product Batch'+subline.Plan_Product__c);
            If(subline.Plan_Product__c != null ){               
                planproductIds.add(subline.Plan_Product__c);
            }
        }   
            PlanProductARRCalculation.updatePlanProducts(planproductIds);
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        //Insert debug Logs
        GAM.CreateLogs('PlanProductARRCalculationBatch --> finish','timestamp:' + System.now());
        GAM.InsertDebugLogs();
    }
    

}