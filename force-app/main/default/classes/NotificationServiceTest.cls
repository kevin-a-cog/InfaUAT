/*
    @created by       : balajip
    @created on       : 02/15/2020
    @Purpose          : Test class for CaseService
    @Testclass        : 
    @JIRA             : 
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************

 */
@isTest
public with sharing class NotificationServiceTest {
    
    @testSetup
    static void setupObjectTestData() {
        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        Id technicalCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
		
		//List<User> userList = UtilityTest.createUsersforPRM();        
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;
        
        SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
        UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecType);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
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
        
        //create an Engagement record
        sObj = new Engagement__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEngagementEscalation);
        List<Engagement__c> lNewEngagement = (List<Engagement__c>)UtilityTest.makeInsert(new List<sObject>{sObj});

        //create a Case record
        sObj = new Case();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
        sObj.put('OwnerId', UserInfo.getUserId());
        sObj.put('Priority', 'P2');
        sObj.put('Support_Account__c', lNewSupportAccount[0].Id);
        sObj.put('Engagement__c', lNewEngagement[0].Id);
        UtilityTest.makeInsert(new List<sObject>{sObj});

        sObj = new Case();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
        sObj.put('OwnerId', UserInfo.getUserId());
        sObj.put('Priority', 'P2');
        sObj.put('Support_Account__c', lNewSupportAccount[0].Id);
        sObj.put('Engagement__c', lNewEngagement[0].Id);
        UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Create plan
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan');
        UtilityTestData.mPlan.put('Is_Template__c','false');
        UtilityTestData.mPlan.put('Account__c',lNewSupportAccount[0].Id);
        UtilityTestData.mPlan.put('Status__c', 'Active'); 
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan}); 
        
        insert new Plan_Team__c(User__c=UserInfo.getUserId(), Plan__c=lPlan[0].Id,Role__c='Account Manager',Primary__c=true);
        
        Plan_Comment__c planComment = new Plan_Comment__c(Plan__c=lPlan[0].Id);
        planComment.Comment__c='commentValue';
        planComment.Type__c=CSMUtilities.TYPE_INTERNAL;
        planComment.Status__c=CSMUtilities.STATUS_SUBMITTED;
        planComment.Sub_Type__c='Auto Pilot';
        planComment.Is_Automated__c=true;
        insert planComment;
        
        Test.startTest();
        
        sObject sObjOpportunity = new Opportunity();
        sObjOpportunity = UtilityTest.putFieldRecord(sObjOpportunity, UtilityTestData.mOpportunityData);
        sObjOpportunity.put('AccountId', lNewCustomerAccount[0].Id);
        sObjOpportunity.put('Substage__c', 'Selected');
        List<Opportunity> oppList = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObjOpportunity});
        UtilityTestData.mOpportunityTeamMemberData.put('OpportunityId', oppList[0].Id);
        UtilityTestData.mOpportunityTeamMemberData.put('UserId',Userinfo.getUserId());
        sObjOpportunity = new OpportunityTeamMember ();
        sObjOpportunity = UtilityTest.putFieldRecord(sObjOpportunity, UtilityTestData.mOpportunityTeamMemberData);
        List<OpportunityTeamMember> lOpportunityTeamMembers = (List<OpportunityTeamMember>) UtilityTest.makeInsert(new List<sObject>{sObjOpportunity}); 
        
        sObj = new Notification_Criteria__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mNotificationCriteria);
        sObj.put('Evaluation_Trigger__c', 'Create/Edit');
        sObj.put('Notification_Type__c', 'Salesforce Bell - Desktop;Salesforce Chatter Post;Microsoft Teams Private message');
        sObj.put('Template_Name__c', 'Dummy');
        
        sObject sObj2 = new Notification_Criteria__c();
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mNotificationCriteria);
        sObj2.put('Evaluation_Trigger__c', 'Create/Edit');
        sObj2.put('Notification_Type__c', 'Salesforce Bell - Desktop;Salesforce Chatter Post;Microsoft Teams Private message');
        
        sObject sObj5 = new Notification_Criteria__c();
        sObj5 = UtilityTest.putFieldRecord(sObj5, UtilityTestData.mNotificationCriteria);
        sObj5.put('Evaluation_Trigger__c', 'Create/Edit');
        sObj5.put('Notification_Type__c', 'Salesforce Bell - Desktop;Microsoft Teams Private message');
        
        sObject sObj7 = new Notification_Criteria__c();
        sObj7.put('Object__c', 'Opportunity');
        sObj7.put('Active__c', true);
        sObj7.put('Condition__c','Substage__c   == \'Contract\'');
        sObj7.put('Evaluation_Trigger__c', 'Create/Edit');
        sObj7.put('Notification_Type__c', 'Salesforce Bell - Desktop;Microsoft Teams Private message');
        
        sObject sObj8 = new Notification_Criteria__c();
        sObj8.put('Object__c', 'Plan__c');
        sObj8.put('Active__c', true);
        sObj8.put('Condition__c','Current_State_of_plan__c   == \'Configuration\'');
        sObj8.put('Evaluation_Trigger__c', 'Create/Edit');
        sObj8.put('Notification_Type__c', 'Salesforce Bell - Desktop;Microsoft Teams Private message');
        
        sObject sObj9 = new Notification_Criteria__c();
        sObj9.put('Object__c', 'Plan_Comment__c');
        sObj9.put('Active__c', true);
        sObj9.put('Condition__c','Status__c   == \'Submitted\'');
        sObj9.put('Evaluation_Trigger__c', 'Create/Edit');
        sObj9.put('Notification_Type__c', 'Salesforce Bell - Desktop;Microsoft Teams Private message');
        
        List<Notification_Criteria__c> lstNotifCriteria = (List<Notification_Criteria__c>)UtilityTest.makeInsert(new List<sObject>{sObj,sObj2,sObj5,sObj7,sObj8,sObj9});
        
        sObj = new Notification_Criteria_Detail__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mNotificationCriteriaDetail);
        sObj.put('Notification_Criteria__c', lstNotifCriteria[0].Id);
        sObj2 = new Notification_Criteria_Detail__c();
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mNotificationCriteriaDetail);
        sObj2.put('Notification_Criteria__c', lstNotifCriteria[1].Id);
        sObj5 = new Notification_Criteria_Detail__c();
        sObj5 = UtilityTest.putFieldRecord(sObj5, UtilityTestData.mNotificationCriteriaDetail);
        sObj5.put('Notification_Criteria__c', lstNotifCriteria[2].Id);
        
        sObj7 = new Notification_Criteria_Detail__c();
        sObj7.put('Field_Name__c','Substage__c');
        sObj7.put('Field_API_Name__c', 'Substage__c');
        sObj7.put('Operator__c', 'equals');
        sObj7.put('Value__c', 'Contract');
        sObj7.put('Notification_Criteria__c', lstNotifCriteria[3].Id);
        
        sObj8 = new Notification_Criteria_Detail__c();
        sObj8.put('Field_Name__c','Current_State_of_plan__c');
        sObj8.put('Field_API_Name__c', 'Current_State_of_plan__c');
        sObj8.put('Operator__c', 'equals');
        sObj8.put('Value__c', 'CSM');
        sObj8.put('Notification_Criteria__c', lstNotifCriteria[4].Id);
        
        sObj9 = new Notification_Criteria_Detail__c();
        sObj9.put('Field_Name__c','Status__c');
        sObj9.put('Field_API_Name__c', 'Status__c');
        sObj9.put('Operator__c', 'equals');
        sObj9.put('Value__c', 'Submitted');
        sObj9.put('Notification_Criteria__c', lstNotifCriteria[5].Id);
        
        List<Notification_Criteria_Detail__c> lstNotifCriteriaDetail = (List<Notification_Criteria_Detail__c>)UtilityTest.makeInsert(new List<sObject>{sObj,sObj2,sObj5,sObj7,sObj8,sObj9});

        sObj = new Notification_User__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mNotificationUser);
        sObj.put('Notification_Criteria__c', lstNotifCriteria[0].Id);
        sObj.put('User__c', UserInfo.getUserId()+'');
        sObj.put('User_Type__c', 'Case Team');

        sObj2 = new Notification_User__c();
        //sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mNotificationUser);
        sObj2.put('Notification_Criteria__c', lstNotifCriteria[1].Id);
        //sObj2.put('Name', 'NU-2');
        sObj2.put('User_Phone__c', '234234234');
        sObj2.put('User_Email__c', 'xyz@abc.com');
        sObj2.put('User_Type__c', 'Account Team');
        sObj2.put('Account_Case_Fields__c', 'Support_Account__c');
        
        sObject sObj3 = new Notification_User__c();
        sObj3.put('Notification_Criteria__c', lstNotifCriteria[0].Id);
        sObj3.put('User__c', UserInfo.getUserId()+'');
        sObj3.put('User_Type__c', 'User');
        sObj3.put('Active__c', True);
        
        sObject sObj4 = new Notification_User__c();
        sObj4.put('Notification_Criteria__c', lstNotifCriteria[0].Id);
        sObj4.put('Related_Fields__c', 'Engagement__r.OwnerId');
        sObj4.put('User_Type__c', 'Related User');
        sObj4.put('Active__c', True);        
        
        
        Sobject sObj6 = new Notification_User__c();
        sObj6.put('Notification_Criteria__c', lstNotifCriteria[4].Id);
        sObj6.put('User_Phone__c', '234234234');
        sObj6.put('User_Email__c', 'xyz@abc.com');
        sObj6.put('User_Type__c', 'Plan Team');
        sObj6.put('Active__c', True);  
        sObj6.put('Team_Member_Role__c', 'Account Manager,Account Manager (Secondary)');
        
        sObj7 = new Notification_User__c();
        sObj7.put('Notification_Criteria__c', lstNotifCriteria[3].Id);
        sObj7.put('User_Phone__c', '234234234');
        sObj7.put('User_Email__c', 'xyz@abc.com');
        sObj7.put('User_Type__c', 'Opportunity Team');
        sObj7.put('Active__c', True);  
        sObj7.put('Team_Member_Role__c', 'Account Manager,Account Manager (Secondary)');
        
        Sobject sObj10 = new Notification_User__c();
        sObj10.put('Notification_Criteria__c', lstNotifCriteria[5].Id);
        sObj10.put('User_Phone__c', '234234234');
        sObj10.put('User_Email__c', 'xyz@abc.com');
        sObj10.put('User_Type__c', 'Plan Team');
        sObj10.put('Active__c', True);  
        sObj10.put('Team_Member_Role__c', 'Account Manager,Account Manager (Secondary)');

        List<Notification_User__c> lNotiUsers = (List<Notification_User__c>)UtilityTest.makeInsert(new List<sObject>{sObj,sObj2,sObj3,sObj4,sObj7,sObj6,sObj10});
        Test.stopTest();
    }
    
    @isTest
    static void testAllMethods(){
        List<Case> lstCase = [Select Id, Priority,Case_Owner_Manager__r.Name From Case];
        Opportunity opp = [Select Id From Opportunity Limit 1];
        Plan__c plan = [Select Id,Current_State_of_plan__c  From Plan__c Limit 1];
        Plan_Comment__c planComment = [Select Id,Status__c  From Plan_Comment__c Limit 1];

        Test.startTest();
        lstCase[0].Priority = 'P1';
        lstCase[1].Priority = 'P1';
        update lstCase;
        
        opp.Substage__c = 'Contract';
        update opp;
        
        plan.Current_State_of_plan__c  = 'Configuration';
        update plan;
        
        planComment.Status__c  = 'Submitted';
        update planComment;
        
        Test.stopTest();
    }
}