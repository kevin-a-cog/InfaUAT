/*
    @created by       : balajip
    @created on       : 11/10/2021
    @Purpose          : Test class for EmailMessage Trigger, handler and helper classes
    @Testclass        : 
    @JIRA             : 
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************

 */
@isTest
public with sharing class EmailMessageTriggerTest {
    
    public static   Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    public static   Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    public static   Id technicalCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
       
    @testSetup
    static void setupObjectTestData() {
        
        SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
        UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecType);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
        UtilityTestData.mAccountData.put('IsCustomerPortal', 'True');
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Support Account');
        UtilityTestData.mAccountData.put('ParentId', lNewCustomerAccount[0].Id);
        UtilityTestData.mAccountData.put('RecordTypeId', SupportAccountRecType);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
        UtilityTestData.mAccountData.put('Active__c', 'true');
        UtilityTestData.mAccountData.put('End_Date__c', System.today()+100+'');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewSupportAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //create Profile Skill records
        List<sObject> lstSObj = new List<sObject>();
        sObj = new ProfileSkill();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillEscalation);
        lstSObj.add(sObj);
        UtilityTest.makeInsert(lstSObj);
    }

    @isTest
    static void testAllMethods(){
        Account acc = [SELECT Id FROM Account WHERE RecordtypeId =: SupportAccountRecType];

        EngagementService engService = new EngagementService();
        Engagement__c engagement = EngagementService.createSupportEscalation(acc.Id, 'Test Engagement', 'P2', 'Hot', 'Customer', 'Escalation', 'details', '');
        insert engagement;

        Test.startTest();
        EmailMessage emailMessage = new EmailMessage();
        emailMessage.Engagement__c = engagement.Id;
        emailMessage.RelatedToId = emailMessage.Engagement__c;    
        emailMessage.Incoming = true;        
        emailMessage.Status = '0';
        emailMessage.MessageDate = System.now();
        emailMessage.Status__c = 'New';
        emailMessage.Last_Modified_Date__c = System.now();        
        //emailMessage.Created_By__c = ;

        emailMessage.FromAddress = 'testest@informatica.com';
        emailMessage.ToAddress = Label.GCS_Escalation_Email_Address;
        emailMessage.Subject = 'Case Escalation';
        emailMessage.HtmlBody = 'Case Escalation';
        emailMessage.TextBody = 'Case Escalation';

        insert emailMessage;

        Test.stopTest();
    }

    @isTest
    static void testActiveEngagedEngagement(){

        List<Profile> employeeProfile = [SElECT Id, Name FROM Profile WHERE Name='System Administrator'];
            
        List<user> lstUser = new List<user>();
        UtilityTestData.mUserData.put('ProfileId',employeeProfile[0].id+'');
        UtilityTestData.mUserData.put('Username','mtest@m.t');
        UtilityTestData.mUserData.put('Email','mtest@m.t');
        UtilityTestData.mUserData.put('Alias','alias');
        UtilityTestData.mUserData.put('CommunityNickname','mtest');
        //UtilityTestData.mUserData.put('UserRoleId',ur.id+'');
        UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
        UtilityTestData.mUserData.put('LocaleSidKey','en_US');
        UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
        UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
        // UtilityTestData.mUserData.put('IsPortalEnabled','true');         
        UtilityTestData.mUserData.put('LastName','last');
        UtilityTestData.mUserData.put('CompanyName','TEST');
        UtilityTestData.mUserData.put('IsActive','true');
        //UtilityTestData.mUserData.put('UserType','PowerPartner');
        UtilityTestData.mUserData.put('ManagerEmployeeNumber__c','');
        sObject userSobj = new User();
        userSobj = UtilityTest.putFieldRecord(userSobj, UtilityTestData.mUserData); 
        List<User> escUsers = (List<User>) UtilityTest.makeInsert(new List<sObject>{userSobj});

        User adminUserObj = [select Id from User where Id =: userinfo.getUserId() limit 1];
        Group escalationQueue = new Group(Name='Escalation Managers', Type='Queue');
        insert escalationQueue;

        system.runAs(adminUserObj){
            QueueSObject gcsQueueObj = new QueueSObject(QueueID = escalationQueue.id, SObjectType = 'Engagement__c');
            insert gcsQueueObj;

            GroupMember member = new GroupMember();
            member.UserOrGroupId = escUsers[0].Id;
            member.GroupId = escalationQueue.Id;
            insert member;
        }

        Account acc = [SELECT Id FROM Account WHERE RecordtypeId =: SupportAccountRecType];

        EngagementService engService = new EngagementService();
        Engagement__c engagement = EngagementService.createSupportEscalation(acc.Id, 'Test Engagement', 'P2', 'Hot', 'Customer', 'Escalation', 'details', '');
        insert engagement;

        system.runAs( escUsers[0])
        {
            engagement.Status__c = 'Verified';
            update engagement;

            engagement.Exit_Criteria__c = 'Test';
            engagement.Source__c = 'Customer';
            engagement.Detail__c = 'Test';
            engagement.Status__c = 'Active Engaged';
            update engagement;
        }

        Test.startTest();
        EmailMessage emailMessage = new EmailMessage();
        emailMessage.Engagement__c = engagement.Id;
        emailMessage.RelatedToId = emailMessage.Engagement__c;    
        emailMessage.Incoming = true;        
        emailMessage.Status = '0';
        emailMessage.MessageDate = System.now();
        emailMessage.Status__c = 'New';
        emailMessage.Last_Modified_Date__c = System.now();        
        //emailMessage.Created_By__c = ;

        emailMessage.FromAddress = 'testest@informatica.com';
        emailMessage.ToAddress = Label.GCS_Escalation_Email_Address;
        emailMessage.Subject = 'Case Escalation';
        emailMessage.HtmlBody = 'Case Escalation';
        emailMessage.TextBody = 'Case Escalation';

        insert emailMessage;

        Test.stopTest();
    }
}