/*
@created by       : MAHESH GANTI
@created on       : 12/05/2020
@Purpose          : Test class for psa_om_Ipsa_om_UpdateInterlockBatchScheduler Controller

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/

@isTest
private class psa_om_UpdateInterlockBatchSchedulerTest {
    
    static testMethod void testschedule() {
        Test.StartTest();
        psa_om_UpdateInterlockBatchScheduler schClass = new psa_om_UpdateInterlockBatchScheduler();
        String cronexpression = '0 0 1 * * ?';
        System.schedule('PSA-Project-Interlock Batch = TEST CLASS', cronexpression, schClass);
        Test.stopTest();        
    }
}