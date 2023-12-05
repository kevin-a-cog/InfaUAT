/*
    @created by       : Pavithra V
    @created on       : 31-05-2021
    @Purpose          : I2RT-563 : Create Engagement on Negative Feedback
    @class            : GCSSurveyResponseHelperTest
    @JIRA             : I2RT-563
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************

 */ 
@isTest
public class GCSSurveyResponseHelperTest {
  
    @testSetup
    static void setupObjectTestData() {
        
        //create an Account record
        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        
        sObject sObj = new Account();
        UtilityTestData.mAccountData.put('RecordTypeId', SupportAccountRecType);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        
        sObject sObj1 = new Account();
        UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecType);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        UtilityTestData.mContactData.put('AccountId', lAccount[1].Id);
        sObj = new Contact(Email = 'testing1email@test.com');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});

        
    //create an Engagement record
        sObj = new Engagement__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEngagementEscalation);
        UtilityTest.makeInsert(new List<sObject>{sObj});
        
        RecordType rt1 = [select id,Name from RecordType where SobjectType='Case' and DeveloperName='Technical' Limit 1];

        //create a Case record
        sObj = new Case();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
        sObj.put('OwnerId', UserInfo.getUserId());
        sObj.put('ContactId', lContact[0].Id);
        sObj.put('AccountId', lAccount[1].Id);
        sObj.put('Support_Account__c', lAccount[0].Id);
        sObj.put('RecordTypeId', rt1.Id);
        UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //create Profile Skill records
        
        List<sObject> lstSObj = new List<sObject>();
        sObj = new ProfileSkill();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillEscalation);
        lstSObj.add(sObj);
        
        sObj = new ProfileSkill();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillProductPS);
        lstSObj.add(sObj);
        UtilityTest.makeInsert(lstSObj);
        
    }
  
    @isTest
    static void testAllMethods(){
    Test.startTest();
        Case cse = [Select Id,Support_Account__c, Engagement__c, Engagement__r.Status__c From Case Limit 1];
    Account supportAcc = [Select Id from Account where RecordType.Name = 'Support Account' Limit 1];
        Account acc = [Select Id from Account where RecordType.Name = 'Customer Account' LIMIT 1];
        Contact con = [Select Id from Contact Limit 1];
        Engagement__c eng = [Select Id from Engagement__c Limit 1];
        
        System.debug('acc : '+ acc.Id);
        
        supportAcc.ParentId = acc.Id;
        update supportAcc;
        
        eng.Status__c ='Not Started';
        update eng;
        
        //Create a survey response
    GCS_Survey_Response__c response = new GCS_Survey_Response__c();
        response.Satisfaction__c = 'Dissatisfied';
        response.Case__c = cse.Id;
        response.Support_Account__c = supportAcc.Id;
        response.Account__c = acc.Id;
        response.Owner_Manager__c = UserInfo.getUserId();
    insert response; 
        
        GCSSurveyResponseHelper.createEngagement(new List<Id>{response.Id});
        Id recid = GCSSurveyResponseHelper.getRecordTypeId('Support Escalation');
        Id userid = userinfo.getuserid();
        //GCSSurveyResponseHelper.create(recid,acc.Id,userid,'test','P1','Hot','Customer','','test6');
        Test.stopTest();
    }
    
     
  
}