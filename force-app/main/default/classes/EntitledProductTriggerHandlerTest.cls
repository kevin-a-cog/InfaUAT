/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-20-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 
 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.            Description                 Tag
 **********************************************************************************************************
 NA                     NA              UTOPIA              Initial version.            NA
 Vignesh Divakaran      16/12/2021      I2RT-4972           Increase code coverage      T01
*/
@isTest(seeAllData=false)

public  class EntitledProductTriggerHandlerTest {
    

    @testSetup
    static void setupObjectTestData() {
        sObject sObj = new blng__BillingRule__c();
        sObject sObj1 = new blng__BillingRule__c();
        sObject sObj2 = new blng__BillingRule__c();
        
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
        
        sObj = new blng__LegalEntity__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalEntityData);
        List<blng__LegalEntity__c> lLegalEntity = (List<blng__LegalEntity__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
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
        UtilityTestData.mProduct2Data.put('SBQQ__AssetConversion__c','One per quote line');
        UtilityTestData.mProduct2Data.put('Offering_Type__c','Cloud Hosted Subscription');
        UtilityTestData.mProduct2Data.put('Name','Test Cloud Product');
        UtilityTestData.mProduct2Data.put('Forecast_Product__c','Cloud Data Integration');
        UtilityTestData.mProduct2Data.put('Pricing_Business_Model__c','Subscription');
        UtilityTestData.mProduct2Data.put('Delivery_Method__c','Hosted Multi Tenant');
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
        //List<Product2> lstProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj1 = new Product2();
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('SBQQ__AssetConversion__c','One per unit');
        UtilityTestData.mProduct2Data.put('Offering_Type__c','On-Premise Perpetual License');
        UtilityTestData.mProduct2Data.put('Name','Test License Product');
        UtilityTestData.mProduct2Data.put('Forecast_Product__c','Axon Data Governance');
        UtilityTestData.mProduct2Data.put('Pricing_Business_Model__c','Perpetual');
        UtilityTestData.mProduct2Data.put('Delivery_Method__c','On Premise');
        UtilityTestData.mProduct2Data.put('Option_Scale__c','ELA Basket');

        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProduct2Data);
        // List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj1});
        
