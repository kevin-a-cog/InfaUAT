/**
 * Name         : IPUE_FileAttachmentHelperTest
 * Author       : Stephanie Viereckl | ATG, Cognizant | stephanie.viereckl@atginfo.com
 * Created Date : July 12, 2021
 * Description  : This test class covers IPUE_FileAttachmentHelper
 * 
 * Change History
 *************************************************************************************
 * ModifiedBy               Date            JIRA No.    Description             Tag
 *************************************************************************************
 * Stephanie Viereckl       07-21-2021      IPUE-21     Initial create
 */
@isTest
public with sharing class IPUE_FileAttachmentHelperTest {

    @TestSetup
    static void setup(){
        IPUE_TestUtils.setupAllData();
    }

    /**
     * Test passing Opportunity record Id to create/update ContentVersion records
     */
    @isTest
    private static void testUploadFromOpportunity(){
		Test.startTest();
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        runCommonTests(testOpp.Id, 'Opportunity', 'TestFileName.xsls');
        Test.stopTest();
    }

    /**
     * Test passing Order record Id to create/update ContentVersion records
     */
    @isTest
    private static void testUploadFromOrder(){
		Test.startTest();
        Order testOrder = [SELECT Id FROM Order LIMIT 1];
        runCommonTests(testOrder.Id, 'Order', 'TestFileName.xsls');
		Test.stopTest();
    }

    /**
     * Test passing Account record Id to create/update ContentVersion records
     */
    @isTest
    private static void testUploadFromAccount(){
		Test.startTest();
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        runCommonTests(testAccount.Id, 'Account', 'TestFileName.xsls');
		Test.stopTest();
    }

    /**
     * Test passing Quote record Id to create/update ContentVersion records
     */
    @isTest
    private static void testUploadFromQuote(){

        SBQQ__Quote__c testQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        test.startTest();
        runCommonTests(testQuote.Id, 'CPQ Quote', 'TestFileName.xsls');
        test.stopTest();

    }

    /**
     * Test passing Quote record Id to create/update ContentVersion records
     */
    @isTest
    private static void testUploadFromQuoteNoRelatedOpp(){

        SBQQ__Quote__c testQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];

        testQuote.SBQQ__Opportunity2__c = null;
        update testQuote;
        
        String updatedFileName = 'New Test File Name.xsls';

        IPUE_FileAttachmentHelper.attachFile(testQuote.Id, 'Test Excel Data', updatedFileName);
        ContentDocument contentDocument = [SELECT Id, Title FROM ContentDocument WHERE Title = :updatedFileName LIMIT 1];
        System.assertEquals(updatedFileName, contentDocument.Title, 'When file was uploaded to Quote without an Opportunity, file name did not work as expected.');

    }


    /****************************** Helper Methods ******************************/

    private static void runCommonTests(Id recordId, String sObjectLabel, String fileName){

        /**
         * Test #1: Upload 1 File to applicable sObject record to ensure that a single ContentVersion and ContentDocumentLink was created
         */
        IPUE_FileAttachmentHelper.attachFile(recordId, 'Test Excel Data', fileName);

        List<ContentDocumentLink> contentDocLinks = queryContentDocumentLinks(recordId);
        System.assertEquals(1, contentDocLinks.size(), 'After uploading a single file to the ' + sObjectLabel + ' a single ContentDocumentLink record should exist.');

        Id contentDocumentId = contentDocLinks[0].ContentDocumentId;

        List<ContentDocument> contentDocs = queryContentDocuments(contentDocumentId);
        System.assertEquals(1, contentDocs[0].ContentVersions.size(), 'After uploading a single file to the ' + sObjectLabel + ', a single ContentVersion record should exist.');

        /**
         * Test #2: Upload a subsequent File to applicable sObject record to ensure that a new ContentVersion was created and associated with the existing ContentDocumentLink
         */
        IPUE_FileAttachmentHelper.attachFile(recordId, 'Test Second Excel Data', fileName);

        contentDocLinks = queryContentDocumentLinks(recordId);
        System.assertEquals(1, contentDocLinks.size(), 'After uploading a second file to the ' + sObjectLabel + ', there should still only be 1 ContentDocumentLink record.');

        contentDocs = queryContentDocuments(contentDocumentId);
        System.assertEquals(2, contentDocs[0].ContentVersions.size(), 'After uploading a second file to the ' + sObjectLabel + ', there should be 2 ContentVersion records created.');

    }

    private static List<ContentDocumentLink> queryContentDocumentLinks(Id relatedRecordId){
        return [
            SELECT Id, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :relatedRecordId
        ];
    }

    private static List<ContentDocument> queryContentDocuments(Id contentDocId){
        return [
            SELECT Id, Title,
            (
                SELECT Id, ContentDocumentId 
                FROM ContentVersions) 
            FROM ContentDocument 
            WHERE Id = :contentDocId
        ];
    }

}