@isTest
public with sharing class EstimationSummaryLineTriggerTest {
    @TestSetup
    static void setup(){
        IPUE_TestUtils.setupAllData();
        IPUE_TestUtils.setupFormData();

        Opportunity testOpp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        Estimation_Summary__c testSummary = IPUE_TestUtils.createEstimationSummary(false, testOpp.Id);
        Form__c testForm = [SELECT Id FROM Form__c LIMIT 1];
        testSummary.Form__c = testForm.Id;
        testSummary.Account__c = testOpp.AccountId;
        insert testSummary;    
    }
    @isTest
    private static void testRollUpIPUValues(){
        
        Test.StartTest();
        Product2 nonProductionProd = IPUE_TestUtils.createProduct(false);
        nonProductionProd.ProductCode = EstimationSummaryLineTriggerHandler.NON_PRODUCTION_ORG_PRODUCTCODE;
        nonProductionProd.Name = 'Non-production Product';
        nonProductionProd.Offering_ID__c = 'uniqueId';
        nonProductionProd.Offering_Type__c = 'On-Premise Subscription';
        insert nonProductionProd;

        Estimation_Summary__c parentSummary = [SELECT Id FROM Estimation_Summary__c LIMIT 1];

        Estimation_Summary_Line__c newLine = new Estimation_Summary_Line__c();
        newLine.product__c = nonProductionProd.Id;
        newLine.Estimation_Summary__c = parentSummary.Id;
        newLine.Required_IPUs__c = 20;
        insert newLine;

        
        newLine.Required_IPUs__c = 30;
        update newLine;
        Test.StopTest();

        Estimation_Summary__c summary = [SELECT Id, Additional_Non_Production_IPUs__c FROM Estimation_Summary__c LIMIT 1];

        System.AssertEquals(30, summary.Additional_Non_Production_IPUs__c);
    }

}