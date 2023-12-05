/**
 * Name         : IPUE_FileUploadControllerTest
 * Author       : Stephanie Viereckl | ATG, Cognizant | stephanie.viereckl@atginfo.com
 * Created Date : July 21, 2021
 * Description  : This test class covers IPUE_FileUploadController
 * 
 * Change History
 *************************************************************************************
 * ModifiedBy               Date            JIRA No.    Description             Tag
 *************************************************************************************
 * Stephanie Viereckl       07-21-2021      IPUE-9      Initial create
 */

@IsTest
public with sharing class IPUE_FileUploadControllerTest {

    @TestSetup
    static void setup(){
        IPUE_TestUtils.setupAllData();
    }

    @isTest 
    private static void fetchOppDataTest(){

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        IPUE_FIleUploadController.FileDataModel testModel;
        testModel = IPUE_FileUploadController.fetchData(opp.Id);
        System.AssertNotEquals(testModel, null);

    }

    @isTest
    private static void processFilesTest(){

        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        Id recordId = testOpp.Id;

        Estimation_Summary__c summaryToInsert = IPUE_TestUtils.createEstimationSummary(false, null);

        List<Estimation_Summary_Line__c> summaryLinesToInsert = new List<Estimation_Summary_line__c>();

        Estimation_Summary_Line__c summaryLine1 = IPUE_TestUtils.createEstimationSummaryLine(false, null, null);
        Estimation_Summary_Line__c summaryLine2 = IPUE_TestUtils.createEstimationSummaryLine(false, null, null);
        summaryLinesToInsert.add(summaryLine1);
        summaryLinesToInsert.add(summaryLine2);


        Test.startTest();
        Id returnedSummaryId = IPUE_FileUploadController.processFile(recordId, summaryToInsert, summaryLinesToInsert,'Test Excel Data', 'fileName');
        Test.stopTest();

        Estimation_Summary__c insertedSummary = [SELECT Id, (SELECT Id FROM Estimation_Summary_Lines__r) FROM Estimation_Summary__c WHERE Id = :returnedSummaryId LIMIT 1];
        
        System.AssertNotEquals(insertedSummary.Id, null);
        System.AssertEquals(insertedSummary.Estimation_Summary_Lines__r.isEmpty(),false);
    }
    
    @isTest
    private static void handleErrorsTest(){

        List<Exceptions_Log__c> returnedLogs = IPUE_FileUploadController.handleErrors('errorCauseString','messageAndStackTraceString');

        System.AssertNotEquals(returnedLogs.isEmpty(),true);

    }

}