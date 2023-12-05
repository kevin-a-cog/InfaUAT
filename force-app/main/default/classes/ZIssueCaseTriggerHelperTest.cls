/*
Class:          ZIssueCaseTriggerHelperTest
@Author:        Venky K
@Created Date:  30-Sep-2021
@Description:   Test class for ZIssueCaseTriggerHelper class.  

Change History
****************************************************************************************************
ModifiedBy  Date        Jira No.    Tag     Description
****************************************************************************************************

*/

@isTest 
public class ZIssueCaseTriggerHelperTest {
    
    @testSetup
    static void setupObjectTestData() {
        
        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        Id technicalCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
        SObject sObj1;
        
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
        
        sObj = new Case();
        UtilityTestData.mCase.put('Subject', 'Test technical Case');
        UtilityTestData.mCase.put('origin', 'Web');
        UtilityTestData.mCase.put('RecordTypeId', technicalCaseRecType);
        UtilityTestData.mCase.put('AccountId', lNewCustomerAccount[0].Id);
        UtilityTestData.mCase.put('Support_Account__c', lNewSupportAccount[0].Id);
        UtilityTestData.mCase.put('Attention_Request__c', 'Callback');
        //UtilityTestData.mCase.put('Next_Action_Owner__c', 'Case Owner');
        UtilityTestData.mCase.put('Priority ', 'P1');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
        List<Case> cases = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        zsfjira__ZIssue__c zissue = new zsfjira__ZIssue__c();
        zissue.zsfjira__Description__c = 'test';
        zissue.zsfjira__IssueId__c = 1234;
        zissue.zsfjira__IssueKey__c = '1234';        
        insert zissue;
        try{
            zsfjira__ZIssue_Case__c zfc = new zsfjira__ZIssue_Case__c();
            zfc.zsfjira__CaseId__c = cases[0].Id;
            zfc.zsfjira__ZIssueId__c = zissue.Id;
            insert zfc;
        }catch (Exception e){
            system.debug('exception');
        }
    }
    
    public static testmethod void postOutageLog(){
        try{
            Case c = [select Id from case limit 1];
            zsfjira__ZIssue__c zissue = [Select Id from zsfjira__ZIssue__c limit 1];
            zsfjira__ZIssue_Case__c zfcase= [Select Id from zsfjira__ZIssue_Case__c limit 1];
            update zfcase;
                    
            Test.startTest();
                zsfjira__ZIssue_Case__c zfc = new zsfjira__ZIssue_Case__c();
                zfc.zsfjira__CaseId__c = c.Id;
                zfc.zsfjira__ZIssueId__c = zissue.Id;
                insert zfc;
                update zfc;
            Test.stopTest();
        }catch(Exception e){
            system.debug('exception');
        }
    }   
}