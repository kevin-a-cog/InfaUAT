/*
Class:  DynamicLookupControllerTest
        @Author:        Anil Solanki
        @Created Date:  05/29/2018
        @Description:   Test Class for DynamicLookupController Class.
*/
@isTest
private class DynamicLookupControllerTest{
    
    @testSetup
    static void setupObjectTestData() {
        sObject sObj = new Account();
        sObject sObj1 = new Account();
        sObj = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        sObj = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname1');
        UtilityTestData.mContactData.put('LastName','LastName1');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        
        sObj1 = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname2');
        UtilityTestData.mContactData.put('LastName','LastName2');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mContactData);
        
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
    }
    
    static testMethod void testAddLOBContactsQuickAction() {
        User u1 = [SELECT id FROM User Where Profile.Name = 'System Administrator' AND IsActive = true Limit 1];
        List<Account> lAccount = [Select Id,Name from Account Limit 1];
        List<Contact> lContact = [Select Id,FirstName,LastName from Contact Limit 2];
        
        System.RunAs(u1) {
            
            String searchKeyword='Firstname1';
            String pillsList;
            String contactListJSON ;
            
            sObject sObj = new Account_LOB__c();
            UtilityTestData.mAccountLOB.put('Account__c',lAccount[0].id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountLOB);
            List<Account_LOB__c> lAccountLOB = (List<Account_LOB__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            String testFields = 'Id, Name'; 
            String oBJectTypeAccountLOB = 'Account_LOB__c';
            String roleSponser = 'Sponsor';
            pillsList = JSON.serialize(lContact);
            
            String contactJSON= '[{"Name":"Test Contact","Email":"aaa@adadsa.com","Id": "'+ lContact[0].Id + '","Is_Selected__c":true}]';
            String roleJSON= '{"'+ lContact[0].Id+'":"Sponsor"}';
            
            sObj = new Success_Contact__c();
            UtilityTestData.mLOBContact.put('Contact__c',lContact[1].id);
            UtilityTestData.mLOBContact.put('Line_of_Business__c',lAccountLOB[0].id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLOBContact);
            List<Success_Contact__c> lLOBContact = (List<Success_Contact__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            List<Success_Contact__c> lobContact = new List<Success_Contact__c>();
            List<DynamicLookupController.FieldSetMember> fsml = new List<DynamicLookupController.FieldSetMember>();
            
            test.StartTest();
                DynamicLookupController.getObjectType(lAccountLOB[0].Id);
                fsml = DynamicLookupController.getFields(lAccountLOB[0].Id); 
                System.assertEquals('Name', fsml[0].fieldPath); 
                DynamicLookupController.contactSearchBar(searchKeyWord,pillsList,testFields ,lAccountLOB[0].Id, oBJectTypeAccountLOB);
                DynamicLookupController.saveSelectedLOBContacts(contactJSON,lAccountLOB[0].Id,roleJSON,oBJectTypeAccountLOB);
                DynamicLookupController.getRoleSelect();
                lobContact = [Select Id,Name from Success_Contact__c where Line_of_Business__c =:lAccountLOB[0].Id ];
                system.assertEquals(lobContact.size(),2);
            test.stopTest();
        }
    }
}