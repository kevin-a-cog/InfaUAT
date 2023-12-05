/*
* Name			:	CSMPlanTriggerHelperTest
* Author		:	Pavithra V
* Created Date	: 	08/20/2021
* Description	:	Test Class for CSMPlanTriggerHelper

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					Tag
**********************************************************************************************************
*/
@isTest
public class CSMPlanContactTriggerTest {
    
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
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        Contact = UtilityTest.putFieldRecord(Contact, UtilityTestData.mContactData); 
        
        sObject Contact2 = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname');
        UtilityTestData.mContactData.put('LastName','LastName');
        UtilityTestData.mContactData.put('Email','test145@test.com');
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        Contact2 = UtilityTest.putFieldRecord(Contact2, UtilityTestData.mContactData); 
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{Contact, Contact2});

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
        UtilityTestData.mPlanContact.put('CST_Survey_Sent__c','true');
        PlanContact = UtilityTest.putFieldRecord(PlanContact, UtilityTestData.mPlanContact);
        List<Plan_Contact__c> lPlanContact = (List<Plan_Contact__c>) UtilityTest.makeInsert(new List<sObject>{PlanContact}); 

    }
   
    @isTest
    public static void checkPlanContactUpdate(){
        Plan__c plan =[SELECT Id,Sub_Stage__c,Onboarding_Survey_Sent__c,Account__c,Business_Outcome_Survey_Sent__c FROM Plan__c LIMIT 1];
        Plan_Contact__c lPlanContacts = [SELECT Id,Contact__c FROM Plan_Contact__c limit 1];
        Id con = lPlanContacts.Contact__c;
        Contact lContact = [Select Id from Contact where  id !=:con limit 1];
        
        lPlanContacts.Contact__c = lContact.Id;
        lPlanContacts.Onboarding_Survey_Sent__c = true;
        update lPlanContacts;
        
    }
    
      @isTest
    public static void checkPlanContactUpdate1(){
        Plan__c plan =[SELECT Id,Sub_Stage__c,Onboarding_Survey_Sent__c,Account__c,Business_Outcome_Survey_Sent__c FROM Plan__c LIMIT 1];
        Plan_Contact__c lPlanContacts = [SELECT Id,Contact__c FROM Plan_Contact__c limit 1];
        Id con = lPlanContacts.Contact__c;
        Contact lContact = [Select Id from Contact where  id !=:con limit 1];
        
        lPlanContacts.Contact__c = lContact.Id;
        lPlanContacts.Business_Outcome_Survey_Sent__c = true;
        update lPlanContacts;
        
    }
    
   
    @isTest
    public static void checkPlanContactunDelete(){
        Plan__c plan =[SELECT Id,Sub_Stage__c,Onboarding_Survey_Sent__c,Account__c,Business_Outcome_Survey_Sent__c FROM Plan__c LIMIT 1];
        List<Plan_Contact__c> lPlanContacts = [SELECT Id,Contact__c FROM Plan_Contact__c];
        List<Contact> lContact = [Select Id from Contact];
        
		delete lPlanContacts;
        
        Test.startTest();
        List<Plan_Contact__c> ldeletedPlanContacts = [SELECT Id,Contact__c FROM Plan_Contact__c ALL ROWS];
        undelete ldeletedPlanContacts;
        Test.stopTest();
        
    }

     @isTest
    public static void checkPlanContactUpdateAcr(){
        
        Plan_Contact__c lPlanContacts = [SELECT Id,Contact__c,Is_Success_Community_User__c,Plan__c,CST_Survey_Sent__c,MFA_Survey_Sent__c FROM Plan_Contact__c limit 1];
        lPlanContacts.Is_Success_Community_User__c=true;
        lPlanContacts.CST_Survey_Sent__c = true;
        lPlanContacts.MFA_Survey_Sent__c = true;

        SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test');
        UtilityTestData.mAccountData.put('BillingCountry', 'US');       
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

        sObj = new Contact();
        UtilityTestData.mContactData.put('LastName', 'Test');
        UtilityTestData.mContactData.put('AccountId', lNewCustomerAccount[0].Id);        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});

        sObject objective = new Objective__c();
        UtilityTestData.mObjective.put('Plan__c',lPlanContacts.Plan__c);
        UtilityTestData.mObjective.put('Sign_Off_Date__c',string.valueOf(Date.today()));
        UtilityTestData.mObjective.put('Is_Template__c','true');
        UtilityTestData.mObjective.put('Customer_Sign_off_Contact__c',lContact[0].Id);
        objective = UtilityTest.putFieldRecord(objective, UtilityTestData.mObjective);
        List<Objective__c> lObjective = (List<Objective__c>) UtilityTest.makeInsert(new List<sObject>{objective});

        sObject mstone = new Milestone__c();
        UtilityTestData.mPlanMilestone.put('Plan__c',lPlanContacts.Plan__c);
        UtilityTestData.mPlanMilestone.put('Is_Template__c','true');
        UtilityTestData.mPlanMilestone.put('Is_Internal__c','false');
        UtilityTestData.mPlanMilestone.put('Planned_Completion_Date__c',string.valueOf(Date.today()));
        UtilityTestData.mPlanMilestone.put('Milestone_Type__c','Business Milestone');
        UtilityTestData.mPlanMilestone.put('Status__c','Yet to Start');
        UtilityTestData.mPlanMilestone.put('Objective__c',lObjective[0].Id);
        mstone = UtilityTest.putFieldRecord(mstone, UtilityTestData.mPlanMilestone);
        List<Milestone__c> lMilestone = (List<Milestone__c>) UtilityTest.makeInsert(new List<sObject>{mstone});

        Id CSTEngagementRT = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName().get('CST').getRecordTypeId();
        sObject engagement = new Engagement__c();
        Account lAccount = [SELECT Id FROM Account LIMIT 1];
        UtilityTestData.mEngagementData.put('Account__c',lAccount.Id);
        UtilityTestData.mEngagementData.put('Name','Test Engagment');//
        UtilityTestData.mEngagementData.put('RecordTypeId', CSTEngagementRT);
        UtilityTestData.mEngagementData.put('Owner_Manager__c',UserInfo.getUserId());
        UtilityTestData.mEngagementData.put('OwnerId',UserInfo.getUserId());
        UtilityTestData.mEngagementData.put('RecType__c','CSA');
        UtilityTestData.mEngagementData.put('CST_Survey_Sent__c','false');
        UtilityTestData.mEngagementData.put('Plan__c',lPlanContacts.Plan__c);
        UtilityTestData.mEngagementData.put('Status__c','Completed');
        UtilityTestData.mEngagementData.put('Closing_Notes__c','test close notes');
        UtilityTestData.mEngagementData.put('Milestone__c',lMilestone[0].Id);
        engagement = UtilityTest.putFieldRecord(engagement, UtilityTestData.mEngagementData);        
        List<Engagement__c> lEngagement = (List<Engagement__c>) UtilityTest.makeInsert(new List<sObject>{engagement});
       
        update lPlanContacts;
        
    }

}