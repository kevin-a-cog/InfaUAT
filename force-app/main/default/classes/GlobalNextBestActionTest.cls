/*
 * Name			:	GlobalNextBestActionTest
 * Author		:	Monserrat Pedroza
 * Created Date	: 	9/14/2021
 * Description	:	Next Best Action test class.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		9/14/2021		N/A				Initial version.			N/A
 */
@isTest(seeAllData = false)
public with sharing class GlobalNextBestActionTest {
	
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

        //Now we create a Contact.
        Contact objContact = new Contact();
        objContact.LastName = 'Test';
		objContact.AccountId = objAccount.Id;
        insert objContact;

		//Now we create predefined Next Best Actions.
		Next_Best_Action_Predefined__c objNextBestActionPredefined = new Next_Best_Action_Predefined__c();
		objNextBestActionPredefined.Action_Data__c = '{"Name": "Test2", "BillingCountry": "US"}';
		objNextBestActionPredefined.Action_Target__c = 'Account';
		objNextBestActionPredefined.Action_Type__c = 'Upsert record';
		objNextBestActionPredefined.Is_Active__c = true;
		objNextBestActionPredefined.Title__c = 'test';
		insert objNextBestActionPredefined;

		//Now we create Next Best Actions and their history records.
		Next_Best_Action__c objNextBestAction = new Next_Best_Action__c();
		Next_Best_Action_History__c objHistory = new Next_Best_Action_History__c();
		objNextBestAction.Action_Data__c = '{"Name": "Test2", "BillingCountry": "US", "ContactId": "{!Contacts[0].Id}"}';
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
		objNextBestAction.Accepted_Action__c = objNextBestActionPredefined.Id;
		objNextBestAction.Rejected_Action__c = objNextBestActionPredefined.Id;
		objNextBestAction.Recurrence__c = 'Recurring';
		objNextBestAction.Recurring_Interval__c = 1;
		objNextBestAction.Additional_Data__c = 'Id, (SELECT Id FROM Contacts LIMIT 1)';
		insert objNextBestAction;
		objNextBestAction = new Next_Best_Action__c();
		objNextBestAction.Action_Data__c = '{"Name": "Test2", "BillingCountry": "US"}';
		objNextBestAction.Action_Target__c = 'Account';
		objNextBestAction.Action_Type__c = 'Upsert record';
		objNextBestAction.Active__c = true;
		objNextBestAction.Criteria__c = 'OR(NOT(AND(EQUALS(1,1), NOT(EQUALS(1,2)))), CONTAINS(\'HI\', \'HIs\'), CONTAINS("HI", "HI"), GREATER_THAN(5,1), ' + 
				'and(LESS_THAN(1,5), GREATER_OR_EQUAL(1,2), GREATER_OR_EQUAL(4,2)), LESS_OR_EQUAL(0,1), OR(ENDS(\'HOLA\', \'A\'), ENDS("HOLA", "A"), STARTS(\'HOLA\', \'H\'), STARTS("HOLA", "H")))';
		objNextBestAction.Criteria_Type__c = 'Formula';
		objNextBestAction.Object__c = 'Account';
		objNextBestAction.Order__c = 1;
		objNextBestAction.Recommendation__c = 'Test';
		objNextBestAction.Threshold__c = 1;
		objNextBestAction.Threshold_Criteria__c = 'Greater than or equal to';
		objNextBestAction.Accepted_Action__c = objNextBestActionPredefined.Id;
		objNextBestAction.Rejected_Action__c = objNextBestActionPredefined.Id;
		objNextBestAction.Recurrence__c = 'Recurring';
		objNextBestAction.Recurring_Interval__c = 1;
		objNextBestAction.Additional_Data__c = 'Id, (SELECT Id FROM Contacts LIMIT 1)';
		insert objNextBestAction;
		objNextBestAction = new Next_Best_Action__c();
		objNextBestAction.Active__c = true;
		objNextBestAction.Criteria__c = 'AND({!1})';
		objNextBestAction.Criteria_Type__c = 'Multiple SOQL';
		objNextBestAction.Object__c = 'Account';
		objNextBestAction.Order__c = 1;
		objNextBestAction.Recommendation__c = 'Test';
		objNextBestAction.Accepted_Action__c = objNextBestActionPredefined.Id;
		objNextBestAction.Rejected_Action__c = objNextBestActionPredefined.Id;
		objNextBestAction.Recurrence__c = 'Recurring';
		objNextBestAction.Recurring_Interval__c = 1;
		objNextBestAction.Additional_Data__c = 'Id, (SELECT Id FROM Contacts LIMIT 1)';
		insert objNextBestAction;

		//Now we create child queries.
		Next_Best_Action_Query__c objChildQuery = new Next_Best_Action_Query__c();
		objChildQuery.Active__c = true;
		objChildQuery.Identifier__c = '1';
		objChildQuery.Next_Best_Action__c = objNextBestAction.Id;
		objChildQuery.Query__c = 'SELECT count() FROM Account WHERE Id = \'{!Id}\'';
		objChildQuery.Threshold__c = 1;
		objChildQuery.Threshold_Criteria__c = 'Greater than or equal to';
		insert objChildQuery;

		//Now we create history records.
		objNextBestAction = new Next_Best_Action__c();
		objNextBestAction.Active__c = true;
		objNextBestAction.Criteria__c = 'AND({!1})';
		objNextBestAction.Criteria_Type__c = 'Multiple SOQL';
		objNextBestAction.Object__c = 'Account';
		objNextBestAction.Order__c = 1;
		objNextBestAction.Recommendation__c = 'Test';
		objNextBestAction.Accepted_Action__c = objNextBestActionPredefined.Id;
		objNextBestAction.Rejected_Action__c = objNextBestActionPredefined.Id;
		objNextBestAction.Recurrence__c = 'Recurring';
		objNextBestAction.Recurring_Interval__c = 1;
		objNextBestAction.Additional_Data__c = 'Id, (SELECT Id FROM Contacts LIMIT 1)';
		insert objNextBestAction;
		objHistory = new Next_Best_Action_History__c();
		objHistory.Accepted__c = true;
		objHistory.Is_Latest__c = true;
		objHistory.Next_Best_Action__c = objNextBestAction.Id;
		objHistory.Offer_Again_On__c = Date.today().addDays(1);
		objHistory.Record_Id__c = objAccount.Id;
		insert objHistory;
    }
	
	/*
	 Method Name : testFetchingRecords
	 Description : Testing fetching records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testFetchingRecords() {
        //System.runAs(createTestUser('System Administrator', true)) {
			GlobalNextBestActionWrapperClass objWrapper = new GlobalNextBestActionWrapperClass();
			Account objRecord = [SELECT Id FROM Account];
			Next_Best_Action__c objNextBestAction = [SELECT Id, Action_Data__c, Action_Target__c FROM Next_Best_Action__c LIMIT 1];

			//We prepare the data.
			objWrapper.idRecord = objRecord.Id;

            //Now we get the records.
			Test.startTest();
            System.assertNotEquals(GlobalNextBestActionController.getRecommendations(objWrapper) == null, true, 'Unable to get records.');

			//Now we save the user selection.
			for(Next_Best_Action__c objNextBestActionSaved : [SELECT Id, Action_Data__c, Action_Target__c FROM Next_Best_Action__c LIMIT 1000]) {
				objWrapper = new GlobalNextBestActionWrapperClass();
				objWrapper.boolAccepted = true;
				objWrapper.idParentRecord = objRecord.Id;
				objWrapper.idRecord = objNextBestActionSaved.Id;
				GlobalNextBestActionController.getSelectionSaved(objWrapper);
			}

			//Now we check no new next best actions are shown.
			objWrapper = new GlobalNextBestActionWrapperClass();
			objWrapper.idRecord = objRecord.Id;
            System.assertNotEquals(GlobalNextBestActionController.getRecommendations(objWrapper) == null, true, 'Unable to get records.');

			//Now we verify the formula.
			System.assertNotEquals(GlobalNextBestActionController.getFormulaVerified('Account', 'EQUALS(1,1)') == null, true, 'Unable to verify the formula.');
			System.assertNotEquals(GlobalNextBestActionController.getFormulaVerified('', 'EQUALS(1,1)') == true, true, 'Unable to verify the formula.');

			//Now we upsert the record, based on the next best action.
			objWrapper.strActionTarget = objNextBestAction.Action_Target__c;
			objWrapper.strActionData = objNextBestAction.Action_Data__c;
			GlobalNextBestActionController.getRecordUpserted(objWrapper);

			//Now we delete the record, based on the next best action.
			objWrapper.strActionTarget = objNextBestAction.Action_Target__c;
			objWrapper.strActionData = '{"Id": "' + objRecord.Id + '"}';
			GlobalNextBestActionController.getRecordDeleted(objWrapper);
			Test.stopTest();
        //}
    }
	
	/*
	 Method Name : testInvalidFormula
	 Description : Testing invalid formula
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testInvalidFormula() {
        System.runAs(createTestUser('System Administrator', true)) {
			GlobalNextBestActionWrapperClass objWrapper = new GlobalNextBestActionWrapperClass();
			Account objRecord = [SELECT Id FROM Account];
			Next_Best_Action__c objNextBestAction;

			//We prepare the data.
			objWrapper.idRecord = objRecord.Id;
			objNextBestAction = new Next_Best_Action__c();
			objNextBestAction.Action_Data__c = '{"Name": "Test2", "BillingCountry": "US"}';
			objNextBestAction.Action_Target__c = 'Account';
			objNextBestAction.Action_Type__c = 'Upsert record';
			objNextBestAction.Active__c = true;
			objNextBestAction.Criteria__c = 'OR())';
			objNextBestAction.Criteria_Type__c = 'Formula';
			objNextBestAction.Object__c = 'Account';
			objNextBestAction.Order__c = 1;
			objNextBestAction.Recommendation__c = 'Test';
			objNextBestAction.Threshold__c = 1;
			objNextBestAction.Threshold_Criteria__c = 'Greater than or equal to';
			insert objNextBestAction;

            //Now we get the records.
			Test.startTest();
			try {
				GlobalNextBestActionController.getRecommendations(objWrapper);
			} catch(Exception objException) {
				System.assertNotEquals(objException == null, true, 'Only valid rules.');
			}
			try {
				GlobalNextBestActionController.getFormulaEvaluated('(1, EQUALS(1,1))');
			} catch(Exception objException) {
				System.assertNotEquals(objException == null, true, 'Only valid rules.');
			}
			Test.stopTest();
        }
    }
	
	/*
	 Method Name : testEvaluationMethods
	 Description : Testing evaluation methods.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testEvaluationMethods() {
        System.runAs(createTestUser('System Administrator', true)) {

			//We prepare the data.
			Next_Best_Action_Query__c objChildQuery = new Next_Best_Action_Query__c();
			objChildQuery.Active__c = true;
			objChildQuery.Identifier__c = '1';
			objChildQuery.Query__c = 'SELECT count() FROM Account WHERE Id = \'{!Id}\'';
			objChildQuery.Threshold__c = 1;
			objChildQuery.Threshold_Criteria__c = 'Greater than or equal to';

            //Now we get the records.
			Test.startTest();
			GlobalNextBestActionController.getLogicEvaluated('Account', 'AND({!1})', new List<Next_Best_Action_Query__c> { objChildQuery });
			GlobalNextBestActionController.getQueryVerified('Account', 'SELECT count() FROM Account', '1', 'Greater than or equal to');
			try {
				GlobalNextBestActionController.getLogicEvaluated('Account', 'AND({!1}, {!2})', new List<Next_Best_Action_Query__c> { objChildQuery });
			} catch(Exception objException) {
				System.assertNotEquals(objException == null, true, 'Only valid logic.');
			}
			try {
				GlobalNextBestActionController.getQueryVerified('Account', 'SELECT Id FROM Account', '1', 'Greater than or equal to');
			} catch(Exception objException) {
				System.assertNotEquals(objException == null, true, 'Only valid logic.');
			}
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