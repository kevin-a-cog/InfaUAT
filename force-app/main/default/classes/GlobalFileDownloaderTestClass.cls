/*
 * Name			:	GlobalFileDownloaderTestClass
 * Author		:	Monserrat Pedroza
 * Created Date	: 	11/1/2021
 * Description	:	Global File Downloader test class.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		11/1/2021		N/A				Initial version.			N/A
 */
@isTest(seeAllData = false)
public with sharing class GlobalFileDownloaderTestClass {
	
	/*
	 Method Name : setup
	 Description : Test setup method.
	 Parameters	 : None
	 Return Type : None
	 */
    @testSetup 
    public static void setup() {

        //We create an Account.
        Account objAccount = new Account();
		objAccount.Name = 'Test';
		objAccount.BillingCountry = 'Test';
		insert objAccount;

		//Now we create a Document.
		ContentVersion objContent = new ContentVersion(); 
        objContent.Title = 'Test';
        objContent.PathOnClient = '/' + objContent.Title + '.jpg'; 
        objContent.VersionData = Blob.valueOf('Unit Test ContentVersion Body'); 
        objContent.Origin = 'H';
        insert objContent;
        ContentDocumentLink objContentLink = new ContentDocumentLink();
        objContentLink.LinkedEntityId = objAccount.id;
        objContentLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :objContent.id].ContentDocumentId;
        objContentLink.ShareType = 'I';
        objContentLink.Visibility = 'AllUsers'; 
        insert objContentLink;
    }
	
	/*
	 Method Name : testRecordFetching
	 Description : Testing fetching records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testRecordFetching() {
        System.runAs(createTestUser('System Administrator', true)) {
			Account objAccount = [SELECT Id FROM Account LIMIT 1];

			//Now we test the method.
			Test.startTest();
            System.assertNotEquals(GlobalFileDownloader.getRecords(objAccount.Id) == null, true, 'Unable to get table details.');
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
        return objTestUser;
    }
}