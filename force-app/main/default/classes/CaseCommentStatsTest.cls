@isTest
public with sharing class CaseCommentStatsTest {
    @testSetup
    static void setupObjectTestData() {
        
        sObject sObj;
        sObject sObj1;
        
        String SupportAccount  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Support_Account').getRecordTypeId();
        String AskAnExpert  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Ask_An_Expert').getRecordTypeId();
        
        List<SendGrid_Templates__mdt> sendGridMetadata = [Select Id,Template_Id__c,DeveloperName from SendGrid_Templates__mdt];
        
        //create an TimeZone record
        sObj = new TimeZone__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mTimeZone);
        List<TimeZone__c> lTimezone = (List<TimeZone__c>) UtilityTest.makeInsert(new List<sObject>{sObj});   
        
        //create an Account record
        sObj = new Account();
        UtilityTestData.mAccountData.put('TimeZone__c',lTimezone[0].Id);
        sObj.put('RecordTypeId',SupportAccount);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Create Contact record
        RecordType rt = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='Customer_Contact' Limit 1];
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);//Email
        UtilityTestData.mContactData.put('Email','test@test.com');
        UtilityTestData.mContactData.put('pse__Salesforce_User__c',UserInfo.getUserId());
        UtilityTestData.mContactData.put('RecordTypeId',rt.Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        RecordType rt1 = [select id,Name from RecordType where SobjectType='Case' and DeveloperName='Technical' Limit 1];
                
        //create a Case record
        sObj = new Case();
        sObj.put('OwnerId', UserInfo.getUserId());
        sObj.put('Success_Offering__c', 'Basic Success');
        sObj.put('Priority', 'P1');
        sObj.put('Forecast_product__c', 'Active VOS');
        sObj.put('Version__c', '10.1');
        sObj.put('Component__c', 'Documentation');
        sObj.put('Case_Support_Add_On__c', 'XS');
        sObj.put('IR_Completion_Date__c', null); 
        sObj.put('ContactId', lContact[0].Id); 
        sObj.put('Status', 'Scheduled');
        sObj.put('CreatedDate', system.now());
        sObj.put('RecordTypeId',AskAnExpert);
        sObj.put('AccountId', lAccount[0].Id);
        sObj.put('Support_Account__c', lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
        List<Case> lCase = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Create a case Contact record
        sObj = new Case_Contact__c();        
       	sObj.put('Case__c', lCase[0].Id);
        sObj.put('Contact__c', lContact[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCaseContact);
        UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Create a case comment record
        sObj = new Case_Comment__c();
        sObj.put('Visibility__c', 'External');
        sObj.put('Email_Sent__c', false);
        sObj.put('Case__c', lCase[0].Id);
        sObj.put('Inbound__c', false);
        sObj.put('Importance__c', true);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCaseComment);
        UtilityTest.makeInsert(new List<sObject>{sObj});
    }
    @isTest
    static void getCaseCommetEmailDetailsTest(){        
        Test.startTest();
        Case_Comment__c cc=[SELECT Id FROM Case_Comment__c Limit 1];
        insert new CaseCommentEmailStat__c(Case_Comment__c=cc.Id,Delivery__c='Processed');
        CaseCommentStats.getCaseCommetEmailDetails(cc.Id);
        Test.stopTest();        
    }
}