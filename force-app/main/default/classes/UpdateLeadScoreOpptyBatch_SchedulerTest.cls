/*
Class:  UpdateLeadScoreOpptyBatch_SchedulerTest
        @Author:        Anil Solanki
        @Created Date:  1st March 2018
        @Description:   Test Class for UpdateLeadScoreOpportunityBatch_Schedule Class.
*/
@isTest
private class UpdateLeadScoreOpptyBatch_SchedulerTest{
    @isTest
    static void testschedule() {
        Test.StartTest();
        UpdateLeadScoreOpportunityBatch_Schedule updateSocreBatch= new UpdateLeadScoreOpportunityBatch_Schedule ();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Lead Scoring Schedule', sch, updateSocreBatch); 
        Test.stopTest();        
    }
}