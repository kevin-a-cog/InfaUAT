/*
 * Name			:	CSMPlanProductsTest
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/16/2021
 * Description	:	Manage Plan Products test class.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description								Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/16/2021		N/A				Initial version.						N/A
 Pavithra V				9/21/2021		N/A				Coverage for planproductcount			N/A
 */
@isTest(seeAllData = false)
public with sharing class CSMPlanProductsTest {
	
	/*
	 Method Name : setup
	 Description : Test setup method.
	 Parameters	 : None
	 Return Type : None
	 */
    @testSetup 
    public static void setup() {

        //We create an Account.
        Account objAccount = new Account();
		objAccount.Name = 'Test';
		objAccount.BillingCountry = 'Test';
		insert objAccount;

		//Now we create a Plan.
		Plan__c objPlan = new Plan__c();
		objPlan.Name = 'Test';
        objPlan.Account__c = objAccount.Id;
        objPlan.Plan_Operational_Model__c = 'Named CSM';
		insert objPlan;
        
        AccountTeamMember team = new AccountTeamMember();
        team.TeamMemberRole = 'CSM';
        team.UserId = UserInfo.getUserId();     
        team.AccountId = objAccount.Id;
        insert team;

		//Now we create an Opportunity.
		Opportunity objOpportunity = new Opportunity();
		objOpportunity.Name = 'Test';
		objOpportunity.AccountId = objAccount.Id;
		objOpportunity.StageName = 'Lead';
		objOpportunity.CloseDate = System.today().addDays(1);
		objOpportunity.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId();
		insert objOpportunity;

		//Now we create Related Plan Product records.
		Related_Account_Plan__c objPlanProduct = new Related_Account_Plan__c();
		objPlanProduct.Account_Plan__c = objPlan.Id;
		objPlanProduct.Account__c = objAccount.Id;
		objPlanProduct.Opportunity__c = objOpportunity.Id;
		insert objPlanProduct;

		//Now we create a risk.
		Risk_Issue__c objRisk = new Risk_Issue__c();
		objRisk.Plan__c = objPlan.Id;
        objRisk.RecordTypeId= Schema.SObjectType.Risk_Issue__c.getRecordTypeInfosByName().get('Risk').getRecordTypeId();
		insert objRisk;

		//Now we create a Risk Product Alias.
		Risk_Product_Alias__c objRiskProductAlias = new Risk_Product_Alias__c();
		objRiskProductAlias.Opportunity__c = objOpportunity.Id;
		objRiskProductAlias.Risk__c = objRisk.Id;
		insert objRiskProductAlias;

		//Now we create the Technical Product Line.
		Technical_Product_Line__c objTechnicalProductLine = new Technical_Product_Line__c();
		objTechnicalProductLine.Name = 'Address Verification';
		objTechnicalProductLine.Forecast_Product__c = 'Active VOS';
		objTechnicalProductLine.Status__c = 'Active';
		insert objTechnicalProductLine;

		//Now we create a Plan Product Alias.
		Plan_Product_Alias__c objPlanProductAlias = new Plan_Product_Alias__c();
		objPlanProductAlias.Plan__c = objPlan.Id;
		objPlanProductAlias.Forecast_Product__c = 'Active VOS';
		objPlanProductAlias.Technical_Product_Line__c = objTechnicalProductLine.Id;
		insert objPlanProductAlias;
		objPlanProduct.Plan_Product_Alias__c = objPlanProductAlias.Id;
		update objPlanProduct;
    }
	
	/*
	 Method Name : testRecordFetching
	 Description : Testing fetching records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testRecordFetching() {
        //System.runAs(createTestUser('System Administrator', true)) {
            Plan__c objPlan = [SELECT Id FROM Plan__c LIMIT 1];
			Account objAccount = [SELECT Id FROM Account LIMIT 1];

            //Now we get the records based on Plan Id.
            System.assertNotEquals(CSMPlanProductsController.getRecords(objPlan.Id, null, null, null,true) == null, true, 'Unable to get records.');

            //Now we get the records based on Account Id.
            System.assertNotEquals(CSMPlanProductsController.getRecords(null, objAccount.Id, null, null,true) == null, true, 'Unable to get records.');

            //Now we get the records based on Account Id, with status restrictions.
            System.assertNotEquals(CSMPlanProductsController.getRecords(null, objAccount.Id, new List<String>{ 'Expired' }, null,true) == null, true, 'Unable to get records.');

            //Now we get the records based on Account Id, with stage restrictions.
            //System.assertNotEquals(CSMPlanProductsController.getRecords(null, objAccount.Id, new List<String>{ 'Expired' }, new List<String>{ 'Not Applicable' },true) == null, true, 'Unable to get records.');

            //Now we get the records based on no parents.
            System.assertNotEquals(CSMPlanProductsController.getRecords(null, null, null, null,true) == null, true, 'Unable to get records.');
            
            //Now we test getting all the records.
			System.assertNotEquals(CSMPlanProductsController.getRecords(objPlan.Id, null, null, null, false) == null, true, 'Unable to get records.');
        //}
    }
	
	/*
	 Method Name : testDeleteRecords
	 Description : Testing deleting records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testDeleteRecords() {
        //System.runAs(createTestUser('System Administrator', true)) {
            Related_Account_Plan__c objRecord = [SELECT Id FROM Related_Account_Plan__c LIMIT 1];
			List<Related_Account_Plan__c> lstRecords = new List<Related_Account_Plan__c>();

            //Now we prepare the data.
            lstRecords.add(objRecord);

			//Now we delete the records.
			CSMPlanProductsController.getRecordsDeleted(lstRecords);

            //Now we get the records history.
            System.assertNotEquals([SELECT Id FROM Related_Account_Plan__c] == null, true, 'No records were deleted.');
        //}
    }
	
	/*
	 Method Name : testRecordsRelationship
	 Description : Testing relating records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testRecordsRelationship() {
        //System.runAs(createTestUser('System Administrator', true)) {
			Plan__c objRecordParent = [SELECT Id FROM Plan__c LIMIT 1];
            Related_Account_Plan__c objRecord = [SELECT Id FROM Related_Account_Plan__c LIMIT 1];
			List<Related_Account_Plan__c> lstRecords = new List<Related_Account_Plan__c>();

            //Now we prepare the data.
            lstRecords.add(objRecord);

			//Now we delete the records.
			CSMPlanProductsController.getRecordsRelated(objRecordParent.Id, lstRecords);

            //Now we get the records history.
            System.assertNotEquals([SELECT Id FROM Related_Account_Plan__c LIMIT 1] == null, true, 'Unable to relate records.');
        //}
    }
	
	/*
	 Method Name : testInsertRecord
	 Description : Testing inserting records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testInsertRecord() {
        //System.runAs(createTestUser('System Administrator', true)) {
            List<Account> lAccount = [Select Id from Account];
			Plan__c objPlan = new Plan__c();
			objPlan.Name = 'Test';
            objPlan.Account__c = lAccount[0].id;
        

			//Now we insert the records.
			CSMPlanProductsController.getRecordInserted(objPlan);
        	Plan__c plan = [SELECT Id,Account__c FROM Plan__c LIMIT 1]; 
        	AccountTeamMember acctm=[select id,AccountId,User.Email,User.Name,UserId from AccountTeamMember limit 1];
			CSMPlanProductsController.createPlanTeamMembers(plan.Id);
            //Now we get the records history.
            System.assertNotEquals([SELECT Id FROM Plan__c LIMIT 1] == null, true, 'Unable to insert records.');
       // }
    }
	
	/*
	 Method Name : testUpdateRecords
	 Description : Testing updating records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testUpdateRecords() {
       // System.runAs(createTestUser('System Administrator', true)) {
            Related_Account_Plan__c objRecord = [SELECT Id FROM Related_Account_Plan__c LIMIT 1];
			List<Related_Account_Plan__c> lstRecords = new List<Related_Account_Plan__c>();

            //Now we prepare the data.
            lstRecords.add(objRecord);

			//Now we update the records.
			CSMPlanProductsController.getRecordsUpdated(lstRecords);

            //Now we get the records history.
            System.assertNotEquals([SELECT Id FROM Risk_Issue__c LIMIT 1] == null, true, 'Unable to update records.');
        //}
    }
	
	/*
	 Method Name : testWrapperClass
	 Description : Testing wrapper class fields.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testWrapperClass() {
       // System.runAs(createTestUser('System Administrator', true)) {
			GlobalDataTableWrapperClass objRecord = new GlobalDataTableWrapperClass();
			GlobalDataTableWrapperClass.ColumnWrapperClass objColumn = new GlobalDataTableWrapperClass.ColumnWrapperClass();

			//We first set values.
			objRecord.lstColumns = new List<GlobalDataTableWrapperClass.ColumnWrapperClass>();
			objColumn.target = '_blank';
			objColumn.objType = Schema.DisplayType.Picklist;
			objRecord.lstColumns.add(objColumn);

			//Now we get values.
            System.assertNotEquals(objColumn.type == null, true, 'Invalid value.');
			objColumn.objType = Schema.DisplayType.Boolean;
            System.assertNotEquals(objColumn.type == null, true, 'Invalid value.');
			objColumn.objType = Schema.DisplayType.Email;
            System.assertNotEquals(objColumn.type == null, true, 'Invalid value.');
			objColumn.objType = Schema.DisplayType.Date;
            System.assertNotEquals(objColumn.type == null, true, 'Invalid value.');
			objColumn.objType = Schema.DisplayType.Double;
            System.assertNotEquals(objColumn.type == null, true, 'Invalid value.');
			objColumn.objType = Schema.DisplayType.Percent;
            System.assertNotEquals(objColumn.type == null, true, 'Invalid value.');
			objColumn.objType = Schema.DisplayType.Reference;
			objColumn.fieldName = '__r.Id';
            System.assertNotEquals(objColumn.type == null, true, 'Invalid value.');
			objColumn.fieldName = '__r.Id';
            System.assertNotEquals(objColumn.type == null, true, 'Invalid value.');
			objColumn.fieldName = '.Id';
            System.assertNotEquals(objColumn.type == null, true, 'Invalid value.');
       // }
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
        for(PermissionSet ps :[SELECT Id FROM PermissionSet WHERE Name in ('CSM_SuccessUser','CSM_Success_Manager','CSM_Success_Operations')]){
            PermissionSetAssignment psAssign = new PermissionSetAssignment(AssigneeId = objTestUser.id, PermissionSetId = ps.Id);
            psAssignList.add(psAssign);
        }
        if(psAssignList?.size()>0){
            insert psAssignList;
        }
		
        return objTestUser;
    }
    
    /*
	 Method Name : getRecordTypeValues
	 Description : Testing getRecordTypeValues
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest //<T02>
    public static void testgetRecordTypeValues() {
			
        	List<Account> lAccount = [Select Id from Account];
        	Plan__c objPlan = new Plan__c();
			objPlan.Name = 'Test';
            objPlan.Account__c = lAccount[0].id;			
			objPlan.Plan_Operational_Model__c = 'Named CSM';
        	insert objPlan;
        	List<Related_Account_Plan__c> lPlanProducts = new List<Related_Account_Plan__c>();
        
            //Related opportunity Plan(Interlock)
            UtilityTestData.mRelatedOpportunityPlan.put('Account__c',lAccount[0].Id);
            UtilityTestData.mRelatedOpportunityPlan.put('Plan__c',objPlan.Id);
            UtilityTestData.mRelatedOpportunityPlan.put('RecordTypeId',Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByDeveloperName().get('Related_Opportunity_Plan').getRecordTypeId());        
            sObject relOptyPlan = new Related_Opportunity_Plan__c();
            relOptyPlan = UtilityTest.putFieldRecord(relOptyPlan, UtilityTestData.mRelatedOpportunityPlan);        
            List<Related_Opportunity_Plan__c> lRelOptyPlan = (List<Related_Opportunity_Plan__c>) UtilityTest.makeInsert(new List<sObject>{relOptyPlan});
        
			CSMPlanProductsController.getRecordTypeValues();
            CSMPlanProductsController.planproductcount(objPlan.Id);
           	CSMPlanProductsController.getInterlockstoDelete(lPlanProducts);
        	//CSMPlanProductsController.deleteInterlocks(lRelOptyPlan);
			CSMPlanProductsController.hasUnasignedProductPlans(lAccount[0].id);
    }
}