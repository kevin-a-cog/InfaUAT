/*
 * Name			:	CSMAdoptionFactorViewControllerTest
 * Author		:	Deva M
 * Created Date	: 	30/09/2021
 * Description	:	Test Class for CSMAdoptionFactorViewController

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M					30/09/2021		AR-1575			Initial version.			N/A
 */
@istest
public with sharing class CSMAdoptionFactorViewControllerTest {
    public static string ADOPTION_INITIAL_STATUS ='Waiting for CSM Input';
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
        UtilityTestData.mPlan.put('CSM_isAutoPilot__c','false');       
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);        
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});
        Plan__c planRecord = [SELECT Id FROM Plan__c LIMIT 1];
        insert new Adoption_Factor__c(Plan__c=planRecord.Id,Status__c=ADOPTION_INITIAL_STATUS); 
    }  
    static testmethod void getAdoptionFactorTest() {
        Plan__c planRecord = [SELECT Id FROM Plan__c LIMIT 1];
        Test.startTest();
        List<Adoption_Factor__c> adopList=CSMAdoptionFactorViewController.getAdoptionFactor(planRecord.Id);
        CSMAdoptionFactorViewController.checkPlanLocked(planRecord.Id);
        System.assert(adopList!=null);
        Test.stopTest();
    }
    static testmethod void updatePlanRecordTest() {
        Plan__c planRecord = [SELECT Id FROM Plan__c LIMIT 1];
        Test.startTest();
        CSMAdoptionFactorViewController.updatePlanRecord(planRecord.Id,'15','Green','Check if reason Validated');
        CSMAdoptionFactorViewController.logPafComment(planRecord.Id,'Plan Comment','Chatterpost');
        Plan__c planRecordUpdated = [SELECT Id,Plan_status_picklist__c FROM Plan__c WHERE Id=:planRecord.Id];
        System.assert(planRecordUpdated.Plan_status_picklist__c == 'Green');
        Test.stopTest();
    }
    @istest
    public static void testAfterUpdate(){
         List<Adoption_Factor__c> interlocker = [SELECT Id,CSM_Comments__c FROM Adoption_Factor__c];
         interlocker[0].CSM_Comments__c='Test';
        update interlocker;
        system.debug('*****'+interlocker);
    }
}