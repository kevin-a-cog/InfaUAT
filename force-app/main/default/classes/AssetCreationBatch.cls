/*
Class:          AssetCreationBatch 
@Author:        Vignesh D
@Created Date:  25 September 2020
@Description:   Batch class to process Contracts for Assets & Entitlements
*/

/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
    ********************************************************************************************************************************************
   
*/

global class AssetCreationBatch implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'Select Id,SBQQ__Order__c from Contract Where SBQQ__Order__r.Asset_Creation_Status__c = \'Initiated\'';
        return Database.getQueryLocator(query);

    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        for(sObject s: scope){
            Contract c = (Contract)s;
            AssetCreationBatchHandler.handleAssets(c);
        }
    }

    global void finish(Database.BatchableContext BC){

        //System.debug('Batch completed');

    }
    
}