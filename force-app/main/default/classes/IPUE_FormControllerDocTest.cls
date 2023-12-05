@isTest
public with sharing class IPUE_FormControllerDocTest {
    @TestSetup
    static void setup(){

        // Setup Common DAta
        IPUE_TestUtils.setupAllData();
        IPUE_TestUtils.setupFormData();

        // Create Estimation Summary for Form
        Opportunity testOpp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        Estimation_Summary__c testSummary = IPUE_TestUtils.createEstimationSummary(false, testOpp.Id);
        Form__c testForm = [SELECT Id FROM Form__c LIMIT 1];
        testSummary.Form__c = testForm.Id;
        testSummary.Account__c = testOpp.AccountId;
        insert testSummary;

        // Setup Integration Data
        API_Information__c apiInfo = IPUE_TestUtils.createApiInformation(true, 'Test Integration ', 'www.test.com', 'Bearer Token', '1234abcd', '', null);
        ConsumptionSchedule consumptionSchedule = [SELECT Id FROM ConsumptionSchedule WHERE Data_Type__c = 'Calculated' LIMIT 1];

        API_Field_Mapping__c fieldMapping = IPUE_TestUtils.createFieldMapping(false, 'test-name', 'data.test', apiInfo.Id, null);
        fieldMapping.API_Field_Type__c = 'Request';
        fieldMapping.Estimation_Schedule__c = consumptionSchedule.Id;
        fieldMapping.Form__c = testForm.Id;     
        insert fieldMapping;        

        List<Page_Section__c> pageSections = [SELECT Id FROM Page_Section__c];
        Lightning_Service_Template__c template = IPUE_TestUtils.createServiceTemplate(true, 'Test Template', '$' + fieldMapping.Name, pageSections[0].Id);

        // Create Tables
        ConsumptionSchedule fixedTable = IPUE_TestUtils.createTable(true, pageSections[0].Id, IPUE_CONSTANTS.TABLE_FIXED);
        IPUE_TestUtils.createSchedulesAndTableCells(fixedTable.Id, pageSections[0].Id, 3, 3, 'Fixed_');

        ConsumptionSchedule elasticTable = IPUE_TestUtils.createTable(true, pageSections[0].Id, IPUE_CONSTANTS.TABLE_ELASTIC);
        IPUE_TestUtils.createSchedulesAndTableCells(elasticTable.Id, pageSections[0].Id, 2, 3, 'Elastic_');

    }
    
    @isTest
    private static void fetchDocFormDataTest(){

        Test.startTest();

        /**
         * Test #1: Test Form Data is created
         */
        Estimation_Summary__c summary = [SELECT Id FROM Estimation_Summary__c LIMIT 1];
        IPUE_FormControllerDocModels.DataWrapper wrapper = IPUE_FormControllerDoc.fetchDocFormData(summary.Id);
        System.assert(wrapper != null, 'DataWrapper not created as expected');
        //System.assert(wrapper.form.pages != null, 'DataWrapper Pages not created as expected');

        /**
         * Test #2: Test Exception Path
         */
        Boolean exceptionThrown = false;

        try {
            // Throw exception by not passing in Estimation Summary Id
            wrapper = IPUE_FormControllerDoc.fetchDocFormData(null);
        } catch (Exception ex) {
            exceptionThrown = true;
        }

        System.assert(exceptionThrown, 'Exception not thrown as expected in fetchFormData()');
        
        Test.stopTest();

    }
/*
        @isTest
    private static void processInputTest(){

        Test.startTest();

        Estimation_Summary__c summary = [SELECT Id, Form__c FROM Estimation_Summary__c LIMIT 1];
        String jsonPayload = IPUE_TestUtils.setupEstimationSchedulePayload(summary);
        IPUE_FormController.processInput(jsonPayload, summary.Form__c, summary.Id);

        Test.stopTest();

    }

    @isTest
    private static void callIntegrationsTest(){

        Test.startTest();

        Estimation_Summary__c summary = [SELECT Id, Form__c FROM Estimation_Summary__c LIMIT 1];
        List<Page_Section__c> pageSectionList = [SELECT Id FROM Page_Section__c WHERE Parent_Page__r.Parent_Form__c = :summary.Form__c];
        List<Id> pageSectionIds = new List<Id>();

        for (Page_Section__c section : pageSectionList) {
            pageSectionIds.add(section.Id);
        }

        String jsonPayload = IPUE_TestUtils.setupEstimationSchedulePayload(summary);
        Map<Id,IPUE_FormControllerModels.LightningServiceTemplate> resultMap = IPUE_FormController.callIntegrations(summary.Id, summary.Form__c, pageSectionIds);

        Test.stopTest();

    }
  @isTest
    private static void testIPUEConstants(){
        IPUE_CONSTANTS ipueConstants = new IPUE_CONSTANTS();
        String constantValue = IPUE_CONSTANTS.ESTIMATION_SCHEDULE_DEV_NAME;
        constantValue = IPUE_CONSTANTS.DEFAULT_KEY;
        constantValue = IPUE_CONSTANTS.ROW_KEY;
        constantValue = IPUE_CONSTANTS.COLUMN_KEY;
    } */  
}