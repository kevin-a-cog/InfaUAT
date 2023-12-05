/*
* Name          :   CSMManageObjectiveProductsTest
* Author        :   Deva M
* Created Date  :   31-08-2021
* Description   :   CSMManageObjectiveProducts controller.

Change History
**********************************************************************************************************
Modified By         Date            Jira No.        Description                 Tag
**********************************************************************************************************
Deva M              31-08-2021      N/A             Initial version.            N/A
*/
@isTest(seeAllData = false)
public class CSMManageObjectiveProductsTest {
    
    /*
	 Method Name : setup
	 Description : Test setup method.
	 Parameters	 : None
	 Return Type : None
	 */
    @testSetup 
    public static void setup() {

         SObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test');
        UtilityTestData.mAccountData.put('BillingCountry', 'US');       
        Id riskRt = Schema.SObjectType.Risk_Issue__c.getRecordTypeInfosByName().get('Risk').getRecordTypeId();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Contact();
        UtilityTestData.mContactData.put('LastName', 'Test');
        UtilityTestData.mContactData.put('AccountId', lNewCustomerAccount[0].Id);        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
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
     
        UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
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

		//Now we create the Technical Product Line.
		Technical_Product_Line__c objTechnicalProductLine = new Technical_Product_Line__c();
		objTechnicalProductLine.Name = 'Address Verification';
		objTechnicalProductLine.Forecast_Product__c = 'Active VOS';
		objTechnicalProductLine.Status__c = 'Active';
		insert objTechnicalProductLine;
        
        //Now we create a Plan Product Alias.
        Plan_Product_Alias__c objPlanProductAlias = new Plan_Product_Alias__c();
        objPlanProductAlias.Plan__c = lPlan[0].Id;
        objPlanProductAlias.Plan_Product__c = lPlanProd2[0].Id;
		objPlanProductAlias.Technical_Product_Line__c = objTechnicalProductLine.Id;
        insert objPlanProductAlias;
        
         // objective__c
        sObject objective = new Objective__c();
        UtilityTestData.mObjective.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mObjective.put('Sign_Off_Date__c',string.valueOf(Date.today()));
        UtilityTestData.mObjective.put('Is_Template__c','true');
        UtilityTestData.mObjective.put('Customer_Sign_off_Contact__c',lContact[0].Id);
        
        objective = UtilityTest.putFieldRecord(objective, UtilityTestData.mObjective);
        List<Objective__c> lObjective = (List<Objective__c>) UtilityTest.makeInsert(new List<sObject>{objective});    
    }


    @isTest
    public static void testgetAssingedRecords() {
        Plan__c plan=[select Id from Plan__c limit 1];
        Objective__c objective=[select Id from Objective__c limit 1];        
        GlobalDataTableWrapperClass obj = new GlobalDataTableWrapperClass();
		Plan_Product_Alias__c objPlanProductAlias = [SELECT Id FROM Plan_Product_Alias__c LIMIT 1];
		List<Objective_Product__c> lstObjectiveProducts = new List<Objective_Product__c>();

		//First we activate the Technical Product lines.
		for(Objective_Product__c objRecord : [SELECT Id FROM Objective_Product__c LIMIT 1000]) {
			objRecord.Plan_Product_Alias__c = objPlanProductAlias.Id;
			lstObjectiveProducts.add(objRecord);
		}
		if(!lstObjectiveProducts.isEmpty()) {
			update lstObjectiveProducts;
		}

		//Now we test the method.
        obj=CSMManageObjectiveProducts.getRecords(plan.Id,false,objective.Id); 
        System.assert(obj.lstRecords.size()>0);
        
    }
    
    @isTest
    public static void testgetRecordsRelated() {
        Plan__c plan=[select Id from Plan__c limit 1];
        Objective__c objective=[select Id from Objective__c limit 1]; 
        GlobalDataTableWrapperClass obj = new GlobalDataTableWrapperClass();
		Plan_Product_Alias__c objPlanProductAlias = [SELECT Id FROM Plan_Product_Alias__c LIMIT 1];
		List<Objective_Product__c> lstObjectiveProducts = new List<Objective_Product__c>();
		List<Plan_Product_Alias__c> lstRecords;

		//First we activate the Technical Product lines.
		for(Objective_Product__c objRecord : [SELECT Id FROM Objective_Product__c LIMIT 1000]) {
			objRecord.Plan_Product_Alias__c = objPlanProductAlias.Id;
			lstObjectiveProducts.add(objRecord);
		}
		if(!lstObjectiveProducts.isEmpty()) {
			update lstObjectiveProducts;
		}

		//Now we test the method.
		lstRecords = new List<Plan_Product_Alias__c>([Select Id from Plan_Product_Alias__c]);
        CSMManageObjectiveProducts.getRecordsRelated(objective.Id,new List<String>{lstRecords[0].Id}); 
        obj=CSMManageObjectiveProducts.getRecords(plan.Id,true,objective.Id);
        
        //Now test deleting Objective_Product__c records
        List<Objective_Product__c> oplist = new List<Objective_Product__c>([select id from Objective_Product__c]);
        CSMManageObjectiveProducts.getRecordsDeleted(oplist);
        List<Objective_Product__c> checkafterdelete = new List<Objective_Product__c>([select id from Objective_Product__c]);
        System.assert(checkafterdelete.size()<=0);  
    }
    
}