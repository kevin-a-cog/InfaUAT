/*
 * Name			:	IPUConsumptionGoalsTest
 * Author		:	Monserrat Pedroza
 * Created Date	: 	3/16/2023
 * Description	:	Test class for IPU Consumption Goals controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		3/16/2023		N/A				Initial version.			N/A
 */
@isTest(seeAllData = false)
public with sharing class IPUConsumptionGoalsTest {

	//Private variables.
	private static Id idInterlockRecordType = Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByDeveloperName().get('Related_Opportunity_Plan').getRecordTypeId();
	private static Id idOpportunityRenewalkRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Renewal_Opportunity').getRecordTypeId();
	
	/*
	 Method Name : setup
	 Description : Test setup method.
	 Parameters	 : None
	 Return Type : None
	 */
    @testSetup 
    public static void setup() {
    
		//Account creation.
		Account objAccount = new Account();
		objAccount.Name = 'Test';
		objAccount.BillingCountry = 'US';
		insert objAccount;

		//Contact creation.
		Contact objContact = new Contact();
		objContact.LastName = 'Test';
		objContact.AccountId = objAccount.Id;
		insert objContact;

		//Legal Entity creation.
		blng__LegalEntity__c objLegalEntity = new blng__LegalEntity__c();
		objLegalEntity.Legal_Entity_Code__c = 'test';
		insert objLegalEntity;

		//Order creation.
		Order objOrder = new Order();
		objOrder.Status = 'Draft';
		objOrder.AccountId = objAccount.Id;
		objOrder.Legal_Entity__c = objLegalEntity.Id;
		objOrder.EffectiveDate = System.today();
		objOrder.SoldToAccount__c = objAccount.Id;
		objOrder.SoldToContact__c = objContact.Id;
		objOrder.SoldStreet__c = 'test';
		objOrder.SoldCity__c = 'test';
		objOrder.SoldPostalCode__c = 'test';
		objOrder.SoldCountry__c = 'test';
		objOrder.EndUserAccount__c = objAccount.Id;
		objOrder.EndUserContact__c = objContact.Id;
		objOrder.EndUserStreet__c = 'test';
		objOrder.EndUserCity__c = 'test';
		objOrder.EndUserPostalCode__c = 'test';
		objOrder.EndUserCountry__c = 'test';
		objOrder.ShipToAccount__c = objAccount.Id;
		objOrder.BilltoAccount__c = objAccount.Id;
		objOrder.Pricebook2Id=Test.getStandardPricebookId();
		objOrder.blng__BillingDayOfMonth__c='10';
		insert objOrder;

		//Org creation.
		Org__c objOrg = new Org__c();
		objOrg.OrgID__c = 'test' + Datetime.now();
		objOrg.Account__c = objAccount.Id;
        objOrg.OrgType__c = 'Production';
		insert objOrg;
		Org__c objOrg2 = new Org__c();
        objOrg2.OrgType__c = 'Production';
		objOrg2.OrgID__c = 'test2' + Datetime.now();
		objOrg2.Account__c = objAccount.Id;
		insert objOrg2;

		//Plan creation.
		Plan__c objPlan = new Plan__c();
		objPlan.Name = 'TestNew';
		objPlan.Is_Template__c = false;
		objPlan.Account__c = objAccount.Id;
		
        objPlan.Plan_Operational_Model__c = 'Other';
		insert objPlan;

		//Objective creation.
		Objective__c objObjective = new Objective__c();
		objObjective.Plan__c = objPlan.Id;
		objObjective.Sign_Off_Date__c = Date.today();
		objObjective.Is_Template__c = true;
		objObjective.Customer_Sign_off_Contact__c = objContact.Id;
		insert objObjective;

		//Contract creation.
		Contract objContract = new Contract();
		objContract.AccountId = objAccount.Id;
		objContract.SBQQ__Order__c = objOrder.Id;
		objContract.ContractTerm = 3;
		insert objContract;

		//Opportunity creation.
		Opportunity objOpportunity = new Opportunity();
		objOpportunity.Name = 'test';
		objOpportunity.StageName = 'Initiated';
		objOpportunity.AccountId = objAccount.Id;
		objOpportunity.CloseDate = System.today().addDays(400);
		objOpportunity.RecordTypeId = idOpportunityRenewalkRecordType;
		insert objOpportunity;

		//Interclock creation.
		Related_Opportunity_Plan__c objInterlock = new Related_Opportunity_Plan__c();
		objInterlock.Is_Automated__c = true;
		objInterlock.Automation_Source__c = 'Plan Products';
		objInterlock.Plan__c = objPlan.Id;
		objInterlock.Account__c = objAccount.Id;
		objInterlock.Contract__c = objContract.Id;
		objInterlock.Opportunity__c = objOpportunity.Id;
		objInterlock.Original_Opportunity__c = objOpportunity.Id;
		objInterlock.RecordTypeId = idInterlockRecordType;
		insert objInterlock;

		//Plan Product creation.
		Related_Account_Plan__c objPlanProduct = new Related_Account_Plan__c();
		objPlanProduct.Forecast_Product__c = 'IPU';
		objPlanProduct.Delivery_Method__c = 'On Premise';
		objPlanProduct.Account_Plan__c = objPlan.Id;
		objPlanProduct.Contract__c = objContract.Id;
		insert objPlanProduct;
		
		//Org service creation.
		Org_Service__c objOrgService = new Org_Service__c();
		List<Org_Service__c> lstOrgServices = new List<Org_Service__c>();
		objOrgService.Active__c =true;
		objOrgService.Service_Type__c = 'Service';
		objOrgService.Number_of_Entitlements_consumed__c = 200;
		objOrgService.Estimated_Number_of_entitlements__c = 200;
		objOrgService.Org_ID__c = objOrg.Id;
		objOrgService.Service_UUID__c = 'yiasdooohaosidmaosd';
		objOrgService.Name = 'Data Test Service';
		lstOrgServices.add(objOrgService);
		objOrgService = new Org_Service__c();
		objOrgService.Active__c =true;
		objOrgService.Service_Type__c = 'Service';
		objOrgService.Number_of_Entitlements_consumed__c = 200;
		objOrgService.Estimated_Number_of_entitlements__c = 200;
		objOrgService.Org_ID__c = objOrg.Id;
		objOrgService.Service_UUID__c = 'rasraseaasd';
		objOrgService.Name = 'Data Test';
		lstOrgServices.add(objOrgService);
		objOrgService = new Org_Service__c();
		objOrgService.Active__c =true;
		objOrgService.Service_Type__c = 'Service';
		objOrgService.Number_of_Entitlements_consumed__c = 200;
		objOrgService.Estimated_Number_of_entitlements__c = 200;
		objOrgService.Org_ID__c = objOrg.Id;
		objOrgService.Service_UUID__c = 'yiasdooosassd';
		objOrgService.Name ='test';
		lstOrgServices.add(objOrgService);
		objOrgService = new Org_Service__c();
		objOrgService.Active__c =true;
		objOrgService.Service_Type__c = 'Service';
		objOrgService.Number_of_Entitlements_consumed__c = 200;
		objOrgService.Estimated_Number_of_entitlements__c = 200;
		objOrgService.Org_ID__c = objOrg2.Id;
		objOrgService.Service_UUID__c = 'yiasdooosassd';
		objOrgService.Name ='test';
		lstOrgServices.add(objOrgService);
		insert lstOrgServices;
    }
	
	/*
	 Method Name : testRecordCreation
	 Description : Testing creation records path.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testRecordCreation() {
       	System.runAs(createTestUser('System Administrator', true)) {
			Integer intButton;
			Id idPlan = [SELECT Id FROM Plan__c LIMIT 1].Id;
			Id idAccount = [SELECT Id FROM Account LIMIT 1].Id;
			Id idContact = [SELECT Id FROM Contact LIMIT 1].Id;
			Id idObjective = [SELECT Id FROM Objective__c LIMIT 1].Id;
			Org_Service__c objOrgService = [SELECT Id FROM Org_Service__c LIMIT 1];
			Objective__c objObjective = new Objective__c();
			IPU_Consumption_Goal__c objICF = new IPU_Consumption_Goal__c();
			List<IPU_Consumption_Goal__c> lstRecords;

			//We create local data.
			objObjective.Plan__c = idPlan;
			objObjective.Sign_Off_Date__c = Date.today();
			objObjective.Is_Template__c = true;
			objObjective.Customer_Sign_off_Contact__c = idContact;
			insert objObjective;

			//We define the button type.
			Test.startTest();
			intButton = IPUConsumptionGoalsController.saveButtonType(idPlan);
			//System.assertNotEquals(intButton == 1, false, 'Unable to get button type. ' + intButton);

			//Now we save records.
			lstRecords = new List<IPU_Consumption_Goal__c>();
			objICF = new IPU_Consumption_Goal__c();
			objICF.Account__c = idAccount;
			objICF.Expected_Goal__c = 1;
			objICF.Expected_Date__c = System.today();
			objICF.Service__c = 'test';
			objICF.Comments__c = 'test';
			objICF.Objective_Id__c = objObjective.Id;
			objICF.Objective_Name__c = 'test';
			lstRecords.add(objICF);
			objICF = new IPU_Consumption_Goal__c();
			objICF.Account__c = idAccount;
			objICF.Expected_Goal__c = 1;
			objICF.Expected_Date__c = System.today();
			objICF.Service__c = 'test 2';
			objICF.Comments__c = 'test';
			objICF.Objective_Id__c = idObjective;
			lstRecords.add(objICF);
			IPUConsumptionGoalsController.saveRecords(idPlan, lstRecords);
			lstRecords = new List<IPU_Consumption_Goal__c>();
			objICF = new IPU_Consumption_Goal__c();
			objICF.Account__c = idAccount;
			objICF.Expected_Goal__c = 1;
			objICF.Expected_Date__c = System.today();
			objICF.Service__c = 'test';
			objICF.Comments__c = 'test 2';
			objICF.Objective_Id__c = objObjective.Id;
			objICF.Objective_Name__c = 'test';
			lstRecords.add(objICF);
			objICF = new IPU_Consumption_Goal__c();
			objICF.Account__c = idAccount;
			objICF.Expected_Goal__c = 1;
			objICF.Expected_Date__c = System.today();
			objICF.Service__c = 'test 2';
			objICF.Comments__c = 'test 2';
			objICF.Objective_Id__c = idObjective;
			lstRecords.add(objICF);
			IPUConsumptionGoalsController.saveRecords(idPlan, lstRecords);

			//Now we fetch the saved records.
			System.assertNotEquals(IPUConsumptionGoalsController.getRecords(false, false, idAccount) == null, true, 'Unable to get records.');
			System.assertNotEquals(IPUConsumptionGoalsController.getRecords(false, true, idAccount) == null, true, 'Unable to get records.');
			System.assertNotEquals(IPUConsumptionGoalsController.getRecords(true, false, idAccount) == null, true, 'Unable to get records.');
			System.assertNotEquals(IPUConsumptionGoalsController.getRecords(true, true, idAccount) == null, true, 'Unable to get records.');

			//We test the history tracking.
			objOrgService.Number_of_Entitlements_consumed__c = 1;
			update objOrgService;
			System.assertNotEquals(IPUConsumptionGoalsController.getRecords(false, true, idAccount) == null, true, 'Unable to get records.');
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
        for(PermissionSet objPermissionSet :[SELECT Id FROM PermissionSet WHERE Name = 'CSM_SuccessUser']) {
            lstPermissionSets.add(new PermissionSetAssignment(AssigneeId = objTestUser.id, PermissionSetId = objPermissionSet.Id));
        }
        if(lstPermissionSets?.size() > 0) {
            insert lstPermissionSets;
        }

		//Now we return the result.
        return objTestUser;
    }
}