/*
    @Author:        Stephanie Viereckl
    @Created Date:  Nov 4 2021
    @Description:   This class tests the IPUE_IntegrationRequestBuilder class.

    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag

    Stephanie Viereckl Nov 2021  IPUE-105                           Initial Create                     
    ********************************************************************************************************************************************
*/
@isTest
public with sharing class IPUE_IntegrationRequestBuilderTest {
    
    @TestSetup
    static void setup(){

        Account testAccount = IPUE_TestUtils.createAccount(true);
        Opportunity testOpp = IPUE_TestUtils.createOpportunity(true, testAccount);
        
        IPUE_TestUtils.setupFormData();
        Form__c testForm = [SELECT Id FROM Form__c LIMIT 1];
        Page_Section__c pageSection = [SELECT Id FROM Page_Section__c LIMIT 1];

        Estimation_Summary__c testSummary = IPUE_TestUtils.createEstimationSummary(false, testOpp.Id);
        testSummary.Form__c = testForm.Id;
        testSummary.Account__c = testOpp.AccountId;
        insert testSummary;

        List<API_Information__c> apiInformationList = new List<API_Information__c>();
        List<ConsumptionSchedule> consumptionScheduleList = new List<ConsumptionSchedule>();
        List<API_Field_Mapping__c> apiFieldMappingList = new List<API_Field_Mapping__c>();

        Integer totalCount = 2;

        for (Integer i = 0; i < totalCount; i++) {
            API_Information__c apiInfo = IPUE_TestUtils.createApiInformation(false, 'Test Integration ' + i, 'www.test.com', 'Bearer Token', '1234abcd', '', null);
            apiInformationList.add(apiInfo);
        }

        insert apiInformationList;

        for (Integer i = 0; i < apiInformationList.size(); i++) {
            ConsumptionSchedule consumptionSchedule = IPUE_TestUtils.createConsumptionSchedule(false, 'Calculated Schedule ' + i, null);
            consumptionSchedule.Data_Type__c = 'Calculated';
            consumptionSchedule.Active__c = true;
            consumptionSchedule.Page_Section__c = pageSection.Id;
            consumptionSchedule.Sequence__c = i + 1;
            consumptionSchedule.Consumption_Description__c = 'Test';            
            consumptionScheduleList.add(consumptionSchedule);
            insert consumptionSchedule; // Consumption Schedule "Matching Attribute" or "Unit of Measure" can't be updated in bulk (these fields are set in the trigger)
        }

        for (Integer i = 0; i < apiInformationList.size(); i++) {
            API_Field_Mapping__c fieldMapping = IPUE_TestUtils.createFieldMapping(false, 'test-name-' + i, 'data.test' + i, apiInformationList[i].Id, null);
            fieldMapping.API_Field_Type__c = 'Request';
            fieldMapping.Estimation_Schedule__c = consumptionScheduleList[i].Id;
            fieldMapping.Form__c = testForm.Id;     
            apiFieldMappingList.add(fieldMapping);
        }

        insert apiFieldMappingList;

        IPUE_EstimationModelHelper.createEstimationModel(testSummary);

        List<Estimation_Output__c> outputs = [
            SELECT Id 
            FROM Estimation_Output__c 
            WHERE Estimation_Schedule__r.Data_Type__c = 'Calculated'
        ];

        for (Estimation_Output__c output : outputs) {
            output.User_Value__c = '100';
        }

        update outputs;

    }
    
    @isTest
    private static void buildRequestTest(){

        Test.startTest();

        Estimation_Summary__c summary = [SELECT Id FROM Estimation_Summary__c LIMIT 1];
        Map<Id, String> jsonRequestMap = IPUE_IntegrationRequestBuilder.buildRequest(summary.Id);

        Test.stopTest();

    }


}



// for (Integer i = 0; i < totalCount; i++) {
//     API_Information__c apiInfo = IPUE_TestUtils.createApiInformation(false, 'Test Integration ' + i, 'www.test.com', 'Bearer Token', '1234abcd');
// }

// API_Information__c apiInfo1 = IPUE_TestUtils.createApiInformation(false, 'Test Integration', 'www.test.com', 'Bearer Token', '1234abcd');
// API_Information__c apiInfo2 = IPUE_TestUtils.createApiInformation(false, 'Test Integration 2', 'www.test2.com', 'Bearer Token', '1234abcd');

// List<API_Information__c> apiInformationList = new List<API_Information__c>();
// apiInformationList.add(apiInfo1);
// apiInformationList.add(apiInfo2);
// insert apiInformationList;

// apiInfo1 = apiInformationList[0];
// apiInfo2 = apiInformationList[1];

// ConsumptionSchedule calculatedSchedule1 = IPUE_TestUtils.createConsumptionSchedule(false, 'Calculated Schedule 1', null);
// calculatedSchedule1.Data_Type__c = 'Calculated';
// calculatedSchedule1.Active__c = true;
// calculatedSchedule1.Page_Section__c = pageSection.Id;
// calculatedSchedule1.Sequence__c = 1;
// calculatedSchedule1.Consumption_Description__c = 'Test';

// ConsumptionSchedule calculatedSchedule2 = IPUE_TestUtils.createConsumptionSchedule(false, 'Calculated Schedule 2', null);
// calculatedSchedule2.Data_Type__c = 'Calculated';
// calculatedSchedule2.Active__c = true;
// calculatedSchedule2.Page_Section__c = pageSection.Id;
// calculatedSchedule2.Sequence__c = 2;
// calculatedSchedule2.Consumption_Description__c = 'Test';

// List<ConsumptionSchedule> consumptionScheduleList = new List<ConsumptionSchedule>();
// consumptionScheduleList.add(calculatedSchedule1);
// consumptionScheduleList.add(calculatedSchedule2);
// insert consumptionScheduleList;

// calculatedSchedule1 = consumptionScheduleList[0];
// calculatedSchedule2 = consumptionScheduleList[1];

// API_Field_Mapping__c fieldMapping1 = IPUE_TestUtils.createFieldMapping(false, 'test-name-1', 'data.test1', apiInfo1.Id, null);
// fieldMapping1.API_Field_Type__c = 'Request';
// fieldMapping1.Estimation_Schedule__c = calculatedSchedule1.Id;
// fieldMapping1.Form__c = testForm.Id;

// API_Field_Mapping__c fieldMapping2 = IPUE_TestUtils.createFieldMapping(false, 'test-name-2', 'data.test2', apiInfo2.Id, null);
// fieldMapping2.API_Field_Type__c = 'Request';
// fieldMapping2.Estimation_Schedule__c = calculatedSchedule2.Id;
// fieldMapping2.Form__c = testForm.Id;

// List<API_Field_Mapping__c> apiFieldMappingList = new List<API_Field_Mapping__c>();
// apiFieldMappingList.add(fieldMapping1);
// apiFieldMappingList.add(fieldMapping2);
// insert apiFieldMappingList;

// fieldMapping1 = apiFieldMappingList[0];
// fieldMapping2 = apiFieldMappingList[1];

// IPUE_EstimationModelHelper.createEstimationModel(testSummary);

// List<Estimation_Output__c> outputs = [
//     SELECT Id 
//     FROM Estimation_Output__c 
//     WHERE Estimation_Schedule__r.Data_Type__c = 'Calculated'
// ];

// for (Estimation_Output__c output : outputs) {
//     output.User_Value__c = '100';
// }

// update outputs;