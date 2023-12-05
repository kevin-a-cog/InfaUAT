/*
Class:          psa_om_UpdateContractBatchScheduler
@Author:        MAHESH GANTI
@Created Date:  DECEMBER 28 2020
@JIRA            PSA-111
@Description:   Scheduler class to schedule Contract Batch Class to fetch the primary project for the source opportunity.
*/
global class psa_om_UpdateContractBatchScheduler implements Schedulable{ 

    global void execute(SchedulableContext sc) {
        psa_om_UpdateProjectOnContractBatch pseContractBatch = new psa_om_UpdateProjectOnContractBatch();
        Database.executeBatch(pseContractBatch, 200);
    }
}