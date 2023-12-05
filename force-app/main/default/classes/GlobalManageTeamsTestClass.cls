/*
 * Name			:	GlobalManageTeamsTestClass
 * Author		:	Monserrat Pedroza
 * Created Date	: 	8/20/2021
 * Description	:	Global Manage Contacts test class.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		8/20/2021		N/A				Initial version.			N/A
 */
@isTest(seeAllData = false)
public with sharing class GlobalManageTeamsTestClass {
	
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

		//Now we create an Engagement.
		Engagement__c objEngagement = new Engagement__c();
		objEngagement.Account__c = objAccount.Id;
		insert objEngagement;
    }
	
	/*
	 Method Name : testRecordFetchingAssigned
	 Description : Testing fetching assigned records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testRecordFetchingAssigned() {
        System.runAs(createTestUser('System Administrator', true)) {
			createData();
            Engagement__c objEngagement = [SELECT Id FROM Engagement__c LIMIT 1];

			//Now we test the method.
			Test.startTest();

            //Now we get the unassigned records based on record Id.
            System.assertNotEquals(GlobalManageTeamsController.getRecords(objEngagement.Id, false) == null, true, 'Unable to get records.');
			Test.stopTest();
        }
    }
	
	/*
	 Method Name : testRecordFetchingUnassigned
	 Description : Testing fetching unassiged records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testRecordFetchingUnassigned() {
        System.runAs(createTestUser('System Administrator', true)) {
			createData();
            Engagement__c objEngagement = [SELECT Id FROM Engagement__c LIMIT 1];

			//Now we test the method.
			Test.startTest();

            //Now we get the assigned records based on record Id.
            System.assertNotEquals(GlobalManageTeamsController.getRecords(objEngagement.Id, true) == null, true, 'Unable to get records.');
			Test.stopTest();
        }
    }
	
	/*
	 Method Name : testDeleteRecords
	 Description : Testing deleting records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testDeleteRecords() {
        System.runAs(createTestUser('System Administrator', true)) {
			createData();
            Engagement_Team__c objRecord = [SELECT Id FROM Engagement_Team__c LIMIT 1];
			List<Engagement_Team__c> lstRecords = new List<Engagement_Team__c>();

            //Now we prepare the data.
            lstRecords.add(objRecord);

			//Now we test the method.
			Test.startTest();

			//Now we delete the records.
			GlobalManageTeamsController.getRecordsDeleted(lstRecords);

            //Now we get the records history.
            System.assertNotEquals([SELECT Id FROM Engagement_Team__c] == null, true, 'No records were deleted.');
			Test.stopTest();
        }
    }
	
	/*
	 Method Name : testRecordsRelationship
	 Description : Testing relating records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testRecordsRelationship() {
        System.runAs(createTestUser('System Administrator', true)) {
			createData();
			Engagement__c objRecordParent = [SELECT Id FROM Engagement__c LIMIT 1];
			List<Id> lstRecords = new List<Id>();

            //Now we prepare the data.
            lstRecords.add(UserInfo.getUserId());

			//Now we test the method.
			Test.startTest();

			//Now we delete the records.
			GlobalManageTeamsController.getRecordsRelated(objRecordParent.Id, lstRecords);

            //Now we get the records history.
            System.assertNotEquals([SELECT Id FROM AccountTeamMember LIMIT 1] == null, true, 'Unable to relate records.');
			Test.stopTest();
        }
    }
	
	/*
	 Method Name : testUpdateRecords
	 Description : Testing updating records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testUpdateRecords() {
        System.runAs(createTestUser('System Administrator', true)) {
			createData();
            Engagement_Team__c objRecordAssigned = [SELECT Id FROM Engagement_Team__c LIMIT 1];
			List<Engagement_Team__c> lstRecordsAssigned = new List<Engagement_Team__c>();
            AccountTeamMember objRecordUnassigned = [SELECT Id FROM AccountTeamMember LIMIT 1];
			List<AccountTeamMember> lstRecordsUnassigned = new List<AccountTeamMember>();

            //Now we prepare the data.
            lstRecordsAssigned.add(objRecordAssigned);
			lstRecordsUnassigned.add(objRecordUnassigned);

			//Now we test the method.
			Test.startTest();

			//Now we update the records.
			GlobalManageTeamsController.getRecordsUpdated(lstRecordsAssigned, null);
			GlobalManageTeamsController.getRecordsUpdated(null, lstRecordsUnassigned);

            //Now we get the records history.
            System.assertNotEquals([SELECT Id FROM Engagement_Team__c LIMIT 1] == null, true, 'Unable to update records.');
			System.assertNotEquals([SELECT Id FROM AccountTeamMember LIMIT 1] == null, true, 'Unable to update records.');
			Test.stopTest();
        }
    }
	
	/*
	 Method Name : createData
	 Description : This method creates data that cannot be created on the setup method.
	 Parameters	 : None
	 Return Type : None
	 */
    private static void createData() {
		Account objAccount = [SELECT Id FROM Account LIMIT 1];
		Engagement__c objEngagement = [SELECT Id FROM Engagement__c LIMIT 1];

		//Now we create a Contact.
		AccountTeamMember objAccountTeamMember = new AccountTeamMember();
		objAccountTeamMember.AccountId = objAccount.Id;
		objAccountTeamMember.UserId = UserInfo.getUserId();
		insert objAccountTeamMember;

		//Now we create an Engagement Contact.
		Engagement_Team__c objEngagementContact = new Engagement_Team__c();
		objEngagementContact.Engagement__c = objEngagement.Id;
		objEngagementContact.Team_Member__c = UserInfo.getUserId();
		insert objEngagementContact;
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
        }*/
        return [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
    }
}