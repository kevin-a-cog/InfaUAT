/*
Class:          LookupSearchResultTest 
@Author:        Ambica P
@Created Date:  5 Jan 2021  
@Description:   Test class for LookupSearchResult
****************************************************************************
MODIFIED BY      JIRA          DESCRIPTION                             TAG
****************************************************************************
*/


@istest
public class LookupSearchResultTest {
	  @isTest
        static void testMonitoring(){
             Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        
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
            
            LookupSearchResult lsr = new LookupSearchResult(lAccount[0].Id,'Account','test1','test2','test3');
                
            lsr.compareTo(lsr);
            lsr.getId();
            lsr.getIcon();
            lsr.getSubtitle();
            lsr.getTitle();
            lsr.getSObjectType();
        }
}