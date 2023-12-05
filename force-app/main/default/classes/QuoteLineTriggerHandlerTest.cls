/*
Class:  QuoteLineTriggerHandlerTest
        @Author:        Anil Solanki
        @Created Date:  14 May 2018
        @Description:   Test Class for QuoteLineTriggerHandler Class.

5/Aug/2019 Anil Solanki 2D Release : Fixed the test class for code coverage issue.
**/
@isTest
private class QuoteLineTriggerHandlerTest {
    
    @testSetup
    static void test_method_one() {
        List<Territory2> lTerritoryNA = (List<Territory2>) UtilityTest.executeQuery('Select Id,Name from Territory2 where Name LIKE \'NA%\'');
        List<Territory2> lTerritoryAPJ = (List<Territory2>) UtilityTest.executeQuery('Select Id from Territory2 where Name LIKE \'AP%\'');
        List<Territory2> lTerritoryEA = (List<Territory2>) UtilityTest.executeQuery('Select Id,Name from Territory2 where Name LIKE \'EA_%\'');
        
        sObject sObj = new Account();
        sObject sObj1 = new Account();
        sObject sObj2 = new Account();
        sObject sObj3 = new Account();
        sObject sObj4 = new Account();
        sObject sObj5 = new Account();
        sObject sObj6 = new Account();
        sObject sObj7 = new Account();
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
               
        UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
        sObj = new Contact();
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
        sObj = new Opportunity(Territory2Id = lTerritoryNA[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);

        sObj1 = new Opportunity(Territory2Id =lTerritoryAPJ[0].Id);
        UtilityTestData.mOpportunityData.put('Territory2Id', lTerritoryAPJ[0].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityData);

        sObj2 = new Opportunity(Territory2Id =lTerritoryEA[0].Id);
        UtilityTestData.mOpportunityData.put('Territory2Id', lTerritoryEA[0].Id);
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mOpportunityData);
         
        sObj3 = new Opportunity();
        UtilityTestData.mOpportunityData.put('Name', 'Test Oppty No Territory');
        UtilityTestData.mOpportunityData.put('CloseDate', System.today().addDays(60)+'');
        UtilityTestData.mOpportunityData.remove('Territory2Id');
        sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mOpportunityData);
        
