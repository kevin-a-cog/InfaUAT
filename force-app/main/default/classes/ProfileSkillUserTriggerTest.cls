@isTest
public class ProfileSkillUserTriggerTest {
    
    @testSetup
    private static void initializeData(){
        
       
        
        // insert profile 
        Profile newProfile = [Select Id,Name from Profile where Name='Employee'];
        system.debug('newProfile'+newProfile);
        
        // insert user
        User newUser = new User();
        newUser.LastName='Test';
        newUser.FirstName='Devel';
        newUser.Email='developertest1234@gmail.com';
        newUser.Username = 'developertest1234@gmail.com.test';  
        newUser.Alias ='test';
        newUser.ProfileId=newProfile.Id;
        newUser.TimeZoneSidKey = 'GMT';
        newUser.LocaleSidKey = 'en_US';
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.LanguageLocaleKey = 'en_US';
        newUser.UserPermissionsKnowledgeUser = true;
        
        insert newUser;
        
        
        // insert public group
        Group newPublicGrp = new Group();
        newPublicGrp.Type='Regular';
        newPublicGrp.Name='Test Public Group';
        newPublicGrp.DeveloperName='TestPublicGroup';
        
        insert newPublicGrp;
        
        // insert Queue
        Group newQueue = new Group();
        newQueue.Type='Queue';
        newQueue.Name='Test Queue';
        newQueue.DeveloperName='TestQueue';
        
        insert newQueue;
        
        
        // insert Permission set
        PermissionSet newPermissionSet = new PermissionSet();
        newPermissionSet.Label ='Test Permission set';
        newPermissionSet.Name='Test_Permission_set';
        insert newPermissionSet;
        
        // insert PermissionSetAssignment
         
        PermissionSetAssignment newPermissionSetAssgnmt = new PermissionSetAssignment();
        newPermissionSetAssgnmt.AssigneeId = newUser.Id;
        newPermissionSetAssgnmt.PermissionSetId = newPermissionSet.Id;
        insert newPermissionSetAssgnmt;
       
        
        
    }
    @isTest
    static void addUserToGroupsTest(){
        
         //  insert custom settings
        Bypass_Trigger_Settings__c trigSetting = new Bypass_Trigger_Settings__c();
        trigSetting.Knowledge__c = true;
        trigSetting.ProfileSkillUser__c = true;
        insert trigSetting;
        user usrRec = [Select Id from User where LastName='Test' and FirstName='Devel' Limit 1];
         // insert Chatter group
        CollaborationGroup newChatterGrp =  new CollaborationGroup();
        newChatterGrp.Name='Test Chatter group';
        newChatterGrp.CollaborationType='Public';
        insert newChatterGrp;
        
        CollaborationGroup checkGrp =  [Select Id from CollaborationGroup where Id=:newChatterGrp.Id];
        system.debug('value of checkGrp'+checkGrp);
        
       
        
        // insert skill
        ProfileSkill newProfileSkill = new ProfileSkill();
        newProfileSkill.Chatter_Group_Name__c='Test Chatter group';
        newProfileSkill.Name ='Test Skill';
        newProfileSkill.Queue_Name__c='TestQueue';
        newProfileSkill.Permission_Set_Name__c='Test_Permission_set';
        newProfileSkill.Domain__c='Knowledge';
        newProfileSkill.Public_Group_Name__c='TestPublicGroup';
        newProfileSkill.Omni_Skill_Name__c='PowerCenter';
        insert newProfileSkill;
        
        ProfileSkillUser profSkillUsr = new ProfileSkillUser();
        profSkillUsr.ProfileSkillId = newProfileSkill.Id;
        profSkillUsr.UserId = usrRec.Id;
        insert profSkillUsr;
        
        update profSkillUsr;
        
    }
    @isTest
    static void removeUserFromGroupsTest(){
        
         //  insert custom settings
        Bypass_Trigger_Settings__c trigSetting = new Bypass_Trigger_Settings__c();
        trigSetting.Knowledge__c = true;
        trigSetting.ProfileSkillUser__c = true;
        insert trigSetting;
        user usrRec = [Select Id from User where LastName='Test' and FirstName='Devel' Limit 1];
         // insert Chatter group
        CollaborationGroup newChatterGrp =  new CollaborationGroup();
        newChatterGrp.Name='Test Chatter group';
        newChatterGrp.CollaborationType='Public';
        insert newChatterGrp;
      

        
        CollaborationGroup checkGrp =  [Select Id from CollaborationGroup where Id=:newChatterGrp.Id];
        system.debug('value of checkGrp'+checkGrp);
        
        // insert skill
        ProfileSkill newProfileSkill = new ProfileSkill();
        newProfileSkill.Chatter_Group_Name__c='Test Chatter group';
        newProfileSkill.Name ='Test Skill';
        newProfileSkill.Queue_Name__c='TestQueue';
        newProfileSkill.Permission_Set_Name__c='Test_Permission_set';
        newProfileSkill.Domain__c='Knowledge';
        newProfileSkill.Public_Group_Name__c='TestPublicGroup';
        insert newProfileSkill;
        
        ProfileSkillUser profSkillUsr = new ProfileSkillUser();
        profSkillUsr.ProfileSkillId = newProfileSkill.Id;
        profSkillUsr.UserId = usrRec.Id;
        insert profSkillUsr;
        
        delete profSkillUsr;
        
    }

}