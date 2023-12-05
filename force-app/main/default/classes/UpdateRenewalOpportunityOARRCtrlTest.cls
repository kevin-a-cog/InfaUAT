@isTest(seeAllData=false)
public with sharing class UpdateRenewalOpportunityOARRCtrlTest {
    
    @testSetup
    static void setupObjectTestData() {
        
        sObject sObj = new blng__BillingRule__c();
        
        sObj = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        Id pricebookId = Test.getStandardPricebookId();  
        
        sObj = new Opportunity();
        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Type','Direct');
        UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
        UtilityTestData.mOpportunityData.put('StageName','Identify');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        lOpportunity[0].Pricebook2Id = priceBookId;
        update lOpportunity[0];
        
        
        sObj = new Order();
        UtilityTestData.mOrderData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOrderData.put('EffectiveDate',System.today()+'');
        UtilityTestData.mOrderData.put('EndDate',System.today().addYears(1)+'');
        UtilityTestData.mOrderData.put('Status','Draft');
        UtilityTestData.mOrderData.put('Asset_Creation_Status__c','Initiated');
        UtilityTestData.mOrderData.put('Pricebook2Id',pricebookId);
        sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mOrderData);
        List<Order> lOrder  =  (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Contract(StartDate = System.Today().addDays(-300));
        UtilityTestData.mContractData.put('AccountId',lAccount[0].Id);
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
        sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mContractData);
        List<Contract> lContract  =  (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});
    }
    
    @isTest
    static void testRecalculateOARR(){
        
        Contract cont = [Select Id, SBQQ__RenewalForecast__c From Contract Limit 1];
        Test.startTest();
        cont.SBQQ__RenewalForecast__c = true;
        update cont;
        
        Contract updatedContract = [SELECT Id, SBQQ__RenewalOpportunity__c from Contract WHERE Id =: cont.Id ];
        
        UpdateRenewalOpportunityOARRController.recalculateOARR(updatedContract.SBQQ__RenewalOpportunity__c);
        
        system.assertNotEquals(updatedContract.SBQQ__RenewalOpportunity__c, null);            
        test.stopTest();
    }
    
    
}