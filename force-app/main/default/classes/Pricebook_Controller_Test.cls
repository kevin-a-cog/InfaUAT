/*
Class:  Pricebook_Controller_Test
        @Author:        Shashank Agarwal
        @Created Date:  15 February 2019
        @Description:   Test Class for Pricebook_Controller Class.
*/
@isTest
private class Pricebook_Controller_Test{

    @testSetup
    static void setupObjectTestData() {
        
        sObject sObj = new blng__BillingRule__c();
        sObject sObj1 = new blng__BillingRule__c();
        sObject sObj2 = new blng__BillingRule__c();
        sObject sObj3 = new blng__BillingRule__c();
        
        sObj = new blng__BillingRule__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngBillingRuleData);
        List<blng__BillingRule__c> lBillingRule = (List<blng__BillingRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new blng__RevenueRecognitionRule__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngRevRecRuleData);
        List<blng__RevenueRecognitionRule__c> lRevRecRule = (List<blng__RevenueRecognitionRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new blng__TaxRule__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngTaxRuleData);
        List<blng__TaxRule__c> lTaxRule = (List<blng__TaxRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Product2(IsActive = true, Exclude_Clone__c = false);
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
        List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        Id pricebookId = Test.getStandardPricebookId(); 
        
        sObj = new Pricebook2(Id = pricebookId,IsActive = True,Version__c='1.0',Primary__c = TRUE,Start_Date__c=Date.Today(),End_Date__c=Date.Today().addDays(30));
        List<Pricebook2> lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        
        sObj1 = new Pricebook2(Clone__c = false,Version__c='1.0',Sync_Status__c='Completed',Primary__c = TRUE,Start_Date__c=Date.Today(),End_Date__c=Date.Today().addDays(30));
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mPricebook2Data);
        List<Pricebook2> lNonStandardPriceBook2 = (List<Pricebook2>) UtilityTest.makeInsert(new List<sObject>{sObj1});
        
        sObj = new Currency_Conversion_Rates__c();
        UtilityTestData.mCurrencyConvRate.put('Price_Book__c',lPriceBook2[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCurrencyConvRate);
        
        sObj1 = new Currency_Conversion_Rates__c();
        UtilityTestData.mCurrencyConvRate.put('Price_Book__c',lNonStandardPriceBook2[0].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mCurrencyConvRate);
        
        sObj2 = new Currency_Conversion_Rates__c();
        UtilityTestData.mCurrencyConvRate.put('Price_Book__c',lPriceBook2[0].Id);
        UtilityTestData.mCurrencyConvRate.put('CurrencyIsoCode','EUR');
        UtilityTestData.mCurrencyConvRate.put('Conversion_Rate__c','0.984');
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mCurrencyConvRate);
        
