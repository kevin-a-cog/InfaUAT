/*
Class:          CreateSubscriptionLineBatchScheduleTest 
@Author:        Ambica P
@Created Date:  15 July 2020
@Description:   Test  class for CreateSubscriptionLineBatchSchedule
*/

@isTest
public class CreateSubscriptionLineScheduleTest {
    
    static testMethod void testschedule() {
        Test.StartTest();
        CreateSubscriptionLineBatchSchedule createSubscriptionLines = new CreateSubscriptionLineBatchSchedule();
        String sch = '0 0 23 * * ?';
        system.schedule('Test CreateSubscriptionLineBatchSchedule', sch, createSubscriptionLines); 
        Test.stopTest();        
    }

}