/*
 * Name			:	CSMDeactivateEntitledProductsTest
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/23/2022
 * Description	:	Deactivate Entitled Products test class.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/23/2022		N/A				Initial version.			N/A
 */
@isTest(seeAllData = false)
public with sharing class CSMDeactivateEntitledProductsTest {
	
	/*
	 Method Name : setup
	 Description : Test setup method.
	 Parameters	 : None
	 Return Type : None
	 */
    public static void setup() {
		sObject objAccount = new Account();
		Asset objAsset = new Asset();
		Technical_Product_Line__c objTechnicalProductLine = new Technical_Product_Line__c();
		Entitled_Product__c objEntitledProduct = new Entitled_Product__c();

        //We create a Partner (Account).
		//objAccount.Name = 'Address Verification';
		//objAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
		//insert objAccount;
        
        
        objAccount = UtilityTest.putFieldRecord(objAccount, UtilityTestData.mAccountData); 
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{objAccount});
        objAccount = lAccount[0];

		//We create the Technical Product Line.
		objTechnicalProductLine.Name = 'Address Verification';
		objTechnicalProductLine.Forecast_Product__c = 'Address Verification';
		insert objTechnicalProductLine;

		//We create the Entitled Product.
		objEntitledProduct.Name = 'Address Verification';
		objEntitledProduct.Forecast_Product__c = 'Address Verification';
		insert objEntitledProduct;

		//We create the Asset.
		objAsset.Name = 'Address Verification';
		objAsset.AccountId = objAccount.Id;
		objAsset.Entitled_Product__c = objEntitledProduct.Id;
		insert objAsset;
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
			Technical_Product_Line__c objTechnicalProductLine;

			//First we setup the data.
			setup();
			objTechnicalProductLine = [SELECT Id FROM Technical_Product_Line__c LIMIT 1];

            //Now we get the records.
			CSMDeactivateEntitledProductsController.deactivateRecords(objTechnicalProductLine.Id);
			CSMDeactivateEntitledProductsController.getForecastProduct(objTechnicalProductLine.Id);
            System.assertNotEquals([SELECT Id FROM Technical_Product_Line__c LIMIT 1] == null, true, 'Unable to process records.');
        }
    }
	
	/*
	 Method Name : testReports
	 Description : Testing reports.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest(seeAllData = true)
    public static void testReports() {
        System.runAs(createTestUser('System Administrator', true)) {
            System.assertNotEquals(CSMDeactivateEntitledProductsController.getReportIds() == null, true, 'Unable to process records.');
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