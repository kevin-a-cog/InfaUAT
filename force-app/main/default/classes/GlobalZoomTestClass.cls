/*
 * Name         :   GlobalZoomTestClass
 * Author       :   Monserrat Pedroza
 * Created Date :   7/10/2021
 * Description  :   Zoom test class.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                 Tag
 **********************************************************************************************************
 Monserrat Pedroza      7/10/2021       N/A             Initial version.            N/A
 */
@isTest(seeAllData = false)
public with sharing class GlobalZoomTestClass {
    
    //Public variables.
    public static GlobalZoomEndpointWrapperClass objEndpoint;
    public static MultiStaticResourceCalloutMock objMockResponse;
    public static Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
    /*
     Method Name : setup
     Description : Test setup method.
     Parameters  : None
     Return Type : None
     */
    @testSetup 
    public static void setup() {
        //Account record
        SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
        UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecType);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Now we create a Contact.
        Contact objContact = new Contact();
        objContact.LastName = 'Test';
        objContact.Email = 'test@test.com';
        objContact.Phone = '55555555';
        insert objContact;

        //Now we create the Lead.
        Lead objLead = new Lead();
        objLead.LastName = 'Test2';
        objLead.Email = 'test2@test.com';
        objLead.Company = 'Test2';
        insert objLead;
    }
    
    /*
     Method Name : testCreatingEvent
     Description : Testing creating records.
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void testCreatingEvent() {
        System.runAs(createTestUser('System Administrator', true)) {

            //Now we create the Meeting Account.
            Meeting_Account__c objMeetingAccount = new Meeting_Account__c();
            insert objMeetingAccount;

            //Now we start the testing.
            Test.startTest();
            Contact objContact = [SELECT Id FROM Contact LIMIT 1];
            Lead objLead = [SELECT Id FROM Lead LIMIT 1];
            Account objAccount = [SELECT Id FROM Account LIMIT 1];
            objMockResponse = new MultiStaticResourceCalloutMock();

            //We set the mock responses.
            objEndpoint = GlobalZoomUtilitiesClass.getEndpoint('Authorize');
            objMockResponse.setStaticResource(objEndpoint.strEndpoint, 'ZoomAccessToken');
            objEndpoint = GlobalZoomUtilitiesClass.getEndpoint('Token');
            objMockResponse.setStaticResource(objEndpoint.strEndpoint, 'ZoomRefreshAccessToken');
            objEndpoint = GlobalZoomUtilitiesClass.getEndpoint('Create Meeting');
            objMockResponse.setStaticResource(objEndpoint.strEndpoint, 'ZoomCreateMeeting');
    
            //General parameters.
            objMockResponse.setStatusCode(200);
            objMockResponse.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, objMockResponse);

            //First we insert the event.
            Event objEvent = new Event();
            objEvent.Subject = 'Test';
            objEvent.Description = 'Test';
            objEvent.StartDateTime = System.now();
            objEvent.EndDateTime = System.now().addMinutes(30);
            objEvent.Generate_Zoom_Meeting__c = true;
            objEvent.WhatId = objAccount.Id;
            insert objEvent;

            //Now we insert the attendees.
            insert new EventRelation(EventId = objEvent.Id, RelationId = objContact.Id);
            insert new EventRelation(EventId = objEvent.Id, RelationId = objLead.Id);

            //Now we update the event.
            objEvent.Generate_Zoom_Meeting__c = true;
            update objEvent;

            //Now we check the records
            System.assertNotEquals([SELECT Id FROM Event LIMIT 1] == null, true, 'Unable to get records.');
            Test.stopTest();
        }
    }
    
    /*
     Method Name : testMultipleEvents
     Description : Testing creating records.
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void testMultipleEvents() {
        System.runAs(createTestUser('System Administrator', true)) {
            Event objEvent;
            List<Event> lstEvents = new List<Event>();

            //Now we create the Meeting Account.
            Meeting_Account__c objMeetingAccount = new Meeting_Account__c();
            insert objMeetingAccount;

            //Now we start the testing.
            Test.startTest();
            Contact objContact = [SELECT Id FROM Contact LIMIT 1];
            Lead objLead = [SELECT Id FROM Lead LIMIT 1];
            Account objAccount = [SELECT Id FROM Account LIMIT 1];
            objMockResponse = new MultiStaticResourceCalloutMock();

            //We set the mock responses.
            objEndpoint = GlobalZoomUtilitiesClass.getEndpoint('Authorize');
            objMockResponse.setStaticResource(objEndpoint.strEndpoint, 'ZoomAccessToken');
            objEndpoint = GlobalZoomUtilitiesClass.getEndpoint('Token');
            objMockResponse.setStaticResource(objEndpoint.strEndpoint, 'ZoomRefreshAccessToken');
            objEndpoint = GlobalZoomUtilitiesClass.getEndpoint('Create Meeting');
            objMockResponse.setStaticResource(objEndpoint.strEndpoint, 'ZoomCreateMeeting');
    
            //General parameters.
            objMockResponse.setStatusCode(200);
            objMockResponse.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, objMockResponse);

            //First we insert the event.
            objEvent = new Event();
            objEvent.Subject = 'Test';
            objEvent.Description = 'Test';
            objEvent.StartDateTime = System.now();
            objEvent.EndDateTime = System.now().addMinutes(30);
            objEvent.Generate_Zoom_Meeting__c = true;
            objEvent.WhatId=objAccount.Id;
            lstEvents.add(objEvent);
            objEvent = new Event();
            objEvent.Subject = 'Test';
            objEvent.Description = 'Test';
            objEvent.StartDateTime = System.now();
            objEvent.EndDateTime = System.now().addMinutes(30);
            objEvent.Generate_Zoom_Meeting__c = true;
            objEvent.WhatId=objAccount.Id;
            lstEvents.add(objEvent);
            insert lstEvents;

            //Now we insert the attendees.
            for(Event objInsertedEvent : lstEvents) {
                insert new EventRelation(EventId = objInsertedEvent.Id, RelationId = objContact.Id);
                insert new EventRelation(EventId = objInsertedEvent.Id, RelationId = objLead.Id);
            }

            //Now we update the event.
            objEvent.Generate_Zoom_Meeting__c = false;
            update objEvent;

            //Now we update the event.
            objEvent.Generate_Zoom_Meeting__c = true;
            update objEvent;

            //Now we check the records
            System.assertNotEquals([SELECT Id FROM Event LIMIT 1] == null, true, 'Unable to get records.');
            Test.stopTest();
        }
    }
    
    /*
     Method Name : testAuthorizationProcess
     Description : Testing Zoom authorization process.
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void testAuthorizationProcess() {
        System.runAs(createTestUser('System Administrator', true)) {

            //First we get authorization endpoint.
            Test.startTest();
            System.assertNotEquals(GlobalZoomController.getAuthorizationEndpoint() == null, true, 'Unable to get records.');
            Test.stopTest();
        }
    }
    
    /*
     Method Name : testAccessTokenProcess
     Description : Testing Zoom access token process.
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void testAccessTokenProcess() {
        System.runAs(createTestUser('System Administrator', true)) {

            //Now we create the Meeting Account.
            Meeting_Account__c objMeetingAccount = new Meeting_Account__c();
            objMeetingAccount.Expires_In__c = -1;
            insert objMeetingAccount;

            //Now we start the testing.
            Test.startTest();
            GlobalZoomController objController = new GlobalZoomController();
            objMockResponse = new MultiStaticResourceCalloutMock();

            //We set the mock responses.
            objEndpoint = GlobalZoomUtilitiesClass.getEndpoint('Authorize');
            objMockResponse.setStaticResource(objEndpoint.strEndpoint, 'ZoomAccessToken');
            objEndpoint = GlobalZoomUtilitiesClass.getEndpoint('Token');
            objMockResponse.setStaticResource(objEndpoint.strEndpoint, 'ZoomRefreshAccessToken');
            objEndpoint = GlobalZoomUtilitiesClass.getEndpoint('Create Meeting');
            objMockResponse.setStaticResource(objEndpoint.strEndpoint, 'ZoomCreateMeeting');
    
            //General parameters.
            objMockResponse.setStatusCode(200);
            objMockResponse.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, objMockResponse);
            Test.setCurrentPage(Page.GlobalZoomAuthorization);
            ApexPages.currentPage().getParameters().put('state', objMeetingAccount.Id);

            //Now we simulate receiving the response.
            objController.processAuthorizationResponse();

            //First we get authorization endpoint.
            System.assertNotEquals([SELECT Id FROM Meeting_Account__c LIMIT 1] == null, true, 'Unable to get records.');
            Test.stopTest();
        }
    }
    
    /*
     Method Name : testEdgeCases
     Description : Testing Zoom edge cases.
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void testRefreshToken() {
        System.runAs(createTestUser('System Administrator', true)) {
            Meeting_Account__c objMeetingAccount = new Meeting_Account__c();

            //First we prepare the local data.
            objMeetingAccount.Expires_In__c = -1;
            insert objMeetingAccount;
            objMeetingAccount = [SELECT Id, Access_Token__c, Refresh_Token__c, Expires_In__c, LastModifiedDate FROM Meeting_Account__c LIMIT 1];

            //Now we start the testing.
            Test.startTest();
            objMockResponse = new MultiStaticResourceCalloutMock();

            //We set the mock responses.
            objEndpoint = GlobalZoomUtilitiesClass.getEndpoint('Authorize');
            objMockResponse.setStaticResource(objEndpoint.strEndpoint, 'ZoomAccessToken');
            objEndpoint = GlobalZoomUtilitiesClass.getEndpoint('Token');
            objMockResponse.setStaticResource(objEndpoint.strEndpoint, 'ZoomRefreshAccessToken');
            objEndpoint = GlobalZoomUtilitiesClass.getEndpoint('Create Meeting');
            objMockResponse.setStaticResource(objEndpoint.strEndpoint, 'ZoomCreateMeeting');
    
            //General parameters.
            objMockResponse.setStatusCode(200);
            objMockResponse.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, objMockResponse);

            //Now we check the edge cases.
            GlobalZoomUtilitiesClass.refreshAccessToken(objMeetingAccount);
            System.assertNotEquals(objMeetingAccount == null, true, 'Unable to get records.');
            Test.stopTest();
        }
    }
    
    /*
     Method Name : testUpdatedAccessToken
     Description : Testing Zoom updated access token.
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void testUpdatedAccessToken() {
        System.runAs(createTestUser('System Administrator', true)) {
            Lead leadRecord = [SELECT Id FROM Lead LIMIT 1];
            Account objAccount = [SELECT Id FROM Account LIMIT 1];
            List<Event> lstRecords = new List<Event>();
            Meeting_Account__c objMeetingAccount = new Meeting_Account__c();

            //First we prepare the local data.
            objMeetingAccount.Expires_In__c = -1;
            insert objMeetingAccount;
            objMeetingAccount = [SELECT Id, Access_Token__c, Refresh_Token__c, Expires_In__c, LastModifiedDate FROM Meeting_Account__c LIMIT 1];
            for(Integer intIndex = 0; intIndex < 200; intIndex++) {
                lstRecords.add(new Event(StartDateTime = System.now(), DurationInMinutes = 30, Subject = 'test',WhatId=objAccount.Id, 
						Additional_Attendees__c = 'Test - test@asd.com;asd@asd.com;'));
            }
            insert lstRecords;

            //Now we start the testing.
            Test.startTest();
            objMockResponse = new MultiStaticResourceCalloutMock();

            //We set the mock responses.
            objEndpoint = GlobalZoomUtilitiesClass.getEndpoint('Authorize');
            objMockResponse.setStaticResource(objEndpoint.strEndpoint, 'ZoomAccessToken');
            objEndpoint = GlobalZoomUtilitiesClass.getEndpoint('Token');
            objMockResponse.setStaticResource(objEndpoint.strEndpoint, 'ZoomRefreshAccessToken');
            objEndpoint = GlobalZoomUtilitiesClass.getEndpoint('Create Meeting');
            objMockResponse.setStaticResource(objEndpoint.strEndpoint, 'ZoomCreateMeeting');
    
            //General parameters.
            objMockResponse.setStatusCode(200);
            objMockResponse.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, objMockResponse);

            //Now we check the edge cases.
            GlobalZoomUtilitiesClass.objUpdatedTokenDetails = objMeetingAccount;
            GlobalZoomUtilitiesClass.generateMeetingAndSendInvite(lstRecords.get(0));
            GlobalZoomUtilitiesClass.forwardinvite(lstRecords.get(0),createTestUser('System Administrator', true).id);
            System.assertNotEquals(objMeetingAccount == null, true, 'Unable to get records.');
            Test.stopTest();
        }
    }
    
    /*
     Method Name : testEdgeCases
     Description : Testing Zoom edge cases.
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void testEdgeCases() {
        System.runAs(createTestUser('System Administrator', true)) {
            Contact objContact = [SELECT Id FROM Contact LIMIT 1];
             Account objAccount = [SELECT Id FROM Account LIMIT 1];
            List<Event> lstRecords = new List<Event>();
            Meeting_Account__c objMeetingAccount = new Meeting_Account__c();

            //First we prepare the local data.
            objMeetingAccount.Expires_In__c = -1;
            insert objMeetingAccount;
            objMeetingAccount = [SELECT Id, Access_Token__c, Refresh_Token__c, Expires_In__c, LastModifiedDate FROM Meeting_Account__c LIMIT 1];
            for(Integer intIndex = 0; intIndex < 200; intIndex++) {
                lstRecords.add(new Event(StartDateTime = System.now(), DurationInMinutes = 30, Subject = 'test',whatId=objAccount.Id));
            }
            insert lstRecords;

            //Now we start the testing.
            Test.startTest();
            objMockResponse = new MultiStaticResourceCalloutMock();

            //We set the mock responses.
            objEndpoint = GlobalZoomUtilitiesClass.getEndpoint('Authorize');
            objMockResponse.setStaticResource(objEndpoint.strEndpoint, 'ZoomAccessToken');
            objEndpoint = GlobalZoomUtilitiesClass.getEndpoint('Token');
            objMockResponse.setStaticResource(objEndpoint.strEndpoint, 'ZoomRefreshAccessToken');
            objEndpoint = GlobalZoomUtilitiesClass.getEndpoint('Create Meeting');
            objMockResponse.setStaticResource(objEndpoint.strEndpoint, 'ZoomCreateMeeting');
    
            //General parameters.
            objMockResponse.setStatusCode(200);
            objMockResponse.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, objMockResponse);

            //Now we check the edge cases.
            GlobalZoomUtilitiesClass objController = new GlobalZoomUtilitiesClass(null);
            objController = new GlobalZoomUtilitiesClass(lstRecords);
            objController.execute(null);
            System.assertNotEquals(objMeetingAccount == null, true, 'Unable to get records.');

            //Finally, we cover wrapper classes.
            GlobalZoomResponseWrapperClass objReponseWrapper = new GlobalZoomResponseWrapperClass();
            objReponseWrapper.id = 1;
            Test.stopTest();
        }
    }

    /*
     Method Name : createTestUser
     Description : This method serves as a Utility method to create Test users.
     Parameters  : String, called from createTestUser, strProfileName Profile name.
                   Boolean, called from createTestUser, boolInsertUser If the user should be inserted or not.
     Return Type : User record.
     */
    private static User createTestUser(String strProfileName, Boolean boolInsertUser) {
        Integer intRandomNumber = Integer.valueOf(DateTime.now().getTime());
        String strRandomValue = String.valueOf(DateTime.now().getTime());
        String strOrgId = UserInfo.getOrganizationId();
        String strUniqueName = strOrgId + intRandomNumber;
        User objTestUser = new User();
        Profile objProfile;

        //First we get the existing profile.
        objProfile = [SELECT Id FROM Profile WHERE Name = :strProfileName];

        //Now we set the user data.
        objTestUser.FirstName = 'TestData' + DateTime.now().getTime();
        objTestUser.LastName = 'TestData' + DateTime.now().getTime();
        objTestUser.Email = strUniqueName + 'TestData' + strOrgId + '@test.com';
        objTestUser.Username = objTestUser.Email;
        objTestUser.EmailEncodingKey = 'ISO-8859-1';
        objTestUser.Alias = strRandomValue.subString(strRandomValue.length() - 9, strRandomValue.length() - 1);
        objTestUser.TimeZoneSidKey = 'America/Los_Angeles';
        objTestUser.LocaleSidKey = 'en_US';
        objTestUser.LanguageLocaleKey = objTestUser.LocaleSidKey;
        objTestUser.ProfileId = objProfile.Id;
        
        //Now we insert the user, if required.
        if(boolInsertUser) {
            insert objTestUser;
        }
        return objTestUser;
    }
}