/*
 * Name			:	CSMApplyPlaybookTest
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/19/2021
 * Description	:	Apply Playbook test class.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/19/2021		N/A				Initial version.			N/A
 */
@isTest(seeAllData = false)
public with sharing class CSMApplyPlaybookTest {
	
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

		//Now we create an Opportunity.
		Opportunity objOpportunity = new Opportunity();
		objOpportunity.Name = 'Test';
		objOpportunity.AccountId = objAccount.Id;
		objOpportunity.StageName = 'Lead';
		objOpportunity.CloseDate = System.today().addDays(1);
		objOpportunity.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
		insert objOpportunity;

		//Now we create a Plan.
		Plan__c objPlan = new Plan__c();
		objPlan.Name = 'TestNew';
		objPlan.Is_Template__c = false;
		objPlan.Account__c = objAccount.Id;
		insert objPlan;
		objPlan = new Plan__c();
		objPlan.Name = 'Test';
		objPlan.Is_Template__c = true;
		objPlan.Account__c = objAccount.Id;
		insert objPlan;

		//Now we create the Objective.
		Objective__c objObjective = new Objective__c();
		objObjective.Is_Template__c = true;
		objObjective.Plan__c = objPlan.Id;
		insert objObjective;

		//Now we create the Milestone.
		Milestone__c objMilestone = new Milestone__c();
		objMilestone.Is_Template__c = true;
		objMilestone.Objective__c = objObjective.Id;
		insert objMilestone;

		//Now we create the Engagement.
		Engagement__c objEngagement = new Engagement__c();
		objEngagement.Name = 'test';
		objEngagement.Is_Template__c = true;
		objEngagement.Milestone__c = objMilestone.Id;
		insert objEngagement;

		//Now we create the Interlock.
		Related_Opportunity_Plan__c objInterlock = new Related_Opportunity_Plan__c();
		objInterlock.Account__c = objAccount.Id;
		objInterlock.Opportunity__c = objOpportunity.Id;
		objInterlock.Plan__c = objPlan.Id;
		objInterlock.Is_Template__c = true;
		objInterlock.Milestone__c = objMilestone.Id;
		objInterlock.RecordTypeId = Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByName().get('Related Opportunity Plan').getRecordTypeId();
		insert objInterlock;

		//Now we create the Interlock.
		Task objTask = new Task();
		objTask.Subject = 'Test';
		objTask.WhatId = objMilestone.Id;
		objTask.Is_Template__c = true;
		insert objTask;

		//Now we create some rules.
		Clone_Engine__c objRule = new Clone_Engine__c();
		objRule.Object__c = 'Objective__c';
		objRule.Field__c = 'Business_Goal__c';
		objRule.Type__c = 'Clear value';
		objRule.Value__c = 'true';
		objRule.Flows__c = 'Apply Template';
		objRule.Active__c = true;
		insert objRule;
		objRule = new Clone_Engine__c();
		objRule.Object__c = 'Milestone__c';
		objRule.Field__c = 'Planned_Completion_Date__c';
		objRule.Type__c = 'New value';
		objRule.Subtype__c = 'Formula';
		objRule.Value__c = 'TODAY()';
		objRule.Flows__c = 'Apply Template';
		objRule.Active__c = true;
		insert objRule;
		objRule = new Clone_Engine__c();
		objRule.Object__c = 'Related_Opportunity_Plan__c';
		objRule.Field__c = 'Additional_Information__c';
		objRule.Type__c = 'New value';
		objRule.Subtype__c = 'Static';
		objRule.Value__c = 'true';
		objRule.Flows__c = 'Apply Template';
		objRule.Active__c = true;
		insert objRule;
		objRule = new Clone_Engine__c();
		objRule.Object__c = 'Milestone__c';
		objRule.Field__c = 'Key_Milestone__c';
		objRule.Type__c = 'New value';
		objRule.Subtype__c = 'Static';
		objRule.Value__c = 'true';
		objRule.Flows__c = 'Apply Template';
		objRule.Active__c = true;
		insert objRule;
		objRule = new Clone_Engine__c();
		objRule.Object__c = 'Milestone__c';
		objRule.Field__c = 'Planned_Completion_Date__c';
		objRule.Type__c = 'New value';
		objRule.Subtype__c = 'Static';
		objRule.Value__c = String.valueOf(System.today());
		objRule.Flows__c = 'Apply Template';
		objRule.Active__c = true;
		insert objRule;
		objRule = new Clone_Engine__c();
		objRule.Object__c = 'Milestone__c';
		objRule.Field__c = 'Milestone_Type__c';
		objRule.Type__c = 'New value';
		objRule.Subtype__c = 'Static';
		objRule.Value__c = 'Technical Milestone';
		objRule.Flows__c = 'Apply Template';
		objRule.Active__c = true;
		insert objRule;
		objRule = new Clone_Engine__c();
		objRule.Object__c = 'Engagement__c';
		objRule.Field__c = 'OwnerId';
		objRule.Type__c = 'New value';
		objRule.Subtype__c = 'Field reference';
		objRule.Value__c = 'CreatedBy.Id';
		objRule.Flows__c = 'Apply Template';
		objRule.Active__c = true;
		insert objRule;
		objRule = new Clone_Engine__c();
		objRule.Object__c = 'Objective__c';
		objRule.Field__c = 'CreatedDate';
		objRule.Type__c = 'New value';
		objRule.Subtype__c = 'Static';
		objRule.Value__c = String.valueOf(DateTime.now());
		objRule.Flows__c = 'Apply Template';
		objRule.Active__c = true;
		insert objRule;
		objRule = new Clone_Engine__c();
		objRule.Object__c = 'Objective__c';
		objRule.Field__c = 'CreatedDate';
		objRule.Type__c = 'New value';
		objRule.Subtype__c = 'Formula';
		objRule.Value__c = 'NOW()';
		objRule.Flows__c = 'Apply Template';
		objRule.Active__c = true;
		insert objRule;
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

            //Now we get the records.
            System.assertNotEquals(CSMApplyPlaybookController.getRecords() == null, true, 'Unable to get records.');
        }
    }
	
	/*
	 Method Name : testFetchingFilterFields
	 Description : Testing fetching filter fields.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testFetchingFilterFields() {
        System.runAs(createTestUser('System Administrator', true)) {

            //Now we get the fields.
            System.assertNotEquals(CSMApplyPlaybookController.getFilterFields() == null, true, 'No fields were found.');
        }
    }
	
	/*
	 Method Name : testSelectedRecords
	 Description : Testing applying rules.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testSelectedRecords() {
        System.runAs(createTestUser('System Administrator', true)) {
			Objective__c objObjective = [SELECT Id FROM Objective__c WHERE Is_Template__c = true];
			Milestone__c objMilestone = [SELECT Id FROM Milestone__c WHERE Is_Template__c = true];
			Engagement__c objEngagement = [SELECT Id FROM Engagement__c WHERE Is_Template__c = true];
			Related_Opportunity_Plan__c objInterlock = [SELECT Id FROM Related_Opportunity_Plan__c WHERE Is_Template__c = true];
			Task objTask = [SELECT Id FROM Task WHERE Is_Template__c = true];
			Plan__c objPlan = [SELECT Id FROM Plan__c WHERE Name = 'TestNew'];
			CSMBucketWrapper objRequest;
			List<CSMBucketWrapper> lstBuckets = new List<CSMBucketWrapper>();

			//First we set the request.
			objRequest = new CSMBucketWrapper();
			objRequest.intOrder = 1;
			objRequest.strObjectName = 'Objective__c';
			objRequest.lstRecordIds = new List<String> {
				objObjective.Id
			};
			lstBuckets.add(objRequest);
			objRequest = new CSMBucketWrapper();
			objRequest.intOrder = 2;
			objRequest.strObjectName = 'Milestone__c';
			objRequest.lstRecordIds = new List<String> {
				objMilestone.Id
			};
			lstBuckets.add(objRequest);
            objRequest = new CSMBucketWrapper();
			objRequest.intOrder = 0;
			objRequest.strObjectName = 'Engagement__c';
			objRequest.lstRecordIds = new List<String> {
				objEngagement.Id
			};
			lstBuckets.add(objRequest);
			objRequest = new CSMBucketWrapper();
			objRequest.intOrder = 0;
			objRequest.strObjectName = 'Related_Opportunity_Plan__c';
			objRequest.lstRecordIds = new List<String> {
				objInterlock.Id
			};
			lstBuckets.add(objRequest);
			objRequest = new CSMBucketWrapper();
			objRequest.intOrder = 0;
			objRequest.strObjectName = 'Task';
			objRequest.lstRecordIds = new List<String> {
				objTask.Id
			};
			lstBuckets.add(objRequest);

			//Now we clone the records
			CSMApplyPlaybookController.getSelectedRecordsCloned(objPlan.Id, lstBuckets);

			//Now we test preselected ids.
			lstBuckets = new List<CSMBucketWrapper>();
			objRequest = new CSMBucketWrapper();
			objRequest.intOrder = 1;
			objRequest.strObjectName = 'Objective__c';
			objRequest.strPreSelectedObjectiveId = objObjective.Id;
			objRequest.strPreSelectedMilestoneId = objMilestone.Id;
			objRequest.lstRecordIds = new List<String> {
				objObjective.Id
			};
			lstBuckets.add(objRequest);
			objRequest = new CSMBucketWrapper();
			objRequest.intOrder = 2;
			objRequest.strObjectName = 'Milestone__c';
			objRequest.strPreSelectedObjectiveId = objObjective.Id;
			objRequest.strPreSelectedMilestoneId = objMilestone.Id;
			objRequest.lstRecordIds = new List<String> {
				objMilestone.Id
			};
			lstBuckets.add(objRequest);
            objRequest = new CSMBucketWrapper();
			objRequest.intOrder = 0;
			objRequest.strObjectName = 'Engagement__c';
			objRequest.strPreSelectedObjectiveId = objObjective.Id;
			objRequest.strPreSelectedMilestoneId = objMilestone.Id;
			objRequest.lstRecordIds = new List<String> {
				objEngagement.Id
			};
			lstBuckets.add(objRequest);
			objRequest = new CSMBucketWrapper();
			objRequest.intOrder = 0;
			objRequest.strObjectName = 'Related_Opportunity_Plan__c';
			objRequest.strPreSelectedObjectiveId = objObjective.Id;
			objRequest.strPreSelectedMilestoneId = objMilestone.Id;
			objRequest.lstRecordIds = new List<String> {
				objInterlock.Id
			};
			lstBuckets.add(objRequest);
			objRequest = new CSMBucketWrapper();
			objRequest.intOrder = 0;
			objRequest.strObjectName = 'Task';
			objRequest.strPreSelectedObjectiveId = objObjective.Id;
			objRequest.strPreSelectedMilestoneId = objMilestone.Id;
			objRequest.lstRecordIds = new List<String> {
				objTask.Id
			};
			lstBuckets.add(objRequest);
			CSMApplyPlaybookController.getSelectedRecordsCloned(objPlan.Id, lstBuckets);

            //Now we get the fields.
            System.assertNotEquals([SELECT count() FROM Objective__c] <= 1, true, 'No records were created.');
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
        List<PermissionSetAssignment> psAssignList = new List<PermissionSetAssignment>();
        for(PermissionSet ps :[SELECT Id FROM PermissionSet WHERE Name LIKE 'CSM_Success%']){
            PermissionSetAssignment psAssign = new PermissionSetAssignment(AssigneeId = objTestUser.id, PermissionSetId = ps.Id);
            psAssignList.add(psAssign);
        }
        if(psAssignList?.size()>0){
            insert psAssignList;
        }
        return objTestUser;
    }
}