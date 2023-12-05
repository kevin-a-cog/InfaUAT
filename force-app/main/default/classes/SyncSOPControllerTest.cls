@isTest
private class SyncSOPControllerTest {
    
    @testSetup
    static void setupObjectTestData() {
      List<Territory2> lTerritory = (List<Territory2>) UtilityTest.executeQuery('Select Id from Territory2');
      sObject sObj = new Account(); 
      sObject sObj1 = new Opportunity();
      sObject sObj2 = new Opportunity();
      sObject sObj3 = new Opportunity();
      sObject sObj4 = new Opportunity();
      sObject sOppty = new Opportunity();
      sObject sOppty1 = new Opportunity();
      sObject sOppty2 = new Opportunity();
      
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
        
      
      sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
      List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
      
      UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
      sObj = new Contact();
      sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
      List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
      sObj = new blng__LegalEntity__c();
      sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalEntityData);
      List<blng__LegalEntity__c> lLegalEntity = (List<blng__LegalEntity__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
      
      //Anil : Creating Pricebook   
      Id pricebookId = Test.getStandardPricebookId(); 
        
      sObj = new Pricebook2(Id = pricebookId,IsActive = True);
      List<Pricebook2> lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
      
      //String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;                
        String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;  
      
      UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
      UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
      UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
      UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
      UtilityTestData.mOpportunityData.put('Type', 'Direct');
      UtilityTestData.mOpportunityData.put('StageName', 'Validate');
      UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Pipeline');
      UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
      UtilityTestData.mOpportunityData.put('Split_Percentage__c', '50');  
      //UtilityTestData.mOpportunityData.put('Substage__c', 'Sales Won'); 
      //UtilityTestData.mOpportunityData.put('StageName', 'Closed Won');
      //UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c', 'Primary');     
      sObj = new Opportunity();
      sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
      List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
      
      //update the pricebook on Opty
      lOpportunity[0].Pricebook2Id = lPriceBook2[0].Id;
      update lOpportunity[0]; 
      
      /*  
      UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
      UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
      UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
      UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
      UtilityTestData.mOpportunityData.put('Type', 'Direct');
      UtilityTestData.mOpportunityData.put('StageName', 'Validate');
      UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Commit');
      UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
      UtilityTestData.mOpportunityData.put('Split_Percentage__c', '50');     
      //UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c', 'Secondary'); 
      sObj1 = new Opportunity(Split_From__c = lOpportunity[0].Id);
      sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityData);
     
      UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
      UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
      UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
      UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
      UtilityTestData.mOpportunityData.put('Type', 'Direct');
      UtilityTestData.mOpportunityData.put('StageName', 'Validate');
      UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Commit');
      UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
      UtilityTestData.mOpportunityData.put('Split_Percentage__c', '50');     
      //UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c', 'Secondary'); 
      sObj2 = new Opportunity(Split_From__c = lOpportunity[0].Id);
      
      sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mOpportunityData);
      
      UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
      UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
      UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
      UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
      UtilityTestData.mOpportunityData.put('Type', 'Direct');
      UtilityTestData.mOpportunityData.put('StageName', 'Identify');
      UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Commit');
      UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
      UtilityTestData.mOpportunityData.put('Split_Percentage__c', '40');     
      //UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c', 'Secondary'); 
      UtilityTestData.mOpportunityData.put('Name', 'Test Oppty 2');         
      sObj3 = new Opportunity();
      sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mOpportunityData);
      
      sOppty = new Opportunity(Split_From__c = lOpportunity[0].Id);
      
      UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
      UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
      UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
      UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
      UtilityTestData.mOpportunityData.put('Type', 'Direct');
      UtilityTestData.mOpportunityData.put('StageName', 'Validate');
      UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Commit');
      UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
      UtilityTestData.mOpportunityData.put('Split_Percentage__c', '50');     
      //UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c', 'Secondary'); 
      sOppty = UtilityTest.putFieldRecord(sOppty, UtilityTestData.mOpportunityData);
      
      sOppty1 = new Opportunity();
      UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
      UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
      UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
      UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
      UtilityTestData.mOpportunityData.put('Type', 'Direct');
      UtilityTestData.mOpportunityData.put('StageName', 'Validate');
      UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Commit');
      UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
      UtilityTestData.mOpportunityData.put('Split_Percentage__c', '50');     
      //UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c', 'Primary'); 
      sOppty1 = UtilityTest.putFieldRecord(sOppty1, UtilityTestData.mOpportunityData);
      
      List<Opportunity> lOpportunityPrimary2 = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sOppty1});

      sOppty2 = new Opportunity(Split_From__c = lOpportunityPrimary2[0].Id);
      
      UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
      UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
      UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
      UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
      UtilityTestData.mOpportunityData.put('Type', 'Direct');
      UtilityTestData.mOpportunityData.put('StageName', 'Validate');
      UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Commit');
      UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
      UtilityTestData.mOpportunityData.put('Split_Percentage__c', '50');     
      //UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c', 'Secondary');
      UtilityTestData.mOpportunityData.put('CurrencyIsoCode', 'INR');
      sOppty2 = UtilityTest.putFieldRecord(sOppty2, UtilityTestData.mOpportunityData);
      
      List<Opportunity> lSecOpportunities = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj1,sObj2,sObj3,sOppty,sOppty2});
        */
                 
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

      sObj = new Product2();
      UtilityTestData.mProduct2Data.put('blng__BillingRule__c', lBillingRule[0].Id);
      UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c', lRevRecRule[0].Id);
      UtilityTestData.mProduct2Data.put('blng__TaxRule__c', lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('Offering_Type__c','Cloud Hosted Subscription');
        UtilityTestData.mProduct2Data.put('SBQQ__ChargeType__c','Recurring');
        UtilityTestData.mProduct2Data.put('SBQQ__BillingFrequency__c','Monthly');
        UtilityTestData.mProduct2Data.put('SBQQ__BillingType__c','Advance');
        UtilityTestData.mProduct2Data.put('SBQQ__SubscriptionTerm__c','12');
      sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
      List<Product2> lProduct = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj});
      System.assertEquals(lProduct.size(), 1);

