/*
    @created by       : balajip
    @created on       : 02/15/2020
    @Purpose          : Test class for CaseTeamService
    @Testclass        : 
    @JIRA             : 
    
Change History
****************************************************************************************************
ModifiedBy  Date        Jira No.    Tag     Description
****************************************************************************************************
balajip     07/05/2022  I2RT-6655   T01     added coverage for the new overridden method getCaseSubscribers
balajip     01/17/2023  I2RT-7643   T02     added coverage for the new method updateEscalationManager

*/

@isTest
public with sharing class CaseTeamServiceTest {
    
    @testSetup
    static void setupObjectTestData() {
        //create a case record
        sObject sObj = new Case();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
        List<Case> lCase = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});

        Subscription__c subscription = new Subscription__c();
        subscription.Record_Id__c = sObj.Id;
        subscription.Subscriber_Id__c = UserInfo.getUserId();
        subscription.Subscribed__c = true;
        insert subscription;
        
        //create an Engagement record
        sObj = new Engagement__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEngagementEscalation);
        List<Engagement__c> lEngagement = (List<Engagement__c>)UtilityTest.makeInsert(new List<sObject>{sObj});

        //update Case
        lCase[0].Engagement__c = lEngagement[0].Id;
        update lCase[0];

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
        Case cse = [Select Id, OwnerId, Is_case_claimed_weekend_holiday__c, Case_claimed_by_user_weekend_holiday__c From Case Limit 1];
        user admin = [Select Id from user where profile.Name='System Administrator' Limit 1];
        Engagement__c eng = [Select Id, OwnerId From Engagement__c Limit 1];

        Test.startTest();

        CaseTeamService service = new CaseTeamService();
        //CaseTeamService.getCaseTeamRoleId(CaseTeamService.TEAM_ROLE_CO_OWNER);
        CaseTeamService.isUserPartOfTeam(cse.Id, UserInfo.getUserId());
        Case_Team__c caseTeamMember = CaseTeamService.createMember(cse.Id, UserInfo.getUserId(), CaseTeamService.TEAM_ROLE_CO_OWNER);
        CaseTeamService.checkAndCreate(new List<Case_Team__c>{caseTeamMember});
        CaseTeamService.getCaseSubscribers(cse.Id,true,true,true,true);
        CaseTeamService.getCaseSubscribers(cse,new Set<Subscription__c>(),true,true,true,true); //T01
        CaseTeamService.swapOwner(cse.Id, UserInfo.getUserId(),admin.Id);
        CaseTeamService.updateEscalationManager(new Map<Id, Id>{eng.Id=>eng.OwnerId}, new Set<Id>(), new Set<Id>()); //T02
        CaseTeamService.updateEscalationManager(new Map<Id, Id>(), new Set<Id>{eng.Id}, new Set<Id>{cse.Id}); //T02
        Test.stopTest();
    }
}