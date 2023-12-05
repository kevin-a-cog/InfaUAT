/*
 * Name         :   ApexUtilitySales
 * Created Date :   10/28/2022
 * Description  :   This is an Test class for ApexUtilitySales

 Change History
 *************************************************************************************************************
 Modified By            Date            Jira No.        Description                                     Tag
 *************************************************************************************************************
 Puneet          10/28/2022             SALESRT-14408       Account Predective Bucket Score         initial code
 */

@isTest
public class ApexUtilitySalesTest {
    
    private Final Static Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    private Final Static Id LeadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
    
    @testSetup
    static void setupObjectTestData() 
    {
        SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Account');
        UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecType);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');

        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccountList = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

        UtilityTestData.mContactData.put('AccountId',lAccountList[0].id);
        UtilityTestData.mContactData.put('Is_Primary__c','True');
        UtilityTestData.mContactData.put('MailingCountry','US');
        UtilityTestData.mContactData.put('LS_Person_Predictive_Score__c','68');
        sObj = new Contact();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);

        SObject sObj1 = new Contact();
        UtilityTestData.mContactData.put('LS_Person_Predictive_Score__c','90');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mContactData);

        List<Contact> contactList = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});

    }

    @isTest
    private static void calculateAccountPredectiveBucketTest(){
        Account acc = [SELECT Id FROM Account LIMIT 1];

        UtilityTestData.mLeadData.put('RecordTypeId',LeadRecTypeId);
        UtilityTestData.mLeadData.put('Informatica_Solution__c','Intelligent Big Data');
        UtilityTestData.mLeadData.put('Decision_Criteria_for_Customer__c','Test');
        UtilityTestData.mLeadData.put('Status','Received');
        UtilityTestData.mLeadData.put('Company','test');
        UtilityTestData.mLeadData.put('LastName ','test');
        UtilityTestData.mLeadData.put('Email','test@testr.q');
        UtilityTestData.mLeadData.put('Account__c',acc.Id);
        UtilityTestData.mLeadData.put('LS_Person_Predictive_Score__c','30');

        sObject lead = new Lead();
        lead = UtilityTest.putFieldRecord(lead, UtilityTestData.mLeadData);

        List<Lead> leadList = (List<lead>) UtilityTest.makeInsert(new List<sObject>{lead});

        Test.startTest();
            ApexUtilitySales.calculateAccountPredectiveBucket(new Set<Id>{acc.Id});
        Test.stopTest();

        Account finalAcc = [SELECT Id,LS_Account_Predictive_Bucket__c FROM Account where Id = :acc.Id];
        System.assertEquals(finalAcc.LS_Account_Predictive_Bucket__c,'B', 'calculateAccountPredectiveBucketTest failed');

    }

    @isTest
    private static void calculateAccountPredectiveBucketTest2(){
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
            ApexUtilitySales.calculateAccountPredectiveBucket(new Set<Id>{acc.Id});
        Test.stopTest();

        Account finalAcc = [SELECT Id,LS_Account_Predictive_Bucket__c FROM Account where Id = :acc.Id];
        System.assertEquals(finalAcc.LS_Account_Predictive_Bucket__c,'B', 'calculateAccountPredectiveBucketTest failed');
    }

    @isTest
    private static void calculateAccountPredectiveBucketTestDelete(){
        List<Contact> conList = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
            delete conList;

            undelete conList;
        Test.stopTest();
    }

    @isTest
    private static void calculateAccountPredectiveBucketTestLeadDelete(){
        Account acc = [SELECT Id FROM Account LIMIT 1];

        UtilityTestData.mLeadData.put('RecordTypeId',LeadRecTypeId);
        UtilityTestData.mLeadData.put('Informatica_Solution__c','Intelligent Big Data');
        UtilityTestData.mLeadData.put('Decision_Criteria_for_Customer__c','Test');
        UtilityTestData.mLeadData.put('Status','Received');
        UtilityTestData.mLeadData.put('Company','test');
        UtilityTestData.mLeadData.put('LastName ','test');
        UtilityTestData.mLeadData.put('Email','test@testr.q');
        UtilityTestData.mLeadData.put('Account__c',acc.Id);
        UtilityTestData.mLeadData.put('LS_Person_Predictive_Score__c','30');

        sObject lead = new Lead();
        lead = UtilityTest.putFieldRecord(lead, UtilityTestData.mLeadData);

        List<Lead> leadList = (List<lead>) UtilityTest.makeInsert(new List<sObject>{lead});

        Test.startTest();
            delete leadList;

            undelete leadList;
        Test.stopTest();

    }

}