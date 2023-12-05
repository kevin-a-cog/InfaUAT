/*
 * Name			:	CSMOpportunityTriggerHelperTestClass
 * Author		:	Monserrat Pedroza
 * Created Date	: 	4/26/2022
 * Description	:	CSM Opportunity Trigger Handler test class.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		4/26/2022		N/A				Initial version.			N/A
 */
@isTest(seeAllData = false)
public with sharing class CSMOpportunityTriggerHelperTestClass {
	
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

		//Now we create the Interlock.
		Related_Opportunity_Plan__c objInterlock = new Related_Opportunity_Plan__c();
		objInterlock.Account__c = objAccount.Id;
		objInterlock.Opportunity__c = objOpportunity.Id;
		objInterlock.Plan__c = objPlan.Id;
		objInterlock.Is_Template__c = true;
		objInterlock.Milestone__c = objMilestone.Id;
		objInterlock.RecordTypeId = Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByName().get('Renewal(SMG)').getRecordTypeId();
		insert objInterlock;
    }
	
	/*
	 Method Name : test120InFuture
	 Description : Testing Close Date in 120 days.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void test120InFuture() {
        System.runAs(createTestUser('System Administrator', true)) {
			Opportunity objOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
			List<Id> lstoppid = new List<Id>();
			lstoppid.add(objOpportunity.id);
			
			//objOpportunity.CloseDate = Date.today().addDays(120);

            //Now we update the records.
			Test.startTest();
			CSMOpportunityTriggerHelper.renewalOpportunitiesClosingIn120Days(lstoppid);
			//System.assertNotEquals(objOpportunity == null, true, 'Unable to update records.');
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