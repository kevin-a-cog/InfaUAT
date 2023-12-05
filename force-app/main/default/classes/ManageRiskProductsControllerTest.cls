/*
Class:  ManageRiskProductsControllerTest
@Author:        Ambica P
@Created Date:  09 Sept 2020
@Description:   Test Class for ManagePlanProductsController Class.

Change History
*************************************************************************************************************************************
ModifiedBy               Date        Requested By        Description                                         Tag
*************************************************************************************************************************************
*/
@isTest
public class ManageRiskProductsControllerTest {
    
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
        sObject planProduct = new Related_Account_Plan__c();
        UtilityTestData.mRelatedAccountProduct.put('Account_Plan__c',lPlan[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Account__c',lAccount[0].Id);
        planProduct = UtilityTest.putFieldRecord(planProduct, UtilityTestData.mRelatedAccountProduct);
        
        //Related Plan Product with plan assigned
        sObject planProduct2 = new Related_Account_Plan__c();
        UtilityTestData.mRelatedAccountProduct.put('Account_Plan__c',lPlan[0].Id);
        UtilityTestData.mRelatedAccountProduct.put('Account__c',lAccount[0].Id);
        planProduct2 = UtilityTest.putFieldRecord(planProduct2, UtilityTestData.mRelatedAccountProduct);
        List<Related_Account_Plan__c> lPlanProd = (List<Related_Account_Plan__c>) UtilityTest.makeInsert(new List<sObject>{planProduct,planProduct2});
        
        
        //Risk
        sObject risk = new Risk_Issue__c();
        UtilityTestData.mRiskIssue.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mRiskIssue.put('Type__c','Adoption');

        risk = UtilityTest.putFieldRecord(risk, UtilityTestData.mRiskIssue);
        List<Risk_Issue__c> lRisk = (List<Risk_Issue__c>) UtilityTest.makeInsert(new List<sObject>{risk});
        
       
        //Risk
        sObject riskproduct = new Related_Risk_Product__c();
        UtilityTestData.mRelatedRiskProduct.put('Plan_Product__c',lPlanProd[0].Id);
        UtilityTestData.mRelatedRiskProduct.put('Risk_Issue__c',lRisk[0].Id);
        riskproduct = UtilityTest.putFieldRecord(riskproduct, UtilityTestData.mRelatedRiskProduct);
        List<Risk_Issue__c> lRiskProduct = (List<Risk_Issue__c>) UtilityTest.makeInsert(new List<sObject>{riskproduct});
        

    }

    static testMethod void ValidateRiksProduts() {
        
        User u1 = [SELECT id FROM User Where Profile.Name = 'System Administrator' AND IsActive = true Limit 1];

        System.RunAs(u1) {
            test.StartTest();
            
            List<Plan__c> plans = [Select Id,Account__c from Plan__c];
            System.assert(plans.size()>0, 'Plan does not exist');
           
            List<Risk_Issue__c> risks = [Select Id,Plan__c,Type__c from Risk_Issue__c];
            System.assert(risks.size()>0, 'Risk does not exist');

            List<Related_Risk_Product__c> riskProds = [Select Id from Related_Risk_Product__c];
            System.assert(riskProds.size()>0, 'Risk Products do not exist');

            string RiskId =risks[0].id;
            string PlanId =plans[0].id;
            
            Risk_Issue__c riskRec = new Risk_Issue__c();
            riskRec.Plan__c= plans[0].Id;
            riskRec.Type__c='Renewal';
            String newRiskId = ManageRiskProductsController.insertRisk(JSON.serialize(riskRec));
            System.assert((newRiskId!=null), 'Risk Insert failed');

            Boolean HasRiskProducts = ManageRiskProductsController.getRiskproductslist(RiskId);
            System.Assert(HasRiskProducts,'Risk Products dont exist');
            
            List<Related_Risk_Product__c> RiskProducts = ManageRiskProductsController.getRiskProducts(RiskId);
            System.Assert((RiskProducts!=null && RiskProducts.size()>0),'Risk Products dont exist');

            List<Related_Account_Plan__c> PlanProducts = ManageRiskProductsController.getPlanProducts(RiskId,PlanId);
            System.Assert((PlanProducts!=null && PlanProducts.size()>0),'Plan Products dont exist');

            String addProducts = ManageRiskProductsController.addRiskProducts(PlanProducts,RiskId);
            System.Assert(addProducts.equals('SUCCESS'),'Risk Products didnt add');

            String removeProducts = ManageRiskProductsController.removeRiskProducts(RiskProducts);
            System.Assert(removeProducts.equals('SUCCESS'),'Risk Products didnt remove');

           
            }
        }
            
}