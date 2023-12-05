/*
 * Name			:	SuccessEngagementUnitServiceTest
 * Author		:	Monserrat Pedroza
 * Created Date	: 	06/01/2022
 * Description	:	Success Engagement Unit Service test class.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		06/01/2022		N/A				Initial version.			N/A
 */
@isTest(seeAllData = false)
public with sharing class SuccessEngagementUnitServiceTest {
	
	/*
	 Method Name : setup
	 Description : Test setup method.
	 Parameters	 : None
	 Return Type : None
	 */
    @testSetup 
    public static void setup() {
		EngagementUnitServiceTest.frameworkDataSetup();

		//Local data.
		Engagement_Unit__c objEngagementUnit = new Engagement_Unit__c();
		objEngagementUnit.Account__c = [SELECT Id FROM Account LIMIT 1].Id;
		objEngagementUnit.Awarded_By__c = 'Engagement';
		objEngagementUnit.Entitled_Units__c = 100;
		objEngagementUnit.Consumed_Units__c = 0;
		objEngagementUnit.Expiry_Date__c = System.today().addMonths(1);
		objEngagementUnit.Start_Date__c = System.today().addMonths(-1);
		objEngagementUnit.Type__c = 'Success';
		insert objEngagementUnit;
    }
	
	/*
	 Method Name : testVerifying
	 Description : Testing Verifying records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testVerifying() {
        System.runAs(EngagementUnitServiceTest.createTestUser('System Administrator', true)) {
			Id idAccount = [SELECT Id FROM Account LIMIT 1].Id;
			EngagementUnitServiceWrapper objRequest = new EngagementUnitServiceWrapper();

			//We set the values.
			objRequest.intUnits = 5;
			objRequest.idAccount = idAccount;
			objRequest.strType = 'Success';
			objRequest.boolIsInternalUser = false;

            //Now we get the records.
			Test.startTest();
			SuccessEngagementUnitService.validateEngagementUnits(objRequest);
			objRequest.boolIsInternalUser = true;
			objRequest = SuccessEngagementUnitService.validateEngagementUnits(objRequest);
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
        System.runAs(EngagementUnitServiceTest.createTestUser('System Administrator', true)) {
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
			objRequest.boolIsInternalUser = false;

            //Now we get the records.
			Test.startTest();
			SuccessEngagementUnitService.consumeEngagementUnits(objRequest);
			objRequest.boolIsInternalUser = true;
			objRequest = SuccessEngagementUnitService.consumeEngagementUnits(objRequest);
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
        System.runAs(EngagementUnitServiceTest.createTestUser('System Administrator', true)) {
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
			objRequest.boolIsInternalUser = false;

            //Now we get the records.
			Test.startTest();
			List<String> strConList = new List<String>();
			strConList.add('Test2');
			objRequest.strContextId = 'Test2';
			Engagement_Unit_Consumption__c engUnitCon = new Engagement_Unit_Consumption__c();
			engUnitCon.Context_Id__c = 'Test2';
			engUnitCon.Status__c = 'Consumed';
			engUnitCon.Type__c = 'Success';
			engUnitCon.Initiated_By__c = 'CSM';
			engUnitCon.Engagement_Unit__c = [SELECT Id FROM Engagement_Unit__c LIMIT 1].Id;
			engUnitCon.Number_of_Units__c = 1;
			insert engUnitCon;
			SuccessEngagementUnitService.consumeEngagementUnits(objRequest);
			SuccessEngagementUnitService.updateEngagementUnitConsumptionStatus(objRequest);
			objRequest.boolIsInternalUser = true;
			SuccessEngagementUnitService.consumeEngagementUnits(objRequest);
			SuccessEngagementUnitService.updateEngagementUnitConsumptionStatus(objRequest);
			objRequest.lstContextIds = null;
			SuccessEngagementUnitService.updateEngagementUnitConsumptionStatus(objRequest);
            System.assertNotEquals(objRequest.boolResult == false, true, 'Unable to update.');
			Test.stopTest();
        }
    }
}