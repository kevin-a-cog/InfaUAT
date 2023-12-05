/*
Class:  genericLookupChildControllerTest
@Author:        Vignesh D
@Created Date:  09 Sept 2020
@Description:   Test Class for ManagePlanProductsController Class.

Change History
*************************************************************************************************************************************
ModifiedBy               Date        Requested By        Description                                         Tag
*************************************************************************************************************************************
*/
@isTest
public with sharing class ManagePlanProductsControllerTest {
    @testSetup
    static void setupObjectTestData() {

        //Account
        sObject Account = new Account();
        UtilityTestData.mAccountData.put('Signature_Success__c','TRUE');
        Account = UtilityTest.putFieldRecord(Account, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{Account});

        //Account LOB
        UtilityTestData.mAccountLOB.put('Account__c',lAccount[0].Id);
        sObject AccLOB = new Account_LOB__c();
        AccLOB = UtilityTest.putFieldRecord(AccLOB, UtilityTestData.mAccountLOB);
        List<Account_LOB__c> lAccLOB = (List<Account_LOB__c>) UtilityTest.makeInsert(new List<sObject>{AccLOB});

        //Plan
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan');
        UtilityTestData.mPlan.put('Line_of_Business__c',lAccLOB[0].Id);
        UtilityTestData.mPlan.put('RecordTypeId',Schema.SObjectType.Plan__c.getRecordTypeInfosByName().get('Digital Plan').getRecordTypeId());
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan}); 

        //Related Plan Product with plan assigned
        sObject relAccProd = new Related_Account_Plan__c();
        UtilityTestData.mRelatedAccountProduct.put('Account_Plan__c',lPlan[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Account__c',lAccount[0].Id);
        relAccProd = UtilityTest.putFieldRecord(relAccProd, UtilityTestData.mRelatedAccountProduct);
        List<Related_Account_Plan__c> lRelAccProd = (List<Related_Account_Plan__c>) UtilityTest.makeInsert(new List<sObject>{relAccProd});

    }

    static testMethod void testGetPlanProducts() {
        User u1 = [SELECT id FROM User Where Profile.Name = 'System Administrator' AND IsActive = true Limit 1];
        System.RunAs(u1) {
            test.StartTest();
            
            List<Plan__c> plans = [Select Id,Account__c from Plan__c];
            System.assert(plans.size()>0, 'Plan does not exist');

            String planId = plans[0].Id;
            String accountId = plans[0].Account__c;

            //Get Plan Products assigned to a Plan
            List<Related_Account_Plan__c> assignedPP = ManagePlanProductsController.getPlanProducts(planId);
            System.assert(assignedPP.size()>0, 'No Assigned Plan Products to show');
            System.assert(ManagePlanProductsController.getplanproductslist(planId), 'Account has Plan Products');

            //Removed Plan Products associated with a Plan
            System.assert(ManagePlanProductsController.removePlanFromPlanProducts(assignedPP) == 'SUCCESS', 'Removing plan from plan products failed');

            Related_Account_Plan__c planProduct2 = new Related_Account_Plan__c();
            planProduct2.Account__c = accountId;
            planProduct2.Start_Date__c = System.today();
            planProduct2.End_Date__c = system.today().addYears(1);
            insert planProduct2;

            //Get Plan Products without a Plan excluding Status with 'Not Applicable'
            List<Related_Account_Plan__c> unassignedPP = ManagePlanProductsController.getAllPlanProducts(accountId, false);
            System.assert(unassignedPP.size()>0, 'No Unassigned Plan Products to show');

            //Get Plan Products without a Plan including Status with 'Not Applicable'
            List<Related_Account_Plan__c> allUnassignedPP = ManagePlanProductsController.getAllPlanProducts(accountId, true);

            //Adding Plan Products to a plan
            System.assert(ManagePlanProductsController.addPlanProductsToPlan(unassignedPP,planId) == 'SUCCESS', 'Adding plan products to plan failed');            

            //Get all Plan Products associated with a Plan under the account
            List<Related_Account_Plan__c> allPP = ManagePlanProductsController.getPlanProducts2(planId, accountId);
            System.assert(allPP.size()>0, 'No Plan Products to show');

            List<Related_Account_Plan__c> planProductsToUpdate = new List<Related_Account_Plan__c>();

            //Update Stage of Plan Products
            for(Related_Account_Plan__c pp : assignedPP){
                pp.Stage__c = 'Configuration';
                planProductsToUpdate.add(pp);
            }
            if(planProductsToUpdate != null && planProductsToUpdate.size()>0){
                System.assert(ManagePlanProductsController.savePlanProducts(planProductsToUpdate) == 'SUCCESS', 'Updation of plan products failed');
            }

            //Move Plan Products to other Plan
            List<Plan__c> lookupPlanRecords = ManagePlanProductsController.search('Test Plan', 'Plan__c', accountId);
            System.assert(lookupPlanRecords.size()>0, 'No lookup records to display');
            System.assert(ManagePlanProductsController.addPlanProductsToPlan(allPP, lookupPlanRecords[0].Id) == 'SUCCESS', 'Moving plan products to other plan failed');


            List<Account_LOB__c> lob = [Select Id,Name,Account__c,Account__r.Name from Account_LOB__c];
            System.assert(lob.size()>0, 'No LOB records');
            System.assert(ManagePlanProductsController.LOBrcrd(lob[0].Id) != null, 'AccountId not returned');
            ManagePlanProductsController.planproductcount(accountId);

            //Get Plan Record Types
            Map<Id, String> recordTypes = ManagePlanProductsController.getRecordTypeValues();
            System.assert(recordTypes.size()>0, 'Plan RecordTypes not found');

            //Creating a Plan
            Plan__c plan = new Plan__c();
            plan.Name = 'Test Plan 1';
            plan.Line_of_Business__c = lob[0].Id;
            plan.Account__c = lob[0].Account__c;
            String PlanRecordTypeId = new List<Id>((Set<Id>)recordTypes.keySet())[0];

            ManagePlanProductsController.insertplan(JSON.serialize(plan),PlanRecordTypeId);

            test.stopTest();
        }
    }
}