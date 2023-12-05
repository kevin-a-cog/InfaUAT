/*
Class:  QuoteLineTriggerHandlerTest
        @Author:        Anil Solanki
        @Created Date:  15 Oct 2018
        @Description:   Test Class for LegalAgreementHandlerTest Class. 
*/
@isTest
private class LegalAgreementHandlerTest {
    
    @testSetup
    static void test_method_one() {
        List<Territory2> lTerritoryNA = (List<Territory2>) UtilityTest.executeQuery('Select Id from Territory2 where Name LIKE \'%NA%\'');
        List<Territory2> lTerritoryAPJ = (List<Territory2>) UtilityTest.executeQuery('Select Id from Territory2 where Name LIKE \'%AP%\'');
        List<Territory2> lTerritoryEA = (List<Territory2>) UtilityTest.executeQuery('Select Id from Territory2 where Name LIKE \'%EA%\'');
        
        sObject sObj = new Account();
        sObject sObj1 = new Account();
        sObject sObj2 = new Account();
        sObject sObj3 = new Account();
        sObject sObj4 = new Account();
        sObject sObj5 = new Account();
        sObject sObj6 = new Account();
        sObject sObj7 = new Account();
        sObject sObj8 = new Account();
        sObject sObj9 = new Account();
        sObject sObj10 = new Account();
        sObject sObj11 = new Account();
        sObject sObj12 = new Account();
        sObject sObj13 = new Account();
        sObject sObj14 = new Account();
        sObject sObj15 = new Account();
        sObject sObj16 = new Account();
        sObject sObj17 = new Account();
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        
        sObj1 = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Account 1');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountData);

        sObj2 = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Account 2');
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mAccountData);

