/*
 * Name			:	EngagementUnitServiceTest
 * Author		:	Monserrat Pedroza
 * Created Date	: 	06/01/2022
 * Description	:	Engagement Unit Service test class.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		06/01/2022		N/A				Initial version.			N/A
 */
@isTest(seeAllData = false)
public with sharing class EngagementUnitServiceTest {
	
	/*
	 Method Name : setup
	 Description : Test setup method.
	 Parameters	 : None
	 Return Type : None
	 */
    @testSetup 
    public static void setup() {
		frameworkDataSetup();
    }
	
	/*
	 Method Name : testVerifying
	 Description : Testing Verifying records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testVerifying() {
        System.runAs(createTestUser('System Administrator', true)) {
			Id idAccount = [SELECT Id FROM Account LIMIT 1].Id;
			EngagementUnitServiceWrapper objRequest = new EngagementUnitServiceWrapper();

			//We set the values.
			objRequest.intUnits = 5;
			objRequest.idAccount = idAccount;
			objRequest.strType = 'Success';

            //Now we get the records.
			Test.startTest();
			objRequest = EngagementUnitService.validateEngagementUnits(objRequest);
            System.assertNotEquals(objRequest.boolResult == false, true, 'Unable to vierfy.');
			Test.stopTest();
        }
    }
	
	/*
	 Method Name : testConsuming
	 Description : Testing Consuming records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testConsuming() {
        System.runAs(createTestUser('System Administrator', true)) {
			Id idAccount = [SELECT Id FROM Account LIMIT 1].Id;
			Id idContact = [SELECT Id FROM Contact LIMIT 1].Id;
			EngagementUnitServiceWrapper objRequest = new EngagementUnitServiceWrapper();

			//We set the values.
			objRequest.intUnits = 101;
			objRequest.idAccount = idAccount;
			objRequest.strType = 'Success';
			objRequest.strContextId = 'Test2';
			objRequest.idContact = idContact;
			objRequest.idUser = UserInfo.getUserId();

            //Now we get the records.
			Test.startTest();
			objRequest = EngagementUnitService.consumeEngagementUnits(objRequest);
            System.assertNotEquals(objRequest.boolResult == false, true, 'Unable to consume.');
			Test.stopTest();
        }
    }
	
	/*
	 Method Name : testUpdating
	 Description : Testing Updating records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testUpdating() {
        System.runAs(createTestUser('System Administrator', true)) {
			Id idAccount = [SELECT Id FROM Account LIMIT 1].Id;
			Id idContact = [SELECT Id FROM Contact LIMIT 1].Id;
			EngagementUnitServiceWrapper objRequest = new EngagementUnitServiceWrapper();

			//We set the values.
			objRequest.intUnits = 5;
			objRequest.idAccount = idAccount;
			objRequest.strType = 'Success';
			objRequest.strContextId = 'Test2';
			objRequest.idContact = idContact;
			objRequest.idUser = UserInfo.getUserId();
			objRequest.lstContextIds = new List<String>();
			objRequest.lstContextIds.add('Test2');
			objRequest.strStatus = 'Cancelled';

            //Now we get the records.
			Test.startTest();
			EngagementUnitService.consumeEngagementUnits(objRequest);
			EngagementUnitService.updateEngagementUnitConsumptionStatus(objRequest);
            System.assertNotEquals(objRequest.boolResult == false, true, 'Unable to update.');

			//Now we try a direct update of an EUC record, of a field different from Status__c.
			for(Engagement_Unit_Consumption__c objRecord : [SELECT Id FROM Engagement_Unit_Consumption__c LIMIT 1]) {
				objRecord.Context_Id__c = 'TEST';
				try {
					update objRecord;
				} catch(Exception objException) {
					System.assertNotEquals(objRequest.boolResult == null, false, 'Able to update.');
				}
			}
			Test.stopTest();
        }
    }

	/*
	 Method Name : frameworkDataSetup
	 Description : This method sets the framework data.
	 Parameters	 : None
	 Return Type : None
	 */
    public static void frameworkDataSetup() {
		Id idContentDocument;

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

		//We create an Engagement Unit.
		Engagement_Unit__c objEngagementUnit = new Engagement_Unit__c();
		objEngagementUnit.Account__c = objAccount.Id;
		objEngagementUnit.Awarded_By__c = 'CSM';
		objEngagementUnit.Entitled_Units__c = 100;
		objEngagementUnit.Consumed_Units__c = 0;
		objEngagementUnit.Expiry_Date__c = System.today().addMonths(1);
		objEngagementUnit.Start_Date__c = System.today().addMonths(-1);
		objEngagementUnit.Type__c = 'Success';
		insert objEngagementUnit;
		objEngagementUnit = new Engagement_Unit__c();
		objEngagementUnit.Account__c = objAccount.Id;
		objEngagementUnit.Awarded_By__c = 'CSM';
		objEngagementUnit.Entitled_Units__c = 100;
		objEngagementUnit.Consumed_Units__c = 0;
		objEngagementUnit.Expiry_Date__c = System.today().addMonths(1);
		objEngagementUnit.Start_Date__c = System.today().addMonths(-1);
		objEngagementUnit.Type__c = 'All';
		insert objEngagementUnit;
	}

	/*
	 Method Name : createTestUser
	 Description : This method serves as a Utility method to create Test users.
	 Parameters	 : String, called from createTestUser, strProfileName Profile name.
	 			   Boolean, called from createTestUser, boolInsertUser If the user should be inserted or not.
	 Return Type : User record.
	 */
    public static User createTestUser(String strProfileName, Boolean boolInsertUser) {
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
        for(PermissionSet objPermissionSet :[SELECT Id FROM PermissionSet WHERE Name = 'CSM_Success_Operations']) {
            lstPermissionSets.add(new PermissionSetAssignment(AssigneeId = objTestUser.id, PermissionSetId = objPermissionSet.Id));
        }
        if(lstPermissionSets?.size() > 0) {
            insert lstPermissionSets;
        }

		//Now we return the result.
        return objTestUser;
    }
}