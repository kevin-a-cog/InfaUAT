/*
    @created by       : Ambica 
    @created on       : 09/03/2021
    @Purpose          : Test class for 
    @Testclass        : GCS_ManagerWorkspaceControllerTestV2
    @JIRA             : 
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************

 
 */
@isTest(seeAllData = false)
public class GCS_ManagerWorkspaceControllerTestV2 {

    @testSetup
    static void setupObjectTestData() {
        List<Profile> employeeProfile = [SElECT Id, Name FROM Profile WHERE Name='System Administrator'];
        UserRole ur = [SELECT Id FROM UserRole Where DeveloperName = 'WW_Sales_EVP' limit 1];
        List<user> lstUser = new List<user>();
        UtilityTestData.mUserData.put('ProfileId',employeeProfile[0].id+'');
        UtilityTestData.mUserData.put('Username','mtest@m.t');
        UtilityTestData.mUserData.put('Email','mtest@m.t');
        UtilityTestData.mUserData.put('Alias','alias');
        UtilityTestData.mUserData.put('CommunityNickname','mtest');
        UtilityTestData.mUserData.put('UserRoleId',ur.id);
        UtilityTestData.mUserData.put('TimeZoneSidKey','GMT');
        UtilityTestData.mUserData.put('LocaleSidKey','en_US');
        UtilityTestData.mUserData.put('EmailEncodingKey','ISO-8859-1');
        UtilityTestData.mUserData.put('LanguageLocaleKey','en_US');
        UtilityTestData.mUserData.put('LastName','last');
        UtilityTestData.mUserData.put('CompanyName','TEST');
        UtilityTestData.mUserData.put('IsActive','true');
        UtilityTestData.mUserData.put('GCS_Team__c','APAC-APS');
        UtilityTestData.mUserData.put( 'ManagerId',UserInfo.getUserId());
        sObject userSobj = new User();
        userSobj = UtilityTest.putFieldRecord(userSobj, UtilityTestData.mUserData);   
        lstUser = (List<USer>) UtilityTest.makeInsert(new List<sObject>{userSobj});
    }

    static testmethod void testCaseViews(){
		Case objLocalCase;
        List<String> Queues = new List<String>();
        List<String> Teams = new List<String>();
		List<Case> lstCases = new List<Case>();

        Schema.DescribeFieldResult Queuevalues = GCS_Subscription__c.Queues__c.getDescribe();
        for(Schema.PicklistEntry val : Queuevalues.getPicklistValues()){
            Queues.add(val.getValue());
        }
        Schema.DescribeFieldResult TeamValues = GCS_Subscription__c.Teams__c.getDescribe();
        for(Schema.PicklistEntry val : TeamValues.getPicklistValues()){
            Teams.add(val.getValue());
        }
		for(Group objGroup : [SELECT Id FROM Group WHERE Group.Type = 'Queue' AND DeveloperName IN ('GCS_CHINA') LIMIT 1]){
			objLocalCase = new Case();
			objLocalCase.OwnerId = objGroup.Id;
			objLocalCase.Priority = 'P1';
			objLocalCase.Success_Offering__c = 'Standard';
			objLocalCase.Component__c = 'Accelerator';
			objLocalCase.Is_Internal_Or_External_Case__c = 'Internal';
			objLocalCase.IR_in_Mins__c = 0;
			objLocalCase.IsEscalated = true;
			objLocalCase.Next_Action__c = 'Case Owner';
			objLocalCase.Case_Last_Activity__c = Date.today().addDays(-30);
			lstCases.add(objLocalCase);
		}
		insert lstCases;
		Case objCase = new Case();
		insert objCase;
		Engagement__c objEngagement = new Engagement__c();
		objEngagement.RecordTypeId = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('Support Escalation').getRecordTypeId();
		insert objEngagement;
		Case_Comment__c objCaseComment = new Case_Comment__c();
		objCaseComment.Case__c = objCase.Id;
		objCaseComment.Type__c = 'Callback';
		objCaseComment.Is_Replied_To__c = false;
		insert objCaseComment;

		//Now we execute the methods.
		Test.startTest();
        GCS_ManagerWorkspaceControllerV2.getSubscription();
		GCS_ManagerWorkspaceControllerV2.getSubscriptionWithoutCache();
        GCS_ManagerWorkspaceControllerV2.getAllQueuesData(Queues,false,false);
		GCS_ManagerWorkspaceControllerV2.getAllQueuesDataRefresh(Queues,false,false);
        GCS_ManagerWorkspaceControllerV2.getMyTeamData(false);
		GCS_ManagerWorkspaceControllerV2.getMyTeamDataRefresh(false);
        GCS_ManagerWorkspaceControllerV2.getAllTeamData('APAC-APS;APAC-APS-BDM',false);
		GCS_ManagerWorkspaceControllerV2.getAllTeamDataRefresh('APAC-APS;APAC-APS-BDM',false);
		GCS_ManagerWorkspaceControllerV2.getListViewId(Queues,false,false,false);
        GCS_ManagerWorkspaceControllerV2.getListViewId(Queues,true,false,false);
		Test.stopTest();
    }

