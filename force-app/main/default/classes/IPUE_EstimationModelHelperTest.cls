@isTest
public with sharing class IPUE_EstimationModelHelperTest {
    @TestSetup
    static void setup(){
        IPUE_TestUtils.setupAllData();
        IPUE_TestUtils.setupFormData();
    }
    
    @isTest
    private static void testCreateEstimationModel(){
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        Estimation_Summary__c testSummary = IPUE_TestUtils.createEstimationSummary(false, testOpp.Id);

        Form__c testForm = [SELECT Id FROM Form__c LIMIT 1];

        testSummary.Form__c = testForm.Id;

        insert testSummary;

        IPUE_EstimationModelHelper.createEstimationModel(testSummary);
    }

    @isTest
    private static void testCloneEstimationModel(){

        Test.startTest();

        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        Estimation_Summary__c testSummary = IPUE_TestUtils.createEstimationSummary(false, testOpp.Id);

        Form__c testForm = [SELECT Id FROM Form__c LIMIT 1];
        testSummary.Form__c = testForm.Id;
        insert testSummary;

        IPUE_EstimationModelHelper.createEstimationModel(testSummary);

        Estimation_Summary__c clonedSummary = IPUE_TestUtils.createEstimationSummary(false, testOpp.Id);
        clonedSummary.Form__c = testForm.Id;
        insert clonedSummary;

        IPUE_EstimationModelHelper.cloneEstimationModel(clonedSummary.Id, testSummary.Id,true);

        Test.stopTest();
    }
}