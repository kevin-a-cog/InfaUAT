/*
 * Name			:	CSMCreateAdoptionFactorRecordTest
 * Author		:	Deva M
 * Created Date	: 	30/09/2021
 * Description	:	Test Class for CSMCreateAdoptionFactorRecordSchedular

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M					30/09/2021		AR-1575			Initial version.			N/A
 */
@istest
public with sharing class CSMCreateAdoptionFactorRecordTest {
    public static String CRON_EXP = '0 0 0 3 9 ? 2023';
    public static string ADOPTION_INITIAL_STATUS ='Waiting for CSM Input';
    @testSetup
    static void setupObjectTestData() {
        List<User> userList = UtilityTest.createUsersforPRM();
        User adminUser = userList[0];
        User sogUser = userList[1];
        User psmUser = userList[2];
        Id systemAdminId = UserInfo.getUserId();
        system.runAs(adminUser){
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
        UtilityTestData.mPlan.put('CSM_isAutoPilot__c','false');       
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);        
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});
            
            Plan_Team__c csm =  new Plan_Team__c(User__c=systemAdminId, Plan__c=plan.Id,Role__c=CSMUtilities.ROLE_CSM);
            Plan_Team__c csmManager =  new Plan_Team__c(User__c=sogUser.Id, Plan__c=plan.Id,Role__c=CSMUtilities.ROLE_CSM_MANAGER);
            insert new List<Plan_Team__c>{csm,csmManager};
       }        
    }  
    static testmethod void CSMCreateAdoptionFactorRecordSchedularTest() {
        Test.startTest();
        String jobId = System.schedule('testBasicScheduledApex',CRON_EXP,new CSMCreateAdoptionFactorRecordSchedular());
        Test.stopTest();
    }
    
    static testmethod void CSMCreateAdoptionFactorRecordSchedularForExisitngAdfTest() {
        Plan__c planRecord = [SELECT Id FROM Plan__c LIMIT 1];
        insert new Adoption_Factor__c(Plan__c=planRecord.Id,Status__c=ADOPTION_INITIAL_STATUS); 
        Test.startTest();
        String jobId = System.schedule('testBasicScheduledApex',CRON_EXP,new CSMCreateAdoptionFactorRecordSchedular());
        Test.stopTest();
    }
    static testmethod void CSMCreateAdoptionFactorRecordSchedularForExisitngFinalAdfTest() {
        Plan__c planRecord = [SELECT Id FROM Plan__c LIMIT 1];
        planRecord.Next_Expected_Adoption_Factor_Date__c = system.today();
        update planRecord;
        
        insert new Adoption_Factor__c(Plan__c=planRecord.Id,Status__c='Final'); 
        Test.startTest();
        String jobId = System.schedule('testBasicScheduledApex',CRON_EXP,new CSMCreateAdoptionFactorRecordSchedular());
        Test.stopTest();
    }
}