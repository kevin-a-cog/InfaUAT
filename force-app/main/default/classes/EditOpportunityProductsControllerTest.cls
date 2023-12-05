@isTest
private class EditOpportunityProductsControllerTest{
    @testSetup
    static void setupObjectTestData() {
        sObject sObj = new blng__BillingRule__c();
        
        sObj = new blng__BillingRule__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngBillingRuleData);
        List<blng__BillingRule__c> lBillingRule = (List<blng__BillingRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new blng__RevenueRecognitionRule__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngRevRecRuleData);
        List<blng__RevenueRecognitionRule__c> lRevRecRule = (List<blng__RevenueRecognitionRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new blng__TaxRule__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngTaxRuleData);
        List<blng__TaxRule__c> lTaxRule = (List<blng__TaxRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        sObj = new Product2();
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
        
        sObject sObjProd = new Product2();
        UtilityTestData.mProduct2Data.put('Name','Test Product');
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
        sObjProd = UtilityTest.putFieldRecord(sObjProd, UtilityTestData.mProduct2Data);
        List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj,sObjProd});
        lProduct2[0].Orderable__c = false;
        
        update lProduct2;
        
        Id pricebookId = Test.getStandardPricebookId(); 
        
        sObj = new Pricebook2(Id = pricebookId,IsActive = True);
        List<Pricebook2> lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        
        sObj = new pricebookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',pricebookId);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);
        
        sObject sObjPBE = new pricebookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',pricebookId);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[1].Id);
        sObjPBE = UtilityTest.putFieldRecord(sObjPBE, UtilityTestData.mPriceBookEntryData);
        List<pricebookEntry> lPriceBookEntry = (List<pricebookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj,sObjPBE});
        
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;
        
        sObj = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Creating Primary Opportunity
        sObject sObjPrimaryOpp = new Opportunity();
        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c','Primary');
        sObjPrimaryOpp = UtilityTest.putFieldRecord(sObjPrimaryOpp, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunityP = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObjPrimaryOpp});
        
        
        //update the pricebook on Opty
        sObj = new Opportunity(id = lOpportunityP[0].Id, Pricebook2Id = pricebookId);
        lOpportunityP = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        
        //Add OLI on Primary Opportunity
        sObject sObjOppLineItem1 = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunityP[0].Id);
        UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[1].Id);
        sObjOppLineItem1 = UtilityTest.putFieldRecord(sObjOppLineItem1 ,UtilityTestData.mOpportunityProdData);
         Test.startTest(); 
        List<OpportunityLineItem> lstOpportunityLineItem = (List<OpportunityLineItem>) UtilityTest.makeInsert(new List<sObject>{sObjOppLineItem1});
         Test.stopTest(); 
    }
	
    @isTest
    static void testEditOpportunityProduct(){

        List<Opportunity> lstOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> lstOpportunityLineItem = [SELECT Id, UnitPrice,Transaction_Type__c FROM OpportunityLineItem LIMIT 1 ];
         
         Test.startTest();
         EditOpportunityProductsController.getTransTypeSelect();
         
         List<EditOpportunityProductsController.OpportunityLineItemWrapper> oliWrapperList = EditOpportunityProductsController.getOpportunityLineItemsWrapper(lstOpportunity[0].Id); 
         oliWrapperList[0].UnitPrice = 5000;
         String serializedObject = System.JSON.serialize(oliWrapperList); 
         EditOpportunityProductsController.saveOpportunityLineItem(serializedObject, lstOpportunity[0].Id); 
         List<EditOpportunityProductsController.OpportunityLineItemWrapper> oliWrapperListDelete = EditOpportunityProductsController.deleteOpportunityLineItemServer(lstOpportunityLineItem[0].Id, lstOpportunity[0].Id);
         Test.stopTest();
    }
}