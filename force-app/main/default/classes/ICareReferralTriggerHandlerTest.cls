/*
    @created by       : balajip
    @created on       : 02/15/2020
    @Purpose          : Test class for ICareReferral Trigger and Handler
    @Testclass        : 
    @JIRA             : 
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************

 */
@isTest
public with sharing class ICareReferralTriggerHandlerTest {
    public ICareReferralTriggerHandlerTest() {

    }
    
    @testSetup
    static void setupObjectTestData() {

        Id supportAccountRecordTypeId;
        Id customerAccountRecordTypeId;
        Map<Id,RecordTypeInfo> recordTypeInfos = Schema.SObjectType.Account.getRecordTypeInfosById();
        for(Id recordTypeId :recordTypeInfos.keyset()){
            if(recordTypeInfos.get(recordTypeId).getDeveloperName().equalsIgnoreCase('Support_Account')){
                supportAccountRecordTypeId = recordTypeId;
            }else if(recordTypeInfos.get(recordTypeId).getDeveloperName().equalsIgnoreCase('Customer_Account')){
                customerAccountRecordTypeId = recordTypeId;
            }
        }

        //create an Account record
        sObject sObj = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        sObj.put('RecordTypeId', customerAccountRecordTypeId);
        
        sObject sObj2 = new Account();
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mAccountData);
        sObj2.put('RecordTypeId', supportAccountRecordTypeId);
        List<Account> lAccount = UtilityTest.makeInsert(new List<sObject>{sObj, sObj2});
        
        //create a Case record
        sObj = new Case();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
        sObj.put('AccountId', lAccount.get(0).Id);
        sObj.put('Support_Account__c', lAccount.get(1).Id);
        UtilityTest.makeInsert(new List<sObject>{sObj});
        
    }

    @isTest
    static void testAllMethods(){
        Case cse = [Select Id From Case Limit 1];
        Account acc = [Select Id From Account Where RecordType.DeveloperName = 'Support_Account'];

        Test.startTest();
            List<iCare_Referral__c> lstReferral = new List<iCare_Referral__c>();
            iCare_Referral__c referral = new iCare_Referral__c();
            referral.Subject__c = 'Test Referral';
            referral.Case__c = cse.Id;
            lstReferral.add(referral);

            referral = new iCare_Referral__c();
            referral.Subject__c = 'Test Referral 2';
            referral.Support_Account__c = acc.Id;
            lstReferral.add(referral);

            insert lstReferral;
            ICareReferralTriggerHandler.setDefaultValues(lstReferral);
        Test.stopTest();
    }
    
    @isTest
    static void testAllUpdateMethods(){
        Case cse = [Select Id From Case Limit 1];
        Account acc = [Select Id From Account Where RecordType.DeveloperName = 'Support_Account'];

        Test.startTest();
            List<iCare_Referral__c> lstReferral = new List<iCare_Referral__c>();
            iCare_Referral__c referral = new iCare_Referral__c();
            referral.Subject__c = 'Test Referral';
            referral.Case__c = cse.Id;
            lstReferral.add(referral);
            insert lstReferral;
            lstReferral[0].Status__c = 'Accepted';
            update lstReferral;
        Test.stopTest();
    }
}