/*
Class:  ReviewAssetsOrderControllerTest
@Author:        Anil Solanki
@Created Date:  27 April 2018
@Description:   Test Class for ReviewAssetsOrderController Class.
*/
@isTest
private class ReviewAssetsOrderControllerTest{
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
        
        
        sObject sObj = new blng__BillingRule__c();
        sObject sObj1 = new blng__BillingRule__c();
        sObject sObj2 = new blng__BillingRule__c();
        
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
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
        List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        Id pricebookId = Test.getStandardPricebookId(); 
        
        sObj = new Pricebook2(Id = pricebookId,IsActive = True);
        List<Pricebook2> lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        
        sObj = new pricebookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',lPriceBook2[0].Id);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);
        List<pricebookEntry> lPriceBookEntry = (List<pricebookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;
        
        sObj = new Account();
        UtilityTestData.mContactData.put('Name','Test account');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        sObj = new Opportunity();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mContactData.put('Type','Direct');
        UtilityTestData.mContactData.put('CurrencyIsoCode','USD');
        UtilityTestData.mContactData.put('StageName','Validate');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        lOpportunity[0].Pricebook2Id = lPriceBook2[0].Id;
        update lOpportunity[0];
        Test.startTest();
        sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunity[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
        List<SBQQ__QuoteLine__c> lSBQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj1 = new SBQQ__Quote__c(Id = lSBQuote[0].Id ,SBQQ__Status__c = 'Approved', ApprovalStatus__c='Approved', ShiptToAccount__c=lAccount[0].Id, BillToAccount__c=lAccount[0].Id, EndUserAccount__c=lAccount[0].Id, SoldToAccount__c=lAccount[0].Id, EndUserContact__c=lContact[0].Id, BillToContact__c=lContact[0].Id, ShipToContact__c=lContact[0].Id, SoldToContact__c=lContact[0].Id); //<T1> Last two arguments);
        
        List<SBQQ__Quote__c> lQuoteUpdated = (List<SBQQ__Quote__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
        system.assertEquals(lQuoteUpdated.size(),1);
        
        sObj1 = new Opportunity(Id = lOpportunity[0].id ,StageName = 'Closed Won', Analysis_Takeaways__c = 'Test', Ease_of_Renewal__c = '3- Not Easy', Next_Renewal_Considerations__c = 'Test', Next_Renewal_Likelyhood__c = 'May Renew 50/50', Stakeholders_Communication__c = 'Test', Stage_Reason__c='Won : Test class', Red_Flags__c = 'Pricing',Delivery__c='IPS Implementation', Solutions__c = 'Big Data', Next_Steps__c = 'Test', Current_Status__c  = 'Draft Opportunity Closing Plan');
        List<Opportunity> lOpportunityUpdated = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
        system.assertEquals(lOpportunityUpdated.size(),1);
        
        Test.stopTest();
        /*
sObj1 = new SBQQ__Quote__c(Id = lSBQuote[0].id ,SBQQ__Ordered__c = True,SBQQ__Account__c = lAccount[0].Id);
List<SBQQ__Quote__c> lQuoteUpdated1 = (List<SBQQ__Quote__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
system.assertEquals(lQuoteUpdated1.size(),1);

/*
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
UtilityTestData.mOrderData.put('Billing_Alignment_Date__c',System.today()+'');
UtilityTestData.mOrderData.put('EffectiveDate',System.today()+'');
sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderData);
List<Order> lOrder = (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj});

sObj = new blng__LegalEntity__c();
UtilityTestData.mLegalEntityData.put('Name','test');
UtilityTestData.mLegalEntityData.put('Legal_Entity_Code__c','test123');
sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalEntityData);
List<blng__LegalEntity__c> lLegalEntity = (List<blng__LegalEntity__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

sObj = new OrderItem(blng__NextChargeDate__c = System.Today().addDays(360));
UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',lSBQuoteLine[0].Id);
UtilityTestData.mOrderItemData.put('OrderId',lOrder[0].Id);
UtilityTestData.mOrderItemData.put('PricebookEntryId',lPriceBookEntry[0].Id);
UtilityTestData.mOrderItemData.put('blng__LegalEntity__c',lLegalEntity[0].Id);
UtilityTestData.mOrderItemData.put('blng__BillingRule__c',lBillingRule[0].Id);
UtilityTestData.mOrderItemData.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
UtilityTestData.mOrderItemData.put('blng__TaxRule__c',lTaxRule[0].Id);
UtilityTestData.mOrderItemData.put('ServiceDate',System.today() + '');
sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderItemData);
List<OrderItem> lOrderItem = (List<OrderItem>) UtilityTest.makeInsert(new List<sObject>{sObj}); 

*/
    }
    
    //Method to test save Asset Functionality
    static testMethod void assetSaveTest() {
        
        List<Account> testAccount = [Select Id,name from Account Limit 1];
        List<SBQQ__Quote__c> lSBQuote= [Select Id,SBQQ__Ordered__c, SBQQ__Account__c from SBQQ__Quote__c LIMIT 1];
        
        Test.startTest();
        
        Sobject sObjQuote=new SBQQ__Quote__c();
        sObjQuote = new SBQQ__Quote__c(Id = lSBQuote[0].id ,SBQQ__Ordered__c = True,SBQQ__Account__c = testAccount[0].id );
        List<SBQQ__Quote__c> lQuoteUpdated1 = (List<SBQQ__Quote__c>) UtilityTest.makeUpdate(new List<sObject>{sObjQuote});
        system.assertEquals(lQuoteUpdated1.size(),1);
        
        List<Order> testOrder = [Select Id from Order where SBQQ__Quote__c = : lSBQuote[0].Id ];
        List<OrderItem> testOrderItem = [Select Id from OrderItem where Order.SBQQ__Quote__c = : lSBQuote[0].Id];
        List<SBQQ__QuoteLine__c> testQuoteItem = [Select Id from SBQQ__QuoteLine__c Limit 1];
       
        sObject sObj = new Asset();
        sObject sObj1 = new Asset();
        sObject sObj2 = new Asset();
        sObject sObj3 = new Asset();
        
        
        UtilityTestData.mAssetData.put('AccountId',testAccount[0].Id);
        UtilityTestData.mAssetData.put('SBQQ__OrderProduct__c',testOrderItem[0].Id);
        
        sObj = new Asset(Status = 'Marked for Review');
        UtilityTestData.mAssetData.put('Status','Marked for Review');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAssetData);
        
        //sObj1 = new Asset(Name ='Test Asset1' ,InstallDate = System.today(),Status = 'Sent for Provisioning',AccountId = testAccount[0].Id,SBQQ__OrderProduct__c = testOrderItem[0].Id,SBQQ__SubscriptionEndDate__c = System.today().addDays(60));
        sObj1 = new Asset();
        UtilityTestData.mAssetData.put('Name','Test Asset1');
        UtilityTestData.mAssetData.put('InstallDate',System.today() + '');
        UtilityTestData.mAssetData.put('Status', 'Sent for Provisioning');
        UtilityTestData.mAssetData.put('AccountId', testAccount[0].Id);
        UtilityTestData.mAssetData.put('SBQQ__OrderProduct__c', testOrderItem[0].Id);
        UtilityTestData.mAssetData.put('SBQQ__SubscriptionEndDate__c', System.today().addDays(60) +'');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAssetData);
        
        sObj3 = new Asset();
        UtilityTestData.mAssetData.put('Name','Test Asset3');
        UtilityTestData.mAssetData.put('InstallDate',System.today() + '');
        UtilityTestData.mAssetData.put('Status', 'Sent for Provisioning');
        UtilityTestData.mAssetData.put('AccountId', testAccount[0].Id);
        UtilityTestData.mAssetData.put('SBQQ__OrderProduct__c', testOrderItem[0].Id);
        UtilityTestData.mAssetData.put('SBQQ__SubscriptionEndDate__c', System.today().addDays(60) +'');
        sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mAssetData);
        List<Asset> lAsset = (List<Asset>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj3});
        
        //sObj2 = new Asset(Name = 'Test Asset2',Primary_Asset__c = lAsset[0].Id,Associated_Asset__c = lAsset[1].Id,Asset_Identifier__c = '112233',Status = 'Ready for Provisioning',AccountId = testAccount[0].Id,SBQQ__OrderProduct__c = testOrderItem[0].Id);
        sObj2 = new Asset();
        UtilityTestData.mAssetData.put('Name','Test Asset2');
        UtilityTestData.mAssetData.put('Primary_Asset__c',lAsset[2].Id);
        UtilityTestData.mAssetData.put('Status', 'Ready for Provisioning');
        UtilityTestData.mAssetData.put('AccountId', testAccount[0].Id);
        UtilityTestData.mAssetData.put('SBQQ__OrderProduct__c', testOrderItem[0].Id);
        UtilityTestData.mAssetData.put('Associated_Asset__c', lAsset[0].Id);
        UtilityTestData.mAssetData.put('Asset_Identifier__c', '112233');
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mAssetData);
        List<Asset> lAssetNew = (List<Asset>) UtilityTest.makeInsert(new List<sObject>{sObj2});
        
        List<Order> lOrderUpdate = [Select Id,Name, Provisioning_Incomplete_Count__c from Order Where Id =: testOrder[0].Id Limit 1];
        //System.assertEquals(lOrderUpdate[0].Provisioning_Incomplete_Count__c,1);
        
        ReviewAssetsOrderController oReviewAssetsOrderController = new ReviewAssetsOrderController();
        oReviewAssetsOrderController.orderId = testOrder[0].Id;                              
        List<ReviewAssetsOrderController.AssetsWrapper> assetWrapperList_Quote = oReviewAssetsOrderController.listAssetWrapper;
        
        if(assetWrapperList_Quote.size()>0){
            assetWrapperList_Quote[0].AssetIdentifier = 'test';
            assetWrapperList_Quote[0].InstallDate = date.today();
            assetWrapperList_Quote[0].ParentAssetID = lAsset[0].Id;
            assetWrapperList_Quote[0].AssociatedAssetID = lAsset[1].Id;
            assetWrapperList_Quote[0].Status = 'Provisioning Complete';
            assetWrapperList_Quote[0].SubscriptionEndDate = System.today().addDays(60);
        }
        
        string sAssets = JSON.serialize(assetWrapperList_Quote);
        ReviewAssetsOrderController.saveAssets(sAssets,testOrderItem[0].Id);
        ReviewAssetsOrderController.saveAssets(sAssets,testQuoteItem[0].Id);
        List<Asset> lAssetUpdate = [Select Id,Name, Status from Asset];
        System.debug('lAssetUpdate'+ lAssetUpdate);
        //System.assertEquals(lAssetUpdate[2].Status , 'Ready for Provisioning');
        System.assertEquals(lAssetUpdate.Size() ,4);
         Test.stopTest();
    }
}