/*
 * Name			:	CsmEditRiskProductControllerTest
 * Author		:	Deva M
 * Created Date	: 	31/01/2022
 * Description	:	CsmEditRiskProductController test class.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M         		31/01/2022		N/A				Initial version.			N/A
 */
@isTest
public with sharing class CSMCreatePlanCommentsQueueableTest {
    @testSetup
    static void setupObjectTestData() {

      
        
         SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test');
        UtilityTestData.mAccountData.put('BillingCountry', 'US');       
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan');
        UtilityTestData.mPlan.put('CSM_isAutoPilot__c','true');
        UtilityTestData.mPlan.put('Account__c',lNewCustomerAccount[0].Id);
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});
        
        sObject Plan2 = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan');
          UtilityTestData.mPlan.put('CSM_isAutoPilot__c','false');
        UtilityTestData.mPlan.put('Account__c',lNewCustomerAccount[0].Id);
        Plan2 = UtilityTest.putFieldRecord(Plan2, UtilityTestData.mPlan);
        List<Plan__c> lPlan2 = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan2});

    }

    @isTest
    public static void testUpdateStage(){
        Plan__c plan =[SELECT Id,Sub_Stage__c,Onboarding_Survey_Sent__c,Account__c,Business_Outcome_Survey_Sent__c FROM Plan__c Where CSM_isAutoPilot__c=false LIMIT 1];        
        plan.Sub_Stage__c = 'Design';
        plan.OwnerId = UserInfo.getUserId();
        plan.Closing_Notes__c = 'Test';
        plan.Closing_Reason__c = 'Lost Opportunity';
        plan.Plan_Completeness_Status__c = 'Submitted for Approval';
        update plan;
    }

    @isTest
    public static void autoPilotRemoveTest(){
        Plan__c plan=[select Id,AutoPilot_Status__c,CSM_isAutoPilot__c from Plan__c  where CSM_isAutoPilot__c = true limit 1];
        
        Test.startTest();
        plan.CSM_isAutoPilot__c=false;
        update plan;
       
        Test.stopTest();
    }

    @isTest
    public static void closePlan(){
        Plan__c plan=[select Id,AutoPilot_Status__c,CSM_isAutoPilot__c from Plan__c  where CSM_isAutoPilot__c = true limit 1];
        
        Test.startTest();
        plan.Plan_Closed_Date__c=System.today();
        update plan;
       
        Test.stopTest();
    }
}