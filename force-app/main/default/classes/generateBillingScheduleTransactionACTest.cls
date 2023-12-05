/**
*  @Author:        Ramesh M S
*  @Created Date:  2/19/2020
*  @Description:   Test class for generateBillingScheduleTransactionAC with the updated test framework
* Change History
***********************************************************************************************
* ModifiedBy          Date              Requested By        Description                     Tag
*   
***********************************************************************************************
*/
@isTest
private class generateBillingScheduleTransactionACTest{
    
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
        
        
        
        sObject sObj = new blng__BillingRule__c();
        sObject sObj1 = new blng__BillingRule__c();
        sObject sObj2 = new blng__BillingRule__c();
        
        sObj = new blng__BillingRule__c();
        UtilityTestData.mblngBillingRuleData.put('Legal_Entity_Code__c','USA');
        UtilityTestData.mblngBillingRuleData.put('Multi_Country_Mapping2__c','United States');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngBillingRuleData);
        List<blng__BillingRule__c> lBillingRule = (List<blng__BillingRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new blng__RevenueRecognitionRule__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngRevRecRuleData);
        List<blng__RevenueRecognitionRule__c> lRevRecRule = (List<blng__RevenueRecognitionRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new blng__TaxRule__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngTaxRuleData);
        List<blng__TaxRule__c> lTaxRule = (List<blng__TaxRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        //Insert product
        sObj = new Product2();
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('SBQQ__AssetConversion__c','One per unit');
        //Generates_Entitlement__c
        UtilityTestData.mProduct2Data.put('Generates_Entitlement__c','True');
        UtilityTestData.mProduct2Data.put('Offering_Type__c','Cloud Hosted Subscription');
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
        
        sObj1 = new Product2();
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('Name','Test Debook Product');
        UtilityTestData.mProduct2Data.put('SBQQ__AssetConversion__c','One per unit');
        //Generates_Entitlement__c
        UtilityTestData.mProduct2Data.put('Generates_Entitlement__c','True');
        UtilityTestData.mProduct2Data.put('Offering_Type__c','Cloud Hosted Subscription');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProduct2Data);
        
        sObj2 = new Product2();
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('SBQQ__AssetConversion__c','One per unit');
        //Generates_Entitlement__c
        UtilityTestData.mProduct2Data.put('Generates_Entitlement__c','True');
        UtilityTestData.mProduct2Data.put('Offering_Type__c','Cloud Hosted Subscription');
        
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mProduct2Data);
        List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
        
        lProduct2[0].Tax_Product_Type__c = null;
        lProduct2[1].Tax_Product_Type__c = null;
        lProduct2[2].Tax_Product_Type__c = null;
        lProduct2[0].Edition__c = 'Test';
        lProduct2[1].Edition__c = 'Test';
        lProduct2[2].Edition__c = 'Test Overage';
        lProduct2[0].Business_Unit__c = 'Secure Archiving';
        lProduct2[1].Business_Unit__c = 'Secure Archiving';
        lProduct2[2].Business_Unit__c = 'Data as a Service';
        
        update lProduct2 ;
        
        //Get the Standard Pricebook id
        Id pricebookId = Test.getStandardPricebookId(); 
        
        //Get the activated pricebook id
        sObj = new Pricebook2(Id = pricebookId,IsActive = True);
        List<Pricebook2> lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        
        //Insert the pricebook entry
        sObj = new pricebookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',lPriceBook2[0].Id);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);
        
        sObj1 = new pricebookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',lPriceBook2[0].Id);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[1].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mPriceBookEntryData);
        
        List<pricebookEntry> lPriceBookEntry = (List<pricebookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        sObj = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        
        Id cometitorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor Account').getRecordTypeId();
        sObj1 = new Account(RecordTypeId =cometitorRecordTypeId, Name = 'Test competitor Account', BillingCountry ='India');
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1});
        
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Opportunity(Name = 'Test Opportunity for Custom Billing 1', StageName = 'Validate', CloseDate=System.today(), AccountId = lAccount[0].Id, Type='Direct', CurrencyIsoCode='USD', Sales_Play__c='Data Integration', Pricebook2Id=lPriceBook2[0].Id);
        
        sObj1 = new Opportunity(Name = 'Test Opportunity for Custom Billing 2', StageName = 'Validate', CloseDate=System.today(), AccountId = lAccount[0].Id, Type='Direct', CurrencyIsoCode='USD', Sales_Play__c='Data Integration', Pricebook2Id=lPriceBook2[0].Id);
        
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        
        
        sObj = new Competitor_Relationship__c();
        UtilityTestData.mCompetitorData.put('Competitor_Account__c',lAccount[1].Id);
        UtilityTestData.mCompetitorData.put('Opportunity__c',lOpportunity[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCompetitorData);
        List<Competitor_Relationship__c> lCompetitorData = (List<Competitor_Relationship__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunity[0].Id);
        UtilityTestData.mOpportunityContactRoleData.put('ContactId',lContact[0].Id);
        UtilityTestData.mOpportunityContactRoleData.put('Role', 'End User');
        sObj = new OpportunityContactRole();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityContactRoleData);
        
        UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunity[1].Id);
        UtilityTestData.mOpportunityContactRoleData.put('ContactId',lContact[0].Id);
        UtilityTestData.mOpportunityContactRoleData.put('Role', 'End User');
        sObj1 = new OpportunityContactRole();
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityContactRoleData);
        
        List<OpportunityContactRole> lContactRoles = (List<OpportunityContactRole>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        
        sObj = new blng__LegalEntity__c();
        UtilityTestData.mLegalEntityData.put('Name','test');
        UtilityTestData.mLegalEntityData.put('Legal_Entity_Code__c','test123');
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
        UtilityTestData.mSBQuoteData.put('SBQQ__BillingFrequency__c','Invoice Plan');
        UtilityTestData.mSBQuoteData.put('BillToContact__c',lContact[0].Id);
        UtilityTestData.mSBQuoteData.put('ShipToContact__c',lContact[0].Id);
        UtilityTestData.mSBQuoteData.put('EndUserContact__c',lContact[0].Id);
        UtilityTestData.mSBQuoteData.put('SoldToContact__c',lContact[0].Id);
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        
        
        sObj1 = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunity[1].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__PriceBook__c',lPriceBook2[0].Id);
        UtilityTestData.mSBQuoteData.put('Price_Book_2__c',lPriceBook2[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__PricebookId__c',lPriceBook2[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__PriceBook__c',lPriceBook2[0].Id);
        UtilityTestData.mSBQuoteData.put('Legal_Entity__c',lLegalEntity[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__BillingFrequency__c','Invoice Plan');
        UtilityTestData.mSBQuoteData.put('BillToContact__c',lContact[0].Id);
        UtilityTestData.mSBQuoteData.put('ShipToContact__c',lContact[0].Id);
        UtilityTestData.mSBQuoteData.put('EndUserContact__c',lContact[0].Id);
        UtilityTestData.mSBQuoteData.put('SoldToContact__c',lContact[0].Id);
        
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        
        
        
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
        
        
        sObj1 = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[1].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[0].Id);
        UtilityTestData.mQuoteLineData.put('Purchase_Order_PO_Number__c','111111111');
        UtilityTestData.mQuoteLineData.put('SBQQ__ListPrice__c','100');
        UtilityTestData.mQuoteLineData.put('SBQQ__NetPrice__c','100');
        UtilityTestData.mQuoteLineData.put('SBQQ__Number__c','1');
        UtilityTestData.mQuoteLineData.put('SBQQ__ChargeType__c','Recurring');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingType__c','Advance');
        UtilityTestData.mQuoteLineData.put('Transaction_Type__c','New');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingFrequency__c','Invoice Plan');
        UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.today()+'');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
        Test.startTest();
        
        List<SBQQ__QuoteLine__c> lSBQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        
        
        
        
        System.runAs(new User(Id=UserInfo.getUserId()))  {
            
            
            
            lOpportunity[0].Pricebook2Id = priceBookId;
            lOpportunity[0].StageName = 'Closed Won';
            lOpportunity[0].Stage_Reason__c = 'Won : Test class';
            
            lOpportunity[1].Pricebook2Id = priceBookId;
            lOpportunity[1].StageName = 'Closed Won';
            lOpportunity[1].Stage_Reason__c = 'Won : Test class';
            
            update lOpportunity;
            
            lSBQuote[0].Price_Book_2__c = priceBookId;
            lSBQuote[0].SBQQ__PricebookId__c = priceBookId;
            
            lSBQuote[1].Price_Book_2__c = priceBookId;
            lSBQuote[1].SBQQ__PricebookId__c = priceBookId;
            update lSBQuote;
            
            
            
            
            /*sObj = new Opportunity(Id = lOpportunity[0].id ,StageName = 'Closed Won',Stage_Reason__c='Won : Test class');

sObj1 = new Opportunity(Id = lOpportunity[1].id ,StageName = 'Closed Won',Stage_Reason__c='Won : Test class');

List<Opportunity> lOpportunityUpdated = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj,sObj1});*/
            
            
            sObj = new SBQQ__Quote__c(Id = lSBQuote[0].Id ,SBQQ__Status__c = 'Approved',SBQQ__Ordered__c = True, SBQQ__Primary__c = True,ApprovalStatus__c='Approved', ShiptToAccount__c=lAccount[0].Id, BillToAccount__c=lAccount[0].Id, EndUserAccount__c=lAccount[0].Id, SoldToAccount__c=lAccount[0].Id, EndUserContact__c=lContact[0].Id, BillToContact__c=lContact[0].Id, ShipToContact__c=lContact[0].Id, SoldToContact__c=lContact[0].Id); //<T1> Last two arguments);
            
            sObj1 = new SBQQ__Quote__c(Id = lSBQuote[1].Id ,SBQQ__Status__c = 'Approved', SBQQ__Ordered__c = True, SBQQ__Primary__c = True,ApprovalStatus__c='Approved', ShiptToAccount__c=lAccount[0].Id, BillToAccount__c=lAccount[0].Id, EndUserAccount__c=lAccount[0].Id, SoldToAccount__c=lAccount[0].Id, EndUserContact__c=lContact[0].Id, BillToContact__c=lContact[0].Id, ShipToContact__c=lContact[0].Id, SoldToContact__c=lContact[0].Id); //<T1> Last two arguments);
            
            List<SBQQ__Quote__c> lQuoteUpdated = (List<SBQQ__Quote__c>) UtilityTest.makeUpdate(new List<sObject>{sObj,sObj1});
            
            Set<Id> quoteIds = new Set<Id>();
            quoteIds.add(lSBQuote[0].Id);
            
            
            List<Order> lOrder = [Select Id from Order where SBQQ__Quote__c IN: quoteIds];
            
            /*List<OrderItem> lOrderItems = [Select Id,SBQQ__BillingFrequency__c, orderid from OrderItem where Order.SBQQ__Quote__c IN : quoteIds];
for(OrderItem li:lOrderItems)
{
system.debug('check>>'+li.SBQQ__BillingFrequency__c);
system.debug('check>>'+li.orderid);
}  
Set<id> orderIds = new Set<id>();
if(!lOrder.isEmpty() ){
orderIds.add(lOrder[0].Id);
orderIds.add(lOrder[1].Id);
ActivateOrderFuture.activateOrder(orderIds);
} */
            
            sObj = new Order(Id = lOrder[0].Id ,Status = 'Activated',SBQQ__PriceCalcStatus__c = 'Not Needed',Shipping_Email__c = 'test@test.com');        
            //sObj1 = new Order(Id = lOrder[1].Id ,Status = 'Activated',SBQQ__PriceCalcStatus__c = 'Not Needed',Shipping_Email__c = 'test@test.com');
            
            lOrder = (List<Order>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            Test.stopTest();
        }
        
    }
    
    @isTest
    static void custombillingAmt(){
        Test.startTest();
        List<Order> lOrder = [Select Id,Name,status,SBQQ__Quote__c from Order where Order.Opportunity.Name = 'Test Opportunity for Custom Billing 1' Limit 2];
        List<OrderItem> lOrderItems = [Select Id,CurrencyIsoCode,TotalPrice, blng__BillingTreatment__r.blng__InvoicePlan__c,Quantity,ServiceDate,EndDate from OrderItem where OrderId =: lOrder[0].id Limit 1];         
        sObject sObj = new Invoice_Schedule__c ();
        UtilityTestData.mBillPlanDataAmt.put('Bill_Amount__c','100');
        UtilityTestData.mBillPlanDataAmt.put('Order__c',lOrder[0].Id);
        UtilityTestData.mBillPlanDataAmt.put('Invoice_Date__c',System.TODAY()+'');
        UtilityTestData.mBillPlanDataAmt.put('CurrencyIsoCode','USD');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mBillPlanDataAmt);
        
        
        generateBillingScheduleTransactionAC.onLoadCmp(lOrder[0].Id);
        
        List<Invoice_Schedule__c> lSBillPlan = (List<Invoice_Schedule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Order(Id = lOrder[0].Id ,Status = 'Bill & Contract');
        lOrder = (List<Order>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        
        generateBillingScheduleTransactionAC.onLoadCmp(lOrder[0].Id);
        List<blng__BillingSchedule__c> BSList = new List<blng__BillingSchedule__c>();         
        for(OrderItem lOrderItem:lOrderItems)
        {
            system.debug('BSLISTS'+lOrderItem.id);
            blng__BillingSchedule__c blngBS = new blng__BillingSchedule__c ();
            blngBS.Name = 'TestBS'+lOrderItem.id ;
            blngBS.blng__Amount__c = lOrderItem.TotalPrice;
            blngBS.blng__InvoicePlan__c = lOrderItem.blng__BillingTreatment__r.blng__InvoicePlan__c;
            blngBS.Order_LKP__c = lOrder[0].Id;
            blngBS.blng__OrderProduct__c = lOrderItem.Id;
            blngBS.CurrencyIsoCode = lOrderItem.CurrencyIsoCode;  
            BSList.add(blngBS);           
        }         
        Insert BSList;
        generateBillingScheduleTransactionAC.createBillingScheduleTransaction(lOrder[0].Id,'New');
        
        Test.StopTest();
        
        
        
    }
    
    @isTest
    static void custombillingPer(){
        Test.startTest();
        List<Order> lOrder = [Select Id,Name,status,SBQQ__Quote__c from Order where Order.Opportunity.Name = 'Test Opportunity for Custom Billing 2' Limit 2];
        List<OrderItem> lOrderItems = [Select Id,CurrencyIsoCode,TotalPrice, blng__BillingTreatment__r.blng__InvoicePlan__c,Quantity,ServiceDate,EndDate from OrderItem where OrderId =: lOrder[0].id Limit 1];         
        sObject sObj1 = new Order();
        generateBillingScheduleTransactionAC.onLoadCmp(lOrder[0].Id);
        sObj1 = new Order(Id = lOrder[0].Id ,Status = 'Activated',SBQQ__PriceCalcStatus__c = 'Not Needed',Shipping_Email__c = 'test@test.com');
        lOrder = (List<Order>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
        sObj1 = new Invoice_Schedule__c ();
        UtilityTestData.mBillPlanDataPer.put('Bill_Percentage__c','100');
        UtilityTestData.mBillPlanDataPer.put('Order__c',lOrder[0].Id);
        UtilityTestData.mBillPlanDataPer.put('Invoice_Date__c',system.TODAY()+'');
        UtilityTestData.mBillPlanDataAmt.put('CurrencyIsoCode','USD');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mBillPlanDataPer);
        List<Invoice_Schedule__c> lSBillPlan = (List<Invoice_Schedule__c>) UtilityTest.makeInsert(new List<sObject>{sObj1});
        sObj1 = new Order(Id = lOrder[0].Id ,Status = 'Bill & Contract');
        lOrder = (List<Order>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
        generateBillingScheduleTransactionAC.onLoadCmp(lOrder[0].Id);
        List<blng__BillingSchedule__c> BSList = new List<blng__BillingSchedule__c>();         
        for(OrderItem lOrderItem:lOrderItems)
        {
            system.debug('BSLISTS'+lOrderItem.id);
            blng__BillingSchedule__c blngBS = new blng__BillingSchedule__c ();
            blngBS.Name = 'TestBS'+lOrderItem.id ;
            blngBS.blng__Amount__c = lOrderItem.TotalPrice;
            blngBS.blng__InvoicePlan__c = lOrderItem.blng__BillingTreatment__r.blng__InvoicePlan__c;
            blngBS.Order_LKP__c = lOrder[0].Id;
            blngBS.blng__OrderProduct__c = lOrderItem.Id;
            blngBS.CurrencyIsoCode = lOrderItem.CurrencyIsoCode;  
            BSList.add(blngBS);           
        }   
        BSList.remove(0);
        Insert BSList;     
        
        generateBillingScheduleTransactionAC.createBillingScheduleTransaction(lOrder[0].Id,'New');
        Test.StopTest();
    }
    
    @isTest
    static void custombillingCancel(){
        Test.startTest();
        List<Order> lOrder = [Select Id,Name,status,SBQQ__Quote__c from Order where Order.Opportunity.Name = 'Test Opportunity for Custom Billing 1' Limit 2];  
        generateBillingScheduleTransactionAC.cancelBillingScheduleTransaction(lOrder[0].Id);
        Test.StopTest();
    }
    
    @isTest
    static void custombillingCancelRegenerate(){
        Test.startTest();
        List<Order> lOrder = [Select Id,Name,status,SBQQ__Quote__c from Order where Order.Opportunity.Name = 'Test Opportunity for Custom Billing 1' Limit 2];
        generateBillingScheduleTransactionAC.cancelandRegenerate(lOrder[0].Id);
        Test.StopTest();
    }
    
    @isTest
    static void InvokableGenerateFulfillmentsTest1(){
        Test.startTest();
        List<Order> lOrder = [Select Id,Name,status,SBQQ__Quote__c from Order where Order.Opportunity.Name = 'Test Opportunity for Custom Billing 1' Limit 2];
        List<id> fflist = new List<id>();
        for(Order li:lOrder) {
            fflist.add(li.id);  
        }       
        InvokableGenerateFulfillments.invokeFulfillmentCreation(fflist);       
        Test.StopTest();
    }
    
    @isTest
    static void InvokableGenerateFulfillmentsTest2(){
        Test.startTest();
        List<Order> lOrder = [Select Id,Name,status,SBQQ__Quote__c from Order where Order.Opportunity.Name = 'Test Opportunity for Custom Billing 2' Limit 2];
        List<id> fflist = new List<id>();
        for(Order li:lOrder) {
            fflist.add(li.id);  
        }
        InvokableGenerateFulfillments.invokeFulfillmentCreation(fflist);
        Test.StopTest();
    }
}