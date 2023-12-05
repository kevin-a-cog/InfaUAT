/*
 * Name			:	CSMCreatePlanProductAliasBatch
 * Author		:	Deva M
 * Created Date	: 	27/03/2022
 * Description	:	this Batch will create Plan Product Alias

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M					27/03/2022		N/A 			Initial version.			N/A
 */
global with sharing class CSMCreatePlanProductAliasBatch implements Database.Batchable<sObject>{
    global static globalApexManager gam = new globalApexManager();
    global static Set<String> setPlanRecordType = new Set<String>{'Optimize_Grow','Digital_Plan','New_Product_Implementation'};
    /*
	 Method Name : start
	 Description : To collect the records or objects to pass to the interface method execute, call the start method at the beginning of a batch Apex job.
	 Parameters	 : A reference to the Database.BatchableContext object.                
	 Return Type : This method returns either a Database.QueryLocator object or an iterable that contains the records or objects passed to the job.
	 */
    global Database.QueryLocator start(Database.BatchableContext BC){
        //String planObjectQuery='SELECT Id, Next_Expected_Adoption_Factor_Date__c, CSM_isAutoPilot__c FROM Plan__c WHERE CSM_isAutoPilot__c = false AND (Next_Expected_Adoption_Factor_Date__c = null OR Next_Expected_Adoption_Factor_Date__c<=:currentDate)';
        String planObjectQuery='SELECT Id FROM Plan__c WHERE Status__c=\'Active\'AND RecordType.DeveloperName=:setPlanRecordType';
        return Database.getQueryLocator(planObjectQuery);
    }
     /*
	 Method Name : execute
	 Description : To do the required processing for each chunk of data, use the execute method. 
                   This method is called for each batch of records that you pass to it.
	 Parameters	 : A reference to the Database.BatchableContext object.
                   A list of Plan__c, such as List<Plan__c>. 
	 Return Type : void
	 */
    global void execute(Database.BatchableContext BC, List<Plan__c> planRecords){
        Set<Id> setPlanIdSet = new Set<Id>();
        if(planRecords!=null && planRecords.size()>0){
            for(Plan__c objPlan:planRecords){ 
                setPlanIdSet.add(objPlan.Id);
            }
            //Crete Plan Product Alias Records for Exisitng records
            if(setPlanIdSet.size()>0){
                PlanProductTriggerHelper.createPlanProductAliasRecords([SELECT Id, Delivery_Method__c, Forecast_Product__c, Account_Plan__c FROM Related_Account_Plan__c WHERE Account_Plan__c =:setPlanIdSet AND Plan_Product_Alias__c=NULL]);
            }
        }
    }
     /*
	 Method Name : finish
	 Description : execute post-processing operations, use the finish method. This method is called after all batches are processed.
	 Parameters	 : A reference to the Database.BatchableContext object.
	 Return Type : void
	 */
    global void finish(Database.BatchableContext BC){
        //Insert debug Logs
        gam.CreateLogs('CSMCreatePlanProductAliasBatch--> finish','timestamp:' + System.now());
        gam.InsertDebugLogs();
    }
}