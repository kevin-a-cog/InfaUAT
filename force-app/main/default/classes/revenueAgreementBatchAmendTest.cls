/**
*  @Author:        Ramesh M S
*  @Created Date:  10/14/2020
*  @Description:   Test class for revenueAgreementBatch with the updated test framework
* Change History
***********************************************************************************************
* ModifiedBy          Date              Requested By        Description                     Tag
*   
***********************************************************************************************
*/
@isTest
private class revenueAgreementBatchAmendTest{
    
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
        UtilityTestData.mProduct2Data.put('Product_Family__c','Support');
        UtilityTestData.mProduct2Data.put('Forecast_Product__c','Support');
        UtilityTestData.mProduct2Data.put('Edition__c','VAS');
        //Generates_Entitlement__c
        UtilityTestData.mProduct2Data.put('Generates_Entitlement__c','True');
        UtilityTestData.mProduct2Data.put('Offering_Type__c','On-Premise Subscription');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
        
        sObj1 = new Product2();
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('Name','Test Debook Product');
        UtilityTestData.mProduct2Data.put('SBQQ__AssetConversion__c','One per unit');
        //Generates_Entitlement__c
        UtilityTestData.mProduct2Data.put('Offering_Type__c','On-Premise Subscription');
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
        
        sObj = new SBQQ__ProductOption__c();
        UtilityTestData.mProductOption.put('SBQQ__ConfiguredSKU__c',lProduct2[0].Id);
        UtilityTestData.mProductOption.put('SBQQ__OptionalSKU__c',lProduct2[1].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProductOption);
        List<SBQQ__ProductOption__c> lProdOpt = (List<SBQQ__ProductOption__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
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
        
        sObj = new Opportunity();
        UtilityTestData.mOpportunityData.put('Name', 'Test Oppty No Territory1');
        UtilityTestData.mOpportunityData.put('CloseDate', System.today().addDays(60)+'');
        UtilityTestData.mOpportunityData.put('Enable_Downstream__c', 'Fulfillment');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Order();
        UtilityTestData.mOrderData.put('SBQQ__PaymentTerm__c','Other');
        UtilityTestData.mOrderData.put('OpportunityId',lOpportunity[0].Id);
        UtilityTestData.mOrderData.put('Contract_Generated__c','true');
        UtilityTestData.mOrderData.put('Name','Order for Revenue Agreement Batch');
        UtilityTestData.mOrderData.put('Legal_Entity__c',lLegalEntity[0].Id);
        UtilityTestData.mOrderData.put('Pricebook2Id',pricebookId);
        UtilityTestData.mOrderData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOrderData.put('Type','Amendment');
        UtilityTestData.mOrderData.put('EffectiveDate',String.valueOf(Date.today()));
        UtilityTestData.mOrderData.put('BillingName_PSFTID__c','1');
        UtilityTestData.mOrderData.put('BillingAddress_PSFTID__c','1');
        UtilityTestData.mOrderData.put('EndUserAddress_PSFTID__c','1');
        UtilityTestData.mOrderData.put('ShippingName_PSFTID__c','1');
        UtilityTestData.mOrderData.put('ShippingAddress_PSFTID__c','1');
        UtilityTestData.mOrderData.put('SoldAddress_PSFTID__c','1');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderData);
        
        
        List<Order> lOrder = (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new OrderItem();
        UtilityTestData.mOrderItemData.put('OrderId',lOrder[0].Id);
        //UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',lQuoteLI[0].Id);
        UtilityTestData.mOrderItemData.put('PricebookEntryId',lPriceBookEntry[0].Id);
        UtilityTestData.mOrderItemData.put('Product2Id',lProduct2[0].Id);
        UtilityTestData.mOrderItemData.put('ServiceDate',String.valueOf(Date.today()));
        UtilityTestData.mOrderItemData.put('EndDate',String.valueOf(Date.today().addDays(450)));
        UtilityTestData.mOrderItemData.put('SBQQ__BillingType__c','Advance');
        UtilityTestData.mOrderItemData.put('SBQQ__DefaultSubscriptionTerm__c','1');
        UtilityTestData.mOrderItemData.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mOrderItemData.put('SBQQ__SubscriptionPricing__c','Percent Of Total');
        UtilityTestData.mOrderItemData.put('Ship_Date__c',String.valueOf(Date.today()));
        //UtilityTestData.mOrderItemData.put('SBQQ__Status__c','Activated');
        UtilityTestData.mOrderItemData.put('SBQQ__Activated__c','TRUE');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderItemData);
        List<OrderItem> lOrderItem = (List<OrderItem>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        System.runAs(userObj) {   
            
            Test.startTest();
            
            lOrderItem[0].SBQQ__Status__c = 'Activated';
            update lOrderItem;
            
            sObj = new Order(Id = lOrder[0].Id,Status = 'Activated',SBQQ__PriceCalcStatus__c = 'Completed',CMS_Approved__c = TRUE,Shipping_Email__c = 'test@test.com',BillingName_PSFTID__c = '1',BillingAddress_PSFTID__c='1',EndUserAddress_PSFTID__c='1',ShippingName_PSFTID__c='1',ShippingAddress_PSFTID__c='1',SoldAddress_PSFTID__c='1');
            List<Order> orderList1 = (List<Order>) UtilityTest.makeUpdate(new List<sObject>{sObj}); 
            
            sObj = new Contract(StartDate = System.Today().addDays(-300));
            UtilityTestData.mContractData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mContractData.put('SBQQ__Order__c',lOrder[0].Id);
            UtilityTestData.mContractData.put('StartDate', System.Today().addDays(-300)+'');
            UtilityTestData.mContractData.put('EndDate',System.Today().addDays(100)+'');
            UtilityTestData.mContractData.put('ContractTerm','10');
            sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mContractData);
            List<Contract> lContract  =  (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new Related_Order_and_Contract__c();
            UtilityTestData.mROC.put('Order__c',lOrder[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mROC);
            
            List<Related_Order_and_Contract__c> lROC = (List<Related_Order_and_Contract__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            system.debug('#lROC.Order__c:'+lROC[0].Order__c);
            
            sObj = new blng__RevenueSchedule__c();
            UtilityTestData.mRevSchedule.put('blng__RevenueRecognitionTreatment__c',lRevTreat[0].Id);
            UtilityTestData.mRevSchedule.put('blng__OrderProduct__c',lOrderItem[0].Id);
            UtilityTestData.mRevSchedule.put('RMCS_Contract_Line_Number__c','Test Rev Agree Batch');
            UtilityTestData.mRevSchedule.put('blng__TotalRevenueAmount__c','1000');
            UtilityTestData.mRevSchedule.put('Product__c',lProduct2[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRevSchedule);
            
            List<blng__RevenueSchedule__c> lRS= (List<blng__RevenueSchedule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //revenueAgreementBatch revAgreeBatch = new revenueAgreementBatch();
            //database.executebatch(revAgreeBatch,1);
            
            
            lOrderItem[0].Ship_Date__c= Date.Today();
            update lOrderItem;
            
            Test.stopTest();
        }
        
        
    }
    
    
    @isTest
    static void revenueAgreementBatchAmendT(){
        System.schedule('test revagreement batch', '0 0 * * * ?', new revenueAgreementBatch());
        List<Revenue_Agreement__c> lRA = [Select Id from Revenue_Agreement__c where ID IN (Select Revenue_Agreement__c from Related_Order_and_Contract__c where Order__r.Name =: 'Order for Revenue Agreement Batch')];
        if(!lRA.isEmpty()){
            lRA[0].Stage__c = 'Ready';
            lRA[0].Reset__c = TRUE;
            update lRA;
        }
        List<blng__RevenueSchedule__c> lRS = [Select Id from blng__RevenueSchedule__c where blng__OrderProduct__r.Order.Name =: 'Order for Revenue Agreement Batch'];
        if(!lRS.isEmpty()){
            lRS[0].Allocated_Bookings__c = 100;
            lRS[0].Sent_to_RMCS__c = TRUE;
            update lRS;
        }
    }
    
    @isTest
    static void revAgreementBatchOrderInactivated(){
        List<Order> lOrder = [SELECT Id FROM Order LIMIT 1];
        List<Account> lAccount = [SELECT Id FROM Account LIMIT 1];
        List<Product2> lProduct2 = [SELECT Id FROM Product2 LIMIT 2];
        List<Opportunity> lOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        List<OrderItem> lOrderItem = [SELECT Id FROM OrderItem LIMIT 1];
        Test.startTest();
        List<Contract> lContract = [SELECT Id FROM Contract LIMIT 1];
        List<Related_Order_and_Contract__c> lROC = [SELECT Id FROM Related_Order_and_Contract__c LIMIT 1];
        
        
        sobject sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'true');
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__EndDate__c', System.today().addDAys(30) + '');
        UtilityTestData.mSBQuoteData.put('Primary_Order__c',lOrder[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObject sObjSBQQSubscription = new SBQQ__Subscription__c();
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
        //UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lProduct2[0].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','10');
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');
        sObjSBQQSubscription = UtilityTest.putFieldRecord(sObjSBQQSubscription,UtilityTestData.mSBQQSubscriptionData);
        List<SBQQ__Subscription__c > sbbqSubscriptionlst  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObjSBQQSubscription});
        
        sObj = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', lQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', lProduct2[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c', '12');
        UtilityTestData.mQuoteLineData.put('SBQQ__UpgradedSubscription__c',sbbqSubscriptionlst[0].Id);        
        UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionPercent__c','20');
        UtilityTestData.mQuoteLineData.put('SBQQ__Discount__c','10');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
        
        /*sobject sObj1 = new SBQQ__QuoteLine__c();
UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', lQuote[0].Id);
UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', lProduct2[1].Id);        
UtilityTestData.mQuoteLineData.put('SBQQ__NetTotal__c','500');
UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c', '12');
//UtilityTestData.mQuoteLineData.put('SBQQ__UpgradedSubscription__c',sbbqSubscriptionlst[0].Id);
sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
*/
        List<SBQQ__QuoteLine__c> lQuoteLI = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        lOrder[0].SBQQ__Quote__c = lQuote[0].Id;
        update lOrder;
        /*
lQuote[1].SBQQ__MasterContract__c = lContract[1].Id;
update lQuote;

lContract[1].SBQQ__Quote__c = lQuote[1].Id;
update lContract;
*/
        lOrderItem[0].SBQQ__QuoteLine__c = lQuoteLI[0].Id;
        update lOrderItem;
        lOrderItem = [SELECT SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c FROM OrderItem WHERE Id = :lOrderItem[0].Id];
        system.debug('lOrderItem[0] SBQQ__UpgradedSubscription__c:'+lOrderItem[0].SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c);
        Test.stopTest();
        
        SBQQ__SubscribedQuoteLine__c sQL = new SBQQ__SubscribedQuoteLine__c(
            SBQQ__SubscriptionQuoteLine__c = lQuoteLI[0].Id,SBQQ__SubscriptionBasePrice__c = 100,
            SBQQ__AssetQuoteLineQuantity__c = 5,SBQQ__SubscriptionNetTotal__c = 1000);
        insert sQL;
        
        sObj = new Revenue_Agreement__c();
        UtilityTestData.mRevAgree.put('RMCS_Contract_Number__c','Test Rev Agree');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRevAgree);
        
        List<Revenue_Agreement__c> lRA = (List<Revenue_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        UtilityTestData.mROC.put('Id',lROC[0].Id);  
        UtilityTestData.mROC.put('Revenue_Agreement__c',lRA[0].Id);        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mROC);
        
        lROC = (List<Related_Order_and_Contract__c>) UtilityTest.makeUpdate(new List<sObject>{sObj});  
        revenueAgreementBatch revAgreeBatch = new revenueAgreementBatch();
        database.executebatch(revAgreeBatch,1);
        //System.schedule('test revagreement batch', '0 0 * * * ?', new revenueAgreementBatch());
    }
    
    @isTest
    static void revAgreementBatchOrderInactivated2(){
        List<Order> lOrder = [SELECT Id FROM Order LIMIT 1];
        List<Account> lAccount = [SELECT Id FROM Account LIMIT 1];
        List<Product2> lProduct2 = [SELECT Id FROM Product2 LIMIT 2];
        List<Opportunity> lOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        List<OrderItem> lOrderItem = [SELECT Id FROM OrderItem LIMIT 1];
        Test.startTest();
        List<Contract> lContract = [SELECT Id FROM Contract LIMIT 1];
        List<Related_Order_and_Contract__c> lROC = [SELECT Id FROM Related_Order_and_Contract__c LIMIT 1];
        //sobject sObj = new Order(Id = lOrder[0].Id,Type = 'New',Contract_Generated__c = TRUE);
        //List<Order> orderList1 = (List<Order>) UtilityTest.makeUpdate(new List<sObject>{sObj}); 
        
        
        sobject sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'true');
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__EndDate__c', System.today().addDAys(30) + '');
        UtilityTestData.mSBQuoteData.put('Primary_Order__c',lOrder[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObject sObjSBQQSubscription = new SBQQ__Subscription__c();
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
        //UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lProduct2[0].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','10');
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');
        sObjSBQQSubscription = UtilityTest.putFieldRecord(sObjSBQQSubscription,UtilityTestData.mSBQQSubscriptionData);
        List<SBQQ__Subscription__c > sbbqSubscriptionlst  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObjSBQQSubscription});
        
        sObj = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', lQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', lProduct2[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c', '12');
        UtilityTestData.mQuoteLineData.put('SBQQ__UpgradedSubscription__c',sbbqSubscriptionlst[0].Id);        
        UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionPercent__c','20');
        UtilityTestData.mQuoteLineData.put('SBQQ__Discount__c','10');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
        
        /*sobject sObj1 = new SBQQ__QuoteLine__c();
UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', lQuote[0].Id);
UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', lProduct2[1].Id);        
UtilityTestData.mQuoteLineData.put('SBQQ__NetTotal__c','500');
UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c', '12');
//UtilityTestData.mQuoteLineData.put('SBQQ__UpgradedSubscription__c',sbbqSubscriptionlst[0].Id);
sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
*/
        List<SBQQ__QuoteLine__c> lQuoteLI = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        lOrder[0].SBQQ__Quote__c = lQuote[0].Id;
        update lOrder;
        
        lQuote[0].SBQQ__MasterContract__c = lContract[0].Id;
        update lQuote;
        
        lContract[0].SBQQ__Quote__c = lQuote[0].Id;
        update lContract;
        
        lOrderItem[0].SBQQ__QuoteLine__c = lQuoteLI[0].Id;
        update lOrderItem;
        lOrderItem = [SELECT SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c FROM OrderItem WHERE Id = :lOrderItem[0].Id];
        system.debug('lOrderItem[0] SBQQ__UpgradedSubscription__c:'+lOrderItem[0].SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c);
        Test.stopTest();
        
        SBQQ__SubscribedQuoteLine__c sQL = new SBQQ__SubscribedQuoteLine__c(
            SBQQ__SubscriptionQuoteLine__c = lQuoteLI[0].Id,SBQQ__SubscriptionBasePrice__c = 100,
            SBQQ__AssetQuoteLineQuantity__c = 5,SBQQ__SubscriptionNetTotal__c = 1000);
        
        SBQQ__SubscribedQuoteLine__c sQL1 = new SBQQ__SubscribedQuoteLine__c(
            SBQQ__AssetQuoteLine__c = lQuoteLI[0].Id, SBQQ__SubscriptionQuoteLine__c = lQuoteLI[0].Id,SBQQ__SubscriptionBasePrice__c = 100,
            SBQQ__AssetQuoteLineQuantity__c = -5,SBQQ__SubscriptionNetTotal__c = 1000);
        
        List<SBQQ__SubscribedQuoteLine__c> sQLlist = new List<SBQQ__SubscribedQuoteLine__c>{sQL,sQL1};
            insert sQLlist;
        
        sObj = new Revenue_Agreement__c();
        UtilityTestData.mRevAgree.put('RMCS_Contract_Number__c','Test Rev Agree');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRevAgree);
        
        List<Revenue_Agreement__c> lRA = (List<Revenue_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        UtilityTestData.mROC.put('Id',lROC[0].Id);  
        UtilityTestData.mROC.put('Revenue_Agreement__c',lRA[0].Id);        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mROC);
        
        lROC = (List<Related_Order_and_Contract__c>) UtilityTest.makeUpdate(new List<sObject>{sObj});  
        revenueAgreementBatch revAgreeBatch = new revenueAgreementBatch();
        database.executebatch(revAgreeBatch,1);
        //System.schedule('test revagreement batch', '0 0 * * * ?', new revenueAgreementBatch());
    }
    @isTest
    static void revAgreementBatchOrderInactivated3(){
        List<Order> lOrder = [SELECT Id,Status,Asset_Creation_Status__c,Contract_Generated__c,Plan_Products_Created__c,
                              Sub_Type__c FROM Order LIMIT 1];
        List<Account> lAccount = [SELECT Id FROM Account LIMIT 1];
        List<Product2> lProduct2 = [SELECT Id FROM Product2 LIMIT 2];
        List<Opportunity> lOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        List<OrderItem> lOrderItem = [SELECT Id FROM OrderItem LIMIT 1];
        Test.startTest();
        List<Contract> lContract = [SELECT Id FROM Contract LIMIT 1];
        List<Related_Order_and_Contract__c> lROC = [SELECT Id FROM Related_Order_and_Contract__c WHERE Order__c != null LIMIT 1];
        //sobject sObj = new Order(Id = lOrder[0].Id,Type = 'New',Contract_Generated__c = TRUE);
        //List<Order> orderList1 = (List<Order>) UtilityTest.makeUpdate(new List<sObject>{sObj}); 
        
        
        sobject sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'true');
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__EndDate__c', System.today().addDAys(30) + '');
        UtilityTestData.mSBQuoteData.put('Primary_Order__c',lOrder[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObject sObjSBQQSubscription = new SBQQ__Subscription__c();
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
        //UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lProduct2[0].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','10');
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');
        sObjSBQQSubscription = UtilityTest.putFieldRecord(sObjSBQQSubscription,UtilityTestData.mSBQQSubscriptionData);
        List<SBQQ__Subscription__c > sbbqSubscriptionlst  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObjSBQQSubscription});
        
        sObj = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', lQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', lProduct2[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c', '12');
        UtilityTestData.mQuoteLineData.put('SBQQ__UpgradedSubscription__c',sbbqSubscriptionlst[0].Id);        
        UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionPercent__c','20');
        UtilityTestData.mQuoteLineData.put('SBQQ__Discount__c','10');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
        
        List<SBQQ__QuoteLine__c> lQuoteLI = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Revenue_Agreement__c();
        UtilityTestData.mRevAgree.put('RMCS_Contract_Number__c','Test Rev Agree');
        UtilityTestData.mRevAgree.put('Stage__c','Ready');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRevAgree);
        
        List<Revenue_Agreement__c> lRA = (List<Revenue_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Related_Order_and_Contract__c();
        UtilityTestData.mROC.put('Revenue_Agreement__c',lRA[0].Id); 
        UtilityTestData.mROC.put('Order__c',lOrder[0].Id); 
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mROC);        
        lROC = (List<Related_Order_and_Contract__c>) UtilityTest.makeInsert(new List<sObject>{sObj});  
        
        globalApexManager.avoidRecursion('OrderAfterUpdate') ;
        
        Id orderId = lOrder[0].Id;
        lOrder[0].Status = 'Bill & Contract'; 
        lOrder[0].Asset_Creation_Status__c = 'Completed';
        lOrder[0].Contract_Generated__c = true;
        lOrder[0].Plan_Products_Created__c = true;
        lOrder[0].Sub_Type__c = Label.RevisionLabel;
        lOrder[0].SBQQ__Quote__c = lQuote[0].Id;
        lOrder[0].Revenue_Agreement_Processed__c = TRUE;
        lOrder[0].BillingName_PSFTID__c = '1';
        lOrder[0].BillingAddress_PSFTID__c='1';
        lOrder[0].EndUserAddress_PSFTID__c='1';
        lOrder[0].ShippingName_PSFTID__c='1';
        lOrder[0].ShippingAddress_PSFTID__c='1';
        lOrder[0].SoldAddress_PSFTID__c='1';
        
        update lOrder;              
        
        revenueAgreementBatch revAgreeBatch = new revenueAgreementBatch();
        database.executebatch(revAgreeBatch,10);
        
        Test.stopTest();
    }
    @isTest
    static void revenueAgreementBatchRevisionOrder(){
        List<Opportunity> lOpportunity =  [SELECT Id FROM Opportunity LIMIT 1];
        List<Order> lOrder  = [SELECT Id FROM Order LIMIT 1];
        //Create Quote
        Test.startTest();
        sObject sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'true');
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__EndDate__c', System.today().addDAys(30) + '');
        UtilityTestData.mSBQuoteData.put('Primary_Order__c',lOrder[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        if(lOrder.size() > 0 && lQuote.size() > 0){            
            lOrder[0].Sub_Type__c = Label.RevisionLabel;
            lOrder[0].OpportunityId = lOpportunity[0].Id;
            lOrder[0].Contract_Generated__c = false;
            lOrder[0].SBQQ__Quote__c = lQuote[0].Id;
            update lOrder;            
            
            revenueAgreementBatch revAgreeBatch = new revenueAgreementBatch();
            database.executebatch(revAgreeBatch,10);
        }
        Test.stopTest();
    }
    @isTest
    static void updateRelatedRevOrderTest(){
        List<Order> lOrder = [SELECT Id,Status,Asset_Creation_Status__c,Contract_Generated__c,Plan_Products_Created__c,
                              Sub_Type__c FROM Order LIMIT 1];
        List<Account> lAccount = [SELECT Id FROM Account LIMIT 1];
        List<Product2> lProduct2 = [SELECT Id FROM Product2 LIMIT 2];
        List<Opportunity> lOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        List<OrderItem> lOrderItem = [SELECT Id FROM OrderItem LIMIT 1];
        Test.startTest();
        List<Contract> lContract = [SELECT Id FROM Contract LIMIT 1];
        List<Related_Order_and_Contract__c> lROC = [SELECT Id FROM Related_Order_and_Contract__c WHERE Order__c != null LIMIT 1];
        //sobject sObj = new Order(Id = lOrder[0].Id,Type = 'New',Contract_Generated__c = TRUE);
        //List<Order> orderList1 = (List<Order>) UtilityTest.makeUpdate(new List<sObject>{sObj}); 
        
        
        sobject sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'true');
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__EndDate__c', System.today().addDAys(30) + '');
        UtilityTestData.mSBQuoteData.put('Primary_Order__c',lOrder[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObject sObjSBQQSubscription = new SBQQ__Subscription__c();
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
        //UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lProduct2[0].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','-10');
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');
        sObjSBQQSubscription = UtilityTest.putFieldRecord(sObjSBQQSubscription,UtilityTestData.mSBQQSubscriptionData);
        List<SBQQ__Subscription__c > sbbqSubscriptionlst  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObjSBQQSubscription});
        
        sObj = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', lQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', lProduct2[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c', '12');
        UtilityTestData.mQuoteLineData.put('SBQQ__UpgradedSubscription__c',sbbqSubscriptionlst[0].Id);        
        UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionPercent__c','20');
        UtilityTestData.mQuoteLineData.put('SBQQ__Discount__c','10');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
        
        List<SBQQ__QuoteLine__c> lQuoteLI = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Revenue_Agreement__c();
        UtilityTestData.mRevAgree.put('RMCS_Contract_Number__c','Test Rev Agree');
        UtilityTestData.mRevAgree.put('Stage__c','Ready');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRevAgree);
        
        List<Revenue_Agreement__c> lRA = (List<Revenue_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Related_Order_and_Contract__c();
        UtilityTestData.mROC.put('Revenue_Agreement__c',lRA[0].Id); 
        UtilityTestData.mROC.put('Order__c',lOrder[0].Id); 
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mROC);        
        lROC = (List<Related_Order_and_Contract__c>) UtilityTest.makeInsert(new List<sObject>{sObj});  
        
        globalApexManager.avoidRecursion('OrderAfterUpdate') ;
        
        Id orderId = lOrder[0].Id;
        lOrder[0].Status = 'Bill & Contract'; 
        lOrder[0].Asset_Creation_Status__c = 'Completed';
        lOrder[0].Contract_Generated__c = true;
        lOrder[0].Plan_Products_Created__c = true;
        lOrder[0].Sub_Type__c = Label.RevisionLabel;
        lOrder[0].SBQQ__Quote__c = lQuote[0].Id;
        lOrder[0].Revenue_Agreement_Processed__c = TRUE;
        lOrder[0].BillingName_PSFTID__c = '1';
        lOrder[0].BillingAddress_PSFTID__c='1';
        lOrder[0].EndUserAddress_PSFTID__c='1';
        lOrder[0].ShippingName_PSFTID__c='1';
        lOrder[0].ShippingAddress_PSFTID__c='1';
        lOrder[0].SoldAddress_PSFTID__c='1';
        
        update lOrder;              
        
        revenueAgreementBatch revAgreeBatch = new revenueAgreementBatch();
        database.executebatch(revAgreeBatch,10);
        Test.stopTest();
    }
    
    @isTest
    static void raCancelfulfillDateTest(){
        List<Order> lOrder = [SELECT Id,Status,Asset_Creation_Status__c,Contract_Generated__c,Plan_Products_Created__c,
                              Sub_Type__c FROM Order LIMIT 1];
        List<Account> lAccount = [SELECT Id FROM Account LIMIT 1];
        List<Product2> lProduct2 = [SELECT Id FROM Product2 LIMIT 2];
        List<Opportunity> lOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        List<OrderItem> lOrderItem = [SELECT Id FROM OrderItem LIMIT 1];
        Test.startTest();
        List<Contract> lContract = [SELECT Id FROM Contract LIMIT 1];
        List<Related_Order_and_Contract__c> lROC = [SELECT Id FROM Related_Order_and_Contract__c WHERE Order__c != null LIMIT 1];
        //sobject sObj = new Order(Id = lOrder[0].Id,Type = 'New',Contract_Generated__c = TRUE);
        //List<Order> orderList1 = (List<Order>) UtilityTest.makeUpdate(new List<sObject>{sObj}); 
        
        
        sobject sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'true');
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__EndDate__c', System.today().addDAys(30) + '');
        UtilityTestData.mSBQuoteData.put('Primary_Order__c',lOrder[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObject sObjSBQQSubscription = new SBQQ__Subscription__c();
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
        //UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lProduct2[0].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','-10');
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');
        sObjSBQQSubscription = UtilityTest.putFieldRecord(sObjSBQQSubscription,UtilityTestData.mSBQQSubscriptionData);
        List<SBQQ__Subscription__c > sbbqSubscriptionlst  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObjSBQQSubscription});
        
        sObj = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', lQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', lProduct2[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c', '12');
        UtilityTestData.mQuoteLineData.put('SBQQ__UpgradedSubscription__c',sbbqSubscriptionlst[0].Id);        
        UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionPercent__c','20');
        UtilityTestData.mQuoteLineData.put('SBQQ__Discount__c','10');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
        
        List<SBQQ__QuoteLine__c> lQuoteLI = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Revenue_Agreement__c();
        UtilityTestData.mRevAgree.put('RMCS_Contract_Number__c','Test Rev Agree');
        UtilityTestData.mRevAgree.put('Stage__c','Ready');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRevAgree);
        
        List<Revenue_Agreement__c> lRA = (List<Revenue_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Related_Order_and_Contract__c();
        UtilityTestData.mROC.put('Revenue_Agreement__c',lRA[0].Id); 
        UtilityTestData.mROC.put('Order__c',lOrder[0].Id); 
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mROC);        
        lROC = (List<Related_Order_and_Contract__c>) UtilityTest.makeInsert(new List<sObject>{sObj});  
        
        globalApexManager.avoidRecursion('OrderAfterUpdate') ;
        
        Id orderId = lOrder[0].Id;
        lOrder[0].Status = 'Bill & Contract'; 
        lOrder[0].Asset_Creation_Status__c = 'Completed';
        lOrder[0].Contract_Generated__c = true;
        lOrder[0].Plan_Products_Created__c = true;
        lOrder[0].Sub_Type__c = Label.RevisionLabel;
        lOrder[0].SBQQ__Quote__c = lQuote[0].Id;
        lOrder[0].Revenue_Agreement_Processed__c = TRUE;
        lOrder[0].BillingName_PSFTID__c = '1';
        lOrder[0].BillingAddress_PSFTID__c='1';
        lOrder[0].EndUserAddress_PSFTID__c='1';
        lOrder[0].ShippingName_PSFTID__c='1';
        lOrder[0].ShippingAddress_PSFTID__c='1';
        lOrder[0].SoldAddress_PSFTID__c='1';
        
        update lOrder;              
        
        revenueAgreementBatch revAgreeBatch = new revenueAgreementBatch();
        database.executebatch(revAgreeBatch,10);
        List<blng__RevenueSchedule__c> rslst = new List<blng__RevenueSchedule__c>();
        for(blng__RevenueSchedule__c rs : [SELECT Revenue_Agreement__r.Id, Sent_to_RMCS__c, Status__c  FROM blng__RevenueSchedule__c]){
            rslst.add(new blng__RevenueSchedule__c(Id = rs.Id, Sent_to_RMCS__c = TRUE));
        }
        update rslst;
        revenueAgreementCancelFulfillDate updateJob = new revenueAgreementCancelFulfillDate(new Set<Id> {lOrder[0].Id},'Cancel_Debook');
        ID jobID = System.enqueueJob(updateJob);
        Test.stopTest();
    }
        @isTest
    static void raCancelfulfillDateTest2(){
        List<Order> lOrder = [SELECT Id,Status,Asset_Creation_Status__c,Contract_Generated__c,Plan_Products_Created__c,
                              Sub_Type__c FROM Order LIMIT 1];
        List<Account> lAccount = [SELECT Id FROM Account LIMIT 1];
        List<Product2> lProduct2 = [SELECT Id FROM Product2 LIMIT 2];
        List<Opportunity> lOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        List<OrderItem> lOrderItem = [SELECT Id FROM OrderItem LIMIT 1];
        Test.startTest();
        List<Contract> lContract = [SELECT Id FROM Contract LIMIT 1];
        List<Related_Order_and_Contract__c> lROC = [SELECT Id FROM Related_Order_and_Contract__c WHERE Order__c != null LIMIT 1];
        //sobject sObj = new Order(Id = lOrder[0].Id,Type = 'New',Contract_Generated__c = TRUE);
        //List<Order> orderList1 = (List<Order>) UtilityTest.makeUpdate(new List<sObject>{sObj}); 
        
        
        sobject sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'true');
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__EndDate__c', System.today().addDAys(30) + '');
        UtilityTestData.mSBQuoteData.put('Primary_Order__c',lOrder[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObject sObjSBQQSubscription = new SBQQ__Subscription__c();
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
        //UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lProduct2[0].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','-10');
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');
        sObjSBQQSubscription = UtilityTest.putFieldRecord(sObjSBQQSubscription,UtilityTestData.mSBQQSubscriptionData);
        List<SBQQ__Subscription__c > sbbqSubscriptionlst  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObjSBQQSubscription});
        
