/*
Class:          TestCaseMilestoneTimeCalc
@Author:        Aishwarya Badri
@Created Date:  15-Mar-2021
@Description:   Test class to BusinessDaysCalculation

Change History
*************************************************************************************************************************************
ModifiedBy               Date        Requested By        Description                                         Tag
*************************************************************************************************************************************
Pavithra V			28-09-2021 		                     Increase Code Coverage                               T01
*/
@isTest
public class TestCaseMilestoneTimeCalc {
    
 @testSetup
    static void setupObjectTestData() {
        //Customer Account
        sObject Account = new Account();
        Id devRecordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();        
        UtilityTestData.mAccountData.put('RecordTypeId',devRecordTypeId1);
        Account = UtilityTest.putFieldRecord(Account, UtilityTestData.mAccountData);
        List<Account> lcustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{Account});
        
        //Support Account
        sObject Account2 = new Account();
        Id devRecordTypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();        
        UtilityTestData.mAccountData.put('RecordTypeId',devRecordTypeId2);
        Account2 = UtilityTest.putFieldRecord(Account2, UtilityTestData.mAccountData);
        List<Account> lsupportAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{Account2});
        
        //Contact
        sObject Contactrec = new Contact();
        UtilityTestData.mContactData.put('AccountId', lcustomerAccount[0].Id);
        Contactrec = UtilityTest.putFieldRecord(Contactrec, UtilityTestData.mContactData);                   
        Map<String,User> userByRole = A2RTestFuel.getUserMapByRole(true);
        List<Contact> lContact = new List<Contact>();
        System.runAs(userByRole.get('Admin')){
            lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{Contactrec});
        }
        
        //Case
        sObject Caserec = new Case();
        UtilityTestData.mCase.put('AccountId',lsupportAccount[0].Id);
        UtilityTestData.mCase.put('ContactId',lContact[0].Id);  
        UtilityTestData.mCase.put('eOGR_in_Mins__c','20'); 
        Caserec = UtilityTest.putFieldRecord(Caserec, UtilityTestData.mCase);
        List<Case> lcase = (List<Case>) UtilityTest.makeInsert(new List<sObject>{Caserec});  
        
        //Case Contact
        sObject Casecon = new Case_Contact__c();
        UtilityTestData.mCaseContact.put('Case__c',lcase[0].Id);
        UtilityTestData.mCaseContact.put('Contact__c',lContact[0].Id);  
        UtilityTestData.mCaseContact.put('Email__c','test@infa.com');  
        Casecon = UtilityTest.putFieldRecord(Casecon, UtilityTestData.mCaseContact);
        System.debug('Casecon-rec before insert->'+Casecon);
        List<Case_Contact__c> lcasecon = (List<Case_Contact__c>) UtilityTest.makeInsert(new List<sObject>{Casecon});   
        System.debug('Casecon-rec after insert->'+lcasecon);
    }
    
     static testMethod void testManageCaseContacts(){
         
         Test.startTest();
         List<Case> c=[Select Id,CaseNumber,eOGR_in_Mins__c from case  limit 1];
         // Select an existing milestone type to test with
         MilestoneType[] mtLst = [SELECT Id, Name FROM MilestoneType LIMIT 1];      
         if(mtLst.size() == 0) { return; }
         MilestoneType mt = mtLst[0];
         
         CaseMilestoneTimeCalc cm=new CaseMilestoneTimeCalc();
         cm.calculateMilestoneTriggerTime(c[0].Id,mt.Id);   
         Test.stopTest();
     }
}