        sObj4 = new Opportunity();
        UtilityTestData.mOpportunityData.put('Name', 'Test Oppty No Territory1');
        UtilityTestData.mOpportunityData.put('CloseDate', System.today().addDays(60)+'');
        sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mOpportunityData);
           
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3,sObj4});
        
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
    
        sObj = new Product2();
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c', lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c', lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c', lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('Offering_Type__c', 'On-Premise Perpetual License');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);

        sObj1 = new Product2();
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c', lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c', lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c', lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('Offering_Type__c', 'Maintenance');
        UtilityTestData.mProduct2Data.put('Family', '');
        UtilityTestData.mProduct2Data.put('Edition__c', 'Premium Success');
        UtilityTestData.mProduct2Data.put('Forecast_Product__c', 'Support');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProduct2Data);
        List<Product2> lProduct = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});

        sObj1 = new SBQQ__ProductOption__c();
        UtilityTestData.mProductOption.put('blng__BillingRule__c', lProduct[0].Id);
        UtilityTestData.mProductOption.put('blng__RevenueRecognitionRule__c', lProduct[1].Id);
        UtilityTestData.mProductOption.put('SBQQ__Selected__c', 'True');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProductOption);
        List<SBQQ__ProductOption__c> lProductOption = (List<SBQQ__ProductOption__c>) UtilityTest.makeInsert(new List<sObject>{sObj1});        

        //create/update standard Pricebook1
        Id priceBookId  = Test.getStandardPricebookId();
    
        sObj = new Pricebook2(ID = priceBookId, IsActive = True);
        List<Pricebook2> lPriceBook = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        System.assertEquals(lPriceBook.size(), 1);
    
        sObj = new PriceBookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id', lPriceBook[0].Id + '');
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct[0].Id + '');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);
        sObj1 = new PriceBookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id', lPriceBook[0].Id + '');
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct[1].Id + '');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mPriceBookEntryData);        
        List<PriceBookEntry> lPBEntry = (List<PriceBookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
    
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
        UtilityTestData.mSBQuoteData.put('SBQQ__EndDate__c', System.today().addDAys(30) + '');
        //NA Quote 
        sObj = new SBQQ__Quote__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        //NA QUote
        sObj1 = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[0].Id + '');
        UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'false');
        UtilityTestData.mSBQuoteData.remove('SBQQ__EndDate__c');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mSBQuoteData);
        
        //APJ Quote 
        sObj2 = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[1].Id + '');
        UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'true');
        UtilityTestData.mSBQuoteData.put('SBQQ__EndDate__c', System.today().addDAys(30) + '');
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mSBQuoteData);
        
        //APJ Quote
        sObj3 = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[1].Id + '');
        UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'false');
        UtilityTestData.mSBQuoteData.remove('SBQQ__EndDate__c');
        sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mSBQuoteData);
        
        //EA Quote 
        sObj4 = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[2].Id + '');
        UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'true');
        UtilityTestData.mSBQuoteData.put('SBQQ__EndDate__c', System.today().addDAys(30) + '');
        sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mSBQuoteData);
        
        //EA Quote
        sObj5 = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[2].Id + '');
        UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'false');
        UtilityTestData.mSBQuoteData.remove('SBQQ__EndDate__c');
        sObj5 = UtilityTest.putFieldRecord(sObj5, UtilityTestData.mSBQuoteData);
        
        //No Territory Quote 
        sObj6 = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[3].Id + '');
        UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'true');
        UtilityTestData.mSBQuoteData.put('SBQQ__EndDate__c', System.today().addDAys(60) + '');
        UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c', System.today().addDAys(30) + '');
        sObj6 = UtilityTest.putFieldRecord(sObj6, UtilityTestData.mSBQuoteData);
        
        //No Territory Quote
        sObj7 = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[3].Id + '');
        UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'false');
        UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c', System.today().addDAys(30) + '');
        UtilityTestData.mSBQuoteData.remove('SBQQ__EndDate__c');
        sObj7 = UtilityTest.putFieldRecord(sObj7, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3,sObj4,sObj5,sObj6,sObj7});
        
        sObj = new Contract(StartDate = System.Today().addDays(-300));
        UtilityTestData.mContractData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mContractData.put('StartDate', System.Today().addDays(-300)+'');
        UtilityTestData.mContractData.put('Amended_End_Date__c',System.Today().addDays(600)+'');
        UtilityTestData.mContractData.put('EndDate',System.Today().addDays(100)+'');
        UtilityTestData.mContractData.put('ContractTerm','10');
        UtilityTestData.mContractData.put('SBQQ__Quote__c',lQuote[0].id+'');
        
        Test.startTest();
        sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mContractData);
        List<Contract> lContract  =  (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObject sObjSBQQSubscription = new SBQQ__Subscription__c();
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__EndDate__c',System.Today().addDays(900)+'');
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','10');
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');
           
        sObjSBQQSubscription = UtilityTest.putFieldRecord(sObjSBQQSubscription,UtilityTestData.mSBQQSubscriptionData);
        List<SBQQ__Subscription__c > sbbqSubscriptionlst  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObjSBQQSubscription});
        
        Test.stopTest();
    }
    
    //NA test
    @isTest static void test_method_insertNA() {
        List<SBQQ__Quote__c> quoteList= (List<SBQQ__Quote__c>) UtilityTest.executeQuery('Select Id from SBQQ__Quote__c');
        List<Product2> prodList= (List<Product2>) UtilityTest.executeQuery('Select Id from Product2');
        
        Test.startTest();
            sObject sObj = new SBQQ__QuoteLine__c();
            sObject sObj1 = new SBQQ__QuoteLine__c();
            sObject sObj2 = new SBQQ__QuoteLine__c();
            sObject sObj3 = new SBQQ__QuoteLine__c();
            //NA
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', prodList[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c', '12');
            sObj = new SBQQ__QuoteLine__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
            
            //NA
            sObj1 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__EndDate__c', System.Today() + '');
            UtilityTestData.mQuoteLineData.Remove('SBQQ__SubscriptionTerm__c');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
            
            sObj2 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[1].Id);
            UtilityTestData.mQuoteLineData.Remove('SBQQ__EndDate__c');
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.Today() + '');
            //UtilityTestData.mQuoteLineData.Remove('SBQQ__SubscriptionTerm__c');
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);
            
            sObj3 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[1].Id);
            UtilityTestData.mQuoteLineData.Remove('SBQQ__EndDate__c');
            UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c','12');
            UtilityTestData.mQuoteLineData.remove('SBQQ__StartDate__c');
            sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lQuoteLI = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3});
            
            //update 
            UtilityTestData.mQuoteLineData.remove('SBQQ__Quote__c');            
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c', System.Today().addDAys(15) + '');
            sObject sObj4 = new SBQQ__QuoteLine__c(Id = lQuoteLI[0].Id);
            sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mQuoteLineData);
            
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c', System.Today().addDAys(15) + '');
            sObject sObj5 = new SBQQ__QuoteLine__c(Id = lQuoteLI[1].Id);
            sObj5 = UtilityTest.putFieldRecord(sObj5, UtilityTestData.mQuoteLineData);
            
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.Today().addDAys(15) + '');
            sObject sObj6 = new SBQQ__QuoteLine__c(Id = lQuoteLI[2].Id);
            sObj6 = UtilityTest.putFieldRecord(sObj6, UtilityTestData.mQuoteLineData);
            
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c', System.Today().addDAys(15) + '');
            sObject sObj7 = new SBQQ__QuoteLine__c(Id = lQuoteLI[3].Id);
            sObj7 = UtilityTest.putFieldRecord(sObj7, UtilityTestData.mQuoteLineData);
            
            globalApexManager.allowRun('QuoteLineBeforeUpdate');
            List<SBQQ__QuoteLine__c> lQuoteLineUpdate = (List<SBQQ__QuoteLine__c>) UtilityTest.makeUpdate(new List<sObject>{sObj4,sObj5,sObj6, sObj7});
            
        Test.stopTest();
    }
    
    @isTest static void test_Tax_category(){
        List<SBQQ__Quote__c> quoteList= [Select Id from SBQQ__Quote__c];
        List<Product2> prodList= [Select Id,Forecast_Product__c,Edition__c from Product2];

        Test.startTest();
            sObject sObj = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', prodList[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);  
        
            sObject sObj1 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', prodList[1].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);         
            List<SBQQ__QuoteLine__c> lQuoteLI = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
            sObj1 = new SBQQ__QuoteLine__c(Id = lQuoteLI[1].Id,SBQQ__RequiredBy__c = lQuoteLI[0].Id);         
            List<SBQQ__QuoteLine__c> lQuoteLI2 = (List<SBQQ__QuoteLine__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});

            Map<Id,Id> mapQLTaxCategoryUpdate = new Map<Id,Id>();
        	mapQLTaxCategoryUpdate.put(lQuoteLI[1].Id,lQuoteLI[0].Id);
        	Map<Id,SBQQ__QuoteLine__c> mapNew = new Map<Id,SBQQ__QuoteLine__c>();
        	mapNew.put(lQuoteLI[1].Id,lQuoteLI[1]);
        	QuoteLineTriggerHandler.updateTaxCategory(mapQLTaxCategoryUpdate,mapNew);
        	QuoteLineTriggerHandler.handleAfterInsert(mapNew,mapNew);
        Test.stopTest();        
    }    
    @isTest
     static void deleteQuoteLine(){
        List<SBQQ__Quote__c> quoteList= [Select Id from SBQQ__Quote__c];
        List<Product2> prodList= [Select Id,Forecast_Product__c,Edition__c from Product2];
        List<SBQQ__Subscription__c> subsList = [SELECT Id FROM SBQQ__Subscription__c LIMIT 1];
        Test.startTest();
        sObject sObj = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', prodList[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__RenewedSubscription__c', subsList[0].Id); 
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);  
        
        sObject sObj1 = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', prodList[1].Id);
        //UtilityTestData.mQuoteLineData.put('SBQQ__RenewedSubscription__c', subsList[0].Id); 
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);         
        List<SBQQ__QuoteLine__c> lQuoteLI = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        List<SBQQ__QuoteLine__c> lQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        delete lQuoteLine;
        Test.stopTest();
    }
    /*
    //APJ test
    @isTest static void test_method_insertAPJ() {
        List<SBQQ__Quote__c> quoteList= (List<SBQQ__Quote__c>) UtilityTest.executeQuery('Select Id from SBQQ__Quote__c');
        List<Product2> prodList= (List<Product2>) UtilityTest.executeQuery('Select Id from Product2');
        
        Test.startTest();
            sObject sObj = new SBQQ__QuoteLine__c();
            sObject sObj1 = new SBQQ__QuoteLine__c();
            sObject sObj2 = new SBQQ__QuoteLine__c();
            sObject sObj3 = new SBQQ__QuoteLine__c();
            
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[2].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', prodList[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c', '12');
            sObj = new SBQQ__QuoteLine__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
            
            sObj1 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[2].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__EndDate__c', System.Today() + '');
            UtilityTestData.mQuoteLineData.Remove('SBQQ__SubscriptionTerm__c');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
            
            sObj2 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[3].Id);
            UtilityTestData.mQuoteLineData.Remove('SBQQ__EndDate__c');
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.Today() + '');
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);
            
            sObj3 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[3].Id);
            UtilityTestData.mQuoteLineData.Remove('SBQQ__EndDate__c');
            UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c','12');
            UtilityTestData.mQuoteLineData.remove('SBQQ__StartDate__c');
            sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lQuoteLI = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3});
            
            //update 
            UtilityTestData.mQuoteLineData.remove('SBQQ__Quote__c');            
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c', System.Today().addDAys(15) + '');
            sObject sObj4 = new SBQQ__QuoteLine__c(Id = lQuoteLI[0].Id);
            sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mQuoteLineData);
            
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c', System.Today().addDAys(15) + '');
            sObject sObj5 = new SBQQ__QuoteLine__c(Id = lQuoteLI[1].Id);
            sObj5 = UtilityTest.putFieldRecord(sObj5, UtilityTestData.mQuoteLineData);
            
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c', System.Today().addDAys(15) + '');
            sObject sObj6 = new SBQQ__QuoteLine__c(Id = lQuoteLI[2].Id);
            sObj6 = UtilityTest.putFieldRecord(sObj6, UtilityTestData.mQuoteLineData);
            
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c', System.Today().addDAys(15) + '');
            sObject sObj7 = new SBQQ__QuoteLine__c(Id = lQuoteLI[3].Id);
            sObj7 = UtilityTest.putFieldRecord(sObj7, UtilityTestData.mQuoteLineData);
            
            globalApexManager.allowRun('QuoteLineBeforeUpdate');
            List<SBQQ__QuoteLine__c> lQuoteLineUpdate = (List<SBQQ__QuoteLine__c>) UtilityTest.makeUpdate(new List<sObject>{sObj4,sObj5,sObj6, sObj7});
            
        Test.stopTest();
    }
    
    //EA test
    @isTest static void test_method_insertEA() {
        List<SBQQ__Quote__c> quoteList= (List<SBQQ__Quote__c>) UtilityTest.executeQuery('Select Id, territory__c from SBQQ__Quote__c');
        for(SBQQ__Quote__c li:quoteList)
        {
            system.debug('0709>>'+li.territory__c);            
        }
        List<Product2> prodList= (List<Product2>) UtilityTest.executeQuery('Select Id from Product2');
        
        Test.startTest();
            sObject sObj = new SBQQ__QuoteLine__c();
            sObject sObj1 = new SBQQ__QuoteLine__c();
            sObject sObj2 = new SBQQ__QuoteLine__c();
            sObject sObj3 = new SBQQ__QuoteLine__c();
            
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[4].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', prodList[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c','12');
            sObj = new SBQQ__QuoteLine__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
            
            sObj1 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[4].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__EndDate__c', System.Today() + '');
            UtilityTestData.mQuoteLineData.Remove('SBQQ__SubscriptionTerm__c');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
            
            sObj2 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[5].Id);
            UtilityTestData.mQuoteLineData.Remove('SBQQ__EndDate__c');
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.Today() + '');
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);
            
            sObj3 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[5].Id);
            UtilityTestData.mQuoteLineData.Remove('SBQQ__EndDate__c');
            UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c','12');
            UtilityTestData.mQuoteLineData.remove('SBQQ__StartDate__c');
            sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lQuoteLI = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3});
            
            //update 
            UtilityTestData.mQuoteLineData.remove('SBQQ__Quote__c');            
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c', System.Today().addDAys(15) + '');
            sObject sObj4 = new SBQQ__QuoteLine__c(Id = lQuoteLI[0].Id);
            sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mQuoteLineData);
            
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c', System.Today().addDAys(15) + '');
            sObject sObj5 = new SBQQ__QuoteLine__c(Id = lQuoteLI[1].Id);
            sObj5 = UtilityTest.putFieldRecord(sObj5, UtilityTestData.mQuoteLineData);
            
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.Today().addDAys(15) + '');
            sObject sObj6 = new SBQQ__QuoteLine__c(Id = lQuoteLI[2].Id);
            sObj6 = UtilityTest.putFieldRecord(sObj6, UtilityTestData.mQuoteLineData);
            
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.Today().addDAys(15) +  '');
            sObject sObj7 = new SBQQ__QuoteLine__c(Id = lQuoteLI[3].Id);
            sObj7 = UtilityTest.putFieldRecord(sObj7, UtilityTestData.mQuoteLineData);
            
            globalApexManager.allowRun('QuoteLineBeforeUpdate');
            List<SBQQ__QuoteLine__c> lQuoteLineUpdate = (List<SBQQ__QuoteLine__c>) UtilityTest.makeUpdate(new List<sObject>{sObj4,sObj5,sObj6, sObj7});
            
        Test.stopTest();
    }
    
    //No Territory test
    @isTest static void test_method_insertNoTerritory() {
        List<SBQQ__Quote__c> quoteList= (List<SBQQ__Quote__c>) UtilityTest.executeQuery('Select Id from SBQQ__Quote__c');
        List<Product2> prodList= (List<Product2>) UtilityTest.executeQuery('Select Id from Product2');
        
        Test.startTest();
            sObject sObj = new SBQQ__QuoteLine__c();
            sObject sObj1 = new SBQQ__QuoteLine__c();
            sObject sObj2 = new SBQQ__QuoteLine__c();
            sObject sObj3 = new SBQQ__QuoteLine__c();
            
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[6].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', prodList[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c', '12');
            sObj = new SBQQ__QuoteLine__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
            
            sObj1 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[6].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__EndDate__c', System.Today() + '');
            UtilityTestData.mQuoteLineData.Remove('SBQQ__SubscriptionTerm__c');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
            
            sObj2 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[7].Id);
            UtilityTestData.mQuoteLineData.Remove('SBQQ__EndDate__c');
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.Today() + '');
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);
            
            sObj3 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[7].Id);
            UtilityTestData.mQuoteLineData.Remove('SBQQ__EndDate__c');
            UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c','12');
            sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lQuoteLI = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3});
            
            //update 
            UtilityTestData.mQuoteLineData.remove('SBQQ__Quote__c');            
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c', System.Today().addDAys(15) + '');
            sObject sObj4 = new SBQQ__QuoteLine__c(Id = lQuoteLI[0].Id);
            sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mQuoteLineData);
            
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c', System.Today().addDAys(15) + '');
            sObject sObj5 = new SBQQ__QuoteLine__c(Id = lQuoteLI[1].Id);
            sObj5 = UtilityTest.putFieldRecord(sObj5, UtilityTestData.mQuoteLineData);
            
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c', System.Today().addDAys(15) + '');
            sObject sObj6 = new SBQQ__QuoteLine__c(Id = lQuoteLI[2].Id);
            sObj6 = UtilityTest.putFieldRecord(sObj6, UtilityTestData.mQuoteLineData);
            
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c', System.Today().addDAys(15) + '');
            sObject sObj7 = new SBQQ__QuoteLine__c(Id = lQuoteLI[3].Id);
            sObj7 = UtilityTest.putFieldRecord(sObj7, UtilityTestData.mQuoteLineData);
            
            globalApexManager.allowRun('QuoteLineBeforeUpdate');
            List<SBQQ__QuoteLine__c> lQuoteLineUpdate = (List<SBQQ__QuoteLine__c>) UtilityTest.makeUpdate(new List<sObject>{sObj4,sObj5,sObj6, sObj7});
            
        Test.stopTest();
    }

    //APJ test
    @isTest static void test_method_insertAPJ2() {
        List<SBQQ__Quote__c> quoteList= (List<SBQQ__Quote__c>) UtilityTest.executeQuery('Select Id from SBQQ__Quote__c');
        List<Product2> prodList= (List<Product2>) UtilityTest.executeQuery('Select Id from Product2');
        
        Test.startTest();
            sObject sObj = new SBQQ__QuoteLine__c();
            sObject sObj1 = new SBQQ__QuoteLine__c();
            sObject sObj2 = new SBQQ__QuoteLine__c();
            sObject sObj3 = new SBQQ__QuoteLine__c();
            
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[3].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', prodList[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c', '12');
            sObj = new SBQQ__QuoteLine__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
            
            sObj1 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[3].Id);
            //UtilityTestData.mQuoteLineData.put('SBQQ__EndDate__c', System.Today() + '');
            UtilityTestData.mQuoteLineData.Remove('SBQQ__SubscriptionTerm__c');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
            
            sObj2 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[3].Id);
            //UtilityTestData.mQuoteLineData.Remove('SBQQ__EndDate__c');
           // UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.Today() + '');
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);
            
            sObj3 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[3].Id);
            //UtilityTestData.mQuoteLineData.Remove('SBQQ__EndDate__c');
            UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c','12');
            //UtilityTestData.mQuoteLineData.remove('SBQQ__StartDate__c');
            sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lQuoteLI = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3});
            
        quoteList[3].SBQQ__StartDate__c = System.today().addDAys(30);          
        update  quoteList[3];
        
            //update 
            UtilityTestData.mQuoteLineData.remove('SBQQ__Quote__c');            
            UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c','12');
            sObject sObj4 = new SBQQ__QuoteLine__c(Id = lQuoteLI[0].Id);
            sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mQuoteLineData);
            
               UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c','12');
            sObject sObj5 = new SBQQ__QuoteLine__c(Id = lQuoteLI[1].Id);
            sObj5 = UtilityTest.putFieldRecord(sObj5, UtilityTestData.mQuoteLineData);
            
               UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c','12');
            sObject sObj6 = new SBQQ__QuoteLine__c(Id = lQuoteLI[2].Id);
            sObj6 = UtilityTest.putFieldRecord(sObj6, UtilityTestData.mQuoteLineData);
            
               UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c','12');
            sObject sObj7 = new SBQQ__QuoteLine__c(Id = lQuoteLI[3].Id);
            sObj7 = UtilityTest.putFieldRecord(sObj7, UtilityTestData.mQuoteLineData);
            
            globalApexManager.allowRun('QuoteLineBeforeUpdate');
            List<SBQQ__QuoteLine__c> lQuoteLineUpdate = (List<SBQQ__QuoteLine__c>) UtilityTest.makeUpdate(new List<sObject>{sObj4,sObj5,sObj6, sObj7});
            
        Test.stopTest();
    }
    
    Method to test Prior Quantity and Cancel Reason
    @isTest static void test_method_insertPriorQuanityandCancelReason() {
        
        List<SBQQ__Quote__c> quoteList= (List<SBQQ__Quote__c>) UtilityTest.executeQuery('Select Id from SBQQ__Quote__c');
        List<Product2> prodList= (List<Product2>) UtilityTest.executeQuery('Select Id from Product2');
        List<SBQQ__Subscription__c> subList= (List<SBQQ__Subscription__c>) UtilityTest.executeQuery('Select Id,Cancel_Reason__c from SBQQ__Subscription__c');
       
        Test.startTest();
            sObject sObj = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', prodList[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__RenewedSubscription__c',subList[0].Id );
            //UtilityTestData.mQuoteLineData.put('Cancel_Reason__c', 'Upgrade' );
            sObj = new SBQQ__QuoteLine__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lQuoteLI = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //update 
            UtilityTestData.mQuoteLineData.remove('SBQQ__Quote__c');            
            UtilityTestData.mQuoteLineData.put('Cancel_Reason__c', 'Compliance');
            sObject sObj1 = new SBQQ__QuoteLine__c(Id = lQuoteLI[0].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
                
            globalApexManager.allowRun('QuoteLineBeforeUpdate');
                
            List<SBQQ__QuoteLine__c> lQuoteLineUpdate = (List<SBQQ__QuoteLine__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            List<SBQQ__Subscription__c> updatedSubList= (List<SBQQ__Subscription__c>) UtilityTest.executeQuery('Select Id,Cancel_Reason__c from SBQQ__Subscription__c');
            System.assertEquals(updatedSubList[0].Cancel_Reason__c,'Compliance');
        
        Test.stopTest();
    }*/      
}