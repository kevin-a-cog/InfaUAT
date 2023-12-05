/*
 * Name			:	GlobalDataTableTest
 * Author		:	Monserrat Pedroza
 * Created Date	: 	10/12/2021
 * Description	:	Data Tables test class.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		10/12/2021		N/A				Initial version.			N/A
 */
@isTest(seeAllData = false)
public with sharing class GlobalDataTableTest {
	
	/*
	 Method Name : testRecordFetching
	 Description : Testing fetching records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testRecordFetching() {
        System.runAs(createTestUser('System Administrator', true)) {
			Object objValue;
            GlobalDataTableWrapperClass objRequest = new GlobalDataTableWrapperClass();
			GlobalDataTableWrapperClass.ColumnWrapperClass objColumnWrapper = new GlobalDataTableWrapperClass.ColumnWrapperClass();
			GlobalDataTableWrapperClass.RecordWrapperClass objRecordWrapper = new GlobalDataTableWrapperClass.RecordWrapperClass();
			List<String> lstValues = new List<String>();
			List<SObject> lstObjectValues = new List<SObject>();
			List<GlobalDataTableWrapperClass.RecordWrapperClass> lstRecordValues = new List<GlobalDataTableWrapperClass.RecordWrapperClass>();

			//Now we prepare the initial data.
			objRequest.strObjectName = 'Plan__c';
			objRequest.lstFieldNames = new List<String>();
			objRequest.lstFieldNames.add('Name');
			objRequest.lstFieldNames.add('Plan_status_picklist__c');
			objRequest.lstFieldNames.add('Account__c');
			objRequest.lstFieldNames.add('Count_of_Open_Opportunities__c');
			objRequest.lstFieldNames.add('e2a_Unread_Email_Count__c');
			objRequest.lstFieldNames.add('Next_Expected_Adoption_Factor_Date__c');

			//Now we test the method.
			Test.startTest();

			//First we test the custom list.
			objRequest = GlobalDataTableUtilitiesClass.getDataTableDetails(objRequest);
            System.assertNotEquals(objRequest == null, true, 'Unable to get table details.');
			for(GlobalDataTableWrapperClass.ColumnWrapperClass objColumn : objRequest.lstColumns) {
				objColumn.typeAttributes = null;
				objValue = objColumn.type;
				objValue = objColumn.subtype;
			}

			//Now we test the field set.
			objRequest = new GlobalDataTableWrapperClass();
			objRequest.strObjectName = 'Plan__c';
			objRequest.strFielSetName = 'Make_Playbook_Update_Fields';
			objRequest = GlobalDataTableUtilitiesClass.getDataTableDetails(objRequest);
			System.assertNotEquals(objRequest == null, true, 'Unable to get table details.');
			for(GlobalDataTableWrapperClass.ColumnWrapperClass objColumn : objRequest.lstColumns) {
				objValue = objColumn.type;
				objValue = objColumn.subtype;
			}
			objRequest = new GlobalDataTableWrapperClass();
			objRequest.strObjectName = 'Plan__c';
			objRequest.strFielSetName = 'Create_Playbook_Table';
			objRequest = GlobalDataTableUtilitiesClass.getDataTableDetails(objRequest);
			System.assertNotEquals(objRequest == null, true, 'Unable to get table details.');
			for(GlobalDataTableWrapperClass.ColumnWrapperClass objColumn : objRequest.lstColumns) {
				objValue = objColumn.type;
				objValue = objColumn.subtype;
			}
			objRequest = new GlobalDataTableWrapperClass();
			objRequest.strObjectName = 'Plan__c';
			objRequest.strFielSetName = 'Create_Playbook_Table_Filters';
			objRequest = GlobalDataTableUtilitiesClass.getDataTableDetails(objRequest);
			System.assertNotEquals(objRequest == null, true, 'Unable to get table details.');
			for(GlobalDataTableWrapperClass.ColumnWrapperClass objColumn : objRequest.lstColumns) {
				objValue = objColumn.type;
				objValue = objColumn.subtype;
			}

			//Now we test special objects.
			objRequest = new GlobalDataTableWrapperClass();
			objRequest.strObjectName = 'Case';
			objRequest.lstFieldNames = new List<String>();
			objRequest.lstFieldNames.add('CaseNumber');
			objRequest = GlobalDataTableUtilitiesClass.getDataTableDetails(objRequest);
            System.assertNotEquals(objRequest == null, true, 'Unable to get table details.');
			objRequest = new GlobalDataTableWrapperClass();
			objRequest.strObjectName = 'Event';
			objRequest.lstFieldNames = new List<String>();
			objRequest.lstFieldNames.add('Subject');
			objRequest = GlobalDataTableUtilitiesClass.getDataTableDetails(objRequest);
            System.assertNotEquals(objRequest == null, true, 'Unable to get table details.');
			objRequest = new GlobalDataTableWrapperClass();
			objRequest.strObjectName = 'Contract';
			objRequest.lstFieldNames = new List<String>();
			objRequest.lstFieldNames.add('ContractNumber');
			objRequest = GlobalDataTableUtilitiesClass.getDataTableDetails(objRequest);
			System.assertNotEquals(objRequest == null, true, 'Unable to get table details.');

			//Now we test the wrapper class.
			objValue = objRequest.strRecordId;
			objValue = objRequest.strMainFilterFieldAPIName;
			objValue = objRequest.strRecordId;
			objValue = objRequest.lstRecordIds;
			objValue = objRequest.lstAdditionalFilters;
			objValue = objRequest.lstRecords;
			objValue = objRequest.lstWrappedRecords;
			objValue = objColumnWrapper.boolContainsHTML;
			objValue = objColumnWrapper.boolContainsHTML;
			objValue = objColumnWrapper.initialWidth;
			objValue = objColumnWrapper.target;
			objValue = objColumnWrapper.cellAttributes;
			objValue = objRecordWrapper.objRecord;
			objValue = objRecordWrapper.lstChildRecords;
			objValue = objRecordWrapper.mapRecordCustomValues;
			objValue = objRecordWrapper.mapChildWrappedRecords;
			for(GlobalDataTableWrapperClass.ColumnWrapperClass objColumn : objRequest.lstColumns) {
				objColumn.objType = Schema.DisplayType.Email;
				objValue = objColumn.type;
				objColumn.objType = Schema.DisplayType.Percent;
				objValue = objColumn.type;
				objColumn.boolContainsHTML = true;
				objValue = objColumn.type;
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
        for(PermissionSet objPermissionSet :[SELECT Id,Type FROM PermissionSet WHERE Name LIKE 'CSM_Success%']) {
			if(objPermissionSet.Type=='Regular'){
            	lstPermissionSets.add(new PermissionSetAssignment(AssigneeId = objTestUser.id, PermissionSetId = objPermissionSet.Id));
			}
        }
        if(lstPermissionSets?.size()>0){
            insert lstPermissionSets;
        }

		//Now we return the result.
        return objTestUser;
    }
		/*
	 Method Name : getDatatableDetailsAndRecordsTest
	 Description : Testing fetching records.
	 Parameters	 : None
	 Return Type : None
	 */
	@isTest
	public static void getDatatableDetailsAndRecordsTest(){
		GlobalDataTableWrapperClass.QueryFilter objQueryFilter = new GlobalDataTableWrapperClass.QueryFilter();
		objQueryFilter.strFilterCondition = 'AND';
		objQueryFilter.lstFilters = new List<GlobalDataTableWrapperClass.Filter>();
		GlobalDataTableWrapperClass.Filter objFilter = new GlobalDataTableWrapperClass.Filter();
		objFilter.strFilterField = 'Status__c';
		objFilter.strFilterOperator = '=';
		objFilter.strFilterValue = '\'Approved\'';
		objQueryFilter.lstFilters.add(objFilter);

		objFilter = new GlobalDataTableWrapperClass.Filter();
		objFilter.strFilterField = 'End_Date__c';
		objFilter.strFilterOperator = '>=';
		objFilter.strFilterValue = 'TODAY';
		objQueryFilter.lstFilters.add(objFilter);

		GlobalDataTableUtilitiesClass.getDatatableDetailsAndRecords('', 'Certification_Request__c', 'Cancel_Certification_Request', objQueryFilter);
	}
    
    
}