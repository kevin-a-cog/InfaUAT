/*
* Name          :   CSMObjectiveTriggerHelperTest
* Author        :   Deva M
* Created Date  :   15/12/2021
* Description   :   Test class for CSMObjectiveTriggerHelperTest

Change History
**********************************************************************************************************
Modified By         Date            Jira No.        Description                 Tag
****/
@istest
public with sharing class CSMObjectiveTriggerHelperTest {
    @testSetup
    static void setupObjectTestData() {
        //Account
        sObject Account = new Account();
        UtilityTestData.mAccountData.put('Signature_Success__c','TRUE');
        Account = UtilityTest.putFieldRecord(Account, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{Account});
        
        sObject Contact = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname');
        UtilityTestData.mContactData.put('LastName','LastName');
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        Contact = UtilityTest.putFieldRecord(Contact, UtilityTestData.mContactData); 
        
        sObject Contact2 = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname');
        UtilityTestData.mContactData.put('LastName','LastName');
        UtilityTestData.mContactData.put('Email','test145@test.com');
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        Contact2 = UtilityTest.putFieldRecord(Contact2, UtilityTestData.mContactData); 
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{Contact, Contact2});
        
        //Plan
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mPlan.put('Name','Test Plan One');//
        UtilityTestData.mPlan.put('Sub_Stage__c','On-board');
        UtilityTestData.mPlan.put('Is_Internal__c','true');
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByDeveloperName().get('New_Product_Implementation').getRecordTypeId());
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);               
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});
        
        //Now we create Related Plan Product records.
        Related_Account_Plan__c objPlanProduct = new Related_Account_Plan__c();
        objPlanProduct.Account_Plan__c = Plan.Id;
        objPlanProduct.Account__c = Account.Id;
        //Now we create Related Plan Product records.
        Related_Account_Plan__c objPlanProduct2 = new Related_Account_Plan__c();
        objPlanProduct2.Account_Plan__c = Plan.Id;
        objPlanProduct2.Account__c = Account.Id;
        insert new List<Related_Account_Plan__c>{objPlanProduct,objPlanProduct2};
            
            sObject objective = new Objective__c();
        UtilityTestData.mObjective.put('Plan__c',lPlan[0].Id);
        objective = UtilityTest.putFieldRecord(objective, UtilityTestData.mObjective);
        List<Objective__c> lObjective = (List<Objective__c>) UtilityTest.makeInsert(new List<sObject>{objective});
        
        Objective_Product__c op = new Objective_Product__c();
        op.Objective__c = objective.Id;
        op.Plan_Product__c = objPlanProduct.Id; 
        
        Objective_Product__c op2 = new Objective_Product__c();
        op2.Objective__c = objective.Id;
        op2.Plan_Product__c = objPlanProduct2.Id; 
        insert new List<Objective_Product__c>{op,op2};
            
            sObject mstone = new Milestone__c();
        UtilityTestData.mPlanMilestone.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanMilestone.put('Status__c','In Progress');
        UtilityTestData.mPlanMilestone.put('Objective__c',lObjective[0].Id);
        UtilityTestData.mPlanMilestone.put('Key_Milestone__c','false');
        mstone = UtilityTest.putFieldRecord(mstone, UtilityTestData.mPlanMilestone);
        
        sObject mstone1 = new Milestone__c();
        UtilityTestData.mPlanMilestone.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mPlanMilestone.put('Status__c','Complete');//
        UtilityTestData.mPlanMilestone.put('Objective__c',lObjective[0].Id);
        UtilityTestData.mPlanMilestone.put('Key_Milestone__c','true');
        mstone1 = UtilityTest.putFieldRecord(mstone1, UtilityTestData.mPlanMilestone);
        List<Milestone__c> lMilestone = (List<Milestone__c>) UtilityTest.makeInsert(new List<sObject>{mstone,mstone1}); 
    }

    @isTest
    public static void updateeTriggerTest() {
        Objective__c obj=[select Id,Is_Internal__c from Objective__c limit 1];
        obj.Is_Internal__c=false;
        update obj;
        Test.startTest();
        //Update internla again
        obj.Is_Internal__c=true;
        update obj;
        Test.stopTest();
    }
}