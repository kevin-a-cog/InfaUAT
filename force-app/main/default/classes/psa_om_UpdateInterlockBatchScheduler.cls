/*
Class:          psa_om_UpdateInterlockBatchScheduler
@Author:        MAHESH GANTI
@Created Date:  DECEMBER 1 2020
@Description:   Scheduler class to schedule Interlock Batch Class
*/
global class psa_om_UpdateInterlockBatchScheduler implements Schedulable{ 

    global void execute(SchedulableContext sc) {
        psa_om_UpdateInterlockBatch interlockBatch = new psa_om_UpdateInterlockBatch();
        Database.executeBatch(interlockBatch, 200);
    }
}