      sObj = new PriceBookEntry();
      UtilityTestData.mPriceBookEntryData.put('Pricebook2Id', lPriceBook2[0].Id + '');
      UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct[0].Id + '');
      sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);
      List<PriceBookEntry> lPBEntry = (List<PriceBookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj});
      System.assertEquals(lPBEntry.size(),1);
      Test.startTest();  
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
      UtilityTestData.mSBQuoteData.put('SBQQ__Type__c', 'Renewal');
      UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c', System.Today() + '');
      
      UtilityTestData.mSBQuoteData.put('SBQQ__Status__c', 'Approved');
      UtilityTestData.mSBQuoteData.put('ApprovalStatus__c', 'Approved');
      UtilityTestData.mSBQuoteData.put('ShipToContact__c', lContact[0].Id);
      UtilityTestData.mSBQuoteData.put('BillToContact__c', lContact[0].Id);
      
      
      
      sObj = new SBQQ__Quote__c();
      sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
      List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
      UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', lQuote[0].Id);
      UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', lProduct[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__ChargeType__c','Recurring');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingFrequency__c','Monthly');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingType__c','Advance');
      sObj = new SBQQ__QuoteLine__c();
      sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
      
      
      sObj1 = new SBQQ__QuoteLine__c();
      sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
     
      sObj2 = new SBQQ__QuoteLine__c();
      sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);
      
      List<SBQQ__QuoteLine__c> lQuoteLI = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
      Test.stopTest();
       
         //sObj1 = new SBQQ__Quote__c(Id = lQuote[0].id ,SBQQ__Ordered__c = True,SBQQ__Account__c = lAccount[0].Id);
         //List<SBQQ__Quote__c> lQuoteUpdated1 = (List<SBQQ__Quote__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
         //system.assertEquals(lQuoteUpdated1.size(),1);

      /*
      UtilityTestData.mOpportunityProdData.put('Product2Id', lPBEntry[0].Id);
      UtilityTestData.mOpportunityProdData.put('OpportunityId', lSecOpportunities[1].Id);
      sObj = new OpportunityLineItem(SBQQ__QuoteLine__c = lQuoteLI[0].Id);
      sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityProdData);
      
      UtilityTestData.mOpportunityProdData.put('OpportunityId', lSecOpportunities[0].Id);
      sObj1 = new OpportunityLineItem(SBQQ__QuoteLine__c = lQuoteLI[1].Id);
      sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityProdData);
      
      UtilityTestData.mOpportunityProdData.put('OpportunityId', lSecOpportunities[0].Id);
      sObj2 = new OpportunityLineItem(SBQQ__QuoteLine__c= lQuoteLI[2].Id);
      sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mOpportunityProdData);
      
      sObj3 = new OpportunityLineItem();
      UtilityTestData.mOpportunityProdData.put('OpportunityId', lSecOpportunities[2].Id);
      sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mOpportunityProdData);
      
      sObj4 = new OpportunityLineItem();
      UtilityTestData.mOpportunityProdData.put('OpportunityId', lSecOpportunities[3].Id);
      sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mOpportunityProdData);
      
      List<OpportunityLineItem> lOpportunityLineItem = (List<OpportunityLineItem>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3,sObj4});
      */
   }
    
	@isTest
    static void syncSOPTest() {
        
      Test.startTest();
           list<Opportunity> opportunities = [Select Id,Name,StageName,CurrencyIsoCode,Split_Percentage__c,/*Primary_or_Secondary__c,*/Split_From__c from Opportunity];
        
        List<SBQQ__Quote__c> lQuote = [Select Id from SBQQ__Quote__c LIMIT 1];
        List<Account> lAccount = [Select Id from Account LIMIT 1];
        
        //sObject sObj1 = new SBQQ__Quote__c(Id = lQuote[0].id ,SBQQ__Ordered__c = True,SBQQ__Account__c = lAccount[0].Id);
        //List<SBQQ__Quote__c> lQuoteUpdated1 = (List<SBQQ__Quote__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
         
         //system.assertEquals(lQuoteUpdated1.size(),1);
            System.debug('INSIDE TEST METHOD');
        
            syncSOPController.syncSOP(opportunities[0].Id);
       
            System.debug('AFTER SYNCSOP');
            list<OpportunityLineItem> oLILst = [Select Id,UnitPrice  from OpportunityLineItem where OpportunityId  =:opportunities[0].Id];
            // System.assertEquals(oLILst.size(),0);
               Test.stopTest();    
    }
    
	@isTest
    static void syncSOPTest1(){
      Test.startTest();
           //list<Opportunity> opportunities = [Select Id,Name,CurrencyIsoCode,Split_Percentage__c,/*Primary_or_Secondary__c,*/Split_From__c from Opportunity];
          List<Account> lAccount = [Select Id from Account Limit 1]; 
          List<Contact> lContact = [Select Id from Contact Limit 1]; 
          List<Territory2> lTerritory = [Select Id from Territory2 Limit 1]; 
          
            String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;  
          
          sObject sOppty1 = new Opportunity();
          UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
          UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
          UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
          UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
          UtilityTestData.mOpportunityData.put('Type', 'Direct');
          UtilityTestData.mOpportunityData.put('StageName', 'Validate');
          UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Pipeline');
          UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
          UtilityTestData.mOpportunityData.put('Split_Percentage__c', '50');     
          //UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c', 'Primary'); 
          sOppty1 = UtilityTest.putFieldRecord(sOppty1, UtilityTestData.mOpportunityData);
          List<Opportunity> lOpportunityPrimary2 = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sOppty1});
          
           syncSOPController.syncSOP(lOpportunityPrimary2[0].Id);
            list<OpportunityLineItem> oLILst = [Select Id,UnitPrice  from OpportunityLineItem where OpportunityId =:lOpportunityPrimary2[0].Id];
           // System.assertEquals(oLILst.size(),0);
      Test.stopTest(); 
    }

    
    @isTest
    static void syncSOPTest2(){
      Test.startTest();
           list<Opportunity> lOpportunity = [Select Id,Name,CurrencyIsoCode,Split_Percentage__c,/*Primary_or_Secondary__c,*/Split_From__c from Opportunity];
          
          List<Account> lAccount = [Select Id from Account Limit 1]; 
          List<Contact> lContact = [Select Id from Contact Limit 1]; 
          List<Territory2> lTerritory = [Select Id from Territory2 Limit 1]; 
          String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity; 
          List<SBQQ__QuoteLine__c> lQuoteLI = [Select Id from SBQQ__QuoteLine__c];
          List<Pricebook2> lPriceBook2 = [Select Id from Pricebook2];
          List<PriceBookEntry> lPBEntry = [Select Id,Pricebook2Id from PriceBookEntry];
          System.debug('@@@lPBEntry' + lPBEntry[0].Pricebook2Id);
          
          UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
          UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
          UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
          UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
          UtilityTestData.mOpportunityData.put('Type', 'Direct');
          UtilityTestData.mOpportunityData.put('StageName', 'Validate');
          UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Pipeline');
          UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
          UtilityTestData.mOpportunityData.put('Split_Percentage__c', '50');     
          //UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c', 'Secondary'); 
          sObject sObj = new Opportunity(Split_From__c = lOpportunity[0].Id);
          sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
          
          List<Opportunity> lOpportunitySec = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
          
          Id pricebookId = Test.getStandardPricebookId(); 
          lOpportunitySec[0].Pricebook2Id = pricebookId;
          update lOpportunitySec[0]; 
          
          System.debug('@@@PricebookId' + lPriceBook2[0].Id);
            UtilityTestData.mOpportunityProdData.put('Product2Id', lPBEntry[0].Id);
            UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunitySec[0].Id);
            sObject sObj1 = new OpportunityLineItem();
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityProdData);
            
            UtilityTestData.mOpportunityProdData.put('Product2Id', lPBEntry[0].Id);
            UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunitySec[0].Id);
            sObject sObj2 = new OpportunityLineItem();
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mOpportunityProdData);
            //List<OpportunityLineItem> lOpportunityLineItem = (List<OpportunityLineItem>) UtilityTest.makeInsert(new List<sObject>{sObj1,sObj2});
           
            syncSOPController.syncSOP(lOpportunitySec[0].Id);
            list<OpportunityLineItem> oLILst = [Select Id,UnitPrice  from OpportunityLineItem where OpportunityId =:lOpportunity[0].Id];
            //System.assertEquals(oLILst.size(),2);
      Test.stopTest(); 
    }
    
    //Don't see any code coverage
	@isTest
    static void syncSOPTest3(){
          Test.startTest();
          List<Opportunity> opportunities = [Select Id,Name,StageName,CurrencyIsoCode,Split_Percentage__c,/*Primary_or_Secondary__c,*/Split_From__c from Opportunity];
          List<Account> lAccount = [Select Id from Account Limit 1]; 
          List<Contact> lContact = [Select Id from Contact Limit 1]; 
          List<Territory2> lTerritory = [Select Id from Territory2 Limit 1]; 
          String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity; 
          List<SBQQ__QuoteLine__c> lQuoteLI = [Select Id from SBQQ__QuoteLine__c];
          List<Pricebook2> lPriceBook2 = [Select Id from Pricebook2];
          List<PriceBookEntry> lPBEntry = [Select Id,Pricebook2Id from PriceBookEntry];
           
          UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
          UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
          UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
          UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
          UtilityTestData.mOpportunityData.put('Type', 'Direct');
          UtilityTestData.mOpportunityData.put('StageName', 'Validate');
          UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Pipeline');
          UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
          UtilityTestData.mOpportunityData.put('Split_Percentage__c', '50');  
          UtilityTestData.mOpportunityData.put('Name','syncSOPTest3Oppty');          
          //UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c', 'Secondary'); 
          sObject sObj = new Opportunity(Split_From__c = opportunities[0].Id);
          sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
          List<Opportunity> lOpportunitySec = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
          //Test.startTest();
          Id pricebookId = Test.getStandardPricebookId(); 
          lOpportunitySec[0].Pricebook2Id = pricebookId;
          update lOpportunitySec[0]; 
          
          UtilityTestData.mOpportunityProdData.put('Product2Id', lPBEntry[0].Id);
          UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunitySec[0].Id);
          sObject sObj1 = new OpportunityLineItem(SBQQ__QuoteLine__c = lQuoteLI[0].Id);
          sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityProdData);
          List<OpportunityLineItem> lOpportunityLineItem = (List<OpportunityLineItem>) UtilityTest.makeInsert(new List<sObject>{sObj1});
         Test.stopTest(); 
            syncSOPController.syncSOP(lOpportunitySec[0].Id);
            //list<OpportunityLineItem> oLILst = [Select Id,UnitPrice  from OpportunityLineItem where OpportunityId =:lOpportunitySec[0].Id];
            //System.assertEquals(oLILst[0].UnitPrice,5.00);
      //Test.stopTest(); 
    }
    
    //Don't see any code coverage
	@isTest
    static void syncSOPTest4(){
      Test.startTest();
           list<Opportunity> opportunities = [Select Id,Name,StageName,CurrencyIsoCode,Split_Percentage__c,/*Primary_or_Secondary__c,*/Split_From__c from Opportunity];
           
          List<Account> lAccount = [Select Id from Account Limit 1]; 
          List<Contact> lContact = [Select Id from Contact Limit 1]; 
          List<Territory2> lTerritory = [Select Id from Territory2 Limit 1]; 
          String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity; 
          List<SBQQ__QuoteLine__c> lQuoteLI = [Select Id from SBQQ__QuoteLine__c];
          List<Pricebook2> lPriceBook2 = [Select Id from Pricebook2];
          List<PriceBookEntry> lPBEntry = [Select Id,Pricebook2Id from PriceBookEntry]; 
            
          UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
          UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
          UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
          UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
          UtilityTestData.mOpportunityData.put('Type', 'Direct');
          UtilityTestData.mOpportunityData.put('StageName', 'Identify');
          UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Omitted');
          UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
          UtilityTestData.mOpportunityData.put('Split_Percentage__c', '40');     
          //UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c', 'Secondary'); 
          UtilityTestData.mOpportunityData.put('Name', 'Test Oppty 2');         
          sObject sObj3 = new Opportunity();
          sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mOpportunityData);
          List<Opportunity> lOpportunitySec = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj3});
          
          Id pricebookId = Test.getStandardPricebookId(); 
          lOpportunitySec[0].Pricebook2Id = pricebookId;
          update lOpportunitySec[0];
          
          sObject sObj = new OpportunityLineItem();
          UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunitySec[0].Id);
          UtilityTestData.mOpportunityProdData.put('Product2Id', lPBEntry[0].Id);
          sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityProdData);
          List<OpportunityLineItem> lOpportunityLineItem = (List<OpportunityLineItem>) UtilityTest.makeInsert(new List<sObject>{sObj}); 
          
            syncSOPController.syncSOP(lOpportunitySec[0].Id);
            //list<OpportunityLineItem> oLILst = [Select Id,UnitPrice  from OpportunityLineItem where OpportunityId =:lOpportunitySec[0].Id];
            //System.assertEquals(oLILst.size(),1);
      Test.stopTest(); 
    }
    
	@isTest
    static void syncSOPTest5(){
      Test.startTest();
           list<Opportunity> opportunities = [Select Id,Name,StageName,CurrencyIsoCode,Split_Percentage__c,/*Primary_or_Secondary__c,*/Split_From__c from Opportunity];
          List<Account> lAccount = [Select Id from Account Limit 1]; 
          List<Contact> lContact = [Select Id from Contact Limit 1]; 
          List<Territory2> lTerritory = [Select Id from Territory2 Limit 1]; 
          String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity; 
          List<SBQQ__QuoteLine__c> lQuoteLI = [Select Id from SBQQ__QuoteLine__c];
          List<Pricebook2> lPriceBook2 = [Select Id from Pricebook2];
          List<PriceBookEntry> lPBEntry = [Select Id,Pricebook2Id from PriceBookEntry];  
         
          sObject sOppty = new Opportunity(Split_From__c = opportunities[0].Id);
          UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
          UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
          UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
          UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
          UtilityTestData.mOpportunityData.put('Type', 'Direct');
          UtilityTestData.mOpportunityData.put('StageName', 'Validate');
          UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Pipeline');
          UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
          UtilityTestData.mOpportunityData.put('Split_Percentage__c', '50');     
          //UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c', 'Secondary'); 
          sOppty = UtilityTest.putFieldRecord(sOppty, UtilityTestData.mOpportunityData);    
          List<Opportunity> lOpportunitySec = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sOppty});
          
          Id pricebookId = Test.getStandardPricebookId(); 
          lOpportunitySec[0].Pricebook2Id = pricebookId;
          update lOpportunitySec[0];
          
          sObject sObj4 = new OpportunityLineItem();
          UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunitySec[0].Id);
          UtilityTestData.mOpportunityProdData.put('Product2Id', lPBEntry[0].Id);
          sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mOpportunityProdData);
      
          List<OpportunityLineItem> lOpportunityLineItem = (List<OpportunityLineItem>) UtilityTest.makeInsert(new List<sObject>{sObj4});
          Test.stopTest(); 
           syncSOPController.syncSOP(lOpportunitySec[0].Id);
           //list<OpportunityLineItem> oLILst = [Select Id,UnitPrice  from OpportunityLineItem where OpportunityId =:lOpportunitySec[0].Id];
           //System.assertEquals(oLILst.size(),1);
     // Test.stopTest(); 
    }
    
	@isTest
    static void syncSOPTest6(){
       Test.startTest();
           //list<Opportunity> opportunities = [Select Id,Name,StageName,CurrencyIsoCode,Split_Percentage__c,/*Primary_or_Secondary__c,*/Split_From__c from Opportunity];
          
          List<Account> lAccount = [Select Id from Account Limit 1]; 
          //List<Contact> lContact = [Select Id from Contact Limit 1]; 
          //List<Territory2> lTerritory = [Select Id from Territory2 Limit 1]; 
          String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity; 
          //List<SBQQ__QuoteLine__c> lQuoteLI = [Select Id from SBQQ__QuoteLine__c];
          //List<Pricebook2> lPriceBook2 = [Select Id from Pricebook2];
          //List<PriceBookEntry> lPBEntry = [Select Id,Pricebook2Id from PriceBookEntry]; 
          
          sObject sOppty1 = new Opportunity();
          UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
          //UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
          //UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
          UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
          UtilityTestData.mOpportunityData.put('Type', 'Direct');
          UtilityTestData.mOpportunityData.put('StageName', 'Validate');
          UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Pipeline');
          UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
          UtilityTestData.mOpportunityData.put('Split_Percentage__c', '50');     
          //UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c', 'Primary'); 
          sOppty1 = UtilityTest.putFieldRecord(sOppty1, UtilityTestData.mOpportunityData);
          
          List<Opportunity> lOpportunityPrimary2 = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sOppty1});
             
            
          sObject sOppty2 = new Opportunity(Split_From__c = lOpportunityPrimary2[0].Id);
      
          UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
          //UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
          //UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
          UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
          UtilityTestData.mOpportunityData.put('Type', 'Direct');
          UtilityTestData.mOpportunityData.put('StageName', 'Validate');
          UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Pipeline');
          UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
          UtilityTestData.mOpportunityData.put('Split_Percentage__c', '50');     
          //UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c', 'Secondary');
          UtilityTestData.mOpportunityData.put('CurrencyIsoCode', 'INR');
          sOppty2 = UtilityTest.putFieldRecord(sOppty2, UtilityTestData.mOpportunityData);
          
          List<Opportunity> lSecOpportunities = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sOppty2});
           
          Id pricebookId = Test.getStandardPricebookId(); 
          lSecOpportunities[0].Pricebook2Id = pricebookId;
            
          update lSecOpportunities[0]; 
     Test.stopTest(); 
            syncSOPController.syncSOP(lSecOpportunities[0].Id);
            //list<OpportunityLineItem> oLILst = [Select Id,UnitPrice  from OpportunityLineItem where OpportunityId =:lSecOpportunities[0].Id];
            //System.assertEquals(oLILst.size(),0);
    //  Test.stopTest(); 
    }
}