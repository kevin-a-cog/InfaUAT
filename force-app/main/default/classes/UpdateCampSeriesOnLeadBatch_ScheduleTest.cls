/*
Class:  UpdateCampSeriesOnLeadBatch_ScheduleTest
        @Author:        Anil Solanki
        @Created Date:  25th March 2021
        @Description:   Test Class for UpdateCampaignSeriesOnLeadBatch_Schedule Class.
*/
@isTest
private class UpdateCampSeriesOnLeadBatch_ScheduleTest{
    @isTest
    static void testschedule() {
        Test.StartTest();
        UpdateCampaignSeriesOnLeadBatch_Schedule updateCampSeriesBatch= new UpdateCampaignSeriesOnLeadBatch_Schedule();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Lead and Contact Campaign Series Schedule', sch, updateCampSeriesBatch); 
        Test.stopTest();        
    }
}