        sObj = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', lQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', lProduct2[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c', '12');
        UtilityTestData.mQuoteLineData.put('SBQQ__UpgradedSubscription__c',sbbqSubscriptionlst[0].Id);        
        UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionPercent__c','20');
        UtilityTestData.mQuoteLineData.put('SBQQ__Discount__c','10');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
        
        List<SBQQ__QuoteLine__c> lQuoteLI = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Revenue_Agreement__c();
        UtilityTestData.mRevAgree.put('RMCS_Contract_Number__c','Test Rev Agree');
        UtilityTestData.mRevAgree.put('Stage__c','Ready');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRevAgree);
        
        List<Revenue_Agreement__c> lRA = (List<Revenue_Agreement__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Related_Order_and_Contract__c();
        UtilityTestData.mROC.put('Revenue_Agreement__c',lRA[0].Id); 
        UtilityTestData.mROC.put('Order__c',lOrder[0].Id); 
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mROC);        
        lROC = (List<Related_Order_and_Contract__c>) UtilityTest.makeInsert(new List<sObject>{sObj});  
        
        globalApexManager.avoidRecursion('OrderAfterUpdate') ;
        
        Id orderId = lOrder[0].Id;
        lOrder[0].Status = 'Bill & Contract'; 
        lOrder[0].Asset_Creation_Status__c = 'Completed';
        lOrder[0].Contract_Generated__c = true;
        lOrder[0].Plan_Products_Created__c = true;
        lOrder[0].Sub_Type__c = Label.RevisionLabel;
        lOrder[0].SBQQ__Quote__c = lQuote[0].Id;
        lOrder[0].Revenue_Agreement_Processed__c = TRUE;
        lOrder[0].BillingName_PSFTID__c = '1';
        lOrder[0].BillingAddress_PSFTID__c='1';
        lOrder[0].EndUserAddress_PSFTID__c='1';
        lOrder[0].ShippingName_PSFTID__c='1';
        lOrder[0].ShippingAddress_PSFTID__c='1';
        lOrder[0].SoldAddress_PSFTID__c='1';
        
        update lOrder;              
        
        revenueAgreementBatch revAgreeBatch = new revenueAgreementBatch();
        database.executebatch(revAgreeBatch,10);
        List<blng__RevenueSchedule__c> rslst = new List<blng__RevenueSchedule__c>();
        for(blng__RevenueSchedule__c rs : [SELECT Revenue_Agreement__r.Id, Sent_to_RMCS__c, Status__c  FROM blng__RevenueSchedule__c]){
            rslst.add(new blng__RevenueSchedule__c(Id = rs.Id, Sent_to_RMCS__c = FALSE, Status__c = 'Active'));
        }
        update rslst;
        revenueAgreementCancelFulfillDate updateJob = new revenueAgreementCancelFulfillDate(new Set<Id> {lOrder[0].Id},'Cancel_Debook');
        ID jobID = System.enqueueJob(updateJob);
        
        Test.stopTest();
    }
}