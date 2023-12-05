/*
 * Name			:	CSMCreateMapRiskProductsQueueableTest
 * Author		:	Deva M
 * Created Date	: 	22/02/2022
 * Description	:	Test class for CSMCreateMapRiskProductsQueueable

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M         		22/02/2022		N/A				Initial version.			N/A
 */
@istest
public with sharing class CSMCreateMapRiskProductsQueueableTest {
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
        UtilityTestData.mAccountData.put('BillingCountry', 'Test');       
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

		//Now we create a Plan.
		sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan');
        UtilityTestData.mPlan.put('Account__c',lNewCustomerAccount[0].Id);
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});  
        
        AccountTeamMember team = new AccountTeamMember();
        team.TeamMemberRole = 'CSM';
        team.UserId = UserInfo.getUserId();
        team.AccountId = lNewCustomerAccount[0].Id;
        insert team;

		//Now we create an Opportunity.
        String OPP_RENEWAL_RT = 'Renewal Opportunity';
        String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
        
        UtilityTestData.mOpportunityData.put('AccountId', lNewCustomerAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Name', 'test');
        UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_RENEWAL_RT).getRecordTypeId());
        UtilityTestData.mOpportunityData.put('Type', 'Renewal');
        UtilityTestData.mOpportunityData.put('StageName', 'Lead');
        UtilityTestData.mOpportunityData.put('CloseDate', string.valueOf(System.today().addDays(1)));
        
        sObj = new Opportunity();     
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});	

		//Now we create Related Plan Product records.
        sObject Related_Account_Plan = new Related_Account_Plan__c();      
        UtilityTestData.mRelatedAccountProduct.put('Account_Plan__c',lPlan[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Account__c', lNewCustomerAccount[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Opportunity__c', lOpportunity[0].Id);
        
        Related_Account_Plan = UtilityTest.putFieldRecord(Related_Account_Plan, UtilityTestData.mRelatedAccountProduct);
        List<Related_Account_Plan__c> lPlanProd2 = (List<Related_Account_Plan__c>) UtilityTest.makeInsert(new List<sObject>{Related_Account_Plan});
        
           sObject Related_Account_Plan2 = new Related_Account_Plan__c();
      
        UtilityTestData.mRelatedAccountProduct.put('Account_Plan__c',lPlan[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Account__c', lNewCustomerAccount[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Opportunity__c', lOpportunity[0].Id);
        
        Related_Account_Plan2 = UtilityTest.putFieldRecord(Related_Account_Plan2, UtilityTestData.mRelatedAccountProduct);
        List<Related_Account_Plan__c> lPlanProd3 = (List<Related_Account_Plan__c>) UtilityTest.makeInsert(new List<sObject>{Related_Account_Plan2});

		//Now we create a risk.
		Risk_Issue__c objRisk = new Risk_Issue__c(RecordTypeId=riskRt);
		objRisk.Plan__c = lPlan[0].Id;
		insert objRisk;

		//Now we create a Plan Product Alias.
		Plan_Product_Alias__c objPlanProductAlias = new Plan_Product_Alias__c();
		objPlanProductAlias.Plan__c = lPlan[0].Id;
		objPlanProductAlias.Plan_Product__c = lPlanProd3[0].Id;
        objPlanProductAlias.Forecast_Product__c='Customer 360 Insights';
		insert objPlanProductAlias;
		lPlanProd2[0].Plan_Product_Alias__c = lPlanProd2[0].Id;
	

        Plan_Product_Alias__c objPlanProductAliasTwo = new Plan_Product_Alias__c();
		objPlanProductAliasTwo.Plan__c = lPlan[0].Id;
		objPlanProductAliasTwo.Plan_Product__c = lPlanProd3[0].Id;
        objPlanProductAliasTwo.Forecast_Product__c='Address Verification';
		insert objPlanProductAliasTwo;

		lPlanProd2[0].Plan_Product_Alias__c = objPlanProductAlias.Id;
        lPlanProd3[0].Plan_Product_Alias__c = objPlanProductAliasTwo.Id;
		update new List<Related_Account_Plan__c>{lPlanProd2[0],lPlanProd3[0]};
    }


    	
	/*
	 Method Name : testRecordCreation
	 Description : Testing create record records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testRecordCreation() {
        Risk_Issue__c objRisk = [SELECT Id FROM Risk_Issue__c LIMIT 1];
        Opportunity objOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        Plan_Product_Alias__c objPlanProduct = [SELECT Id FROM Plan_Product_Alias__c LIMIT 1];
        //Now we create a Risk Product Alias.
		Risk_Product_Alias__c objRiskProductAlias = new Risk_Product_Alias__c();
		objRiskProductAlias.Opportunity__c = objOpportunity.Id;
		objRiskProductAlias.Risk__c = objRisk.Id;
        objRiskProductAlias.Plan_Product_Alias__c = objPlanProduct.Id;
		insert objRiskProductAlias;
    }


    	/*
	 Method Name : testRecordUpdate
	 Description : Testing create record records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testRecordUpdate() {
        Risk_Issue__c objRisk = [SELECT Id FROM Risk_Issue__c LIMIT 1];
        Opportunity objOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        List<Plan_Product_Alias__c> lstObjPlanProduct = [SELECT Id FROM Plan_Product_Alias__c LIMIT 2];
        //Now we create a Risk Product Alias.
		Risk_Product_Alias__c objRiskProductAlias = new Risk_Product_Alias__c();
		objRiskProductAlias.Opportunity__c = objOpportunity.Id;
		objRiskProductAlias.Risk__c = objRisk.Id;
        objRiskProductAlias.Plan_Product_Alias__c = lstObjPlanProduct[0].Id;
		insert objRiskProductAlias;

        objRiskProductAlias.Plan_Product_Alias__c = lstObjPlanProduct[1].Id;
		update objRiskProductAlias;
    }


      	
	/*
	 Method Name : testRecordDelete
	 Description : Testing delete record records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testRecordDelete() {
        Risk_Issue__c objRisk = [SELECT Id FROM Risk_Issue__c LIMIT 1];
        Opportunity objOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        Plan_Product_Alias__c objPlanProduct = [SELECT Id FROM Plan_Product_Alias__c LIMIT 1];
        //Now we create a Risk Product Alias.
		Risk_Product_Alias__c objRiskProductAlias = new Risk_Product_Alias__c();
		objRiskProductAlias.Opportunity__c = objOpportunity.Id;
		objRiskProductAlias.Risk__c = objRisk.Id;
        objRiskProductAlias.Plan_Product_Alias__c = objPlanProduct.Id;
		insert objRiskProductAlias;

        delete objRiskProductAlias;
    }
    
}