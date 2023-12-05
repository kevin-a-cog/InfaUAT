/*
 * Name			:	IPUHierarchyTest
 * Author		:	Monserrat Pedroza
 * Created Date	: 	25/1/2023
 * Description	:	Test class for IPU Hierarchy controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		25/1/2023		N/A				Initial version.			N/A
 */
@isTest(seeAllData = false)
public with sharing class IPUHierarchyTest {
	
	/*
	 Method Name : setup
	 Description : Test setup method.
	 Parameters	 : None
	 Return Type : None
	 */
    @testSetup 
    public static void setup() {

		//Fulfillment creation.
		Fulfillment__c objFulfillment = new Fulfillment__c();
		insert objFulfillment;

		//Org creation.
		Org__c objOrg = new Org__c();
		objOrg.OrgID__c = 'test';
		insert objOrg;

		//Fulfillment Line creation.
		Fulfillment_Line__c objFulfillmentLine = new Fulfillment_Line__c();
		objFulfillmentLine.Fullfillment__c = objFulfillment.Id;
		objFulfillmentLine.Org__c = objOrg.Id;
		objFulfillmentLine.Org_UUID__c = objOrg.OrgID__c;
		insert objFulfillmentLine;

		//Fulfillment creation.
		Org_Entitlement__c objOrgEntitlement = new Org_Entitlement__c();
		objOrgEntitlement.Org_Id__c = objOrg.Id;
		objOrgEntitlement.Start_Date__c = System.today();
		objOrgEntitlement.End_Date__c = System.today();
		insert objOrgEntitlement;

		//Fulfillment creation.
		Org_Entitlement_Line__c objOrgEntitlementLine = new Org_Entitlement_Line__c();
		objOrgEntitlementLine.Org_Entilement__c = objOrgEntitlement.Id;
		objOrgEntitlementLine.Start_Date__c = System.today();
		objOrgEntitlementLine.End_Date__c = System.today();
		objOrgEntitlementLine.Provisioned__c = true;
		objOrgEntitlementLine.Fulfillment_Line__c = objFulfillmentLine.Id;
		insert objOrgEntitlementLine;
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

			//Now we test the method.
			Test.startTest();
            System.assertNotEquals(IPUHierarchyController.getRecords(true, [SELECT Id FROM Fulfillment__c LIMIT 1].Id) == null, true, 'Unable to get records.');
			System.assertNotEquals(IPUHierarchyController.getRecords(null, [SELECT Id FROM Fulfillment_Line__c LIMIT 1].Id) == null, true, 'Unable to get records.');
			System.assertNotEquals(IPUHierarchyController.getRecords(null, [SELECT Id FROM Org__c LIMIT 1].Id) == null, true, 'Unable to get records.');
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