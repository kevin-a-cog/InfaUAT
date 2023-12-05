@isTest
public with sharing class FillRequiredFieldsControllerTest {
    private Final Static String vEmployee = Label.Profile_Employee;
    private Final Static String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
    
    @testSetup
    static void setupObjectTestData() {    
        
        //Insert Account setup data
        sObject sObj = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Insert contact
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Inserting an Opportunity
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('StageName', 'Identify');
        UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
        UtilityTestData.mOpportunityData.put('Type', 'Upsell');    
        UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c', 'Primary');   
        UtilityTestData.mOpportunityData.put('CloseDate', System.Today() + '');     
        sObj = new Opportunity();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunityPrimary1 = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        System.assertEquals(lOpportunityPrimary1.size(), 1);
    } 
    @isTest
    static void testMethod1() {
        Test.StartTest();
        try{
            List<Opportunity> lOpportunityPrimary = (List<Opportunity>) UtilityTest.executeQuery('Select Id from Opportunity where Primary_or_Secondary__c =\'Primary\' Limit 1');
            system.assertEquals(lOpportunityPrimary.size(),1);
            FillRequiredFieldsController.saveData('Opportunity', 'Metrics__c', lOpportunityPrimary[0].Id, 'TEST METRICS');
            FillRequiredFieldsController.saveData('Opportunity', 'POC_Required__c', lOpportunityPrimary[0].Id, 'TEST METRICS');
        }catch (System.Exception e){
            
        }
        Test.Stoptest();
    }
}