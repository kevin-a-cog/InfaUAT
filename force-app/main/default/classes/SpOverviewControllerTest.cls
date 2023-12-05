@isTest
public with sharing class SpOverviewControllerTest {
    
     @testSetup
    static void setupObjectTestData() {
        
        //Account
        sObject Account = new Account();
        UtilityTestData.mAccountData.put('Signature_Success__c','TRUE');
        Account = UtilityTest.putFieldRecord(Account, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{Account});
        
        sObject Contact = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname');
        UtilityTestData.mContactData.put('LastName','Lname');
        UtilityTestData.mContactData.put('Email',userinfo.getUserEmail());
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        Contact = UtilityTest.putFieldRecord(Contact, UtilityTestData.mContactData); 
       
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{Contact});
        
        //Plan
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mPlan.put('Name','Test Plan');//
        UtilityTestData.mPlan.put('Sub_Stage__c','On-board');
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        
        sObject Plan2 = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mPlan.put('Name','Test Plan');//
        UtilityTestData.mPlan.put('Sub_Stage__c','Business Value');
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan2 = UtilityTest.putFieldRecord(Plan2, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan,Plan2}); 
        
        //Plan Contacts
        sObject PlanContact = new Plan_Contact__c();
        UtilityTestData.mPlanContact.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanContact.put('Contact__c',lContact[0].Id);
        UtilityTestData.mPlanContact.put('Contact_Type__c','Customer');
        UtilityTestData.mPlanContact.put('Role__c','Business Owner');
        
        PlanContact = UtilityTest.putFieldRecord(PlanContact, UtilityTestData.mPlanContact);
        List<Plan_Contact__c> lPlanContact = (List<Plan_Contact__c>) UtilityTest.makeInsert(new List<sObject>{PlanContact}); 
        
    }
    
    
    @isTest 
    public static void overviewdatatest(){
       Plan_Contact__c oPC = [Select Id,Name,Plan__c From Plan_Contact__c LIMIT 1];
        test.startTest(); 
        
        SpOverviewController.fetchOverViewData(oPC.Plan__c);
        test.stopTest(); 
        
    }
}