        sObj3 = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Account 3');
        sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mAccountData);

        sObj4 = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Account 4');
        sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mAccountData);

        sObj5 = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Account 5');
        sObj5 = UtilityTest.putFieldRecord(sObj5, UtilityTestData.mAccountData);

        sObj6 = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Account 6');
        sObj6 = UtilityTest.putFieldRecord(sObj6, UtilityTestData.mAccountData);

        sObj7 = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Account 7');
        sObj7 = UtilityTest.putFieldRecord(sObj7, UtilityTestData.mAccountData);

        sObj8 = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Account 8');
        sObj8 = UtilityTest.putFieldRecord(sObj8, UtilityTestData.mAccountData);
        
        sObj9 = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Account 9');
        sObj9 = UtilityTest.putFieldRecord(sObj9, UtilityTestData.mAccountData);
        
        sObj10 = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Account 10');
        sObj10 = UtilityTest.putFieldRecord(sObj10, UtilityTestData.mAccountData);
        
        sObj11 = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Account 11');
        sObj11 = UtilityTest.putFieldRecord(sObj11, UtilityTestData.mAccountData);
        
        sObj12 = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Account 12');
        sObj12 = UtilityTest.putFieldRecord(sObj12, UtilityTestData.mAccountData);
        
        sObj13 = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Account 13');
        sObj13 = UtilityTest.putFieldRecord(sObj13, UtilityTestData.mAccountData);
        
        sObj14 = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Account 14');
        sObj14 = UtilityTest.putFieldRecord(sObj14, UtilityTestData.mAccountData);
        
        sObj15 = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Account 15');
        sObj15 = UtilityTest.putFieldRecord(sObj15, UtilityTestData.mAccountData);
        
        sObj16 = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Account 16');
        sObj16 = UtilityTest.putFieldRecord(sObj16, UtilityTestData.mAccountData);
        
        sObj17 = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Account 17');
        sObj17 = UtilityTest.putFieldRecord(sObj17, UtilityTestData.mAccountData);
        
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3,sObj4,sObj5,sObj6,sObj7,sObj8,sObj9,sObj10,sObj11,sObj12,sObj13,sObj14,sObj15,sObj16,sObj17});
       
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
        sObj = new Opportunity();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        
        System.debug('Test Oppty 1' + sObj);
        sObj1 = new Opportunity();
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[1].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityData);
        
        System.debug('Test Oppty 2' + sObj1);
        
        sObj2 = new Opportunity();
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[2].Id);
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mOpportunityData);

        
        System.debug('Test Oppty 3' + sObj2);
        sObj3 = new Opportunity();
        UtilityTestData.mOpportunityData.put('Name', 'Test Oppty No Territory');
        UtilityTestData.mOpportunityData.put('CloseDate', System.today().addDays(60)+'');
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[3].Id);
        sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mOpportunityData);

        sObj4 = new Opportunity();
        UtilityTestData.mOpportunityData.put('Name', 'Test Oppty No Territory1');
        UtilityTestData.mOpportunityData.put('CloseDate', System.today().addDays(60)+'');
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[4].Id);  
        sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mOpportunityData);
        
        sObj5 = new Opportunity();
        UtilityTestData.mOpportunityData.put('Name', 'Test Oppty No Territory5');
        UtilityTestData.mOpportunityData.put('CloseDate', System.today().addDays(60)+'');
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[5].Id);  
        sObj5 = UtilityTest.putFieldRecord(sObj5, UtilityTestData.mOpportunityData);
        
        System.debug('Test Oppty 5' + sObj5);
        
        
        sObj6 = new Opportunity();
        UtilityTestData.mOpportunityData.put('Name', 'Test Oppty No Territory6');
        UtilityTestData.mOpportunityData.put('CloseDate', System.today().addDays(60)+'');
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[6].Id);  
        sObj6 = UtilityTest.putFieldRecord(sObj6, UtilityTestData.mOpportunityData);
        
        System.debug('Test Oppty 6' + sObj6);
        
        sObj7 = new Opportunity();
        UtilityTestData.mOpportunityData.put('Name', 'Test Oppty No Territory7');
        UtilityTestData.mOpportunityData.put('CloseDate', System.today().addDays(60)+'');
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[7].Id);  
        sObj7 = UtilityTest.putFieldRecord(sObj7, UtilityTestData.mOpportunityData);
        
        sObj8 = new Opportunity();
        UtilityTestData.mOpportunityData.put('Name', 'Test Oppty No Territory8');
        UtilityTestData.mOpportunityData.put('CloseDate', System.today().addDays(60)+'');
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[8].Id);  
        sObj8 = UtilityTest.putFieldRecord(sObj8, UtilityTestData.mOpportunityData);
        
        sObj9 = new Opportunity();
        UtilityTestData.mOpportunityData.put('Name', 'Test Oppty No Territory9');
        UtilityTestData.mOpportunityData.put('CloseDate', System.today().addDays(60)+'');
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[9].Id);  
        sObj9 = UtilityTest.putFieldRecord(sObj9, UtilityTestData.mOpportunityData);
        
        sObj10 = new Opportunity();
        UtilityTestData.mOpportunityData.put('Name', 'Test Oppty No Territory10');
        UtilityTestData.mOpportunityData.put('CloseDate', System.today().addDays(60)+'');
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[10].Id);  
        UtilityTestData.mOpportunityData.put('StageName', 'Validate');
        sObj10 = UtilityTest.putFieldRecord(sObj10, UtilityTestData.mOpportunityData);
        
        sObj11 = new Opportunity();
        UtilityTestData.mOpportunityData.put('Name', 'Test Oppty No Territory1');
        UtilityTestData.mOpportunityData.put('CloseDate', System.today().addDays(60)+'');
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[11].Id);  
        UtilityTestData.mOpportunityData.put('StageName', 'Validate');
        sObj11 = UtilityTest.putFieldRecord(sObj11, UtilityTestData.mOpportunityData);
        
        sObj12 = new Opportunity();
        UtilityTestData.mOpportunityData.put('Name', 'Test Oppty No Territory12');
        UtilityTestData.mOpportunityData.put('CloseDate', System.today().addDays(60)+'');
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[12].Id);  
        UtilityTestData.mOpportunityData.put('StageName', 'Validate');
        sObj12 = UtilityTest.putFieldRecord(sObj12, UtilityTestData.mOpportunityData);
        
        sObj13 = new Opportunity();
        UtilityTestData.mOpportunityData.put('Name', 'Test Oppty No Territory13');
        UtilityTestData.mOpportunityData.put('CloseDate', System.today().addDays(60)+'');
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[13].Id);  
        UtilityTestData.mOpportunityData.put('StageName', 'Validate');
        sObj13 = UtilityTest.putFieldRecord(sObj13, UtilityTestData.mOpportunityData);
        
        sObj14 = new Opportunity();
        UtilityTestData.mOpportunityData.put('Name', 'Test Oppty No Territory14');
        UtilityTestData.mOpportunityData.put('CloseDate', System.today().addDays(60)+'');
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[14].Id);  
        UtilityTestData.mOpportunityData.put('StageName', 'Validate');
        sObj14 = UtilityTest.putFieldRecord(sObj14, UtilityTestData.mOpportunityData);
        
        sObj15 = new Opportunity();
        UtilityTestData.mOpportunityData.put('Name', 'Test Oppty No Territory15');
        UtilityTestData.mOpportunityData.put('CloseDate', System.today().addDays(60)+'');
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[15].Id);  
        UtilityTestData.mOpportunityData.put('StageName', 'Validate');
        sObj15 = UtilityTest.putFieldRecord(sObj15, UtilityTestData.mOpportunityData);
        
        sObj16 = new Opportunity();
        UtilityTestData.mOpportunityData.put('Name', 'Test Oppty No Territory16');
        UtilityTestData.mOpportunityData.put('CloseDate', System.today().addDays(60)+'');
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[16].Id);  
        UtilityTestData.mOpportunityData.put('StageName', 'Validate');
        sObj16 = UtilityTest.putFieldRecord(sObj16, UtilityTestData.mOpportunityData);
        
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3,sObj4,sObj5,sObj6,sObj7,sObj8,sObj9,sObj10,sObj11,sObj12,sObj13,sObj14,sObj15,sObj16});
        Test.startTest();
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
        UtilityTestData.mProduct2Data.put('Family','Cloud Subscription');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
        
        sObj1 = new Product2();
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c', lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c', lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c', lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('Family','DaaS Subscription');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProduct2Data);

        sObj2 = new Product2();
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c', lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c', lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c', lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('Family','On-Premise Subscription');
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mProduct2Data);

        sObj3 = new Product2();
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c', lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c', lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c', lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('Family','On-Premise Perpetual');
        sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mProduct2Data);
        
        List<Product2> lProduct = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3});
        System.assertEquals(lProduct.size(), 4);
        System.debug('Test Product Inserted' + lProduct);
        //create/update standard Pricebook1
        Id priceBookId  = Test.getStandardPricebookId();
    
        sObj = new Pricebook2(ID = priceBookId, IsActive = True);
        List<Pricebook2> lPriceBook = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        System.assertEquals(lPriceBook.size(), 1);
    
        sObj = new PriceBookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id', lPriceBook[0].Id);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);
        
        sObj1 = new PriceBookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id', lPriceBook[0].Id);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct[1].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mPriceBookEntryData);
        
        sObj2 = new PriceBookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id', lPriceBook[0].Id);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct[2].Id);
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mPriceBookEntryData);
        
        sObj3 = new PriceBookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id', lPriceBook[0].Id);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct[3].Id);
        sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mPriceBookEntryData);
        
        List<PriceBookEntry> lPBEntry = (List<PriceBookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3});
        System.assertEquals(lPBEntry.size(),4);
    
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
         
        sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c', lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);

        sObj1 = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[1].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c', lAccount[1].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mSBQuoteData);

        sObj2 = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunity[2].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c', lAccount[2].Id);
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mSBQuoteData);

        sObj3 = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[3].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c', lAccount[3].Id);
        sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mSBQuoteData);

        sObj4 = new SBQQ__Quote__c(SBQQ__StartDate__c = null);
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[4].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c', lAccount[4].Id);
        sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mSBQuoteData);

        sObj5 = new SBQQ__Quote__c(SBQQ__EndDate__c = System.today().addDays(30));
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[5].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c', lAccount[5].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'False');
        sObj5 = UtilityTest.putFieldRecord(sObj5, UtilityTestData.mSBQuoteData);

        
        sObj6 = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[6].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c', lAccount[6].Id);
        sObj6 = UtilityTest.putFieldRecord(sObj6, UtilityTestData.mSBQuoteData);

        sObj7 = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[7].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c', lAccount[7].Id);
        sObj7 = UtilityTest.putFieldRecord(sObj7, UtilityTestData.mSBQuoteData);
        
        sObj8 = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[8].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c', lAccount[8].Id);
        sObj8 = UtilityTest.putFieldRecord(sObj8, UtilityTestData.mSBQuoteData);
        
        sObj9 = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[9].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c', lAccount[9].Id);
        sObj9 = UtilityTest.putFieldRecord(sObj9, UtilityTestData.mSBQuoteData);
        
        sObj10 = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[10].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c', lAccount[10].Id);
        sObj10 = UtilityTest.putFieldRecord(sObj10, UtilityTestData.mSBQuoteData);
        
        sObj11 = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[11].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c', lAccount[11].Id);
        sObj11 = UtilityTest.putFieldRecord(sObj11, UtilityTestData.mSBQuoteData);
        
        sObj12 = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[12].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c', lAccount[12].Id);
        sObj12 = UtilityTest.putFieldRecord(sObj12, UtilityTestData.mSBQuoteData);
        
        sObj13 = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[13].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c', lAccount[13].Id);
        sObj13 = UtilityTest.putFieldRecord(sObj13, UtilityTestData.mSBQuoteData);
        
        sObj14 = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[14].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c', lAccount[14].Id);
        sObj14 = UtilityTest.putFieldRecord(sObj14, UtilityTestData.mSBQuoteData);
        
        sObj15 = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[15].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c', lAccount[15].Id);
        sObj15 = UtilityTest.putFieldRecord(sObj15, UtilityTestData.mSBQuoteData);
        
        sObj16 = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[16].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c', lAccount[16].Id);
        sObj16 = UtilityTest.putFieldRecord(sObj16, UtilityTestData.mSBQuoteData);
        
        globalApexManager.avoidRecursion('QuoteBeforeInsert');
        globalApexManager.avoidRecursion('QuoteAfterInsert');
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3,sObj4,sObj5,sObj6,sObj7,sObj8,sObj9,sObj10,sObj11,sObj12,sObj13,sObj14,sObj15,sObj16});
        Test.stopTest();
            
}
    
    //SVP=no,TP=Yes
    @isTest static void test_method_insert(){
        List<Account> account = (List<Account>) UtilityTest.executeQuery('SELECT Id FROM Account LIMIT 18');
        List<Contact> contact = (List<Contact>) UtilityTest.executeQuery('SELECT Id FROM Contact LIMIT 1');
        
        Test.startTest();
            
            sObject sobjLA = new Legal_Agreement__c();
            UtilityTestData.mLegalAgreement.put('Contract_Group__c', 'Sales - NA');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c', 'Yes');
            UtilityTestData.mLegalAgreement.put('Account__c', account[17].Id);
            UtilityTestData.mLegalAgreement.put('Customer_Contact__c',contact[0].Id);
            sobjLA = UtilityTest.putFieldRecord(sObjLA, UtilityTestData.mLegalAgreement);
            List<Legal_Agreement__c> lLegalAgreementInsert = (List<Legal_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sobjLA});
        
            sObject sObj = new Legal_Agreement__c(Id = lLegalAgreementInsert[0].id);
            UtilityTestData.mLegalAgreement.put('Account__c', account[17].Id);
            UtilityTestData.mLegalAgreement.put('SVP_Approved__c','');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c', 'Yes');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalAgreement);
            
            globalApexManager.allowRun('LegalAgreementBeforeUpdate');
            List<Legal_Agreement__c> lLegalAgreementUpdate = (List<Legal_Agreement__c>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            System.assertEquals(lLegalAgreementUpdate.size(), 1);
            System.assertEquals(lLegalAgreementUpdate[0].Use_Third_Party_Paper__c, 'Yes');
        Test.stopTest();

    }
    //SVP= yes,Tp=YES , LC=YES
    @isTest static void legalAgreemtnwithNoQuote1insert(){
        List<Account> account = (List<Account>) UtilityTest.executeQuery('SELECT Id FROM Account LIMIT 18');
        List<Contact> contact = (List<Contact>) UtilityTest.executeQuery('SELECT Id FROM Contact LIMIT 1');
        
        Test.startTest();
            sObject sObj = new Legal_Agreement__c();
            UtilityTestData.mLegalAgreement.put('Contract_Group__c', 'Sales - NA');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c', 'Yes');
            UtilityTestData.mLegalAgreement.put('Account__c',account[17].Id);
            UtilityTestData.mLegalAgreement.put('Customer_Contact__c', contact[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalAgreement);
            
            List<Legal_Agreement__c> lLegalAgreementInsert = (List<Legal_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObject sObj1 = new Legal_Agreement__c(Id = lLegalAgreementInsert[0].id);
            UtilityTestData.mLegalAgreement.put('SVP_Approved__c','Yes');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c','Yes');
            UtilityTestData.mLegalAgreement.put('Legal_Counsel_Approved__c','Yes');
            
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mLegalAgreement);
            
            globalApexManager.allowRun('LegalAgreementBeforeUpdate');
            List<Legal_Agreement__c> lLegalAgreementUpdate = (List<Legal_Agreement__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            System.assertEquals(lLegalAgreementUpdate.size(), 1);
            System.assertEquals(lLegalAgreementUpdate[0].Use_Third_Party_Paper__c, 'Yes');
        Test.stopTest();

    }
    //SVP=Yes,TP= YES, DS= YES
    @isTest static void legalAgreemtnwithNoQuote11insert(){
        List<Account> account = (List<Account>) UtilityTest.executeQuery('SELECT Id FROM Account LIMIT 18');
        List<Contact> contact = (List<Contact>) UtilityTest.executeQuery('SELECT Id FROM Contact LIMIT 1');
         
        Test.startTest();
            sObject sObj = new Legal_Agreement__c();
            UtilityTestData.mLegalAgreement.put('Contract_Group__c', 'Sales - NA');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c', 'Yes');
            UtilityTestData.mLegalAgreement.put('Account__c',account[17].Id);
            UtilityTestData.mLegalAgreement.put('Customer_Contact__c', contact[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalAgreement);
            
            List<Legal_Agreement__c> lLegalAgreementInsert = (List<Legal_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObject sObj1 = new Legal_Agreement__c(Id = lLegalAgreementInsert[0].id);
            UtilityTestData.mLegalAgreement.put('SVP_Approved__c','Yes');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c','Yes');
            UtilityTestData.mLegalAgreement.put('Deal_Strategy_Approved__c','Yes');
            
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mLegalAgreement);
            
            globalApexManager.allowRun('LegalAgreementBeforeUpdate');
            List<Legal_Agreement__c> lLegalAgreementUpdate = (List<Legal_Agreement__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            System.assertEquals(lLegalAgreementUpdate.size(), 1);
            System.assertEquals(lLegalAgreementUpdate[0].Use_Third_Party_Paper__c, 'Yes');
        Test.stopTest();

    }
    //TP= Yes
    @isTest static void legalAgreemtnwithNoQuote31insert(){
        List<Account> account = (List<Account>) UtilityTest.executeQuery('SELECT Id FROM Account LIMIT 18');
        List<Contact> contact = (List<Contact>) UtilityTest.executeQuery('SELECT Id FROM Contact LIMIT 1');
        
        Test.startTest();
            sObject sObj = new Legal_Agreement__c();
            UtilityTestData.mLegalAgreement.put('Contract_Group__c', 'Sales - NA');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c', 'No');
            UtilityTestData.mLegalAgreement.put('Account__c',account[17].Id);
            UtilityTestData.mLegalAgreement.put('Customer_Contact__c', contact[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalAgreement);
            
            List<Legal_Agreement__c> lLegalAgreementInsert = (List<Legal_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObject sObj1 = new Legal_Agreement__c(Id = lLegalAgreementInsert[0].id);
            UtilityTestData.mLegalAgreement.put('Account__c',account[17].Id);
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c','Yes');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mLegalAgreement);
            
            globalApexManager.allowRun('LegalAgreementBeforeUpdate');
            List<Legal_Agreement__c> lLegalAgreementUpdate = (List<Legal_Agreement__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            System.assertEquals(lLegalAgreementUpdate.size(), 1);
            System.assertEquals(lLegalAgreementUpdate[0].Use_Third_Party_Paper__c, 'Yes');
        Test.stopTest();

    }
    
    @isTest static void legalAgreemtnwithNoQuote41insert(){
        List<Account> account = (List<Account>) UtilityTest.executeQuery('SELECT Id FROM Account LIMIT 18');
        List<Contact> contact = (List<Contact>) UtilityTest.executeQuery('SELECT Id FROM Contact LIMIT 1');
       
        Test.startTest();
            sObject sObj = new Legal_Agreement__c();
            UtilityTestData.mLegalAgreement.put('Contract_Group__c', 'Sales - NA');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c', 'Yes');
            UtilityTestData.mLegalAgreement.put('Account__c',account[17].Id);
            UtilityTestData.mLegalAgreement.put('Customer_Contact__c', contact[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalAgreement);
            
            List<Legal_Agreement__c> lLegalAgreementInsert = (List<Legal_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObject sObj1 = new Legal_Agreement__c(Id = lLegalAgreementInsert[0].id);
            UtilityTestData.mLegalAgreement.put('SVP_Approved__c','Yes');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c','No');
            
            
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mLegalAgreement);
            
            globalApexManager.allowRun('LegalAgreementBeforeUpdate');
            List<Legal_Agreement__c> lLegalAgreementUpdate = (List<Legal_Agreement__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            System.assertEquals(lLegalAgreementUpdate.size(), 1);
            System.assertEquals(lLegalAgreementUpdate[0].Use_Third_Party_Paper__c, 'No');
        Test.stopTest();

    }
    
    @isTest static void legalAgreemtnwithNoQuote51insert(){
        List<Account> account = (List<Account>) UtilityTest.executeQuery('SELECT Id FROM Account LIMIT 18');
        List<Contact> contact = (List<Contact>) UtilityTest.executeQuery('SELECT Id FROM Contact LIMIT 1');
        
        Test.startTest();
            sObject sObj = new Legal_Agreement__c();
            UtilityTestData.mLegalAgreement.put('Contract_Group__c', 'Sales - NA');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c', 'Yes');
            UtilityTestData.mLegalAgreement.put('Account__c',account[17].Id);
            UtilityTestData.mLegalAgreement.put('Customer_Contact__c', contact[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalAgreement);
            
            List<Legal_Agreement__c> lLegalAgreementInsert = (List<Legal_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObject sObj1 = new Legal_Agreement__c(Id = lLegalAgreementInsert[0].id);
            UtilityTestData.mLegalAgreement.put('SVP_Approved__c','Yes');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c','No');
            UtilityTestData.mLegalAgreement.put('Legal_Counsel_Approved__c','Yes');
            
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mLegalAgreement);
            
            globalApexManager.allowRun('LegalAgreementBeforeUpdate');
            List<Legal_Agreement__c> lLegalAgreementUpdate = (List<Legal_Agreement__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            System.assertEquals(lLegalAgreementUpdate.size(), 1);
            System.assertEquals(lLegalAgreementUpdate[0].Use_Third_Party_Paper__c, 'No');
        Test.stopTest();

    }
    
    
    @isTest static void legalAgreemtnwithNoQuote61insert(){
        List<Account> account = (List<Account>) UtilityTest.executeQuery('SELECT Id FROM Account LIMIT 18');
        List<Contact> contact = (List<Contact>) UtilityTest.executeQuery('SELECT Id FROM Contact LIMIT 1');
        
        Test.startTest();
            sObject sObj = new Legal_Agreement__c();
            UtilityTestData.mLegalAgreement.put('Contract_Group__c', 'Sales - NA');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c', 'Yes');
            UtilityTestData.mLegalAgreement.put('Account__c',account[17].Id);
            UtilityTestData.mLegalAgreement.put('Customer_Contact__c', contact[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalAgreement);
            
            List<Legal_Agreement__c> lLegalAgreementInsert = (List<Legal_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObject sObj1 = new Legal_Agreement__c(Id = lLegalAgreementInsert[0].id);
            UtilityTestData.mLegalAgreement.put('SVP_Approved__c','Yes');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c','No');
            UtilityTestData.mLegalAgreement.put('Deal_Strategy_Approved__c','Yes');
            
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mLegalAgreement);
            
            globalApexManager.allowRun('LegalAgreementBeforeUpdate');
            List<Legal_Agreement__c> lLegalAgreementUpdate = (List<Legal_Agreement__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            System.assertEquals(lLegalAgreementUpdate.size(), 1);
            System.assertEquals(lLegalAgreementUpdate[0].Use_Third_Party_Paper__c, 'No');
        Test.stopTest();

    }
    
    @isTest static void legalAgreemtnwithNoQuote71insert(){
        List<Account> account = (List<Account>) UtilityTest.executeQuery('SELECT Id FROM Account LIMIT 18');
        List<Contact> contact = (List<Contact>) UtilityTest.executeQuery('SELECT Id FROM Contact LIMIT 1');
        
        Test.startTest();
            sObject sObj = new Legal_Agreement__c();
            UtilityTestData.mLegalAgreement.put('Contract_Group__c', 'Sales - NA');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c', 'Yes');
            UtilityTestData.mLegalAgreement.put('Account__c',account[17].Id);
            UtilityTestData.mLegalAgreement.put('Customer_Contact__c', contact[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalAgreement);
            
            List<Legal_Agreement__c> lLegalAgreementInsert = (List<Legal_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObject sObj1 = new Legal_Agreement__c(Id = lLegalAgreementInsert[0].id);
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c','No');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mLegalAgreement);
            
            globalApexManager.allowRun('LegalAgreementBeforeUpdate');
            List<Legal_Agreement__c> lLegalAgreementUpdate = (List<Legal_Agreement__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            System.assertEquals(lLegalAgreementUpdate.size(), 1);
            System.assertEquals(lLegalAgreementUpdate[0].Use_Third_Party_Paper__c, 'No');
        Test.stopTest();

    }


    //Not a cloud or DaaS , <1M
    @isTest static void legalAgreemtnNotCLoudorDaas1insert(){
        List<Account> account = (List<Account>) UtilityTest.executeQuery('SELECT Id FROM Account LIMIT 18');
        List<Contact> contact = (List<Contact>) UtilityTest.executeQuery('SELECT Id FROM Contact LIMIT 1');
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.executeQuery('SELECT Id FROM SBQQ__Quote__c Limit 18');
        List<Product2> lProduct = (List<Product2>) UtilityTest.executeQuery('Select Id from Product2 Limit 4');
        
        Test.startTest();
        
            //Not cloud or Dass, < 1M
            sObject sObj2 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[2].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.today()+'');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','10');
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj2}); 
        
        
            sObject sObj = new Legal_Agreement__c();
            UtilityTestData.mLegalAgreement.put('Contract_Group__c', 'Sales - NA');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c', 'Yes');
            UtilityTestData.mLegalAgreement.put('Account__c',account[0].Id);
            UtilityTestData.mLegalAgreement.put('Customer_Contact__c', contact[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalAgreement);
            
            List<Legal_Agreement__c> lLegalAgreementInsert = (List<Legal_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObject sObj1 = new Legal_Agreement__c(Id = lLegalAgreementInsert[0].id);
            UtilityTestData.mLegalAgreement.put('SVP_Approved__c','Yes');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c','Yes');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mLegalAgreement);
            
            globalApexManager.allowRun('LegalAgreementBeforeUpdate');
            List<Legal_Agreement__c> lLegalAgreementUpdate = (List<Legal_Agreement__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            System.assertEquals(lLegalAgreementUpdate.size(), 1);
            System.assertEquals(lLegalAgreementUpdate[0].Use_Third_Party_Paper__c, 'Yes');
        Test.stopTest();

    }
    
    //Cloud or DaaS  + On Prem Sub, <1M
    @isTest static void legalAgreemtnCLoudorDaasAndOnPremSubInsert(){
        List<Account> account = (List<Account>) UtilityTest.executeQuery('SELECT Id FROM Account LIMIT 18');
        List<Contact> contact = (List<Contact>) UtilityTest.executeQuery('SELECT Id FROM Contact LIMIT 1');
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.executeQuery('SELECT Id FROM SBQQ__Quote__c Limit 18');
        List<Product2> lProduct = (List<Product2>) UtilityTest.executeQuery('Select Id,Family from Product2 Limit 4');
        
        Test.startTest();
            
            //Cloud or DaaS + On Prem, < 1M
            sObject sObj3 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuote[1].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.today()+'');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','1500');
            sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mQuoteLineData);
            
            //cloud or Dass + On Prem, < 1M
            sObject sObj4 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuote[1].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[2].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.today()+'');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','500');
            sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj3,sObj4}); 
            
            List<SBQQ__Quote__c> lQuoteTest = (List<SBQQ__Quote__c>) UtilityTest.executeQuery('SELECT Id ,Name, SBQQ__Opportunity2__r.AccountId,SBQQ__Account__c,SBQQ__NetAmount__c FROM SBQQ__Quote__c Limit 20');
            System.debug('Quote Value' + lQuoteTest);
            
            sObject sObj = new Legal_Agreement__c();
            UtilityTestData.mLegalAgreement.put('Contract_Group__c', 'Sales - NA');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c', 'No');
            UtilityTestData.mLegalAgreement.put('Account__c',account[1].Id);
            UtilityTestData.mLegalAgreement.put('Customer_Contact__c', contact[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalAgreement);
            
            List<Legal_Agreement__c> lLegalAgreementInsert = (List<Legal_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObject sObj1 = new Legal_Agreement__c(Id = lLegalAgreementInsert[0].id);
            UtilityTestData.mLegalAgreement.put('Account__c',account[1].Id);
            UtilityTestData.mLegalAgreement.put('SVP_Approved__c','No');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c','Yes');
        	UtilityTestData.mLegalAgreement.put('Quote_Number__c',lQuoteTest[1].Name);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mLegalAgreement);
            
            globalApexManager.allowRun('LegalAgreementBeforeUpdate');
            List<Legal_Agreement__c> lLegalAgreementUpdate = (List<Legal_Agreement__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            System.assertEquals(lLegalAgreementUpdate.size(), 1);
            System.assertEquals(lLegalAgreementUpdate[0].Use_Third_Party_Paper__c, 'Yes');
            
        Test.stopTest();

    }
    
    //On Prem Sub OR on Prem P, >1M
    @isTest static void legalAgreemtnNotOnPremSubInsert(){
        List<Account> account = (List<Account>) UtilityTest.executeQuery('SELECT Id FROM Account LIMIT 18');
        List<Contact> contact = (List<Contact>) UtilityTest.executeQuery('SELECT Id FROM Contact LIMIT 1');
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.executeQuery('SELECT Id FROM SBQQ__Quote__c Limit 18');
        List<Product2> lProduct = (List<Product2>) UtilityTest.executeQuery('Select Id from Product2 Limit 4');
        
        Test.startTest();
        
            //On Prem S or P, > 1M
            sObject sObj5 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuote[2].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[2].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.today()+'');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','2010');
            sObj5 = UtilityTest.putFieldRecord(sObj5, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj5}); 
            
            
            sObject sObj = new Legal_Agreement__c();
            UtilityTestData.mLegalAgreement.put('Contract_Group__c', 'Sales - NA');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c', 'Yes');
            UtilityTestData.mLegalAgreement.put('Account__c',account[2].Id);
            UtilityTestData.mLegalAgreement.put('Customer_Contact__c', contact[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalAgreement);
            
            List<Legal_Agreement__c> lLegalAgreementInsert = (List<Legal_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObject sObj1 = new Legal_Agreement__c(Id = lLegalAgreementInsert[0].id);
            UtilityTestData.mLegalAgreement.put('SVP_Approved__c','No');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c','Yes');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mLegalAgreement);
            
            globalApexManager.allowRun('LegalAgreementBeforeUpdate');
            List<Legal_Agreement__c> lLegalAgreementUpdate = (List<Legal_Agreement__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            System.assertEquals(lLegalAgreementUpdate.size(), 1);
            System.assertEquals(lLegalAgreementUpdate[0].Use_Third_Party_Paper__c, 'Yes');
        Test.stopTest();

    }

//Cloud Or DaaS, >1M
    @isTest static void legalAgreemtCloudOrDaaSInsert(){
        List<Account> account = (List<Account>) UtilityTest.executeQuery('SELECT Id FROM Account LIMIT 18');
        List<Contact> contact = (List<Contact>) UtilityTest.executeQuery('SELECT Id FROM Contact LIMIT 1');
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.executeQuery('SELECT Id FROM SBQQ__Quote__c Limit 18');
        List<Product2> lProduct = (List<Product2>) UtilityTest.executeQuery('Select Id from Product2 Limit 4');
        
        
        Test.startTest();
            
            //Cloud or DaaS, > 1M
            sObject sObj6 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuote[3].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.today()+'');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','2010');
            sObj6 = UtilityTest.putFieldRecord(sObj6, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj6}); 
            
            
            sObject sObj = new Legal_Agreement__c();
            UtilityTestData.mLegalAgreement.put('Contract_Group__c', 'Sales - NA');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c', 'Yes');
            UtilityTestData.mLegalAgreement.put('Account__c',account[3].Id);
            UtilityTestData.mLegalAgreement.put('Customer_Contact__c', contact[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalAgreement);
            
            List<Legal_Agreement__c> lLegalAgreementInsert = (List<Legal_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObject sObj1 = new Legal_Agreement__c(Id = lLegalAgreementInsert[0].id);
            UtilityTestData.mLegalAgreement.put('Account__c',account[3].Id);
            UtilityTestData.mLegalAgreement.put('SVP_Approved__c','No');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c','Yes');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mLegalAgreement);
            
            globalApexManager.allowRun('LegalAgreementBeforeUpdate');
            List<Legal_Agreement__c> lLegalAgreementUpdate = (List<Legal_Agreement__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            System.assertEquals(lLegalAgreementUpdate.size(), 1);
            System.assertEquals(lLegalAgreementUpdate[0].Use_Third_Party_Paper__c, 'Yes');
        Test.stopTest();

    }   

//On Prem P, <150k
    @isTest static void legalAgreemtOnPremPInsert(){
        List<Account> account = (List<Account>) UtilityTest.executeQuery('SELECT Id FROM Account LIMIT 18');
        List<Contact> contact = (List<Contact>) UtilityTest.executeQuery('SELECT Id FROM Contact LIMIT 1');
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.executeQuery('SELECT Id FROM SBQQ__Quote__c Limit 18');
        List<Product2> lProduct = (List<Product2>) UtilityTest.executeQuery('Select Id from Product2 Limit 4');
        
        
        Test.startTest();
        
            //On Prem, < 150
            sObject sObj7 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuote[4].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[3].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.today()+'');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','290');
            sObj7 = UtilityTest.putFieldRecord(sObj7, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj7}); 
            
            sObject sObj = new Legal_Agreement__c();
            UtilityTestData.mLegalAgreement.put('Contract_Group__c', 'Sales - NA');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c', 'Yes');
            UtilityTestData.mLegalAgreement.put('Account__c',account[4].Id);
            UtilityTestData.mLegalAgreement.put('Customer_Contact__c', contact[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalAgreement);
            
            List<Legal_Agreement__c> lLegalAgreementInsert = (List<Legal_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObject sObj1 = new Legal_Agreement__c(Id = lLegalAgreementInsert[0].id);
            UtilityTestData.mLegalAgreement.put('SVP_Approved__c','No');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c','No');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mLegalAgreement);
            
            globalApexManager.allowRun('LegalAgreementBeforeUpdate');
            List<Legal_Agreement__c> lLegalAgreementUpdate = (List<Legal_Agreement__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            System.assertEquals(lLegalAgreementUpdate.size(), 1);
            System.assertEquals(lLegalAgreementUpdate[0].Use_Third_Party_Paper__c, 'No');
        Test.stopTest();

    }
    
 //On Prem P, >150k
    @isTest static void legalAgreemtOnPremP1Insert(){
        List<Account> account = (List<Account>) UtilityTest.executeQuery('SELECT Id FROM Account LIMIT 18');
        List<Contact> contact = (List<Contact>) UtilityTest.executeQuery('SELECT Id FROM Contact LIMIT 1');
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.executeQuery('SELECT Id FROM SBQQ__Quote__c Limit 18');
        List<Product2> lProduct = (List<Product2>) UtilityTest.executeQuery('Select Id from Product2 Limit 4');
        
        
        Test.startTest();
            
            //On Prem, > 150
            sObject sObj8 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuote[5].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[3].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.today()+'');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','350');
            sObj8 = UtilityTest.putFieldRecord(sObj8, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj8}); 
            
            
            sObject sObj = new Legal_Agreement__c();
            UtilityTestData.mLegalAgreement.put('Contract_Group__c', 'Sales - NA');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c', 'Yes');
            UtilityTestData.mLegalAgreement.put('Account__c',account[5].Id);
            UtilityTestData.mLegalAgreement.put('Customer_Contact__c', contact[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalAgreement);
            
            List<Legal_Agreement__c> lLegalAgreementInsert = (List<Legal_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObject sObj1 = new Legal_Agreement__c(Id = lLegalAgreementInsert[0].id);
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c','No');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mLegalAgreement);
            
            globalApexManager.allowRun('LegalAgreementBeforeUpdate');
            List<Legal_Agreement__c> lLegalAgreementUpdate = (List<Legal_Agreement__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            System.assertEquals(lLegalAgreementUpdate.size(), 1);
            System.assertEquals(lLegalAgreementUpdate[0].Use_Third_Party_Paper__c, 'No');
        Test.stopTest();

    }
    
//Cloud Or On Prem s, <75k
    @isTest static void legalAgreemtCloudOrOnPremSInsert(){
        List<Account> account = (List<Account>) UtilityTest.executeQuery('SELECT Id FROM Account LIMIT 18');
        List<Contact> contact = (List<Contact>) UtilityTest.executeQuery('SELECT Id FROM Contact LIMIT 1');
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.executeQuery('SELECT Id FROM SBQQ__Quote__c Limit 18');
        List<Product2> lProduct = (List<Product2>) UtilityTest.executeQuery('Select Id from Product2 Limit 4');
        
        
        Test.startTest();
            
            //On Prem S or CLoud, > 75
            sObject sObj9 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuote[6].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[2].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.today()+'');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','110');
            sObj9 = UtilityTest.putFieldRecord(sObj9, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj9}); 
            
            sObject sObj = new Legal_Agreement__c();
            UtilityTestData.mLegalAgreement.put('Contract_Group__c', 'Sales - NA');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c', 'Yes');
            UtilityTestData.mLegalAgreement.put('Account__c',account[6].Id);
            UtilityTestData.mLegalAgreement.put('Customer_Contact__c', contact[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalAgreement);
            
            List<Legal_Agreement__c> lLegalAgreementInsert = (List<Legal_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObject sObj1 = new Legal_Agreement__c(Id = lLegalAgreementInsert[0].id);
            UtilityTestData.mLegalAgreement.put('SVP_Approved__c','No');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c','No');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mLegalAgreement);
            
            globalApexManager.allowRun('LegalAgreementBeforeUpdate');
            List<Legal_Agreement__c> lLegalAgreementUpdate = (List<Legal_Agreement__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            System.assertEquals(lLegalAgreementUpdate.size(), 1);
            System.assertEquals(lLegalAgreementUpdate[0].Use_Third_Party_Paper__c, 'No');
        Test.stopTest();

    }

    //Cloud Or On Prem s, >75k
    @isTest static void legalAgreemtCloudOoOnPremS1Insert(){
        List<Account> account = (List<Account>) UtilityTest.executeQuery('SELECT Id FROM Account Limit 18');
        List<Contact> contact = (List<Contact>) UtilityTest.executeQuery('SELECT Id FROM Contact Limit 1');
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.executeQuery('SELECT Id FROM SBQQ__Quote__c Limit 18');
        List<Product2> lProduct = (List<Product2>) UtilityTest.executeQuery('Select Id from Product2 Limit 4');
        
        
        Test.startTest();
            
            //On Prem S Or CLoud, > 75
            sObject sObj10 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuote[7].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[2].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.today()+'');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','200');
            sObj10 = UtilityTest.putFieldRecord(sObj10, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj10}); 
            
            
            sObject sObj = new Legal_Agreement__c();
            UtilityTestData.mLegalAgreement.put('Contract_Group__c', 'Sales - NA');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c', 'Yes');
            UtilityTestData.mLegalAgreement.put('Account__c',account[7].Id);
            UtilityTestData.mLegalAgreement.put('Customer_Contact__c', contact[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalAgreement);
            
            List<Legal_Agreement__c> lLegalAgreementInsert = (List<Legal_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObject sObj1 = new Legal_Agreement__c(Id = lLegalAgreementInsert[0].id);
            //UtilityTestData.mLegalAgreement.put('SVP_Approved__c','No');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c','No');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mLegalAgreement);
            
            globalApexManager.allowRun('LegalAgreementBeforeUpdate');
            List<Legal_Agreement__c> lLegalAgreementUpdate = (List<Legal_Agreement__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            System.assertEquals(lLegalAgreementUpdate.size(), 1);
            System.assertEquals(lLegalAgreementUpdate[0].Use_Third_Party_Paper__c, 'No');
        Test.stopTest();
    }
    
//Daas, <25k
    @isTest static void legalAgreementDaasInsert(){
        List<Account> account = (List<Account>) UtilityTest.executeQuery('SELECT Id FROM Account Limit 18');
        List<Contact> contact = (List<Contact>) UtilityTest.executeQuery('SELECT Id FROM Contact Limit 1');
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.executeQuery('SELECT Id FROM SBQQ__Quote__c Limit 18');
        List<Product2> lProduct = (List<Product2>) UtilityTest.executeQuery('Select Id from Product2 Limit 4');
        
        
        Test.startTest();
            
            //On Prem S Or CLoud, > 75
            sObject sObj10 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuote[8].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[1].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.today()+'');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','10');
            sObj10 = UtilityTest.putFieldRecord(sObj10, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj10}); 
            
            
            sObject sObj = new Legal_Agreement__c();
            UtilityTestData.mLegalAgreement.put('Contract_Group__c', 'Sales - NA');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c', 'Yes');
            UtilityTestData.mLegalAgreement.put('Account__c',account[8].Id);
            UtilityTestData.mLegalAgreement.put('Customer_Contact__c', contact[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalAgreement);
            
            List<Legal_Agreement__c> lLegalAgreementInsert = (List<Legal_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObject sObj1 = new Legal_Agreement__c(Id = lLegalAgreementInsert[0].id);
            UtilityTestData.mLegalAgreement.put('SVP_Approved__c','No');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c','No');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mLegalAgreement);
            
            globalApexManager.allowRun('LegalAgreementBeforeUpdate');
            List<Legal_Agreement__c> lLegalAgreementUpdate = (List<Legal_Agreement__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            
            Legal_Agreement__c legalAgreementToDelete = [Select Id from Legal_Agreement__c where Id =: lLegalAgreementUpdate[0].id];
            
            delete legalAgreementToDelete; 
            
            undelete legalAgreementToDelete;
            
        Test.stopTest();
    }
    
//Daas, >25k
    @isTest static void legalAgreementDaaS1Insert(){
        List<Account> account = (List<Account>) UtilityTest.executeQuery('SELECT Id FROM Account Limit 18');
        List<Contact> contact = (List<Contact>) UtilityTest.executeQuery('SELECT Id FROM Contact Limit 1');
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.executeQuery('SELECT Id FROM SBQQ__Quote__c Limit 18');
        List<Product2> lProduct = (List<Product2>) UtilityTest.executeQuery('Select Id from Product2 Limit 4');
        
        
        Test.startTest();
            
            //On Prem S Or CLoud, > 75
            sObject sObj10 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuote[9].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[1].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.today()+'');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','60');
            sObj10 = UtilityTest.putFieldRecord(sObj10, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj10}); 
            
            
            sObject sObj = new Legal_Agreement__c();
            UtilityTestData.mLegalAgreement.put('Contract_Group__c', 'Sales - NA');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c', 'Yes');
            UtilityTestData.mLegalAgreement.put('Account__c',account[9].Id);
            UtilityTestData.mLegalAgreement.put('Customer_Contact__c', contact[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalAgreement);
            
            List<Legal_Agreement__c> lLegalAgreementInsert = (List<Legal_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObject sObj1 = new Legal_Agreement__c(Id = lLegalAgreementInsert[0].id);
            //UtilityTestData.mLegalAgreement.put('SVP_Approved__c','No');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c','No');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mLegalAgreement);
            
            globalApexManager.allowRun('LegalAgreementBeforeUpdate');
            List<Legal_Agreement__c> lLegalAgreementUpdate = (List<Legal_Agreement__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            System.assertEquals(lLegalAgreementUpdate.size(), 1);
            System.assertEquals(lLegalAgreementUpdate[0].Use_Third_Party_Paper__c, 'No');
        Test.stopTest();
    }


    //Only Or Prem P, <50k EMEA
    @isTest static void legalAgreementOnlyOnPremPInsert(){
        List<Account> account = (List<Account>) UtilityTest.executeQuery('SELECT Id FROM Account Limit 18');
        List<Contact> contact = (List<Contact>) UtilityTest.executeQuery('SELECT Id FROM Contact Limit 1');
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.executeQuery('SELECT Id FROM SBQQ__Quote__c Limit 18');
        List<Product2> lProduct = (List<Product2>) UtilityTest.executeQuery('Select Id from Product2 Limit 4');
        
        
        Test.startTest();
            
            //Only On Prem P, <50k
            sObject sObj10 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuote[10].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[3].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.today()+'');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','60');
            sObj10 = UtilityTest.putFieldRecord(sObj10, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj10}); 
            
            
            sObject sObj = new Legal_Agreement__c();
            UtilityTestData.mLegalAgreement.put('Contract_Group__c', 'Sales - EMEA/LA');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c', 'Yes');
            UtilityTestData.mLegalAgreement.put('Account__c',account[10].Id);
            UtilityTestData.mLegalAgreement.put('Customer_Contact__c', contact[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalAgreement);
            
            List<Legal_Agreement__c> lLegalAgreementInsert = (List<Legal_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObject sObj1 = new Legal_Agreement__c(Id = lLegalAgreementInsert[0].id);
            UtilityTestData.mLegalAgreement.put('SVP_Approved__c','No');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c','No');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mLegalAgreement);
            
            globalApexManager.allowRun('LegalAgreementBeforeUpdate');
            List<Legal_Agreement__c> lLegalAgreementUpdate = (List<Legal_Agreement__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            System.assertEquals(lLegalAgreementUpdate.size(), 1);
            System.assertEquals(lLegalAgreementUpdate[0].Use_Third_Party_Paper__c, 'No');
        Test.stopTest();
    }

//Only Or Prem P, >50k EMEA
    @isTest static void legalAgreementOnlyOnPremP1Insert(){
        List<Account> account = (List<Account>) UtilityTest.executeQuery('SELECT Id FROM Account Limit 18');
        List<Contact> contact = (List<Contact>) UtilityTest.executeQuery('SELECT Id FROM Contact Limit 1');
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.executeQuery('SELECT Id FROM SBQQ__Quote__c Limit 18');
        List<Product2> lProduct = (List<Product2>) UtilityTest.executeQuery('Select Id from Product2 Limit 4');
        
        
        Test.startTest();
            
            //Only On Prem P, >50k
            sObject sObj10 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuote[11].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[3].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.today()+'');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','110');
            sObj10 = UtilityTest.putFieldRecord(sObj10, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj10}); 
            
            
            sObject sObj = new Legal_Agreement__c();
            UtilityTestData.mLegalAgreement.put('Contract_Group__c', 'Sales - EMEA/LA');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c', 'Yes');
            UtilityTestData.mLegalAgreement.put('Account__c',account[11].Id);
            UtilityTestData.mLegalAgreement.put('Customer_Contact__c', contact[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalAgreement);
            
            List<Legal_Agreement__c> lLegalAgreementInsert = (List<Legal_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObject sObj1 = new Legal_Agreement__c(Id = lLegalAgreementInsert[0].id);
            UtilityTestData.mLegalAgreement.put('SVP_Approved__c','No');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c','No');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mLegalAgreement);
            
            globalApexManager.allowRun('LegalAgreementBeforeUpdate');
            List<Legal_Agreement__c> lLegalAgreementUpdate = (List<Legal_Agreement__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            System.assertEquals(lLegalAgreementUpdate.size(), 1);
            System.assertEquals(lLegalAgreementUpdate[0].Use_Third_Party_Paper__c, 'No');
        Test.stopTest();
    }   

    //Cloud Or OnPremS , <25K EMEA
    @isTest static void legalAgreemtCloudOrOnPremEMEAInsert(){
        List<Account> account = (List<Account>) UtilityTest.executeQuery('SELECT Id FROM Account LIMIT 18');
        List<Contact> contact = (List<Contact>) UtilityTest.executeQuery('SELECT Id FROM Contact LIMIT 1');
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.executeQuery('SELECT Id FROM SBQQ__Quote__c Limit 18');
        List<Product2> lProduct = (List<Product2>) UtilityTest.executeQuery('Select Id from Product2 Limit 4');
        
        
        Test.startTest();
            
            //Cloud Or OnPremS , <25K
            sObject sObj6 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuote[12].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.today()+'');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','10');
            sObj6 = UtilityTest.putFieldRecord(sObj6, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj6}); 
            
            
            sObject sObj = new Legal_Agreement__c();
            UtilityTestData.mLegalAgreement.put('Contract_Group__c', 'Sales - EMEA/LA');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c', 'Yes');
            UtilityTestData.mLegalAgreement.put('Account__c',account[12].Id);
            UtilityTestData.mLegalAgreement.put('Customer_Contact__c', contact[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalAgreement);
            
            List<Legal_Agreement__c> lLegalAgreementInsert = (List<Legal_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObject sObj1 = new Legal_Agreement__c(Id = lLegalAgreementInsert[0].id);
            UtilityTestData.mLegalAgreement.put('SVP_Approved__c','No');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c','No');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mLegalAgreement);
            
            globalApexManager.allowRun('LegalAgreementBeforeUpdate');
            List<Legal_Agreement__c> lLegalAgreementUpdate = (List<Legal_Agreement__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            System.assertEquals(lLegalAgreementUpdate.size(), 1);
            System.assertEquals(lLegalAgreementUpdate[0].Use_Third_Party_Paper__c, 'No');
        Test.stopTest();

    }

//Cloud Or OnPremS , >25K EMEA
    @isTest static void legalAgreemtCloudOrOnPremEMEA1Insert(){
        List<Account> account = (List<Account>) UtilityTest.executeQuery('SELECT Id FROM Account LIMIT 18');
        List<Contact> contact = (List<Contact>) UtilityTest.executeQuery('SELECT Id FROM Contact LIMIT 1');
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.executeQuery('SELECT Id FROM SBQQ__Quote__c Limit 18');
        List<Product2> lProduct = (List<Product2>) UtilityTest.executeQuery('Select Id from Product2 Limit 4');
        
        
        Test.startTest();
            
            //Cloud Or OnPremS , >25K
            sObject sObj6 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuote[13].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.today()+'');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','60');
            sObj6 = UtilityTest.putFieldRecord(sObj6, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj6}); 
            
            
            sObject sObj = new Legal_Agreement__c();
            UtilityTestData.mLegalAgreement.put('Contract_Group__c', 'Sales - EMEA/LA');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c', 'Yes');
            UtilityTestData.mLegalAgreement.put('Account__c',account[13].Id);
            UtilityTestData.mLegalAgreement.put('Customer_Contact__c', contact[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalAgreement);
            
            List<Legal_Agreement__c> lLegalAgreementInsert = (List<Legal_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObject sObj1 = new Legal_Agreement__c(Id = lLegalAgreementInsert[0].id);
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c','No');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mLegalAgreement);
            
            globalApexManager.allowRun('LegalAgreementBeforeUpdate');
            List<Legal_Agreement__c> lLegalAgreementUpdate = (List<Legal_Agreement__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            System.assertEquals(lLegalAgreementUpdate.size(), 1);
            System.assertEquals(lLegalAgreementUpdate[0].Use_Third_Party_Paper__c, 'No');
        Test.stopTest();

    }
    

    //DaaS , <25K EMEA
    @isTest static void legalAgreemtDaaSEMEAInsert(){
        List<Account> account = (List<Account>) UtilityTest.executeQuery('SELECT Id FROM Account LIMIT 18');
        List<Contact> contact = (List<Contact>) UtilityTest.executeQuery('SELECT Id FROM Contact LIMIT 1');
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.executeQuery('SELECT Id FROM SBQQ__Quote__c Limit 18');
        List<Product2> lProduct = (List<Product2>) UtilityTest.executeQuery('Select Id from Product2 Limit 4');
        
        
        Test.startTest();
            
            //DaaS , <25K
            sObject sObj6 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuote[14].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[1].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.today()+'');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','10');
            sObj6 = UtilityTest.putFieldRecord(sObj6, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj6}); 
            
            
            sObject sObj = new Legal_Agreement__c();
            UtilityTestData.mLegalAgreement.put('Contract_Group__c', 'Sales - EMEA/LA');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c', 'Yes');
            UtilityTestData.mLegalAgreement.put('Account__c',account[14].Id);
            UtilityTestData.mLegalAgreement.put('Customer_Contact__c', contact[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalAgreement);
            
            List<Legal_Agreement__c> lLegalAgreementInsert = (List<Legal_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObject sObj1 = new Legal_Agreement__c(Id = lLegalAgreementInsert[0].id);
            UtilityTestData.mLegalAgreement.put('SVP_Approved__c','');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c','No');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mLegalAgreement);
            
            globalApexManager.allowRun('LegalAgreementBeforeUpdate');
            List<Legal_Agreement__c> lLegalAgreementUpdate = (List<Legal_Agreement__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            System.assertEquals(lLegalAgreementUpdate.size(), 1);
            System.assertEquals(lLegalAgreementUpdate[0].Use_Third_Party_Paper__c, 'No');
        Test.stopTest();

    }

    //DaaS , >25K EMEA
    @isTest static void legalAgreemtDaaSEMEA1Insert(){
        List<Account> account = (List<Account>) UtilityTest.executeQuery('SELECT Id FROM Account LIMIT 18');
        List<Contact> contact = (List<Contact>) UtilityTest.executeQuery('SELECT Id FROM Contact LIMIT 1');
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.executeQuery('SELECT Id FROM SBQQ__Quote__c Limit 18');
        List<Product2> lProduct = (List<Product2>) UtilityTest.executeQuery('Select Id from Product2 Limit 4');
        
        
        Test.startTest();
            
            //DaaS , >25K
            sObject sObj6 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuote[15].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[1].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.today()+'');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','60');
            sObj6 = UtilityTest.putFieldRecord(sObj6, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj6}); 
            
            
            sObject sObj = new Legal_Agreement__c();
            UtilityTestData.mLegalAgreement.put('Contract_Group__c', 'Sales - EMEA/LA');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c', 'Yes');
            UtilityTestData.mLegalAgreement.put('Account__c',account[15].Id);
            UtilityTestData.mLegalAgreement.put('Customer_Contact__c', contact[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalAgreement);
            
            List<Legal_Agreement__c> lLegalAgreementInsert = (List<Legal_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObject sObj1 = new Legal_Agreement__c(Id = lLegalAgreementInsert[0].id);
            //UtilityTestData.mLegalAgreement.put('SVP_Approved__c','No');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c','No');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mLegalAgreement);
            
            globalApexManager.allowRun('LegalAgreementBeforeUpdate');
            List<Legal_Agreement__c> lLegalAgreementUpdate = (List<Legal_Agreement__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            System.assertEquals(lLegalAgreementUpdate.size(), 1);
            System.assertEquals(lLegalAgreementUpdate[0].Use_Third_Party_Paper__c, 'No');
        Test.stopTest();

    }

    //Cloud or DaaS  + On Prem Sub, <1M
    @isTest static void testQuoteNumber(){
        List<SBQQ__Quote__c> lQuote = [SELECT Id,Name FROM SBQQ__Quote__c LIMIT 2];
        
        Test.startTest();

            sObject sObj = new Legal_Agreement__c();
            UtilityTestData.mLegalAgreement.put('Contract_Group__c', 'Sales - NA');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c', 'No');
        	UtilityTestData.mLegalAgreement.put('Quote_Number__c',lQuote[0].Name);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalAgreement);
            
            List<Legal_Agreement__c> lLegalAgreementInsert = (List<Legal_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObject sObj1 = new Legal_Agreement__c(Id = lLegalAgreementInsert[0].id);
            UtilityTestData.mLegalAgreement.put('SVP_Approved__c','No');
            UtilityTestData.mLegalAgreement.put('Use_Third_Party_Paper__c','Yes');
        	UtilityTestData.mLegalAgreement.put('Quote_Number__c',lQuote[1].Name);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mLegalAgreement);
            
            globalApexManager.allowRun('LegalAgreementBeforeUpdate');
            List<Legal_Agreement__c> lLegalAgreementUpdate = (List<Legal_Agreement__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});

            SBQQ__Quote__c quoteRec = [SELECT Id,Name,Exhibit_A_Legal_Agreement_Reference__c FROM SBQQ__Quote__c WHERE Name = :lQuote[1].Name LIMIT 1];
            Legal_Agreement__c lar = [SELECT Id,Name from Legal_Agreement__c WHERE Id = :lLegalAgreementInsert[0].id];
            System.assertEquals(quoteRec.Exhibit_A_Legal_Agreement_Reference__c,lar.Name);
            
        Test.stopTest();

    }    

    }