/*
 * Name			:	CSMPlanActivitiesControllerTest
 * Author		:	Deva M
 * Created Date	: 	06-Apr-2022
 * Description	:	Test Class for Plan Activities controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
Deva M          		06-Apr-2022		N/A				Initial version.			N/A
 */
@isTest
public with sharing class CSMPlanActivitiesControllerTest {
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
        
        String OPP_RENEWAL_RT = 'Renewal Opportunity';
        String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
                        
        UtilityTestData.mOpportunityData.put('AccountId', lNewCustomerAccount[0].Id);
     //   UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
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
        
		
        
         // objective__c
        sObject objective = new Objective__c();
        UtilityTestData.mObjective.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mObjective.put('Sign_Off_Date__c',string.valueOf(Date.today()));
        UtilityTestData.mObjective.put('Is_Template__c','true');
        UtilityTestData.mObjective.put('Customer_Sign_off_Contact__c',lContact[0].Id);
        
        objective = UtilityTest.putFieldRecord(objective, UtilityTestData.mObjective);
        List<Objective__c> lObjective = (List<Objective__c>) UtilityTest.makeInsert(new List<sObject>{objective});
        
        
		//Now we create the Objective Products.
		Objective_Product__c objObjectiveProduct = new Objective_Product__c();
		objObjectiveProduct.Objective__c = lObjective[0].Id;
		objObjectiveProduct.Plan_Product__c = lPlanProd2[0].Id;
		insert objObjectiveProduct;

        //Milestone__c
        
        sObject mstone = new Milestone__c();
        UtilityTestData.mPlanMilestone.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanMilestone.put('Is_Template__c','true');
        UtilityTestData.mPlanMilestone.put('Objective__c',lObjective[0].Id);
        UtilityTestData.mPlanMilestone.put('Planned_Completion_Date__c',string.valueOf(Date.today()));
        UtilityTestData.mPlanMilestone.put('Milestone_Type__c','Business Milestone');
        mstone = UtilityTest.putFieldRecord(mstone, UtilityTestData.mPlanMilestone);
        
        sObject mstone1 = new Milestone__c();
        UtilityTestData.mPlanMilestone.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanMilestone.put('Is_Template__c','true');
        UtilityTestData.mPlanMilestone.put('Objective__c',lObjective[0].Id);
        UtilityTestData.mPlanMilestone.put('Planned_Completion_Date__c',string.valueOf(Date.today()));
        UtilityTestData.mPlanMilestone.put('Milestone_Type__c','Business Milestone');
        mstone1 = UtilityTest.putFieldRecord(mstone1, UtilityTestData.mPlanMilestone);
        List<Milestone__c> lMilestone = (List<Milestone__c>) UtilityTest.makeInsert(new List<sObject>{mstone,mstone1});
        
        
		//Now we create the Milestone Product.
		Milestone_Product__c objMilestoneProduct = new Milestone_Product__c();
		objMilestoneProduct.MIlestone__c = lMilestone[0].Id;
		objMilestoneProduct.Objective_Product__c = objObjectiveProduct.Id;
		insert objMilestoneProduct;
        Task planTask = new Task(Subject = 'Plan Task',TaskSubType= 'Email',WhatId=lPlan[0].Id);
        Task milestoneTask = new Task(Subject = 'Milestone Task',TaskSubType= 'Email',WhatId=lMilestone[0].Id);
        insert new List<Task>{planTask,milestoneTask};
    }
	

    /*
	 Method Name : testFetchingRecords
	 Description : Testing fetching records.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testFetchingRecords() {
        Plan__c objPlan = [SELECT Id FROM Plan__c];
        //Now we get the records.
        Test.startTest();
        System.assertNotEquals(CSMPlanActivitiesController.getRecords(objPlan.Id) == null, true, 'Unable to get records.');
        Test.stopTest();
    }
}