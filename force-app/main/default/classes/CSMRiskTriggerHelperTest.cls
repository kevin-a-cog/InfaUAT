/*
* Name			:	CSMRiskTriggerHelperTest
* Author		:	Deva M
* Created Date	: 	07-Apr-2022	
* Description	:	Test class for CSMRiskTriggerHelper

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					Tag
**********************************************************************************************************
Deva M         		07-Apr-2022		N/A				Initial version.			N/A
*/
@istest
public with sharing class CSMRiskTriggerHelperTest {
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
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test');
        UtilityTestData.mPlan.put('Account__c',lNewCustomerAccount[0].Id);
        UtilityTestData.mPlan.put('Plan_Operational_Model__c', 'Named CSM');
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});  
        
        
        
        AccountTeamMember team = new AccountTeamMember();
        team.TeamMemberRole = 'CSM';
        team.UserId = UserInfo.getUserId();
        team.AccountId = lNewCustomerAccount[0].Id;
        insert team;
        
        
        
        sObj = new Opportunity(); 
        String OPP_RENEWAL_RT = 'Renewal Opportunity';                
        UtilityTestData.mOpportunityData.put('Name', 'Test');
        UtilityTestData.mOpportunityData.put('AccountId', lNewCustomerAccount[0].Id);        
        UtilityTestData.mOpportunityData.put('StageName', 'Lead');
        UtilityTestData.mOpportunityData.put('CloseDate', string.valueOf(System.today().addDays(1)));
        UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId());
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        
        
        
        
        //Now we insert the Plan Products.
        sObject objPlanProductOne = new Related_Account_Plan__c();
        UtilityTestData.mRelatedAccountProduct.put('Account_Plan__c',lPlan[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Account__c',lNewCustomerAccount[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Opportunity__c',lOpportunity[0].Id);       
        
        objPlanProductOne = UtilityTest.putFieldRecord(objPlanProductOne, UtilityTestData.mRelatedAccountProduct);
        List<Related_Account_Plan__c> lPlanProd1 = (List<Related_Account_Plan__c>) UtilityTest.makeInsert(new List<sObject>{objPlanProductOne});
        
        //Now we insert the Plan Products.
        sObject objPlanProductTwo = new Related_Account_Plan__c();
        UtilityTestData.mRelatedAccountProduct.put('Account_Plan__c',lPlan[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Account__c',lNewCustomerAccount[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Opportunity__c',lOpportunity[0].Id);       
        
        
        objPlanProductTwo = UtilityTest.putFieldRecord(objPlanProductTwo, UtilityTestData.mRelatedAccountProduct);
        List<Related_Account_Plan__c> lPlanProd2 = (List<Related_Account_Plan__c>) UtilityTest.makeInsert(new List<sObject>{objPlanProductTwo});
        
        
        
        
        
        Id riskRt = Schema.SObjectType.Risk_Issue__c.getRecordTypeInfosByName().get('Risk').getRecordTypeId();
        
        //Risk
        sObject objRisk = new Risk_Issue__c();
        UtilityTestData.mRiskIssue.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mRiskIssue.put('RecordTypeId',riskRt);
        objRisk = UtilityTest.putFieldRecord(objRisk, UtilityTestData.mRiskIssue);
        List<Risk_Issue__c> lRisk = (List<Risk_Issue__c>) UtilityTest.makeInsert(new List<sObject>{objRisk});
        
        //Risk
        sObject objRisk2 = new Risk_Issue__c();
        UtilityTestData.mRiskIssue.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mRiskIssue.put('RecordTypeId',riskRt);
        objRisk2 = UtilityTest.putFieldRecord(objRisk2, UtilityTestData.mRiskIssue);
        List<Risk_Issue__c> lRisk2 = (List<Risk_Issue__c>) UtilityTest.makeInsert(new List<sObject>{objRisk2});
        
        
        
        //Now we create a Plan Product Alias.
        Plan_Product_Alias__c objPlanProductAlias = new Plan_Product_Alias__c();
        objPlanProductAlias.Plan__c = lPlan[0].Id;
        objPlanProductAlias.Plan_Product__c = lPlanProd2[0].Id;
        objPlanProductAlias.Forecast_Product__c='Customer 360 Insights';       
        insert objPlanProductAlias;
        lPlanProd2[0].Plan_Product_Alias__c = objPlanProductAlias.Id;
        
        
        Plan_Product_Alias__c objPlanProductAliasTwo = new Plan_Product_Alias__c();
        objPlanProductAliasTwo.Plan__c = lPlan[0].Id;
        objPlanProductAliasTwo.Plan_Product__c = lPlanProd2[0].Id;
        objPlanProductAliasTwo.Forecast_Product__c='Address Verification';
        insert objPlanProductAliasTwo;
        
        lPlanProd2[0].Plan_Product_Alias__c = objPlanProductAliasTwo.Id;
        update new List<Related_Account_Plan__c>{lPlanProd2[0]};
            
            
            //Now we create a Risk Product Alias.
            Risk_Product_Alias__c objRiskProductAlias = new Risk_Product_Alias__c();
        objRiskProductAlias.Opportunity__c = lOpportunity[0].Id;
        objRiskProductAlias.Plan_Product_Alias__c=objPlanProductAlias.Id;
        objRiskProductAlias.Risk__c = lRisk[0].Id;        
        Risk_Product_Alias__c objRiskProductAlias2 = new Risk_Product_Alias__c();
        objRiskProductAlias2.Opportunity__c = lOpportunity[0].Id;
        objRiskProductAlias2.Risk__c = lRisk2[0].Id;
        objRiskProductAlias2.Plan_Product_Alias__c=objPlanProductAliasTwo.Id;
        insert new List<Risk_Product_Alias__c>{objRiskProductAlias,objRiskProductAlias2};       
            
            }
    
    /*
Method Name : updateRiskStatusTest
Description : Testing update records.
Parameters	 : None
Return Type : None
*/
    @isTest
    public static void updateRiskStatusTest() {
        Risk_Issue__c objRisk = [SELECT Id,Status__c FROM Risk_Issue__c LIMIT 1];
        objRisk.Risk_Stage__c='Resolved';
        objRisk.Closure_Notes__c='Request Closure';
        Test.startTest();
        update objRisk;
        Test.stopTest();
    }
     @isTest
    public static void updateRiskStatusTestD() {
        Test.startTest();
        Risk_Issue__c objRisk = [SELECT Id,Status__c FROM Risk_Issue__c LIMIT 1];
       	delete objRisk;
        Test.stopTest();
    }
}