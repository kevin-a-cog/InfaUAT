/*
@created by       : Pavithra V
@created on       : 11/20/2020
@Purpose          : Test class for psa_us_ContactTriggerHelper
@description	  :
Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
@isTest(seeAllData=false)
public class psa_us_ContactTriggerHelperTest {
 	/**
     * @description - create test data
     */
    @testSetup
    static void setupObjectTestData() {
        
        Sobject sObj;
        Sobject sObj1;
        Sobject sObj2;
        
        sObj = new Account();
        UtilityTestData.mAccountData.put('Name','Test Account');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new pse__Region__c();
        UtilityTestData.mRegion.put('Name','Test Region-1');
        UtilityTestData.mRegion.put('psa_pm_Territory_ID_Mapping__c','1023423');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRegion);
        
        sObj1 = new pse__Region__c();
        UtilityTestData.mRegion.put('Name','Test Region-2');
        UtilityTestData.mRegion.put('psa_pm_Territory_ID_Mapping__c','1923423');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mRegion);
        List<pse__Region__c> lRegion = (List<pse__Region__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mContactData.put('pse__Resource_Role__c','Business Analyst');
        UtilityTestData.mContactData.put('pse__Region__c',lRegion[0].Id);
        UtilityTestData.mContactData.put('pse__Is_Resource__c','false');//pse__Salesforce_User__c
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        
        sObj1 = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mContactData.put('pse__Resource_Role__c','Project Manager');
        UtilityTestData.mContactData.put('pse__Region__c',null);
        UtilityTestData.mContactData.put('pse__Is_Resource__c','false');
        UtilityTestData.mContactData.put('pse__Is_Resource_Active__c','true');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mContactData);
        
        sObj2 = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mContactData.put('pse__Resource_Role__c','Architect');
        UtilityTestData.mContactData.put('pse__Region__c',lRegion[0].Id);
        UtilityTestData.mContactData.put('pse__Is_Resource__c','false');
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
        
        for(Contact con : lContact){
            con.pse__Is_Resource__c = true;
            //con.ReportsToId = con.Id;
        }
        update lContact;		
    }
    
    @isTest
    public static void handlePSEContactTest() {
        
        Test.startTest();
        
        List<pse__Region__c> lRegion = [SELECT Id,Name FROM pse__Region__c LIMIT 2];
        System.assert(lRegion.size()>0, 'Region not created');
        
        List<Contact> contactList = [SELECT Id,pse__Region__c,pse__Resource_Role__c,pse__Is_Resource__c,pse__Is_Resource_Active__c FROM Contact LIMIT 3];
        System.assert(contactList.size()>0, 'Contacts does not exist');
        
        contactList[0].ReportsToId = contactList[2].Id;
        contactList[0].pse__Region__c = lRegion[1].Id;
        contactList[0].pse__Resource_Role__c = 'Consultant';
        contactList[1].ReportsToId = contactList[0].Id;
        contactList[1].pse__Is_Resource__c = true;
        contactList[1].pse__Region__c = lRegion[1].Id;
        contactList[1].pse__Is_Resource_Active__c= false;
        contactList[2].pse__Region__c = null;
        
        update contactList;
        
        Test.stopTest();
    }

    //Method to test if the duplicate contacts are not created for Informatica LLC PSA Account
    @isTest
    static void avoidDuplicatePSContactTest(){
        Test.startTest();
        Account psaAccount = new Account(name = 'Informatica LLC PSA', BillingCountry = 'United States');
        insert psaAccount;
        Contact con = new Contact(firstname = 'Test Contact', lastname =  'PSA', email = 'test@psa.com', accountId = psaAccount.Id);
        insert con;
        Contact con1 = new Contact(firstname = 'Test Contact', lastname = 'PSA 123', email = 'test@psa.com', accountId = psaAccount.Id);
        try{
            insert con1;
        }
        catch(Exception e){
            Assert.isNotNull(e.getMessage(),'DML Exception occurred');
        }
        Test.stopTest();
    }
}