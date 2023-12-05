/*
@created by       : Vivek W
@created on       : 30-Nov-2021
@Purpose          : Test class for psa_rm_SkillRatingTriggerHelper

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/

@isTest(seeAllData=false)
public class psa_rm_SkillRatingTriggerHelperTest {
    
    public static void setupCustomSettings(){
        Bypass_Trigger_Settings__c trigSetting = new Bypass_Trigger_Settings__c();
        trigSetting.psa_SkillRatingTrigger__c = true;
        insert trigSetting;
    }
    
    @testSetup
    static void setupObjectTestData() {
        
        setupCustomSettings();
        
        RecordType AccRecType = [select id,Name from RecordType where SobjectType='Account' and DeveloperName='Customer_Account' Limit 1];
        
        Sobject sObj;
        Sobject sObj1;
        
        sObj = new Account();
        UtilityTestData.mAccountData.put('Name','Test Account');
        UtilityTestData.mAccountData.put('RecordTypeId', AccRecType.Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new pse__Region__c();
        UtilityTestData.mRegion.put('Name','Test Region-1');
        UtilityTestData.mRegion.put('psa_pm_Territory_ID_Mapping__c','13423');
        UtilityTestData.mRegion.put('pse__Action_Update_Current_Time_Period__c','false');
        UtilityTestData.mRegion.put('psa_pm_Territory_ID_Mapping__c','13423');
        UtilityTestData.mRegion.put('Allow_Customer_Project__c','true');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRegion);
        
        sObj1 = new pse__Region__c();
        UtilityTestData.mRegion.put('Name','Test Region-2');
        UtilityTestData.mRegion.put('pse__Action_Update_Current_Time_Period__c','false');
        UtilityTestData.mRegion.put('psa_pm_Territory_ID_Mapping__c','1340023');
        UtilityTestData.mRegion.put('Allow_Customer_Project__c','true');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mRegion);
        List<pse__Region__c> lRegion = (List<pse__Region__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        Profile prof = [select Name from Profile where Name = 'Employee'];
        User psaNonAdminUser = new User(alias='psaNAmin',
                                        username='psaUser2TestNAdmin@abc123.com',
                                        lastname='psaUserTestNonAdmin',
                                        firstname='psaUserTestNonAdmin',
                                        email='psaUser2TestNAdmin@abc123.com',
                                        communitynickname='psaNAmin',
                                        timezonesidkey='America/New_York',
                                        LocaleSidKey='en_US',
                                        ProfileId=prof.Id,
                                        LanguageLocaleKey='en_US',
                                        EmailEncodingKey='UTF-8');
        insert psaNonAdminUser;
        
        User userObj = [select Id, Name from User where Id =:UserInfo.getUserId() limit 1];
        
        RecordType rt = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='Customer_Contact' Limit 1];

        sObj = new pse__Skill__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSkill);
        List<pse__Skill__c> lSkill = (List<pse__Skill__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        System.runAs(userObj){
            
            pse__Work_Calendar__c defaultWorkCalendar = new pse__Work_Calendar__c(Name='Test Work Calendar');
            defaultWorkCalendar.pse__Sunday_Hours__c= 8;
            defaultWorkCalendar.pse__Monday_Hours__c=8;
            defaultWorkCalendar.pse__Tuesday_Hours__c=8;
            defaultWorkCalendar.pse__Wednesday_Hours__c=8;
            defaultWorkCalendar.pse__Thursday_Hours__c=8;
            defaultWorkCalendar.pse__Friday_Hours__c=8;
            defaultWorkCalendar.pse__Saturday_Hours__c=8;                
            insert defaultWorkCalendar; 
            
            sObj = new Contact();
            UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mContactData.put('pse__Resource_Role__c','Regional Manager');
            UtilityTestData.mContactData.put('pse__Region__c',lRegion[0].Id);
            UtilityTestData.mContactData.put('pse__Is_Resource__c','false');
            UtilityTestData.mContactData.put('Is_Primary__c','false');
            UtilityTestData.mContactData.put('pse__Is_Resource__c','true');
            UtilityTestData.mContactData.put('pse__Is_Resource_Active__c','true');
            UtilityTestData.mContactData.put('pse__Default_Cost_Rate__c','10.00');//psa_Employee_Type__c
            UtilityTestData.mContactData.put('pse__Work_Calendar__c',defaultWorkCalendar.Id);
            UtilityTestData.mContactData.put('Allow_Customer_Project__c','true');
            UtilityTestData.mContactData.put('employee_guid__c','serp-employee-guid');
            UtilityTestData.mContactData.put('psa_Employee_Type__c','Informatica-Non PS');
            
            UtilityTestData.mContactData.put('pse__Salesforce_User__c',userObj.Id);
            UtilityTestData.mContactData.put('RecordTypeId',rt.Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            
            List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        }
    }

    public static testmethod void testRatingInsert(){
        
        Sobject sObj;

        Test.startTest();

        List<Contact> lContact = [SELECT Id FROM Contact LIMIT 1];
        System.debug('lContact: ' + lContact);

        List<pse__Skill__c> lSkill = [SELECT Id FROM pse__Skill__c LIMIT 1];
        System.debug('lSkill: ' + lSkill);

        pse__Skill_Certification_Rating__c scr = new pse__Skill_Certification_Rating__c();
        scr.pse__Aspiration__c = true; 
        scr.pse__Certified__c = true; 
        scr.pse__Rating__c = '1 - Limited Exposure';
        scr.pse__Resource__c = lContact[0].Id;
        scr.pse__Skill_Certification__c = lSkill[0].Id;
        insert scr;

        Test.stopTest();
    }

    public static testmethod void testRatingUpdate(){
        
        Sobject sObj;
        
        List<Contact> lContact = [SELECT Id FROM Contact LIMIT 1];
        System.debug('lContact: ' + lContact);

        List<pse__Skill__c> lSkill = [SELECT Id FROM pse__Skill__c LIMIT 1];
        System.debug('lSkill: ' + lSkill);

        pse__Skill_Certification_Rating__c scr = new pse__Skill_Certification_Rating__c();
        scr.pse__Aspiration__c = true; 
        scr.pse__Certified__c = true; 
        scr.pse__Rating__c = '1 - Limited Exposure';
        scr.pse__Resource__c = lContact[0].Id;
        scr.pse__Skill_Certification__c = lSkill[0].Id;
        scr.psa_Status__c = 'Validated';
        insert scr;

        Test.startTest();

        scr.pse__Rating__c = '3 - Comfortable';
        update scr;
        
        Test.stopTest();
    }
    
    public static testmethod void testSkillBatch(){
        
        Sobject sObj;
        
        List<Contact> lContact = [SELECT Id FROM Contact LIMIT 1];
        System.debug('lContact: ' + lContact);

        List<pse__Skill__c> lSkill = [SELECT Id FROM pse__Skill__c LIMIT 1];
        System.debug('lSkill: ' + lSkill);

        pse__Skill_Certification_Rating__c scr = new pse__Skill_Certification_Rating__c();
        scr.pse__Aspiration__c = true; 
        scr.pse__Certified__c = true; 
        scr.pse__Rating__c = '1 - Limited Exposure';
        scr.pse__Resource__c = lContact[0].Id;
        scr.pse__Skill_Certification__c = lSkill[0].Id;
        scr.psa_Status__c = 'Validated';
        scr.pse__Expiration_Date__c = Date.today().addDays(-1);
        insert scr;
        
        Test.startTest();
        
        psa_rm_SkillRatingUpdateBatch batch = new psa_rm_SkillRatingUpdateBatch();
        Id jobid = Database.executeBatch(batch,200);
        
        Test.stopTest();
    }
    
    public static testmethod void testSkillScheduler(){
        
        Sobject sObj;
        
        List<Contact> lContact = [SELECT Id FROM Contact LIMIT 1];
        System.debug('lContact: ' + lContact);

        List<pse__Skill__c> lSkill = [SELECT Id FROM pse__Skill__c LIMIT 1];
        System.debug('lSkill: ' + lSkill);

        pse__Skill_Certification_Rating__c scr = new pse__Skill_Certification_Rating__c();
        scr.pse__Aspiration__c = true; 
        scr.pse__Certified__c = true; 
        scr.pse__Rating__c = '1 - Limited Exposure';
        scr.pse__Resource__c = lContact[0].Id;
        scr.pse__Skill_Certification__c = lSkill[0].Id;
        scr.psa_Status__c = 'Validated';
        scr.pse__Expiration_Date__c = Date.today().addDays(-1);
        insert scr;
        
        Test.startTest();
        psa_rm_SkillRatingUpdateScheduler skillRatingScheduler = new psa_rm_SkillRatingUpdateScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Activate Pricebook Schedule', sch, skillRatingScheduler); 
        Test.stopTest();
    }
}