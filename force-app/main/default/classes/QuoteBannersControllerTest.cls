///Testclass for QuoteBannersController
@isTest
public with sharing class QuoteBannersControllerTest {
    @testSetup
    static void setupObjectTestData() {
        
        //Create TaxConfig Custom Setting
        blng__TaxConfig__c taxConfig = new blng__TaxConfig__c();
        taxConfig.Name = 'Standard';
        taxConfig.blng__ClassName__c = 'blng.StandardTaxCalculation';
        insert taxConfig;
        
        //Create Billing Config Custom Setting
        List<blng__BillingConfig__c> listBillingConfig = new List<blng__BillingConfig__c>();
        
        blng__BillingConfig__c billConfig1 = new blng__BillingConfig__c();
        billConfig1.Name = 'ADVANCED_AR_APPLICATION';
        billConfig1.blng__BooleanValue__c = true;
        billConfig1.blng__Category__c = 'Invoice';
        billConfig1.blng__Sequence__c = 2;
        listBillingConfig.add(billConfig1);
        
        blng__BillingConfig__c billConfig2 = new blng__BillingConfig__c();
        billConfig2.Name = 'ALIGN_BILLDAYOFMONTH_TO_ORDERSTARTDATE  ';
        billConfig2.blng__BooleanValue__c = true;
        billConfig2.blng__Category__c = 'General';
        billConfig2.blng__FieldType__c = 'Boolean';
        billConfig2.blng__Sequence__c = 3;
        listBillingConfig.add(billConfig2);
        
        blng__BillingConfig__c billConfig3 = new blng__BillingConfig__c();
        billConfig3.Name = 'AVALARA_AVATAX';
        billConfig3.blng__BooleanValue__c = false;
        billConfig3.blng__Category__c = 'Tax';
        billConfig3.blng__StringValue__c = 'Avalara AvaTax';
        listBillingConfig.add(billConfig3);
        
        blng__BillingConfig__c billConfig4 = new blng__BillingConfig__c();
        billConfig4.Name = 'BILLING_REMAINDER_PROCESS';
        billConfig4.blng__BooleanValue__c = false;
        billConfig4.blng__FieldType__c = 'Picklist';
        billConfig4.blng__Category__c = 'Invoice';
        billConfig4.blng__Sequence__c = 5;
        billConfig4.blng__StringValue__c = 'Last Period';
        billConfig4.blng__PicklistIndicator__c = 'billingRemainderProcessList';
        listBillingConfig.add(billConfig4);
        
        blng__BillingConfig__c billConfig5 = new blng__BillingConfig__c();
        billConfig5.Name = 'CARD_MAPPING';
        billConfig5.blng__BooleanValue__c = false;
        billConfig5.blng__Category__c = 'Payment';
        billConfig5.blng__FieldType__c = 'String';
        billConfig5.blng__Sequence__c = 2;
        listBillingConfig.add(billConfig5);
        
        blng__BillingConfig__c billConfig6 = new blng__BillingConfig__c();
        billConfig6.Name = 'DISABLE_TRIGGERS';
        billConfig6.blng__BooleanValue__c = false;
        billConfig6.blng__Category__c = 'General';
        billConfig6.blng__FieldType__c = 'Boolean';
        listBillingConfig.add(billConfig6);
        
        blng__BillingConfig__c billConfig7 = new blng__BillingConfig__c();
        billConfig7.Name = 'INSERT_SAMPLE_DATA';
        billConfig7.blng__BooleanValue__c = false;
        billConfig7.blng__FieldType__c = 'Boolean';
        listBillingConfig.add(billConfig7);
        
        blng__BillingConfig__c billConfig8 = new blng__BillingConfig__c();
        billConfig8.Name = 'INVOICE_BATCH_SIZE';
        billConfig8.blng__BooleanValue__c = false;
        billConfig8.blng__Category__c = 'Invoice';
        billConfig8.blng__FieldType__c = 'Number';
        billConfig8.blng__NumberValue__c = 2000.00;
        billConfig8.blng__Sequence__c = 7;
        listBillingConfig.add(billConfig8);
        
        blng__BillingConfig__c billConfig9 = new blng__BillingConfig__c();
        billConfig9.Name = 'INVOICE_TO_BE_CHARGED_ON';
        billConfig9.blng__BooleanValue__c = false;
        billConfig9.blng__Category__c = 'Payment';
        billConfig9.blng__FieldType__c = 'Picklist';
        billConfig9.blng__PicklistIndicator__c = 'PaymentSchedulerList';
        billConfig9.blng__StringValue__c = 'Due Date';
        billConfig9.blng__Sequence__c = 2;
        listBillingConfig.add(billConfig9);
        
        blng__BillingConfig__c billConfig10 = new blng__BillingConfig__c();
        billConfig10.Name = 'PARTIAL_PERIOD_BILLING_PRORATION';
        billConfig10.blng__BooleanValue__c = false;
        billConfig10.blng__Category__c = 'Invoice';  
        billConfig10.blng__FieldType__c = 'Picklist';
        billConfig10.blng__PicklistIndicator__c = 'PartialProrationTypeList';
        billConfig10.blng__StringValue__c = 'Month + Daily';
        billConfig10.blng__Sequence__c = 3;
        listBillingConfig.add(billConfig10);
        
        blng__BillingConfig__c billConfig11 = new blng__BillingConfig__c();
        billConfig11.Name = 'PAYMENT_METHOD_DISPLAY';
        billConfig11.blng__BooleanValue__c = false;
        billConfig11.blng__Category__c = 'Payment';  
        billConfig11.blng__FieldType__c = 'Picklist';
        billConfig11.blng__PicklistIndicator__c = 'PaymentMethodDisplayList';
        billConfig11.blng__StringValue__c = 'Nickname';
        billConfig11.blng__Sequence__c = 1;
        listBillingConfig.add(billConfig11);
        
        blng__BillingConfig__c billConfig12 = new blng__BillingConfig__c();
        billConfig12.Name = 'PERIOD_PRICE_ROUNDING';
        billConfig12.blng__BooleanValue__c = false;
        billConfig12.blng__Category__c = 'General';  
        billConfig12.blng__FieldType__c = 'Picklist';
        billConfig12.blng__PicklistIndicator__c = 'PeriodPriceRoundingList';
        billConfig12.blng__StringValue__c = 'HALF_UP';
        billConfig12.blng__Sequence__c = 8;
        listBillingConfig.add(billConfig12);
        
        blng__BillingConfig__c billConfig13 = new blng__BillingConfig__c();
        billConfig13.Name = 'PRORATION_TYPE';
        billConfig13.blng__BooleanValue__c = false;
        billConfig13.blng__Category__c = 'Invoice';  
        billConfig13.blng__FieldType__c = 'Picklist';
        billConfig13.blng__PicklistIndicator__c = 'CalendarDaysList';
        billConfig13.blng__StringValue__c = 'Calendar Days';
        billConfig13.blng__Sequence__c = 3;
        listBillingConfig.add(billConfig13);
        
        blng__BillingConfig__c billConfig14 = new blng__BillingConfig__c();
        billConfig14.Name = 'REVENUE_REMAINDER_PROCESS';
        billConfig14.blng__BooleanValue__c = false;
        billConfig14.blng__Category__c = 'Invoice';  
        billConfig14.blng__FieldType__c = 'Picklist';
        billConfig14.blng__PicklistIndicator__c = 'RevenueRemainderProcessList';
        billConfig14.blng__StringValue__c = 'Last Period';
        billConfig14.blng__Sequence__c = 6;
        listBillingConfig.add(billConfig14);
        
        blng__BillingConfig__c billConfig15 = new blng__BillingConfig__c();
        billConfig15.Name = 'SAVE_CREDIT_CARD_ON_PAYMENT_PAGE';
        billConfig15.blng__BooleanValue__c = false;
        billConfig15.blng__Category__c = 'Payment';  
        billConfig15.blng__FieldType__c = 'Boolean';
        billConfig15.blng__Sequence__c = 6;
        listBillingConfig.add(billConfig15);
        
        blng__BillingConfig__c billConfig16 = new blng__BillingConfig__c();
        billConfig16.Name = 'TAX_CALCULATION_BASED_ON';
        billConfig16.blng__BooleanValue__c = false;
        billConfig16.blng__Category__c = 'General';  
        billConfig16.blng__FieldType__c = 'Picklist';
        billConfig16.blng__PicklistIndicator__c = 'TaxcCalculationList';
        billConfig16.blng__StringValue__c = 'Order: Account Billing Address';
        billConfig16.blng__Sequence__c = 3;
        listBillingConfig.add(billConfig16);
        
        blng__BillingConfig__c billConfig17 = new blng__BillingConfig__c();
        billConfig17.Name = 'USAGE_RATING_PROCESS';
        billConfig17.blng__BooleanValue__c = false;
        billConfig17.blng__Category__c = 'General';  
        billConfig17.blng__FieldType__c = 'Picklist';
        billConfig17.blng__PicklistIndicator__c = 'UsageRatingProcessList';
        billConfig17.blng__StringValue__c = 'On Trigger';
        billConfig17.blng__Sequence__c = 9;
        listBillingConfig.add(billConfig17);
        insert listBillingConfig;
        
        //Create Billing Prefix Custom Setting 
        blng__BillingPrefix__c billingPrefix = new blng__BillingPrefix__c(SetupOwnerId = UserInfo.getUserId());
        billingPrefix.blng__BarPrefix__c = 'blng__' ;
        billingPrefix.blng__DotPrefix__c = 'blng.';
        billingPrefix.blng__RawPrefix__c = 'blng';
        insert billingPrefix;
        
        sObject sObj = new blng__BillingRule__c();
        sObject sObj1 = new Account();
        sObject sObj2 = new Account();
        
        sObj = new blng__BillingRule__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngBillingRuleData);
        List<blng__BillingRule__c> lBillingRule = (List<blng__BillingRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new blng__RevenueRecognitionRule__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngRevRecRuleData);
        List<blng__RevenueRecognitionRule__c> lRevRecRule = (List<blng__RevenueRecognitionRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new blng__TaxRule__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngTaxRuleData);
        List<blng__TaxRule__c> lTaxRule = (List<blng__TaxRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('Offering_Type__c','Cloud Hosted Subscription');
        sObj = new Product2();        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
        
        UtilityTestData.mProductData.put('Name', 'Intelligent Cloud Data Management for FedRAMP - 120 Informatica Processing Units per consecutive month');
        UtilityTestData.mProductData.put('Product_Family__c', 'IPU');
        UtilityTestData.mProductData.put('ProductCode', 'BACKPOCKET');
        UtilityTestData.mProductData.put('IsActive', 'True');
        UtilityTestData.mProductData.put('Offering_ID__c', 'TEST-OFFERING_ID5');
        UtilityTestData.mProductData.put('Offering_Type__c','Cloud Hosted Subscription');
        sObject sObj4 = new Product2();
        sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mProductData); 
        
        List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj4});
        
        Id pricebookId = Test.getStandardPricebookId(); 
        
        sObj = new Pricebook2(Id = pricebookId,IsActive = True);
        List<Pricebook2> lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        
        sObj = new pricebookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',lPriceBook2[0].Id);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);
        
        List<pricebookEntry> lPriceBookEntry = (List<pricebookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;
        
        sObj = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        
        sObj1 = new Account();
        UtilityTestData.mAccountData.put('Name','Testing');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountData);
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();

        sObj2 = new Account();
        UtilityTestData.mAccountData.put('Name','Testing2');
        UtilityTestData.mAccountData.put('RecordTypeId',devRecordTypeId);
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mAccountData);
        
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
        
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new blng__LegalEntity__c();
        UtilityTestData.mLegalEntityData.put('Name','test');
        UtilityTestData.mLegalEntityData.put('Business_Unit_Code__c','US001');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalEntityData);
        List<blng__LegalEntity__c> lLegalEntity = (List<blng__LegalEntity__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        Test.startTest();
        sObj = new Opportunity();
        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Type','Direct');
        UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
        UtilityTestData.mOpportunityData.put('StageName','Validate');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});      
        
        sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('AccountId',lAccount[0].Id);        
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunity[0].Id);
        UtilityTestData.mSBQuoteData.put('Shipping_Preference__c','Email');
        UtilityTestData.mSBQuoteData.put('SBQQ__BillingName__c','Test user');
        UtilityTestData.mSBQuoteData.put('SBQQ__ShippingName__c','Test user');
        UtilityTestData.mSBQuoteData.put('Shipping_Email__c','test@email.com');
        UtilityTestData.mSBQuoteData.put('SBQQ__ShippingCountry__c','USA');
        UtilityTestData.mSBQuoteData.put('Legal_Entity__c',lLegalEntity[0].Id);
        UtilityTestData.mSBQuoteData.put('PO__c','123213');
        UtilityTestData.mSBQuoteData.put('BillToAccount__c',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('ShiptToAccount__c',lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj}); 
        Test.stopTest();
    }

    @isTest
    static void checkEarlyTerminateTest(){        
        SBQQ__Quote__c quoteRec = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        Product2 prodRec = [SELECT Id FROM Product2 LIMIT 1];
        PriceBookEntry pbe = [SELECT Id FROM PriceBookEntry LIMIT 1];
        Test.startTest();
        sObject sObj = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__ChargeType__c','Recurring');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingFrequency__c','Monthly');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingType__c','Advance');
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',quoteRec.Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',prodRec.Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__PricebookEntryId__c',pbe.Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
        List<SBQQ__QuoteLine__c> lSBQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj});  
        Test.stopTest();
        Boolean res = QuoteBannersController.checkEarlyTerminate(quoteRec.Id);
        System.assertEquals(res,false);
    } 
    
    @isTest
    static void checkStartDate(){
        SBQQ__Quote__c quoteRec = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        quoteRec.SBQQ__StartDate__c = System.Today().addDays(-10);
        update quoteRec;        
        Date res = QuoteBannersController.checkStartDate(quoteRec.Id);
        System.assertEquals(res,System.Today());

        Test.startTest();
        quoteRec.SBQQ__StartDate__c = System.Today().addDays(10);
        update quoteRec;
        res = QuoteBannersController.checkStartDate(quoteRec.Id);
        System.assertEquals(res,quoteRec.SBQQ__StartDate__c);
        Test.stopTest();
    }
    
    @isTest
    static void testCheckParties(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'Testing2' LIMIT 1];
        SBQQ__Quote__c quoteRec = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        quoteRec.BillToAccount__c = acc.Id;
        quoteRec.EndUserAccount__c = acc.Id;
        quoteRec.ShiptToAccount__c = acc.Id;
        quoteRec.SoldToAccount__c = acc.Id;
        update quoteRec;        
        Test.startTest();
        String res = QuoteBannersController.checkParties(quoteRec.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testcheckaccounts(){
        SBQQ__Quote__c quoteRec = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        quoteRec.SBQQ__StartDate__c = System.Today().addDays(-10);
        update quoteRec;        
        Test.startTest();
        Boolean res = QuoteBannersController.checkaccounts(quoteRec.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testcheckOpptyaccounts(){
        Opportunity opptyRec = [SELECT Id FROM Opportunity LIMIT 1];     
        Test.startTest();
        Boolean res = QuoteBannersController.checkOpptyaccounts(opptyRec.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testcheckQuoteLineStartDate(){
        SBQQ__Quote__c quoteRec = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        quoteRec.SBQQ__StartDate__c = System.Today().addDays(-10);
        update quoteRec;        
        Test.startTest();
        Boolean res = QuoteBannersController.checkQuoteLineStartDate(quoteRec.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetQuoteLineItemsStartDate(){
        SBQQ__Quote__c quoteRec = [SELECT Id, SBQQ__StartDate__c FROM SBQQ__Quote__c LIMIT 1];
        Boolean res = QuoteBannersController.getQuoteLineItemsStartDate(quoteRec.Id, quoteRec.SBQQ__StartDate__c);
        System.assertEquals(res,true);
    }
    
      @isTest
    static void checkInactivePBE(){        
        SBQQ__Quote__c quoteRec = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        Product2 prodRec = [SELECT Id FROM Product2 LIMIT 1];
        PriceBookEntry pbe = [SELECT Id FROM PriceBookEntry LIMIT 1];
        Test.startTest();
        sObject sObj = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__ChargeType__c','Recurring');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingFrequency__c','Monthly');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingType__c','Advance');
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',quoteRec.Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',prodRec.Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__PricebookEntryId__c',pbe.Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
        List<SBQQ__QuoteLine__c> lSBQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj}); 
       if(pbe!=null)       
        {
           pbe.IsActive = false;  
             update pbe;
        }               
        Test.stopTest();
        Boolean res = QuoteBannersController.checkInactivePBE(quoteRec.Id);
       system.debug('Result'+res);
    }
    
    @isTest
    static void checkIPUProdsTest() {
        
		User userObj = [select Id, Name from User where Name = 'Deployment master'  and IsActive = true limit 1];
       
        List<Product2> lIpuProduct = [SELECT ID,Forecast_Product__c,Product_Family__c FROM Product2 WHERE Product_Family__c = 'IPU'];
        
        List<Opportunity> lOpportunityRecord = [SELECT Id,Substage__c FROM Opportunity LIMIT 1];

        SBQQ__Quote__c quoteRec = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        System.runAs(userObj) {
            
            Id pbId = Test.getStandardPricebookId(); 
            sObject sObj = new Pricebook2(Id = pbId,IsActive = True);
            List<Pricebook2> lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            
            system.debug('lPriceBook2'+lPriceBook2.size());
            system.debug('lPriceBook2'+lIpuProduct.size());
            
            sObject sObj1 = new PriceBookEntry(UnitPrice=1000, Pricebook2Id = lPriceBook2[0].Id, Product2Id=lIpuProduct[0].Id + '' );
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mPriceBookEntryData);
            
            List<PriceBookEntry> lPriceBookEntry = (List<PriceBookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj1});
            System.assertEquals(lPriceBookEntry.size(),1); 
            
            //update the pricebook on Opty
            sObj = new Opportunity(id = lOpportunityRecord[0].Id, Pricebook2Id = pbId );
            lOpportunityRecord = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            
            String checkFal = QuoteBannersController.checkForIPUProduct(lOpportunityRecord[0].Id);
            System.assertEquals(false,String.isEmpty(checkFal));
            
            test.startTest();
            //Add OLI on Primary Opportunity
            sObject sObjOppLineItem = new OpportunityLineItem();
            UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunityRecord[0].Id);
            UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[0].Id);
            UtilityTestData.mOpportunityProdData.put('Product2Id', lIpuProduct[0].Id);
            UtilityTestData.mOpportunityProdData.put('Transaction_Type__c', 'New');
            UtilityTestData.mOpportunityProdData.put('UnitPrice', '2.00');
            sObjOppLineItem = UtilityTest.putFieldRecord(sObjOppLineItem ,UtilityTestData.mOpportunityProdData);
  			
            
            List<OpportunityLineItem> lstOpportunityLineItem = (List<OpportunityLineItem>) UtilityTest.makeInsert(new List<sObject>{sObjOppLineItem});
            system.assertEquals(lstOpportunityLineItem.size(),1);
            
            String check = QuoteBannersController.checkForIPUProduct(lOpportunityRecord[0].Id);
            System.assertEquals(false,String.isEmpty(check));
            
            QuoteBannersController.getQuoteLineItemsSubTermOutput(quoteRec.Id);
            test.stopTest();
            
        }
    }

    @isTest
    static void testQuoteLineItemsSubTermOutput(){
        SBQQ__Quote__c quoteRec = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];      
        Test.startTest();
        Boolean res = QuoteBannersController.getQuoteLineItemsSubTermOutput(quoteRec.Id);
        Test.stopTest();
    }

    @isTest
    private static void testcheckForIPUProductQuoteOnly(){

        SBQQ__Quote__c quoteRec = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];   
        Test.startTest();
            Boolean result = QuoteBannersController.checkForIPUProductQuoteOnly(quoteRec.Id);
            System.assertEquals(false, result);
        Test.stopTest();   
    }

    @isTest
    private static void testCheckOutOfSync(){

        SBQQ__Quote__c quoteRec = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];      

        Test.startTest();
            Boolean result = QuoteBannersController.checkOutOfSync(quoteRec.Id);
            System.assertEquals(false, result);
        Test.stopTest();
    }
}