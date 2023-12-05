/*
    @created by       : balajip
    @created on       : 02/15/2020
    @Purpose          : Test class for EngagementService
    @Testclass        : 
    @JIRA             : 
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************
 balajip        07/13/2022  I2RT-6153   T01     To replace GCS_Segment__c field with Segment__c field in the notifications

 */
@isTest
public with sharing class EngagementServiceTest {
    
    @testSetup
    static void setupObjectTestData() {
        
        //create an Account record
        sObject sObj = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        UtilityTest.makeInsert(new List<sObject>{sObj});

        //create a Case record
        sObj = new Case();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
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
        Account acc = [Select Id From Account Limit 1];
        id recTypeId = [select id from recordType where name = 'Support Account' limit 1].id;
        acc.recordtypeId = recTypeid;
        EngagementService engService = new EngagementService();
        EngagementService.getRecordTypeId(EngagementService.RECORD_TYPE_NAME_SUPPORT_ESCALATION);
        EngagementService.createSupportEscalation(acc.Id, 'Test Engagement', 'P2', 'Hot', 'Customer', 'Escalation','','');
        update acc;
        Engagement__c eng = EngagementService.getSupportEngagement(acc.Id);
        EngagementService.updateLastActivity(new Set<Id>{eng.Id});

        Case cse = [Select Id, CaseNumber, Subject, IsEscalated,  Forecast_Product__c, Support_Account__c,
                    AccountId, OwnerId, Owner_Name__c, Engagement__c, Engagement__r.Status__c, Attention_Request__c,
                    Priority, Support_Level__c, Version__c, GCS_Segment__c, Segment__c, Acc__c, //T01
                    Support_Account__r.Name, Support_Account__r.New_Org_Account_Number__c,
                    Account.Name, Account.New_Org_Account_Number__c From Case Limit 1];
        EngagementService.notifyCaseTeam(cse, eng, 'test');
    }
}