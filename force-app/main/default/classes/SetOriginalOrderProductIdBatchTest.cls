//UAT
/*
Class:          SetOriginalOrderProductIdBatchTest
@Author:        Sumitkumar Mittal
@Created Date:  05/11/2018
@Description:   test class for SetOriginalOrderProductIdBatch
Change History
******************************************************************
ModifiedBy          Date        Requested By        Description                 Tag

******************************************************************
*/

@isTest
private class SetOriginalOrderProductIdBatchTest{
    @testSetup
    static void setupTestData(){
        sObject sObj = new blng__BillingRule__c();
        sObject sObj1 = new blng__BillingRule__c();
        sObject sObj2 = new blng__BillingRule__c();
        
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
        UtilityTestData.mProduct2Data.put('Offering_Type__c','Cloud Hosted Subscription');
        UtilityTestData.mProduct2Data.put('Edition__c','Test Edition');
        
        //Generates_Entitlement__c
        UtilityTestData.mProduct2Data.put('Generates_Entitlement__c','True');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
        List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Get the Standard Pricebook id
        Id pricebookId = Test.getStandardPricebookId(); 
        //sObj = new Product2(ID = lProduct2[0].Id, Tax_Product_Type__c = null);
        //lProduct2 = (List<Product2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        //Get the activated pricebook id
        sObj = new Pricebook2(Id = pricebookId,IsActive = True);
        List<Pricebook2> lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        
        //Insert the pricebook entry
        sObj = new pricebookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',lPriceBook2[0].Id);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);
        List<pricebookEntry> lPriceBookEntry = (List<pricebookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        Id customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        //sObj = new Account(RecordTypeId =customerRecordTypeId, Name = 'Test customer Account', BillingCountry ='India');
        //UtilityTestData.mAccountData.put('RecordTypeId',customerRecordTypeId);
        sObj = new Account(RecordTypeId =customerRecordTypeId, Name = 'Test Customer Account', BillingCountry ='India');
        // sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        
        Id competitorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor Account').getRecordTypeId();
        sObj1 = new Account(RecordTypeId =competitorRecordTypeId, Name = 'Test competitor Account', BillingCountry ='India');
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1});
        
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Opportunity(Name = 'Test Opportunity', StageName = 'Validate', CloseDate=System.today(), AccountId = lAccount[0].Id, Type='Direct', CurrencyIsoCode='USD', Sales_Play__c='Data Integration', /*OrderableIn__c='New',*/ Pricebook2Id=lPriceBook2[0].Id);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Competitor_Relationship__c();
        
