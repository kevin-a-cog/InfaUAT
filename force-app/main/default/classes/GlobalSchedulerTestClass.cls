/*
 * Name         :   GlobalSchedulerTestClass
 * Author       :   Monserrat Pedroza
 * Created Date :   7/27/2021
 * Description  :   Zoom test class.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                         Tag
 **********************************************************************************************************
 Monserrat Pedroza      7/27/2021       N/A             Initial version.                    N/A..
 Shashikanth            10/25/2023      I2RT-7702       Added getContactTimezone            <T01>
                                                        test method
 */
@isTest(seeAllData = false)
public with sharing class GlobalSchedulerTestClass {

    //Private Variables
    //<T01>
    private static List<Schema.SObjectType> UOW_SOBJECTS = 
        new Schema.SObjectType[] {
                Timezone__c.SObjectType, 
                User.SObjectType, 
                Contact.SObjectType 
                };
    //</T01>                                                                                        
    
    //Public variables.
    public static GlobalZoomEndpointWrapperClass objEndpoint;
    public static MultiStaticResourceCalloutMock objMockResponse;

    /*
     Method Name : setup
     Description : Test setup method.
     Parameters  : None
     Return Type : None
     */
    @testSetup 
    public static void setup() {

        //Now we create a Account.
        Account objAccount = new Account();
        objAccount.Name = 'Test';
        objAccount.BillingCountry = 'Test';
        objAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        insert objAccount;

        Account objCustomerAccount = new Account();
        objCustomerAccount.Name = 'Test';
        objCustomerAccount.BillingCountry = 'Test';
        objCustomerAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        insert objCustomerAccount;

        //Now we create a Contact.
        Contact objContact = new Contact();
        objContact.LastName = 'Test';
        objContact.Email = 'test@test.com';
        objContact.Phone = '55555555';
        objContact.AccountId = objCustomerAccount.Id;
        insert objContact;

        //Now we create Timezones.
        List<TimeZone__c> lstTimezones = Test.loadData(TimeZone__c.sObjectType, 'Timezones');
        for(TimeZone__c objTimezone : lstTimezones) {
            objTimezone.Id = null;
        }
        insert lstTimezones;

        //Now we create a Case.
        Case objCase = new Case();
        objCase.Subject = 'Test';
        objCase.ContactId = objContact.Id;
        objCase.Support_Account__c = objAccount.Id;
        objCase.Case_Timezone__c = lstTimezones[0].Id;
        insert objCase;

        //We also create Case Contacts.
        Case_Contact__c objCaseContact = new Case_Contact__c();
        objCaseContact.Case__c = objCase.Id;
        objCaseContact.Contact__c = objContact.Id;
        insert objCaseContact;

        //Now we create a Plan.
        Plan__c objPlan = new Plan__c();
        objPlan.Name = 'TestNew';
        objPlan.Is_Template__c = false;
        objPlan.Account__c = objAccount.Id;
        objPlan.Plan_Timezone__c = lstTimezones[0].Id;
        objPlan.Plan_Operational_Model__c = 'Pooled CSM';
        insert objPlan;

        //Now we create Plan Contacts.
        Plan_Contact__c objPlanContact = new Plan_Contact__c();
        objPlanContact.Plan__c = objPlan.Id;
        objPlanContact.Contact__c = objContact.Id;
        insert objPlanContact;
        
        //Create site record
        /*site objSiteRecord = new site();
        objSiteRecord.UrlPathPrefix = 'success';
        insert objSiteRecord;
        */
    }
    
    /*
     Method Name : testCreatingScheduleAndEvent
     Description : Testing creating records.
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void testCreatingScheduleAndEvent() {

        //We create an extra user, to include it as a team member.
        User objExtraUser = [Select Id from User where Id =: userinfo.getUserId()];

        //Now we run the test.
        System.runAs(createTestUser('System Administrator', true)) {
            Event objEvent;
            Time_Slot__c objSlot = new Time_Slot__c();
            Attendee__c objAttende = new Attendee__c();
            Appointment_Request__c objAppointment;
            Contact objContact = [SELECT Id FROM Contact LIMIT 1];
            Case objCase = [SELECT Id FROM Case LIMIT 1];
            CaseTeamRole objCaseTeamRole = [SELECT Id FROM CaseTeamRole LIMIT 1];
            GlobalSchedulerWrapperClass objRequest;
            Meeting_Account__c objMeetingAccount = new Meeting_Account__c();

            //We set initial parameters.
            objMockResponse = new MultiStaticResourceCalloutMock();
            objSlot.Start_Time__c = System.now();
            objSlot.Duration__c = 60;
            objAttende.User__c = UserInfo.getUserId();

            //Now we insert the Case Team Members.
            Case_Team__c objCaseTeamMember = new Case_Team__c();
            objCaseTeamMember.Case__c = objCase.Id;
            objCaseTeamMember.User__c = UserInfo.getUserId();
            insert objCaseTeamMember;

            //Now we insert the extra Case Team Member.
            objCaseTeamMember = new Case_Team__c();
            objCaseTeamMember.Case__c = objCase.Id;
            objCaseTeamMember.User__c = objExtraUser.Id;
            insert objCaseTeamMember;

            //Now we insert a Meeting Account.
            objMeetingAccount.Access_Token__c = 'test';
            objMeetingAccount.Expires_In__c = 20;
            objMeetingAccount.Refresh_Token__c = 'test';
            objMeetingAccount.Scope__c = 'test';
            objMeetingAccount.Token_Type__c = 'test';
            insert objMeetingAccount;

            //We now update the owner of the Case.
            objCase.OwnerId = UserInfo.getUserId();
            update objCase;

            //Now we create an event.
            objEvent = new Event();
            objEvent.StartDateTime = System.now();
            objEvent.DurationInMinutes = 60;
            objEvent.WhatId = objCase.Id;
            insert objEvent;

            //Now we start the testing.
            Test.startTest();

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

            //First we return the Time Zone lists.
            System.assertNotEquals(GlobalSchedulerController.getTimeZoneValues() == null, true, 'Unable to get Time Zones.');

            //Now we check if the mode is Read-only.
            System.assertNotEquals(GlobalSchedulerController.getIsReadOnly(objCase.Id) == true, true, 'Read only scenario');

            //Now we get the involved users.
            objRequest = GlobalSchedulerController.getRelatedUsers(objCase.Id);

            //We also return the current user's name.
            System.assertNotEquals(GlobalSchedulerController.getUserName(UserInfo.getUserId()) == null, true, 'Invalid user.');

            //Now we get the available slots.
            objRequest.datStart = Date.today();
            objRequest.datStop = Date.today().addDays(1);
            objRequest.lstUsers = new List<String> { UserInfo.getUserId() };
            objRequest.strStartTime = '00:00:00';
            objRequest.strStopTime = '23:59:59';
            objRequest.intDefaultDurationMinutes = 60;
            objRequest.intDefaultGapMinutes = 15;
            System.assertNotEquals(GlobalSchedulerController.getAvailableSlots(objRequest) == null, true, 'Unable to fetch available slots.');

            //Now we create a schedule.
            objRequest.lstContacts = new List<String>();
            objRequest.lstContacts.add(objContact.Id);
            objRequest.lstAttendees = new List<Attendee__c>();
            objRequest.lstAttendees.add(objAttende);
            objRequest.objAppointmentRequest = new Appointment_Request__c();
            objRequest.lstSlots = new List<Time_Slot__c>();
            objRequest.lstSlots.add(objSlot);
            objRequest.strRecordId = objCase.Id;
            System.assertNotEquals(GlobalSchedulerController.getAppointmentRequestCreated(objRequest) == null, true, 'Unable to create schedule.');

            //Now we get the Appointment data.
            objAppointment = [SELECT Id FROM Appointment_Request__c LIMIT 1];
            System.assertNotEquals(GlobalSchedulerController.getAppointmentRequestData(objAppointment.Id,'IST') == null, true, 'Unable to get Appointment data.');

            //Now we create an Event.
            objRequest.boolIsReadOnly = true;
            objRequest.objSlot = objSlot;
            System.assertNotEquals(GlobalSchedulerController.getEventScheduled(objRequest) == null, true, 'Unable to create Event.');
            objRequest.strRecordId = [SELECT Id FROM Appointment_Request__c LIMIT 1].Id;
            System.assertNotEquals(GlobalSchedulerController.getEventScheduled(objRequest) == null, true, 'Unable to create Event.');

            //We get the event details of what we just created.
            System.assertNotEquals(GlobalSchedulerController.getEventDetails([SELECT Id FROM Event LIMIT 1].Id) == null, true, 'Unable to get Event details.');

            //Now, we get the Email templates.
            objRequest.strRecordId = [SELECT Id FROM Event LIMIT 1].Id;
            System.assertNotEquals(GlobalSchedulerController.getEmailTemplate(objRequest) == null, true, 'Unable to fetch Event template.');
            objRequest.strRecordId = [SELECT Id FROM Case_Comment__c LIMIT 1].Id;
            System.assertNotEquals(GlobalSchedulerController.getEmailTemplate(objRequest) == null, true, 'Unable to fetch Appointment template.');
            objRequest.strRecordId = null;
            objRequest.strSlotsURL = 'Test';
            System.assertNotEquals(GlobalSchedulerController.getEmailTemplate(objRequest) == null, true, 'Unable to fetch Appointment template.');

            //Now we check if the user should be able to use the scheduler.
            System.assertNotEquals(GlobalSchedulerController.getRecordOwnerValidated(objCase.Id), false, 'User cannot use scheduler.');

            //Now we check if the mode now can be Read-only.
            System.assertNotEquals(GlobalSchedulerController.getIsReadOnly([SELECT Id FROM Appointment_Request__c LIMIT 1].Id) == false, true, 'None Read only scenario');

            //Now we check a case without timezone.
            objCase.Case_Timezone__c = null;
            update objCase;
            objRequest.strRecordId = [SELECT Id FROM Event LIMIT 1].Id;
            System.assertNotEquals(GlobalSchedulerController.getEmailTemplate(objRequest) == null, true, 'Unable to fetch Event template.');

            //We stop the test.
            Test.stopTest();
        }
    }
    
    /*
     Method Name : testCreatingScheduleAndEventPlan
     Description : Testing creating records from Plan.
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void testCreatingScheduleAndEventPlan() {

        //We create an extra user, to include it as a team member.
        User objExtraUser = [Select Id from User where Id =: userinfo.getUserId()];

        //Now we run the test.
        System.runAs(createTestUser('System Administrator', true)) {
            Event objEvent;
            Time_Slot__c objSlot = new Time_Slot__c();
            Attendee__c objAttende = new Attendee__c();
            Appointment_Request__c objAppointment;
            Contact objContact = [SELECT Id FROM Contact LIMIT 1];
            Plan__c objPlan = [SELECT Id FROM Plan__c LIMIT 1];
            GlobalSchedulerWrapperClass objRequest;
            Meeting_Account__c objMeetingAccount = new Meeting_Account__c();

            //We set initial parameters.
            objMockResponse = new MultiStaticResourceCalloutMock();
            objSlot.Start_Time__c = System.now();
            objSlot.Duration__c = 60;
            objAttende.User__c = UserInfo.getUserId();

            //Now we insert the Plan Team Members.
            Plan_Team__c objPlanTeamMember = new Plan_Team__c();
            objPlanTeamMember.Plan__c = objPlan.Id;
            objPlanTeamMember.User__c = UserInfo.getUserId();
            objPlanTeamMember.Primary__c = true;
            objPlanTeamMember.Role__c = 'test';
            insert objPlanTeamMember;

            //Now we insert the extra Plan Team Member.
            objPlanTeamMember = new Plan_Team__c();
            objPlanTeamMember.Plan__c = objPlan.Id;
            objPlanTeamMember.User__c = objExtraUser.Id;
            objPlanTeamMember.Primary__c = false;
            objPlanTeamMember.Role__c = 'test';
            insert objPlanTeamMember;

            //Now we insert a Meeting Account.
            objMeetingAccount.Access_Token__c = 'test';
            objMeetingAccount.Expires_In__c = 20;
            objMeetingAccount.Refresh_Token__c = 'test';
            objMeetingAccount.Scope__c = 'test';
            objMeetingAccount.Token_Type__c = 'test';
            insert objMeetingAccount;

            //We now update the owner of the Plan.
            objPlan.OwnerId = UserInfo.getUserId();
            update objPlan;

            //Now we create an event.
            objEvent = new Event();
            objEvent.StartDateTime = System.now();
            objEvent.DurationInMinutes = 60;
            objEvent.WhatId = objPlan.Id;
            insert objEvent;

            //Now we start the testing.
            Test.startTest();

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

            //First we return the Time Zone lists.
            System.assertNotEquals(GlobalSchedulerController.getTimeZoneValues() == null, true, 'Unable to get Time Zones.');

            //Now we check if the mode is Read-only.
            System.assertNotEquals(GlobalSchedulerController.getIsReadOnly(objPlan.Id) == true, true, 'Read only scenario');

            //Now we get the involved users.
            objRequest = GlobalSchedulerController.getRelatedUsers(objPlan.Id);

            //We also return the current user's name.
            System.assertNotEquals(GlobalSchedulerController.getUserName(UserInfo.getUserId()) == null, true, 'Invalid user.');

            //Now we get the available slots.
            objRequest.datStart = Date.today();
            objRequest.datStop = Date.today().addDays(1);
            objRequest.lstUsers = new List<String> { UserInfo.getUserId() };
            objRequest.strStartTime = '00:00:00';
            objRequest.strStopTime = '23:59:59';
            objRequest.intDefaultDurationMinutes = 60;
            objRequest.intDefaultGapMinutes = 15;
            System.assertNotEquals(GlobalSchedulerController.getAvailableSlots(objRequest) == null, true, 'Unable to fetch available slots.');

            //Now we create a schedule.
            objRequest.lstContacts = new List<String>();
            objRequest.lstContacts.add(objContact.Id);
            objRequest.lstAttendees = new List<Attendee__c>();
            objRequest.lstAttendees.add(objAttende);
            objRequest.objAppointmentRequest = new Appointment_Request__c();
            objRequest.lstSlots = new List<Time_Slot__c>();
            objRequest.lstSlots.add(objSlot);
            objRequest.strRecordId = objPlan.Id;
            System.assertNotEquals(GlobalSchedulerController.getAppointmentRequestCreated(objRequest) == null, true, 'Unable to create schedule.');

            //Now we get the Appointment data.
            objAppointment = [SELECT Id FROM Appointment_Request__c LIMIT 1];
            System.assertNotEquals(GlobalSchedulerController.getAppointmentRequestData(objAppointment.Id,null) == null, true, 'Unable to get Appointment data.');
            site sr = [select id,UrlPathPrefix from site where UrlPathPrefix = 'success' limit 1];
            //Now we create an Event.
            objRequest.boolIsReadOnly = true;
            objRequest.objSlot = objSlot;
            System.assertNotEquals(GlobalSchedulerController.getEventScheduled(objRequest) == null, true, 'Unable to create Event.');
            objRequest.strRecordId = [SELECT Id FROM Appointment_Request__c LIMIT 1].Id;
            System.assertNotEquals(GlobalSchedulerController.getEventScheduled(objRequest) == null, true, 'Unable to create Event.');

            //We get the event details of what we just created.
            System.assertNotEquals(GlobalSchedulerController.getEventDetails([SELECT Id FROM Event LIMIT 1].Id) == null, true, 'Unable to get Event details.');

            //Now, we get the Email templates.
            objRequest.strRecordId = [SELECT Id FROM Event LIMIT 1].Id;
            System.assertNotEquals(GlobalSchedulerController.getEmailTemplate(objRequest) == null, true, 'Unable to fetch Event template.');
            objRequest.strRecordId = [SELECT Id FROM Plan_Comment__c LIMIT 1].Id;
            System.assertNotEquals(GlobalSchedulerController.getEmailTemplate(objRequest) == null, true, 'Unable to fetch Appointment template.');
            objRequest.strRecordId = null;
            objRequest.strRelatedToId = objPlan.Id;
            objRequest.strSlotsURL = 'Testid=' + objAppointment.Id;
            System.assertNotEquals(GlobalSchedulerController.getEmailTemplate(objRequest) == null, true, 'Unable to fetch Appointment template.');

            //Now we check if the user should be able to use the scheduler.
            System.assertNotEquals(GlobalSchedulerController.getRecordOwnerValidated(objPlan.Id), false, 'User cannot use scheduler.');

            //Now we check if the mode now can be Read-only.
            System.assertNotEquals(GlobalSchedulerController.getIsReadOnly([SELECT Id FROM Appointment_Request__c LIMIT 1].Id) == false, true, 'None Read only scenario');

            //Now we check a case without timezone.
            objPlan.Plan_Timezone__c = null;
            update objPlan;
            objRequest.strRecordId = [SELECT Id FROM Event LIMIT 1].Id;
            System.assertNotEquals(GlobalSchedulerController.getEmailTemplate(objRequest) == null, true, 'Unable to fetch Event template.');

            //We stop the test.
            Test.stopTest();
        }
    }
    
    /*
     Method Name : testCreatingScheduleAndEvent
     Description : Testing creating records.
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void testCreatingScheduleAndEventEngagement() {

        //We create an extra user, to include it as a team member.
        //User objExtraUser = createTestUser('System Administrator', true);
        User objExtraUser = [Select Id from User where Id =: userinfo.getUserId()];

        //Now we run the test.
        System.runAs(createTestUser('System Administrator', true)) {
            Event objEvent;
            Time_Slot__c objSlot = new Time_Slot__c();
            Attendee__c objAttende = new Attendee__c();
            Appointment_Request__c objAppointment;
            Contact objContact = [SELECT Id FROM Contact LIMIT 1];
            Account objAccount = [SELECT Id FROM Account LIMIT 1];
            Engagement__c objEngagement = new Engagement__c();
            Engagement_Team__c objEngagementTeam = new Engagement_Team__c();
            Engagement_Contacts__c objEngagementContact = new Engagement_Contacts__c();
            GlobalSchedulerWrapperClass objRequest;

            //Now we create an Engagement.
            objEngagement.Support_Account__c = objAccount.Id;
            insert objEngagement;

            //Now we create an Engagement Team Member.
            objEngagementTeam.Engagement__c = objEngagement.Id;
            objEngagementTeam.Team_Member__c = UserInfo.getUserId();
            insert objEngagementTeam;

            //Now we create an Engagement Contact.
            objEngagementContact.Engagement__c = objEngagement.Id;
            objEngagementContact.Contact__c = objContact.Id;
            insert objEngagementContact;

            //We set initial parameters.
            objMockResponse = new MultiStaticResourceCalloutMock();
            objSlot.Start_Time__c = System.now();
            objSlot.Duration__c = 60;
            objAttende.User__c = UserInfo.getUserId();

            //Now we create an event.
            objEvent = new Event();
            objEvent.StartDateTime = System.now();
            objEvent.DurationInMinutes = 60;
            insert objEvent;

            //Now we start the testing.
            Test.startTest();

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

            //Now we get the involved users.
            objRequest = GlobalSchedulerController.getRelatedUsers(objEngagement.Id);

            //We also return the current user's name.
            System.assertNotEquals(GlobalSchedulerController.getUserName(UserInfo.getUserId()) == null, true, 'Invalid user.');

            //Now we get the available slots.
            objRequest.datStart = Date.today();
            objRequest.datStop = Date.today().addDays(1);
            objRequest.lstUsers = new List<String> { UserInfo.getUserId() };
            objRequest.strStartTime = '00:00:00';
            objRequest.strStopTime = '23:59:59';
            objRequest.intDefaultDurationMinutes = 60;
            objRequest.intDefaultGapMinutes = 15;
            System.assertNotEquals(GlobalSchedulerController.getAvailableSlots(objRequest) == null, true, 'Unable to fetch available slots.');

            //Now we create a schedule.
            objRequest.lstContacts = new List<String>();
            objRequest.lstContacts.add(objContact.Id);
            objRequest.lstAttendees = new List<Attendee__c>();
            objRequest.lstAttendees.add(objAttende);
            objRequest.objAppointmentRequest = new Appointment_Request__c();
            objRequest.lstSlots = new List<Time_Slot__c>();
            objRequest.lstSlots.add(objSlot);
            objRequest.strRecordId = objEngagement.Id;
            System.assertNotEquals(GlobalSchedulerController.getAppointmentRequestCreated(objRequest) == null, true, 'Unable to create schedule.');

            //Now we get the Appointment data.
            objAppointment = [SELECT Id FROM Appointment_Request__c LIMIT 1];
            System.assertNotEquals(GlobalSchedulerController.getAppointmentRequestData(objAppointment.Id,'PDT') == null, true, 'Unable to get Appointment data.');

            //Now we create an Event.
            objRequest.boolIsReadOnly = true;
            objRequest.objSlot = objSlot;
            System.assertNotEquals(GlobalSchedulerController.getEventScheduled(objRequest) == null, true, 'Unable to create Event.');
            objRequest.strRecordId = [SELECT Id FROM Appointment_Request__c LIMIT 1].Id;
            System.assertNotEquals(GlobalSchedulerController.getEventScheduled(objRequest) == null, true, 'Unable to create Event.');

            //We get the event details of what we just created.
            System.assertNotEquals(GlobalSchedulerController.getEventDetails([SELECT Id FROM Event LIMIT 1].Id) == null, true, 'Unable to get Event details.');
            Test.stopTest();
        }
    }
    
    /*
     Method Name : testCreatedSchedule
     Description : Testing created Schedules.
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void testCreatedSchedule() {
        System.runAs(createTestUser('System Administrator', true)) {
            Event objEvent = new Event();
            Time_Slot__c objTimeSlot = new Time_Slot__c();
            Appointment_Request__c objAppointment = new Appointment_Request__c();

            //Now we create an event.
            objEvent.StartDateTime = System.now();
            objEvent.DurationInMinutes = 60;
            insert objEvent;
            objEvent = new Event();
            objEvent.StartDateTime = System.now().addHours(3);
            objEvent.DurationInMinutes = 60;
            insert objEvent;

            //We set initial parameters.
            objAppointment.Created_Event__c = objEvent.Id;
            insert objAppointment;
            objTimeSlot.Start_Time__c = System.now();
            objTimeSlot.Duration__c = 50;
            objTimeSlot.Appointment_Request__c = objAppointment.Id;
            insert objTimeSlot;
            objTimeSlot = new Time_Slot__c();
            objTimeSlot.Start_Time__c = System.now().addDays(1);
            objTimeSlot.Duration__c = 50;
            objTimeSlot.Appointment_Request__c = objAppointment.Id;
            insert objTimeSlot;

            //Now we start the testing.
            Test.startTest();

            //Now we get the Appointment data.
            System.assertNotEquals(GlobalSchedulerController.getAppointmentRequestData(objAppointment.Id,'PDT') == null, true, 'Unable to get Appointment data.');
            Test.stopTest();
        }
    }

    //<T01>
    /*
     Method Name : testGetContactTimezone
     Description : Testing GlobalSchedulerController.getContactTimezone
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void testGetContactTimezone() {
        UnitOfWork uow = new UnitOfWork(UOW_SOBJECTS);

        Timezone__c objTimezone = new Timezone__c();
        objTimezone.Name = 'GMT–07:00 Pacific Daylight Time (America/Los_Angeles)';
        objTimezone.TimeZone__c = 'GMT–07:00 Pacific Daylight Time (America/Los_Angeles)';
        objTimezone.TimeZoneSidKey__c = 'America/Los_Angeles';
        uow.registerNew(objTimezone);

        Contact objContact = [Select Id FROM Contact LIMIT 1];
        uow.registerRelationship(objContact, Contact.TimeZone_Lookup__c, objTimezone);
        uow.registerUpsert(objContact);

        Profile ppProfile = [SELECT Id, Name FROM Profile WHERE Name='Customer Community Plus Login User'];
       
        User objUser = new User();
        objUser.ProfileId = ppProfile.id;
        objUser.Username = 'portalUsers@m.t';
        objUser.Email = 'portalUsers@m.t';
        objUser.Alias = 'alias';
        objUser.CommunityNickname = 'portalTest';
        objUser.LastName = 'last';
        objUser.IsActive = true;
        objUser.ContactId = objContact.Id;
        objUser.EmailEncodingKey = 'UTF-8';
        objUser.LanguageLocaleKey = 'en_US';
        objUser.LocaleSidKey = 'en_US';
        objUser.TimeZoneSidKey = 'America/Los_Angeles';
        uow.registerNew(objUser);

        uow.commitWork();

        System.runAs(objUser) {
            Test.startTest();
            String strContactTimezone = GlobalSchedulerController.getContactTimezone();
            System.assertEquals(strContactTimezone, 'America/Los_Angeles', 'Unable to get contact timezone.');
            Test.stopTest();
        }
    }

    //</T01>
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
        List<PermissionSetAssignment> lstPermissionSets = new List<PermissionSetAssignment>();

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

        //Now we add the permission set.
        for(PermissionSet objPermissionSet :[SELECT Id FROM PermissionSet WHERE Name LIKE 'CSM_Success%' and Type != 'GROUP']) {
            lstPermissionSets.add(new PermissionSetAssignment(AssigneeId = objTestUser.id, PermissionSetId = objPermissionSet.Id));
        }
        if(lstPermissionSets?.size()>0){
            insert lstPermissionSets;
        }

        //Now we return the result.
        return objTestUser;
    }
}