/*
Class:          AssociateOrgToAssetTest 
@Author:        Pavithra
@Created Date:  01 December 2020
@Description:   Test class for AssociateOrgToAssetTest

Change History
********************************************************************************************************************************************
ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
********************************************************************************************************************************************
*/

@isTest(seeAllData=false)
public class AssociateOrgToAssetTest {

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
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
        //List<Product2> lstProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj1 = new Product2();
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('SBQQ__AssetConversion__c','One per unit');
        UtilityTestData.mProduct2Data.put('Offering_Type__c','On-Premise Perpetual License');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProduct2Data);
        // List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj1});
        
        sObj2 = new Product2();
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('SBQQ__AssetConversion__c','One per unit');
        //UtilityTestData.mProduct2Data.put('Generates_Entitlement__c','True');
        UtilityTestData.mProduct2Data.put('Offering_Type__c','Cloud Hosted Subscription');
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mProduct2Data);
        List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
        
        Pricebook2 pb = new Pricebook2(Name = 'Test Price Book', Description = 'Price Book 2009 Products', IsActive = true);
        insert pb;
        
        Id pricebookId = pb.Id;
        Id standardPB = Test.getStandardPricebookId();
        
        sObj = new Pricebook2(Id = pricebookId,IsActive = True);
        List<Pricebook2> lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        
        sObj = new pricebookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',standardPB);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);
        
        sObj1 = new pricebookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',standardPB);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[1].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mPriceBookEntryData);
        
        sObj2 = new pricebookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',standardPB);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[2].Id);
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mPriceBookEntryData);
        
        List<pricebookEntry> lStdPriceBookEntry = (List<pricebookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
        
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
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
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

            sObj2 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lProduct2[2].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','1');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','1');
            sObj2 = UtilityTest.putFieldRecord(sObj2,UtilityTestData.mSBQQSubscriptionData);

            List<SBQQ__Subscription__c > lSubscription  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});

            List<Contract> lstContracts = [Select Id,SBQQ__Order__c from Contract];
            AssetCreationBatchHandler.handleAssets(lstContracts[0]);

            //Amend on the NNB/Migrated Contract
            sObj = new SBQQ__Quote__c();
            UtilityTestData.mSBQuoteData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c',System.today()+ '');
            UtilityTestData.mSBQuoteData.put('SBQQ__EndDate__c',System.today().addYears(1)+ '');
            UtilityTestData.mSBQuoteData.put('SBQQ__SubscriptionTerm__c','12');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
            List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});


            sObj = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__PriorQuantity__c','3');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','0');
            UtilityTestData.mQuoteLineData.put('SBQQ__UpgradedSubscription__c',lSubscription[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
            
            sObj1 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[1].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__PriorQuantity__c','6');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','4');
            UtilityTestData.mQuoteLineData.put('SBQQ__UpgradedSubscription__c',lSubscription[1].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
            
            sObj2 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[2].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__PriorQuantity__c','1');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','2');
            UtilityTestData.mQuoteLineData.put('SBQQ__UpgradedSubscription__c',lSubscription[2].Id);
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lSBQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});


            sObj = new OrderItem();
            UtilityTestData.mOrderItemData.put('ServiceDate',System.today()+'');
            UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(1)+'');
            UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',lSBQuoteLine[0].Id);
            UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','-3');
            UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','-3');
            UtilityTestData.mOrderItemData.put('Quantity','-3');
            UtilityTestData.mOrderItemData.put('Product2Id',lProduct2[0].Id);
            UtilityTestData.mOrderItemData.put('OrderId',lOrder[0].Id);
            UtilityTestData.mOrderItemData.put('PricebookEntryId',lPriceBookEntry[0].Id);
            UtilityTestData.mOrderItemData.put('UnitPrice','2000');
            UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today()+'');
            UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131311');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderItemData);

            sObj1 = new OrderItem();
            UtilityTestData.mOrderItemData.put('ServiceDate',System.today()+'');
            UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(1)+'');
            UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',lSBQuoteLine[1].Id);
            UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','-2');
            UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','-2');
            UtilityTestData.mOrderItemData.put('Quantity','-2');
            UtilityTestData.mOrderItemData.put('Product2Id',lProduct2[1].Id);
            UtilityTestData.mOrderItemData.put('OrderId',lOrder[0].Id);
            UtilityTestData.mOrderItemData.put('PricebookEntryId',lPriceBookEntry[1].Id);
            UtilityTestData.mOrderItemData.put('UnitPrice','2000');
            UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today()+'');
            UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131311');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOrderItemData);

            sObj2 = new OrderItem();
            UtilityTestData.mOrderItemData.put('ServiceDate',System.today()+'');
            UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(1)+'');
            UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',lSBQuoteLine[2].Id);
            UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','1');
            UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','1');
            UtilityTestData.mOrderItemData.put('Quantity','1');
            UtilityTestData.mOrderItemData.put('Product2Id',lProduct2[2].Id);
            UtilityTestData.mOrderItemData.put('OrderId',lOrder[0].Id);
            UtilityTestData.mOrderItemData.put('PricebookEntryId',lPriceBookEntry[2].Id);
            UtilityTestData.mOrderItemData.put('UnitPrice','2000');
            UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today()+'');
            UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131311');
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mOrderItemData);

            List<OrderItem> amendedOrderItems = (List<OrderItem>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});


            sObj = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lProduct2[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','-3');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','-3');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lSBQuoteLine[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',amendedOrderItems[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mSBQQSubscriptionData);

            sObj1 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lProduct2[1].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','-2');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','-2');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lSBQuoteLine[1].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',amendedOrderItems[1].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1,UtilityTestData.mSBQQSubscriptionData);

            sObj2 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lProduct2[2].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','1');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','1');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lSBQuoteLine[2].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',amendedOrderItems[2].Id);
            sObj2 = UtilityTest.putFieldRecord(sObj2,UtilityTestData.mSBQQSubscriptionData);

            List<SBQQ__Subscription__c > lamendedSubscriptions  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});

            lOrder[0].Asset_Creation_Status__c='Initiated';
            update lOrder[0];

            AssetCreationBatchHandler.handleAssets(lstContracts[0]);
            
            List<Asset> lstAssets = [Select Id from Asset where Status != 'Cancelled'];
            System.debug('lstAsset.size --> '+lstAssets.size());

            for(Asset a: lstAssets){
                System.debug('asset --> '+a);
            }
        

        Test.stopTest();
        
    }
    

    static testmethod void createdata(){

        sObject sObj;
        sObject sObj1;
        sObject sObj2;
        sObject sObj3;

        List<Account> lAccount = [Select Id from Account];
        List<Pricebook2> lPriceBook2 = [Select Id from Pricebook2];
        List<Product2> lProduct2 = [Select Id from Product2];
        for(Product2 prod :lProduct2){
            prod.License_Generation__c = 'Production';
            prod.License_Screen_Type__c ='Cloud';
        }
        update lProduct2;
        List<pricebookEntry> lPriceBookEntry = [Select Id from pricebookEntry where Pricebook2.IsStandard = false];

        Test.startTest();
    
        sObj = new Order();
        UtilityTestData.mOrderData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOrderData.put('EffectiveDate',System.today()+'');
        UtilityTestData.mOrderData.put('EndDate',System.today().addYears(1)+'');
        UtilityTestData.mOrderData.put('Status','Draft');
        UtilityTestData.mOrderData.put('Asset_Creation_Status__c','Initiated');
        UtilityTestData.mOrderData.put('Pricebook2Id',lPriceBook2[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mOrderData);
        List<Order> lOrder  =  (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObject sObj4 = new OrderItem();
        UtilityTestData.mOrderItemData.put('ServiceDate',System.today()+'');
        UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(1)+'');
        //UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',lSBQuoteLine[0].Id);
        UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','2');
        UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','2');
        UtilityTestData.mOrderItemData.put('Quantity','2');
        UtilityTestData.mOrderItemData.put('Product2Id',lProduct2[0].Id);
        UtilityTestData.mOrderItemData.put('OrderId',lOrder[0].Id);
        UtilityTestData.mOrderItemData.put('PricebookEntryId',lPriceBookEntry[0].Id);
        UtilityTestData.mOrderItemData.put('UnitPrice','2000');
        UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today()+'');
        UtilityTestData.mOrderItemData.put('SBQQ__DefaultSubscriptionTerm__c','12');
        sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mOrderItemData);

        List<OrderItem> amendedOrderItems = (List<OrderItem>) UtilityTest.makeInsert(new List<sObject>{sObj4});
        
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

        sObj2 = new SBQQ__Subscription__c();
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lProduct2[2].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','1');
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','1');
        sObj2 = UtilityTest.putFieldRecord(sObj2,UtilityTestData.mSBQQSubscriptionData);

        List<SBQQ__Subscription__c > lSubscription  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});

        List<Contract> lstContracts = [Select Id,SBQQ__Order__c from Contract];
        AssetCreationBatchHandler.handleAssets(lstContracts[0]);
    
        lOrder[0].status='Activated' ;
        lOrder[0].SBQQ__PriceCalcStatus__c='Completed';
        update lOrder[0];
        
        List<id> orderids = new List<id>();
        orderids.add(lOrder[0].Id);
        
        Org__c org = new Org__c();
        org.Pod_Region__c = 'test';
        org.OrgID__c='123';
        insert org;
        
        Fulfillment__c ff = new Fulfillment__c();
        ff.Active__c = true;
        ff.Order__c =lOrder[0].Id;
        insert ff;
    
        Fulfillment_Line__c ffl = new Fulfillment_Line__c();
        ffl.License_Screen_Type2__c = 'Cloud';
        ffl.License_Generation__c='Production';
           ffl.Fullfillment__c =ff.id;
        ffl.Ship_Date__c=system.today();
        ffl.Org_UUID__c='123';
        ffl.Org__c= org.Id;
        insert ffl;
        
        Related_Fulfillment_Line__c rffl = new Related_Fulfillment_Line__c();
        rffl.Order_Product__c = amendedOrderItems[0].Id;
        rffl.Fullfillment_Line__c = ffl.id;
        insert rffl;
    
    
        List<Asset> lAsset = [Select Id,SBQQ__OrderProduct__c,Product2.License_Screen_Type__c,Product2.License_Generation__c,Org__c from Asset];
        System.assert(lAsset.size()> 0, 'Asset is not created.');   
        
        lAsset[0].Org__c = null;
         lAsset[0].SBQQ__OrderProduct__c = amendedOrderItems[0].Id;
        update lAsset;
        
        System.debug('lAsset'+lAsset);
        AssociateOrgToAsset org2Assets = new AssociateOrgToAsset();
        Database.executeBatch(org2Assets);
        
        Test.stopTest();

}

    static testMethod void handleorgToAssetOptions(){

        sObject sObj;
        sObject sObj1;
        sObject sObj2;
        sObject sObj3;

        List<Account> lAccount = [Select Id from Account];
        List<Pricebook2> lPriceBook2 = [Select Id from Pricebook2];
        List<Product2> lProduct2 = [Select Id from Product2];
        for(Product2 prod :lProduct2){
            prod.License_Generation__c = 'Options';
            prod.License_Screen_Type__c ='Cloud';
        }
        update lProduct2;
        List<pricebookEntry> lPriceBookEntry = [Select Id from pricebookEntry where Pricebook2.IsStandard = false];

        Test.startTest();
        
        sObj = new Entitled_Product__c();
        UtilityTestData.mEntitledProduct.put('Support_Account__c', lAccount[0].Id);
        UtilityTestData.mEntitledProduct.put('Name', 'Axon Data Governance(Hosted Multi Tenant)');
        UtilityTestData.mEntitledProduct.put('Product__c', 'Axon Data Governance');
        UtilityTestData.mEntitledProduct.put('Delivery_Method__c', 'Hosted Multi Tenant');
        UtilityTestData.mEntitledProduct.put('Active__c', 'True');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEntitledProduct);
        
       
        List<Entitled_Product__c> lEntitledProduct = (List<Entitled_Product__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Order();
        UtilityTestData.mOrderData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOrderData.put('EffectiveDate',System.today()+'');
        UtilityTestData.mOrderData.put('EndDate',System.today().addYears(1)+'');
        UtilityTestData.mOrderData.put('Status','Draft');
        UtilityTestData.mOrderData.put('Asset_Creation_Status__c','Initiated');
        UtilityTestData.mOrderData.put('Pricebook2Id',lPriceBook2[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mOrderData);
        List<Order> lOrder  =  (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObject sObj4 = new OrderItem();
        UtilityTestData.mOrderItemData.put('ServiceDate',System.today()+'');
        UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(1)+'');
        //UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',lSBQuoteLine[0].Id);
        UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','2');
        UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','2');
        UtilityTestData.mOrderItemData.put('Quantity','2');
        UtilityTestData.mOrderItemData.put('Product2Id',lProduct2[0].Id);
        UtilityTestData.mOrderItemData.put('OrderId',lOrder[0].Id);
        UtilityTestData.mOrderItemData.put('PricebookEntryId',lPriceBookEntry[0].Id);
        UtilityTestData.mOrderItemData.put('UnitPrice','2000');
        UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today()+'');
        UtilityTestData.mOrderItemData.put('SBQQ__DefaultSubscriptionTerm__c','12');
        sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mOrderItemData);

        List<OrderItem> amendedOrderItems = (List<OrderItem>) UtilityTest.makeInsert(new List<sObject>{sObj4});

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

        sObj2 = new SBQQ__Subscription__c();
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lProduct2[2].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','1');
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','1');
        sObj2 = UtilityTest.putFieldRecord(sObj2,UtilityTestData.mSBQQSubscriptionData);

        List<SBQQ__Subscription__c > lSubscription  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});

        List<Contract> lstContracts = [Select Id,SBQQ__Order__c from Contract];
        AssetCreationBatchHandler.handleAssets(lstContracts[0]);
    
        lOrder[0].status='Activated' ;
        lOrder[0].SBQQ__PriceCalcStatus__c='Completed';
        update lOrder[0];
        
        List<id> orderids = new List<id>();
        orderids.add(lOrder[0].Id);
        
        Fulfillment__c ff = new Fulfillment__c();
        ff.Active__c = true;
        ff.Order__c =lOrder[0].Id;
        insert ff;
    
        Fulfillment_Line__c ffl = new Fulfillment_Line__c();
        ffl.License_Screen_Type2__c = 'Cloud';
        ffl.License_Generation__c='Production';
           ffl.Fullfillment__c =ff.id;
        ffl.Ship_Date__c=system.today();
        ffl.Org_UUID__c='123';
        insert ffl;
        
        Related_Fulfillment_Line__c rffl = new Related_Fulfillment_Line__c();
        rffl.Order_Product__c = amendedOrderItems[0].Id;
        rffl.Fullfillment_Line__c = ffl.id;
        insert rffl;
    
        Org__c org = new Org__c();
        org.Pod_Region__c = 'test';
        org.OrgID__c='123';
        insert org;
        
        Org_Contract__c orgCon = new Org_Contract__c();
        orgCon.Org__c =org.id;
        orgCon.Contract__c =lContract[0].Id;
        orgCon.Status__c = 'Active';
        insert orgCon;
    
        List<Asset> lAsset = [Select Id,SBQQ__OrderProduct__c,Product2.License_Screen_Type__c,Product2.License_Generation__c,Org__c from Asset];
        System.assert(lAsset.size()> 0, 'Asset is not created.');   
        
        lAsset[0].Org__c = null;
        lAsset[0].SBQQ__OrderProduct__c = amendedOrderItems[0].Id;//lEntitledProduct
        lAsset[0].Entitled_Product__c = lEntitledProduct[0].Id;
        update lAsset;
        System.debug('lAsset'+lAsset);
        
        AssociateOrgToAsset org2Assets = new AssociateOrgToAsset();
        Database.executeBatch(org2Assets);
    
        Test.stopTest();

    }

    static testMethod void handleEntitleProducts(){

        sObject sObj;
        sObject sObj1;
        sObject sObj2;
        sObject sObj3;

        List<Account> lAccount = [Select Id from Account];
        List<Pricebook2> lPriceBook2 = [Select Id from Pricebook2];
        List<Product2> lProduct2 = [Select Id from Product2];
        for(Product2 prod :lProduct2){
            prod.License_Generation__c = 'Options';
            prod.License_Screen_Type__c ='Cloud';
        }
        update lProduct2;
        List<pricebookEntry> lPriceBookEntry = [Select Id from pricebookEntry where Pricebook2.IsStandard = false];

        Test.startTest();
        
        sObj = new Entitled_Product__c();
        UtilityTestData.mEntitledProduct.put('Support_Account__c', lAccount[0].Id);
        UtilityTestData.mEntitledProduct.put('Name', 'Axon Data Governance(Hosted Multi Tenant)');
        UtilityTestData.mEntitledProduct.put('Product__c', 'Axon Data Governance');
        UtilityTestData.mEntitledProduct.put('Delivery_Method__c', 'Hosted Multi Tenant');
        UtilityTestData.mEntitledProduct.put('Active__c', 'True');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEntitledProduct);
        
        List<Entitled_Product__c> lEntitledProduct = (List<Entitled_Product__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Order();
        UtilityTestData.mOrderData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOrderData.put('EffectiveDate',System.today()+'');
        UtilityTestData.mOrderData.put('EndDate',System.today().addYears(1)+'');
        UtilityTestData.mOrderData.put('Status','Draft');
        UtilityTestData.mOrderData.put('Asset_Creation_Status__c','Initiated');
        UtilityTestData.mOrderData.put('Pricebook2Id',lPriceBook2[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mOrderData);
        List<Order> lOrder  =  (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObject sObj4 = new OrderItem();
        UtilityTestData.mOrderItemData.put('ServiceDate',System.today()+'');
        UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(1)+'');
        UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','2');
        UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','2');
        UtilityTestData.mOrderItemData.put('Quantity','2');
        UtilityTestData.mOrderItemData.put('Product2Id',lProduct2[0].Id);
        UtilityTestData.mOrderItemData.put('OrderId',lOrder[0].Id);
        UtilityTestData.mOrderItemData.put('PricebookEntryId',lPriceBookEntry[0].Id);
        UtilityTestData.mOrderItemData.put('UnitPrice','2000');
        UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today()+'');
        UtilityTestData.mOrderItemData.put('SBQQ__DefaultSubscriptionTerm__c','12');
        sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mOrderItemData);
        List<OrderItem> amendedOrderItems = (List<OrderItem>) UtilityTest.makeInsert(new List<sObject>{sObj4});
        
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

        sObj2 = new SBQQ__Subscription__c();
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lProduct2[2].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','1');
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','1');
        sObj2 = UtilityTest.putFieldRecord(sObj2,UtilityTestData.mSBQQSubscriptionData);

        List<SBQQ__Subscription__c > lSubscription  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});

        List<Contract> lstContracts = [Select Id,SBQQ__Order__c from Contract];
        AssetCreationBatchHandler.handleAssets(lstContracts[0]);
    
        lOrder[0].status='Activated' ;
        lOrder[0].SBQQ__PriceCalcStatus__c='Completed';
        update lOrder[0];
        
        List<id> orderids = new List<id>();
        orderids.add(lOrder[0].Id);
        
        Fulfillment__c ff = new Fulfillment__c();
        ff.Active__c = true;
        ff.Order__c =lOrder[0].Id;
        insert ff;
    
        Fulfillment_Line__c ffl = new Fulfillment_Line__c();
        ffl.License_Screen_Type2__c = 'Cloud';
        ffl.License_Generation__c='Production';
        ffl.Fullfillment__c =ff.id;
        ffl.Ship_Date__c=system.today();
        ffl.Org_UUID__c='123';
        insert ffl;
        
        Related_Fulfillment_Line__c rffl = new Related_Fulfillment_Line__c();
        rffl.Order_Product__c = amendedOrderItems[0].Id;
        rffl.Fullfillment_Line__c = ffl.id;
        insert rffl;
    
        Org__c org = new Org__c();
        org.Pod_Region__c = 'test';
        org.OrgID__c='123';
        insert org;
        
        Org_Contract__c orgCon = new Org_Contract__c();
        orgCon.Org__c =org.id;
        orgCon.Contract__c =lContract[0].Id;
        orgCon.Status__c = 'Active';
        insert orgCon;
    
        List<Asset> lAsset = [Select Id,SBQQ__OrderProduct__c,Product2.License_Screen_Type__c,Product2.License_Generation__c,Org__c from Asset];
        System.assert(lAsset.size()> 0, 'Asset is not created.');   
        
        lAsset[0].Org__c = org.Id;
        lAsset[0].SBQQ__OrderProduct__c = amendedOrderItems[0].Id;//lEntitledProduct
        lAsset[0].Entitled_Product__c = lEntitledProduct[0].Id;
        update lAsset;
        
        AssociateOrgToAsset org2Assets = new AssociateOrgToAsset();
        Database.executeBatch(org2Assets);
    
        Test.stopTest();

    }
    
    static testMethod void testSchedule(){
        Test.StartTest();
        
        String sch = '0 0 23 * * ?'; 
        AssociateOrgToAssetSchedulable sh2 = new AssociateOrgToAssetSchedulable();
        system.schedule('Test Org to Asset scheduler', sch, sh2); 
        
        Test.StopTest();
    }
}