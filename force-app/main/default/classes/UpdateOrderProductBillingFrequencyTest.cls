@isTest
public class UpdateOrderProductBillingFrequencyTest {  
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
        
        
        
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
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
        
        sObj = new blng__GLRule__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mGLRule);
        List<blng__GLRule__c> lGLRule = (List<blng__GLRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new blng__FinanceBook__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mFinanceBook);
        List<blng__FinanceBook__c> lFBook = (List<blng__FinanceBook__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new blng__RevenueDistributionMethod__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRevenueDistributionMethod);
        List<blng__RevenueDistributionMethod__c> lRevDis = (List<blng__RevenueDistributionMethod__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new blng__RevenueRecognitionTreatment__c();
        UtilityTestData.mRevRecTreat.put('blng__RevenueDistributionMethod__c',lRevDis[0].Id);
        UtilityTestData.mRevRecTreat.put('blng__RevenueFinanceBook__c',lFBook[0].Id);
        UtilityTestData.mRevRecTreat.put('blng__RevenueGLRule__c',lGLRule[0].Id);
        UtilityTestData.mRevRecTreat.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRevRecTreat);
        List<blng__RevenueRecognitionTreatment__c> lRevTreat = (List<blng__RevenueRecognitionTreatment__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        
        //Insert product
        sObj = new Product2();
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('SBQQ__AssetConversion__c','One per unit');
        //Generates_Entitlement__c
        UtilityTestData.mProduct2Data.put('Generates_Entitlement__c','True');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
        
        sObj1 = new Product2();
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('Name','Test Debook Product');
        UtilityTestData.mProduct2Data.put('SBQQ__AssetConversion__c','One per unit');
        //Generates_Entitlement__c
        UtilityTestData.mProduct2Data.put('Generates_Entitlement__c','True');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProduct2Data);
        List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        lProduct2[0].Tax_Product_Type__c = null;
        lProduct2[1].Tax_Product_Type__c = null;
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
        
        
        
        sObj = new blng__LegalEntity__c();
        UtilityTestData.mLegalEntityData.put('Name','test');
        UtilityTestData.mLegalEntityData.put('Legal_Entity_Code__c','test123');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalEntityData);
        List<blng__LegalEntity__c> lLegalEntity = (List<blng__LegalEntity__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Order();
        UtilityTestData.mOrderData.put('SBQQ__PaymentTerm__c','Other');
        UtilityTestData.mOrderData.put('Name','Order for Revenue Schedule');
        UtilityTestData.mOrderData.put('Legal_Entity__c',lLegalEntity[0].Id);
        UtilityTestData.mOrderData.put('Pricebook2Id',pricebookId);
        UtilityTestData.mOrderData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOrderData.put('EffectiveDate',String.valueOf(Date.today()));
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderData);
        List<Order> lOrder = (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new OrderItem();
        UtilityTestData.mOrderItemData.put('OrderId',lOrder[0].Id);
        UtilityTestData.mOrderItemData.put('PricebookEntryId',lPriceBookEntry[0].Id);
        UtilityTestData.mOrderItemData.put('ServiceDate',String.valueOf(Date.today()));
        UtilityTestData.mOrderItemData.put('EndDate',String.valueOf(Date.today().addDays(450)));
        UtilityTestData.mOrderItemData.put('SBQQ__BillingType__c','Advance');
        UtilityTestData.mOrderItemData.put('SBQQ__DefaultSubscriptionTerm__c','1');
        UtilityTestData.mOrderItemData.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderItemData);
        
        List<OrderItem> lOrderItem = (List<OrderItem>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        System.runAs(userObj) {   
            Test.startTest();
            lOrder[0].Status = 'Activated';
            lOrder[0].SBQQ__PriceCalcStatus__c = 'Completed';
            update lOrder;
            lOrderItem[0].SBQQ__Status__c = 'Activated';
            lOrderItem[0].SBQQ__Activated__c= TRUE;
            update lOrderItem;
            
            sObj = new Revenue_Agreement__c();
            UtilityTestData.mRevAgree.put('RMCS_Contract_Number__c','Test Rev Agree');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRevAgree);
            List<Revenue_Agreement__c> lRA = (List<Revenue_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            
            sObj = new blng__RevenueSchedule__c();
            UtilityTestData.mRevSchedule.put('blng__RevenueRecognitionTreatment__c',lRevTreat[0].Id);
            UtilityTestData.mRevSchedule.put('blng__OrderProduct__c',lOrderItem[0].Id);
            UtilityTestData.mRevSchedule.put('RMCS_Contract_Line_Number__c','Test Rev Sch');
            UtilityTestData.mRevSchedule.put('Revenue_Agreement__c',lRA[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRevSchedule);
            List<blng__RevenueSchedule__c> lRS= (List<blng__RevenueSchedule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            
            Test.stopTest();
        }
        
        
    }
    
    @isTest
    Static void updateBillingDatesTest() {
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and Name = 'Datamigration Master' and IsActive = true limit 1];
        
        System.runAs(userObj) {
            List<OrderItem> lOrderItem = [Select Id, blng__OverrideNextBillingDate__c, blng__BillThroughDateOverride__c, orderId,
                                          SBQQ__BillingFrequency__c, SBQQ__ChargeType__c, blng__InvoiceRunProcessingStatus__c, blng__NextBillingDate__c
                                          from OrderItem limit 1];
            
            Test.startTest();
            String str3= UpdateOrderProductBillingFrequency.updateBillingDates(lOrderItem[0].orderId, Date.today().addDays(10),Date.today().addDays(5));
            Test.stopTest();           
        } 
    }
    @isTest
    Static void updateBillingDatesTest2() {
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and Name = 'Datamigration Master' and IsActive = true limit 1];
        
        System.runAs(userObj) {
            List<OrderItem> lOrderItem = [Select Id, blng__OverrideNextBillingDate__c, blng__BillThroughDateOverride__c, orderId,
                                          SBQQ__BillingFrequency__c, SBQQ__ChargeType__c, blng__InvoiceRunProcessingStatus__c, blng__NextBillingDate__c
                                          from OrderItem limit 1];
            update new OrderItem(Purchase_Order_PO_Number__c = NULL, Id =lOrderItem[0].Id);
            
            Test.startTest();
            String str3= UpdateOrderProductBillingFrequency.updateBillingDates(lOrderItem[0].orderId, Date.today().addDays(10),Date.today().addDays(5));
            Test.stopTest();           
        } 
    }
    
}