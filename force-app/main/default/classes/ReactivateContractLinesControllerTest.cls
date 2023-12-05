/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
* 
*  @Author:        Sumitkumar Mittal
*  @Created Date:  05/08/2018
*  @Description:   Test class for ReactivateContractLinesController with the updated test framework
* Change History
***********************************************************************************************************************
* ModifiedBy          Date        Requested By        Description                                                               Tag
* Wasim Akram       1/14/2020       Liz             Fixed errors that occurred due to Process Builder check for Quote           <T1>
Business Model for Contract update/insert
******************************************************************
*/
@isTest
private class ReactivateContractLinesControllerTest
{
    
    @testSetup
    static void setupObjectTestData() {
        
        Id competitorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor Account').getRecordTypeId();
        sObject sObj    = new Account();
        UtilityTestData.mAccountData.put('RecordtypeId',competitorRecordTypeId);
        sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mAccountData);
        List<Account> accountlst = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
               
        List<Territory2> lTerritoryNA = (List<Territory2>) UtilityTest.executeQuery('Select Id from Territory2 where Name LIKE \'%NA%\'');
        List<Territory2> lTerritoryAPJ = (List<Territory2>) UtilityTest.executeQuery('Select Id from Territory2 where Name LIKE \'%AP%\'');
        List<Territory2> lTerritoryEA = (List<Territory2>) UtilityTest.executeQuery('Select Id from Territory2 where Name LIKE \'%EA%\'');
        
