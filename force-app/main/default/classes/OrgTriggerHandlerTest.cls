/*
Class:          OrgTriggerHandlerTest
@Author:        Sumitkumar Mittal
@Created Date:  05/01/2018
@Description:   test class for OrgTriggerHandler
Change History
******************************************************************
ModifiedBy          Date        Requested By        Description                 Tag

******************************************************************
*/

@isTest
private class OrgTriggerHandlerTest{
    
    @testSetup
    static void setupObjectTestData() {
        //Set up object data
        //Account object data
        sObject sObj = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        //Lead object data
        sObj = new Lead();
        // Call methos and pass sObject and data maps
        // This utility method will populate all the fields data according to the Map passed
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLeadData);         
        List<Lead> lLead = (List<Lead>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //DMLOption setup
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        
        
        // Set all the required fields and dynamic ids in Map : Contact 1
        UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
        sObj = new Contact();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        // Set all the required fields and dynamic ids in Map : Contact 2
        UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
        //Same email as of Lead
        UtilityTestData.mContactData.put('Email', 'testemailforlead@test.com'); 
        sObj = new Contact();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContactDuplicate = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        system.assertEquals(lContactDuplicate.Size(),1);
        
        //Insert data for the Org
        sObj = new Org__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrgData);
        List<Org__c> lOrg = (List<Org__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        system.assertEquals(lOrg.Size(),1);
        
        
        UtilityTestData.mOrgUserData.put('Org__c', lOrg[0].Id); 
        sObj = new Org_User__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrgUserData);
        UtilityTestData.mOrgUserData.put('Org__c', lOrg[0].Id); 
        UtilityTestData.mOrgUserData.put('Email__c', 'testOrgEmail1@test.com'); 
        Sobject sObj1 = new Org_User__c();
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOrgUserData);
        List<Org_User__c> lOrgUser = (List<Org_User__c>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1});
        system.assertEquals(lOrgUser.Size(),2);
        
        
    }//END static void setupTestData()
    
    
    /*
Below methods are covering the class ContactTriggerHandler
*/
    @isTest
    static void orgUserWithLeadUnitTest() {
        
        List<Lead> lLead = (List<Lead>) UtilityTest.executeQuery('Select Id, Email from Lead limit 1');
        List<Org__c> lOrg= (List<Org__c>) UtilityTest.executeQuery('Select Id from Org__c limit 1');
        System.assertEquals(lOrg.size(), 1);
        
        Test.StartTest();
        UtilityTestData.mOrgUserData.put('Org__c', lOrg[0].Id); 
        UtilityTestData.mOrgUserData.put('Email__c', lLead[0].Email);
        sObject sObj = new Org_User__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrgUserData);
        List<Org_User__c> lOrgUser = (List<Org_User__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        system.assertEquals(lOrgUser.Size(),1);
        Test.StopTest();
    }
    
    @isTest
    static void orgUserWithContactUnitTest() {
        
        List<Contact> lContact = (List<Contact>) UtilityTest.executeQuery('Select Id, Email from Contact where Email = \'testemailforlead@test.com\' limit 1');
        System.assertEquals(lContact.size(), 1);
        List<Org__c> lOrg= (List<Org__c>) UtilityTest.executeQuery('Select Id from Org__c limit 1');
        System.assertEquals(lOrg.size(), 1);
        
        Test.StartTest();
        UtilityTestData.mOrgUserData.put('Org__c', lOrg[0].Id); 
        UtilityTestData.mOrgUserData.put('Email__c', lContact[0].Email);
        sObject sObj = new Org_User__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrgUserData);
        List<Org_User__c> lOrgUser = (List<Org_User__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        system.assertEquals(lOrgUser.Size(),1);
        Test.StopTest();
    }
    
    @isTest
    static void orgUserUpdateUnitTest() {
        
        List<Org_User__c> lOrgUser= (List<Org_User__c>) UtilityTest.executeQuery('Select Id, Email__c from Org_User__c limit 1');
        System.assertEquals(lOrgUser.size(), 1);
        
        Test.StartTest();
        sObject sObj = new Org_User__c(Id = lOrgUser[0].Id, Email__c = 'testOrgUserEmail@test.com' );
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrgUserData);
        List<Org_User__c> lOrgUserUpdate = (List<Org_User__c>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        
        system.assertEquals(lOrgUser.Size(),1);
        Test.StopTest();
    }


    @isTest
    static void orgUserIgnoreInsertAndUpdate() {
        
        List<Contact> lContact = (List<Contact>) UtilityTest.executeQuery('Select Id, Email from Contact where Email = \'testemailforlead@test.com\' limit 1');
        System.assertEquals(lContact.size(), 1);
        List<Org__c> lOrg= (List<Org__c>) UtilityTest.executeQuery('Select Id from Org__c limit 1');
        System.assertEquals(lOrg.size(), 1);
        
        Test.StartTest();
        UtilityTestData.mOrgUserData.put('Org__c', lOrg[0].Id); 
        UtilityTestData.mOrgUserData.put('Email__c', lContact[0].Email);
        sObject sObj = new Org_User__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrgUserData);
        globalApexManager.avoidRecursion('OrgUserBeforeInsert');
        List<Org_User__c> lOrgUserInsert = (List<Org_User__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        system.assertEquals(lOrgUserInsert.Size(),1);
        
        sObj = new Org_User__c(Id = lOrgUserInsert[0].Id, Email__c = 'testOrgUserEmail@test.com' );
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrgUserData);
        globalApexManager.avoidRecursion('OrgUserBeforeUpdate');
        List<Org_User__c> lOrgUserUpdate = (List<Org_User__c>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        
        system.assertEquals(lOrgUserUpdate.Size(),1);

        Test.StopTest();
    }
    
    
    
}