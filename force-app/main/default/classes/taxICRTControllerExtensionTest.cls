///taxICRTControllerExtensionTest
@isTest
public class taxICRTControllerExtensionTest {
    @testSetup
    static void setupObjectTestData() {
        
        User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1];
        
        system.runAs(adminUser){
            
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
            UtilityTestData.mProduct2Data.put('Pricing_Business_Model__c','Subscription');
            UtilityTestData.mProduct2Data.put('Forecast_Product__c','Data Quality');
            UtilityTestData.mProduct2Data.put('Delivery_Method__c','Hosted Multi Tenant');
            UtilityTestData.mProduct2Data.put('Offering_Type__c','Cloud Hosted Subscription');
            UtilityTestData.mProduct2Data.put('Tax_Product_Type__c','Services');
            UtilityTestData.mProduct2Data.put('SBQQ__SubscriptionTerm__c','12');
            UtilityTestData.mProduct2Data.put('Business_Unit__c','Big Data');
            sObj = new Product2();        
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
            
            sObj1 = new Product2();
            UtilityTestData.mProduct2Data.put('Name','Test');
            
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProduct2Data);
            List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
            Id pricebookId = Test.getStandardPricebookId(); 
            
            sObj = new Pricebook2(Id = pricebookId,IsActive = True);
            List<Pricebook2> lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            
            sObj = new pricebookEntry();
            UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',lPriceBook2[0].Id);
            UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);
            
            sObj1 = new pricebookEntry();
            UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',lPriceBook2[0].Id);
            UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[1].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mPriceBookEntryData);
            
            List<pricebookEntry> lPriceBookEntry = (List<pricebookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
            User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
            settings.Ignore_Validation_Rules__c = true;
            upsert settings User_Exemptions__c.Id;
            
            sObj = new ERP_Company__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mERPCompany);            
            List<ERP_Company__c> lErpCompany = (List<ERP_Company__c>) UtilityTest.makeInsert(new List<sObject>{sObj});            
            
            sObj = new Account();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            
            sObj1 = new Account();
            UtilityTestData.mAccountData.put('ERP_Company__c',lErpCompany[0].Id);
            UtilityTestData.mAccountData.put('Name','Testing');
            UtilityTestData.mAccountData.put('BillingCountry','USA');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountData);
            
            List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
            sObj = new Contact();
            UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mContactData.put('MailingCountry','USA');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new Opportunity();
            UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('Type','Direct');
            UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
            UtilityTestData.mOpportunityData.put('StageName','Validate');
            UtilityTestData.mOpportunityData.put('Name','OrderTriggerHandler');
            UtilityTestData.mOpportunityData.put('Pricebook2Id',lPriceBook2[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunity[0].Id);
            UtilityTestData.mOpportunityContactRoleData.put('ContactId',lContact[0].Id);
            UtilityTestData.mOpportunityContactRoleData.put('Role', 'End User');
            sObj1 = new OpportunityContactRole();
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityContactRoleData);
            
            List<OpportunityContactRole> lContactRoles = (List<OpportunityContactRole>) UtilityTest.makeInsert(new List<sObject>{sObj1});
            
            sObj = new blng__LegalEntity__c();
            UtilityTestData.mLegalEntityData.put('Name','test Legal Entity');
            UtilityTestData.mLegalEntityData.put('Business_Unit_Code__c','US001');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalEntityData);
            List<blng__LegalEntity__c> lLegalEntity = (List<blng__LegalEntity__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            
            sObj = new SBQQ__Quote__c();
            UtilityTestData.mSBQuoteData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunity[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__PriceBook__c',lPriceBook2[0].Id);
            UtilityTestData.mSBQuoteData.put('Price_Book_2__c',lPriceBook2[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__PricebookId__c',lPriceBook2[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__PriceBook__c',lPriceBook2[0].Id);
            UtilityTestData.mSBQuoteData.put('Legal_Entity__c',lLegalEntity[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c',System.today()+'');
            UtilityTestData.mSBQuoteData.put('SBQQ__EndDate__c',System.today().addMonths(12)+'');
            UtilityTestData.mSBQuoteData.put('Shipping_Preference__c','Email');
            UtilityTestData.mSBQuoteData.put('SBQQ__BillingName__c','Test user');
            UtilityTestData.mSBQuoteData.put('SBQQ__ShippingName__c','Test user');
            UtilityTestData.mSBQuoteData.put('SBQQ__ShippingCountry__c','USA');
            UtilityTestData.mSBQuoteData.put('Shipping_Email__c','test@email.com');
            UtilityTestData.mSBQuoteData.put('PO__c','123213');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
            List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});           
            
            sObj = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__PricebookEntryId__c',lPriceBookEntry[0].Id);
            UtilityTestData.mQuoteLineData.put('Purchase_Order_PO_Number__c','111111111');
            UtilityTestData.mQuoteLineData.put('SBQQ__ListPrice__c','100');
            UtilityTestData.mQuoteLineData.put('SBQQ__NetPrice__c','100');
            UtilityTestData.mQuoteLineData.put('SBQQ__Number__c','1');
            UtilityTestData.mQuoteLineData.put('SBQQ__ChargeType__c','Recurring');
            UtilityTestData.mQuoteLineData.put('SBQQ__BillingType__c','Advance');
            UtilityTestData.mQuoteLineData.put('Transaction_Type__c','New');
            UtilityTestData.mQuoteLineData.put('SBQQ__BillingFrequency__c','Invoice Plan');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
            
            Test.startTest();
            List<SBQQ__QuoteLine__c> lSBQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            Test.stopTest();
        }
    } 
    
	@isTest
    static void testMethod1(){
        SBQQ__Quote__c quoteRec = [SELECT Id,SBQQ__ShippingCountry__c,Business_Unit__c FROM SBQQ__Quote__c LIMIT 1]; 
        
        ApexPages.StandardController sc = new ApexPages.StandardController(quoteRec);
        taxICRTControllerExtension testTaxPage = new taxICRTControllerExtension(sc);        
        PageReference pageRef = new pageReference('/apex/UpdateTaxIcrt');
        pageRef.getParameters().put('id', String.valueOf(quoteRec.Id));
        Test.setCurrentPage(pageRef);
        
        Test.StartTest();
        testTaxPage.updateQuote();  
        quoteRec = [SELECT Id,Tax_Update_Status__c FROM SBQQ__Quote__c LIMIT 1];
        System.assertEquals('Running', quoteRec.Tax_Update_Status__c);        
        Test.StopTest();
        /*
        testTaxPage.getTaxStatus();  
        quoteRec = [SELECT Id,Tax_Update_Status__c FROM SBQQ__Quote__c LIMIT 1];
        System.assertEquals(false, testTaxPage.renderButtons); 
        quoteRec.Tax_Update_Status__c = 'Failed';
        update quoteRec;
        testTaxPage.getTaxStatus();
        System.assertEquals(true, testTaxPage.renderButtons);
        
        PageReference returnPage = testTaxPage.onReturnToQuote();  
        returnPage = testTaxPage.fromGenerateDocumentQuoteVF();
        System.assertEquals(new pageReference('/apex/UpdateTaxIcrt').getUrl(), returnPage.getUrl());
        returnPage = testTaxPage.fromGeneratePartnerDocumentQuoteVF();
        System.assertEquals(new pageReference('/apex/UpdateTaxIcrt').getUrl(), returnPage.getUrl()); 
        
        quoteRec.SBQQ__ShippingCountry__c = 'India';
        update quoteRec; 
        sc = new ApexPages.StandardController(quoteRec);
        testTaxPage = new taxICRTControllerExtension(sc);        
        returnPage = testTaxPage.fromGenerateDocumentQuoteVF();
        System.assertEquals(null, returnPage);
        returnPage = testTaxPage.fromGeneratePartnerDocumentQuoteVF();
        System.assertEquals(null, returnPage);   */     
    } 
    
	@isTest
    static void testMethod2(){
        SBQQ__Quote__c quoteRec = [SELECT Id,SBQQ__ShippingCountry__c,Business_Unit__c FROM SBQQ__Quote__c LIMIT 1]; 
        
        ApexPages.StandardController sc = new ApexPages.StandardController(quoteRec);
        taxICRTControllerExtension testTaxPage = new taxICRTControllerExtension(sc);        
        PageReference pageRef = new pageReference('/apex/UpdateTaxIcrt');
        pageRef.getParameters().put('id', String.valueOf(quoteRec.Id));
        Test.setCurrentPage(pageRef);
        Test.startTest();
        testTaxPage.updateQuote();  
        
        quoteRec = [SELECT Id,Tax_Update_Status__c FROM SBQQ__Quote__c LIMIT 1];
        System.assertEquals(false, testTaxPage.renderButtons); 
        quoteRec.Tax_Update_Status__c = 'Failed';
        update quoteRec;
        testTaxPage.getTaxStatus();
        System.assertEquals(true, testTaxPage.renderButtons);
        Test.stopTest();
    }
    
    @isTest
	static void testMethod3(){
        SBQQ__Quote__c quoteRec = [SELECT Id,SBQQ__ShippingCountry__c,Business_Unit__c FROM SBQQ__Quote__c LIMIT 1]; 
    
        ApexPages.StandardController sc = new ApexPages.StandardController(quoteRec);
        taxICRTControllerExtension testTaxPage = new taxICRTControllerExtension(sc);        
        PageReference pageRef = new pageReference('/apex/UpdateTaxIcrt');
        pageRef.getParameters().put('id', String.valueOf(quoteRec.Id));
        Test.setCurrentPage(pageRef);
        test.startTest();
        testTaxPage.updateQuote(); 
        
        
        PageReference returnPage = testTaxPage.onReturnToQuote();  
        returnPage = testTaxPage.fromGenerateDocumentQuoteVF();
        System.assertEquals(new pageReference('/apex/UpdateTaxIcrt').getUrl(), returnPage.getUrl());
        returnPage = testTaxPage.fromGeneratePartnerDocumentQuoteVF();
        System.assertEquals(new pageReference('/apex/UpdateTaxIcrt').getUrl(), returnPage.getUrl()); 
        
        quoteRec.SBQQ__ShippingCountry__c = 'India';
        update quoteRec; 
        sc = new ApexPages.StandardController(quoteRec);
        testTaxPage = new taxICRTControllerExtension(sc);        
        returnPage = testTaxPage.fromGenerateDocumentQuoteVF();
        System.assertEquals(null, returnPage);
        returnPage = testTaxPage.fromGeneratePartnerDocumentQuoteVF();
        System.assertEquals(null, returnPage); 
        
        test.stopTest();
    }
	
    @isTest
	static void testMethod4(){
        globalApexManager.avoidRecursion('OpportunityBeforeUpdate');
        globalApexManager.avoidRecursion('OpportunityAfterUpdate');
        globalApexManager.avoidRecursion('OpportunityLineItemAfterUpdate');
        
        SBQQ__QuoteLine__c lSBQuoteLine = [SELECT Id,SBQQ__Quote__c,SBQQ__ListPrice__c FROM SBQQ__QuoteLine__c LIMIT 1];
        lSBQuoteLine.SBQQ__ListPrice__c = 0;
        update lSBQuoteLine;
        SBQQ__Quote__c quoteRec = [SELECT Id,SBQQ__ShippingCountry__c,Business_Unit__c FROM SBQQ__Quote__c LIMIT 1]; 
        ApexPages.StandardController sc = new ApexPages.StandardController(quoteRec);
        taxICRTControllerExtension testTaxPage = new taxICRTControllerExtension(sc);        
        PageReference pageRef = new pageReference('/apex/UpdateTaxIcrt');
        pageRef.getParameters().put('id', String.valueOf(quoteRec.Id));
        Test.setCurrentPage(pageRef);
        test.startTest();
        testTaxPage.updateQuote(); 
        test.stopTest();        
    }
	
    @isTest
	static void testMethod5(){
        SBQQ__Quote__c quoteRec = [SELECT Id,SBQQ__ShippingCountry__c FROM SBQQ__Quote__c LIMIT 1]; 
        ApexPages.StandardController sc = new ApexPages.StandardController(quoteRec);
        taxICRTControllerExtension testTaxPage = new taxICRTControllerExtension(sc);        
        test.startTest(); 
        System.assertEquals('True', taxICRTControllerExtension.CheckTaxApplicableAndErrorMessage(quoteRec.Id));
        test.stopTest();        
    }
}