        sObj3 = new Currency_Conversion_Rates__c();
        UtilityTestData.mCurrencyConvRate.put('Price_Book__c',lNonStandardPriceBook2[0].Id);
        UtilityTestData.mCurrencyConvRate.put('CurrencyIsoCode','EUR');
        UtilityTestData.mCurrencyConvRate.put('Conversion_Rate__c','0.984');
        sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mCurrencyConvRate);
        
        List<Currency_Conversion_Rates__c> lCCR = (List<Currency_Conversion_Rates__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3});
        
        sObj = new pricebookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',lPriceBook2[0].Id);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);
        
        sObj2 = new pricebookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',lNonStandardPriceBook2[0].Id);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[0].Id);
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mPriceBookEntryData);
        List<pricebookEntry> lPriceBookEntry = (List<pricebookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj2});   
    }
    
    //Method to test upsert of PricebookEntry
    @isTest
    static void priceBookEntryCloneTest() {
        Test.startTest();
        Pricebook2 pricebook;
        Pricebook2 SPriceBook;
        List<String> PBIds = new List<String> ();
        for(Pricebook2 pb : [Select Id, Name, IsActive, Description, Primary__c, IsStandard, Version__c, Sync_Status__c, End_Date__c, Start_Date__c, Multi_Currency_Master__c, Multi_Currency_Master__r.Name, Cloned_From__c from Pricebook2])
        {
            if(pb.IsStandard)
                SPriceBook = pb;
             else
                 pricebook = pb;
            PBIds.add(pb.Id);
        }
        System.debug('@Test--->'+pricebook.Id);
      
        sObject sObj = new Pricebook_Uplift__c();
        UtilityTestData.mPricebookUpliftData.put('Price_Book__c', pricebook.Id);
        UtilityTestData.mPricebookUpliftData.put('Pricing_Business_Model__c', '');
        UtilityTestData.mPricebookUpliftData.put('Processing_Engine__c', '');
        UtilityTestData.mPricebookUpliftData.put('Delivery_Method__c ', '');
        UtilityTestData.mPricebookUpliftData.put('Product_Family__c', '');
        UtilityTestData.mPricebookUpliftData.put('Round_up_To__c', '1');
        UtilityTestData.mPricebookUpliftData.put('Percentage__c','5');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPricebookUpliftData);
        insert sObj;
        
         sObj = new Pricebook_Uplift__c();
        UtilityTestData.mPricebookUpliftData.put('Price_Book__c', pricebook.Id);
        UtilityTestData.mPricebookUpliftData.put('Pricing_Business_Model__c', '');
        UtilityTestData.mPricebookUpliftData.put('Processing_Engine__c', '');
        UtilityTestData.mPricebookUpliftData.put('Delivery_Method__c ', '');
        UtilityTestData.mPricebookUpliftData.put('Product_Family__c', '');
        UtilityTestData.mPricebookUpliftData.put('Round_up_To__c', '100');
        UtilityTestData.mPricebookUpliftData.put('Percentage__c','5');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPricebookUpliftData);
         List<Pricebook_Uplift__c> pbUList = (List<Pricebook_Uplift__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        System.assertEquals(pbUList.size(), 1);







        
        List<PricebookEntry> pbEList = [Select Id, End_Date__c, Pricebook2Id, CurrencyIsoCode, Product2.Exclude_Clone__c, IsActive, Start_Date__c, Exclude_Currency_Exchange__c, UnitPrice, Product2Id, ProductCode, Product2.Product_Family__c, Product2.Pricing_Business_Model__c, Product2.Delivery_Method__c, Product2.Processing_Engine__c, Product2.Exclude_Round_Up_to__c from PricebookEntry Where Pricebook2Id =: pricebook.Id AND IsActive = true AND CurrencyIsoCode = 'USD'];


        Pricebook2 onLoadCurrent = Pricebook_Controller.onLoadCurrent(pricebook.Id);
        Pricebook2 getPricebook = Pricebook_Controller.getCurrentPriceBook(pricebook.Id);
        Boolean checkName = Pricebook_Controller.checkPriceBookName(pricebook.Name);
        Pricebook_Controller.getRefreshAllPB(SPriceBook.Id);
        Pricebook_Controller.refreshStandardPB(SPriceBook.Id);
        Pricebook_Controller.getCurrencyRates(pricebook.Id);
        Pricebook_Controller.getPriceBookEntries(pricebook.Id);
        Pricebook_Controller.updateAllPB(PBIds);
        
        List<Pricebook_Uplift__c> getPricebookUplifts = Pricebook_Controller.getPricebookUplifts(pricebook.Id);
        
        Pricebook_Controller.ProductUpliftWrapperClass getPage2 = Pricebook_Controller.getPage();
        
        String pricebookId = Pricebook_Controller.savePricebookAddPricebookUplift(pricebook, JSON.serialize(pbUList));
        
        String pricebookId1 = Pricebook_Controller.savePricebookUplift(SPriceBook.Id, SPriceBook, JSON.serialize(pbUList));
        
        Test.stopTest();
        System.assert(pricebookId1!=null);
        
    }
}