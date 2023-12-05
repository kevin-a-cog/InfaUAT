/**
 * Name         : IPUE_ProcessSummaryHelperTest
 * Author       : Colton Kloppel | ATG, Cognizant | Colton.Kloppel@atginfo.com
 * Created Date : July 28, 2021
 * Description  : This test class covers IPUE_ProcessSummaryHelperTest
 * 
 * Change History
 *************************************************************************************
 * ModifiedBy               Date            JIRA No.    Description             Tag
 *************************************************************************************
 * Colton Kloppel       07-28-2021      IPUE-25     Initial create
 */
@isTest
 public with sharing class IPUE_ProcessSummaryHelperTest {
    
    
    @TestSetup
    static void setup(){
        IPUE_TestUtils.setupAllData();
    }

    @isTest
    private static void testNewSummaryFromOpportunity(){
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        Id recordId = testOpp.Id;

        Estimation_Summary__c summaryToInsert = IPUE_TestUtils.createEstimationSummary(false, null);
        summaryToInsert.RecordTypeId = Schema.SObjectType.Estimation_Summary__c.getRecordTypeInfosByName().get('Manual Upload').getRecordTypeId();


        List<Estimation_Summary_Line__c> summaryLinesToInsert = new List<Estimation_Summary_line__c>();

        Estimation_Summary_Line__c summaryLine1 = IPUE_TestUtils.createEstimationSummaryLine(false, null, null);
        Estimation_Summary_Line__c summaryLine2 = IPUE_TestUtils.createEstimationSummaryLine(false, null, null);
        summaryLinesToInsert.add(summaryLine1);
        summaryLinesToInsert.add(summaryLine2);


        Test.startTest();
        IPUE_ProcessSummaryHelper.saveSummaryRecords(recordId, summaryToInsert, summaryLinesToInsert, 'fileName');
        Test.stopTest();

        Estimation_Summary__c insertedSummary = [SELECT Id, (SELECT Id FROM Estimation_Summary_Lines__r) FROM Estimation_Summary__c Limit 1];
        
        System.AssertNotEquals(insertedSummary.Id, null);
        System.AssertEquals(insertedSummary.Estimation_Summary_Lines__r.isEmpty(),false);
    }

    @isTest
    private static void testOverwriteSummaryFromOpportunity(){

        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        Id recordId = testOpp.Id;

        Estimation_Summary__c existingSummary = IPUE_TestUtils.createEstimationSummary(false, recordId);
        existingSummary.RecordTypeId = Schema.SObjectType.Estimation_Summary__c.getRecordTypeInfosByName().get('Manual Upload').getRecordTypeId();
        insert existingSummary;

        Estimation_Summary_Line__c summaryLine1 = IPUE_TestUtils.createEstimationSummaryLine(true, existingSummary.Id, null);
        Estimation_Summary_Line__c summaryLine2 = IPUE_TestUtils.createEstimationSummaryLine(true, existingSummary.Id, 'OVERWRITE123');
        Estimation_Summary_Line__c summaryLine3 = IPUE_TestUtils.createEstimationSummaryLine(true, existingSummary.Id, 'OBSOLETE');

        List<Estimation_Summary_Line__c> summaryLinesToUpsert = new List<Estimation_Summary_line__c>();

        Estimation_Summary__c summaryToInsert = IPUE_TestUtils.createEstimationSummary(false, null);
        summaryToInsert.RecordTypeId = Schema.SObjectType.Estimation_Summary__c.getRecordTypeInfosByName().get('Manual Upload').getRecordTypeId();

        Estimation_Summary_Line__c summaryLine4 = IPUE_TestUtils.createEstimationSummaryLine(false, null, summaryLine1.Service_Id__c);
        Estimation_Summary_Line__c summaryLine5 = IPUE_TestUtils.createEstimationSummaryLine(false, null, null);
        summaryLinesToUpsert.add(summaryLine4);
        summaryLinesToUpsert.add(summaryLine5);

        Test.startTest();
        IPUE_ProcessSummaryHelper.saveSummaryRecords(recordId, summaryToInsert, summaryLinesToUpsert, 'fileName');
        Test.stopTest();

        Estimation_Summary__c upsertedSummary = [SELECT Id, Opportunity__c, (SELECT Id FROM Estimation_Summary_Lines__r) FROM Estimation_Summary__c WHERE Opportunity__c = :recordId LIMIT 1];
        
        System.AssertNotEquals(upsertedSummary.Id, null);
        System.AssertEquals(upsertedSummary.Estimation_Summary_Lines__r.isEmpty(),false);
    }

    @isTest
    private static void testNewSummaryFromQuote(){

        SBQQ__Quote__c testQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        Id recordId = testQuote.Id;

        Estimation_Summary__c summaryToInsert = IPUE_TestUtils.createEstimationSummary(false, null);
        summaryToInsert.RecordTypeId = Schema.SObjectType.Estimation_Summary__c.getRecordTypeInfosByName().get('Manual Upload').getRecordTypeId();

        List<Estimation_Summary_Line__c> summaryLinesToInsert = new List<Estimation_Summary_line__c>();

        Estimation_Summary_Line__c summaryLine1 = IPUE_TestUtils.createEstimationSummaryLine(false, null, null);
        Estimation_Summary_Line__c summaryLine2 = IPUE_TestUtils.createEstimationSummaryLine(false, null, null);
        summaryLinesToInsert.add(summaryLine1);
        summaryLinesToInsert.add(summaryLine2);


        Test.startTest();
        IPUE_ProcessSummaryHelper.saveSummaryRecords(recordId, summaryToInsert, summaryLinesToInsert, 'fileName');
        Test.stopTest();

        Estimation_Summary__c insertedSummary = [SELECT Id, Quote__c, (SELECT Id FROM Estimation_Summary_Lines__r) FROM Estimation_Summary__c WHERE Quote__c = :recordId LIMIT 1];
        
        System.AssertNotEquals(insertedSummary.Id, null);
        System.AssertEquals(insertedSummary.Estimation_Summary_Lines__r.isEmpty(),false);

    }

    @isTest
    private static void testOverwriteSummaryFromQuote(){

        SBQQ__Quote__c testQuote = [SELECT Id,SBQQ__Opportunity2__c FROM SBQQ__Quote__c LIMIT 1];
        Id recordId = testQuote.Id;

        Estimation_Summary__c existingSummary = IPUE_TestUtils.createEstimationSummary(false, testQuote.SBQQ__Opportunity2__c);
        existingSummary.RecordTypeId = Schema.SObjectType.Estimation_Summary__c.getRecordTypeInfosByName().get('Manual Upload').getRecordTypeId();
        insert existingSummary;


        Estimation_Summary_Line__c summaryLine1 = IPUE_TestUtils.createEstimationSummaryLine(true, existingSummary.Id, null);
        Estimation_Summary_Line__c summaryLine2 = IPUE_TestUtils.createEstimationSummaryLine(true, existingSummary.Id, 'OVERWRITE123');
        Estimation_Summary_Line__c summaryLine3 = IPUE_TestUtils.createEstimationSummaryLine(true, existingSummary.Id, 'OBSOLETE');

        List<Estimation_Summary_Line__c> summaryLinesToUpsert = new List<Estimation_Summary_line__c>();

        Estimation_Summary__c summaryToInsert = IPUE_TestUtils.createEstimationSummary(false, null);
        summaryToInsert.RecordTypeId = Schema.SObjectType.Estimation_Summary__c.getRecordTypeInfosByName().get('Manual Upload').getRecordTypeId();

        Estimation_Summary_Line__c summaryLine4 = IPUE_TestUtils.createEstimationSummaryLine(false, null, summaryLine1.Service_Id__c);
        Estimation_Summary_Line__c summaryLine5 = IPUE_TestUtils.createEstimationSummaryLine(false, null, null);
        summaryLinesToUpsert.add(summaryLine4);
        summaryLinesToUpsert.add(summaryLine5);

        Test.startTest();
        IPUE_ProcessSummaryHelper.saveSummaryRecords(recordId, summaryToInsert, summaryLinesToUpsert, 'fileName');
        Test.stopTest();

        Estimation_Summary__c insertedSummary = [SELECT Id, Quote__c, (SELECT Id FROM Estimation_Summary_Lines__r) FROM Estimation_Summary__c WHERE Quote__c = :recordId LIMIT 1];
        
        System.AssertNotEquals(insertedSummary.Id, null);
        System.AssertEquals(insertedSummary.Estimation_Summary_Lines__r.isEmpty(),false);
    }

    @isTest
    private static void testNewSummaryFromOrder(){

        Order testOrder = [SELECT Id, OpportunityId FROM Order LIMIT 1];
        Id recordId = testOrder.Id;

        Estimation_Summary__c summaryToInsert = IPUE_TestUtils.createEstimationSummary(false, null);
        summaryToInsert.RecordTypeId = Schema.SObjectType.Estimation_Summary__c.getRecordTypeInfosByName().get('Manual Upload').getRecordTypeId();        

        List<Estimation_Summary_Line__c> summaryLinesToInsert = new List<Estimation_Summary_line__c>();

        Estimation_Summary_Line__c summaryLine1 = IPUE_TestUtils.createEstimationSummaryLine(false, null, null);
        Estimation_Summary_Line__c summaryLine2 = IPUE_TestUtils.createEstimationSummaryLine(false, null, null);
        summaryLinesToInsert.add(summaryLine1);
        summaryLinesToInsert.add(summaryLine2);


        Test.startTest();
        IPUE_ProcessSummaryHelper.saveSummaryRecords(recordId, summaryToInsert, summaryLinesToInsert, 'fileName');
        Test.stopTest();

        Estimation_Summary__c insertedSummary = [SELECT Id, Opportunity__c, (SELECT Id FROM Estimation_Summary_Lines__r) FROM Estimation_Summary__c WHERE Opportunity__c = :testOrder.OpportunityId LIMIT 1];
        
        System.AssertNotEquals(insertedSummary.Id, null);
        System.AssertEquals(insertedSummary.Estimation_Summary_Lines__r.isEmpty(),false);

    }

    @isTest
    private static void testOverwriteSummaryFromOrder(){

        Order testOrder = [SELECT Id, OpportunityId FROM Order LIMIT 1];
        Id recordId = testOrder.Id;

        Estimation_Summary__c existingSummary = IPUE_TestUtils.createEstimationSummary(false, testOrder.OpportunityId);
        existingSummary.RecordTypeId = Schema.SObjectType.Estimation_Summary__c.getRecordTypeInfosByName().get('Manual Upload').getRecordTypeId();
        insert existingSummary;
        
        Estimation_Summary_Line__c summaryLine1 = IPUE_TestUtils.createEstimationSummaryLine(true, existingSummary.Id, null);
        Estimation_Summary_Line__c summaryLine2 = IPUE_TestUtils.createEstimationSummaryLine(true, existingSummary.Id, 'OVERWRITE123');
        Estimation_Summary_Line__c summaryLine3 = IPUE_TestUtils.createEstimationSummaryLine(true, existingSummary.Id, 'OBSOLETE');

        List<Estimation_Summary_Line__c> summaryLinesToUpsert = new List<Estimation_Summary_line__c>();

        Estimation_Summary__c summaryToInsert = IPUE_TestUtils.createEstimationSummary(false, null);
        summaryToInsert.RecordTypeId = Schema.SObjectType.Estimation_Summary__c.getRecordTypeInfosByName().get('Manual Upload').getRecordTypeId();

        Estimation_Summary_Line__c summaryLine4 = IPUE_TestUtils.createEstimationSummaryLine(false, null, summaryLine1.Service_Id__c);
        Estimation_Summary_Line__c summaryLine5 = IPUE_TestUtils.createEstimationSummaryLine(false, null, null);
        summaryLinesToUpsert.add(summaryLine4);
        summaryLinesToUpsert.add(summaryLine5);

        Test.startTest();
        IPUE_ProcessSummaryHelper.saveSummaryRecords(recordId, summaryToInsert, summaryLinesToUpsert, 'fileName');
        Test.stopTest();

        Estimation_Summary__c insertedSummary = [SELECT Id, Opportunity__c, (SELECT Id FROM Estimation_Summary_Lines__r) FROM Estimation_Summary__c WHERE Opportunity__c = :testOrder.OpportunityId LIMIT 1];
        
        System.AssertNotEquals(insertedSummary.Id, null);
        System.AssertEquals(insertedSummary.Estimation_Summary_Lines__r.isEmpty(),false);
    }
}