        SObject sObj1 = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Account 1');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountData);
        
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj1});
        
        UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
        sObj = new Contact();
        UtilityTestData.mContactData.put('Phone', '123456677');
        UtilityTestData.mContactData.put('Email', 'abc@test.com');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        // Set all the required fields and dynamic ids in Map
        sObj = new blng__LegalEntity__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalEntityData);
        List<blng__LegalEntity__c> lLegalEntity = (List<blng__LegalEntity__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        // Insert new Opportunity
        String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;            
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
        UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
        UtilityTestData.mOpportunityData.put('Type', 'Direct');
        UtilityTestData.mOpportunityData.put('StageName', 'Validate');
        UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Commit');
        UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
        UtilityTestData.mOpportunityData.put('Split_Percentage__c', '50');     
        UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c', 'Primary');     
        
        sObj1 = new Opportunity();
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityData);
        
        
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj1});
        
        
        sObj = new Pricebook2();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPricebook2Data);
        List<Pricebook2> lPricebook2 = (List<Pricebook2>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new blng__BillingRule__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngBillingRuleData);
        List<blng__BillingRule__c> lBillingRule = (List<blng__BillingRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new blng__RevenueRecognitionRule__c();
        sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mblngRevRecRuleData);
        List<blng__RevenueRecognitionRule__c> lRevRecRule = (List<blng__RevenueRecognitionRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});    
        System.assertEquals(lRevRecRule.size(),1);
        
        sObj = new blng__TaxRule__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngTaxRuleData);
        List<blng__TaxRule__c> lTaxRule = (List<blng__TaxRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        System.assertEquals(lTaxRule.size(),1);
        
        sObj1 = new Product2();
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c', lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c', lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c', lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('Family','DaaS Subscription');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProduct2Data);
        
        
        List<Product2> lProduct = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj1});
        System.debug('Test Product Inserted' + lProduct);
        //create/update standard Pricebook1
        Id priceBookId  = Test.getStandardPricebookId();
        
        sObj = new Pricebook2(ID = priceBookId, IsActive = True);
        List<Pricebook2> lPriceBook = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        System.assertEquals(lPriceBook.size(), 1);
        
        sObj1 = new PriceBookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id', lPriceBook[0].Id);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct[0].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mPriceBookEntryData);
        
        
        List<PriceBookEntry> lPBEntry = (List<PriceBookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj1});
        
        // Insert new Quote
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[0].Id + '');
        UtilityTestData.mSBQuoteData.put('SBQQ__PriceBook__c', lPricebook2[0].Id + '');
        UtilityTestData.mSBQuoteData.put('SBQQ__PricebookId__c', lPricebook2[0].Id + '');
        UtilityTestData.mSBQuoteData.put('Legal_Entity__c', lLegalEntity[0].Id + '');
        UtilityTestData.mSBQuoteData.put('SoldToAccount__c', lAccount[0].Id + '');
        UtilityTestData.mSBQuoteData.put('ShiptToAccount__c', lAccount[0].Id + '');
        UtilityTestData.mSBQuoteData.put('BillToAccount__c', lAccount[0].Id + '');
        UtilityTestData.mSBQuoteData.put('EndUserAccount__c', lAccount[0].Id + '');
        UtilityTestData.mSBQuoteData.put('SoldToContact__c', lContact[0].Id + '');
        UtilityTestData.mSBQuoteData.put('EndUserContact__c', lContact[0].Id + '');
        UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'true');
        UtilityTestData.mSBQuoteData.put('SBQQ__Type__c', 'Renewal');
        
        sObj1 = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c', lAccount[0].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mSBQuoteData);
        
        globalApexManager.avoidRecursion('QuoteBeforeInsert');
        globalApexManager.avoidRecursion('QuoteAfterInsert');
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj1});
        
        Test.startTest();
        
         //<T1>
        //create a Quote
        sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c',accountlst[0].Id);
        UtilityTestData.mSBQuoteData.put('Shipping_Preference__c','Email');
        UtilityTestData.mSBQuoteData.put('BillToAccount__c',accountlst[0].Id);
        UtilityTestData.mSBQuoteData.put('ShiptToAccount__c',accountlst[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Type__c','Quote');
        UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c',System.Today() + '');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        //<T1>    
        sObj = new Contract(StartDate = System.Today().addDays(-300));
        UtilityTestData.mContractData.put('AccountId',accountlst[0].Id);
        UtilityTestData.mContractData.put('StartDate', System.Today().addDays(-300)+'');
        UtilityTestData.mContractData.put('Amended_End_Date__c',System.Today().addDays(600)+'');
        UtilityTestData.mContractData.put('EndDate',System.Today().addDays(100)+'');
        UtilityTestData.mContractData.put('ContractTerm','10');
        //  UtilityTestData.mContractData.put('SBQQ__RenewalQuoted__c','True');
        //<T1>
        UtilityTestData.mContractData.put('SBQQ__Quote__c',lSBQuote[0].Id);
        //<T1>
        sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mContractData);
        List<Contract> contractlst  =  (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});
                        
        sObject sObj2 = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.today()+'');
        UtilityTestData.mQuoteLineData.put('Purchase_Order_PO_Number__c','1');
        UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','1');
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);
        
        globalApexManager.avoidRecursion('QuoteLineBeforeInsert');
        globalApexManager.avoidRecursion('QuoteLineAfterInsert');
        globalApexManager.avoidRecursion('QuoteLineBeforeUpdate');
        globalApexManager.avoidRecursion('QuoteLineAfterUpdate');
        
        List<SBQQ__QuoteLine__c> lQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj2}); 
        
        
        sObject sObjSBQQSubscription = new SBQQ__Subscription__c();
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',contractlst[0].ID);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__EndDate__c',System.Today().addDays(900)+'');
        UtilityTestData.mSBQQSubscriptionData.put('Original_Annual_Recurring_Revenue__c','100');
        UtilityTestData.mSBQQSubscriptionData.put('Current_ACV__c','100');
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','1');
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lQuoteLine[0].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');
        
        sObjSBQQSubscription = UtilityTest.putFieldRecord(sObjSBQQSubscription,UtilityTestData.mSBQQSubscriptionData);
        List<SBQQ__Subscription__c > sbbqSubscriptionlst  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObjSBQQSubscription});
        Test.stopTest();
        
        
    }//END static void setupTestData()
    
    //Method to Test reactivate contract lines success case
    @isTest
    static void reactivateContractlinesSuccessTest(){
        Test.startTest();
        List<Contract> lContract = [Select Id from Contract Limit 1];
        String queryString = 'id';
        
        //Get the fieldset from the controller
        List<ReactivateContractLinesController.FieldSetMember> fsnames = ReactivateContractLinesController.getFields('SBQQ__Subscription__c','ReleaseLinesFieldSet');
        
        list<SBQQ__Subscription__c > rtnSubsription = ReactivateContractLinesController.fetchParentSubscriptionProducts(lContract[0].id, queryString);
        Test.stopTest();
    }
    
    
    //Method to Test reactivate contract lines Fail case
    @isTest
    static void reactivateContractlinesFailTest(){
        
        Test.startTest();
        List<Contract> lContract = [Select Id from Contract Limit 1];
        String queryString = 'id';
        
        
        lContract[0].SBQQ__RenewalQuoted__c = False;   
        List<Contract> updatedContract = (List<Contract>) UtilityTest.makeUpdate(new List<sObject>{lContract[0]});
        
        list<SBQQ__Subscription__c > rtnSubsription = ReactivateContractLinesController.fetchParentSubscriptionProducts(updatedContract[0].id, queryString);
        system.debug('returnValue ::::'+rtnSubsription);
        //system.assertEquals(returnValue,'Fails');
        Test.stopTest();
    }
    
    //Method to call release contract lines
    //Method to Test reactivate contract lines Pass case
    @isTest
    static void releaseContractLinesTest(){
        Test.startTest();
        List<Contract> lContract = [Select Id from Contract Limit 1];
        List<SBQQ__Subscription__c> lSubscription = [Select Id from SBQQ__Subscription__c Limit 1];
        List<String> lsub = new List<String>();
        lSub.add(lSubscription[0].Id);        
        
        lSubscription[0].SBQQ__RootId__c = lSubscription[0].Id;   
        List<SBQQ__Subscription__c> updatedSub = (List<SBQQ__Subscription__c>) UtilityTest.makeUpdate(new List<sObject>{lSubscription[0]});
        String returnString = ReactivateContractLinesController.transferRecords(lsub,lContract[0].Id);

        Test.stopTest();
    }
    
    //Method to call release contract lines
    //Method to Test reactivate contract lines Fail case
    @isTest
    static void releaseContractLinesFailTest(){
        Test.startTest();
        List<Contract> lContract = [Select Id from Contract Limit 1];
        List<SBQQ__Subscription__c> lSubscription = [Select Id from SBQQ__Subscription__c Limit 1];
        List<String> lsub = new List<String>();
        lSub.add(lSubscription[0].Id);
        
        String returnString = ReactivateContractLinesController.transferRecords(lsub,lContract[0].Id);

        Test.stopTest();
    }
    
}