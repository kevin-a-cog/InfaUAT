/*
@created by       : MAHESH GANTI
@created on       : 07/28/2021
@Purpose          : Test class for psa_om_SyncOpptyToProjectBatchScheduler Controller

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/

@isTest
private class psa_om_SyncOpptyToProjBatchSchTest {
    
    static testMethod void testschedule() {
        Test.StartTest();
        psa_om_SyncOpptyToProjectBatchScheduler schClass = new psa_om_SyncOpptyToProjectBatchScheduler();
        String cronexpression = '0 0 1 * * ?';
        System.schedule('PSA-Opportunity Project = TEST CLASS', cronexpression, schClass);
        Test.stopTest();        
    }
}