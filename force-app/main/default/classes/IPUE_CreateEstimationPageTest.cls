@isTest
public with sharing class IPUE_CreateEstimationPageTest {
    @TestSetup
    static void setup(){
        IPUE_TestUtils.setupAllData();
        IPUE_TestUtils.setupFormData();
    }

    @isTest
    private static void getAccountTest(){
        Account testAccount = [SELECT Id, Name FROM Account LIMIT 1];

        Test.StartTest();
        IPUE_CreateEstimationPageController.EstimationDataModel returnedModel = IPUE_CreateEstimationPageController.getExistingData(testAccount.Id);
        Test.StopTest();

        System.assertNotEquals(null, returnedModel);
    }

    @isTest
    private static void getOpportunity(){
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.StartTest();
        IPUE_CreateEstimationPageController.EstimationDataModel returnedModel = IPUE_CreateEstimationPageController.getExistingData(testOpp.Id);
        Test.StopTest();

        System.assertNotEquals(null, returnedModel);
    }

    @isTest
    private static void getQuote(){
        SBQQ__Quote__c testQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];

        Test.StartTest();
        IPUE_CreateEstimationPageController.EstimationDataModel returnedModel = IPUE_CreateEstimationPageController.getExistingData(testQuote.Id);
        Test.StopTest();

        System.assertNotEquals(null, returnedModel);
    }

    @isTest
    private static void getSummary(){
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        Estimation_Summary__c testSummary = IPUE_TestUtils.createEstimationSummary(true, testOpp.Id);

        Test.StartTest();
        IPUE_CreateEstimationPageController.EstimationDataModel returnedModel = IPUE_CreateEstimationPageController.getExistingData(testSummary.Id);
        Test.StopTest();

        System.assertNotEquals(null, returnedModel);
    }

    @isTest
    private static void testFormIdTrue(){
        Form__c testForm = [SELECT Id FROM Form__c LIMIT 1];
        Boolean formBool = IPUE_CreateEstimationPageController.checkForValidForm(testForm.Id);

        System.AssertEquals(formBool,true);
    }

    @isTest
    private static void testFormIdFalse(){
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        Boolean formBool = IPUE_CreateEstimationPageController.checkForValidForm(testOpp.Id);

        System.AssertEquals(formBool,false);
    }

    @isTest
    private static void testCreateEstimationModel(){
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        Estimation_Summary__c testSummary = IPUE_TestUtils.createEstimationSummary(false, testOpp.Id);

        Form__c testForm = [SELECT Id FROM Form__c LIMIT 1];

        testSummary.Form__c = testForm.Id;

        insert testSummary;

        Test.startTest();
        IPUE_CreateEstimationPageController.createEstimationModel(testSummary.Id, null,true);
        Test.stopTest();
    }
}