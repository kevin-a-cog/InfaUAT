/*
 * Name			:	CsmEditRiskProductControllerTest
 * Author		:	Deva M
 * Created Date	: 	31/01/2022
 * Description	:	CsmEditRiskProductController test class.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 DEva M         		31/01/2022		N/A				Initial version.			N/A
 */
@istest
public with sharing class CsmEditRiskProductControllerTest {
     /*
	 Method Name : setup
	 Description : Test setup method.
	 Parameters	 : None
	 Return Type : None
	 */
    @testSetup 
    public static void setup() {
		Id riskRt = Schema.SObjectType.Risk_Issue__c.getRecordTypeInfosByName().get('Risk').getRecordTypeId();
           SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test');
        UtilityTestData.mAccountData.put('BillingCountry', 'US');       
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
      
        
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan');
        UtilityTestData.mPlan.put('Is_Template__c','false');
        UtilityTestData.mPlan.put('Account__c',lNewCustomerAccount[0].Id);
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});  
        
        AccountTeamMember team = new AccountTeamMember();
        team.TeamMemberRole = 'CSM';
        team.UserId = UserInfo.getUserId();
        team.AccountId = lNewCustomerAccount[0].Id;
        insert team;
        
          String OPP_RENEWAL_RT = 'Renewal Opportunity';
        String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
                        
        UtilityTestData.mOpportunityData.put('AccountId', lNewCustomerAccount[0].Id);
    
        UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_RENEWAL_RT).getRecordTypeId());
        UtilityTestData.mOpportunityData.put('Type', 'Renewal');
        UtilityTestData.mOpportunityData.put('StageName', 'Validate');
        UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Commit');
        sObj = new Opportunity();     
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Now we insert the Plan Products.
        sObject Related_Account_Plan = new Related_Account_Plan__c();
        UtilityTestData.mRelatedAccountProduct.put('Forecast_Product__c','Active VOS');
        
        Related_Account_Plan = UtilityTest.putFieldRecord(Related_Account_Plan, UtilityTestData.mRelatedAccountProduct);
        List<Related_Account_Plan__c> lPlanProd2 = (List<Related_Account_Plan__c>) UtilityTest.makeInsert(new List<sObject>{Related_Account_Plan});
        
        //Risk
        sObject risk = new Risk_Issue__c();
        UtilityTestData.mRiskIssue.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mRiskIssue.put('Type__c','Adoption');
        //  UtilityTestData.mRiskIssue.put('Milestone__c',lMilestone[0].Id);        
        UtilityTestData.mRiskIssue.put('Risk_Reason__c','Acquisition');
        UtilityTestData.mRiskIssue.put('Status__c','Open');
         UtilityTestData.mRiskIssue.put('RecordTypeId',riskRt);
        risk = UtilityTest.putFieldRecord(risk, UtilityTestData.mRiskIssue);
        List<Risk_Issue__c> lRisk = (List<Risk_Issue__c>) UtilityTest.makeInsert(new List<sObject>{risk});
        
        //Now we create a Risk Product Alias.
        Risk_Product_Alias__c objRiskProductAlias = new Risk_Product_Alias__c();
        objRiskProductAlias.Opportunity__c = lOpportunity[0].Id;
        objRiskProductAlias.Risk__c = lRisk[0].Id;
        insert objRiskProductAlias;
        
        //Now we create a Plan Product Alias.
        Plan_Product_Alias__c objPlanProductAlias = new Plan_Product_Alias__c();
        objPlanProductAlias.Plan__c = lPlan[0].Id;
        objPlanProductAlias.Plan_Product__c = lPlanProd2[0].Id;
        insert objPlanProductAlias;
       
        lPlanProd2[0].Plan_Product_Alias__c = objPlanProductAlias.Id;
        update lPlanProd2[0];
        
     
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
            Plan_Product_Alias__c objRiskProduct = [SELECT Id FROM Plan_Product_Alias__c LIMIT 1];
			Risk_Issue__c objRiskIssue = [SELECT Id FROM Risk_Issue__c LIMIT 1];
            Plan_Product_Alias__c objPlanProductAlias = [SELECT Id FROM Plan_Product_Alias__c LIMIT 1];
            //Now we get the Product records.
            System.assertNotEquals(CsmEditRiskProductController.getRecords(objRiskIssue.Id,null) == null, true, 'Unable to get records.');

            //Now we get the RiskProduct Alias records.
            System.assertNotEquals(CsmEditRiskProductController.getRecords(objRiskIssue.Id,objRiskProduct.Id) == null, true, 'Unable to get records.');

            //Now we get the Opportunity records.
            System.assertNotEquals(CsmEditRiskProductController.getOpportunityRecords(objPlanProductAlias.Id) == null, true, 'Unable to get records.');
        }
    }


    	/*
	 Method Name : saveRiskProductTest
	 Description : Testing save risk Prod.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void saveRiskProductTest() {
        System.runAs(createTestUser('System Administrator', true)) {
            Plan_Product_Alias__c objRiskProduct = [SELECT Id FROM Plan_Product_Alias__c LIMIT 1];
			Risk_Issue__c objRiskIssue = [SELECT Id FROM Risk_Issue__c LIMIT 1];
            Plan_Product_Alias__c objPlanProductAlias = [SELECT Id FROM Plan_Product_Alias__c LIMIT 1];
            Opportunity objOpp = [SELECT Id from Opportunity Limit 1];
            CsmEditRiskProductController.saveRiskProduct(objRiskIssue.Id,objPlanProductAlias.Id,objOpp.Id,'25%','');
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