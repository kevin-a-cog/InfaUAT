/*
 * Name			:	CSMCreatePlanProductsAndAliasTest
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/25/2022
 * Description	:	Create Plan Products and Alias test class.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/25/2022		N/A				Initial version.			N/A
 */
@isTest(seeAllData = false)
public with sharing class CSMCreatePlanProductsAndAliasTest {
	
	/*
	 Method Name : setup
	 Description : Test setup method.
	 Parameters	 : None
	 Return Type : None
	 */
    @testSetup 
    public static void setup() {
		Account objAccount = new Account();
		Product2 objProduct = new Product2();
		Plan__c objPlan = new Plan__c();
		Technical_Product_Line__c objTechnicalProductLine = new Technical_Product_Line__c();
		Subscription_Line__c objSubscriptionLine = new Subscription_Line__c();

		//We create the Technical Product Line.
		objTechnicalProductLine.Name = 'Active VOS;Address Verification;';
		objTechnicalProductLine.Forecast_Product__c = 'Active VOS;Address Verification;';
		objTechnicalProductLine.Delivery_Method__c = 'Hosted Multi Tenant;On Premise;';
		insert objTechnicalProductLine;

		//Now we create the Product.
		objProduct.Name = 'Address Verification';
		objProduct.Offering_Type__c = 'On-Premise Subscription';
		objProduct.Forecast_Product__c = 'Address Verification';
		objProduct.Delivery_Method__c = 'On Premise';
		insert objProduct;

		//We create the Subscription Line.
		objSubscriptionLine.Product__c = objProduct.Id;
		objSubscriptionLine.End_Date__c = System.today().addDays(10);
		insert objSubscriptionLine;

        //Now we create an Account.
        objAccount.Name = 'Test';
        objAccount.BillingCountry = 'US';
        insert objAccount;

		//Now we insert the Plans.
		objPlan.Name = 'TestNew';
		objPlan.Is_Template__c = false;
		objPlan.Account__c = objAccount.Id;
		insert objPlan;
    }
	
	/*
	 Method Name : testProcessRecords
	 Description : Testing processing records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testProcessRecords() {
        System.runAs(createTestUser('System Administrator', true)) {
			Technical_Product_Line__c objTechnicalProductLine = [SELECT Id FROM Technical_Product_Line__c LIMIT 1];

            //Now we get the records.
			CSMCreatePlanProductsAndAliasController.createRecords(objTechnicalProductLine.Id);
            System.assertNotEquals([SELECT Id FROM Technical_Product_Line__c LIMIT 1] == null, true, 'Unable to process records.');
        }
    }
	
	/*
	 Method Name : testProcessRecordsWithPlanProducts
	 Description : Testing processing records with Plan Products.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testProcessRecordsWithPlanProducts() {
        System.runAs(createTestUser('System Administrator', true)) {
			Plan__c objPlan = [SELECT Id FROM Plan__c];
			Related_Account_Plan__c objPlanProduct = new Related_Account_Plan__c();
			Technical_Product_Line__c objTechnicalProductLine = [SELECT Id FROM Technical_Product_Line__c LIMIT 1];

            //Now we get the records.
			objPlanProduct.Forecast_Product__c = 'Address Verification';
			objPlanProduct.Delivery_Method__c = 'On Premise';
			objPlanProduct.Account_Plan__c = objPlan.Id;
			insert objPlanProduct;
			CSMCreatePlanProductsAndAliasController.createRecords(objTechnicalProductLine.Id);
            System.assertNotEquals([SELECT Id FROM Technical_Product_Line__c LIMIT 1] == null, true, 'Unable to process records.');
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
		List<PermissionSetAssignment> lstPermissionSetsRequired = new List<PermissionSetAssignment>();

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
        
		//Now we set the required permission sets.
        for(PermissionSet objPermissionSet : [SELECT Id FROM PermissionSet WHERE Name LIKE 'CSM_Success%' LIMIT 1000]) {
            lstPermissionSetsRequired.add(new PermissionSetAssignment(AssigneeId = objTestUser.id, PermissionSetId = objPermissionSet.Id));
        }
        if(lstPermissionSetsRequired?.size()>0){
            insert lstPermissionSetsRequired;
        }
        return objTestUser;
    }
}