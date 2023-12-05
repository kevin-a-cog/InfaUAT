/*
    @created by       : balajip
    @created on       : 11/10/2021
    @Purpose          : Test class for FeedItem Trigger, handler and helper classes
    @Testclass        : 
    @JIRA             : 
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************

 */
@isTest
public with sharing class FeedItemTriggerTest {
    
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
        //Create Related Feed Item Record
        FeedItem feedItem = new FeedItem(ParentId = engagement.Id, Body = 'Test Body');
        insert feedItem;
        Test.stopTest();
    }
    
    @isTest
    static void testEstOutFeedWithInternalVisibility(){
        
        /*Account acc = IPUE_TestUtils.createAccount(true);
        Opportunity opp=IPUE_TestUtils.createOpportunity(true,acc);
        
        Estimation_Summary__c testSummary = IPUE_TestUtils.createEstimationSummary(false, opp.Id);
        testSummary.Account__c = opp.AccountId;
        insert testSummary;*/

		Estimation_Output__c  estOut= IPUE_TestUtils.createEstimationOutput(true,'Test',null,12); 
        //Create Related Feed Item Record
        /*FeedItem feed1= new FeedItem(ParentId = testSummary.Id, Body = 'Test Body');
        insert feed1;*/
        FeedItem feed= new FeedItem(ParentId = estOut.Id, Body = 'Test Body');
       	insert feed;
        /*FeedItem feed3= new FeedItem(ParentId = testSummary.Id, Body = 'Test Body',Visibility='AllUsers');
       	insert feed3;
        FeedItem feed4= new FeedItem(ParentId = estOut.Id, Body = 'Test Body',Visibility='AllUsers');
       	insert feed4;*/
    }
    
    @isTest
    static void testEstOutFeedWithPublicVisibility(){
		Estimation_Output__c  estOut= IPUE_TestUtils.createEstimationOutput(true,'Test',null,12); 
        //Create Related Feed Item Record
        FeedItem feed= new FeedItem(ParentId = estOut.Id, Body = 'Test Body',Visibility='AllUsers');
       	insert feed;
        delete feed;
    }
    
    @isTest
    static void testEstSummFeedWithInternalVisibility(){
        
        Account acc = IPUE_TestUtils.createAccount(true);
        Opportunity opp=IPUE_TestUtils.createOpportunity(true,acc);
        
        Estimation_Summary__c testSummary = IPUE_TestUtils.createEstimationSummary(false, opp.Id);
        testSummary.Account__c = opp.AccountId;
        insert testSummary;
        
        //Create Related Feed Item Record
        FeedItem feed= new FeedItem(ParentId = testSummary.Id, Body = 'Test Body');
       	insert feed;

    }
    
    @isTest
    static void testEstSummFeedWithPublicVisibility(){
		Account acc = IPUE_TestUtils.createAccount(true);
        Opportunity opp=IPUE_TestUtils.createOpportunity(true,acc);
        
        Estimation_Summary__c testSummary = IPUE_TestUtils.createEstimationSummary(false, opp.Id);
        testSummary.Account__c = opp.AccountId;
        insert testSummary;
        
        //Create Related Feed Item Record
        FeedItem feed= new FeedItem(ParentId = testSummary.Id, Body = 'Test Body',Visibility='AllUsers');
       	insert feed;
        delete feed;
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
        //Create Related Feed Item Record
        FeedItem feedItem = new FeedItem(ParentId = engagement.Id, Body = 'Test Body');
        insert feedItem;
        Test.stopTest();
    }
}