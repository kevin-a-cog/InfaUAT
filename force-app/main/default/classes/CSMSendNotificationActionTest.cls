/*
* Name          :   CSMSendNotificationActionTest
* Author        :   Pavithra V
* Created Date  :   26/11/2021
* Description   :   Test class for CSMSendNotificationAction

Change History
**********************************************************************************************************
Modified By         Date            Jira No.        Description                 Tag
**********************************************************************************************************
Pavithra V             13/10/2021      N/A             Initial version.            N/A
*/
@isTest
public class CSMSendNotificationActionTest {
    
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
        UtilityTestData.mPlan.put('CSM_isAutoPilot__c',true+'');
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);        
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});
    }  
    @isTest
    public static void createAutoPilotPlanCommentTest() {
        Plan__c plan=[select Id from Plan__c limit 1];
        Test.startTest();
        Plan_Comment__c planComment = new Plan_Comment__c(Plan__c=plan.Id);
        planComment.Comment__c='commentValue';
        planComment.Type__c='Cassini';
        planComment.Status__c='Scheduled';
        planComment.Date_Time_Scheduled__c= System.now();
        planComment.Sub_Type__c='Auto Pilot';
        planComment.Is_Automated__c=true;
        insert planComment;
        List<Id> pCommentList = new List<Id>{planComment.Id};
        CSMSendNotificationAction.sendNotificationToUser(pCommentList);
        test.stopTest();
        
        
    }

}