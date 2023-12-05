/*
Class:          OpportunityIPUServicesTriggerHandlerTest
@Author:        Nishant Bansal
@Created Date:  March 03 20213
@Description:  Test Class for OpportunityIPUServicesTriggerHandler
*/
/*
Change History
********************************************************************************************************************************************
ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
********************************************************************************************************************************************
*/
@isTest
public with sharing class OpportunityIPUServicesTriggerHandlerTest {
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
    private static void rollUpIPUsOnOpportunity(){
        
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
        
 
        Product2 testProd = [SELECT ID FROM Product2 LIMIT 1];
        Opportunity opp = [SELECT ID FROM Opportunity LIMIT 1];
        
        Opportunity_IPU_Services__c IPUServices = IPUE_TestUtils.createOppIPUServices(opp.Id, testProd.Id ,true);
        
        
        IPUServices.Required_IPUs__c = 50;
        update IPUServices;
        
        Test.StopTest();
        
        Opportunity updatedOpp = [SELECT Id, Cloud_Data_Governance_and_Catalog_DQ__c FROM Opportunity LIMIT 1];

        System.AssertEquals(50, updatedOpp.Cloud_Data_Governance_and_Catalog_DQ__c);

    }

}