    static testmethod void testCaseViews2(){
		Case objLocalCase;
        List<String> Queues = new List<String>();
        List<String> Teams = new List<String>();
		List<Case> lstCases = new List<Case>();

        Schema.DescribeFieldResult Queuevalues = GCS_Subscription__c.Queues__c.getDescribe();
        for(Schema.PicklistEntry val : Queuevalues.getPicklistValues()){
            Queues.add(val.getValue());
        }
        Schema.DescribeFieldResult TeamValues = GCS_Subscription__c.Teams__c.getDescribe();
        for(Schema.PicklistEntry val : TeamValues.getPicklistValues()){
            Teams.add(val.getValue());
        }
		for(Group objGroup : [SELECT Id FROM Group WHERE Group.Type = 'Queue' AND DeveloperName IN ('GCS_CHINA') LIMIT 1]){
			objLocalCase = new Case();
			objLocalCase.OwnerId = objGroup.Id;
			objLocalCase.Priority = 'P1';
			objLocalCase.Success_Offering__c = 'Standard';
			objLocalCase.Component__c = 'Accelerator';
			objLocalCase.Is_Internal_Or_External_Case__c = 'Internal';
			objLocalCase.IR_in_Mins__c = 0;
			objLocalCase.IsEscalated = true;
			objLocalCase.Next_Action__c = 'Case Owner';
			objLocalCase.Case_Last_Activity__c = Date.today().addDays(-30);
			lstCases.add(objLocalCase);
		}
		insert lstCases;
		Case objCase = new Case();
		insert objCase;
		Engagement__c objEngagement = new Engagement__c();
		objEngagement.RecordTypeId = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('Support Escalation').getRecordTypeId();
		insert objEngagement;
		Case_Comment__c objCaseComment = new Case_Comment__c();
		objCaseComment.Case__c = objCase.Id;
		objCaseComment.Type__c = 'Callback';
		objCaseComment.Is_Replied_To__c = false;
		insert objCaseComment;

		//Now we execute the methods.
		Test.startTest();
		GCS_ManagerWorkspaceControllerV2.getListViewId(Queues,false,true,false);
		GCS_ManagerWorkspaceControllerV2.getListViewId(Queues,false,false,true);
		

		List<Id> caseIdList=new List<Id>();
		for(Case cs:lstCases){
			caseIdList.add(cs.Id);
		}

		GCS_ManagerWorkspaceControllerV2.getRecordAssigned(null,caseIdList);
		
		Test.stopTest();
    }

    
    static testmethod void testRaiseHandiews(){
		Case objLocalCase;
        List<String> Queues = new List<String>();
        List<String> Teams = new List<String>();
		List<Case> lstCases = new List<Case>();

        Schema.DescribeFieldResult Queuevalues = GCS_Subscription__c.Queues__c.getDescribe();
        for(Schema.PicklistEntry val : Queuevalues.getPicklistValues()){
            Queues.add(val.getValue());
        }
        Schema.DescribeFieldResult TeamValues = GCS_Subscription__c.Teams__c.getDescribe();
        for(Schema.PicklistEntry val : TeamValues.getPicklistValues()){
            Teams.add(val.getValue());
        }
		for(Group objGroup : [SELECT Id FROM Group WHERE Group.Type = 'Queue' AND DeveloperName IN ('GCS_CHINA') LIMIT 1]){
			objLocalCase = new Case();
			objLocalCase.OwnerId = objGroup.Id;
			objLocalCase.Priority = 'P1';
			objLocalCase.Success_Offering__c = 'Standard';
			objLocalCase.Component__c = 'Accelerator';
			objLocalCase.Is_Internal_Or_External_Case__c = 'Internal';
			objLocalCase.IR_in_Mins__c = 0;
			objLocalCase.IsEscalated = true;
			objLocalCase.Next_Action__c = 'Case Owner';
			objLocalCase.Case_Last_Activity__c = Date.today().addDays(-30);
			lstCases.add(objLocalCase);
		}
		insert lstCases;
		Case objCase = new Case();
		insert objCase;
		Engagement__c objEngagement = new Engagement__c();
		objEngagement.RecordTypeId = Schema.SObjectType.Engagement__c.getRecordTypeInfosByName().get('Support Escalation').getRecordTypeId();
		insert objEngagement;
		Case_Comment__c objCaseComment = new Case_Comment__c();
		objCaseComment.Case__c = objCase.Id;
		objCaseComment.Type__c = 'Callback';
		objCaseComment.Is_Replied_To__c = false;
		insert objCaseComment;

		//Now we execute the methods.
		Test.startTest();
        GCS_ManagerWorkspaceControllerV2.getSubscription();
		GCS_ManagerWorkspaceControllerV2.getSubscriptionWithoutCache();
        GCS_ManagerWorkspaceControllerV2.getAllQueuesData(Queues,true,false);
		GCS_ManagerWorkspaceControllerV2.getAllQueuesDataRefresh(Queues,true,false);
        GCS_ManagerWorkspaceControllerV2.getMyTeamData(true);
		GCS_ManagerWorkspaceControllerV2.getMyTeamDataRefresh(true);
        GCS_ManagerWorkspaceControllerV2.getAllTeamData('APAC-APS;APAC-APS-BDM',true);
		GCS_ManagerWorkspaceControllerV2.getAllTeamDataRefresh('APAC-APS;APAC-APS-BDM',true);
        GCS_ManagerWorkspaceControllerV2.getListViewId(Queues,false,false,false);
		GCS_ManagerWorkspaceControllerV2.getListViewId(Queues,true,false,false);
		GCS_ManagerWorkspaceControllerV2.getListViewId(Queues,false,true,false);
		GCS_ManagerWorkspaceControllerV2.getListViewId(Queues,false,false,true);
		Test.stopTest();
    }
	
