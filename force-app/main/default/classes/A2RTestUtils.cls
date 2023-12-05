/****************************************************************************************************************
Class:          A2RTestUtils
@Author:        vsabbell
@Created Date:  8/21/2018.
@Description:   Contains TestMethods to Test chatter notification for A2R 2.1 functionality.

******************************************************************************************************************
Change History
*******************************************************************************************************************
ModifiedBy          Date        Requested By        Description                             Tag
vsabbella             11/29: Add coverage for E2ANotifySMGController developed by ortoo for A2R 2.2 Phase.
*******************************************************************************************************************/

@IsTest(SeeAllData=false)
public with sharing class A2RTestUtils {
    private final static string ASSET_STATUS_PROVISION_COMPLETE = 'Provisioning Complete';
    private final static string PROD_PRICING_MODEL_SUBSCRIPTION = 'Subscription';
    private final static string DELIVERY_METHOD_HOSTED = 'Hosted';
    private final static string DELIVERY_METHOD_MIX = 'Mix';

    public static A2RTestFuel testFuel;

    @TestSetup
    public static void A2RdataSetup(){
        testFuel = new A2RTestFuel();
        List<Account> accountList = testFuel.AccountList;
        List<Asset> assetList =testFuel.assetList;
        List<Account_LOB__c> accountLOBS = testFuel.accountLOBList;
        List<Account_Product__c> AccountProductList =testFuel.accountProductList;
        User_Exemptions__c settings = testFuel.settings;
        List<Opportunity> opportunities = testFuel.OpportunityList;
    }


    /*
    * Testing Opportunity Creation.
    * CSM access to opportunity after adding him on the account as CSM.
    * Creation of Plan,Adding account products, risk and opportunity plan.
    * Notify SMGs.
    *
    * */
    private static testMethod void testChatterNotificationPositive(){

        Map<String,User> userByRole = A2RTestFuel.getUserMapByRole(true);
        A2RTestFuel.AssignpermissionSets(userByRole);
        assignCustomPermission(userByRole,'CSMUser');
        A2RTestFuel testFuel = new A2RTestFuel();

        List<Account> AcctList = [select id,name from account limit 1];
        Account Acct =AcctList[0];
        Opportunity Oppty = [select Id,name from Opportunity where AccountId =:Acct.Id ];
        List<Account_Product__c>  accountProductList1= [Select Id,name from Account_Product__c where Account__c=:Acct.Id];

        testFuel.AccountList = AcctList;
        testFuel.OpportunityList = new List<Opportunity>{Oppty};
        testFuel.accountProductList = accountProductList1;
        //testFuel.accountLOBList =[select Id,Name from Account_LOB__c where Account__c = :testFuel.AccountList[0].Id]
        System.runAs(userByRole.get('CSM')){
            // CSM should NOT have access to opportunity here..
            List<Opportunity> opp = [select id,name from opportunity where AccountId=:Acct.Id];
        //    System.assertEquals(opp.size(),0);

        }
        system.runAs(userByRole.get('Admin')){
            List<AccountTeamMember> AccountTeamMemberList =A2RTestFuel.AssignaccountTeamList(userByRole, Acct.Id);
            List<Opportunity> oppList = [select id,name,OwnerId from opportunity where AccountId=:Acct.Id and IsClosed=false];
            System.assertEquals(oppList.size(),1);
            oppList[0].OwnerId = userByRole.get('SMG').Id;
        }
        System.runAs(userByRole.get('CSM')){
            CustomPermissionsReader csm = new CustomPermissionsReader();
            if(!csm.hasPermission('CSMUser')){
                system.assert(false);
            }
            // CSM should have access to opportunity here as he is added as account team member with read access to opportunity.
            List<Opportunity> opp = [select id,name from opportunity where AccountId=:Acct.Id];
            System.assertEquals(opp.size(),1);

            List<Sobject> lobsobjectList = (List<Sobject>)testFuel.accountLOBList;
            List<Sobject> accountProductList = (List<Sobject>)testFuel.accountProductList;
            List<Sobject> plansobjectList = (List<Sobject>)testFuel.PlanList;
            List<Sobject> planProductsobjectList = (List<Sobject>)testFuel.PlanProductList;
            List<Sobject> risksobjectList = (List<Sobject>)testFuel.riskIssueList;

            //System.assert();
            List<Sobject> relatedOpportunityPlanList = (List<Sobject>)testFuel.relatedOpportunityPlanList;
            String NotificationStatus = A2R_Controller.invokeNotification(relatedOpportunityPlanList[0].Id);
            A2R_Controller.A2RResponse response = (A2R_Controller.A2RResponse) JSON.deserialize(NotificationStatus,A2R_Controller.A2RResponse.class);
           // boolean success = response.isSuccess();
            //String message = response.getMessage();
           // system.assert(response.isSuccess(),response.getMessage());
            Related_Opportunity_Plan__c relOppPlan = (Related_Opportunity_Plan__c)relatedOpportunityPlanList[0];
            system.assert(relOppPlan.Opportunity__c!=null, 'Related Opportunity plan does not have Opportunity associated.');
            //String email = E2ANotifySMGController.getToAddress(relatedOpportunityPlanList[0].Id,'Related_Opportunity_Plan__c');
            
           // system.assert(email!=null,'NotitySMG:Opportunity Owner email is empty.');
        }
    }


    private static testMethod void testChatterNotificationNegative(){

        Map<String,User> userByRole = A2RTestFuel.getUserMapByRole(false);
        A2RTestFuel.AssignpermissionSets(userByRole);
        assignCustomPermission(userByRole,'CSMUser');
        A2RTestFuel testFuel = new A2RTestFuel();

        List<Account> AcctList = [select id,name from account limit 1];
        Account Acct =AcctList[0];
        Opportunity Oppty = [select Id,name from Opportunity where AccountId =:Acct.Id ];
        List<Account_Product__c>  accountProductList1= [Select Id,name from Account_Product__c where Account__c=:Acct.Id];

        testFuel.AccountList = AcctList;
        testFuel.OpportunityList = new List<Opportunity>{Oppty};
        testFuel.accountProductList = accountProductList1;
        //testFuel.accountLOBList =[select Id,Name from Account_LOB__c where Account__c = :testFuel.AccountList[0].Id]
        System.runAs(userByRole.get('CSM')){
            // CSM should NOT have access to opportunity here..
            List<Opportunity> opp = [select id,name from opportunity where AccountId=:Acct.Id];
           // System.assertEquals(opp.size(),0);

        }
        system.runAs(userByRole.get('Admin')){
            List<AccountTeamMember> AccountTeamMemberList =A2RTestFuel.AssignaccountTeamList(userByRole, Acct.Id);
            List<Opportunity> oppList = [select id,name,OwnerId from opportunity where AccountId=:Acct.Id and IsClosed=false];
            System.assertEquals(oppList.size(),1);
            oppList[0].OwnerId = userByRole.get('SMG').Id;
        }
        System.runAs(userByRole.get('CSM')){
            CustomPermissionsReader csm = new CustomPermissionsReader();
            if(!csm.hasPermission('CSMUser')){
               // system.assert(false);
            }
            // CSM should have access to opportunity here as he is added as account team member with read access to opportunity.
            List<Opportunity> opp = [select id,name from opportunity where AccountId=:Acct.Id];
            System.assertEquals(opp.size(),1);

            List<Sobject> lobsobjectList = (List<Sobject>)testFuel.accountLOBList;
            List<Sobject> accountProductList = (List<Sobject>)testFuel.accountProductList;
            List<Sobject> plansobjectList = (List<Sobject>)testFuel.PlanList;
            List<Sobject> planProductsobjectList = (List<Sobject>)testFuel.PlanProductList;
            List<Sobject> risksobjectList = (List<Sobject>)testFuel.riskIssueList;

            //System.assert();
            List<Sobject> relatedOpportunityPlanList = (List<Sobject>)testFuel.relatedOpportunityPlanList;
            String NotificationStatus = A2R_Controller.invokeNotification(relatedOpportunityPlanList[0].Id);
            A2R_Controller.A2RResponse response = (A2R_Controller.A2RResponse) JSON.deserialize(NotificationStatus,A2R_Controller.A2RResponse.class);
            //boolean success = response.isSuccess();
            //String message = response.getMessage();
            //system.assert(response.isSuccess(),'Assertion should fail if the custom permission is not assigned to user invoking NotifySMGs');
            Related_Opportunity_Plan__c relOppPlan = (Related_Opportunity_Plan__c)relatedOpportunityPlanList[0];
            system.assert(relOppPlan.Opportunity__c!=null, 'Related Opportunity plan does not have Opportunity associated.');
           // String email = E2ANotifySMGController.getToAddress(relatedOpportunityPlanList[0].Id,'Related_Opportunity_Plan__c');
          //  system.assert(email!=null,'NotitySMG:Opportunity Owner email is empty.');
        }
    }
   

    public static void assignCustomPermission(Map<String,User> userByRole, String CustomPermission){

        PermissionSet ps = new PermissionSet();
        ps.Name = 'Notify_SMGs';
        ps.Label = 'Notify_SMGs';
        insert ps;
        SetupEntityAccess sea = new SetupEntityAccess();
        sea.ParentId = ps.Id;
        CustomPermission cp = [select Id from CustomPermission where DeveloperName = :CustomPermission];
        system.assert(cp!=null,'CustomPermission '+CustomPermission+' not found.');
        sea.SetupEntityId = cp.Id;

        insert sea;
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userByRole.get('CSM').Id;
        psa.PermissionSetId = ps.Id;
        insert psa;

    }
    public static void createTestData(){


        List<product2> productList = new List<product2>();
        // Create product2 record
        Product2 oProduct = new Product2();
        oProduct.Name = 'Test';
        oProduct.Pricing_Business_Model__c = 'Subscription';
        oProduct.Forecast_Product__c = 'Data Quality';
        oProduct.Delivery_Method__c  = 'Hosted Multi Tenant';
        //oProduct.blng__BillingRule__c = bilRule.id;
        //oProduct.blng__RevenueRecognitionRule__c = revRecogRule.id;
        //oProduct.blng__TaxRule__c = taxRule.id;
        //insert oProduct;
        productList.add(oProduct);

        /*Product2 oProduct1 = new Product2();
        oProduct1.Name = 'Test';
        oProduct1.Pricing_Business_Model__c = 'Subscription';
        oProduct1.Forecast_Product__c = 'Cloud Application Integration';
        oProduct1.Delivery_Method__c  = 'Hosted Multi Tenant';
        //oProduct1.blng__BillingRule__c = bilRule.id;
        //oProduct1.blng__RevenueRecognitionRule__c = revRecogRule.id;
        //oProduct1.blng__TaxRule__c = taxRule.id;
        // insert oProduct1;
        productList.add(oProduct1);

        */

        Insert productList;

        // Create/Update standard pricebook2
        Id pricebookId = Test.getStandardPricebookId();

        Pricebook2 pb = new Pricebook2();
        pb.Id = pricebookId;
        pb.IsActive = true;

        update pb;

        // List<pricebookEntry> pricebookEntr
        // create PriceBookEntry2 for standard pricebook
        pricebookEntry pbe = new pricebookEntry();
        pbe.IsActive = true;
        pbe.Pricebook2Id = pb.Id;
        pbe.Product2Id = oProduct.Id;
        pbe.CurrencyIsoCode = 'USD';
        pbe.UnitPrice = 500.00;

        insert pbe;

        // set custom setting data for ignore validation rule when Delete the Opportunity Product
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;

        List<Account> accountList = new List<Account>();
        // create Account
        Account acc = new Account();
        acc.Name = 'test';
        acc.BillingCountry = 'India';
        acc.Payment_Terms__c = 'Net 30';
        //insert acc;
        accountList.add(acc);

       /* Account acc1 = new Account();
        acc1.Name = 'test1';
        acc1.BillingCountry = 'India';
        acc1.Payment_Terms__c = 'Net 30';
        //insert acc;
        accountList.add(acc1);*/

        insert accountList;

        List<Account_LOB__c>  accountLOBList = new List<Account_LOB__c>();

        Account_LOB__c lob1 = new Account_LOB__c();
        lob1.Account__c = acc.Id;
        accountLOBList.add(lob1);

        /*Account_LOB__c lob2 = new Account_LOB__c();
        lob2.Account__c = acc1.Id;
        accountLOBList.add(lob2);

        Account_LOB__c lob3 = new Account_LOB__c();
        lob3.Account__c = acc1.Id;
        accountLOBList.add(lob3);*/

        insert accountLOBList;

        List<Account_Product__c> accountProductList = new List<Account_Product__c>();

        Account_Product__c ap1 = new Account_Product__c();
        ap1.Account__c = acc.Id;
        ap1.Line_of_Business__c = lob1.Id;
        ap1.Forecast_Product__c = 'Data Quality';
        accountProductList.add(ap1);

        Account_Product__c ap2 = new Account_Product__c();
        ap2.Account__c = acc.Id;
        ap2.Line_of_Business__c = lob1.Id;
        ap2.Forecast_Product__c = 'Cloud Application Integration';
        accountProductList.add(ap2);

        Account_Product__c ap3 = new Account_Product__c();
        ap3.Account__c = acc.Id;
        ap3.Line_of_Business__c = lob1.Id;
        ap3.Forecast_Product__c = 'Data Transformation';
        accountProductList.add(ap3);

        Account_Product__c ap4 = new Account_Product__c();
        ap4.Account__c = acc.Id;
        ap4.Line_of_Business__c = lob1.Id;
        ap4.Forecast_Product__c = 'Identity Resolution';
        accountProductList.add(ap4);




        insert accountProductList;

        test.startTest();

        List<Asset> assetList = new List<Asset>();
        // create asset1
        Asset oAsset1 = new Asset();
        oAsset1.Name = 'testAsset1';
        oAsset1.AccountId = acc.Id;
        oAsset1.Product2 = oProduct;
        oAsset1.Asset_Identifier__c = null;
        //oAsset1.Pricin
        //PROD_PRICING_MODEL_SUBSCRIPTION
        assetList.add(oAsset1);

        // create asset2
        Asset oAsset2 = new Asset();
        oAsset2.Name = 'testAsset2';
        oAsset2.AccountId = acc.Id;
        oAsset2.Product2 = oProduct;
        oAsset2.Asset_Identifier__c = null;
        assetList.add(oAsset2);

        // create asset3
        Asset oAsset3 = new Asset();
        oAsset3.Name = 'testAsset3';
        oAsset3.AccountId = acc.Id;
        oAsset3.Product2 = oProduct;
        oAsset3.Asset_Identifier__c = null;
        assetList.add(oAsset3);

        // create asset4
        Asset oAsset4 = new Asset();
        oAsset4.Name = 'testAsset4';
        oAsset4.AccountId = acc.Id;
        oAsset4.Product2 = oProduct;
        oAsset4.Asset_Identifier__c = null;
        assetList.add(oAsset4);

        insert assetList;

        //Update Assets
        List<Asset> updateAssets = new List<Asset>();
        oAsset1.Status = 'Provisioning Complete';
        oAsset1.Asset_Identifier__c = '1234';
        updateAssets.add(oAsset1);

        oAsset4.Status = 'Provisioning Complete';
        oAsset4.Asset_Identifier__c = '1234';
        updateAssets.add(oAsset4);

        //update updateAssets;
        test.stopTest();
    }



}