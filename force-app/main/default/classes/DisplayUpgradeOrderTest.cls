/**
*  @Author:        Anil Solanki
*  @Created Date:  11/15/2019
*  @Description:   Test class for DisplayUpgradeOrder with the updated test framework
* Change History
***********************************************************************************************
* ModifiedBy          Date              Requested By        Description                     Tag
*   
***********************************************************************************************
*/
@isTest
private class DisplayUpgradeOrderTest{

      private Final Static String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
    private Final Static String ACC_Prospect_Account_Record_Type = Label.Prospect_Account_Record_Type;
    
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
        
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;
        
        sObject sObjb = new blng__BillingRule__c();
        sObject sObjc = new blng__BillingRule__c();
        sObject sObjd = new blng__BillingRule__c();
        
        sObjb = new blng__BillingRule__c();
        UtilityTestData.mblngBillingRuleData.put('Legal_Entity_Code__c','USA');
        UtilityTestData.mblngBillingRuleData.put('Multi_Country_Mapping2__c','United States');
        sObjb = UtilityTest.putFieldRecord(sObjb, UtilityTestData.mblngBillingRuleData);
        List<blng__BillingRule__c> lBillingRule = (List<blng__BillingRule__c>) UtilityTest.makeInsert(new List<sObject>{sObjb});
        
        sObjb = new blng__RevenueRecognitionRule__c();
        sObjb = UtilityTest.putFieldRecord(sObjb, UtilityTestData.mblngRevRecRuleData);
        List<blng__RevenueRecognitionRule__c> lRevRecRule = (List<blng__RevenueRecognitionRule__c>) UtilityTest.makeInsert(new List<sObject>{sObjb});
        
        sObjb = new blng__TaxRule__c();
        sObjb = UtilityTest.putFieldRecord(sObjb, UtilityTestData.mblngTaxRuleData);
        List<blng__TaxRule__c> lTaxRule = (List<blng__TaxRule__c>) UtilityTest.makeInsert(new List<sObject>{sObjb});
        