	/*
	 Method Name : testFlowOne
	 Description : Testing flow one.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testFlowOne() {
        System.runAs(createTestUser('System Administrator', true)) {
			GCS_Subscription__c objSubscriptionRecord;
			List<String> lstColumns = new List<String>();

			//We create additional data.
			lstColumns.add('P1');
			lstColumns.add('AllOpenCases');
			for(Group objGroup : [SELECT Name FROM Group WHERE Group.Type = 'Queue' LIMIT 1000]) {
				lstColumns.add(objGroup.Name);
			}

			//Now we create the Subscription records.
			objSubscriptionRecord = new GCS_Subscription__c();
			objSubscriptionRecord.Pinned_View__c = 'AllOpenCases';
			objSubscriptionRecord.Case_Views__c = 'AllOpenCases';
			objSubscriptionRecord.Engineering_Workspace_List_View_Sort__c = 'AllOpenCases';
			objSubscriptionRecord.Latest_Eng_Workspace_Splitter_Position__c = '1';
			objSubscriptionRecord.Manager_Workspace_Columns_Order__c = '{"My_GEMS_Columns__c":["P3","P1"]}';
			objSubscriptionRecord.User__c = UserInfo.getUserId();
			insert objSubscriptionRecord;
			objSubscriptionRecord = new GCS_Subscription__c();
			objSubscriptionRecord.Pinned_View__c = 'AllOpenCases';
			objSubscriptionRecord.Case_Views__c = 'AllOpenCases';
			objSubscriptionRecord.Latest_Eng_Workspace_Splitter_Position__c = '1';
			objSubscriptionRecord.Manager_Workspace_Columns_Order__c = '{"My_GEMS_Columns__c":["P3","P1"]}';
			objSubscriptionRecord.User__c = UserInfo.getUserId();
			insert objSubscriptionRecord;

			//Now we test the methods.
			Test.startTest();
			System.assertNotEquals(GCS_ManagerWorkspaceControllerV2.getGEMSDataRefresh(true) == null, true, 'Unable to execute the test.');
			System.assertNotEquals(GCS_ManagerWorkspaceControllerV2.getGEMSDataRefresh(false) == null, true, 'Unable to execute the test.');
			GCS_ManagerWorkspaceControllerV2.getSortingSaved('Manager_Workspace_Engagement_All_Sort__c', '{"strFieldName":"P1","strSortDirection":"desc","strTable":"All"}');
			System.assertNotEquals(GCS_ManagerWorkspaceControllerV2.getSortingPreviouslySaved('Manager_Workspace_Columns_Order__c') == null, true, 'Unable to execute the test.');
			System.assertNotEquals(GCS_ManagerWorkspaceControllerV2.getAllListViewId(lstColumns, true, false, false) == null, true, 'Unable to execute the test.');
			System.assertNotEquals(GCS_ManagerWorkspaceControllerV2.getAllListViewId(lstColumns, false, true, false) == null, true, 'Unable to execute the test.');
			System.assertNotEquals(GCS_ManagerWorkspaceControllerV2.getAllListViewId(lstColumns, false, false, true) == null, true, 'Unable to execute the test.');
			GCS_ManagerWorkspaceControllerV2.getColumnOrderSaved('My_GEMS_Columns__c', lstColumns);
			System.assertNotEquals(GCS_ManagerWorkspaceControllerV2.getColumnOrderPreviouslySaved('My_GEMS_Columns__c') == null, true, 'Unable to execute the test.');
			/*System.assertNotEquals(GCS_ManagerWorkspaceControllerV2.setColumnOrderPreviouslySavedOnSubscriptionRecords([SELECT Manager_Workspace_Columns_Order__c FROM GCS_Subscription__c]) == null, 
					true, 'Unable to execute the test.');*/
			Test.stopTest();
		}
	}
	
	/*
	 Method Name : testFlowTwo
	 Description : Testing flow two.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testFlowTwo() {
        System.runAs(createTestUser('System Administrator', true)) {
			GCS_Subscription__c objSubscriptionRecord;
			List<String> lstColumns = new List<String>();

			//We create additional data.
			lstColumns.add('P1');
			lstColumns.add('AllOpenCases');
			for(Group objGroup : [SELECT Name FROM Group WHERE Group.Type = 'Queue' LIMIT 1000]) {
				lstColumns.add(objGroup.Name);
			}

			//Now we test the methods.
			Test.startTest();
			GCS_ManagerWorkspaceControllerV2.getColumnOrderSaved('My_GEMS_Columns__c', lstColumns);
			System.assertNotEquals(GCS_ManagerWorkspaceControllerV2.getColumnOrderPreviouslySaved('My_GEMS_Columns__c') == null, true, 'Unable to execute the test.');
			/*System.assertNotEquals(GCS_ManagerWorkspaceControllerV2.setColumnOrderPreviouslySavedOnSubscriptionRecords([SELECT Manager_Workspace_Columns_Order__c FROM GCS_Subscription__c]) == null, 
					true, 'Unable to execute the test.');*/
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