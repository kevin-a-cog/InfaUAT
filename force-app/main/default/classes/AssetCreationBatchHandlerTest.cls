/*
Class:          AssetCreationBatchHandlerTest 
@Author:        Vignesh D
@Created Date:  25 September 2020
@Description:   Test class for AssetCreationBatchHandler
Change History
********************************************************************************************************************************************
ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
********************************************************************************************************************************************
Pavithra V       18-11-2020     F2A-316          NA             Test class for error in Migrated contracts                   <T01>
*/
@isTest(seeAllData=false)
public with sharing class AssetCreationBatchHandlerTest {
    
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
        
        /*  
        sObj1 = new Product2(ID = lProduct2[0].Id, Tax_Product_Type__c = null);
        lProduct2 = (List<Product2>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
        */
        
        Id pricebookId = Test.getStandardPricebookId();         
        
        sObj = new Pricebook2(Id = pricebookId,IsActive = True);
        //sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPricebook2Data);
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
        /*
        sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[0].Id + '');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj1 = new SBQQ__Quote__c(Id = lSBQuote[0].Id ,SBQQ__Status__c = 'Approved', ApprovalStatus__c='Approved',SBQQ__Account__c=lAccount[0].Id, ShiptToAccount__c=lAccount[0].Id, BillToAccount__c=lAccount[0].Id, EndUserAccount__c=lAccount[0].Id, SoldToAccount__c=lAccount[0].Id, EndUserContact__c=lContact[0].Id, BillToContact__c=lContact[0].Id, ShipToContact__c=lContact[0].Id, SoldToContact__c=lContact[0].Id,SBQQ__StartDate__c=system.today(),SBQQ__SubscriptionTerm__c=12); //<T1> Last two arguments);
        
        List<SBQQ__Quote__c> lQuoteUpdated = (List<SBQQ__Quote__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
        system.assertEquals(lQuoteUpdated.size(),1);
        
        sObj = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuoteUpdated[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[0].Id);
        UtilityTestData.mQuoteLineData.put('Purchase_Order_PO_Number__c','1');
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
        
        sObj1 = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuoteUpdated[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[1].Id);
        UtilityTestData.mQuoteLineData.put('Purchase_Order_PO_Number__c','1');
        
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
        
        sObj2 = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuoteUpdated[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[2].Id);
        UtilityTestData.mQuoteLineData.put('Purchase_Order_PO_Number__c','1');
        UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','2');
        
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);
        
        List<SBQQ__QuoteLine__c> lSBQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
        */
        
        /*
        lQuoteUpdated[0].SBQQ__Ordered__c = True;
        update lQuoteUpdated[0];
        List<Order> lstOrders = [Select Id,EffectiveDate,EndDate from Order];
        System.debug('order --> '+lstOrders[0]);
        System.assert(lstOrders.size()>0, 'Order not created');
        
        List<OrderItem> orderProducts = [Select Id,ServiceDate,EndDate,Ship_Date__c  from OrderItem where OrderId=:lstOrders[0].Id];
        for(OrderItem oitem: orderProducts){
            System.debug('order product --> '+oitem);
            oitem.Ship_Date__c = system.today();
            oitem.SBQQ__DefaultSubscriptionTerm__c=1;
        }
        update orderProducts;
        System.assert(orderProducts.size()>0, 'Order Products Not created.');
        String defaultText = '1';
        lstOrders[0].Shipping_Email__c='test@informatica.com.sfdc';
        lstOrders[0].SBQQ__PriceCalcStatus__c='Completed';
        lstOrders[0].Status='Activated';
        lstOrders[0].CMS_Approved__c=true;
        lstOrders[0].Revenue_Agreement_Processed__c=true;
        lstOrders[0].BillingAddress_PSFTID__c=defaultText;
        lstOrders[0].EndUserAddress_PSFTID__c=defaultText;
        lstOrders[0].ShippingAddress_PSFTID__c=defaultText;
        lstOrders[0].SoldAddress_PSFTID__c=defaultText;
        update lstOrders[0];
        */
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
            UtilityTestData.mOrderItemData.put('ServiceDate',System.today().addDays(1)+'');
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
    
    static testMethod void handleRenewalTest1(){
        
        sObject sObj;
        sObject sObj1;
        sObject sObj2;
        
        //List<Contract> nnbContract = [Select Id,AccountId from Contract];
        String contract;
        String account; //= nnbContract[0].AccountId;
        String pricebook;
        List<SBQQ__Subscription__c> nnbSubLines = [Select Id,SBQQ__Contract__c,SBQQ__Contract__r.AccountId,SBQQ__Product__c,SBQQ__Contract__r.SBQQ__Order__r.Pricebook2Id from SBQQ__Subscription__c where SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c = null and SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c = null];
        for(SBQQ__Subscription__c sub: nnbSubLines){
            contract = sub.SBQQ__Contract__c;
            account = sub.SBQQ__Contract__r.AccountId;
            pricebook = sub.SBQQ__Contract__r.SBQQ__Order__r.Pricebook2Id;
        }
        List<pricebookEntry> lstPriceBookEntries = [Select Id from pricebookEntry];
        System.assert(nnbSubLines.size() == 3, 'No Subscription lines found');
        System.assert(contract != null, 'No Contract found');
        System.assert(account != null, 'No account found');
        System.assert(pricebook != null, 'No pricebook found');
        Test.startTest();
        //Renewal on NNB/Migrated Contract
        sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('AccountId',account);
        UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c',System.today().addYears(1)+'');
        UtilityTestData.mSBQuoteData.put('SBQQ__EndDate__c',System.today().addYears(2)+'');
        UtilityTestData.mSBQuoteData.put('SBQQ__SubscriptionTerm__c','12');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        
        List<SBQQ__Quote__c> renQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        sObj = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',renQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',nnbSubLines[0].SBQQ__Product__c);
        UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','5');
        UtilityTestData.mQuoteLineData.put('SBQQ__RenewedSubscription__c',nnbSubLines[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
        
        sObj1 = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',renQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',nnbSubLines[1].SBQQ__Product__c);
        UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','6');
        UtilityTestData.mQuoteLineData.put('SBQQ__RenewedSubscription__c',nnbSubLines[1].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
        
        sObj2 = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',renQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',nnbSubLines[2].SBQQ__Product__c);
        UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','3');
        UtilityTestData.mQuoteLineData.put('SBQQ__RenewedSubscription__c',nnbSubLines[2].Id);
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);
        
        List<SBQQ__QuoteLine__c> renQuoteLines = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
        sObj = new Order();
        UtilityTestData.mOrderData.put('AccountId',account);
        UtilityTestData.mOrderData.put('EffectiveDate',System.today().addYears(1)+'');
        UtilityTestData.mOrderData.put('EndDate',System.today().addYears(2)+'');
        UtilityTestData.mOrderData.put('Status','Draft');
        UtilityTestData.mOrderData.put('Asset_Creation_Status__c','Initiated');
        UtilityTestData.mOrderData.put('Pricebook2Id',pricebook);
        sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mOrderData);
        
        List<Order> renOrder  =  (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new OrderItem();
        UtilityTestData.mOrderItemData.put('ServiceDate',System.today().addYears(1)+'');
        UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(2)+'');
        UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',renQuoteLines[0].Id);
        UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','5');
        UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','5');
        UtilityTestData.mOrderItemData.put('Quantity','5');
        UtilityTestData.mOrderItemData.put('Product2Id',nnbSubLines[0].SBQQ__Product__c);
        UtilityTestData.mOrderItemData.put('OrderId',renOrder[0].Id);
        UtilityTestData.mOrderItemData.put('PricebookEntryId',lstPriceBookEntries[0].Id);
        UtilityTestData.mOrderItemData.put('UnitPrice','2000');
        UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today().addYears(1)+'');
        UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131312');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderItemData);
        sObj1 = new OrderItem();
        UtilityTestData.mOrderItemData.put('ServiceDate',System.today().addYears(1)+'');
        UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(2)+'');
        UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',renQuoteLines[1].Id);
        UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','6');
        UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','6');
        UtilityTestData.mOrderItemData.put('Quantity','6');
        UtilityTestData.mOrderItemData.put('Product2Id',nnbSubLines[1].SBQQ__Product__c);
        UtilityTestData.mOrderItemData.put('OrderId',renOrder[0].Id);
        UtilityTestData.mOrderItemData.put('PricebookEntryId',lstPriceBookEntries[1].Id);
        UtilityTestData.mOrderItemData.put('UnitPrice','2000');
        UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today().addYears(1)+'');
        UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131312');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOrderItemData);
        sObj2 = new OrderItem();
        UtilityTestData.mOrderItemData.put('ServiceDate',System.today().addYears(1)+'');
        UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(2)+'');
        UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',renQuoteLines[2].Id);
        UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','3');
        UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','3');
        UtilityTestData.mOrderItemData.put('Quantity','3');
        UtilityTestData.mOrderItemData.put('Product2Id',nnbSubLines[2].SBQQ__Product__c);
        UtilityTestData.mOrderItemData.put('OrderId',renOrder[0].Id);
        UtilityTestData.mOrderItemData.put('PricebookEntryId',lstPriceBookEntries[2].Id);
        UtilityTestData.mOrderItemData.put('UnitPrice','2000');
        UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today().addYears(1)+'');
        UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131312');
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mOrderItemData);
        List<OrderItem> renOrderItems = (List<OrderItem>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
        
        sObj = new Contract(StartDate = System.today().addYears(1));
            UtilityTestData.mContractData.put('AccountId',account);
            UtilityTestData.mContractData.put('StartDate', System.today()+'');
            UtilityTestData.mContractData.put('EndDate',System.today().addYears(2)+'');
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
            UtilityTestData.mContractData.put('SBQQ__Order__c',renOrder[0].Id);
            //UtilityTestData.mContractData.put('SBQQ__Quote__c',lQuote[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mContractData);
            List<Contract> renContract  =  (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});
            sObj = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',account);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',renContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',nnbSubLines[0].SBQQ__Product__c);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','5');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','5');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',renQuoteLines[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',renOrderItems[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mSBQQSubscriptionData);
            sObj1 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',account);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',renContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',nnbSubLines[1].SBQQ__Product__c);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','6');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','6');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',renQuoteLines[1].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',renOrderItems[1].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1,UtilityTestData.mSBQQSubscriptionData);
            sObj2 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',account);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',renContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',nnbSubLines[2].SBQQ__Product__c);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','3');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','3');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',renQuoteLines[2].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',renOrderItems[2].Id);
            sObj2 = UtilityTest.putFieldRecord(sObj2,UtilityTestData.mSBQQSubscriptionData);
            List<SBQQ__Subscription__c > renSubscriptions  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
        	
            AssetCreationBatchHandler.handleAssets(renContract[0]);
            /**
        	//Amend on the Renewed Contract
            sObj = new SBQQ__Quote__c();
            UtilityTestData.mSBQuoteData.put('AccountId',account);
            UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c',System.today().addYears(1)+ '');
            UtilityTestData.mSBQuoteData.put('SBQQ__EndDate__c',System.today().addYears(2)+ '');
            UtilityTestData.mSBQuoteData.put('SBQQ__SubscriptionTerm__c','12');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
            List<SBQQ__Quote__c> amendQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            sObj = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',amendQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',nnbSubLines[0].SBQQ__Product__c);
            UtilityTestData.mQuoteLineData.put('SBQQ__PriorQuantity__c','5');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','0');
            UtilityTestData.mQuoteLineData.put('SBQQ__RenewedSubscription__c',null);
            UtilityTestData.mQuoteLineData.put('SBQQ__UpgradedSubscription__c',renSubscriptions[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
            
            sObj1 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',amendQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',nnbSubLines[1].SBQQ__Product__c);
            UtilityTestData.mQuoteLineData.put('SBQQ__PriorQuantity__c','6');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','4');
            UtilityTestData.mQuoteLineData.put('SBQQ__RenewedSubscription__c',null);
            UtilityTestData.mQuoteLineData.put('SBQQ__UpgradedSubscription__c',renSubscriptions[1].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
            
            sObj2 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',amendQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',nnbSubLines[2].SBQQ__Product__c);
            UtilityTestData.mQuoteLineData.put('SBQQ__PriorQuantity__c','3');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','4');
            UtilityTestData.mQuoteLineData.put('SBQQ__RenewedSubscription__c',null);
            UtilityTestData.mQuoteLineData.put('SBQQ__UpgradedSubscription__c',renSubscriptions[2].Id);
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> amendedQuoteLines = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
            sObj = new Order();
            UtilityTestData.mOrderData.put('AccountId',account);
            UtilityTestData.mOrderData.put('EffectiveDate',System.today().addYears(1)+'');
            UtilityTestData.mOrderData.put('EndDate',System.today().addYears(2)+'');
            UtilityTestData.mOrderData.put('Status','Draft');
            UtilityTestData.mOrderData.put('Asset_Creation_Status__c','Initiated');
            UtilityTestData.mOrderData.put('Pricebook2Id',pricebook);
            sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mOrderData);
                List<Order> amendOrder  =  (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj});
            sObj = new OrderItem();
            UtilityTestData.mOrderItemData.put('ServiceDate',System.today().addYears(1)+'');
            UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(2)+'');
            UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',amendedQuoteLines[0].Id);
            UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','-5');
            UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','-5');
            UtilityTestData.mOrderItemData.put('Quantity','-5');
            UtilityTestData.mOrderItemData.put('Product2Id',nnbSubLines[0].SBQQ__Product__c);
            UtilityTestData.mOrderItemData.put('OrderId',amendOrder[0].Id);
            UtilityTestData.mOrderItemData.put('PricebookEntryId',lstPriceBookEntries[0].Id);
            UtilityTestData.mOrderItemData.put('UnitPrice','2000');
            UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today().addYears(1)+'');
            UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131314');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderItemData);
            sObj1 = new OrderItem();
            UtilityTestData.mOrderItemData.put('ServiceDate',System.today().addYears(1)+'');
            UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(2)+'');
            UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',amendedQuoteLines[1].Id);
            UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','-2');
            UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','-2');
            UtilityTestData.mOrderItemData.put('Quantity','-2');
            UtilityTestData.mOrderItemData.put('Product2Id',nnbSubLines[1].SBQQ__Product__c);
            UtilityTestData.mOrderItemData.put('OrderId',amendOrder[0].Id);
            UtilityTestData.mOrderItemData.put('PricebookEntryId',lstPriceBookEntries[1].Id);
            UtilityTestData.mOrderItemData.put('UnitPrice','2000');
            UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today().addYears(1)+'');
            UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131314');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOrderItemData);
            sObj2 = new OrderItem();
            UtilityTestData.mOrderItemData.put('ServiceDate',System.today().addYears(1)+'');
            UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(2)+'');
            UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',amendedQuoteLines[2].Id);
            UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','1');
            UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','1');
            UtilityTestData.mOrderItemData.put('Quantity','1');
            UtilityTestData.mOrderItemData.put('Product2Id',nnbSubLines[2].SBQQ__Product__c);
            UtilityTestData.mOrderItemData.put('OrderId',amendOrder[0].Id);
            UtilityTestData.mOrderItemData.put('PricebookEntryId',lstPriceBookEntries[2].Id);
            UtilityTestData.mOrderItemData.put('UnitPrice','2000');
            UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today().addYears(1)+'');
            UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131314');
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mOrderItemData);
            List<OrderItem> amendedOrderItems = (List<OrderItem>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
            sObj = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',account);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',renContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',nnbSubLines[0].SBQQ__Product__c);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','-5');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','-5');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',amendedQuoteLines[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',amendedOrderItems[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mSBQQSubscriptionData);
            sObj1 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',account);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',renContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',nnbSubLines[1].SBQQ__Product__c);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','-2');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','-2');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',amendedQuoteLines[1].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',amendedOrderItems[1].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1,UtilityTestData.mSBQQSubscriptionData);
            sObj2 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',account);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',renContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',nnbSubLines[2].SBQQ__Product__c);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','1');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','1');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',amendedQuoteLines[2].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',amendedOrderItems[2].Id);
            sObj2 = UtilityTest.putFieldRecord(sObj2,UtilityTestData.mSBQQSubscriptionData);
            List<SBQQ__Subscription__c > amendedSubscriptions  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
            for(SBQQ__Subscription__c amendSub: amendedSubscriptions){
                System.debug('ren amended subscription --> '+amendSub);
            }
            AssetCreationBatchHandler.handleAssets(renContract[0]);
			**/
        Test.stopTest();
    } 
    
    static testMethod void handleRenewalTest2(){
        
        sObject sObj;
        sObject sObj1;
        sObject sObj2;
        
        //List<Contract> nnbContract = [Select Id,AccountId from Contract];
        String contract;
        String account; //= nnbContract[0].AccountId;
        String pricebook;
        List<SBQQ__Subscription__c> nnbSubLines = [Select Id,SBQQ__Contract__c,SBQQ__Contract__r.AccountId,SBQQ__Product__c,SBQQ__Contract__r.SBQQ__Order__r.Pricebook2Id from SBQQ__Subscription__c where SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c = null and SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c = null];
        for(SBQQ__Subscription__c sub: nnbSubLines){
            contract = sub.SBQQ__Contract__c;
            account = sub.SBQQ__Contract__r.AccountId;
            pricebook = sub.SBQQ__Contract__r.SBQQ__Order__r.Pricebook2Id;
        }
        List<pricebookEntry> lstPriceBookEntries = [Select Id from pricebookEntry];
        System.assert(nnbSubLines.size() == 3, 'No Subscription lines found');
        System.assert(contract != null, 'No Contract found');
        System.assert(account != null, 'No account found');
        System.assert(pricebook != null, 'No pricebook found');
        Test.startTest();
        //Renewal on NNB/Migrated Contract
        sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('AccountId',account);
        UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c',System.today().addYears(1)+'');
        UtilityTestData.mSBQuoteData.put('SBQQ__EndDate__c',System.today().addYears(2)+'');
        UtilityTestData.mSBQuoteData.put('SBQQ__SubscriptionTerm__c','12');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> renQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        sObj = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',renQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',nnbSubLines[0].SBQQ__Product__c);
        UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','5');
        UtilityTestData.mQuoteLineData.put('SBQQ__RenewedSubscription__c',nnbSubLines[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
        
        sObj1 = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',renQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',nnbSubLines[1].SBQQ__Product__c);
        UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','6');
        UtilityTestData.mQuoteLineData.put('SBQQ__RenewedSubscription__c',nnbSubLines[1].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
        
        sObj2 = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',renQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',nnbSubLines[2].SBQQ__Product__c);
        UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','0');
        UtilityTestData.mQuoteLineData.put('SBQQ__RenewedSubscription__c',nnbSubLines[2].Id);
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);
        
        List<SBQQ__QuoteLine__c> renQuoteLines = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
        sObj = new Order();
        UtilityTestData.mOrderData.put('AccountId',account);
        UtilityTestData.mOrderData.put('EffectiveDate',System.today().addYears(1)+'');
        UtilityTestData.mOrderData.put('EndDate',System.today().addYears(2)+'');
        UtilityTestData.mOrderData.put('Status','Draft');
        UtilityTestData.mOrderData.put('Asset_Creation_Status__c','Initiated');
        UtilityTestData.mOrderData.put('Pricebook2Id',pricebook);
        sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mOrderData);
        
        List<Order> renOrder  =  (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new OrderItem();
        UtilityTestData.mOrderItemData.put('ServiceDate',System.today().addYears(1)+'');
        UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(2)+'');
        UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',renQuoteLines[0].Id);
        UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','5');
        UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','5');
        UtilityTestData.mOrderItemData.put('Quantity','5');
        UtilityTestData.mOrderItemData.put('Product2Id',nnbSubLines[0].SBQQ__Product__c);
        UtilityTestData.mOrderItemData.put('OrderId',renOrder[0].Id);
        UtilityTestData.mOrderItemData.put('PricebookEntryId',lstPriceBookEntries[0].Id);
        UtilityTestData.mOrderItemData.put('UnitPrice','2000');
        UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today().addYears(1)+'');
        UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131312');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderItemData);
        sObj1 = new OrderItem();
        UtilityTestData.mOrderItemData.put('ServiceDate',System.today().addYears(1)+'');
        UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(2)+'');
        UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',renQuoteLines[1].Id);
        UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','6');
        UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','6');
        UtilityTestData.mOrderItemData.put('Quantity','6');
        UtilityTestData.mOrderItemData.put('Product2Id',nnbSubLines[1].SBQQ__Product__c);
        UtilityTestData.mOrderItemData.put('OrderId',renOrder[0].Id);
        UtilityTestData.mOrderItemData.put('PricebookEntryId',lstPriceBookEntries[1].Id);
        UtilityTestData.mOrderItemData.put('UnitPrice','2000');
        UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today().addYears(1)+'');
        UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131312');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOrderItemData);
        sObj2 = new OrderItem();
        UtilityTestData.mOrderItemData.put('ServiceDate',System.today().addYears(1)+'');
        UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(2)+'');
        UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',renQuoteLines[2].Id);
        UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','0');
        UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','0');
        UtilityTestData.mOrderItemData.put('Quantity','3');
        UtilityTestData.mOrderItemData.put('Product2Id',nnbSubLines[2].SBQQ__Product__c);
        UtilityTestData.mOrderItemData.put('OrderId',renOrder[0].Id);
        UtilityTestData.mOrderItemData.put('PricebookEntryId',lstPriceBookEntries[2].Id);
        UtilityTestData.mOrderItemData.put('UnitPrice','2000');
        UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today().addYears(1)+'');
        UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131312');
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mOrderItemData);
        List<OrderItem> renOrderItems = (List<OrderItem>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
 
        sObj = new Contract(StartDate = System.today().addYears(1));
            UtilityTestData.mContractData.put('AccountId',account);
            UtilityTestData.mContractData.put('StartDate', System.today()+'');
            UtilityTestData.mContractData.put('EndDate',System.today().addYears(2)+'');
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
            UtilityTestData.mContractData.put('SBQQ__Order__c',renOrder[0].Id);
            //UtilityTestData.mContractData.put('SBQQ__Quote__c',lQuote[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mContractData);
            List<Contract> renContract  =  (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});
            sObj = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',account);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',renContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',nnbSubLines[0].SBQQ__Product__c);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','1');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','1');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',renQuoteLines[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',renOrderItems[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mSBQQSubscriptionData);
            sObj1 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',account);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',renContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',nnbSubLines[1].SBQQ__Product__c);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','1');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','1');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',renQuoteLines[1].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',renOrderItems[1].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1,UtilityTestData.mSBQQSubscriptionData);
            sObj2 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',account);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',renContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',nnbSubLines[2].SBQQ__Product__c);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','1');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','1');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',renQuoteLines[2].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',renOrderItems[2].Id);
            sObj2 = UtilityTest.putFieldRecord(sObj2,UtilityTestData.mSBQQSubscriptionData);
            List<SBQQ__Subscription__c > renSubscriptions  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
            AssetCreationBatchHandler.handleAssets(renContract[0]);
            List<Asset> lstAssets = [Select Id from Asset where Status != 'Cancelled' and SBQQ__CurrentSubscription__r.SBQQ__Contract__c =: renContract[0].Id];
            System.debug('lstAsset.size --> '+lstAssets.size());
            
            for(Asset a: lstAssets){
                System.debug('asset --> '+a);
            }
        Test.stopTest();
    } 
    
    static testMethod void handleRenewalTest3(){
        
        sObject sObj;
        sObject sObj1;
        sObject sObj2;
        
        //List<Contract> nnbContract = [Select Id,AccountId from Contract];
        String contract;
        String account; //= nnbContract[0].AccountId;
        String pricebook;
        List<SBQQ__Subscription__c> nnbSubLines = [Select Id,SBQQ__Contract__c,SBQQ__Contract__r.AccountId,SBQQ__Product__c,SBQQ__Contract__r.SBQQ__Order__r.Pricebook2Id from SBQQ__Subscription__c where SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c = null and SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c = null];
        for(SBQQ__Subscription__c sub: nnbSubLines){
            contract = sub.SBQQ__Contract__c;
            account = sub.SBQQ__Contract__r.AccountId;
            pricebook = sub.SBQQ__Contract__r.SBQQ__Order__r.Pricebook2Id;
        }
        List<pricebookEntry> lstPriceBookEntries = [Select Id from pricebookEntry];
        System.assert(nnbSubLines.size() == 3, 'No Subscription lines found');
        System.assert(contract != null, 'No Contract found');
        System.assert(account != null, 'No account found');
        System.assert(pricebook != null, 'No pricebook found');
        
         Test.startTest();
        //Renewal on NNB/Migrated Contract
        sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('AccountId',account);
        UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c',System.today().addYears(1)+'');
        UtilityTestData.mSBQuoteData.put('SBQQ__EndDate__c',System.today().addYears(2)+'');
        UtilityTestData.mSBQuoteData.put('SBQQ__SubscriptionTerm__c','12');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> renQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        sObj = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',renQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',nnbSubLines[0].SBQQ__Product__c);
        UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','5');
        UtilityTestData.mQuoteLineData.put('SBQQ__RenewedSubscription__c',nnbSubLines[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
        
        sObj1 = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',renQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',nnbSubLines[1].SBQQ__Product__c);
        UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','6');
        UtilityTestData.mQuoteLineData.put('SBQQ__RenewedSubscription__c',nnbSubLines[1].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
        
        sObj2 = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',renQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',nnbSubLines[2].SBQQ__Product__c);
        UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','3');
        UtilityTestData.mQuoteLineData.put('SBQQ__RenewedSubscription__c',nnbSubLines[2].Id);
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);
       
        List<SBQQ__QuoteLine__c> renQuoteLines = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
        sObj = new Order();
        UtilityTestData.mOrderData.put('AccountId',account);
        UtilityTestData.mOrderData.put('EffectiveDate',System.today().addYears(1)+'');
        UtilityTestData.mOrderData.put('EndDate',System.today().addYears(2)+'');
        UtilityTestData.mOrderData.put('Status','Draft');
        UtilityTestData.mOrderData.put('Asset_Creation_Status__c','Initiated');
        UtilityTestData.mOrderData.put('Pricebook2Id',pricebook);
        sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mOrderData);
        
        List<Order> renOrder  =  (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new OrderItem();
        UtilityTestData.mOrderItemData.put('ServiceDate',System.today().addYears(1)+'');
        UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(2)+'');
        UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',renQuoteLines[0].Id);
        UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','5');
        UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','5');
        UtilityTestData.mOrderItemData.put('Quantity','5');
        UtilityTestData.mOrderItemData.put('Product2Id',nnbSubLines[0].SBQQ__Product__c);
        UtilityTestData.mOrderItemData.put('OrderId',renOrder[0].Id);
        UtilityTestData.mOrderItemData.put('PricebookEntryId',lstPriceBookEntries[0].Id);
        UtilityTestData.mOrderItemData.put('UnitPrice','2000');
        UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today().addYears(1)+'');
        UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131312');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderItemData);
        sObj1 = new OrderItem();
        UtilityTestData.mOrderItemData.put('ServiceDate',System.today().addYears(1)+'');
        UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(2)+'');
        UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',renQuoteLines[1].Id);
        UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','6');
        UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','6');
        UtilityTestData.mOrderItemData.put('Quantity','6');
        UtilityTestData.mOrderItemData.put('Product2Id',nnbSubLines[1].SBQQ__Product__c);
        UtilityTestData.mOrderItemData.put('OrderId',renOrder[0].Id);
        UtilityTestData.mOrderItemData.put('PricebookEntryId',lstPriceBookEntries[1].Id);
        UtilityTestData.mOrderItemData.put('UnitPrice','2000');
        UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today().addYears(1)+'');
        UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131312');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOrderItemData);
        sObj2 = new OrderItem();
        UtilityTestData.mOrderItemData.put('ServiceDate',System.today().addYears(1)+'');
        UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(2)+'');
        UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',renQuoteLines[2].Id);
        UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','3');
        UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','3');
        UtilityTestData.mOrderItemData.put('Quantity','3');
        UtilityTestData.mOrderItemData.put('Product2Id',nnbSubLines[2].SBQQ__Product__c);
        UtilityTestData.mOrderItemData.put('OrderId',renOrder[0].Id);
        UtilityTestData.mOrderItemData.put('PricebookEntryId',lstPriceBookEntries[2].Id);
        UtilityTestData.mOrderItemData.put('UnitPrice','2000');
        UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today().addYears(1)+'');
        UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131312');
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mOrderItemData);
        List<OrderItem> renOrderItems = (List<OrderItem>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
        
        sObj = new Contract(StartDate = System.today().addYears(1));
            UtilityTestData.mContractData.put('AccountId',account);
            UtilityTestData.mContractData.put('StartDate', System.today()+'');
            UtilityTestData.mContractData.put('EndDate',System.today().addYears(2)+'');
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
            UtilityTestData.mContractData.put('SBQQ__Order__c',renOrder[0].Id);
            //UtilityTestData.mContractData.put('SBQQ__Quote__c',lQuote[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mContractData);
            List<Contract> renContract  =  (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});
            sObj = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',account);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',renContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',nnbSubLines[0].SBQQ__Product__c);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','5');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','5');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',renQuoteLines[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',renOrderItems[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mSBQQSubscriptionData);
            sObj1 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',account);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',renContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',nnbSubLines[1].SBQQ__Product__c);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','6');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','6');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',renQuoteLines[1].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',renOrderItems[1].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1,UtilityTestData.mSBQQSubscriptionData);
            sObj2 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',account);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',renContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',nnbSubLines[2].SBQQ__Product__c);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','3');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','3');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',renQuoteLines[2].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',renOrderItems[2].Id);
            sObj2 = UtilityTest.putFieldRecord(sObj2,UtilityTestData.mSBQQSubscriptionData);
            List<SBQQ__Subscription__c > renSubscriptions  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
            AssetCreationBatchHandler.handleAssets(renContract[0]);
            
        	//Amend on the Renewed Contract
        	/**
            sObj = new SBQQ__Quote__c();
            UtilityTestData.mSBQuoteData.put('AccountId',account);
            UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c',System.today().addYears(1)+ '');
            UtilityTestData.mSBQuoteData.put('SBQQ__EndDate__c',System.today().addYears(2)+ '');
            UtilityTestData.mSBQuoteData.put('SBQQ__SubscriptionTerm__c','12');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
            List<SBQQ__Quote__c> amendQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            sObj = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',amendQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',nnbSubLines[0].SBQQ__Product__c);
            UtilityTestData.mQuoteLineData.put('SBQQ__PriorQuantity__c','5');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','0');
            UtilityTestData.mQuoteLineData.put('SBQQ__RenewedSubscription__c',null);
            UtilityTestData.mQuoteLineData.put('SBQQ__UpgradedSubscription__c',renSubscriptions[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
            
            sObj1 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',amendQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',nnbSubLines[1].SBQQ__Product__c);
            UtilityTestData.mQuoteLineData.put('SBQQ__PriorQuantity__c','6');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','4');
            UtilityTestData.mQuoteLineData.put('SBQQ__RenewedSubscription__c',null);
            UtilityTestData.mQuoteLineData.put('SBQQ__UpgradedSubscription__c',renSubscriptions[1].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
            
            sObj2 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',amendQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',nnbSubLines[2].SBQQ__Product__c);
            UtilityTestData.mQuoteLineData.put('SBQQ__PriorQuantity__c','3');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','4');
            UtilityTestData.mQuoteLineData.put('SBQQ__RenewedSubscription__c',null);
            UtilityTestData.mQuoteLineData.put('SBQQ__UpgradedSubscription__c',renSubscriptions[2].Id);
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);
        
        
             sObject sObj3 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',amendQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',nnbSubLines[2].SBQQ__Product__c);
            UtilityTestData.mQuoteLineData.put('SBQQ__PriorQuantity__c','3');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','4');
            UtilityTestData.mQuoteLineData.put('SBQQ__RenewedSubscription__c',null);
            UtilityTestData.mQuoteLineData.put('SBQQ__UpgradedSubscription__c',renSubscriptions[2].Id);
            sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mQuoteLineData);
        
            List<SBQQ__QuoteLine__c> amendedQuoteLines = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3});
            sObj = new Order();
            UtilityTestData.mOrderData.put('AccountId',account);
            UtilityTestData.mOrderData.put('EffectiveDate',System.today().addYears(1)+'');
            UtilityTestData.mOrderData.put('EndDate',System.today().addYears(2)+'');
            UtilityTestData.mOrderData.put('Status','Draft');
            UtilityTestData.mOrderData.put('Asset_Creation_Status__c','Initiated');
            UtilityTestData.mOrderData.put('Pricebook2Id',pricebook);
            sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mOrderData);
                List<Order> amendOrder  =  (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj});
            sObj = new OrderItem();
            UtilityTestData.mOrderItemData.put('ServiceDate',System.today().addYears(1)+'');
            UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(2)+'');
            UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',amendedQuoteLines[0].Id);
            UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','-5');
            UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','-5');
            UtilityTestData.mOrderItemData.put('Quantity','-5');
            UtilityTestData.mOrderItemData.put('Product2Id',nnbSubLines[0].SBQQ__Product__c);
            UtilityTestData.mOrderItemData.put('OrderId',amendOrder[0].Id);
            UtilityTestData.mOrderItemData.put('PricebookEntryId',lstPriceBookEntries[0].Id);
            UtilityTestData.mOrderItemData.put('UnitPrice','2000');
            UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today().addYears(1)+'');
            UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131314');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderItemData);
            sObj1 = new OrderItem();
            UtilityTestData.mOrderItemData.put('ServiceDate',System.today().addYears(1)+'');
            UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(2)+'');
            UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',amendedQuoteLines[1].Id);
            UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','-2');
            UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','-2');
            UtilityTestData.mOrderItemData.put('Quantity','-2');
            UtilityTestData.mOrderItemData.put('Product2Id',nnbSubLines[1].SBQQ__Product__c);
            UtilityTestData.mOrderItemData.put('OrderId',amendOrder[0].Id);
            UtilityTestData.mOrderItemData.put('PricebookEntryId',lstPriceBookEntries[1].Id);
            UtilityTestData.mOrderItemData.put('UnitPrice','2000');
            UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today().addYears(1)+'');
            UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131314');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOrderItemData);
            sObj2 = new OrderItem();
            UtilityTestData.mOrderItemData.put('ServiceDate',System.today().addYears(1)+'');
            UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(2)+'');
            UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',amendedQuoteLines[2].Id);
            UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','1');
            UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','1');
            UtilityTestData.mOrderItemData.put('Quantity','1');
            UtilityTestData.mOrderItemData.put('Product2Id',nnbSubLines[2].SBQQ__Product__c);
            UtilityTestData.mOrderItemData.put('OrderId',amendOrder[0].Id);
            UtilityTestData.mOrderItemData.put('PricebookEntryId',lstPriceBookEntries[2].Id);
            UtilityTestData.mOrderItemData.put('UnitPrice','2000');
            UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today().addYears(1)+'');
            UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131314');
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mOrderItemData);
            
            sObj3 = new OrderItem();
            UtilityTestData.mOrderItemData.put('ServiceDate',System.today().addYears(1)+'');
            UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(2)+'');
            UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',amendedQuoteLines[2].Id);
            UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','1');
            UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','1');
            UtilityTestData.mOrderItemData.put('Quantity','1');
            UtilityTestData.mOrderItemData.put('Product2Id',nnbSubLines[2].SBQQ__Product__c);
            UtilityTestData.mOrderItemData.put('OrderId',amendOrder[0].Id);
            UtilityTestData.mOrderItemData.put('PricebookEntryId',lstPriceBookEntries[2].Id);
            UtilityTestData.mOrderItemData.put('UnitPrice','2000');
            UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today().addYears(1)+'');
            UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131314');
            sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mOrderItemData);
        
            List<OrderItem> amendedOrderItems = (List<OrderItem>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3});
            sObj = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',account);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',renContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',nnbSubLines[0].SBQQ__Product__c);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','-5');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','-5');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',amendedQuoteLines[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',amendedOrderItems[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mSBQQSubscriptionData);
            sObj1 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',account);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',renContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',nnbSubLines[1].SBQQ__Product__c);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','-2');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','-2');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',amendedQuoteLines[1].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',amendedOrderItems[1].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1,UtilityTestData.mSBQQSubscriptionData);
            sObj2 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',account);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',renContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',nnbSubLines[2].SBQQ__Product__c);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','1');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','1');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',amendedQuoteLines[2].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',amendedOrderItems[2].Id);
            sObj2 = UtilityTest.putFieldRecord(sObj2,UtilityTestData.mSBQQSubscriptionData);
            
            sObj3 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',account);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',renContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',nnbSubLines[2].SBQQ__Product__c);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','1');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','1');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',amendedQuoteLines[2].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',amendedOrderItems[2].Id);
            sObj3 = UtilityTest.putFieldRecord(sObj3,UtilityTestData.mSBQQSubscriptionData);
                    
            List<SBQQ__Subscription__c > amendedSubscriptions  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3});
            for(SBQQ__Subscription__c amendSub: amendedSubscriptions){
                System.debug('ren amended subscription --> '+amendSub);
            }
            
        List<Asset> lstAssets = [Select Id from Asset where Status != 'Cancelled' and SBQQ__CurrentSubscription__r.SBQQ__Contract__c =: renContract[0].Id];
        System.debug('lstAsset.size --> '+lstAssets.size());
        
        for(Asset a: lstAssets){
            a.SBQQ__CurrentSubscription__c = null;
        }
        update lstAssets;
        AssetCreationBatchHandler.handleAssets(renContract[0]);
            **/
        Test.stopTest();
    }
    
    static testMethod void handleRenewalTest4(){
        
        sObject sObj;
        sObject sObj1;
        sObject sObj2;
        
        //List<Contract> nnbContract = [Select Id,AccountId from Contract];
        String contract;
        String account; //= nnbContract[0].AccountId;
        String pricebook;
        List<SBQQ__Subscription__c> nnbSubLines = [Select Id,SBQQ__Contract__c,SBQQ__Contract__r.AccountId,SBQQ__Product__c,SBQQ__Contract__r.SBQQ__Order__r.Pricebook2Id from SBQQ__Subscription__c where SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c = null and SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c = null];
        for(SBQQ__Subscription__c sub: nnbSubLines){
            contract = sub.SBQQ__Contract__c;
            account = sub.SBQQ__Contract__r.AccountId;
            pricebook = sub.SBQQ__Contract__r.SBQQ__Order__r.Pricebook2Id;
        }
        List<pricebookEntry> lstPriceBookEntries = [Select Id from pricebookEntry];
        System.assert(nnbSubLines.size() == 3, 'No Subscription lines found');
        System.assert(contract != null, 'No Contract found');
        System.assert(account != null, 'No account found');
        System.assert(pricebook != null, 'No pricebook found');
         Test.startTest();
         Global_Config__c settings = Global_Config__c.getOrgDefaults();
        settings.Mute_Triggers__c = true;
        upsert settings Global_Config__c.Id;
    
        User_Exemptions__c settings1 = User_Exemptions__c.getOrgDefaults();
        settings1.Ignore_Validation_Rules__c = true;
        upsert settings1 User_Exemptions__c.Id;
        //Renewal on NNB/Migrated Contract
        sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('AccountId',account);
        UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c',System.today().addYears(1)+'');
        UtilityTestData.mSBQuoteData.put('SBQQ__EndDate__c',System.today().addYears(2)+'');
        UtilityTestData.mSBQuoteData.put('SBQQ__SubscriptionTerm__c','12');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> renQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        sObj = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',renQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',nnbSubLines[0].SBQQ__Product__c);
        UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','6');
        UtilityTestData.mQuoteLineData.put('SBQQ__RenewedSubscription__c',nnbSubLines[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
        
        sObj1 = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',renQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',nnbSubLines[1].SBQQ__Product__c);
        UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','7');
        UtilityTestData.mQuoteLineData.put('SBQQ__RenewedSubscription__c',nnbSubLines[1].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
        
        sObj2 = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',renQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',nnbSubLines[2].SBQQ__Product__c);
        UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','4');
        UtilityTestData.mQuoteLineData.put('SBQQ__RenewedSubscription__c',nnbSubLines[2].Id);
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);
        
        List<SBQQ__QuoteLine__c> renQuoteLines = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
        sObj = new Order();
        UtilityTestData.mOrderData.put('AccountId',account);
        UtilityTestData.mOrderData.put('EffectiveDate',System.today().addYears(1)+'');
        UtilityTestData.mOrderData.put('EndDate',System.today().addYears(2)+'');
        UtilityTestData.mOrderData.put('Status','Draft');
        UtilityTestData.mOrderData.put('Asset_Creation_Status__c','Initiated');
        UtilityTestData.mOrderData.put('Pricebook2Id',pricebook);
        sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mOrderData);
        
            List<Order> renOrder  =  (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new OrderItem();
        UtilityTestData.mOrderItemData.put('ServiceDate',System.today().addYears(1)+'');
        UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(2)+'');
        UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',renQuoteLines[0].Id);
        UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','6');
        UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','6');
        UtilityTestData.mOrderItemData.put('Quantity','6');
        UtilityTestData.mOrderItemData.put('Product2Id',nnbSubLines[0].SBQQ__Product__c);
        UtilityTestData.mOrderItemData.put('OrderId',renOrder[0].Id);
        UtilityTestData.mOrderItemData.put('PricebookEntryId',lstPriceBookEntries[0].Id);
        UtilityTestData.mOrderItemData.put('UnitPrice','2000');
        UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today().addYears(1)+'');
        UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131312');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderItemData);
        sObj1 = new OrderItem();
        UtilityTestData.mOrderItemData.put('ServiceDate',System.today().addYears(1)+'');
        UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(2)+'');
        UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',renQuoteLines[1].Id);
        UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','7');
        UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','7');
        UtilityTestData.mOrderItemData.put('Quantity','7');
        UtilityTestData.mOrderItemData.put('Product2Id',nnbSubLines[1].SBQQ__Product__c);
        UtilityTestData.mOrderItemData.put('OrderId',renOrder[0].Id);
        UtilityTestData.mOrderItemData.put('PricebookEntryId',lstPriceBookEntries[1].Id);
        UtilityTestData.mOrderItemData.put('UnitPrice','2000');
        UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today().addYears(1)+'');
        UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131312');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOrderItemData);
        sObj2 = new OrderItem();
        UtilityTestData.mOrderItemData.put('ServiceDate',System.today().addYears(1)+'');
        UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(2)+'');
        UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',renQuoteLines[2].Id);
        UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','4');
        UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','4');
        UtilityTestData.mOrderItemData.put('Quantity','4');
        UtilityTestData.mOrderItemData.put('Product2Id',nnbSubLines[2].SBQQ__Product__c);
        UtilityTestData.mOrderItemData.put('OrderId',renOrder[0].Id);
        UtilityTestData.mOrderItemData.put('PricebookEntryId',lstPriceBookEntries[2].Id);
        UtilityTestData.mOrderItemData.put('UnitPrice','2000');
        UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today().addYears(1)+'');
        UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131312');
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mOrderItemData);
        List<OrderItem> renOrderItems = (List<OrderItem>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
        
        sObj = new Contract(StartDate = System.today().addYears(1));
            UtilityTestData.mContractData.put('AccountId',account);
            UtilityTestData.mContractData.put('StartDate', System.today()+'');
            UtilityTestData.mContractData.put('EndDate',System.today().addYears(2)+'');
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
            UtilityTestData.mContractData.put('SBQQ__Order__c',renOrder[0].Id);
            //UtilityTestData.mContractData.put('SBQQ__Quote__c',lQuote[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mContractData);
            List<Contract> renContract  =  (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});
            sObj = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',account);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',renContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',nnbSubLines[0].SBQQ__Product__c);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','6');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','6');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',renQuoteLines[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',renOrderItems[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mSBQQSubscriptionData);
            sObj1 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',account);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',renContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',nnbSubLines[1].SBQQ__Product__c);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','7');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','7');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',renQuoteLines[1].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',renOrderItems[1].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1,UtilityTestData.mSBQQSubscriptionData);
            sObj2 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',account);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',renContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',nnbSubLines[2].SBQQ__Product__c);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','4');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','4');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',renQuoteLines[2].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',renOrderItems[2].Id);
            sObj2 = UtilityTest.putFieldRecord(sObj2,UtilityTestData.mSBQQSubscriptionData);
            List<SBQQ__Subscription__c > renSubscriptions  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
            AssetCreationBatchHandler.handleAssets(renContract[0]);
        
            
            //Amend on the Renewed Contract
            sObj = new SBQQ__Quote__c();
            UtilityTestData.mSBQuoteData.put('AccountId',account);
            UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c',System.today().addYears(1)+ '');
            UtilityTestData.mSBQuoteData.put('SBQQ__EndDate__c',System.today().addYears(2)+ '');
            UtilityTestData.mSBQuoteData.put('SBQQ__SubscriptionTerm__c','12');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
            List<SBQQ__Quote__c> amendQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            sObj = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',amendQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',nnbSubLines[0].SBQQ__Product__c);
            UtilityTestData.mQuoteLineData.put('SBQQ__PriorQuantity__c','6');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','7');
            UtilityTestData.mQuoteLineData.put('SBQQ__RenewedSubscription__c',null);
            UtilityTestData.mQuoteLineData.put('SBQQ__UpgradedSubscription__c',renSubscriptions[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
            
            sObj1 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',amendQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',nnbSubLines[1].SBQQ__Product__c);
            UtilityTestData.mQuoteLineData.put('SBQQ__PriorQuantity__c','7');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','1');
            UtilityTestData.mQuoteLineData.put('SBQQ__RenewedSubscription__c',null);
            UtilityTestData.mQuoteLineData.put('SBQQ__UpgradedSubscription__c',renSubscriptions[1].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
            
            sObj2 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',amendQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',nnbSubLines[2].SBQQ__Product__c);
            UtilityTestData.mQuoteLineData.put('SBQQ__PriorQuantity__c','4');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','8');
            UtilityTestData.mQuoteLineData.put('SBQQ__RenewedSubscription__c',null);
            UtilityTestData.mQuoteLineData.put('SBQQ__UpgradedSubscription__c',renSubscriptions[2].Id);
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> amendedQuoteLines = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
            sObj = new Order();
            UtilityTestData.mOrderData.put('AccountId',account);
            UtilityTestData.mOrderData.put('EffectiveDate',System.today().addYears(1)+'');
            UtilityTestData.mOrderData.put('EndDate',System.today().addYears(2)+'');
            UtilityTestData.mOrderData.put('Status','Draft');
            UtilityTestData.mOrderData.put('Asset_Creation_Status__c','Initiated');
            UtilityTestData.mOrderData.put('Pricebook2Id',pricebook);
            sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mOrderData);
                List<Order> amendOrder  =  (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj});
            sObj = new OrderItem();
            UtilityTestData.mOrderItemData.put('ServiceDate',System.today().addYears(1)+'');
            UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(2)+'');
            UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',amendedQuoteLines[0].Id);
            UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','1');
            UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','1');
            UtilityTestData.mOrderItemData.put('Quantity','1');
            UtilityTestData.mOrderItemData.put('Product2Id',nnbSubLines[0].SBQQ__Product__c);
            UtilityTestData.mOrderItemData.put('OrderId',amendOrder[0].Id);
            UtilityTestData.mOrderItemData.put('PricebookEntryId',lstPriceBookEntries[0].Id);
            UtilityTestData.mOrderItemData.put('UnitPrice','2000');
            UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today().addYears(1)+'');
            UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131314');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderItemData);
            sObj1 = new OrderItem();
            UtilityTestData.mOrderItemData.put('ServiceDate',System.today().addYears(2)+'');
            UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(2)+'');
            UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',amendedQuoteLines[1].Id);
            UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','-6');
            UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','-6');
            UtilityTestData.mOrderItemData.put('Quantity','-6');
            UtilityTestData.mOrderItemData.put('Product2Id',nnbSubLines[1].SBQQ__Product__c);
            UtilityTestData.mOrderItemData.put('OrderId',amendOrder[0].Id);
            UtilityTestData.mOrderItemData.put('PricebookEntryId',lstPriceBookEntries[1].Id);
            UtilityTestData.mOrderItemData.put('UnitPrice','2000');
            UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today().addYears(1)+'');
            UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131314');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOrderItemData);
            sObj2 = new OrderItem();
            UtilityTestData.mOrderItemData.put('ServiceDate',System.today().addYears(1)+'');
            UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(2)+'');
            UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',amendedQuoteLines[2].Id);
            UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','4');
            UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','4');
            UtilityTestData.mOrderItemData.put('Quantity','1');
            UtilityTestData.mOrderItemData.put('Product2Id',nnbSubLines[2].SBQQ__Product__c);
            UtilityTestData.mOrderItemData.put('OrderId',amendOrder[0].Id);
            UtilityTestData.mOrderItemData.put('PricebookEntryId',lstPriceBookEntries[2].Id);
            UtilityTestData.mOrderItemData.put('UnitPrice','2000');
            UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today().addYears(1)+'');
            UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131314');
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mOrderItemData);
            List<OrderItem> amendedOrderItems = (List<OrderItem>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
            sObj = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',account);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',renContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',nnbSubLines[0].SBQQ__Product__c);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','1');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','1');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',amendedQuoteLines[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',amendedOrderItems[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mSBQQSubscriptionData);
            sObj1 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',account);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',renContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',nnbSubLines[1].SBQQ__Product__c);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','-6');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','-6');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',amendedQuoteLines[1].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',amendedOrderItems[1].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1,UtilityTestData.mSBQQSubscriptionData);
            sObj2 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',account);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',renContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',nnbSubLines[2].SBQQ__Product__c);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','4');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','4');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',amendedQuoteLines[2].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',amendedOrderItems[2].Id);
            sObj2 = UtilityTest.putFieldRecord(sObj2,UtilityTestData.mSBQQSubscriptionData);
            List<SBQQ__Subscription__c > amendedSubscriptions  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
            for(SBQQ__Subscription__c amendSub: amendedSubscriptions){
                System.debug('ren amended subscription --> '+amendSub);
            }
            
            List<Asset> lstAssets = [Select Id from Asset where Status != 'Cancelled' and SBQQ__CurrentSubscription__r.SBQQ__Contract__c =: renContract[0].Id];
            System.debug('lstAsset.size --> '+lstAssets.size());
            
            for(Asset a: lstAssets){
                a.SBQQ__SubscriptionStartDate__c = System.today();
            }
            update lstAssets;
        
            AssetCreationBatchHandler.handleAssets(renContract[0]);
        
        Test.stopTest();
    }
    
    static testMethod void handleNNBTest1(){
        sObject sObj;
        sObject sObj1;
        sObject sObj2;
        sObject sObj3;
        List<Account> lAccount = [Select Id from Account];
        List<Pricebook2> lPriceBook2 = [Select Id from Pricebook2];
        List<Product2> lProduct2 = [Select Id from Product2];
        List<pricebookEntry> lPriceBookEntry = [Select Id from pricebookEntry];
        Test.startTest();
        Global_Config__c settings = Global_Config__c.getOrgDefaults();
        settings.Mute_Triggers__c = true;
        upsert settings Global_Config__c.Id;

        User_Exemptions__c settings1 = User_Exemptions__c.getOrgDefaults();
        settings1.Ignore_Validation_Rules__c = true;
        upsert settings1 User_Exemptions__c.Id;
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
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','4');
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
            UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','1');
            UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','1');
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
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','1');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','1');
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
            sObj3 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lProduct2[1].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','3');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','3');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lSBQuoteLine[1].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',amendedOrderItems[1].Id);
            sObj3 = UtilityTest.putFieldRecord(sObj3,UtilityTestData.mSBQQSubscriptionData);
            List<SBQQ__Subscription__c > lamendedSubscriptions  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3});
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
    
    static testMethod void handleNNBTest2(){
        sObject sObj;
        sObject sObj1;
        sObject sObj2;
        sObject sObj3;
        List<Account> lAccount = [Select Id from Account];
        List<Pricebook2> lPriceBook2 = [Select Id from Pricebook2];
        List<Product2> lProduct2 = [Select Id from Product2];
        List<pricebookEntry> lPriceBookEntry = [Select Id from pricebookEntry];
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
            //AssetCreationBatchHandler.handleAssets(lstContracts[0]);
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
            sObj3 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lProduct2[1].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','3');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','3');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lSBQuoteLine[1].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',amendedOrderItems[1].Id);
            sObj3 = UtilityTest.putFieldRecord(sObj3,UtilityTestData.mSBQQSubscriptionData);
            List<SBQQ__Subscription__c > lamendedSubscriptions  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3});
            lOrder[0].Asset_Creation_Status__c='Initiated';
            update lOrder[0];
            AssetCreationBatchHandler.handleAssets(lstContracts[0]);
            
            List<Asset> lstAssets = [Select Id from Asset where Status != 'Cancelled'];
            System.debug('lstAsset.size --> '+lstAssets.size());
            for(Asset a: lstAssets){
                System.debug('asset --> '+a);
            }
            AssetCreationBatch b = new AssetCreationBatch();
            database.executebatch(b,1);
        
            Test.stopTest();
    } 
    
    static testMethod void debookAssetsTest(){
        List<SBQQ__Subscription__c> subscriptionList = [Select Id,
                                                        SBQQ__Contract__c,
                                                        SBQQ__Quantity__c,
                                                        SBQQ__QuoteLine__c,
                                                        SBQQ__StartDate__c,
                                                        SBQQ__EndDate__c,
                                                        SBQQ__Product__r.Id,
                                                        SBQQ__Account__r.Id,
                                                        SBQQ__Product__r.Name,
                                                        SBQQ__Product__r.Offering_Type__c,
                                                        SBQQ__Product__r.SBQQ__AssetConversion__c,
                                                        SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c, 
                                                        SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c,
                                                        SBQQ__OrderProduct__c,
                                                        SBQQ__OrderProduct__r.Product2.SBQQ__AssetConversion__c,
                                                        SBQQ__OrderProduct__r.Product2.Offering_Type__c,
                                                        SBQQ__OrderProduct__r.SBQQ__QuoteLine__c,
                                                        SBQQ__OrderProduct__r.Product2Id,
                                                        SBQQ__OrderProduct__r.SBQQ__OrderedQuantity__c,
                                                        SBQQ__OrderProduct__r.Order.accountId,
                                                        SBQQ__OrderProduct__r.Id,
                                                        SBQQ__OrderProduct__r.Product2.Name,
                                                        SBQQ__OrderProduct__r.Ship_Date__c,
                                                        SBQQ__OrderProduct__r.ServiceDate,
                                                        SBQQ__OrderProduct__r.EndDate,
                                                        SBQQ__OrderProduct__r.Order.Generate_Date__c,
                                                        (Select id,
                                                         InstallDate,
                                                         SBQQ__CurrentSubscription__c,
                                                         SBQQ__CurrentSubscription__r.SBQQ__Contract__c,
                                                         SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__SubscriptionStartDate__c,
                                                         SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__SubscriptionEndDate__c,
                                                         SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__r.EndDate,
                                                         SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__c,
                                                         SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c,
                                                         SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c,
                                                         SBQQ__SubscriptionStartDate__c
                                                         from SBQQ__CoveredAssets__r 
                                                         order by Id DESC) 
                                                        from SBQQ__Subscription__c 
                                                        ];
        	System.debug('subscriptionList >> '+ subscriptionList[0]);
            System.debug('subscriptionList >> '+ subscriptionList[1]);
            System.debug('subscriptionList >> '+ subscriptionList[2]);
        	AssetCreationBatchHandler.debookRenewalAsset(subscriptionList[0],subscriptionList[0]);
    }
    
    static testMethod void canceldebookAssetTest(){
        List<SBQQ__Subscription__c> subscriptionList = [Select Id,
                                                        SBQQ__Contract__c,
                                                        SBQQ__Quantity__c,
                                                        SBQQ__QuoteLine__c,
                                                        SBQQ__StartDate__c,
                                                        SBQQ__EndDate__c,
                                                        SBQQ__Product__r.Id,
                                                        SBQQ__Account__r.Id,
                                                        SBQQ__Product__r.Name,
                                                        SBQQ__Product__r.Offering_Type__c,
                                                        SBQQ__Product__r.SBQQ__AssetConversion__c,
                                                        SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c, 
                                                        SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c,
                                                        SBQQ__OrderProduct__c,
                                                        SBQQ__OrderProduct__r.Product2.SBQQ__AssetConversion__c,
                                                        SBQQ__OrderProduct__r.Product2.Offering_Type__c,
                                                        SBQQ__OrderProduct__r.SBQQ__QuoteLine__c,
                                                        SBQQ__OrderProduct__r.Product2Id,
                                                        SBQQ__OrderProduct__r.SBQQ__OrderedQuantity__c,
                                                        SBQQ__OrderProduct__r.Order.accountId,
                                                        SBQQ__OrderProduct__r.Id,
                                                        SBQQ__OrderProduct__r.Product2.Name,
                                                        SBQQ__OrderProduct__r.Ship_Date__c,
                                                        SBQQ__OrderProduct__r.ServiceDate,
                                                        SBQQ__OrderProduct__r.EndDate,
                                                        SBQQ__OrderProduct__r.Order.Generate_Date__c,
                                                        (Select id,
                                                         InstallDate,
                                                         SBQQ__CurrentSubscription__c,
                                                         SBQQ__CurrentSubscription__r.SBQQ__Contract__c,
                                                         SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__SubscriptionStartDate__c,
                                                         SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__SubscriptionEndDate__c,
                                                         SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__r.EndDate,
                                                         SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__c,
                                                         SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c,
                                                         SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c,
                                                         SBQQ__SubscriptionStartDate__c
                                                         from SBQQ__CoveredAssets__r 
                                                         order by Id DESC) 
                                                        from SBQQ__Subscription__c 
                                                        ];
        	
        	AssetCreationBatchHandler.debookRenewalAsset(subscriptionList[0],subscriptionList[3]);
    }
    
    static testMethod void handleExceptiontest(){
        List<Order> lOrder = [Select Id from Order];
        try{
            
            Contract con = new Contract();
            con.SBQQ__Order__c = lOrder[0].Id;
            Test.startTest();
            AssetCreationBatchHandler.handleAssets(con);
            Test.stopTest();
        }catch(Exception ex){
            system.debug('error occurred >>');
        }
        
    }
	
    
}