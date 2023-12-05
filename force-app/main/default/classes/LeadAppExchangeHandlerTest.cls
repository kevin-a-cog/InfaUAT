/*
Class:          leadAppExchangeHandlerTest
@Author:        Sumitkumar Mittal
@Created Date:  04/25/2018
@Description:   test class for leadAppExchangeHandler
Change History
******************************************************************
ModifiedBy          Date        Requested By        Description                 Tag

******************************************************************
*/

@isTest
private class LeadAppExchangeHandlerTest {
    
    private Final Static String vEmployee = Label.Profile_Employee;
    
    @testSetup
    static void setupObjectTestData() {
        
        //Insert Marketo custom settting data for integration testing
        AppExchange_Config__c settings = new AppExchange_Config__c(
            name = 'appexchange test settings',
            Marketo_REST_Endpoint__c = 'https://munckinId.mktorest.com/rest',
            Marketo_Identity_Endpoint__c = 'https://munckinId.mktorest.com/identity',
            Marketo_REST_Client_Id__c = 'string',
            Marketo_REST_Client_Secret__c = 'string',
            Marketo_AppExchange_Smart_Campaign_Id__c = '0'
        );
        insert settings;
        
        //DMLOption setup
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        
        //Lead object data
        sObject sObj = new Lead();
        // Call methos and pass sObject and data maps
        // This utility method will populate all the fields data according to the Map passed
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLeadData);         
        
        //Creating a Lead 2
        UtilityTestData.mLeadData.put('FirstName', 'DuplicateLeadFirst');
        UtilityTestData.mLeadData.put('LastName', 'DuplicateLeadLast');
        UtilityTestData.mLeadData.put('Email', 'testemailforleadExtra@infa.com');
        sObject sObj1 = new Lead();
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mLeadData);
        List<Lead> lLead = (List<Lead>) UtilityTest.makeInsertDMLOptions(new List<sObject>{sObj, sObj1}, dml);
        
    }//END static void setupTestData()
    
    
    
    /*
Below methods are covering the class ContactTriggerHandler
*/
    @isTest
    static void myUnitTest_remoteSyncAppExchangeLeads() {
        List<Lead> lLead = (List<Lead>) UtilityTest.executeQuery('Select Id from Lead limit 2');
        system.assertEquals(lLead.size(), 2);
        
        list<id> lLeadIds = new list<id>();
        for(lead l : lLead) lLeadIds.add(l.id);
        
        Test.setCurrentPage(Page.leadAppExchangeListButton);
        leadAppExchangeHandler controller = new leadAppExchangeHandler(new ApexPages.StandardSetController(lLead));
        
        Test.StartTest();        
        Test.setMock(HttpCalloutMock.class, new marketoTest());        
        leadAppExchangeHandler.syncResult syncResult = leadAppExchangeHandler.remoteSyncAppExchangeLeads(lLeadIds);        
        Test.StopTest();
        
        //assert the result sent back shows success
        system.assertEquals(true, syncResult.success);
    }
    
    
    /*
Below methods are covering the class ContactTriggerHandler
*/
    @isTest
    static void myUnitTest_processAppExchangeLeadTest() {
        
        List<Lead> lLead = (List<Lead>) UtilityTest.executeQuery('Select Id from Lead limit 2');
        system.assertEquals(lLead.size(), 2);
        
        list<id> lLeadIds = new list<id>();
        for(lead l : lLead) lLeadIds.add(l.id);
        
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new marketoTest());        
        leadAppExchangeHandler.processAppExchangeLead(lLeadIds);        
        Test.stopTest();
        //assert the result sent back shows success
    }
    
}