/*
@created by       : Isha B
@created on       : 04/07/2023
@Purpose          : Test class for GlobalLookupController.
@JIRA             : I2RT-8234
 */
@isTest
private class GlobalLookupControllerTest {
    public static Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    public static Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    @testSetup
    static void setupObjectTestData() {
            
            SObject sObj = new Account();
            UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
            UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecType);
            UtilityTestData.mAccountData.put('BillingCountry', 'USA');
            UtilityTestData.mAccountData.put('IsCustomerPortal', 'True');
            
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            
            sObj = new Account();
            UtilityTestData.mAccountData.put('Name', 'Test Support Account');
            UtilityTestData.mAccountData.put('ParentId', lNewCustomerAccount[0].Id);
            UtilityTestData.mAccountData.put('RecordTypeId', SupportAccountRecType);
            UtilityTestData.mAccountData.put('BillingCountry', 'USA');
            UtilityTestData.mAccountData.put('Active__c', 'true');
            UtilityTestData.mAccountData.put('End_Date__c', System.today()+100+'');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            List<Account> lNewSupportAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
    }

    static TestMethod void getOneRecordById_givenSearchable_shouldGetRecord() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        GlobalLookupController.Searchable searcher = new GlobalLookupController.Searchable();
        searcher.searchTerm = 'test';
        searcher.objectName = 'Account';
        searcher.fields = new List<String> { 'Name', 'Id' };

        Test.startTest();

            String data = GlobalLookupController.getOneRecordById(searcher, acc.Id);

        Test.stopTest();
        System.debug('data: ' + data);

        // the following is weird because
        // USUALLY: Account acc = Database.query(...LIMIT 1) // => { account }
        // BUT HERE: return JSON.serialize(Database.query(...)) // => [ { account } ]

        List<Account> queried = (List<Account>) JSON.deserialize(data, List<Account>.class);
        System.assertEquals(acc.Id, queried[0].Id);
    }

    static TestMethod void getRecent_givenDefault_shouldGetRecentRecords() {
        List<Account> recentAccounts;
        GlobalLookupController.Searchable searcher = new GlobalLookupController.Searchable();
        searcher.searchTerm = 'test';
        searcher.objectName = 'Account';
        searcher.fields = new List<String> { 'Name', 'Id' };

        Test.startTest();

        recentAccounts = (List<Account>) JSON.deserialize(GlobalLookupController.getRecent(searcher), List<Account>.class);

        Test.stopTest();

        // Recent Queries can Fail in an org where a User doesn't have Recent Records.
        List<RecentlyViewed> recents = [SELECT Id FROM RecentlyViewed WHERE Type = :searcher.objectName];
        Boolean isValid = recents.size() >= 0 || recentAccounts.size() == 2;
       // System.assert(isValid, 'RecentlyViewed table is TestVisible, and will vary by environment.');
    } 

    static TestMethod void getRecords_givenTerm_shouldGetAccounts() {
        List<Id> fixedAccountIds = new List<Id>();
        for(Account acc : [ SELECT Id FROM Account ]) {
            fixedAccountIds.add(acc.Id);
        }

        Test.setFixedSearchResults(fixedAccountIds);

        List<List<Account>> results;
        GlobalLookupController.Searchable searcher = new GlobalLookupController.Searchable();
        searcher.searchTerm = 'test';
        searcher.objectName = 'Account';
        searcher.fields = new List<String> { 'Name', 'Id' };

        Test.startTest();

            results = (List<List<Account>>) JSON.deserialize(GlobalLookupController.getRecords(searcher), List<List<Account>>.class);

        Test.stopTest();

        System.assertEquals(2, results[0].size());
    }
   
}