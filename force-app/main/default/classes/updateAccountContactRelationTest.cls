@istest
public  class updateAccountContactRelationTest {
    
    @testSetup
    static void setupObjectTestData() {
        sObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

        sObject sObj4 = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Customer Account1');
        sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mAccountData);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
        List<Account> lNewAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj4});
        
        sObject sObj2 = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mContactData.put('MailingCountry', 'USA');
        UtilityTestData.mContactData.put('Email', 'test@test2021.com');
        sObj2 = UtilityTest.putFieldRecord(sObj2 , UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj2});

        sObject sObj3 = new AccountContactRelation();
        UtilityTestData.mAccContactRelation.put('Access_Level__c','Read Only');
        UtilityTestData.mAccContactRelation.put('AccountId',lNewAccount[0].Id);
        UtilityTestData.mAccContactRelation.put('ContactId',lContact[0].Id);
        sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mAccContactRelation);
        List<AccountContactRelation> lACR = (List<AccountContactRelation>) UtilityTest.makeInsert(new List<sObject>{sObj3});
    }

    static testmethod void testUpdateACR(){
        List<Contact> lstCon = new List<Contact>();
        lstCon = [select Id,Email from Contact where email = 'test@test2021.com'];
  
        sObject sObj1 = (Contact) lstCon[0];
        UtilityTestData.mContactData.put('Email','test1@test2021.com');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mContactData);
        
        List<Contact> con1 = UtilityTest.makeUpdate(new list<sObject>{sObj1});

    }
    
    static testmethod void testsetContactUpdatedOnACR(){
        Contact c = [select id from contact limit 1];
        updateAccountContactRelation.setContactUpdatedOnACR(new List<Id>{c.Id});
    }
}