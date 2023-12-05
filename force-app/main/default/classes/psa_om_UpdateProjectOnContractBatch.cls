/*
Class:          psa_om_UpdateProjectOnContractBatch
@Author:        MAHESH GANTI
@Created Date:  23 DECEMBER 2020
@JIRA             : PSA-111
@Description:   Batch class to update Primary Project on Contract
*/
global class psa_om_UpdateProjectOnContractBatch implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator([SELECT Id,Status,SBQQ__Opportunity__c,PSA_OM_Project__c,CreatedDate,PSA_Contract_Trigger_Time__c FROM Contract WHERE (CreatedDate = LAST_N_DAYS:1 OR PSA_Contract_Trigger_Time__c = LAST_N_DAYS:1) AND PSA_OM_Project__c = NULL]);
    }

    global void execute(Database.BatchableContext BC, List<Contract> scope){
        
        List<Contract> contractRecsToProcess = new List<Contract>();
        for(Contract conRec : scope){
            if(conRec.PSA_OM_Project__c == null){
                contractRecsToProcess.add(conRec);
            }        
        }
        system.debug('**CB-contractRecsToProcess*'+contractRecsToProcess);

        if(contractRecsToProcess.size()>0){
            psa_om_AmmendOpportunityHandler.updateProjectIdOnContract(contractRecsToProcess);
        }
    }

    global void finish(Database.BatchableContext BC){

    }
}