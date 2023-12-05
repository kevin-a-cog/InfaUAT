/*
 * Name			:	CSMPlanRisksTest
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/14/2021
 * Description	:	Manage Risk & Issues test class.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/14/2021		N/A				Initial version.			N/A
 */
@isTest(seeAllData = false)
public with sharing class CSMPlanRisksTest {
	
	/*
	 Method Name : setup
	 Description : Test setup method.
	 Parameters	 : None
	 Return Type : None
	 */
    @testSetup 
    public static void setup() {
        Id riskRt = Schema.SObjectType.Risk_Issue__c.getRecordTypeInfosByName().get('Risk').getRecordTypeId();
		//Now we create a Plan.
		Plan__c objPlan = new Plan__c();
		objPlan.Name = 'Test';
        objPlan.Plan_Operational_Model__c='Named CSM';
		insert objPlan;

		//We create a Risk Issue.
        Risk_Issue__c objRiskIssue = new Risk_Issue__c(RecordTypeId=riskRt);
		objRiskIssue.Name = 'Test';
		objRiskIssue.Type__c = 'Adoption ';
		objRiskIssue.Risk_Reason__c = 'Acquisition';
		insert objRiskIssue;
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
            Plan__c objPlan = [SELECT Id FROM Plan__c LIMIT 1];
            System.assertNotEquals(CSMPlanRisksController.getRecords(objPlan.Id) == null, true, 'Unable to get records.');
            
            Risk_Issue__c objRiskIssue = [SELECT Id FROM Risk_Issue__c LIMIT 1];
            CSMPlanRisksController.getRecords(objRiskIssue.Id);
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
            Risk_Issue__c objRecord = [SELECT Id FROM Risk_Issue__c LIMIT 1];
			List<Risk_Issue__c> lstRecords = new List<Risk_Issue__c>();

            //Now we prepare the data.
            lstRecords.add(objRecord);

			//Now we delete the records.
			//CSMPlanRisksController.getRecordsDeleted(lstRecords);

            //Now we get the records history.
            //System.assertNotEquals([SELECT Id FROM Risk_Issue__c] == null, true, 'No records were deleted.');
        }
    }
	
	/*
	 Method Name : validateRisk
	 Description : Testing validateRisk records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void validateRiskTest() {
		Plan__c objPlan = [SELECT Id FROM Plan__c LIMIT 1];
		CSMPlanRisksController.validateRisk(objPlan.Id);
	}
	
	/*
	 Method Name : testWrapperClass
	 Description : Testing wrapper class fields.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testWrapperClass() {
        System.runAs(createTestUser('System Administrator', true)) {
			GlobalDataTableWrapperClass objRecord = new GlobalDataTableWrapperClass();
			GlobalDataTableWrapperClass.ColumnWrapperClass objColumn = new GlobalDataTableWrapperClass.ColumnWrapperClass();

			//We first set values.
			objRecord.lstColumns = new List<GlobalDataTableWrapperClass.ColumnWrapperClass>();
			objColumn.target = '_blank';
			objColumn.objType = Schema.DisplayType.Picklist;
			objRecord.lstColumns.add(objColumn);

			//Now we get values.
            System.assertNotEquals(objColumn.type == null, true, 'Invalid value.');
			objColumn.objType = Schema.DisplayType.Boolean;
            System.assertNotEquals(objColumn.type == null, true, 'Invalid value.');
			objColumn.objType = Schema.DisplayType.Email;
            System.assertNotEquals(objColumn.type == null, true, 'Invalid value.');
			objColumn.objType = Schema.DisplayType.Date;
            System.assertNotEquals(objColumn.type == null, true, 'Invalid value.');
			objColumn.objType = Schema.DisplayType.Double;
            System.assertNotEquals(objColumn.type == null, true, 'Invalid value.');
			objColumn.objType = Schema.DisplayType.Percent;
            System.assertNotEquals(objColumn.type == null, true, 'Invalid value.');
			objColumn.objType = Schema.DisplayType.Reference;
			objColumn.fieldName = '__r.Id';
            System.assertNotEquals(objColumn.type == null, true, 'Invalid value.');
			objColumn.fieldName = '__r.Id';
            System.assertNotEquals(objColumn.type == null, true, 'Invalid value.');
			objColumn.fieldName = '.Id';
            System.assertNotEquals(objColumn.type == null, true, 'Invalid value.');
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