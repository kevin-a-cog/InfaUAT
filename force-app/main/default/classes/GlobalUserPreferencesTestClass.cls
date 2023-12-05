/*
 * Name			:	GlobalUserPreferencesTestClass
 * Author		:	Monserrat Pedroza
 * Created Date	: 	10/28/2021
 * Description	:	Global User Preferences test class.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		10/28/2021		N/A				Initial version.			N/A
 */
@isTest(seeAllData = false)
public with sharing class GlobalUserPreferencesTestClass {
	
	/*
	 Method Name : testGetAndSet
	 Description : Testing creating and getting records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testGetAndSet() {
        System.runAs(createTestUser('System Administrator', true)) {
			GlobalUserPreferencesWrapperClass objResult;

			//Now we start the testing.
			Test.startTest();

			//First we test getting the data.
			objResult = GlobalUserPreferencesClass.getUserPreferences();
            System.assertNotEquals(objResult == null, true, 'Unable to get records.');

			//Now we test setting the data.
			objResult.objEngineerWorkspace.intSplitterPosition = 1;
			objResult.objEngineerWorkspace.strView = 'Test';
			objResult.objEngineerWorkspace.strPinnedListView = 'Test';
			objResult.objManagerWorkspace.strTeamsSelectedTab = 'Test';
			GlobalUserPreferencesClass.setUserPreferences(objResult);

			//Now we test getting the data again.
            System.assertNotEquals(GlobalUserPreferencesClass.getUserPreferences() == null, true, 'Unable to get records.');

			//Now we cover the wrapper class.
			GlobalUserPreferencesWrapperClass.SortingWrapperClass objSorting = new GlobalUserPreferencesWrapperClass.SortingWrapperClass();
			objSorting.strFieldName = 'test';
			objSorting.strSortDirection = 'test';
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