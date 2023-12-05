/*
* Name          :   CSMPlanCommentTriggerHelperTest
* Author        :   Deva M
* Created Date  :   13/10/2021
* Description   :   Test class for CSMPlanCommentTriggerHelper

Change History
**********************************************************************************************************
Modified By         Date            Jira No.        Description                 Tag
**********************************************************************************************************
Deva M              13/10/2021      N/A             Initial version.            N/A
*/
@isTest
public with sharing class CSMPlanCommentTriggerHelperTest {
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
        UtilityTestData.mPlan.put('CSM_isAutoPilot__c',false+'');
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);        
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});
        lPlan[0].CSM_isAutoPilot__c = true;
        update lPlan[0];
        
    }  
    @isTest
    public static void createAutoPilotPlanCommentTest() {
        Plan__c plan=[select Id from Plan__c limit 1];
        Test.startTest();
        Plan_Comment__c planComment = new Plan_Comment__c(Plan__c=plan.Id);
        planComment.Comment__c='commentValue';
        planComment.Type__c='Cassini';
        planComment.Status__c='Draft';
        planComment.Sub_Type__c='Auto Pilot';
        planComment.Is_Automated__c=true;
        planComment.Tagged_User_1__c = UserInfo.getUserId();
        planComment.Tagged_User_2__c = UserInfo.getUserId();
        planComment.Tagged_User_3__c = UserInfo.getUserId();
        planComment.Tagged_User_4__c = UserInfo.getUserId();
        planComment.Tagged_User_5__c = UserInfo.getUserId();
        insert planComment;
         planComment.Status__c= CSMUtilities.STATUS_SUBMITTED ;
        update planComment;
        test.stopTest();
        Plan__c planAfter=[select Id,CSM_isAutoPilot__c from Plan__c limit 1];
        
    }
    
      @isTest
    public static void createAutoPilotPlanCommentTest2() {
        Plan__c plan=[select Id from Plan__c limit 1];
        Test.startTest();
        Plan_Comment__c planComment = new Plan_Comment__c(Plan__c=plan.Id);
        planComment.Comment__c='commentValue';
        planComment.Type__c='Cassini';
       planComment.Status__c= CSMUtilities.STATUS_SUBMITTED ;
        planComment.Sub_Type__c='Auto Pilot';
        planComment.Is_Automated__c=true;
        planComment.Tagged_User_1__c = UserInfo.getUserId();
        planComment.Tagged_User_2__c = UserInfo.getUserId();
        planComment.Tagged_User_3__c = UserInfo.getUserId();
        planComment.Tagged_User_4__c = UserInfo.getUserId();
        planComment.Tagged_User_5__c = UserInfo.getUserId();
        insert planComment;        
        test.stopTest();
        Plan__c planAfter=[select Id,CSM_isAutoPilot__c from Plan__c limit 1];
        
    }
}