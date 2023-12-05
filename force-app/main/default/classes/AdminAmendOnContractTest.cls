/**
* 
*  @Author: Kiran G   
*  @Created Date:  
*  @Description:   Test class for AdminAmend with the updated test framework
* Change History
******************************************************************
* ModifiedBy          Date        Requested By        Description                 Tag
* 
******************************************************************
*/
@isTest
private class AdminAmendOnContractTest
{

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
        
        // Set all the required fields and dynamic ids in Map : Contact 1
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
        //UtilityTestData.mOpportunityData.put('OrderableIn__c', 'New');
        sObj = new Opportunity();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        
        //for
        sObj1 = new Opportunity();
        UtilityTestData.mOpportunityData.put('Name', 'Test Admin Amend');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityData);
        
        //Oppty
        sObj2 = new Opportunity();
        UtilityTestData.mOpportunityData.put('Name', 'Test Admin Amend');
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mOpportunityData);
        
        List<Opportunity> lOpportunityRecord = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
        
        //Insert Opportunity Contact Roles
        UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunityRecord[0].Id);
        UtilityTestData.mOpportunityContactRoleData.put('ContactId',lContact[0].Id);
        UtilityTestData.mOpportunityContactRoleData.put('Role', 'End User');
        sObj = new OpportunityContactRole();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityContactRoleData);
        
        sObj1 = new OpportunityContactRole();
        UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunityRecord[1].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityContactRoleData);
        
        sObj2 = new OpportunityContactRole();
        UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunityRecord[2].Id);
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mOpportunityContactRoleData);
        
        List<OpportunityContactRole> lContactRoles = (List<OpportunityContactRole>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
       
        
        sObj = new Product2();
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('Is_Parent__c','TRUE');
        UtilityTestData.mProduct2Data.put('SBQQ__SubscriptionPricing__c','Fixed Price');
        UtilityTestData.mProduct2Data.put('SBQQ__ChargeType__c','Recurring');
        UtilityTestData.mProduct2Data.put('SBQQ__BillingFrequency__c','Monthly');
        UtilityTestData.mProduct2Data.put('SBQQ__BillingType__c','Advance');
        UtilityTestData.mProduct2Data.put('Offering_Type__c','Cloud Hosted Subscription');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
        
        sObj1 = new Product2();
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('Name','Test AdminAmend Product');
        UtilityTestData.mProduct2Data.put('SBQQ__SubscriptionPricing__c','Fixed Price');
        UtilityTestData.mProduct2Data.put('SBQQ__ChargeType__c','Recurring');
        UtilityTestData.mProduct2Data.put('SBQQ__BillingFrequency__c','Monthly');
        UtilityTestData.mProduct2Data.put('SBQQ__BillingType__c','Advance');
        UtilityTestData.mProduct2Data.put('Offering_Type__c','Cloud Hosted Subscription');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProduct2Data);
        List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        SBQQ__ProductFeature__c feature = new SBQQ__ProductFeature__c();
        feature.Name = 'Included' ;
        feature.SBQQ__MinOptionCount__c = 0;
        feature.SBQQ__Number__c = 10;
        feature.SBQQ__ConfiguredSKU__c = lProduct2[0].Id;
        
        insert feature;
        
        SBQQ__ProductOption__c option = new SBQQ__ProductOption__c();
        option.SBQQ__Number__c = 10;
        option.SBQQ__Quantity__c = 1;
        option.SBQQ__Selected__c = TRUE;
        option.SBQQ__Selected__c = TRUE;
        option.SBQQ__ConfiguredSKU__c = lProduct2[0].Id;
        option.SBQQ__OptionalSKU__c = lProduct2[1].Id;
        option.SBQQ__Bundled__c = TRUE;
        
        insert option;
        
        //Standard PriceBook
        Id pricebookId = Test.getStandardPricebookId(); 
        
        sObj = new Pricebook2(Id = pricebookId,IsActive = True);
        List<Pricebook2> lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        
        sObj = new pricebookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',lPriceBook2[0].Id);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[0].Id);
        UtilityTestData.mPriceBookEntryData.put('UnitPrice','100');
        UtilityTestData.mPriceBookEntryData.put('IsActive','TRUE');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData); 
        
        sObj1 = new pricebookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',lPriceBook2[0].Id);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[1].Id);
        UtilityTestData.mPriceBookEntryData.put('UnitPrice','100');
        UtilityTestData.mPriceBookEntryData.put('IsActive','TRUE');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mPriceBookEntryData); 
       
        List<pricebookEntry> lPriceBookEntry = (List<pricebookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
                
        
        //Insert a legal entity record
        sObj = new blng__LegalEntity__c();
        UtilityTestData.mLegalEntityData.put('Name','test');
        UtilityTestData.mLegalEntityData.put('Legal_Entity_Code__c','test123');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalEntityData);
        List<blng__LegalEntity__c> lLegalEntity = (List<blng__LegalEntity__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Create Quote
        sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunityRecord[0].Id);
        UtilityTestData.mSBQuoteData.put('Legal_Entity__c',lLegalEntity[0].Id);
        UtilityTestData.mSBQuoteData.put('Shipping_Preference__c','Email');
        UtilityTestData.mSBQuoteData.put('BillToAccount__c',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('ShiptToAccount__c',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Type__c','Quote');
        UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c',System.Today() + '');
        UtilityTestData.mSBQuoteData.put('Price_Book_2__c',lPriceBook2[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__PricebookId__c',lPriceBook2[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__PriceBook__c',lPriceBook2[0].Id);
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
        UtilityTestData.mSBQuoteData.put('Price_Book_2__c',lPriceBook2[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__PricebookId__c',lPriceBook2[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__PriceBook__c',lPriceBook2[0].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mSBQuoteData);
        
        /*
        sObj2 = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunityRecord[2].Id);
        UtilityTestData.mSBQuoteData.put('Legal_Entity__c',lLegalEntity[0].Id);
        UtilityTestData.mSBQuoteData.put('Shipping_Preference__c','Email');
        UtilityTestData.mSBQuoteData.put('BillToAccount__c',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('ShiptToAccount__c',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Type__c','Quote');
        UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c',System.Today() + '');
        UtilityTestData.mSBQuoteData.put('Price_Book_2__c',lPriceBook2[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__PricebookId__c',lPriceBook2[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__PriceBook__c',lPriceBook2[0].Id);
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mSBQuoteData);*/
        List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        //Create QuoteLineItem
        sObj = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__PricebookEntryId__c',lPriceBookEntry[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__ListPrice__c','100');
        UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.today()+'');
        UtilityTestData.mQuoteLineData.put('SBQQ__NetPrice__c','100');
        UtilityTestData.mQuoteLineData.put('SBQQ__Number__c','1');
        UtilityTestData.mQuoteLineData.put('SBQQ__ChargeType__c','Recurring');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingType__c','Advance');
        UtilityTestData.mQuoteLineData.put('Transaction_Type__c','New');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingFrequency__c','Annual');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
        
        //For 
        sObj1 = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[1].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__PricebookEntryId__c',lPriceBookEntry[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.today()+'');
        UtilityTestData.mQuoteLineData.put('SBQQ__ListPrice__c','100');
        UtilityTestData.mQuoteLineData.put('SBQQ__NetPrice__c','100');
        UtilityTestData.mQuoteLineData.put('SBQQ__Number__c','1');
        UtilityTestData.mQuoteLineData.put('SBQQ__ChargeType__c','Recurring');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingType__c','Advance');
        UtilityTestData.mQuoteLineData.put('Transaction_Type__c','New');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingFrequency__c','Annual');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
        
        /*sObj2 = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[2].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__PricebookEntryId__c',lPriceBookEntry[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.today()+'');
        UtilityTestData.mQuoteLineData.put('SBQQ__ListPrice__c','100');
        UtilityTestData.mQuoteLineData.put('SBQQ__NetPrice__c','100');
        UtilityTestData.mQuoteLineData.put('SBQQ__Number__c','1');
        UtilityTestData.mQuoteLineData.put('SBQQ__ChargeType__c','Recurring');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingType__c','Advance');
        UtilityTestData.mQuoteLineData.put('Transaction_Type__c','New');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingFrequency__c','Annual');
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);
        
        sObject sObj3 = new SBQQ__QuoteLine__c();
        sObj3 = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[2].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[1].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__PricebookEntryId__c',lPriceBookEntry[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c',System.today()+'');
        UtilityTestData.mQuoteLineData.put('SBQQ__ListPrice__c','100');
        UtilityTestData.mQuoteLineData.put('SBQQ__NetPrice__c','100');
        UtilityTestData.mQuoteLineData.put('SBQQ__Number__c','1');
        UtilityTestData.mQuoteLineData.put('SBQQ__ChargeType__c','Recurring');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingType__c','Advance');
        UtilityTestData.mQuoteLineData.put('Transaction_Type__c','New');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingFrequency__c','Annual');
        sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mQuoteLineData);*/
       
        Test.startTest();
        List<SBQQ__QuoteLine__c> lSBQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        //Create Order for Quote 1 ----------------------------------------------------------------------------------------------
        sObj1 = new SBQQ__Quote__c(Id = lSBQuote[0].Id ,SBQQ__Status__c = 'Approved', ApprovalStatus__c='Approved', ShiptToAccount__c=lAccount[0].Id, BillToAccount__c=lAccount[0].Id, EndUserAccount__c=lAccount[0].Id, SoldToAccount__c=lAccount[0].Id, EndUserContact__c=lContact[0].Id, BillToContact__c=lContact[0].Id, ShipToContact__c=lContact[0].Id, SoldToContact__c=lContact[0].Id); 
        sObj2 = new SBQQ__Quote__c(Id = lSBQuote[1].Id ,SBQQ__Status__c = 'Approved', ApprovalStatus__c='Approved', ShiptToAccount__c=lAccount[0].Id, BillToAccount__c=lAccount[0].Id, EndUserAccount__c=lAccount[0].Id, SoldToAccount__c=lAccount[0].Id, EndUserContact__c=lContact[0].Id, BillToContact__c=lContact[0].Id, ShipToContact__c=lContact[0].Id, SoldToContact__c=lContact[0].Id); 
        //sObj3 = new SBQQ__Quote__c(Id = lSBQuote[2].Id ,SBQQ__Status__c = 'Approved', ApprovalStatus__c='Approved', ShiptToAccount__c=lAccount[0].Id, BillToAccount__c=lAccount[0].Id, EndUserAccount__c=lAccount[0].Id, SoldToAccount__c=lAccount[0].Id, EndUserContact__c=lContact[0].Id, BillToContact__c=lContact[0].Id, ShipToContact__c=lContact[0].Id, SoldToContact__c=lContact[0].Id); 
        
        List<SBQQ__Quote__c> lQuoteUpdated = (List<SBQQ__Quote__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1,sObj2});
       
        
        sObj1 = new Opportunity(Id = lOpportunityRecord[0].id ,StageName = 'Closed Won', Stage_Reason__c='Won : Test class', Red_Flags__c = 'Pricing',Delivery__c='IPS Implementation', Solutions__c = 'Big Data', Next_Steps__c = 'Test', Current_Status__c  = 'Draft Opportunity Closing Plan');
        sObj2 = new Opportunity(Id = lOpportunityRecord[1].id ,StageName = 'Closed Won', Stage_Reason__c='Won : Test class', Red_Flags__c = 'Pricing',Delivery__c='IPS Implementation', Solutions__c = 'Big Data', Next_Steps__c = 'Test', Current_Status__c  = 'Draft Opportunity Closing Plan');
        //sObj3 = new Opportunity(Id = lOpportunityRecord[2].id ,StageName = 'Closed Won', Stage_Reason__c='Won : Test class', Red_Flags__c = 'Pricing',Delivery__c='IPS Implementation', Solutions__c = 'Big Data', Next_Steps__c = 'Test', Current_Status__c  = 'Draft Opportunity Closing Plan');
        
        List<Opportunity> lOpportunityUpdated2 = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj1,sObj2});
       

        
       
        sObj1 = new SBQQ__Quote__c(Id = lSBQuote[0].id ,SBQQ__Ordered__c = True,SBQQ__Account__c = lAccount[0].Id);
        List<SBQQ__Quote__c> lQuoteUpdated10 = (List<SBQQ__Quote__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
        system.assertEquals(lQuoteUpdated10.size(),1);
        //------------------------------------------------------------------------------------------------------------------------
        
        //Create Order for Quote 2------------------------------------------------------------------------------------------------
 
        sObj2 = new SBQQ__Quote__c(Id = lSBQuote[1].id ,SBQQ__Ordered__c = True,SBQQ__Account__c = lAccount[0].Id);
        List<SBQQ__Quote__c> lQuoteUpdated11 = (List<SBQQ__Quote__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
        system.assertEquals(lQuoteUpdated11.size(),1);
        //------------------------------------------------------------------------------------------------------------------------

        //Create Order for Quote 3------------------------------------------------------------------------------------------------
    
        /*sObj3 = new SBQQ__Quote__c(Id = lSBQuote[2].id ,SBQQ__Ordered__c = True,SBQQ__Account__c = lAccount[0].Id);
        List<SBQQ__Quote__c> lQuoteUpdated12 = (List<SBQQ__Quote__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
        system.assertEquals(lQuoteUpdated12.size(),1);*/
        //------------------------------------------------------------------------------------------------------------------------
        
       
        List<SBQQ__Quote__c> lSBQuotes = [Select Id from SBQQ__Quote__c LIMIT 3];
        
        List<Order> lOrder = [Select Id from Order where SBQQ__Quote__c = : lSBQuotes] ;
        
        //activated Order
        Set<id> orderIds = new Set<id>();
        if(!lOrder.isEmpty() ){
            orderIds.add(lOrder[0].Id);
            //orderIds.add(lOrder[].Id);
            //ActivateOrderFuture.activateOrder(orderIds);
        }
        Test.stopTest();
        
        /*sObj = new Contract();
        sObj = new Contract(StartDate = System.Today().addDays(-300));
        UtilityTestData.mContractData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mContractData.put('SBQQ__Order__c',lOrder[0].Id);
        UtilityTestData.mContractData.put('StartDate', System.Today().addDays(-300)+'');
        UtilityTestData.mContractData.put('Amended_End_Date__c',System.Today().addDays(600)+'');
        UtilityTestData.mContractData.put('EndDate',System.Today().addDays(100)+'');
        UtilityTestData.mContractData.put('ContractTerm','12');
        //<T1>
        UtilityTestData.mContractData.put('SBQQ__Quote__c',lSBQuote[0].Id);
        //<T1>
        //UtilityTestData.mContractData.put('SBQQ__RenewalForecast__c','true');
        sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mContractData);
        List<Contract> lContract  =  (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});
        System.debug('$$$$$..Setup'+lContract[0].SBQQ__Order__c);
             
        sObj = new SBQQ__Subscription__c();
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','10');
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lSBQuoteLine[0].Id);
       
        sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mSBQQSubscriptionData);
        List<SBQQ__Subscription__c > lSubscription  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj});   */         

        
    }//END static void setupTestData()
       
    @isTest
    static void testMethodAdminAmend(){
        Test.startTest();
        Boolean status = AdminAmendOnContract.currentUser();
        Test.stopTest();
    }
    
    //Method to Test Admin Amend on Cntract
    @isTest
    static void AdminAmend(){
    List<Order> lOrder = [Select Id,Name,status,SBQQ__Quote__c  from Order Limit 3];  
    Test.startTest();  
    List<Account> lAccount = [Select Id,Name from Account Limit 1];    
    List<SBQQ__QuoteLine__c> lQuoteLine = [Select Id,SBQQ__StartDate__c from SBQQ__QuoteLine__c Limit 4];
    List<SBQQ__Quote__c> lQuote = [SELECT Id from SBQQ__Quote__c LIMIT 1];
    
   
    List<Product2> lProduct = [SELECT Id from Product2 LIMIT 1];
    
     
    sObject sObj = new Contract();
    
    sObj = new Contract(StartDate = System.Today().addDays(-300));
    UtilityTestData.mContractData.put('AccountId',lAccount[0].Id);
    UtilityTestData.mContractData.put('SBQQ__Order__c',lOrder[0].Id);
    UtilityTestData.mContractData.put('StartDate', System.Today().addDays(-300)+'');
    UtilityTestData.mContractData.put('Amended_End_Date__c',System.Today().addDays(600)+'');
    UtilityTestData.mContractData.put('EndDate',System.Today().addDays(180)+'');
    UtilityTestData.mContractData.put('ContractTerm','10');
    UtilityTestData.mContractData.put('SBQQ__Quote__c',lQuote[0].Id);
    sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mContractData);
    
    
    List<Contract> lContract  =  (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
    sObj = new SBQQ__Subscription__c();
    UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
    UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
    UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','10');
    UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(180)+'');
    UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lQuoteLine[0].Id);
    UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lProduct[0].Id);
    
    sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mSBQQSubscriptionData);
        
    List<SBQQ__Subscription__c > lSubscription  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //List<Contract> lstContracts = [Select Id,Name  from Contract LIMIT 1];
                      
            AdminAmendOnContract.adminAmend(lContract[0].id);
        
    Test.stopTest();
        
        
    }

}