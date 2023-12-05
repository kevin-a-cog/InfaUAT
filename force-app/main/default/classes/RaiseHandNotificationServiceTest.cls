/*
    @created by       : balajip
    @created on       : 10/01/2021
    @Purpose          : Test class for RaiseHandService
    @Testclass        : 
    @JIRA             : 
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************

 */
@isTest
public with sharing class RaiseHandNotificationServiceTest {
    
    @testSetup
    static void setupObjectTestData() {
        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        Id technicalCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
        
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
        UtilityTestData.mAccountData.put('Active__c', 'true');
        UtilityTestData.mAccountData.put('End_Date__c', System.today()+100+'');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewSupportAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //create an Engagement record
        sObj = new Engagement__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEngagementEscalation);
        UtilityTest.makeInsert(new List<sObject>{sObj});

        //create a Case record
        sObj = new Case();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
        sObj.put('OwnerId', UserInfo.getUserId());
        sObj.put('Priority', 'P2');
        sObj.put('Support_Account__c', lNewSupportAccount[0].Id);
        List<Case> lstCase = UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Notification_Criteria__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mNotificationCriteria);
        sObj.put('Object__c', 'Raise_Hand__c');
        sObj.put('Condition__c', 'Type__c == \'Co-own\'');
        sObj.put('Evaluation_Trigger__c', 'Create/Edit');
        sObj.put('Notification_Type__c', 'Salesforce Bell - Desktop;Microsoft Teams Private message');
        sObj.put('Template_Name__c', 'Dummy');
        List<Notification_Criteria__c> lstNotifCriteria = (List<Notification_Criteria__c>)UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Notification_Criteria_Detail__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mNotificationCriteriaDetail);
        sObj.put('Field_Name__c', 'Status');
        sObj.put('Field_API_Name__c', 'Type__c');
        sObj.put('Operator__c', 'equals');
        sObj.put('Value__c', 'Completed');
        sObj.put('Notification_Criteria__c', lstNotifCriteria[0].Id);
        List<Notification_Criteria_Detail__c> lstNotifCriteriaDetail = (List<Notification_Criteria_Detail__c>)UtilityTest.makeInsert(new List<sObject>{sObj});

        sObj = new Notification_User__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mNotificationUser);
        sObj.put('Notification_Criteria__c', lstNotifCriteria[0].Id);
        sObj.put('User__c', UserInfo.getUserId()+'');
        List<Notification_User__c> lNotiUsers = (List<Notification_User__c>)UtilityTest.makeInsert(new List<sObject>{sObj});
    
    
        Raise_Hand__c raiseHandGetHelp = new Raise_Hand__c();
        raiseHandGetHelp.Case__c = lstCase.get(0).Id;
        raiseHandGetHelp.Status__c = RaiseHandService.STATUS_OPEN;
        raiseHandGetHelp.Type__c = RaiseHandService.TYPE_GET_HELP;
        //raiseHand.Subtype__c = subtype;
        raiseHandGetHelp.Skill__c = 'PowerCenter - PS';
        raiseHandGetHelp.Question__c = 'This is the question';
        insert raiseHandGetHelp;
    }
    
    @isTest
    static void testAllMethods(){
        Raise_Hand__c raiseHand = [Select Id From Raise_Hand__c Limit 1];

        Test.startTest();
        raiseHand.Type__c = 'Co-own';
        update raiseHand;
        Test.stopTest();
    }
}