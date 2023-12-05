/*
 * Name			:	CSMNextBestActionManagementTest
 * Author		:	Monserrat Pedroza
 * Created Date	: 	10/14/2021
 * Description	:	Next Best Action Management test class.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		10/14/2021		N/A				Initial version.			N/A
 */
@isTest(seeAllData = false)
public with sharing class CSMNextBestActionManagementTest {
	
	/*
	 Method Name : setup
	 Description : Test setup method.
	 Parameters	 : None
	 Return Type : None
	 */
    @testSetup 
    public static void setup() {

		//Now we create predefined Next Best Actions.
		Next_Best_Action_Predefined__c objNextBestActionPredefined = new Next_Best_Action_Predefined__c();
		objNextBestActionPredefined.Action_Data__c = '{"Name": "Test2", "BillingCountry": "US"}';
		objNextBestActionPredefined.Action_Target__c = 'Account';
		objNextBestActionPredefined.Action_Type__c = 'Upsert record';
		objNextBestActionPredefined.Is_Active__c = true;
		objNextBestActionPredefined.Title__c = 'test';
		insert objNextBestActionPredefined;
    }
	
	/*
	 Method Name : testMainScenarios
	 Description : Testing main scenarios.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testMainScenarios() {
        System.runAs(createTestUser('System Administrator', true)) {
			Next_Best_Action__c objNextBestAction = new Next_Best_Action__c();
			Next_Best_Action_Query__c objChildQuery = new Next_Best_Action_Query__c();

			//We prepare the data.
			objNextBestAction.Action_Data__c = '{"Name": "Test2", "BillingCountry": "US"}';
			objNextBestAction.Action_Target__c = 'Account';
			objNextBestAction.Action_Type__c = 'Upsert record';
			objNextBestAction.Active__c = true;
			objNextBestAction.Criteria__c = 'SELECT count() FROM Plan__c WHERE Id = \'{!Id}\'';
			objNextBestAction.Criteria_Type__c = 'SOQL';
			objNextBestAction.Object__c = 'Account';
			objNextBestAction.Order__c = 1;
			objNextBestAction.Recommendation__c = 'Test';
			objNextBestAction.Threshold__c = 1;
			objNextBestAction.Threshold_Criteria__c = 'Greater than or equal to';
			objNextBestAction.Recurrence__c = 'Recurring';
			objNextBestAction.Recurring_Interval__c = 1;
			objChildQuery.Active__c = true;
			objChildQuery.Identifier__c = '1';
			objChildQuery.Next_Best_Action__c = objNextBestAction.Id;
			objChildQuery.Query__c = 'SELECT count() FROM Account WHERE Id = \'{!Id}\'';
			objChildQuery.Threshold__c = 1;
			objChildQuery.Threshold_Criteria__c = 'Greater than or equal to';

            //Now we get the records.
			Test.startTest();
            System.assertNotEquals(CSMNextBestActionManagementController.getSObjects() == null, true, 'Unable to get records.');
			System.assertNotEquals(CSMNextBestActionManagementController.getRelatedFields('Account') == null, true, 'Unable to get records.');
			System.assertNotEquals(CSMNextBestActionManagementController.getActions() == null, true, 'Unable to get records.');
			System.assertNotEquals(CSMNextBestActionManagementController.getRecordCreated(objNextBestAction, new List<Next_Best_Action_Query__c> { objChildQuery }) == null, 
					true, 'Unable to get records.');
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

		//Now we add the permission set.
        for(PermissionSet objPermissionSet :[SELECT Id FROM PermissionSet WHERE Name LIKE 'CSM_Success%']) {
            lstPermissionSets.add(new PermissionSetAssignment(AssigneeId = objTestUser.id, PermissionSetId = objPermissionSet.Id));
        }
        if(lstPermissionSets?.size()>0){
            insert lstPermissionSets;
        }

		//Now we return the result.
        return objTestUser;
    }
}