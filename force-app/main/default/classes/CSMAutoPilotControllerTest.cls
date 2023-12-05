/*
* Name          :   CSMAutoPilotControllerTest
* Author        :   Deva M
* Created Date  :   17/09/2021
* Description   :   Test class for CSMAutoPilotController

Change History
**********************************************************************************************************
Modified By         Date            Jira No.        Description                 Tag
**********************************************************************************************************
Deva M                  17/09/2021      N/A             Initial version.            N/A
*/
@isTest(seeAllData = false)
public class CSMAutoPilotControllerTest {
    @testSetup
    static void setupObjectTestData() {
        //Account
        sObject Account = new Account();
        UtilityTestData.mAccountData.put('Signature_Success__c','TRUE');
        Account = UtilityTest.putFieldRecord(Account, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{Account});
        //Plan
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mPlan.put('Name','Test Plan One');//
        UtilityTestData.mPlan.put('Sub_Stage__c','On-board');
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);        
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});
        CSMPlanTriggerHelper.createPlanTeamMember(new Set<Id>{lPlan[0].Id});
    }  
    
    @isTest
    public static void createAutoPilotPlanCommentTest() {
        Plan__c plan=[select Id from Plan__c limit 1];
        CSMAutoPilotController.createAutoPilotPlanComment(plan.Id,'Plan Comments for Auto Pilot',true,'Test User');
        List<Plan_Comment__c> pCommentList = new List<Plan_Comment__c>([Select Id From Plan_Comment__c]);
        //System.assert(pCommentList.size()>0);
    }

    @isTest
    public static void submitAutoPilotRequestTest() {
        Plan__c plan=[select Id,AutoPilot_Status__c,CSM_isAutoPilot__c from Plan__c limit 1];
        plan.AutoPilot_Status__c = 'Submitted for Approval';
        plan.CSM_isAutoPilot__c = false;
        update plan;
        Test.startTest();
        CSMAutoPilotController.submitAutoPilotRequest(plan.Id,'Plan Comments for Auto Pilot');
        List<Plan_Comment__c> pCommentList = new List<Plan_Comment__c>([Select Id From Plan_Comment__c]);
       // System.assert(pCommentList.size()>0);
        Test.stopTest();
    }

    @isTest
    public static void removeAutoPilotTest() {
        Plan__c plan=[select Id from Plan__c limit 1];
        CSMAutoPilotController.removeAutoPilot(plan.Id);
        CSMAutoPilotController.getPlanRecord(plan.Id);
        List<Plan_Comment__c> pCommentList = new List<Plan_Comment__c>([Select Id From Plan_Comment__c]);
        //System.assert(pCommentList.size()>0);
    }
     @isTest
    public static void LookupSearchHelperTest() {
        LookupSearchHelper.lookupCombinedSearch('search',new List<String>());
         LookupSearchHelper.lookupQueueSearch('search',new List<String>());
    }
}