        sObj2 = new Product2();
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
        //UtilityTestData.mProduct2Data.put('SBQQ__AssetConversion__c','One per unit');
        UtilityTestData.mProduct2Data.put('Generates_Entitlement__c','True');
        UtilityTestData.mProduct2Data.put('Offering_Type__c','Cloud Hosted Subscription');
        UtilityTestData.mProduct2Data.put('Name','Test Support Product');
        UtilityTestData.mProduct2Data.put('Forecast_Product__c','Support');
        UtilityTestData.mProduct2Data.put('Pricing_Business_Model__c','Subscription');
        UtilityTestData.mProduct2Data.put('Delivery_Method__c','NA');
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mProduct2Data);
        List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
        

        Product2 ELAProduct= [Select Id from Product2 where Option_Scale__c ='ELA Basket' limit 1];
        sObj = new Service_BOM__c();
        UtilityTestData.mServiceBOM.put('Product__c',ELAProduct.Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mserviceBOM);
        List<Service_BOM__c> lserviceBoms = (List<Service_BOM__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
       
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
        
        sObj2 = new pricebookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',lPriceBook2[0].Id);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[2].Id);
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mPriceBookEntryData);
        
        List<pricebookEntry> lPriceBookEntry = (List<pricebookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
        
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;
        
        sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
        UtilityTestData.mAccountData.put('Signature_Success__c', 'true');
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mContactData.put('MailingCountry', 'USA');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        sObj = new Opportunity();
        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Type','Direct');
        UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
        UtilityTestData.mOpportunityData.put('StageName','Closed Won');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        lOpportunity[0].Pricebook2Id = priceBookId;
        update lOpportunity[0];
        
        Test.startTest();

        sObj = new Order();
        UtilityTestData.mOrderData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOrderData.put('EffectiveDate',System.today()+'');
        UtilityTestData.mOrderData.put('EndDate',System.today().addYears(1)+'');
        UtilityTestData.mOrderData.put('Status','Draft');
        UtilityTestData.mOrderData.put('Asset_Creation_Status__c','Initiated');
        UtilityTestData.mOrderData.put('Pricebook2Id',lPriceBook2[0].Id);

        //---------------------------------------<T01>----------------------------
        UtilityTestData.mOrderData.put('SoldToAccount__c',lAccount[0].Id);
        UtilityTestData.mOrderData.put('SoldToContact__c',lContact[0].Id);
        UtilityTestData.mOrderData.put('EndUserAccount__c',lAccount[0].Id);
        UtilityTestData.mOrderData.put('EndUserContact__c',lContact[0].Id);
        UtilityTestData.mOrderData.put('ShipToAccount__c',lAccount[0].Id);
        UtilityTestData.mOrderData.put('ShipToContactId',lContact[0].Id);
        UtilityTestData.mOrderData.put('BilltoAccount__c',lAccount[0].Id);
        UtilityTestData.mOrderData.put('BillToContactId',lContact[0].Id);
        //---------------------------------------</T01>----------------------------
        
        sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mOrderData);
            List<Order> lOrder  =  (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Contract(StartDate = System.Today().addDays(-300));
            UtilityTestData.mContractData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mContractData.put('StartDate', System.today()+'');
            UtilityTestData.mContractData.put('EndDate',System.today().addYears(1)+'');
            UtilityTestData.mContractData.put('ContractTerm','12');
            UtilityTestData.mContractData.put('BillingStreet','Test Street');
            UtilityTestData.mContractData.put('BillingCity','Test City');
            UtilityTestData.mContractData.put('BillingState','Test State');
            UtilityTestData.mContractData.put('BillingPostalCode','98714-4927');
            UtilityTestData.mContractData.put('BillingCountry','Test Country');
            UtilityTestData.mContractData.put('ShippingStreet','Test Street');
            UtilityTestData.mContractData.put('ShippingCity','Test City');
            UtilityTestData.mContractData.put('ShippingState','Test State');
            UtilityTestData.mContractData.put('ShippingPostalCode','98714-4927');
            UtilityTestData.mContractData.put('ShippingCountry','Test Country');
            UtilityTestData.mContractData.put('SBQQ__Order__c',lOrder[0].Id);
            //UtilityTestData.mContractData.put('SBQQ__Quote__c',lQuote[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mContractData);
            List<Contract> lContract  =  (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lProduct2[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','3');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','3');
            sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mSBQQSubscriptionData);

            sObj1 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lProduct2[1].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','6');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','6');
            sObj1 = UtilityTest.putFieldRecord(sObj1,UtilityTestData.mSBQQSubscriptionData);

            List<SBQQ__Subscription__c > lSubscription  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});

            sObj2 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lProduct2[2].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','1');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','1');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RequiredById__c',lSubscription[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RootId__c',lSubscription[0].Id);
            sObj2 = UtilityTest.putFieldRecord(sObj2,UtilityTestData.mSBQQSubscriptionData);

            List<SBQQ__Subscription__c > lSubscription2  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj2});

            List<Contract> lstContracts = [Select Id,SBQQ__Order__c from Contract];

            AssetCreationBatchHandler.handleAssets(lstContracts[0]);
            
            String query = 'SELECT Id,AccountId,Product2.Edition__c,SBQQ__CurrentSubscription__r.SBQQ__Contract__r.Business_Model__c,Support_Account__c,Account.Name,Account.BillingCountry,Account.BillingState,Account.BillingStreet,Account.BillingCity, Account.CurrencyIsoCode,AssetServicedById,Product2Id,SBQQ__CurrentSubscription__c,SBQQ__CurrentSubscription__r.SBQQ__Contract__r.SBQQ__Order__c,SBQQ__CurrentSubscription__r.SBQQ__Contract__r.SBQQ__Order__r.EndUserContact__c,SBQQ__CurrentSubscription__r.SBQQ__Contract__c,SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c, SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c,SBQQ__SubscriptionStartDate__c,SBQQ__SubscriptionEndDate__c,Entitled_Product__c,SBQQ__CurrentSubscription__r.SBQQ__Contract__r.SBQQ__Order__r.ShipToContactId from Asset where (Entitled_Product__c=null or Support_Account__c = null) and Product2Id!=null and (SBQQ__SubscriptionEndDate__c >= TODAY OR SBQQ__SubscriptionEndDate__c = null) and CreatedDate = LAST_N_DAYS:1 order by SBQQ__CurrentSubscription__r.SBQQ__Contract__c ';

            List<Asset> lstAssets = Database.query(query); 
            System.debug('lstAsset.size --> '+lstAssets.size());
        
            CreateSupportAccountBatchHandler.CreateSupportAccounts (lstAssets);           
            
            Test.stopTest();
        
    }
    

    
    static testmethod void createSignatureSupport(){

        List<Account> lstSupportAccounts = [Select id,parentId from account where recordtype.name ='Support Account'];
        System.debug('lstSupportAccounts.size --> '+lstSupportAccounts.size());

        List<Entitled_Product__c> lstEntitledProducts = [Select id,support_level__c from Entitled_Product__c ];
        System.debug('lstEntitledProducts.size --> '+lstEntitledProducts.size());


        Test.startTest();

        Account custAcc = new Account(id =lstSupportAccounts[0].ParentId , Signature_Success__c = false );
        update custAcc;


        Test.stopTest();
    }


    
    static testmethod void testExtendSupport(){



        List<Account> lstSupportAccounts = [Select id,parentId from account where recordtype.name ='Support Account'];
        System.debug('lstSupportAccounts.size --> '+lstSupportAccounts?.size());

      
        Test.startTest();

        Entitled_Product__c EP = new Entitled_Product__c();
        EP.Forecast_Product__c= 'Axon Data Governance';
        EP.Delivery_Method__c= 'On Premise';
        EP.Support_Account__c= lstSupportAccounts[0].Id;
        EP.Account__c =lstSupportAccounts[0].ParentId;
        EP.Support_Level__c ='Premium Success';
        EP.Manual_Creation_Override__c = true;
        EP.End_Date__c = System.today()+100;
        Insert EP;


        List<Entitled_Product__c> lstEntitledProducts = [Select id,Override_Entitlement_Date__c,End_Date__c,support_level__c from Entitled_Product__c where Manual_Creation_Override__c=true ];
        System.debug('lstEntitledProducts.size --> '+lstEntitledProducts?.size());

        Entitled_Product__c updateEP = new Entitled_Product__c(Id=lstEntitledProducts[0].id);
        updateEP.Override_Entitlement_Date__c= true;
        updateEP.End_Date__c = lstEntitledProducts[0].End_Date__c+ 120;
        system.debug('updateEP'+updateEP);
        update updateEP;

        Test.stopTest();
    }

     static testmethod void testTempSupportExtension(){


        List<Account> lstSupportAccounts = [Select id,parentId from account where recordtype.name ='Support Account'];
        System.debug('lstSupportAccounts.size --> '+lstSupportAccounts?.size());

      
        Test.startTest();

        Entitled_Product__c EP = new Entitled_Product__c();
        EP.Forecast_Product__c= 'Axon Data Governance';
        EP.Delivery_Method__c= 'On Premise';
        EP.Support_Account__c= lstSupportAccounts[0].Id;
        EP.Account__c =lstSupportAccounts[0].ParentId;
        EP.Support_Level__c ='Premium Success';
        EP.Manual_Creation_Override__c = true;
        EP.End_Date__c = System.today()+100;
        Insert EP;


        List<Entitled_Product__c> lstEntitledProducts = [Select id,Override_Entitlement_Date__c,End_Date__c,support_level__c from Entitled_Product__c where Manual_Creation_Override__c=true ];
        System.debug('lstEntitledProducts.size --> '+lstEntitledProducts?.size());

        Entitled_Product__c updateEP = new Entitled_Product__c(Id=lstEntitledProducts[0].id);
        updateEP.Manual_Creation_Override__c= true;
        updateEP.End_Date__c = lstEntitledProducts[0].End_Date__c+ 120;
        system.debug('updateEP'+updateEP);
        update updateEP;

        Test.stopTest();
    }

 
}