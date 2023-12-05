@isTest
public class CustomLookupLwcControllerTest {
    @testSetup
    static void setupObjectTestData() {
        
        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;
        
        SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
        UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecType);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Support Account');
        UtilityTestData.mAccountData.put('ParentId', lNewCustomerAccount[0].Id);
        UtilityTestData.mAccountData.put('RecordTypeId', SupportAccountRecType);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewSupportAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
    }
    
    
    static testmethod void customLookupTest(){        
        String SearchTerm ='Test';
        String Objectname = 'Account';
        String FilterVariable = 'RecordType.Name';
        String Filter = 'Support Account';
        
        List<sObject> lstAccounts = CustomLookupLwcController.search(SearchTerm,Objectname,Filter,FilterVariable);
        List<sObject> lstAccounts2 = CustomLookupLwcController.fetchLookupData(SearchTerm,Objectname);        
    }
      static testmethod void customLookupUserTest(){        
        String SearchTerm ='Test';
        String Objectname = 'User';
        String FilterVariable = 'Email';
        String Filter = 'email';
        List<sObject> userList = CustomLookupLwcController.fetchLookupData(SearchTerm,Objectname);        
    }
}