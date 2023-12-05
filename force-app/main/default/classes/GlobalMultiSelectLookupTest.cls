/*
 * Name			:	GlobalMultiSelectLookupTest
 * Author		:	Monserrat Pedroza
 * Created Date	: 	3/7/2022
 * Description	:	Test class for GlobalMultiSelectLookupController

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		3/7/2022		N/A				Initial version.			N/A
 */
@isTest
public with sharing class GlobalMultiSelectLookupTest {
	
	/*
	 Method Name : testLoadRecords
	 Description : Testing Loading records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testLoadRecords() {
        System.runAs(createTestUser('System Administrator', true)) {
			GlobalMultiSelectLookupWrapperClass objRequest = new GlobalMultiSelectLookupWrapperClass();
			List<GlobalMultiSelectLookupWrapperClass> lstResults;

			//We prepare the request.
			objRequest.intLimitResults = 10;
			objRequest.strAdditionalFilters = 'AND UserType = \'Standard\'';
			objRequest.strFilterFieldAPIName = 'Name';
			objRequest.strKeyword = 'Test';
			objRequest.strObjectName = 'User';

            //Now we get the records.
			Test.startTest();
			lstResults = GlobalMultiSelectLookupController.loadRecords(objRequest);
			objRequest.strKeyword = null;
			objRequest.strAdditionalFilters = null;
			lstResults = GlobalMultiSelectLookupController.loadRecords(objRequest);
			objRequest.strFilterFieldAPIName = null;
			objRequest.strValueFormat = '{!Name} - {!Email}';
			objRequest.mapFilterFieldAPINames = new Map<String, String>();
			objRequest.mapFilterFieldAPINames.put('Name', 'Test');
			objRequest.mapFilterFieldAPINames.put('Alias', 'Test');
			lstResults = GlobalMultiSelectLookupController.loadRecords(objRequest);
			System.assertNotEquals(lstResults == null, true, 'Unable to get the record.');
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