        Id opptyCompRecTypeId = Schema.SObjectType.Competitor_Relationship__c.getRecordTypeInfosByName().get('Opportunity Competitor').getRecordTypeId();
        UtilityTestData.mCompetitorData.put('RecordTypeId',opptyCompRecTypeId);
        UtilityTestData.mCompetitorData.put('Competitor_Account__c',lAccount[1].Id);
        UtilityTestData.mCompetitorData.put('Opportunity__c',lOpportunity[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCompetitorData);
        List<Competitor_Relationship__c> lCompetitorData = (List<Competitor_Relationship__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
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
        UtilityTestData.mSBQuoteData.put('Route_To_Market__c','Direct');
        UtilityTestData.mSBQuoteData.put('Detail_RTM__c','Field Sales');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__PricebookEntryId__c',lPriceBookEntry[0].Id);
        UtilityTestData.mQuoteLineData.put('Purchase_Order_PO_Number__c','111111111');
        UtilityTestData.mQuoteLineData.put('SBQQ__ListPrice__c','100');
        UtilityTestData.mQuoteLineData.put('SBQQ__Number__c','1');
        UtilityTestData.mQuoteLineData.put('SBQQ__ChargeType__c','Recurring');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingType__c','Advance');
        UtilityTestData.mQuoteLineData.put('Transaction_Type__c','New');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingFrequency__c','Annual');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
           test.startTest();
        List<SBQQ__QuoteLine__c> lSBQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        /*sObj = new Order();
UtilityTestData.mOrderData.put('AccountId',lAccount[0].Id);
UtilityTestData.mOrderData.put('SoldToAccount__c',lAccount[0].Id);
UtilityTestData.mOrderData.put('SoldToContact__c',lContact[0].Id);
UtilityTestData.mOrderData.put('EndUserAccount__c',lAccount[0].Id);
UtilityTestData.mOrderData.put('EndUserContact__c',lContact[0].Id);
UtilityTestData.mOrderData.put('ShipToAccount__c',lAccount[0].Id);
UtilityTestData.mOrderData.put('BilltoAccount__c',lAccount[0].Id);
UtilityTestData.mOrderData.put('SBQQ__Quote__c',lSBQuote[0].Id);
UtilityTestData.mOrderData.put('Pricebook2Id',lPriceBook2[0].Id);
UtilityTestData.mOrderData.put('Billing_Alignment_Date__c',System.today()+'');
UtilityTestData.mOrderData.put('EffectiveDate',System.today()+'');
sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderData);
List<Order> lOrder = (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj});

sObj = new OrderItem(blng__NextChargeDate__c = System.Today().addDays(360));
UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',lSBQuoteLine[0].Id);
UtilityTestData.mOrderItemData.put('OrderId',lOrder[0].Id);
UtilityTestData.mOrderItemData.put('PricebookEntryId',lPriceBookEntry[0].Id);
UtilityTestData.mOrderItemData.put('blng__LegalEntity__c',lLegalEntity[0].Id);
UtilityTestData.mOrderItemData.put('blng__BillingRule__c',lBillingRule[0].Id);
UtilityTestData.mOrderItemData.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
UtilityTestData.mOrderItemData.put('blng__TaxRule__c',lTaxRule[0].Id);
UtilityTestData.mOrderItemData.put('ServiceDate',System.today() + '');
UtilityTestData.mOrderItemData.put('Original_Order_Product_Id__c', Null);
UtilityTestData.mOrderItemData.put('SBQQ__RevisedOrderProduct__c',Null);
sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderItemData);
List<OrderItem> lOrderItem = (List<OrderItem>) UtilityTest.makeInsert(new List<sObject>{sObj});*/
     
        
        lSBQuote[0].Price_Book_2__c = priceBookId;
        lSBQuote[0].SBQQ__PricebookId__c = priceBookId;
        update lSBQuote[0];
        
        sObj1 = new SBQQ__Quote__c(Id = lSBQuote[0].Id ,SBQQ__Status__c = 'Approved', ApprovalStatus__c='Approved', ShiptToAccount__c=lAccount[0].Id, BillToAccount__c=lAccount[0].Id, EndUserAccount__c=lAccount[0].Id, SoldToAccount__c=lAccount[0].Id, EndUserContact__c=lContact[0].Id, BillToContact__c=lContact[0].Id, ShipToContact__c=lContact[0].Id, SoldToContact__c=lContact[0].Id); //<T1> Last 8 arguments
        List<SBQQ__Quote__c> lQuoteUpdated = (List<SBQQ__Quote__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
        system.assertEquals(lQuoteUpdated.size(),1);
        
        Date currentDate = Date.today();
        
        sObj1 = new Opportunity(Id = lOpportunity[0].id,
                                Win_Loss_Commentary__c='sample',
                                Sales_Journey__c='Business 360',
                                psa_om_IPS_Package__c='Others',
                                psa_om_End_Date__c=currentDate.addDays(10),
                                psa_om_Start_Date__c=currentDate,
                                BANT_Qualification__c='Test',
                                PSA_OM_Project_Type__c='Billable Customer Project',
                                StageName = 'Closed Won',
                                Substage__c = 'Sales Won',
                                Analysis_Takeaways__c = 'Test',
                                Ease_of_Renewal__c = '3- Not Easy',
                                Next_Renewal_Considerations__c = 'Test',
                                Next_Renewal_Likelyhood__c = 'May Renew 50/50', 
                                Stakeholders_Communication__c = 'Test', 
                                Stage_Reason__c='Product Features', 
                                Red_Flags__c = 'Pricing',
                                Delivery__c='IPS Implementation', 
                                Solutions__c = 'FedRAMP',
                                Next_Steps__c = 'Test',
								Competitors_Verification__c = true,
                                Current_Status__c  = 'Draft Opportunity Closing Plan');
        
        List<Opportunity> lOpportunityUpdated = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
        system.assertEquals(lOpportunityUpdated.size(),1);
        
        sObj1 = new SBQQ__Quote__c(Id = lSBQuote[0].id ,SBQQ__Ordered__c = True);
        List<SBQQ__Quote__c> lQuoteUpdated1 = (List<SBQQ__Quote__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
        system.assertEquals(lQuoteUpdated1.size(),1);
        List<OrderItem> orderli= [SELECT Id, Original_Order_Product_Id__c, Original_Order_Product__c, SBQQ__RevisedOrderProduct__c, SBQQ__RevisedOrderProduct__r.Original_Order_Product_Id__c FROM OrderItem];
        orderli[0].SBQQ__RevisedOrderProduct__c = null ;
        orderli[0].Original_Order_Product_Id__c = null;
        upsert orderli[0];
        List<OrderItem> orderli1= [SELECT Id, Original_Order_Product_Id__c, Original_Order_Product__c, SBQQ__RevisedOrderProduct__c, SBQQ__RevisedOrderProduct__r.Original_Order_Product_Id__c FROM OrderItem];
        system.debug('check>>'+orderli1);
        test.stopTest(); 
        
    }
    
    //test method to call the batch class and schedule it as per the data
    @isTest
    static void unitTestExecuteBatch(){
        Test.startTest();
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(userObj) { 
            
            
            SetOriginalOrderProductIdBatch cls  = new SetOriginalOrderProductIdBatch();
            Database.executeBatch(cls);
            
            String sch = '0 0 23 * * ?';
            System.schedule('Test Schedule Batch', sch, cls);
            
            Test.stopTest();
        }
        
    }
    
    @isTest
    static void handleCatch(){
        try{
            SetOriginalOrderProductIdBatch cls = new SetOriginalOrderProductIdBatch();
            cls.updateOrderItem(Null);
        } catch(NullPointerException e){
            globalApexManager gam = new globalApexManager();
            List<sObject> scope = new List<sObject>();
            gam.CreateLogs('OriginalOrderProductUpdateBatch --> execute',scope , 'scope: ');
        }
    }    
}