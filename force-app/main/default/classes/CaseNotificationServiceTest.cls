/*
Class:          CaseNotificationServiceTest 
@Author:        Venky K
@Created Date:  5 Oct 2021  
@Description:   Test class for CaseNotificationService
****************************************************************************
MODIFIED BY      JIRA          DESCRIPTION                             TAG
****************************************************************************
*/
@isTest
public class CaseNotificationServiceTest {
      
    @testSetup
    static void setupObjectTestData() {
	 Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        Id GCSAdminrectype = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('GCS Administration').getRecordTypeId();
        
        sObject sObj = new Account();
        UtilityTestData.mAccountData.put('RecordTypeId', SupportAccountRecType);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        
        sObject sObj1 = new Account();
        UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecType);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        UtilityTestData.mContactData.put('AccountId', lAccount[1].Id);
        sObj = new Contact(Email = 'testing1email@test.com');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        Engagement__c eng = new Engagement__c();
        eng.recordtypeid = GCSAdminrectype;
        eng.name = 'test';
        insert eng;
    }
    
    @isTest
    static void testmethodnotification(){
       CaseNotificationService cs = new CaseNotificationService();
        cs.getTitle();
        cs.getTextMsgBody();
        
           
    }
}