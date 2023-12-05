/*
Class:          psa_om_UpdateInterlockRecsFromProjectBatch
@Author:        MAHESH GANTI
@Created Date:  25 NOVEMBER 2020
@Description:   Batch class to sync Project fields on the related Interlock record
*******************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                             Jira No.        Tag
*******************************************************************************************************************************
Pavithra V      09-Dec-2021     Cosmos     To sync the project details to IPS Jumpstart Engagement          AR-1584         T1
*/
global class psa_om_UpdateInterlockBatch implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        
        DateTime twentyFourHoursAgo = System.now().addHours(-24);
        return Database.getQueryLocator([SELECT Id,psa_om_Interlock__c,psa_pm_Engagement__c,psa_om_InterlockFieldsUpdate_Date__c 
                                        FROM pse__Proj__c 
                                        WHERE psa_om_InterlockFieldsUpdate_Date__c >= :twentyFourHoursAgo]);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
       /** Set<Id> interlockIdSet = new Set<Id>();
        Set<Id> projIdSet = new Set<Id>();
        for(sObject rec : scope){
            projIdSet.add(rec.Id);
        }
        system.debug('**UIB-projIdSet**________'+projIdSet);
        
        List<pse__Proj__c> projRecList = new List<pse__Proj__c>([SELECT id,Name,psa_om_Interlock__c FROM pse__Proj__c WHERE Id IN :projIdSet]);
        for(pse__Proj__c proj : projRecList){
            if(proj.psa_om_Interlock__c <> null){
                interlockIdSet.add(proj.psa_om_Interlock__c);
            }
        }
        system.debug('**UIB-interlockIdSet**________'+interlockIdSet);
        if(interlockIdSet.size()>0){
            psa_om_UpdateInterlockBatchHandler.updateInterLockRecs(interlockIdSet);
        } **/
        
        Set<Id> engagementIdSet = new Set<Id>();
        Set<Id> projIdSet = new Set<Id>();
        for(sObject rec : scope){
            projIdSet.add(rec.Id);
        }
        system.debug('**UIB-projIdSet**________'+projIdSet);
        
        List<pse__Proj__c> projRecList = new List<pse__Proj__c>([SELECT id,Name,psa_pm_Engagement__c FROM pse__Proj__c WHERE Id IN :projIdSet]);
        for(pse__Proj__c proj : projRecList){
            if(proj.psa_pm_Engagement__c <> null){
                engagementIdSet.add(proj.psa_pm_Engagement__c);
            }
        }
        system.debug('**UIB-engagementIdSet**________'+engagementIdSet);
        //
        if(engagementIdSet.size()>0){
            psa_om_UpdateInterlockBatchHandler.updateEngagementRecs(engagementIdSet);
        }
    }

    global void finish(Database.BatchableContext BC){

    }
}