@isTest
public class NotificationPowerAutomateTest {

     
    @testSetup
    static void setupObjectTestData() {
        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        Id technicalCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
        
         Id riskRt = Schema.SObjectType.Risk_Issue__c.getRecordTypeInfosByName().get('Risk').getRecordTypeId();

        
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
        UtilityTest.makeInsert(new List<sObject>{sObj});

        //create a Case record
        sObj = new Case();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
        sObj.put('OwnerId', UserInfo.getUserId());
        sObj.put('Priority', 'P2');
        sObj.put('Support_Account__c', lNewSupportAccount[0].Id);
        UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Create plan
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan');
        UtilityTestData.mPlan.put('Is_Template__c','false');
        UtilityTestData.mPlan.put('Account__c',lNewSupportAccount[0].Id);
        UtilityTestData.mPlan.put('Status__c', 'Active');
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan}); 
        
        sObject risk = new Risk_Issue__c();
        UtilityTestData.mRiskIssue.put('Plan__c',lPlan[0].Id);
      	UtilityTestData.mRiskIssue.put('RecordTypeId',riskRt);
        UtilityTestData.mRiskIssue.put('Risk_Stage__c','Planning');
        
        risk = UtilityTest.putFieldRecord(risk, UtilityTestData.mRiskIssue);
        List<Risk_Issue__c> lRisk = (List<Risk_Issue__c>) UtilityTest.makeInsert(new List<sObject>{risk});
        
        sObject sObjOpportunity = new Opportunity();
        sObjOpportunity = UtilityTest.putFieldRecord(sObjOpportunity, UtilityTestData.mOpportunityData);
        sObjOpportunity.put('AccountId', lNewCustomerAccount[0].Id);
        sObjOpportunity.put('Substage__c', 'Selected');
        List<Opportunity> oppList = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObjOpportunity});
        
        UtilityTestData.mOpportunityTeamMemberData.put('OpportunityId', oppList[0].Id);
        
        sObj = new Notification_Criteria__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mNotificationCriteria);
        sObj.put('Evaluation_Trigger__c', 'Create/Edit');
        sObj.put('Notification_Type__c', 'Salesforce Bell - Desktop;Microsoft Teams Private message');
        sObj.put('Template_Name__c', 'Dummy');
        
        sObject sObj2 = new Notification_Criteria__c();
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mNotificationCriteria);
        sObj2.put('Evaluation_Trigger__c', 'Create/Edit');
        sObj2.put('Notification_Type__c', 'Salesforce Bell - Desktop;Microsoft Teams Private message');
        
        sObject sObj3 = new Notification_Criteria__c();
        sObj3.put('Object__c', 'Opportunity');
        sObj3.put('Active__c', true);
        sObj3.put('Condition__c','Substage__c   == \'Contract\'');
        sObj3.put('Evaluation_Trigger__c', 'Create/Edit');
        sObj3.put('Notification_Type__c', 'Salesforce Bell - Desktop;Microsoft Teams Private message');
        
        
        List<Notification_Criteria__c> lstNotifCriteria = (List<Notification_Criteria__c>)UtilityTest.makeInsert(new List<sObject>{sObj,sObj2,sObj3});
        
        sObj = new Notification_Criteria_Detail__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mNotificationCriteriaDetail);
        sObj.put('Notification_Criteria__c', lstNotifCriteria[0].Id);
        sObj2 = new Notification_Criteria_Detail__c();
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mNotificationCriteriaDetail);
        sObj2.put('Notification_Criteria__c', lstNotifCriteria[1].Id);
        
        sObj3 = new Notification_Criteria_Detail__c();
        sObj3.put('Field_Name__c','Substage__c');
        sObj3.put('Field_API_Name__c', 'Substage__c');
        sObj3.put('Operator__c', 'equals');
        sObj3.put('Value__c', 'Contract');
        sObj3.put('Notification_Criteria__c', lstNotifCriteria[2].Id);
        
        List<Notification_Criteria_Detail__c> lstNotifCriteriaDetail = (List<Notification_Criteria_Detail__c>)UtilityTest.makeInsert(new List<sObject>{sObj,sObj2,sObj3});

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
        
        
       Sobject sObj2a = new Notification_User__c();
        //sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mNotificationUser);
        sObj2a.put('Notification_Criteria__c', lstNotifCriteria[1].Id);
        //sObj2.put('Name', 'NU-2');
        sObj2a.put('User_Phone__c', '234234234');
        sObj2a.put('User_Email__c', 'xyz@abc.com');
        sObj2a.put('User_Type__c', 'Plan Team');
                
        Sobject sobj3a= new Notification_User__c();
        sobj3a.put('Notification_Criteria__c', lstNotifCriteria[1].Id);
        sobj3a.put('Related_Fields__c', 'OwnerId');
        sobj3a.put('User_Type__c','Related User');
        
        Sobject sobj4a= new Notification_User__c();
        sobj4a.put('Notification_Criteria__c', lstNotifCriteria[2].Id);  
        sobj4a.put('User_Phone__c', '234234234');
        sobj4a.put('Queue_Name__c', 'xyz');
        sobj4a.put('User_Type__c','Queue');
            
        sObj3 = new Notification_User__c();
        sObj3.put('Notification_Criteria__c', lstNotifCriteria[2].Id);
        sObj3.put('User_Phone__c', '234234234');
        sObj3.put('User_Email__c', 'xyz@abc.com');
        sObj3.put('User_Type__c', 'Opportunity Team');
        
        List<Notification_User__c> lNotiUsers = (List<Notification_User__c>)UtilityTest.makeInsert(new List<sObject>{sObj,sObj2,sObj2a, sobj3a, sObj3,sobj4a});
     
    }
    
    @isTest
    static void sendTest(){
        Case cse = [Select Id From Case Limit 1];
        Opportunity opp = [Select Id From Opportunity Limit 1];
		NotificationPowerAutomate npa = new NotificationPowerAutomate();
        npa.send();
        NotificationPowerAutomate.PARequest parReq = new NotificationPowerAutomate.PARequest();
                
        Test.startTest();
            cse.Priority = 'P1';
        	update cse;
        
            opp.Substage__c = 'Contract';
            update opp;

        Test.stopTest();
    }

}