/**
 * Name         : ConsumptionScheduleTriggerHandlerTest
 * Author       : Stephanie Viereckl | ATG, Cognizant | stephanie.viereckl@atginfo.com
 * Created Date : October 22, 2021
 * Description  : This test class covers IPUE_FileAttachmentHelper
 * 
 * Change History
 *************************************************************************************
 * ModifiedBy               Date            JIRA No.    Description             Tag
 *************************************************************************************
 * Stephanie Viereckl       10-22-21        IPUE-     Initial create
 */
@isTest
public with sharing class ConsumptionScheduleTriggerHandlerTest {

    /**
     * Test inserting a Consumption Schedule record with the "Estimation Schedule" record type and check that 
     */
    @isTest
    private static void processEstimationSchedulesTest(){

        ConsumptionSchedule consumptionSched = IPUE_TestUtils.createConsumptionSchedule(false, 'Test Consumption Schedule', 'Estimation Schedule');
        insert consumptionSched;

        // Check to see a Consumption Rate was created
        List<ConsumptionRate> relatedRates = [SELECT Id FROM ConsumptionRate WHERE ConsumptionScheduleId = :consumptionSched.Id];
        System.assertEquals(1, relatedRates.size(), 'Consumption Rate was not created upon inserting Consumption Schedule');

        consumptionSched = [SELECT Id, isActive FROM ConsumptionSchedule WHERE Id = :consumptionSched.Id];
        System.assertEquals(true, consumptionSched.isActive, 'Consumption Schedule was not automatically activated as expected');

    }

}