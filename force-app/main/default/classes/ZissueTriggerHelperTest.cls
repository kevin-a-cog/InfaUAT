/*
Trigger:        ZIssueTriggerHelper
@Author:        Pavithra V
@Created Date:  15 March 2021
@Description:   Handles the trigger logic on the object ZIssue

Change History
****************************************************************************************************
ModifiedBy  Date        Jira No.    Tag     Description
****************************************************************************************************
balajip     07/05/2022  I2RT-6655   T01     uncommented code that seems was commented out by mistake
*/
@isTest
public class ZissueTriggerHelperTest {
    
    static Id syppAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId(); 
    static Id cusacc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId(); 
    static Id caseRt = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId(); 
    static Id contactRt = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer Contact').getRecordTypeId(); 
    @testSetup
    static void setupObjectTestData() {
        
        sObject sObj;
        sObject sObj2;
        
        //create an Account record
        sObj = new Account();
        UtilityTestData.mAccountData.put('RecordTypeId',cusacc);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj2 = new Account();
        UtilityTestData.mAccountData.put('RecordTypeId',syppAcc);
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mAccountData);
        List<Account> lAccount2 = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj2});
        
       sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mContactData.put('pse__Salesforce_User__c',UserInfo.getUserId());
        UtilityTestData.mContactData.put('RecordTypeId',contactRt);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        //create a Case record
        sObj = new Case();
        sObj.put('OwnerId', userInfo.getUserId());
        sObj.put('Success_Offering__c', 'Premium Success');
        sObj.put('ContactId', lContact[0].Id);
        sObj.put('AccountId', lAccount[0].Id);
        sObj.put('Support_Account__c', lAccount2[0].Id);
        sObj.put('Priority', 'P1');
        sObj.put('RecordTypeId',caseRt);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
        List<Case> lCase = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Create a zIssue record
        zsfjira__ZIssue__c zissue = new zsfjira__ZIssue__c();
        zissue.zsfjira__Project__c ='TEST_SF_Jira_Connect';
        zissue.zsfjira__IssueType__c ='Task';
        zissue.zsfjira__Summary__c ='TEST_Summary';
        zissue.zsfjira__Prioriy__c ='P2/Normal';
        zissue.zsfjira__Description__c ='TEST_Description';
        zissue.zsfjira__Assignee__c ='Automatic';
        zissue.zsfjira__IssueKey__c='123456';
        zissue.zsfjira__IssueId__c=123456;
        zissue.Name ='SFJC-0001';
        insert zissue;
        
        //Create a caseIssue record
        zsfjira__ZIssue_Case__c cissue = new zsfjira__ZIssue_Case__c();
        cissue.zsfjira__ZIssueId__c = zissue.Id;
        cissue.zsfjira__CaseId__c = lCase[0].id; 
       insert cissue;
    }
    
    @isTest
    static void testZIssueTriggerHelper(){
        Test.startTest();
        
        List<Case> lCase = [Select Id,Priority From Case Limit 1];
        List <zsfjira__ZIssue__c> lZIssue = [Select Id,zsfjira__Prioriy__c from zsfjira__ZIssue__c LIMIT 1];
        
        /** Update the fields to check the creation of chatter post **/
        lZIssue[0].zsfjira__Prioriy__c='P3/Minor'; //T01
        lZIssue[0].zsfjira__IssueKey__c='123456'; //T01
        update lZIssue[0]; //T01
        Test.stopTest();
        
    }
    @isTest
    static void notifyCaseTeamTest(){
        
       Test.startTest();
        Account acc = [Select Id from Account where Recordtypeid = :syppAcc Limit 1];
        Account acc2 = [Select Id from Account where Recordtypeid = :cusacc Limit 1];
        Contact con = [Select Id from Contact Limit 1];
        Case c = [Select Id from Case limit 1];
        sObject obj = new Case();
        obj.put('OwnerId', userInfo.getUserId());
        obj.put('Success_Offering__c', 'Premium Success');
        obj.put('ContactId', con.Id);
        obj.put('AccountId', acc.Id);
        obj.put('Support_Account__c', acc.Id);
        obj.put('Priority', 'P1');
        obj.put('RecordTypeId',caseRt);
        obj = UtilityTest.putFieldRecord(obj, UtilityTestData.mCasePowerCenter);
        List<Case> lCase = (List<Case>) UtilityTest.makeInsert(new List<sObject>{obj});
        List <zsfjira__ZIssue_Case__c> lZIssue = [Select Id,zsfjira__CaseId__c  from zsfjira__ZIssue_Case__c LIMIT 1];
        System.debug('asdasd'+lZIssue);               
        update lZIssue[0];
        Test.stopTest();
    }
    
    @isTest
    static void updatezissue(){
        
       Test.startTest();
         zsfjira__ZIssue__c zi = [select id from zsfjira__ZIssue__c limit 1];
        update zi;
        Test.stopTest();
    }
    
}