/*
* Name          :   CSMObjectiveAndMilestoneViewConTest
* Author        :   Deva M
* Created Date  :   15/12/2021
* Description   :   Test class for CSMObjectiveAndMilestoneViewController

Change History
**********************************************************************************************************
Modified By         Date            Jira No.        Description                 Tag
****/
@istest
public with sharing class CSMObjectiveAndMilestoneViewConTest {
    @testSetup
    static void setupObjectTestData() {
        Id riskRt = Schema.SObjectType.Risk_Issue__c.getRecordTypeInfosByName().get('Risk').getRecordTypeId();
        
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
        
        
        //Plan Contacts
        sObject PlanContact = new Plan_Contact__c();
        UtilityTestData.mPlanContact.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanContact.put('Contact__c',lContact[0].Id);
        //  UtilityTestData.mPlanContact.put('Contact_Type__c','Customer');
        PlanContact = UtilityTest.putFieldRecord(PlanContact, UtilityTestData.mPlanContact);
        List<Plan_Contact__c> lPlanContact = (List<Plan_Contact__c>) UtilityTest.makeInsert(new List<sObject>{PlanContact}); 
        
        // objective__c
        sObject objective = new Objective__c();
        UtilityTestData.mObjective.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mObjective.put('Sign_Off_Date__c',string.valueOf(Date.today()));
        UtilityTestData.mObjective.put('Is_Template__c','true');
        UtilityTestData.mObjective.put('Customer_Sign_off_Contact__c',lContact[0].Id);
        
        objective = UtilityTest.putFieldRecord(objective, UtilityTestData.mObjective);
        List<Objective__c> lObjective = (List<Objective__c>) UtilityTest.makeInsert(new List<sObject>{objective});                                 
        
        
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
        
        //Risk
        sObject risk = new Risk_Issue__c();
        UtilityTestData.mRiskIssue.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mRiskIssue.put('Type__c','Adoption');
        UtilityTestData.mRiskIssue.put('Milestone__c',lMilestone[0].Id);        
        UtilityTestData.mRiskIssue.put('Reason__c','Technical Issues');
        UtilityTestData.mRiskIssue.put('Status__c','Open');
        UtilityTestData.mRiskIssue.put('RecordTypeId',riskRt);
        risk = UtilityTest.putFieldRecord(risk, UtilityTestData.mRiskIssue);
        List<Risk_Issue__c> lRisk = (List<Risk_Issue__c>) UtilityTest.makeInsert(new List<sObject>{risk});
        
        //Now we insert the Plan Products.
        sObject Related_Account_Plan = new Related_Account_Plan__c();
        UtilityTestData.mRelatedAccountProduct.put('Forecast_Product__c','Active VOS');
        
        Related_Account_Plan = UtilityTest.putFieldRecord(Related_Account_Plan, UtilityTestData.mRelatedAccountProduct);
        List<Related_Account_Plan__c> lPlanProd2 = (List<Related_Account_Plan__c>) UtilityTest.makeInsert(new List<sObject>{Related_Account_Plan});
        
        
        
             
    }
    
    @isTest
    public static void fetchPlanProductsTest() {
        Plan__c obj=[select Id,Is_Internal__c from Plan__c limit 1];
        obj.Is_Internal__c=false;
        update obj;
        Test.startTest();
        CSMObjectiveAndMilestoneViewController.fetchPlanProducts(obj.id);
        Test.stopTest();
    }
    
    @isTest
    public static void createObjectiveProductsTest() {
        Objective__c obj=[select Id,Is_Internal__c from Objective__c limit 1];
        List<String> selectedProducts = new List<String> ();
        for(Plan_Product_Alias__c objProd:[Select Id FROM Plan_Product_Alias__c]){
            selectedProducts.add(objProd.id);
        }
        Test.startTest();
        CSMObjectiveAndMilestoneViewController.createObjectiveProducts(obj.id,selectedProducts);
        CSMObjectiveAndMilestoneViewController.fetchObjectiveProducts(obj.id);        
        Test.stopTest();
    }
    
    @isTest
    public static void checkInternalRecordsTest() {
        Objective__c obj=[select Id,Is_Internal__c from Objective__c limit 1];
        Milestone__c objMile=[select Id,Is_Internal__c from Milestone__c limit 1];
        Test.startTest();
        CSMObjectiveAndMilestoneViewController.checkInternalRecords(obj.id);   
        CSMObjectiveAndMilestoneViewController.checkInternalRecords(objMile.id);      
        Test.stopTest();
    }
}