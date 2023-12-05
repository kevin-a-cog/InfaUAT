/*  
@Author:        Anil Sahu  
@Created Date:  20may21
@Description:   Test class for LinkUtility_Controller controller.
*/
@istest
public class LinkUtility_ControllerTest {
    static testMethod void getQuicklinkInfo() {
        test.startTest();
         Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        
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
        UtilityTestData.mAccountData.put('Active__c', 'true');
        UtilityTestData.mAccountData.put('End_Date__c', System.today()+100+'');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewSupportAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lNewCustomerAccount[0].id);
        UtilityTestData.mContactData.put('FirstName','test Con FirstName1');
        UtilityTestData.mContactData.put('LastName','test Con LastName1');
        UtilityTestData.mContactData.put('Email',UserInfo.getUserEmail());
        UtilityTestData.mContactData.put('Phone','9517536548');
        UtilityTestData.mContactData.put('MailingCountry','India');
        UtilityTestData.mContactData.put('Is_Active__c','true');
        UtilityTestData.mContactData.put('View_All_Deal_Registrations__c','true');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> contacts = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new AccountContactRelation(); 
        UtilityTestData.mAccContactRelation.put('AccountId',lNewSupportAccount[0].id);
        UtilityTestData.mAccContactRelation.put('ContactId',contacts[0].id);
        UtilityTestData.mAccContactRelation.put('IsActive','true');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccContactRelation);
        List<AccountContactRelation> accContactRelation = (List<AccountContactRelation>) UtilityTest.makeInsert(new List<sObject>{sObj});
     
        sObj = new Link__c();
        UtilityTestData.mLinkData.put('Name','eSupport');
        UtilityTestData.mLinkData.put('Group_Name__c','eSupport');       
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLinkData);
        List<Link__c> Link = (List<Link__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
     
        LinkUtility_Controller objcls=new LinkUtility_Controller();
        LinkUtility_Controller.getQuicklinkInfo();
        Test.stopTest();
        
    }
}