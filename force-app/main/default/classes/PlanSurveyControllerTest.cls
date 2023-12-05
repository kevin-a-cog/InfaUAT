/*
Class:          PlanSurveyControllerTest
@Author:        Chandana Gowda
@Created Date:  17/3/2018
@Description:   AR-1101 Test class for PlanSurveyController

    Change History
*************************************************************************************************************************************
    ModifiedBy               Date        Requested By        Description                                         Tag                                                       
*************************************************************************************************************************************
*/
@isTest
public with sharing class PlanSurveyControllerTest {
    //Setting up the test data
    @testSetup
    static void setupObjectTestData() {        
        //Account
        sObject Account = new Account();
        Account = UtilityTest.putFieldRecord(Account, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{Account});

        sObject sObj1 = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname2');
        UtilityTestData.mContactData.put('LastName','LastName2');
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mContactData);   
        sObject sObj2 = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname2');
        UtilityTestData.mContactData.put('LastName','LastName2');
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mContactData); 
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj1,sObj2});
        
        //Opportunity
        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('RecordTypeId',Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId()); 
        sObject Opty = new Opportunity();
        Opty = UtilityTest.putFieldRecord(Opty, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpty = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{Opty});
        
        //Account LOB
        UtilityTestData.mAccountLOB.put('Account__c',lAccount[0].Id);
        sObject AccLOB = new Account_LOB__c();
        AccLOB = UtilityTest.putFieldRecord(AccLOB, UtilityTestData.mAccountLOB);
        List<Account_LOB__c> lAccLOB = (List<Account_LOB__c>) UtilityTest.makeInsert(new List<sObject>{AccLOB});

        sObject sObj = new Success_Contact__c();
        UtilityTestData.mLOBContact.put('Contact__c',lContact[0].id);
        UtilityTestData.mLOBContact.put('Line_of_Business__c',lAccLOB[0].id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLOBContact);
        List<Success_Contact__c> lLOBContact = (List<Success_Contact__c>) UtilityTest.makeInsert(new List<sObject>{sObj});        
        
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan');
        UtilityTestData.mPlan.put('Line_of_Business__c',lAccLOB[0].Id);
        UtilityTestData.mPlan.put('LOB_Contact_email__c','test@test.com');
        UtilityTestData.mPlan.put('Success_Plan_Signoff_Contact__c',lLOBContact[0].Id); 
        UtilityTestData.mPlan.put('Success_Plan_Customer_Signoff__c',String.valueOf(System.today())); 
        UtilityTestData.mPlan.put('Actual_Go_Live_Date__c',String.valueOf(System.today()));        
        UtilityTestData.mPlan.put('Projected_Go_Live_Date__c',String.valueOf(System.today()));
        //UtilityTestData.mPlan.put('RecordTypeId', Schema.SObjectType.Plan__c.getRecordTypeInfosByName().get('Adoption Success Plan').getRecordTypeId());
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});

		//Plan Contact
		Plan_Contact__c pc = new Plan_Contact__c();
		pc.Plan__c = lPlan[0].Id;
        pc.Contact__c =  lContact[0].Id;
        insert pc;
    }

    //Test Plan data
    @isTest
    public static void CheckSurveySentTest(){
        Plan__c plan =[SELECT ID,Onboarding_Survey_Sent__c,Account__c,Business_Outcome_Survey_Sent__c FROM plan__c LIMIT 1];
        Plan__c planFunc = PlanSurveyController.CheckSurveySent(plan.Id);
        System.assertEquals(planFunc.Id,plan.Id);
        List<Contact> conlist = PlanSurveyController.acccontacts(plan.Id);
        List<Contact> conlist2 = PlanSurveyController.findByName('First',plan.Account__c);
    }

    //Test Onboarding_Survey_Sent__c Updated to true
    @isTest
    public static void updateOnboardingSurveySent(){
        Plan__c plan =[SELECT ID,Onboarding_Survey_Sent__c,Account__c,Business_Outcome_Survey_Sent__c FROM plan__c LIMIT 1];
        List<Contact> conlist = new List<Contact>([SELECT Id,Name,Email,Title,AccountId FROM Contact ]);
        plan.put('Current_State_of_plan__c','Configuration');
        List<Plan__c> lstPlan = (List<Plan__c>) UtilityTest.makeUpdate(new List<sObject>{plan});
        PlanSurveyController.updatePlanSurveySent(conlist,plan.Id);
        System.assertNotEquals(true, plan.get('Onboarding_Survey_Sent__c'));
    }    

    //Test Business_Outcome_Survey_Sent__c Updated to true
    @isTest
    public static void updateBizOutcomeSurveySent(){
        Plan_contact__c pc =[SELECT ID,Plan__c,Plan__r.Onboarding_Survey_Sent__c,Plan__r.Account__c,Plan__r.Business_Outcome_Survey_Sent__c FROM Plan_contact__c LIMIT 1];
        List<Contact> conlist = new List<Contact>([SELECT Id,Name,Email,Title,AccountId FROM Contact ]);
        system.debug('size'+conlist.size());
        Plan__c plan = new Plan__c();
        plan.Id = pc.Plan__c;
        plan.put('Current_State_of_plan__c','Optimize/Grow');
        List<Plan__c> lstPlan = (List<Plan__c>) UtilityTest.makeUpdate(new List<sObject>{plan});
        PlanSurveyController.updatePlanSurveySent(conlist,pc.plan__c);
        System.assertNotEquals(true, plan.get('Business_Outcome_Survey_Sent__c'));
    }    
    
}