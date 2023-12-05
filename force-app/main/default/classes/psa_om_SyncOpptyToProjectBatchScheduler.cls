/*
Class:          psa_om_SyncOpptyToProjectBatchScheduler
@Author:        MAHESH GANTI
@Created Date:  JULY 28 2021
@JIRA            PSA-111
@Description:   Scheduler class to sync PSA Field on Opportunity  to Project
*/

global class psa_om_SyncOpptyToProjectBatchScheduler implements Schedulable{ 

    global void execute(SchedulableContext sc) {
        psa_om_SyncOpptyToProjectBatch pseContractBatch = new psa_om_SyncOpptyToProjectBatch();
        Database.executeBatch(pseContractBatch, 200);
    }
}