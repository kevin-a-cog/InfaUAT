/*
 * Name			:	GlobalUserPreferencesClassTest
 * Author		:	Vignesh D
 * Created Date	: 	10/20/2021
 * Description	:	GlobalUserPreferencesClass test class.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Vignesh D            10/20/2021		N/A				Initial version.			N/A
 */

@isTest(seeAllData = false)
public with sharing class GlobalUserPreferencesClassTest {
    

    /*
	 Method Name : testUserPreferences
	 Description : Testing set & get user preferences.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testUserPreferences() {
        System.runAs(createTestUser('System Administrator', true)) {
            GlobalUserPreferencesWrapperClass objRequest = new GlobalUserPreferencesWrapperClass();
            GlobalUserPreferencesClass.setUserPreferences(objRequest);
            GlobalUserPreferencesClass.getUserPreferences();
            GlobalUserPreferencesWrapperClass.SortingWrapperClass objSortingWrapperClass = new GlobalUserPreferencesWrapperClass.SortingWrapperClass();
            objSortingWrapperClass.strFieldName = 'Test Field';
            objSortingWrapperClass.strSortDirection = 'Test direction';
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
        /*Integer intRandomNumber = Integer.valueOf(DateTime.now().getTime());
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

		//Now we return the result.
        return objTestUser;*/
        return [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
    }
}