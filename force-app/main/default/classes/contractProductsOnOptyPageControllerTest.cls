/*
Class:          contractProductsOnOptyPageControllerTest
@Author:        Chandana Gowda
@Created Date:  09-Nov-2020
@Description:   Test Class for contractProductsOnOptyPageController
Change History
**********************************************************************************************************************************************************
ModifiedBy          Date        Requested By        Description                                                                             Tag
**********************************************************************************************************************************************************
**********************************************************************************************************************************************************
*/
@isTest
public class contractProductsOnOptyPageControllerTest {

    public @IsTest(SeeAllData = true)
    static void testMRContracts(){
        Contract  mrContract = [SELECT Id,SBQQ__RenewalOpportunity__c FROM Contract WHERE Renewal_Type__c = 'MR' AND SBQQ__RenewalOpportunity__c != null LIMIT 1];
        Test.startTest();

        List<SBQQ__Subscription__c> lstSubRec = contractProductsOnOptyPageController.getSubscriptionRecs(mrContract.SBQQ__RenewalOpportunity__c);
        System.assertNotEquals(lstSubRec, null);

        Test.stopTest();        
    }

    public @IsTest(SeeAllData = true)
    static void testAmendedContracts(){
        Contract  amendContract = [SELECT Id,SBQQ__RenewalOpportunity__c FROM Contract WHERE SBQQ__RenewalOpportunity__c != null AND SBQQ__Order__r.Type = 'Amendment' LIMIT 1];
        Test.startTest();

        List<SBQQ__Subscription__c> lstSubRec = contractProductsOnOptyPageController.getSubscriptionRecs(amendContract.SBQQ__RenewalOpportunity__c);
        System.assertNotEquals(lstSubRec, null);

        Test.stopTest();        
    }    

    public @IsTest(SeeAllData = true)
    static void testMigratedContracts(){
        Contract  amendContract = [SELECT Id,SBQQ__RenewalOpportunity__c FROM Contract WHERE SBQQ__RenewalOpportunity__c != null AND SBQQ__Quote__c = null LIMIT 1];
        Test.startTest();

        List<SBQQ__Subscription__c> lstSubRec = contractProductsOnOptyPageController.getSubscriptionRecs(amendContract.SBQQ__RenewalOpportunity__c);
        System.assertNotEquals(lstSubRec, null);

        Test.stopTest();        
    }    
}