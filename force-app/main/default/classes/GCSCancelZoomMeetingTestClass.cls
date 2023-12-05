/*
 * Name			:	GCSCancelZoomMeetingTestClass
 * Author		:	Monserrat Pedroza
 * Created Date	: 	11/02/2021
 * Description	:	Cancel Zoom test class.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		11/02/2021		N/A				Initial version.			N/A
 */
@isTest(seeAllData = false)
public with sharing class GCSCancelZoomMeetingTestClass {
	
	//Public variables.
	public static GlobalZoomEndpointWrapperClass objEndpoint;
	public static MultiStaticResourceCalloutMock objMockResponse;
	
	/*
	 Method Name : testCancellingEvent
	 Description : Testing cancelling event.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testCancellingEvent() {
        System.runAs(createTestUser('System Administrator', true)) {
			Event objEvent;
			Meeting_Account__c objMeetingAccount = new Meeting_Account__c();

			//We set initial parameters.
			objMockResponse = new MultiStaticResourceCalloutMock();

			//Now we insert a Meeting Account.
			objMeetingAccount.Access_Token__c = 'test';
			objMeetingAccount.Expires_In__c = 20;
			objMeetingAccount.Refresh_Token__c = 'test';
			objMeetingAccount.Scope__c = 'test';
			objMeetingAccount.Token_Type__c = 'test';
			insert objMeetingAccount;

			//Now we create an event.
			objEvent = new Event();
			objEvent.StartDateTime = System.now();
			objEvent.DurationInMinutes = 60;
			objEvent.Zoom_Meeting_Id__c = 'test';
			insert objEvent;

			//Now we start the testing.
			Test.startTest();

			//We set the mock responses.
			objEndpoint = GlobalZoomUtilitiesClass.getEndpoint('Authorize');
			objMockResponse.setStaticResource(objEndpoint.strEndpoint, 'ZoomAccessToken');
			objEndpoint = GlobalZoomUtilitiesClass.getEndpoint('Token');
			objMockResponse.setStaticResource(objEndpoint.strEndpoint, 'ZoomRefreshAccessToken');
			objEndpoint = GlobalZoomUtilitiesClass.getEndpoint('Cancel Meeting');
			objMockResponse.setStaticResource(objEndpoint.strEndpoint.replace('{meetingId}', 'test'), 'ZoomCreateMeeting');
	
			//General parameters.
			objMockResponse.setStatusCode(200);
			objMockResponse.setHeader('Content-Type', 'application/json');
			Test.setMock(HttpCalloutMock.class, objMockResponse);
			
			//Now we cancel the event.
			System.assertNotEquals(GCSCancelZoomMeetingController.getMeetingCanceled(objEvent.Id) == null, true, 'Unable to create Event.');
			Test.stopTest();
        }
    }

	/*
	 Method Name : createTestUser
	 Description : This method serves as a Utility method to create Test users.
	 Parameters	 : String, called from createTestUser, strProfileName Profile name.
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