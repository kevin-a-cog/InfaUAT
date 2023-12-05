/*
 * Name			:	GlobalEmailApprovalTestClass
 * Author		:	Monserrat Pedroza
 * Created Date	: 	12/6/2021
 * Description	:	This class tests the Global Email Approver controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		12/6/2021		N/A				Initial version.			N/A
 */
@isTest(seeAllData = false)
public with sharing class GlobalEmailApprovalTestClass {
	
	/*
	 Method Name : setup
	 Description : Test setup method.
	 Parameters	 : None
	 Return Type : None
	 */
    @testSetup 
    public static void setup() {

		//Now we create an Account.
		Account objAccount = new Account();
		objAccount.Name = 'Test';
		objAccount.BillingCountry = 'US';
		insert objAccount;
    }
	
	/*
	 Method Name : testFetchingRecords
	 Description : Testing fetching records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testFetchingRecords() {
        System.runAs(createTestUser('System Administrator', true)) {
			Account objAccount = [SELECT Id FROM Account];
			GlobalEmailApprovalController objController = new GlobalEmailApprovalController();
			Messaging.InboundEmail objEmail = new Messaging.InboundEmail();

			//First we set the test data.
			objEmail.PlainTextBody = 'Yes Ref{' + objAccount.Id + '}';

            //Now we get the records.
			Test.startTest();
            System.assertNotEquals(objController.handleInboundEmail(objEmail, null) == null, true, 'Unable to get records.');
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

        //Assign CSM permissions
        for(PermissionSet objPermissionSet :[SELECT Id FROM PermissionSet WHERE Name LIKE 'CSM_Success%']){
            PermissionSetAssignment objPermissionSetAssignment = new PermissionSetAssignment(AssigneeId = objTestUser.id, PermissionSetId = objPermissionSet.Id);
            lstPermissionSets.add(objPermissionSetAssignment);
        }
        if(lstPermissionSets.size() > 0){
            insert lstPermissionSets;
        }
        return objTestUser;
    }
}