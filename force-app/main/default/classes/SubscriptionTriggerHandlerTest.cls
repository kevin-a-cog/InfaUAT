/***************************************************************************
*        Name        :        SubscriptionTriggerHandlerTest
*        Author      :        Wasim Akram
*        Date        :        8 January 2020
*        Description :        Test class for Subscription Trigger Handler
*****************************************************************************

Change History
*********************************************************************************************************************************
ModifiedBy          Date        Requested By         JIRA#              Description                                          Tag
*********************************************************************************************************************************
Wasim Akram         8/1/2020    Liz                  SALESRT - 11149    Created methods to test SubscriptionTriggerHandler   <T1>
*********************************************************************************************************************************
*/
@isTest
private class SubscriptionTriggerHandlerTest
{
    
    @testSetup
    static void setupObjectTestData() {
        
        Id competitorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor Account').getRecordTypeId();
        sObject sObj    = new Account();
        UtilityTestData.mAccountData.put('RecordtypeId',competitorRecordTypeId);
        sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mAccountData);
        List<Account> accountlst = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});        
        
        sObject sObjQuote = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('Business_Model__c', 'Standard');
        sObjQuote = UtilityTest.putFieldRecord(sObjQuote,UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> quotelst = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObjQuote}); 
        
        sObj = new Contract(StartDate = System.Today().addDays(-300));
        UtilityTestData.mContractData.put('AccountId',accountlst[0].Id);
        UtilityTestData.mContractData.put('StartDate', System.Today().addDays(-300)+'');
        UtilityTestData.mContractData.put('Amended_End_Date__c',System.Today().addDays(600)+'');
        UtilityTestData.mContractData.put('EndDate',System.Today().addDays(100)+'');
        UtilityTestData.mContractData.put('ContractTerm','10');
        UtilityTestData.mContractData.put('SBQQ__Quote__c',quotelst[0].Id);
        
        sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mContractData);
        List<Contract> contractlst  =  (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});
   
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
        UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Pipeline');
        UtilityTestData.mOpportunityData.put('Probability', '25');
        UtilityTestData.mOpportunityData.put('Substage__c', 'Intro Meeting');
        
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
    
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('Pricing_Business_Model__c','Subscription');
        UtilityTestData.mProduct2Data.put('Forecast_Product__c','Data Quality');
        UtilityTestData.mProduct2Data.put('Delivery_Method__c','Hosted Multi Tenant');
        UtilityTestData.mProduct2Data.put('Tax_Classification__c','C');
        UtilityTestData.mProduct2Data.put('Tax_Product_Type__c','Services');
        sObj = new Product2();        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
        //system.debug('++++++' + sObj);
        
        sObj1 = new Product2();
        UtilityTestData.mProduct2Data.put('Name','Test');
        UtilityTestData.mProduct2Data.put('Pricing_Business_Model__c','Subscription');
        UtilityTestData.mProduct2Data.put('Forecast_Product__c','Data Quality');
        UtilityTestData.mProduct2Data.put('Delivery_Method__c','Hosted Multi Tenant');
        UtilityTestData.mProduct2Data.put('Tax_Classification__c','C');
        UtilityTestData.mProduct2Data.put('Tax_Product_Type__c','Services');
        UtilityTestData.mProduct2Data.put('SBQQ__SubscriptionType__c','One-time');
        UtilityTestData.mProduct2Data.put('Product_Family__c', 'Other');
        UtilityTestData.mProduct2Data.put('Business_Unit__c', 'Professional Services');        
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProduct2Data);
        List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        Id pricebookId = Test.getStandardPricebookId(); 
        
        sObj = new Pricebook2(Id = pricebookId,IsActive = True);
        lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        
        sObj = new pricebookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',lPriceBook2[0].Id);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);
        
        sObj1 = new pricebookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',lPriceBook2[0].Id);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[1].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mPriceBookEntryData);
        
        List<pricebookEntry> lPriceBookEntry = (List<pricebookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
      Test.startTest();
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
        
        sObject sObj2 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.today()+'');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','10');
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj2}); 
        
        sObj1 = new Asset();
        UtilityTestData.mAssetData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mAssetData.put('Name','Test Asset1');
        UtilityTestData.mAssetData.put('Status','Marked for Review');
        UtilityTestData.mAssetData.put('SBQQ__QuoteLine__c',lQuoteLine[0].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAssetData);
        
        sObj2 = new Asset();
        UtilityTestData.mAssetData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mAssetData.put('Name','Test Asset1');
        UtilityTestData.mAssetData.put('Status','Marked for Review');
        UtilityTestData.mAssetData.put('SBQQ__QuoteLine__c',lQuoteLine[0].Id);
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mAssetData);
        
        List<Asset> lAsset = (List<Asset>) UtilityTest.makeInsert(new List<sObject>{sObj1, sObj2});
          Test.stopTest();
    }//END static void setupTestData()

    //Method to Test Insert on Subscription
    @isTest
    static void subscriptionInsertTest(){

        List<Account> lAccount = [Select Id from Account Limit 1];
        List<Contract> lContract = [Select Id from Contract Limit 1];
        List<SBQQ__QuoteLine__c> lQuoteLine = [Select Id from SBQQ__QuoteLine__c Limit 1];
        Test.startTest();
            sObject sObjSBQQSubscription = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__EndDate__c',System.Today().addDays(900)+'');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','10');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lQuoteLine[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');
           
            sObjSBQQSubscription = UtilityTest.putFieldRecord(sObjSBQQSubscription,UtilityTestData.mSBQQSubscriptionData);
            List<SBQQ__Subscription__c > sbbqSubscriptionlst  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObjSBQQSubscription});
           
            List<SBQQ__Subscription__c> lSubScription = [Select Id,SBQQ__SubscriptionEndDate__c from SBQQ__Subscription__c where Id =:sbbqSubscriptionlst[0].Id Limit 1];
            List<Contract> lstContract = [Select Id,Amended_End_Date__c from Contract where Id =:lContract[0].Id Limit 1];
            //System.assertEquals(lSubScription[0].SBQQ__SubscriptionEndDate__c,lstContract[0].Amended_End_Date__c);

            sObjSBQQSubscription = new SBQQ__Subscription__c(Id = sbbqSubscriptionlst[0].Id,SBQQ__OptionLevel__c = null);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.today().addDays(300)+'');
            sObjSBQQSubscription = UtilityTest.putFieldRecord(sObjSBQQSubscription,UtilityTestData.mSBQQSubscriptionData);
            List<SBQQ__Subscription__c > sbbqSubscriptionUpdatelst  =  (List<SBQQ__Subscription__c>) UtilityTest.makeUpdate(new List<sObject>{sObjSBQQSubscription});
            
            sObjSBQQSubscription = new SBQQ__Subscription__c(Id = sbbqSubscriptionlst[0].Id,SBQQ__OptionLevel__c = 1.0);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.today().addDays(3)+'');
            sObjSBQQSubscription = UtilityTest.putFieldRecord(sObjSBQQSubscription,UtilityTestData.mSBQQSubscriptionData);
            sbbqSubscriptionUpdatelst  =  (List<SBQQ__Subscription__c>) UtilityTest.makeUpdate(new List<sObject>{sObjSBQQSubscription});
            
            List<SBQQ__Subscription__c> lSubScription2 = [Select Id,SBQQ__SubscriptionEndDate__c from SBQQ__Subscription__c where Id =:sbbqSubscriptionUpdatelst[0].Id Limit 1];
            List<Contract> lstContract2 = [Select Id,Amended_End_Date__c from Contract where Id =:lContract[0].Id Limit 1];
            //System.assertEquals(lSubScription2[0].SBQQ__SubscriptionEndDate__c,lstContract2[0].Amended_End_Date__c);
    
        Test.stopTest();
    }

    //Method to Test Insert on Subscription
    @isTest
    static void subscriptionInsertTest2(){

        List<Account> lAccount = [Select Id from Account Limit 1];
        List<Contract> lContract = [Select Id,Amended_End_Date__c from Contract Limit 1];
        
        Test.startTest();
            lContract[0].Amended_End_Date__c = null;
            UPSERT lContract;
            sObject sObjSBQQSubscription = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','1000');
           
            sObjSBQQSubscription = UtilityTest.putFieldRecord(sObjSBQQSubscription,UtilityTestData.mSBQQSubscriptionData);
            List<SBQQ__Subscription__c > sbbqSubscriptionlst  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObjSBQQSubscription});
           
            List<SBQQ__Subscription__c> lSubScription = [Select Id,SBQQ__SubscriptionEndDate__c from SBQQ__Subscription__c where Id =:sbbqSubscriptionlst[0].Id Limit 1];
            List<Contract> lstContract = [Select Id,Amended_End_Date__c from Contract where Id =:lContract[0].Id Limit 1];
            //System.assertEquals(lSubScription[0].SBQQ__SubscriptionEndDate__c,lstContract[0].Amended_End_Date__c);
    
        Test.stopTest();
    }

    //Method to Test Insert on Subscription
    @isTest
    static void subscriptionIgnoreInsertAndUpdateTest(){

        List<Account> lAccount = [Select Id from Account Limit 1];
        List<Contract> lContract = [Select Id from Contract Limit 1];
        
        Test.startTest();
            sObject sObjSBQQSubscription = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','10');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');
            sObjSBQQSubscription = UtilityTest.putFieldRecord(sObjSBQQSubscription,UtilityTestData.mSBQQSubscriptionData);
            globalApexManager.avoidRecursion('SubscriptionAfterInsert');
            List<SBQQ__Subscription__c > sbbqSubscriptionlst  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObjSBQQSubscription});
           
            List<SBQQ__Subscription__c> lSubScription = [Select Id,SBQQ__SubscriptionEndDate__c from SBQQ__Subscription__c where Id =:sbbqSubscriptionlst[0].Id Limit 1];
            System.assertEquals(lSubScription.size(),1);

            sObjSBQQSubscription = new SBQQ__Subscription__c(Id = sbbqSubscriptionlst[0].Id,SBQQ__OptionLevel__c = null);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.today().addDays(400)+'');
            sObjSBQQSubscription = UtilityTest.putFieldRecord(sObjSBQQSubscription,UtilityTestData.mSBQQSubscriptionData);
            globalApexManager.avoidRecursion('SubscriptionAfterUpdate');
            List<SBQQ__Subscription__c > sbbqSubscriptionUpdatelst  =  (List<SBQQ__Subscription__c>) UtilityTest.makeUpdate(new List<sObject>{sObjSBQQSubscription});
            
            List<SBQQ__Subscription__c> lSubScription2 = [Select Id,SBQQ__SubscriptionEndDate__c from SBQQ__Subscription__c where Id =:sbbqSubscriptionUpdatelst[0].Id Limit 1];
            System.assertEquals(lSubScription2.size(),1);
            System.assertEquals(lSubScription2[0].SBQQ__SubscriptionEndDate__c,System.today().addDays(400));
        Test.stopTest();
    }

