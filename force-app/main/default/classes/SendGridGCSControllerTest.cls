/*
Class:          SendGridGCSControllerTest
@Author:        Pavithra V
@Created Date:  15-Mar-2021
@Description:   Test class for SendGridEmailService class for sending emails.

    Change History
*************************************************************************************************************************************
    ModifiedBy               Date        Requested By        Description                                         Tag
************************************************************************************************************************************
*/
@isTest
public class SendGridGCSControllerTest {
    
    @testSetup
    static void setupObjectTestData() {
        
        sObject sObj;
        sObject sObj1;
        
        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        Id technicalCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
        
        String AskAnExpert  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Ask_An_Expert').getRecordTypeId();
        
        List<SendGrid_Templates__mdt> sendGridMetadata = [Select Id,Template_Id__c,DeveloperName from SendGrid_Templates__mdt];
        
        //create an TimeZone record
        sObj = new TimeZone__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mTimeZone);
        List<TimeZone__c> lTimezone = (List<TimeZone__c>) UtilityTest.makeInsert(new List<sObject>{sObj});   
        
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;
        
        sObj = new Account();
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

        //Create Contact record
        RecordType rt = [select id,Name from RecordType where SobjectType='Contact' and DeveloperName='Customer_Contact' Limit 1];
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lNewCustomerAccount[0].Id);//Email
        UtilityTestData.mContactData.put('Email','test@test.com');
        UtilityTestData.mContactData.put('pse__Salesforce_User__c',UserInfo.getUserId());
        UtilityTestData.mContactData.put('RecordTypeId',rt.Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        RecordType rt1 = [select id,Name from RecordType where SobjectType='Case' and DeveloperName='Technical' Limit 1];
                
        //create a Case record
        sObj = new Case();
        sObj.put('OwnerId', UserInfo.getUserId());
        sObj.put('Success_Offering__c', 'Basic Success');
        sObj.put('Priority', 'P1');
        sObj.put('Forecast_product__c', 'Active VOS');
        sObj.put('Version__c', '10.1');
        sObj.put('Component__c', 'Documentation');
        sObj.put('Case_Support_Add_On__c', 'XS');
        sObj.put('IR_Completion_Date__c', null); 
        sObj.put('ContactId', lContact[0].Id); 
        sObj.put('Status', 'Scheduled');
        sObj.put('CreatedDate', system.now());
        sObj.put('RecordTypeId',AskAnExpert);
        sObj.put('AccountId', lNewCustomerAccount[0].Id);
        sObj.put('Support_Account__c', lNewSupportAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
        List<Case> lCase = (List<Case>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Create a case Contact record
        sObj = new Case_Contact__c();        
       	sObj.put('Case__c', lCase[0].Id);
        sObj.put('Contact__c', lContact[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCaseContact);
        UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Create a case comment record
        sObj = new Case_Comment__c();
        sObj.put('Visibility__c', 'External');
        sObj.put('Email_Sent__c', false);
        sObj.put('Case__c', lCase[0].Id);
        sObj.put('Inbound__c', false);
        sObj.put('Importance__c', true);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCaseComment);
        UtilityTest.makeInsert(new List<sObject>{sObj});
    }
    
    public static testmethod void testSendGridGCSController(){
        
        List<Case> lCase = [Select Id,IR_Completion_Date__c,Priority,Case_Support_Add_On__c From Case Limit 1];
        Case_Comment__c casecomm = [Select Id,Importance__c From Case_Comment__c Limit 1]; 
        Case_Contact__c ccon = [Select Id,Case__r.casenumber,Contact__r.Name From Case_Contact__c Limit 1];
        
        Test.startTest();
        Map<String, String> emaillist = new Map<String, String>();
        emaillist.put('test@test.com','Test Contact');
        
        SendGridGCSController.SendGridrequestwrapper sgs = new SendGridGCSController.SendGridrequestwrapper();
        sgs.casenum = ccon.Case__r.casenumber;
        sgs.conname = ccon.Contact__r.Name;
        sgs.priority = casecomm.Importance__c;
        sgs.ccomentid = casecomm.Id;
        sgs.emaillist = emaillist;
        sgs.usecase = 'GCS Initial Response';
        
        Test.setMock(HTTPCalloutMock.class, new SendGridEmailServiceMock());
        // Performing the API callout        
        SendGridGCSController.configureEmail(JSON.serialize(sgs));
        
        Test.stopTest();
    }
    
    
    public static testmethod void testSendGridResponse(){
        List<Case> lCase = [Select Id,IR_Completion_Date__c,Priority,Case_Support_Add_On__c From Case Limit 1];
        Case_Comment__c casecomm = [Select Id,Importance__c From Case_Comment__c Limit 1]; 
        Case_Contact__c ccon = [Select Id,Case__r.casenumber,Contact__r.Name From Case_Contact__c Limit 1];
        
        //Instantiate the Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/SendgridResponse'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('[{"ccid":'+'"'+String.valueOf(casecomm.Id)+'","event":"click","email":"test@test.com","ip":"test","sg_content_type":"","sg_event_id":"test","sg_message_id":"","sg_template_name":"d-fc28c4bf07ad49f68534627eae7cd878","timestamp":"","useragent":""}]');
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        SendgridResponse.doPost();
        Test.stopTest();
    }
}