/*
Class:          ContractAndSubsStatusUpdateBatchTest
@Author:        Chandana Gowda
@Created Date:  09-Nov-2020
@Description:   Test Class for ContractAndSubsStatusUpdateBatch

Change History
**********************************************************************************************************************************************************
ModifiedBy          Date        Requested By        Description                                                                             Tag
**********************************************************************************************************************************************************
**********************************************************************************************************************************************************
*/
@isTest
public class ContractAndSubsStatusUpdateBatchTest {
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
        UtilityTestData.mProduct2Data.put('Offering_Type__c','Cloud Hosted Subscription');
        sObj = new Product2();        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
        
        sObj1 = new Product2();               
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('Offering_Type__c','On-Premise One Time Term License');        
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
        
        sObj = new blng__LegalEntity__c();
        UtilityTestData.mLegalEntityData.put('Name','test');
        UtilityTestData.mLegalEntityData.put('Legal_Entity_Code__c','test123');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalEntityData);
        List<blng__LegalEntity__c> lLegalEntity = (List<blng__LegalEntity__c>) UtilityTest.makeInsert(new List<sObject>{sObj});    
        
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
         
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Opportunity();
        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Type','Direct');
        UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
        UtilityTestData.mOpportunityData.put('StageName','Validate');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        Test.startTest();
        lOpportunity[0].Pricebook2Id = lPriceBook2[0].Id;
        update lOpportunity[0];
        
        sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('AccountId',lAccount[0].Id);        
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunity[0].Id);
        UtilityTestData.mSBQuoteData.put('Shipping_Preference__c','Email');
        UtilityTestData.mSBQuoteData.put('SBQQ__BillingName__c','Test user');
        UtilityTestData.mSBQuoteData.put('SBQQ__ShippingName__c','Test user');
        UtilityTestData.mSBQuoteData.put('Shipping_Email__c','test@email.com');
        UtilityTestData.mSBQuoteData.put('PO__c','123213');
        UtilityTestData.mSBQuoteData.put('BillToAccount__c',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('ShiptToAccount__c',lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
       
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});     
        
        sObj = new Contract();
        UtilityTestData.mContractData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mContractData.put('Status','Draft');
        UtilityTestData.mContractData.put('SBQQ__Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mContractData.put('StartDate',System.today()+'');
        UtilityTestData.mContractData.put('Business_Model__c','Standard');
        UtilityTestData.mContractData.put('SBQQ__Quote__c',lQuote[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContractData);
        
        List<Contract> lContract = (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj1 = new Contract(Id = lContract[0].id,Status = 'Activated');
        lContract = (List<Contract>) UtilityTest.makeUpdate(new List<sObject>{sObj1}); 
        
        sObj = new Opportunity();
        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Type','Initiated');
        UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
        UtilityTestData.mOpportunityData.put('SBQQ__RenewedContract__c',lContract[0].id);        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        
        List<Opportunity> rOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj}); 
        Test.stopTest();
        //Unrenewed__r unren = new Unrenewed__r();
        //unren.
                
    }    
    
    static void testSetupforTestMethods(){
        
        Test.startTest();
        sObject sObj;sObject sObj1;sObject sObj2;sObject sObj3;
       
        List<Product2> lprodRec = [Select Id from Product2];
        Contract contractRec = [Select Id,AccountId,SBQQ__Opportunity__c,SBQQ__Quote__c from Contract where status='Activated' Limit 1];
        Opportunity renewedOpptyRec = [Select Id from Opportunity where SBQQ__RenewedContract__c=:contractRec.Id Limit 1];
         
       
        sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('AccountId',contractRec.AccountId);        
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',renewedOpptyRec.Id);
        UtilityTestData.mSBQuoteData.put('Shipping_Preference__c','Email');
        UtilityTestData.mSBQuoteData.put('SBQQ__BillingName__c','Test user');
        UtilityTestData.mSBQuoteData.put('SBQQ__ShippingName__c','Test user');
        UtilityTestData.mSBQuoteData.put('Shipping_Email__c','test@email.com');
        UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c','false');
        UtilityTestData.mSBQuoteData.put('PO__c','123213');
        UtilityTestData.mSBQuoteData.put('BillToAccount__c',contractRec.AccountId);
        UtilityTestData.mSBQuoteData.put('ShiptToAccount__c',contractRec.AccountId);        
        UtilityTestData.mSBQuoteData.put('Related_Contract__c',contractRec.Id); 
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
         
        List<SBQQ__Quote__c> rQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__ChargeType__c','Recurring');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingFrequency__c','Monthly');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingType__c','Advance');
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',contractRec.SBQQ__Quote__c);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lprodRec[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
        
        sObj1 = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__ChargeType__c','Recurring');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingFrequency__c','Monthly');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingType__c','Advance');
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',contractRec.SBQQ__Quote__c);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lprodRec[1].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
        
        sObj2 = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__ChargeType__c','Recurring');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingFrequency__c','Monthly');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingType__c','Advance');
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',rQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lprodRec[0].Id);
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);
        
        sObj3 = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__ChargeType__c','Recurring');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingFrequency__c','Monthly');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingType__c','Advance');
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',rQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lprodRec[1].Id);
        sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mQuoteLineData);
        
        List<SBQQ__QuoteLine__c> lSBQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3}); 
        
        sObject sObjSBQQSubscription = new SBQQ__Subscription__c();
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',contractRec.AccountId);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lprodRec[0].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',contractRec.Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__EndDate__c',System.Today().addDays(900)+'');
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','10');
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lSBQuoteLine[0].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');        
        sObjSBQQSubscription = UtilityTest.putFieldRecord(sObjSBQQSubscription,UtilityTestData.mSBQQSubscriptionData);
        
        sObj = new SBQQ__Subscription__c();
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',contractRec.AccountId);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lprodRec[1].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',contractRec.Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__EndDate__c',System.Today().addDays(900)+'');
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','10');
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lSBQuoteLine[1].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');        
        sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mSBQQSubscriptionData);
        
        sObj1 = new SBQQ__Subscription__c();
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',contractRec.AccountId);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lprodRec[0].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',contractRec.Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__EndDate__c',System.Today().addDays(900)+'');
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','10');
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lSBQuoteLine[2].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');
        sObj1 = UtilityTest.putFieldRecord(sObj1,UtilityTestData.mSBQQSubscriptionData);
        
        sObj2 = new SBQQ__Subscription__c();
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',contractRec.AccountId);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lprodRec[1].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',contractRec.Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__EndDate__c',System.Today().addDays(900)+'');
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','10');
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lSBQuoteLine[3].Id);
        UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');
        sObj2 = UtilityTest.putFieldRecord(sObj2,UtilityTestData.mSBQQSubscriptionData);
        
        List<SBQQ__Subscription__c> sbbqSubscriptionlst  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObjSBQQSubscription,sObj,sObj1,sObj2});  
        
        List<SBQQ__QuoteLine__c> quoteLineRen = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =:rQuote[0].Id];
        quoteLineRen[0].SBQQ__RenewedSubscription__c = sbbqSubscriptionlst[2].Id;
        quoteLineRen[1].SBQQ__RenewedSubscription__c = sbbqSubscriptionlst[3].Id;
        update quoteLineRen;
        
        sbbqSubscriptionlst[0].SBQQ__RevisedSubscription__c = sbbqSubscriptionlst[2].Id;
        sbbqSubscriptionlst[1].SBQQ__RevisedSubscription__c = sbbqSubscriptionlst[3].Id;
        update sbbqSubscriptionlst;
        
        Test.stopTest();
    }
    
    @isTest static void testContractStatusUpdate(){
        
        testSetupforTestMethods();
        ContractAndSubsStatusUpdateBatch contractStatus = new ContractAndSubsStatusUpdateBatch();
        Id batchId = Database.executeBatch(contractStatus);        
    } 
    
    @isTest static void testContractStatusUpdate2(){
        
        testSetupforTestMethods();        
        Opportunity renewedOpptyRec = [Select Id,SBQQ__RenewedContract__c from Opportunity where SBQQ__RenewedContract__c != null LIMIT 1];
        Contract sObj1 = new Contract(Id = renewedOpptyRec.SBQQ__RenewedContract__c,SBQQ__RenewalOpportunity__c = renewedOpptyRec.id);
        List<Contract> lContract = (List<Contract>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
        renewedOpptyRec = new Opportunity(Id = renewedOpptyRec.id ,StageName = 'Closed Lost', Analysis_Takeaways__c = 'Test', Ease_of_Renewal__c = '3- Not Easy', Next_Renewal_Considerations__c = 'Test', Next_Renewal_Likelyhood__c = 'May Renew 50/50', Stakeholders_Communication__c = 'Test', Stage_Reason__c='Won : Test class', Red_Flags__c = 'Pricing',Delivery__c='IPS Implementation', Solutions__c = 'Big Data', Next_Steps__c = 'Test', Current_Status__c  = 'Draft Opportunity Closing Plan');
        List<Opportunity> lOpportunityUpdated = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{renewedOpptyRec});        
        ContractAndSubsStatusUpdateBatch contractStatus = new ContractAndSubsStatusUpdateBatch();
        Id batchId = Database.executeBatch(contractStatus);        
    }
    
    @isTest static void testContractStatusUpdate3(){
        
        testSetupforTestMethods();
        List<SBQQ__Subscription__c> sbbqSubscriptionlst = [SELECT ID FROM SBQQ__Subscription__c WHERE SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Primary__c = false];
        sbbqSubscriptionlst[0].Cancel_Reason__c = 'Upgraded';
        sbbqSubscriptionlst[1].Cancel_Reason__c = 'Upgraded';
        update sbbqSubscriptionlst;           
        ContractAndSubsStatusUpdateBatch contractStatus = new ContractAndSubsStatusUpdateBatch();
        Id batchId = Database.executeBatch(contractStatus);        
    }
    
    
    @isTest static void testContractStatusUpdateProductRelated(){
        
        testSetupforTestMethods();
        List<SBQQ__Subscription__c> sbbqSubscriptionlst = [SELECT ID FROM SBQQ__Subscription__c WHERE SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Primary__c = false];
        sbbqSubscriptionlst[0].Cancel_Reason__c = 'Product Related';
        sbbqSubscriptionlst[1].Cancel_Reason__c = 'Product Related';
        update sbbqSubscriptionlst;           
        ContractAndSubsStatusUpdateBatch contractStatus = new ContractAndSubsStatusUpdateBatch();
        Id batchId = Database.executeBatch(contractStatus);        
    }
    
    @isTest static void testContractStatusUpdateCoTerm(){
        
        testSetupforTestMethods();
        List<SBQQ__Subscription__c> sbbqSubscriptionlst = [SELECT ID FROM SBQQ__Subscription__c WHERE SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Primary__c = false];
        sbbqSubscriptionlst[0].Cancel_Reason__c = 'Co-Term';
        sbbqSubscriptionlst[1].Cancel_Reason__c = 'Co-Term';
        update sbbqSubscriptionlst;           
        ContractAndSubsStatusUpdateBatch contractStatus = new ContractAndSubsStatusUpdateBatch();
        Id batchId = Database.executeBatch(contractStatus);        
    }
    
    // this method is to test ContractSubsStatusUpdate_Schedule class
    @isTest static void testContractSubsStatusUpdate_Schedule(){
        
        testSetupforTestMethods();
        ContractSubsStatusUpdate_Schedule contractStatus = new ContractSubsStatusUpdate_Schedule();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Sched', sch, contractStatus);         
    }    
}