// Added for JIRA 11149 - Methods to Test Product Mix
// <T1>
 
    @isTest
    static void supportProductTest(){        
        List<Account> lAccount = [Select Id from Account Limit 1];
        List<Contract> lContract = [Select Id from Contract Limit 1];
        List<Product2> lProduct = [Select Id from Product2 limit 1];
        List<SBQQ__Quote__c> lQuote = [Select Id from SBQQ__Quote__c Limit 1];
        Test.startTest();
            sObject sObjProduct = lProduct[0];
            UtilityTestData.mProduct2Data.put('Forecast_Product__c', 'Support');
            sObjProduct =  UtilityTest.putFieldRecord(sObjProduct,UtilityTestData.mProduct2Data);
            globalApexManager.avoidRecursion('SubscriptionAfterInsert');
            lProduct  =  (List<Product2>)UtilityTest.makeUpdate(new List<sObject>{sObjProduct});
            
            sObject sObjQuote = lQuote[0];
            UtilityTestData.mSBQuoteData.put('Business_Model__c', 'Standard');
            sObjQuote =  UtilityTest.putFieldRecord(sObjQuote,UtilityTestData.mSBQuoteData);
            globalApexManager.avoidRecursion('SubscriptionAfterInsert');
            lQuote  =  (List<SBQQ__Quote__c>)UtilityTest.makeUpdate(new List<sObject>{sObjQuote});
        
            sObject sObjContract = lContract[0];
            UtilityTestData.mContractData.put('Business_Model__c','Standard');
            UtilityTestData.mContractData.put('SBQQ__Quote__c',lQuote[0].Id);
            sObjContract =  UtilityTest.putFieldRecord(sObjContract,UtilityTestData.mContractData);
            globalApexManager.avoidRecursion('SubscriptionAfterInsert');
            lContract  =  (List<Contract>)UtilityTest.makeUpdate(new List<sObject>{sObjContract});
            
            sObject sObjSBQQSubscription = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lProduct[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','10');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');
            sObjSBQQSubscription = UtilityTest.putFieldRecord(sObjSBQQSubscription,UtilityTestData.mSBQQSubscriptionData);
            globalApexManager.avoidRecursion('SubscriptionAfterInsert');
            List<SBQQ__Subscription__c > sbbqSubscriptionlst  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObjSBQQSubscription});
               
        List<Contract> lstContract = [Select Id, One_Time__c, DaaS__c,Support__c, Renewal_Type__c,Business_Model__c, SBQQ__RenewalOwner__r.Name from Contract where Id =:lContract[0].Id Limit 1];
        System.assertEquals(true,lstContract[0].Support__c);
        Test.stopTest();
    }
  
    @isTest
    static void oneTimeProductTest(){        
        List<Account> lAccount = [Select Id from Account Limit 1];
        List<Contract> lContract = [Select Id from Contract Limit 1];
        List<Product2> lProduct = [Select Id from Product2];
        List<SBQQ__Quote__c> lQuote = [Select Id from SBQQ__Quote__c Limit 1];
        Test.startTest();
            /*sObject sObjProduct = lProduct[0];
            UtilityTestData.mProduct2Data.put('SBQQ__SubscriptionType__c', 'One-Time');
            sObjProduct =  UtilityTest.putFieldRecord(sObjProduct,UtilityTestData.mProduct2Data);
            globalApexManager.avoidRecursion('SubscriptionAfterInsert');
         if (Schema.sObjectType.Product2.isUpdateable()){
            lProduct  =  (List<Product2>)UtilityTest.makeUpdate(new List<sObject>{sObjProduct});
         }*/
            sObject sObjQuote = lQuote[0];
            UtilityTestData.mSBQuoteData.put('Business_Model__c', 'Standard');
            sObjQuote =  UtilityTest.putFieldRecord(sObjQuote,UtilityTestData.mSBQuoteData);
            globalApexManager.avoidRecursion('SubscriptionAfterInsert');
            lQuote  =  (List<SBQQ__Quote__c>)UtilityTest.makeUpdate(new List<sObject>{sObjQuote});
        
            sObject sObjContract = lContract[0];
            UtilityTestData.mContractData.put('Business_Model__c','Standard');
            UtilityTestData.mContractData.put('SBQQ__Quote__c',lQuote[0].Id);
            sObjContract =  UtilityTest.putFieldRecord(sObjContract,UtilityTestData.mContractData);
            globalApexManager.avoidRecursion('SubscriptionAfterInsert');
            lContract  =  (List<Contract>)UtilityTest.makeUpdate(new List<sObject>{sObjContract});
            
            sObject sObjSBQQSubscription = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lProduct[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','10');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');
            sObjSBQQSubscription = UtilityTest.putFieldRecord(sObjSBQQSubscription,UtilityTestData.mSBQQSubscriptionData);
            globalApexManager.avoidRecursion('SubscriptionAfterInsert');
            List<SBQQ__Subscription__c > sbbqSubscriptionlst  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObjSBQQSubscription});
                
            List<Contract> lstContract = [Select Id,One_Time__c, DaaS__c,Support__c, Renewal_Type__c,Business_Model__c, SBQQ__RenewalOwner__r.Name from Contract where Id =:lContract[0].Id Limit 1];         
            System.assertEquals(false,lstContract[0].One_Time__c);
        Test.stopTest();
    }

     @isTest
    static void daaSProductTest(){        
        List<Account> lAccount = [Select Id from Account Limit 1];
        List<Contract> lContract = [Select Id from Contract Limit 1];
        List<Product2> lProduct = [Select Id from Product2 limit 1];
        List<SBQQ__Quote__c> lQuote = [Select Id from SBQQ__Quote__c Limit 1];
        Test.startTest();
            sObject sObjProduct = lProduct[0];
            UtilityTestData.mProduct2Data.put('Product_Family__c', 'DQ');
            UtilityTestData.mProduct2Data.put('Business_Unit__c', 'Address Doctor');
            sObjProduct =  UtilityTest.putFieldRecord(sObjProduct,UtilityTestData.mProduct2Data);
            globalApexManager.avoidRecursion('SubscriptionAfterInsert');
            lProduct  =  (List<Product2>)UtilityTest.makeUpdate(new List<sObject>{sObjProduct});
            
            sObject sObjQuote = lQuote[0];
            UtilityTestData.mSBQuoteData.put('Business_Model__c', 'Standard');
            sObjQuote =  UtilityTest.putFieldRecord(sObjQuote,UtilityTestData.mSBQuoteData);
            globalApexManager.avoidRecursion('SubscriptionAfterInsert');
            lQuote  =  (List<SBQQ__Quote__c>)UtilityTest.makeUpdate(new List<sObject>{sObjQuote});
        
            sObject sObjContract = lContract[0];
            UtilityTestData.mContractData.put('Business_Model__c','Standard');
            UtilityTestData.mContractData.put('SBQQ__Quote__c',lQuote[0].Id);
            sObjContract =  UtilityTest.putFieldRecord(sObjContract,UtilityTestData.mContractData);
            globalApexManager.avoidRecursion('SubscriptionAfterInsert');
            lContract  =  (List<Contract>)UtilityTest.makeUpdate(new List<sObject>{sObjContract});
            
            sObject sObjSBQQSubscription = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lProduct[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','10');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');
            sObjSBQQSubscription = UtilityTest.putFieldRecord(sObjSBQQSubscription,UtilityTestData.mSBQQSubscriptionData);
            globalApexManager.avoidRecursion('SubscriptionAfterInsert');
            List<SBQQ__Subscription__c > sbbqSubscriptionlst  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObjSBQQSubscription});
                
            List<Contract> lstContract = [Select Id,One_Time__c, DaaS__c,Support__c, Renewal_Type__c,Business_Model__c, SBQQ__RenewalOwner__r.Name from Contract where Id =:lContract[0].Id Limit 1];
            System.assertEquals(true,lstContract[0].DaaS__c);
        Test.stopTest();
    }
    
    //No Subscription Lines
    @isTest
    static void noSubscriptionLinestest()
    {
        List<Account> lAccount = [Select Id from Account Limit 1];
        List<Contract> lContract = [Select Id from Contract Limit 1];
        List<Product2> lProduct = [Select Id from Product2];
        List<SBQQ__Quote__c> lQuote = [Select Id from SBQQ__Quote__c Limit 1];
        Test.startTest();
            //One Time Product
            /*sObject sObjProduct = lProduct[0];
            UtilityTestData.mProduct2Data.put('SBQQ__SubscriptionType__c', 'One-Time');
            sObjProduct =  UtilityTest.putFieldRecord(sObjProduct,UtilityTestData.mProduct2Data);
            globalApexManager.avoidRecursion('SubscriptionAfterInsert');
         if (Schema.sObjectType.Product2.isUpdateable()){
            lProduct  =  (List<Product2>)UtilityTest.makeUpdate(new List<sObject>{sObjProduct});
         }*/
            sObject sObjQuote = lQuote[0];
            UtilityTestData.mSBQuoteData.put('Business_Model__c', 'Standard');
            sObjQuote =  UtilityTest.putFieldRecord(sObjQuote,UtilityTestData.mSBQuoteData);
            globalApexManager.avoidRecursion('SubscriptionAfterInsert');
            lQuote  =  (List<SBQQ__Quote__c>)UtilityTest.makeUpdate(new List<sObject>{sObjQuote});
            //Update Contract with Standard Business Model
            sObject sObjContract = lContract[0];
            UtilityTestData.mContractData.put('Business_Model__c','Standard');
            UtilityTestData.mContractData.put('SBQQ__Quote__c',lQuote[0].Id);
            sObjContract =  UtilityTest.putFieldRecord(sObjContract,UtilityTestData.mContractData);
            globalApexManager.avoidRecursion('SubscriptionAfterInsert');
            lContract  =  (List<Contract>)UtilityTest.makeUpdate(new List<sObject>{sObjContract});
            
            // Insert Subscription Line for Product 1 - One Time Product
            sObject sObjSBQQSubscription = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lProduct[1].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','10');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');
            sObjSBQQSubscription = UtilityTest.putFieldRecord(sObjSBQQSubscription,UtilityTestData.mSBQQSubscriptionData);
            globalApexManager.avoidRecursion('SubscriptionAfterInsert');
            List<SBQQ__Subscription__c > sbbqSubscriptionlst  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObjSBQQSubscription});
              
            // Support Product
            sObject sObj1 = new Product2();
            UtilityTestData.mProduct2Data.put('SBQQ__SubscriptionType__c', 'Renewable');
            UtilityTestData.mProduct2Data.put('Family','Support');
            UtilityTestData.mProduct2Data.put('Forecast_Product__c', 'Support');
            UtilityTestData.mProduct2Data.put('Offering_ID__c', 'TEST-OFFERING_ID');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProduct2Data);
            lProduct = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj1});
            lProduct = [Select Id from Product2 WHERE Forecast_Product__c = 'Support' limit 1];
            
            // Insert Subscription Line for Product 2 - Support Product
            sObject sObjSBQQSubscription2 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lProduct[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','10');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');
            sObjSBQQSubscription2 = UtilityTest.putFieldRecord(sObjSBQQSubscription2,UtilityTestData.mSBQQSubscriptionData);
            globalApexManager.avoidRecursion('SubscriptionAfterInsert');
            sbbqSubscriptionlst  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObjSBQQSubscription2});
              
            List<Contract> lstContract = [Select Id, DaaS__c, Renewal_Type__c,Business_Model__c, SBQQ__RenewalOwner__r.Name from Contract where Id =:lContract[0].Id Limit 1];
            // Delete all Subscription Lines
            List<SBQQ__Subscription__c> lstSubscriptionDeleteAll = [Select Id,SBQQ__Product__r.SBQQ__SubscriptionType__c, SBQQ__Product__r.Forecast_Product__c 
                                                           FROM SBQQ__Subscription__c]; 
            delete lstSubscriptionDeleteAll;
            List<Contract> lstContractDelete = [Select Id, Renewal_Type__c,Business_Model__c, SBQQ__RenewalOwner__r.Name,Support__c, DaaS__c, One_Time__c from Contract where Id =:lContract[0].Id Limit 1];
            System.assertEquals(false,lstContractDelete[0].DaaS__c);
            System.assertEquals(false,lstContractDelete[0].One_Time__c);
            System.assertEquals(false,lstContractDelete[0].Support__c);
            //Added for code coverage
            undelete lstSubscriptionDeleteAll[0];
            undelete lstSubscriptionDeleteAll[1];
            delete lstSubscriptionDeleteAll[0];
            delete lstSubscriptionDeleteAll[1];
        Test.stopTest();
    }    
// <T1> 
}