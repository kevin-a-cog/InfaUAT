/*
 * Name			:	CSMCreateEntitledProductsTest
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/24/2022
 * Description	:	Create Entitled Products test class.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/24/2022		N/A				Initial version.			N/A
 */
@isTest(seeAllData = false)
public with sharing class CSMCreateEntitledProductsTest {
	
	/*
	 Method Name : setup
	 Description : Test setup method.
	 Parameters	 : None
	 Return Type : None
	 */
    @testSetup 
    public static void setup() {
		Account objAccount = new Account();
		Asset objAsset = new Asset();
		Product2 objProduct = new Product2();
		Entitlement objEntitlement = new Entitlement();
		Technical_Product_Line__c objTechnicalProductLine = new Technical_Product_Line__c();
		Entitled_Product__c objEntitledProduct = new Entitled_Product__c();

        //We create a Partner (Account).
		objAccount.Name = 'Address Verification';
		objAccount.BillingCountry = 'United States';
		objAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
		insert objAccount;

		//We create the Technical Product Line.
		objTechnicalProductLine.Name = 'Address Verification';
		objTechnicalProductLine.Forecast_Product__c = 'Address Verification';
		objTechnicalProductLine.Delivery_Method__c = 'On Premise';
		insert objTechnicalProductLine;

		//Now we create the Product.
		objProduct.Name = 'Address Verification';
		objProduct.Offering_Type__c = 'On-Premise Subscription';
		insert objProduct;

		//We create the Asset.
		objAsset.Name = 'Address Verification';
		objAsset.AccountId = objAccount.Id;
		objAsset.Delivery_Method__c = 'On Premise';
		objAsset.Product2Id = objProduct.Id;
		insert objAsset;

		//Now we create the Entitlement.
		objEntitlement.Name = 'Address Verification';
		objEntitlement.StartDate = System.today();
		objEntitlement.EndDate = System.today().addDays(2);
		objEntitlement.AccountId = objAccount.Id;
		objEntitlement.AssetId = objAsset.Id;
		insert objEntitlement;
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
			CSMCreateEntitledProductsController.createRecords(objTechnicalProductLine.Id);
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