        //Set up object data
        //Account object data
        sObject sObj = new Account();
        sObject sObj1 = new Account();
        sObject sObj2 = new Account();
        UtilityTestData.mAccountData.put('RecordTypeId', Schema.SObjectType.Account.getRecordTypeInfosByName().get(ACC_Prospect_Account_Record_Type).getRecordTypeId());
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData); 
        
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
        sObj = new Contact();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Insert Opportunity
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
        UtilityTestData.mOpportunityData.put('Type', 'New');
        UtilityTestData.mOpportunityData.put('CloseDate',System.today()+'');
        UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Commit');
        sObj = new Opportunity();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        
        sObj1 = new Opportunity();
        UtilityTestData.mOpportunityData.put('Name', 'Test Oppty2');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunityRecord = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        sObj = new Product2();
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
        
        sObj1 = new Product2();
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('Name','Test Debook Product');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProduct2Data);
        
        sObj2 = new Product2();
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('Name','Test Product Linkage');
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mProduct2Data);
        List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
        
        //Standard PriceBook
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
                
        
        //Insert a legal entity record
        sObj = new blng__LegalEntity__c();
        UtilityTestData.mLegalEntityData.put('Name','test');
        UtilityTestData.mLegalEntityData.put('Legal_Entity_Code__c','test123');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalEntityData);
        List<blng__LegalEntity__c> lLegalEntity = (List<blng__LegalEntity__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunityRecord[0].Id);
        UtilityTestData.mSBQuoteData.put('Legal_Entity__c',lLegalEntity[0].Id);
        UtilityTestData.mSBQuoteData.put('Shipping_Preference__c','Email');
        UtilityTestData.mSBQuoteData.put('BillToAccount__c',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('ShiptToAccount__c',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Type__c','Quote');
        UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c',System.Today() + '');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        
        sObj1 = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunityRecord[1].Id);
        UtilityTestData.mSBQuoteData.put('Legal_Entity__c',lLegalEntity[0].Id);
        UtilityTestData.mSBQuoteData.put('Shipping_Preference__c','Email');
        UtilityTestData.mSBQuoteData.put('BillToAccount__c',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('ShiptToAccount__c',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Type__c','Quote');
        UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c',System.Today() + '');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mSBQuoteData);
        
        List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        sObj = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
        
        sObj1 = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[1].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.today()+'');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
        
        sObj2 = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[1].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.today()+'');
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);
        
           Test.startTest();
        
        List<SBQQ__QuoteLine__c> lSBQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
        
        //Create related Order record
        sObj = new Order();
        UtilityTestData.mOrderData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOrderData.put('SoldToAccount__c',lAccount[0].Id);
        UtilityTestData.mOrderData.put('SoldToContact__c',lContact[0].Id);
        UtilityTestData.mOrderData.put('EndUserAccount__c',lAccount[0].Id);
        UtilityTestData.mOrderData.put('EndUserContact__c',lContact[0].Id);
        UtilityTestData.mOrderData.put('ShipToAccount__c',lAccount[0].Id);
        UtilityTestData.mOrderData.put('BilltoAccount__c',lAccount[0].Id);
        UtilityTestData.mOrderData.put('SBQQ__Quote__c',lSBQuote[0].Id);
        UtilityTestData.mOrderData.put('Pricebook2Id',lPriceBook2[0].Id);
        UtilityTestData.mOrderData.put('SBQQ__PriceCalcStatus__c','Completed'); 
        UtilityTestData.mOrderData.put('EffectiveDate',System.today()+'');
        UtilityTestData.mOrderData.put('Type','New');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderData);
        
        sObj1 = new Order();
        UtilityTestData.mOrderData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOrderData.put('SoldToAccount__c',lAccount[0].Id);
        UtilityTestData.mOrderData.put('SoldToContact__c',lContact[0].Id);
        UtilityTestData.mOrderData.put('EndUserAccount__c',lAccount[0].Id);
        UtilityTestData.mOrderData.put('EndUserContact__c',lContact[0].Id);
        UtilityTestData.mOrderData.put('ShipToAccount__c',lAccount[0].Id);
        UtilityTestData.mOrderData.put('BilltoAccount__c',lAccount[0].Id);
        UtilityTestData.mOrderData.put('SBQQ__Quote__c',lSBQuote[1].Id);
        UtilityTestData.mOrderData.put('Pricebook2Id',lPriceBook2[0].Id);
        UtilityTestData.mOrderData.put('SBQQ__PriceCalcStatus__c','Completed'); 
        UtilityTestData.mOrderData.put('EffectiveDate',System.today()+'');
        UtilityTestData.mOrderData.put('Type','New');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOrderData);
        
        List<Order> lOrder = (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        
        sObj = new OrderItem();
        UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',lSBQuoteLine[0].Id);
        UtilityTestData.mOrderItemData.put('OrderId',lOrder[0].Id);
        UtilityTestData.mOrderItemData.put('PricebookEntryId',lPriceBookEntry[0].Id);
        UtilityTestData.mOrderItemData.put('blng__LegalEntity__c',lLegalEntity[0].Id);
        UtilityTestData.mOrderItemData.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mOrderItemData.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mOrderItemData.put('blng__TaxRule__c',lTaxRule[0].Id);
        UtilityTestData.mOrderItemData.put('ServiceDate',System.today() + '');
        UtilityTestData.mOrderItemData.put('blng__NextChargeDate__c',System.Today().addDays(360) + '');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderItemData);
        
        sObj1 = new OrderItem();
        UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',lSBQuoteLine[1].Id);
        UtilityTestData.mOrderItemData.put('OrderId',lOrder[1].Id);
        UtilityTestData.mOrderItemData.put('PricebookEntryId',lPriceBookEntry[0].Id);
        UtilityTestData.mOrderItemData.put('blng__LegalEntity__c',lLegalEntity[0].Id);
        UtilityTestData.mOrderItemData.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mOrderItemData.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mOrderItemData.put('blng__TaxRule__c',lTaxRule[0].Id);
        UtilityTestData.mOrderItemData.put('ServiceDate',System.today() + '');
        UtilityTestData.mOrderItemData.put('blng__NextChargeDate__c',System.Today().addDays(360) + '');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOrderItemData);
        
        sObj2 = new OrderItem();
        UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',lSBQuoteLine[1].Id);
        UtilityTestData.mOrderItemData.put('OrderId',lOrder[1].Id);
        UtilityTestData.mOrderItemData.put('PricebookEntryId',lPriceBookEntry[0].Id);
        UtilityTestData.mOrderItemData.put('blng__LegalEntity__c',lLegalEntity[0].Id);
        UtilityTestData.mOrderItemData.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mOrderItemData.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mOrderItemData.put('blng__TaxRule__c',lTaxRule[0].Id);
        UtilityTestData.mOrderItemData.put('ServiceDate',System.today() + '');
        UtilityTestData.mOrderItemData.put('blng__NextChargeDate__c',System.Today().addDays(360) + '');
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mOrderItemData);
        
        //List<OrderItem> lOrderItem = (List<OrderItem>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
        
        sObj = new Old_Org_Order__c();
        sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mOldOrgOrderData );
        List<Old_Org_Order__c>  lOldOrgOrder = (List<Old_Org_Order__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj1 = new Old_Org_Order_Detail__c();
        UtilityTestData.mOldOrgOrderDetailData.put('Old_Org_Order__c',lOldOrgOrder[0].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1,UtilityTestData.mOldOrgOrderDetailData );
        List<Old_Org_Order_Detail__c>  lOldOrgOrderDetails = (List<Old_Org_Order_Detail__c>) UtilityTest.makeInsert(new List<sObject>{sObj1});
        
         Test.stopTest();
        
    }
    
    static testmethod void DisplayOrderApttusTest(){
        List<Order> lOrder = [Select Id from Order];
        List<OrderItem> lOrderItems = [Select Id from OrderItem];
        
        List<Old_Org_Order__c> lOldOrgOrder = [Select Id,Name from Old_Org_Order__c];
        List<Old_Org_Order_Detail__c> lOldOrgOrderDetails = [Select Id,Name,Extended_Price__c,Old_Org_Order__c,Old_Org_Order_Name__c    ,Quantity__c,SKU_Name__c from Old_Org_Order_Detail__c];
       
        List<Previous_Order__c> POList = new List<Previous_Order__c>();
        List<Previous_Order_Detail__c> poDetailList = new List<Previous_Order_Detail__c>();
      
        Test.startTest();
            Previous_Order__c po = new Previous_Order__c();
            po.Previous_Order_Apttus__c = lOldOrgOrder[0].Id;
            po.Previous_Order_Notes__c = 'Test';
            po.Order__c = lOrder[1].Id;
            insert po;
            
            Previous_Order_Detail__c poDetail = new Previous_Order_Detail__c();
            //poDetail.Order_Product__c = lOrderItems[1].Id;
            poDetail.Order__c = lOrder[1].Id;
            poDetail.Previous_Order_Line_Apttus__c = lOldOrgOrderDetails[0].id;
            poDetail.Previous_Order_Apttus__c = lOldOrgOrder[0].id;
            poDetail.Upgrade_Percentage__c = 10;
            poDetail.Upgrade_Quantity__c = 5;
            poDetailList.add(poDetail);
            
            insert poDetail;
            
            PageReference pageRef = page.DisplayUpgradeOrder;
            pageRef.getParameters().put('id', String.valueOf(lOrder[1].Id));
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(lOrder[1]);
            DisplayUpgradeOrder controller = new DisplayUpgradeOrder(sc);
            
        Test.stopTest();
    }
    
    static testmethod void DisplayOrderCPQTest(){
        List<Order> lOrder = [Select Id from Order];
        List<OrderItem> lOrderItems = [Select Id from OrderItem];
        
        List<Old_Org_Order__c> lOldOrgOrder = [Select Id,Name from Old_Org_Order__c];
        List<Old_Org_Order_Detail__c> lOldOrgOrderDetails = [Select Id,Name,Extended_Price__c,Old_Org_Order__c,Old_Org_Order_Name__c    ,Quantity__c,SKU_Name__c from Old_Org_Order_Detail__c];
       
        List<Previous_Order__c> POList = new List<Previous_Order__c>();
        List<Previous_Order_Detail__c> poDetailList = new List<Previous_Order_Detail__c>();
      
        Test.startTest();
            Previous_Order__c po = new Previous_Order__c();
            po.Previous_Order_Apttus__c = lOldOrgOrder[0].Id;
            po.Previous_Order_Notes__c = 'Test';
            po.Order__c = lOrder[1].Id;
            insert po;
            
            Previous_Order_Detail__c poDetail = new Previous_Order_Detail__c();
            //poDetail.Order_Product__c = lOrderItems[2].Id;
            poDetail.Order__c = lOrder[1].Id;
            //poDetail.Previous_Order_Line_CPQ__c = lOrderItems[0].id;
            poDetail.Previous_Order_CPQ__c = lOrder[0].id;
            poDetail.Upgrade_Percentage__c = 10;
            poDetail.Upgrade_Quantity__c = 5;
            poDetailList.add(poDetail);
            
            insert poDetail;
            
            PageReference pageRef = page.DisplayUpgradeOrder;
            pageRef.getParameters().put('id', String.valueOf(lOrder[1].Id));
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(lOrder[1]);
            DisplayUpgradeOrder controller = new DisplayUpgradeOrder(sc);
            
         Test.stopTest();
    }
    
    static testmethod void DisplayOrderNoUpgradeTest(){
        List<Order> lOrder = [Select Id from Order];
        List<OrderItem> lOrderItems = [Select Id from OrderItem];
        
        Test.startTest();
            
            PageReference pageRef = page.DisplayUpgradeOrder;
            pageRef.getParameters().put('id', String.valueOf(lOrder[0].Id));
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(lOrder[0]);
            DisplayUpgradeOrder controller = new DisplayUpgradeOrder(sc);
            
        Test.stopTest();
    }


}