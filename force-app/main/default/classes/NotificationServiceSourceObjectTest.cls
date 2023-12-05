/*
Class:          NotificationServiceSourceObjectTest
@Author:        Nishant Bansal
@Created Date:  March 03 20213
@Description:  Test Class for NotificationServiceSourceObject
*/
/*
Change History
********************************************************************************************************************************************
ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
********************************************************************************************************************************************
*/
@isTest
public with sharing class NotificationServiceSourceObjectTest {
    @TestSetup
    static void setup(){
        Account acc = IPUE_TestUtils.createAccount(true);
        Opportunity opp = IPUE_TestUtils.createOpportunity(false, acc);
        opp.Trigger_IPU_Notification__c = true;
        insert opp;
        
        sObject sObj;
        
        sObj = new blng__RevenueRecognitionRule__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngRevRecRuleData);
        List<blng__RevenueRecognitionRule__c> lRevRecRule = (List<blng__RevenueRecognitionRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new blng__TaxRule__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngTaxRuleData);
        List<blng__TaxRule__c> lTaxRule = (List<blng__TaxRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new blng__BillingRule__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngBillingRuleData);
        List<blng__BillingRule__c> lBillingRule = (List<blng__BillingRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Product2();
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('SBQQ__AssetConversion__c','One per quote line');
        UtilityTestData.mProduct2Data.put('Offering_Type__c','Cloud Hosted Subscription');
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
        List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        Id pricebookId = Test.getStandardPricebookId();         
        sObj = new Pricebook2(Id = pricebookId,IsActive = True);
        List<Pricebook2> lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        
        sObj = new pricebookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',lPriceBook2[0].Id);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);
        
        List<pricebookEntry> lPriceBookEntry = (List<pricebookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        sObj = new Order();
        UtilityTestData.mOrderData.put('AccountId',acc.id);
        UtilityTestData.mOrderData.put('EffectiveDate',System.today()+'');
        UtilityTestData.mOrderData.put('EndDate',System.today().addYears(1)+'');
        UtilityTestData.mOrderData.put('Status','Draft');
        UtilityTestData.mOrderData.put('Asset_Creation_Status__c','Initiated');
        UtilityTestData.mOrderData.put('Pricebook2Id',lPriceBook2[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mOrderData);
        List<Order> lOrder  =  (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Contract(StartDate = System.Today().addDays(-300));
        UtilityTestData.mContractData.put('AccountId',acc.id);
        UtilityTestData.mContractData.put('StartDate', System.today()+'');
        UtilityTestData.mContractData.put('EndDate',System.today().addYears(1)+'');
        UtilityTestData.mContractData.put('ContractTerm','12');
        UtilityTestData.mContractData.put('BillingStreet','Test Street');
        UtilityTestData.mContractData.put('BillingCity','Test City');
        UtilityTestData.mContractData.put('BillingState','Test State');
        UtilityTestData.mContractData.put('BillingPostalCode','98714-4927');
        UtilityTestData.mContractData.put('BillingCountry','Test Country');
        UtilityTestData.mContractData.put('ShippingStreet','Test Street');
        UtilityTestData.mContractData.put('ShippingCity','Test City');
        UtilityTestData.mContractData.put('ShippingState','Test State');
        UtilityTestData.mContractData.put('ShippingPostalCode','98714-4927');
        UtilityTestData.mContractData.put('ShippingCountry','Test Country');
        UtilityTestData.mContractData.put('SBQQ__Order__c',lOrder[0].Id);
		UtilityTestData.mContractData.put('Amendment_Contracted_Notification__c','true');
        //UtilityTestData.mContractData.put('SBQQ__Quote__c',lQuote[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mContractData);
        List<Contract> lContract  =  (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});
    }
    
    @isTest
    private static void testUpdateOppTriggerToFalse(){
        
        Test.StartTest();
        
        Opportunity testOpp = [SELECT Id, Trigger_IPU_Notification__c FROM Opportunity LIMIT 1];
        
        NotificationServiceSourceObjectUpdate.updateOppTriggerToFalse('Opportunity', testOpp);
        
        Test.StopTest();
        
        Opportunity updatedOpp = [SELECT Id, Trigger_IPU_Notification__c FROM Opportunity LIMIT 1];
        
        System.AssertEquals(false, updatedOpp.Trigger_IPU_Notification__c);
        
    }
    
    @isTest
    private static void testUpdateContractTriggerToFalse(){
        
        Test.StartTest();
        
        Contract cont = [SELECT Id, Amendment_Contracted_Notification__c FROM Contract LIMIT 1];
        NotificationServiceSourceObjectUpdate.updateContractTriggerToFalse('Contract', cont);
        
        Contract updatedCont = [SELECT Id, Amendment_Contracted_Notification__c FROM Contract LIMIT 1];
        System.AssertEquals(false, updatedCont.Amendment_Contracted_Notification__c);
        
        Test.StopTest();
        
    }
    
}