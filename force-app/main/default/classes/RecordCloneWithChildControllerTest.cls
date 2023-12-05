@isTest
public class RecordCloneWithChildControllerTest {
    
    @testSetup
    public static void setupObjectTestData(){
        
        List<Territory2> lTerritoryNA = (List<Territory2>) UtilityTest.executeQuery('Select Id,Name from Territory2 where Name LIKE \'NA%\'');
        sObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name','Test Account 1');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
       
        UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
        sObj = new Contact();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
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
        
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Pricebook2();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPricebook2Data);
        List<Pricebook2> lPricebook2 = (List<Pricebook2>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        // Set all the required fields and dynamic ids in Map
        sObj = new blng__LegalEntity__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalEntityData);
        List<blng__LegalEntity__c> lLegalEntity = (List<blng__LegalEntity__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new blng__BillingRule__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngBillingRuleData);
        List<blng__BillingRule__c> lBillingRule = (List<blng__BillingRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new blng__RevenueRecognitionRule__c();
        sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mblngRevRecRuleData);
        List<blng__RevenueRecognitionRule__c> lRevRecRule = (List<blng__RevenueRecognitionRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});    
       
        sObj = new blng__TaxRule__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngTaxRuleData);
        List<blng__TaxRule__c> lTaxRule = (List<blng__TaxRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //inserting product
        sObj = new Product2();
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c', lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c', lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c', lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('Offering_Type__c', 'On-Premise Perpetual License');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
        List<Product2> lProduct = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
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
        
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
    }

    @isTest
    public static void testChildCloneMethod(){
        List<SBQQ__Quote__c> quoteList= (List<SBQQ__Quote__c>) UtilityTest.executeQuery('Select Id from SBQQ__Quote__c');
        SBQQ__Quote__c clonedQuote = quoteList[0].clone(false, true);
        clonedQuote.SBQQ__Source__c = quoteList[0].Id;
        insert clonedQuote;
        List<Product2> prodList= (List<Product2>) UtilityTest.executeQuery('Select Id from Product2');
        Test.startTest();
        sObject sObj = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', prodList[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c', '12');
        sObj = new SBQQ__QuoteLine__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
        List<SBQQ__QuoteLine__c> lQuoteLI = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        RecordCloneWithChildController.cloneObjectSingle(clonedQuote.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testGetChildObjectNames(){
        List<SBQQ__Quote__c>quote=(List<SBQQ__Quote__c>) UtilityTest.executeQuery('Select Id from SBQQ__Quote__c');
        System.assert(quote.size()>0);
        Map<String,Object> resultMap=RecordCloneWithChildController.getChildObjectNames(quote[0].Id);
        System.assert(resultMap.get('Status')!='Error');
    }

    @isTest
    public static void testGetChildObjectNamesException(){
        List<Account> accRecord = (List<Account>) UtilityTest.executeQuery('Select Id from Account');
        Map<String,Object> resultMap=RecordCloneWithChildController.getChildObjectNames(accRecord[0].Id);
        System.assert(resultMap.get('Status')=='Error');
    }

}