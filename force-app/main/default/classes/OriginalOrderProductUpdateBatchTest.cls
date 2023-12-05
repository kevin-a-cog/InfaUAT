//UAT
@isTest
private class OriginalOrderProductUpdateBatchTest {
    @isTest
    static void testExecuteBatch(){

        OriginalOrderProductUpdateBatch obj1 =  new OriginalOrderProductUpdateBatch();
        Database.executeBatch(obj1,2000);
    }
    @isTest
    static void testHandleCatch(){
        OriginalOrderProductUpdateBatch obj2 =  new OriginalOrderProductUpdateBatch();
        obj2.execute(null);
    }
    @isTest
    static void testUpdateOriginalProduct(){

        OriginalOrderProductUpdateBatch obj3 =  new OriginalOrderProductUpdateBatch();
        User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1];
        List<SBQQ__Quote__c> lQuoteUpdated = new List<SBQQ__Quote__c>();
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
            //system.debug('++++++' + sObj);
            
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
            
            sObj = new Account();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            
            sObj1 = new Account();
            UtilityTestData.mAccountData.put('Name','Testing');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountData);
            
            List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
            sObj = new Account_LOB__c();
            UtilityTestData.mAccountLOB.put('Account__c',lAccount[0].id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountLOB);
            
            sObj1 = new Account_LOB__c();
            UtilityTestData.mAccountLOB.put('Account__c',lAccount[1].id);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountLOB);
            
            sObject sObj2 = new Account_LOB__c();
            UtilityTestData.mAccountLOB.put('Account__c',lAccount[1].id);
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mAccountLOB);
            List<Account_LOB__c> lAccountLOB = (List<Account_LOB__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
            
            sObj = new Account_Product__c();
            UtilityTestData.mAccountProduct.put('Account__c',lAccount[0].id);
            UtilityTestData.mAccountProduct.put('Service_Account__c',lAccount[0].id); // <T01>
            UtilityTestData.mAccountProduct.put('Line_of_Business__c',lAccountLOB[1].id);
            UtilityTestData.mAccountProduct.put('Forecast_Product__c','Data Quality');
            UtilityTestData.mAccountProduct.put('Related_Asset_Identifier__c','Test');//<T01>
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountProduct);
            List<Account_Product__c> lAccountProd = (List<Account_Product__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new Contact();
            UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
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
            UtilityTestData.mContractData.put('SBQQ__StartDate__c',System.today()+'');
            UtilityTestData.mContractData.put('SBQQ__EndDate__c',System.today().addMonths(12)+'');
            UtilityTestData.mSBQuoteData.put('Shipping_Preference__c','Email');
            UtilityTestData.mSBQuoteData.put('SBQQ__BillingName__c','Test user');
            UtilityTestData.mSBQuoteData.put('SBQQ__ShippingName__c','Test user');
            UtilityTestData.mSBQuoteData.put('Shipping_Email__c','test@email.com');
            UtilityTestData.mSBQuoteData.put('PO__c','123213');
            UtilityTestData.mSBQuoteData.put('BillToAccount__c',lAccount[0].Id);
            UtilityTestData.mSBQuoteData.put('ShiptToAccount__c',lAccount[0].Id);
            UtilityTestData.mSBQuoteData.put('BillToContact__c',lContact[0].Id);
            UtilityTestData.mSBQuoteData.put('ShipToContact__c',lContact[0].Id);
            UtilityTestData.mSBQuoteData.put('EndUserContact__c',lContact[0].Id);
            UtilityTestData.mSBQuoteData.put('SoldToContact__c',lContact[0].Id);
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
            sObj1 = new Opportunity(Id = lOpportunity[0].id ,StageName = 'Closed Won', Analysis_Takeaways__c = 'Test', Ease_of_Renewal__c = '3- Not Easy', Next_Renewal_Considerations__c = 'Test', Next_Renewal_Likelyhood__c = 'May Renew 50/50', Stakeholders_Communication__c = 'Test', Stage_Reason__c='Won : Test class', Red_Flags__c = 'Pricing',Delivery__c='IPS Implementation', Solutions__c = 'Big Data', Next_Steps__c = 'Test', Current_Status__c  = 'Draft Opportunity Closing Plan');
            List<Opportunity> lOpportunityUpdated = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            system.assertEquals(lOpportunityUpdated.size(),1);
            
            List<SBQQ__QuoteLine__c> lSBQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj1 = new SBQQ__Quote__c(Id = lSBQuote[0].Id ,SBQQ__Status__c = 'Approved', SBQQ__Primary__c = True,SBQQ__Ordered__c = True, ApprovalStatus__c='Approved', ShiptToAccount__c=lAccount[0].Id, BillToAccount__c=lAccount[0].Id, EndUserAccount__c=lAccount[0].Id, SoldToAccount__c=lAccount[0].Id, EndUserContact__c=lContact[0].Id, BillToContact__c=lContact[0].Id, ShipToContact__c=lContact[0].Id, SoldToContact__c=lContact[0].Id); //<T1> Last two arguments);
            lQuoteUpdated = (List<SBQQ__Quote__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            
            Test.stopTest();
        }
      
        List<OrderItem> lOrderItem = [Select Id,SBQQ__RevisedOrderProduct__c  from OrderItem where Order.SBQQ__Quote__c = : lQuoteUpdated[0].Id];
        //listOrderItems.add((OrderItem)sObjOrderItem2);
        lOrderItem[0].SBQQ__RevisedOrderProduct__c =  lOrderItem[0].id;
        obj3.updateOriginalOrderProduct(lOrderItem);
        obj3.execute(null);
    }

}