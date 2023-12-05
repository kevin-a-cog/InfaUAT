/*
    @created by       : balajip
    @created on       : 02/15/2020
    @Purpose          : Test class for EngagementController
    @Testclass        : 
    @JIRA             : 
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************

 */
@isTest
public with sharing class EngagementControllerTest {

    public static id recTypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    public EngagementControllerTest() {

    }

    public class CaseEscalationNotes{
        public String id;
        public String escalationNotes;
    }
    
    @testSetup
    static void setupObjectTestData() {
        
        id customerAccRecTypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();

        //create an Account record
        sObject sObj = new Account();
        UtilityTestData.mAccountData.put('RecordTypeId', customerAccRecTypeId);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

        //create an Account record
        sObj = new Account();
        UtilityTestData.mAccountData.put('RecordTypeId', recTypeId);
        UtilityTestData.mAccountData.put('ParentId', lCustomerAccount.get(0).Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

        //create an Engagement record
        sObj = new Engagement__c();

        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEngagementEscalation);
        sObj.put('Support_Account__c', lAccount.get(0).Id);
        UtilityTest.makeInsert(new List<sObject>{sObj});

        //create a Case record
        sObj = new Case();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
        sObj.put('AccountId', lAccount.get(0).Id);
        sObj.put('OwnerId', UserInfo.getUserId());
        UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //create Profile Skill records
        List<sObject> lstSObj = new List<sObject>();
        sObj = new ProfileSkill();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillEscalation);
        lstSObj.add(sObj);
        sObj = new ProfileSkill();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillProductSME);
        lstSObj.add(sObj);
        sObj = new ProfileSkill();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillProductPS);
        lstSObj.add(sObj);
        UtilityTest.makeInsert(lstSObj);
    }
    
    @isTest
    static void testAllMethods(){

        Account acc = [Select Id,ParentId From Account Where RecordTypeId=:recTypeId Limit 1];
        Case cse = [Select Id From Case Limit 1];
        Engagement__c engagement = [Select Id From Engagement__c Limit 1];

        Test.startTest();

        EngagementController controller = new EngagementController();

        EngagementController.getCases(engagement.Id, acc.Id, acc.ParentId);
        EngagementController.updateEscalationNotes('["' + cse.Id + '"]', 'escalation notes');

        List<CaseEscalationNotes> lstCaseEscNotes = new List<CaseEscalationNotes>();
        CaseEscalationNotes escNotes = new CaseEscalationNotes();
        escNotes.id = cse.Id;
        escNotes.escalationNotes = 'aaaaaaaaaaaa';
        lstCaseEscNotes.add(escNotes);
        EngagementController.updateCases(lstCaseEscNotes);
        Test.stopTest();
    }

    @isTest
    static void testremovecasesfromEngagement(){
        Test.startTest();
        Account acc = [Select Id From Account Limit 1];
        Case cse = [Select Id From Case Limit 1];
        Engagement__c engagement = [Select Id From Engagement__c Limit 1];

        EngagementController.removecasesfromEngagement('["' + cse.Id + '"]');

        Test.stopTest();
    }

    @isTest
    static void testGetTableColumns() {
        // Create a test GCS_Config__c record
        GCS_Config__c config = new GCS_Config__c();
        config.GEMS_Manage_Cases_Columns__c = 'Column1,Column2,Column3';
        insert config;
        
        // Call the method being tested
        Test.startTest();
        List<String> columnNames = EngagementController.getTableColumns();
        Test.stopTest();
    }
}