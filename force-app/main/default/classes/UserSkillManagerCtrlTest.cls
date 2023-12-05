/*
Change History
****************************************************************************************************
ModifiedBy		Date        Jira No.    Tag     Description
****************************************************************************************************
balajip			03/17/2022	I2RT-5677	T01		removed the calls to the methods that no longer exists
****************************************************************************************************
*/
@isTest
public with sharing class UserSkillManagerCtrlTest {
    @testSetup
    static void setupObjectTestData() {
        //create Profile Skill records
        List<sObject> lstSObj = new List<sObject>();
        SObject sObj = new ProfileSkill();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillEscalation);
        sObj.put('Omni_Skill_Name__c', 'PowerCenter');
        sObj.put('Domain__c', 'Service Cloud');        
        sObj.put('Visible__c', true);        
        lstSObj.add(sObj);
        
        sObj = new ProfileSkill();
        sObj.put('Omni_Skill_Name__c', 'PowerCenter');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillProductSME);
        sObj.put('Domain__c', 'Service Cloud');        
        sObj.put('Visible__c', true);        
        lstSObj.add(sObj);
        
        sObj = new ProfileSkill();
        sObj.put('Omni_Skill_Name__c', 'PowerCenter');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillProductPS);
        sObj.put('Domain__c', 'Service Cloud');        
        sObj.put('Visible__c', true);        
        sObj.put('Omni_Skill_Name__c', 'PowerCenter');
        lstSObj.add(sObj);
        UtilityTest.makeInsert(lstSObj);

        ProfileSkillUser profileSkillUser = new ProfileSkillUser();
        profileSkillUser.ProfileSkillId = lstSObj.get(0).Id;
        profileSkillUser.UserId = UserInfo.getUserId();
        //insert profileSkillUser;

        //create collaboration
        CollaborationGroup chatterGroup = new CollaborationGroup();
        chatterGroup.Name='PowerCenter-PS'; // Define group name here
        chatterGroup.CollaborationType='Public'; //It can be 'Public' or 'Private'                   
        insert chatterGroup;
    }

    @isTest
    static void testMethods(){
        ProfileSkill profileSkill = [Select Id From ProfileSkill Where Name = 'PowerCenter - PS'];

        UserSkillManagerCtrl.fetchProfileSkills(UserInfo.getUserId(), '');
        UserSkillManagerCtrl.getselectOptions('Priority__c');
        UserSkillManagerCtrl.addNewProfileSkillUser('[{"name":"PowerCenter","roleBased":false,"lstSkillType":[{"keyval":"PowerCenter-Product Specialist","type":"Product Specialist","orderNumber":2,"showSkill":true,"disabled":false,"assigned":true,"profileSkillId":"' + profileSkill.Id + '"}]}]', false, UserInfo.getUserId());
        UserSkillManagerCtrl.fetchProfileSkills(UserInfo.getUserId(), '');

        ProfileSkillUser profileSkillUser = [Select Id From ProfileSkillUser Limit 1];
        UserSkillManagerCtrl.removeSkill(profileSkillUser.Id);
    }
}