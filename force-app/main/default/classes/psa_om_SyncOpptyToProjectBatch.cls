/*
Class:          psa_om_SyncOpptyToProjectBatch
@Author:        MAHESH GANTI
@Created Date:  24 JULY 2021
@JIRA           : PSA - 1904
@Description:   Batch class to update Project attributes from Opportunity.
*/

global class psa_om_SyncOpptyToProjectBatch implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator([SELECT Id,pse__Region__c,Sales_Journey__c,PSA_Field_Change_Timestamp__c FROM Opportunity WHERE (PSA_Field_Change_Timestamp__c = LAST_N_DAYS:1)]);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        

        if(scope.size()>0){
            psa_om_AmmendOpportunityHandler.updateProjectFromOppty(scope);
        }
    }

    global void finish(Database.BatchableContext BC){

    }
}