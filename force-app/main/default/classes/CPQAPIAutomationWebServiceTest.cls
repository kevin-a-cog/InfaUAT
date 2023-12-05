@isTest
public class CPQAPIAutomationWebServiceTest {
    @testSetup
    static void setupObjectTestData() {
        User userObj = [select Id, Name from User where Name = 'Deployment master' and IsActive = true limit 1];
        System.runAs(userObj){
            //Query NA, APJ and EA territories
            List<Territory2> lTerritoryNA = (List<Territory2>) UtilityTest.executeQuery('Select Id from Territory2 where Name LIKE \'%NA%\'');
            List<Territory2> lTerritoryAPJ = (List<Territory2>) UtilityTest.executeQuery('Select Id from Territory2 where Name LIKE \'%AP%\'');
            List<Territory2> lTerritoryEA = (List<Territory2>) UtilityTest.executeQuery('Select Id from Territory2 where Name LIKE \'EA%\'');
            
            sObject sObj = new Account();
            
            UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
            UtilityTestData.mAccountData.put('BillingCountry','United States');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
            List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //Insert Contact Data
            
            sObj = new Contact();
            UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mContactData.put('MailingCountry','United States');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //Billing rule data
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
            
            sObj = new blng__LegalEntity__c();
            UtilityTestData.mLegalEntityData.put('Name','test');
            UtilityTestData.mLegalEntityData.put('Business_Unit_Code__c','US001');
            UtilityTestData.mLegalEntityData.put('Multi_Country_Mapping1__c','India');
            UtilityTestData.mLegalEntityData.put('Multi_Country_Mapping2__c','India');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalEntityData);
            
            List<blng__LegalEntity__c> lLegalEntity = (List<blng__LegalEntity__c>) UtilityTest.makeInsert(new List<sObject>{sObj});  
            
            //Pricebook data
            sObj = new Pricebook2();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPricebook2Data);
            List<Pricebook2> lPricebook2 = (List<Pricebook2>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new Product2();
            UtilityTestData.mProduct2Data.put('blng__BillingRule__c', lBillingRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c', lRevRecRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__TaxRule__c', lTaxRule[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
            
            sObject sObj11 = new Product2();
            UtilityTestData.mProduct2Data.put('blng__BillingRule__c', lBillingRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c', lRevRecRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__TaxRule__c', lTaxRule[0].Id);
            sObj11 = UtilityTest.putFieldRecord(sObj11, UtilityTestData.mProduct2Data);
            
            sObject sObj13 = new Product2();
            UtilityTestData.mProduct2Data.put('blng__BillingRule__c', lBillingRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c', lRevRecRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__TaxRule__c', lTaxRule[0].Id);
            sObj13 = UtilityTest.putFieldRecord(sObj13, UtilityTestData.mProduct2Data);
            
            List<Product2> lProduct = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj11, sObj13});
            
            //create/update standard Pricebook1
            Id priceBookId  = Test.getStandardPricebookId();
            
            sObj = new Pricebook2(ID = priceBookId, IsActive = True);
            List<Pricebook2> lPriceBook = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            System.assertEquals(lPriceBook.size(), 1);
            
            sObj = new PriceBookEntry();
            UtilityTestData.mPriceBookEntryData.put('Pricebook2Id', lPriceBook[0].Id + '');
            UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct[0].Id + '');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);
            
            sObject sObj01 = new PriceBookEntry();
            UtilityTestData.mPriceBookEntryData.put('Pricebook2Id', lPriceBook[0].Id + '');
            UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct[1].Id + '');
            sObj01 = UtilityTest.putFieldRecord(sObj01, UtilityTestData.mPriceBookEntryData);
            
            sObject sObj02 = new PriceBookEntry();
            UtilityTestData.mPriceBookEntryData.put('Pricebook2Id', lPriceBook[0].Id + '');
            UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct[2].Id + '');
            sObj02 = UtilityTest.putFieldRecord(sObj02, UtilityTestData.mPriceBookEntryData);
            List<PriceBookEntry> lPBEntry = (List<PriceBookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj01,sObj02});

            sObj = new SBQQ__ProductFeature__c();
            UtilityTestData.mProductFeature.put('SBQQ__ConfiguredSKU__c',lProduct[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProductFeature);
          
            sObject sObj10 = new SBQQ__ProductFeature__c();
            UtilityTestData.mProductFeature.put('SBQQ__ConfiguredSKU__c',lProduct[1].Id);
            sObj10 = UtilityTest.putFieldRecord(sObj10, UtilityTestData.mProductFeature);
            
            sObject sObj22 = new SBQQ__ProductFeature__c();
            UtilityTestData.mProductFeature.put('SBQQ__ConfiguredSKU__c',lProduct[1].Id);
            sObj22 = UtilityTest.putFieldRecord(sObj22, UtilityTestData.mProductFeature);
          
            List<SBQQ__ProductFeature__c> lProdFea2 = (List<SBQQ__ProductFeature__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj10,sObj22});
                      
            sObj = new SBQQ__ProductOption__c();
            UtilityTestData.mProductOption.put('SBQQ__ConfiguredSKU__c',lProduct[0].Id);
            UtilityTestData.mProductOption.put('SBQQ__OptionalSKU__c',lProduct[1].Id);        
            UtilityTestData.mProductOption.put('SBQQ__QuoteLineVisibility__c','Never');
            UtilityTestData.mProductOption.put('SBQQ__Feature__c', lProdFea2[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProductOption);
            List<SBQQ__ProductOption__c> lProdOpt = (List<SBQQ__ProductOption__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
            
            
            // Insert new Opportunity
            String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;            
            UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'Direct');
            UtilityTestData.mOpportunityData.put('StageName', 'Final Negotiation');
            UtilityTestData.mOpportunityData.put('Substage__c', 'Selected');
            UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
            UtilityTestData.mOpportunityData.put('CloseDate', System.today().addDays(60) + '');
            
            sObj = new Opportunity(Territory2Id = lTerritoryNA[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);        
            sObject sObj1 = new Opportunity(Territory2Id =lTerritoryAPJ[0].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityData);        
            sObject sObj2 = new Opportunity(Territory2Id =lTerritoryEA[0].Id);
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mOpportunityData);
            
            //Below opportunities are without Territories data into it
            sObject sObj3 = new Opportunity();        
            sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mOpportunityData);
            
            sObject sObj4 = new Opportunity();        
            sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mOpportunityData);        
            
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3,sObj4});
            
            //Insert Opportunity Contact Roles, Sold To
            UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunity[0].Id);
            UtilityTestData.mOpportunityContactRoleData.put('ContactId',lContact[0].Id);
            UtilityTestData.mOpportunityContactRoleData.put('Role', 'End User');
            sObj = new OpportunityContactRole();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityContactRoleData);
            
            UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunity[1].Id);
            UtilityTestData.mOpportunityContactRoleData.put('ContactId',lContact[0].Id);
            UtilityTestData.mOpportunityContactRoleData.put('Role', 'Sold To');
            sObj1 = new OpportunityContactRole();
            sObj1= UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityContactRoleData);
            
            UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunity[2].Id);
            UtilityTestData.mOpportunityContactRoleData.put('ContactId',lContact[0].Id);
            UtilityTestData.mOpportunityContactRoleData.put('Role', 'Shipping Contact');
            sObj2 = new OpportunityContactRole();
            sObj2= UtilityTest.putFieldRecord(sObj2, UtilityTestData.mOpportunityContactRoleData);
            
            UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunity[3].Id);
            UtilityTestData.mOpportunityContactRoleData.put('ContactId',lContact[0].Id);
            UtilityTestData.mOpportunityContactRoleData.put('Role', 'Billing Contact');
            sObj3 = new OpportunityContactRole();
            sObj3= UtilityTest.putFieldRecord(sObj3, UtilityTestData.mOpportunityContactRoleData);
            List<OpportunityContactRole> lContactRoles = (List<OpportunityContactRole>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1, sObj2, sObj3});
            System.assertEquals(lContactRoles.size(), 4);
            
            UtilityTestData.mSBQuoteData.put('SoldToAccount__c', lAccount[0].Id + '');
            UtilityTestData.mSBQuoteData.put('ShiptToAccount__c', lAccount[0].Id + '');
            UtilityTestData.mSBQuoteData.put('BillToAccount__c', lAccount[0].Id + '');
            UtilityTestData.mSBQuoteData.put('EndUserAccount__c', lAccount[0].Id + '');
            UtilityTestData.mSBQuoteData.put('SoldToContact__c', lContact[0].Id + '');
            UtilityTestData.mSBQuoteData.put('EndUserContact__c', lContact[0].Id + '');
            UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'true');        
            UtilityTestData.mSBQuoteData.put('CurrencyIsoCode', 'USD'); 
            UtilityTestData.mSBQuoteData.put('SBQQ__Type__c', 'Quote');
            UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c', System.Today() + '');        
            sObj = new SBQQ__Quote__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
            List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            UtilityTestData.mContractData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mContractData.put('Status','Draft');
            UtilityTestData.mContractData.put('SBQQ__Opportunity__c',lOpportunity[0].Id);
            UtilityTestData.mContractData.put('StartDate',System.today()+'');
            UtilityTestData.mContractData.put('SBQQ__Quote__c',lQuote[0].Id);
            /*sObj = new Contract();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContractData);
            List<Contract> lContract = (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});*/        
            
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
            UtilityTestData.mSBQuoteData.put('CurrencyIsoCode', 'USD'); 
            UtilityTestData.mSBQuoteData.put('SBQQ__Type__c', 'Renewal');
            UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c', System.Today() + '');
            
            sObj = new SBQQ__Quote__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
            
            sObj1 = new SBQQ__Quote__c();
            UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[1].Id + '');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mSBQuoteData);
            
            sObj2 = new SBQQ__Quote__c();
            UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[2].Id + '');
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mSBQuoteData);
            
            sObj3 = new SBQQ__Quote__c();
            UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[3].Id + '');
            UtilityTestData.mSBQuoteData.put('SBQQ__Type__c', 'Renewal');
            sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mSBQuoteData);
            
            UtilityTestData.mSBQuoteData.put('SBQQ__Type__c', 'Amendment');
            UtilityTestData.mSBQuoteData.put('SBQQ__SubscriptionTerm__c', '12');
            UtilityTestData.mSBQuoteData.put('SBQQ__BillingName__c', 'Quote Billing Name');
            UtilityTestData.mSBQuoteData.put('SBQQ__PaymentTerms__c', 'Net 30');
            UtilityTestData.mSBQuoteData.put('SBQQ__ShippingName__c', 'Quote Shipping Name');
            UtilityTestData.mSBQuoteData.put('Shipping_Email__c', 'testmail@test.com');
            UtilityTestData.mSBQuoteData.put('SBQQ__Status__c', 'Approved');
            UtilityTestData.mSBQuoteData.put('BillingAddress_PSFTID__c', 'Billing Address');
            UtilityTestData.mSBQuoteData.put('EditLinesFieldSetName__c', 'Standard');
            UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunity[4].Id + '');
            //UtilityTestData.mSBQuoteData.put('SBQQ__MasterContract__c',lContract[0].Id + '');
            UtilityTestData.mSBQuoteData.put('Additional_Customer_Signature_Blocks__c', '1');
            UtilityTestData.mSBQuoteData.put('Compliance_Settlement__c', 'True');
            UtilityTestData.mSBQuoteData.put('Custom_Support_SLAs__c', 'Testing');
            UtilityTestData.mSBQuoteData.put('ELA_Terms__c', 'Testing');
            UtilityTestData.mSBQuoteData.put('INFA_Signature_Blocks__c', '1');
            UtilityTestData.mSBQuoteData.put('IPS_Custom_Travel_Policy__c', 'Testing');
            UtilityTestData.mSBQuoteData.put('IPS_Price_Holds__c', 'True');
            UtilityTestData.mSBQuoteData.put('License_Price_Protection__c', 'Testing');
            sObj4 = new SBQQ__Quote__c();
            sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mSBQuoteData);
            
            Test.startTest();
            
            List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3,sObj4});
            
            //Create QuoteLineItem
            sObj = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
            
            sObj1 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[0].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
            
            sObj2 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[0].Id);
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);
            
            sObj3 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[1].Id);
            sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mQuoteLineData);
            
            sObj4 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[1].Id);
            sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mQuoteLineData);        
            
            List<SBQQ__QuoteLine__c> lSBQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3,sObj4});
            
            
            Test.stopTest();
        }
    }
    
    @isTest
    public static void runCPQApiAutomationInsertTest() {
        Test.startTest();
        SBQQ__Quote__c qt = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        List<Pricebook2> pbList = [SELECT Id FROM Pricebook2];
        List<Product2> productList = [Select Id FROM Product2];
        String parentProductsIds = ''+productList[0].Id+':1';
        String addOptionSKUIds = ''+productList[1].Id+':1';
        String removeOptionSKUids = productList[1].Id;
        String nestedChildLevelSKUids = productList[2].Id;
        String nesteeChildLevelAddOptionSKUids = ''+productList[2].Id+':2';
        Test.setMock(HTTPCalloutMock.class, new CalloutRestMock());
        CPQAPIAutomationWebService.runCPQApiAutomationInsert(qt.Id, pbList[0].Id, 'USD', parentProductsIds, addOptionSKUIds, removeOptionSKUids, nestedChildLevelSKUids, nesteeChildLevelAddOptionSKUids);
        Test.stopTest();
    }
    
    @isTest
    public static void runCPQApiAutomationUpdateTest() {
        Test.startTest();
        //SBQQ__Quote__c qt = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        List<SBQQ__QuoteLine__c> qlList = [SELECT Id,SBQQ__Quote__c FROM SBQQ__QuoteLine__c];
        List<Product2> productList = [Select Id FROM Product2];
        String updateProdIdsQuantity = ''+productList[0].Id+':1';
        String updateProdIdsDiscount = ''+productList[0].Id+':15';
        
        Test.setMock(HTTPCalloutMock.class, new CalloutRestMock());
        CPQAPIAutomationWebService.runCPQApiAutomationUpdate(qlList[0].SBQQ__Quote__c, updateProdIdsQuantity, updateProdIdsDiscount);
        Test.stopTest();
    }
    
    @isTest
    public static void quoteSaverTest() {
        QuoteModel qm = new QuoteModel();
        SBQQ__Quote__c qt = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        qm.record = qt;
        new QuoteSaver().save(qm);
    }
    @isTest
    public static void cpqAPIMethods() {
    
        QuoteProposalModel qpm = new QuoteProposalModel();
        ConstraintModel conm = new ConstraintModel();
        QuoteLineModel qlm = new QuoteLineModel();
        OptionModel om = new OptionModel();
        ProductModel pm = new ProductModel();
        ConfigurationModel cm = new ConfigurationModel();
        FeatureModel fm = new FeatureModel();
        QuoteLineGroupModel qlgm = new QuoteLineGroupModel();
        ConfigAttributeModel cam = new ConfigAttributeModel();
    
    }
}