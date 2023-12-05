/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against 
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
* 
*  @Author:        Sumitkumar Mittal
*  @Created Date:  05/07/2018
*  @Description:   Test class for OrderProductTriggerHandler with the updated test framework
* Change History
************************************************************************************************
* ModifiedBy          Date              Requested By        Description                     Tag
*   
************************************************************************************************
Vivek Warrier        09-Jan-2019       NA                  Adding required field values    <T1>
Pavithra V           10-Nov-2020       NA                  Adding method to update         <T2>
FulFillment Completed date
Anusha Akella      13-Sep-2021     SALESRT-13240    Updated the Meddicc fields in the opty update <T03>
Nikhil Mane        13-JAN-2022     I2C-1470         Updated OrderProduct field to meet Billing    <T04>
                          Frequency Invoice Plan condition  
Nikhil Mane       07-FEB-2022                                    <T05>
*/
@isTest
private class OrderProductTriggerHandlerTest {
    
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
        UtilityTestData.mProduct2Data.put('Tax_Product_Type__c','Services');
        sObj = new Product2();        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
        //system.debug('++++++' + sObj);
        
        sObj1 = new Product2();
        UtilityTestData.mProduct2Data.put('Name','Test');
        UtilityTestData.mProduct2Data.put('SBQQ__SubscriptionType__c','One-time');
        UtilityTestData.mProduct2Data.put('Product_Family__c', 'Other');
        UtilityTestData.mProduct2Data.put('Business_Unit__c', 'Professional Services');        
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProduct2Data);
        
        sObject sObj2 = new Product2();
        UtilityTestData.mProduct2Data.put('Name','Test2');
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);        
        UtilityTestData.mProduct2Data.put('Forecast_Product__c','Data Transformation');
        UtilityTestData.mProduct2Data.put('Product_Family__c', 'MDM');
        UtilityTestData.mProduct2Data.put('Business_Unit__c', 'Big Data');       
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mProduct2Data);
        
        List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});
        
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
        
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;
        
        sObj = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        
        sObj1 = new Account();
        UtilityTestData.mAccountData.put('Name','Testing');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountData);
        
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        sObj = new Opportunity();
        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Type','Direct');
        UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
        UtilityTestData.mOpportunityData.put('StageName','Validate');
        UtilityTestData.mOpportunityData.put('Pricebook2Id',lPriceBook2[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
                
        sObj = new blng__LegalEntity__c();
        UtilityTestData.mLegalEntityData.put('Name','test');
        UtilityTestData.mLegalEntityData.put('Legal_Entity_Code__c','test123');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalEntityData);
        List<blng__LegalEntity__c> lLegalEntity = (List<blng__LegalEntity__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        Test.startTest();
        //<T1>
        sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunity[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__PriceBook__c',lPriceBook2[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__PricebookId__c',lPriceBook2[0].Id+'');
        UtilityTestData.mSBQuoteData.put('Shipping_Preference__c','Email');
        UtilityTestData.mSBQuoteData.put('SBQQ__BillingName__c','Test user');
        UtilityTestData.mSBQuoteData.put('SBQQ__ShippingName__c','Test user');
        UtilityTestData.mSBQuoteData.put('Shipping_Email__c','test@email.com');
        UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c',System.today()+'');
        UtilityTestData.mSBQuoteData.put('SBQQ__EndDate__c',System.today().addMonths(12)+'');
        UtilityTestData.mSBQuoteData.put('PO__c','123213');
        UtilityTestData.mSBQuoteData.put('SBQQ__Status__c','Approved');
        UtilityTestData.mSBQuoteData.put('ApprovalStatus__c','Approved');
        UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c','true');
        UtilityTestData.mSBQuoteData.put('Co_Term_Long__c','true');
        UtilityTestData.mSBQuoteData.put('ShiptToAccount__c',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('BillToAccount__c',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('EndUserAccount__c',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('SoldToAccount__c',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('EndUserContact__c',lContact[0].Id);
        UtilityTestData.mSBQuoteData.put('BillToContact__c',lContact[0].Id);
        UtilityTestData.mSBQuoteData.put('ShipToContact__c',lContact[0].Id);
        UtilityTestData.mSBQuoteData.put('SoldToContact__c',lContact[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
        List<SBQQ__QuoteLine__c> lSBQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj});        
        //<T1>
        sObj = new Contract();
        UtilityTestData.mContractData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mContractData.put('Status','Draft');
        UtilityTestData.mContractData.put('SBQQ__Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mContractData.put('StartDate',System.today()+'');
        UtilityTestData.mContractData.put('Business_Model__c','Standard');
        //<T1>
        UtilityTestData.mContractData.put('SBQQ__Quote__c',lQuote[0].Id);
        //<T1>
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContractData);
        List<Contract> lContract = (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        //sObj1 = new Opportunity(Id = lOpportunity[0].id ,StageName = 'Closed Won', Analysis_Takeaways__c = 'Test', Ease_of_Renewal__c = '3- Not Easy', Next_Renewal_Considerations__c = 'Test', Next_Renewal_Likelyhood__c = 'May Renew 50/50', Stakeholders_Communication__c = 'Test', Stage_Reason__c='Won : Test class', Red_Flags__c = 'Pricing',Delivery__c='IPS Implementation', Solutions__c = 'IPU Expansion', Next_Steps__c = 'Test', Current_Status__c  = 'Draft Opportunity Closing Plan',Metrics__c  ='test',Economic_Buyer__c  = lContact[0].Id,Decision_Criteria__c  ='test',Decision_Process__c  ='test',Champion__c  = lContact[0].Id);
        sObj1 = new Opportunity(Id = lOpportunity[0].id ,StageName = 'Closed Won', Analysis_Takeaways__c = 'Test', Ease_of_Renewal__c = '3- Not Easy', Next_Renewal_Considerations__c = 'Test', Next_Renewal_Likelyhood__c = 'May Renew 50/50', Stakeholders_Communication__c = 'Test', Stage_Reason__c='Won : Test class', Red_Flags__c = 'Pricing',Delivery__c='IPS Implementation', Solutions__c = 'IPU Expansion', Next_Steps__c = 'Test', Current_Status__c  = 'Draft Opportunity Closing Plan');
        List<Opportunity> lOpportunityUpdated = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
        
        sObj1 = new SBQQ__Quote__c(Id = lQuote[0].Id ,SBQQ__Ordered__c = true); //<T1> Last two arguments);
        List<SBQQ__Quote__c> lQuoteUpdated = (List<SBQQ__Quote__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
        
        Test.stopTest();
    }
    
    /*Below method is to check the functional flow on Opportunity Insert*/
    @isTest
    Static void updateQuoteOrderOpportunityAnnual() {
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        SBQQ__Quote__c quoteRec = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        
        System.runAs(userObj) {
            List<OrderItem> lOrderItem = [Select Id from OrderItem where Order.SBQQ__Quote__c = : quoteRec.Id];
            
            /**Start**/
            List<Order> OrderLst = new List<Order>();
            OrderLst =[Select id,Source__c from Order where SBQQ__Quote__c = :quoteRec.Id];
            OrderLst[0].Billing_Alignment_Date__c = System.today()-10;
            OrderLst[0].Source__c = 'Fee';            
            update OrderLst;
            Test.startTest();
            for(OrderItem oi : lOrderItem){
                oi.SBQQ__BillingFrequency__c ='Annual';
                oi.Ship_Date__c = system.today()+1;
                oi.SBQQ__Status__c = 'Activated';
                oi.Statement_of_Position_SOP_Amount__c = 200;
                oi.blng__NextChargeDate__c = system.today();
            }
            update lOrderItem;
            /**End**/
            
            
            sObject sObj = new Asset(SBQQ__SubscriptionEndDate__c = System.today().addDays(300),One_Per_Unit_Total_Assets__c = 20,Status = 'Sent for Provisioning',AccountId = accRec.Id,SBQQ__OrderProduct__c = lOrderItem[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAssetData);
            List<Asset> lAsset = (List<Asset>) UtilityTest.makeInsert(new List<sObject>{sObj});
            system.assertEquals(lAsset.size(),1);
            
            Set<id> lOrderItemId = new Set<id>();
            lOrderItemId.add(lOrderItem[0].Id);
            OrderProductTriggerHandler.updateDate(lOrderItemId);
            //Nothing to assert
            
            Test.stopTest();
        }//END static testMethod void setCorrectStage()
    }
    
    @isTest
    Static void updateQuoteOrderOpportunitySemiAnnual() {
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        SBQQ__Quote__c quoteRec = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        
        System.runAs(userObj) {
            List<OrderItem> lOrderItem = [Select Id from OrderItem where Order.SBQQ__Quote__c = : quoteRec.Id];
            
            /**Start**/
            List<Order> OrderLst = new List<Order>();
            OrderLst =[Select id,Source__c from Order where SBQQ__Quote__c = :quoteRec.Id];
            OrderLst[0].Billing_Alignment_Date__c = System.today()-10;
            OrderLst[0].Source__c = 'Fee';            
            update OrderLst;
            Test.startTest();
            for(OrderItem oi : lOrderItem){
                oi.SBQQ__BillingFrequency__c ='Semiannual';
                oi.Ship_Date__c = system.today()+1;
                oi.SBQQ__Status__c = 'Activated';
                oi.Statement_of_Position_SOP_Amount__c = 200;
                oi.blng__NextChargeDate__c = system.today();
            }
            update lOrderItem;
            /**End**/
            
            sObject sObj = new Asset(SBQQ__SubscriptionEndDate__c = System.today().addDays(300),One_Per_Unit_Total_Assets__c = 20,Status = 'Sent for Provisioning',AccountId = accRec.Id,SBQQ__OrderProduct__c = lOrderItem[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAssetData);
            List<Asset> lAsset = (List<Asset>) UtilityTest.makeInsert(new List<sObject>{sObj});
            system.assertEquals(lAsset.size(),1);
            
            Set<id> lOrderItemId = new Set<id>();
            lOrderItemId.add(lOrderItem[0].Id);
            OrderProductTriggerHandler.updateDate(lOrderItemId);
            //Nothing to assert
            
            Test.stopTest();
        }//END static testMethod void setCorrectStage()
    }
    
    @isTest
    Static void updateQuoteOrderOpportunityQuarterly() {
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        SBQQ__Quote__c quoteRec = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        System.runAs(userObj) {
            List<OrderItem> lOrderItem = [Select Id from OrderItem where Order.SBQQ__Quote__c = : quoteRec.Id];
            
            /**Start**/
            List<Order> OrderLst = new List<Order>();
            OrderLst =[Select id,Source__c from Order where SBQQ__Quote__c = :quoteRec.Id];
            OrderLst[0].Billing_Alignment_Date__c = System.today()-10;
            OrderLst[0].Source__c = 'Fee';            
            update OrderLst;
            
            for(OrderItem oi : lOrderItem){
                oi.SBQQ__BillingFrequency__c ='Quarterly';
                oi.Ship_Date__c = system.today()+1;
                oi.SBQQ__Status__c = 'Activated';
                oi.Statement_of_Position_SOP_Amount__c = 200;
                oi.blng__NextChargeDate__c = system.today();
            }
            update lOrderItem;
            /**End**/
            
            sObject sObj = new Asset(SBQQ__SubscriptionEndDate__c = System.today().addDays(300),One_Per_Unit_Total_Assets__c = 20,Status = 'Sent for Provisioning',AccountId = accRec.Id,SBQQ__OrderProduct__c = lOrderItem[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAssetData);
            List<Asset> lAsset = (List<Asset>) UtilityTest.makeInsert(new List<sObject>{sObj});
            system.assertEquals(lAsset.size(),1);
            
            Set<id> lOrderItemId = new Set<id>();
            lOrderItemId.add(lOrderItem[0].Id);
            OrderProductTriggerHandler.updateDate(lOrderItemId);
            //Nothing to assert
            
            Test.stopTest();
        }//END static testMethod void setCorrectStage()
    }
   
    @isTest
    Static void updateQuoteOrderOpportunityMonthly() {
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        SBQQ__Quote__c quoteRec = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        
        System.runAs(userObj) {
            List<OrderItem> lOrderItem = [Select Id from OrderItem where Order.SBQQ__Quote__c = : quoteRec.Id];
            
            /**Start**/
            List<Order> OrderLst = new List<Order>();
            OrderLst =[Select id,Source__c from Order where SBQQ__Quote__c = :quoteRec.Id];
            OrderLst[0].Billing_Alignment_Date__c = System.today()+10;
            OrderLst[0].Source__c = 'Fee';            
            update OrderLst;
            Test.startTest();
            for(OrderItem oi : lOrderItem){
                oi.SBQQ__BillingFrequency__c ='Monthly';
                oi.Ship_Date__c = system.today()+1;
                oi.SBQQ__Status__c = 'Activated';
                oi.Statement_of_Position_SOP_Amount__c = 200;
                oi.blng__NextChargeDate__c = system.today();
            }
            update lOrderItem;
            /**End**/
            
            sObject sObj = new Asset(SBQQ__SubscriptionEndDate__c = System.today().addDays(300),One_Per_Unit_Total_Assets__c = 20,Status = 'Sent for Provisioning',AccountId = accRec.Id,SBQQ__OrderProduct__c = lOrderItem[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAssetData);
            List<Asset> lAsset = (List<Asset>) UtilityTest.makeInsert(new List<sObject>{sObj});
            system.assertEquals(lAsset.size(),1);
            
            Set<id> lOrderItemId = new Set<id>();
            lOrderItemId.add(lOrderItem[0].Id);
            OrderProductTriggerHandler.updateDate(lOrderItemId);
            //Nothing to assert
            
            Test.stopTest();
        }//END static testMethod void setCorrectStage()
    }
    
    
    //Below methods are replica of the above methds with Billing alighment date less than today
    @isTest
    Static void updateQuoteOrderOpportunityAnnual1() {
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        SBQQ__Quote__c quoteRec = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        
        System.runAs(userObj) {
            List<OrderItem> lOrderItem = [Select Id from OrderItem where Order.SBQQ__Quote__c = : quoteRec.Id];
            
            /**Start**/
            List<Order> OrderLst = new List<Order>();
            OrderLst =[Select id,Source__c from Order where SBQQ__Quote__c = :quoteRec.Id];
            OrderLst[0].Billing_Alignment_Date__c = System.today()+10;
            OrderLst[0].Source__c = 'Fee';            
            update OrderLst;
            Test.startTest();
            for(OrderItem oi : lOrderItem){
                oi.SBQQ__BillingFrequency__c ='Quarterly';
                oi.Ship_Date__c = system.today()+1;
                oi.SBQQ__Status__c = 'Activated';
                oi.Statement_of_Position_SOP_Amount__c = 200;
                oi.blng__NextChargeDate__c = system.today();
            }
            update lOrderItem;
            /**End**/
            
            sObject sObj = new Asset(SBQQ__SubscriptionEndDate__c = System.today().addDays(300),One_Per_Unit_Total_Assets__c = 20,Status = 'Sent for Provisioning',AccountId = accRec.Id,SBQQ__OrderProduct__c = lOrderItem[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAssetData);
            List<Asset> lAsset = (List<Asset>) UtilityTest.makeInsert(new List<sObject>{sObj});
            system.assertEquals(lAsset.size(),1);
            
            Set<id> lOrderItemId = new Set<id>();
            lOrderItemId.add(lOrderItem[0].Id);
            OrderProductTriggerHandler.updateDate(lOrderItemId);
            //Nothing to assert
            
            Test.stopTest();
        }//END static testMethod void setCorrectStage()
    }
    
    @isTest
    Static void updateQuoteOrderOpportunityMonthly1() {
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        SBQQ__Quote__c quoteRec = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        
        System.runAs(userObj) {
            List<OrderItem> lOrderItem = [Select Id from OrderItem where Order.SBQQ__Quote__c = : quoteRec.Id];
            
            /**Start**/
            List<Order> OrderLst = new List<Order>();
            OrderLst =[Select id,Source__c from Order where SBQQ__Quote__c = :quoteRec.Id];
            OrderLst[0].Billing_Alignment_Date__c = System.today()-10;
            OrderLst[0].Source__c = 'Fee';            
            update OrderLst;
            Test.startTest();
            for(OrderItem oi : lOrderItem){
                oi.SBQQ__BillingFrequency__c ='Monthly';
                oi.Ship_Date__c = system.today()+1;
                oi.SBQQ__Status__c = 'Activated';
                oi.Statement_of_Position_SOP_Amount__c = 200;
                oi.blng__NextChargeDate__c = system.today();
            }
            update lOrderItem;
            /**End**/
            
            sObject sObj = new Asset(SBQQ__SubscriptionEndDate__c = System.today().addDays(300),One_Per_Unit_Total_Assets__c = 20,Status = 'Sent for Provisioning',AccountId = accRec.Id,SBQQ__OrderProduct__c = lOrderItem[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAssetData);
            List<Asset> lAsset = (List<Asset>) UtilityTest.makeInsert(new List<sObject>{sObj});
            system.assertEquals(lAsset.size(),1);
            
            Set<id> lOrderItemId = new Set<id>();
            lOrderItemId.add(lOrderItem[0].Id);
            OrderProductTriggerHandler.updateDate(lOrderItemId);
            //Nothing to assert
            
            Test.stopTest();
        }//END static testMethod void setCorrectStage()
    }
    
    @isTest
    static void updatefulfillmentCompletiondate() {
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<SBQQ__Quote__c> lQuoteUpdated1 = [SELECT Id FROM SBQQ__Quote__c];
        
        System.runAs(userObj) {
            
            List<Order> OrderLst = new List<Order>();
            OrderLst =[Select id,Source__c from Order where SBQQ__Quote__c = :lQuoteUpdated1[0].Id];
            OrderLst[0].Billing_Alignment_Date__c = System.today()-10;
            OrderLst[0].Source__c = 'ES'; 
            OrderLst[0].Sub_Type__c='Revision';
            update OrderLst;
            Test.startTest();
            Map<Id,OrderItem> OrderItemMap = new Map<Id,OrderItem>();
            
            List<OrderItem> lOrderItem = [Select Id from OrderItem where Order.SBQQ__Quote__c = : lQuoteUpdated1[0].Id];
            for(OrderItem oitem : lOrderItem){
                OrderItemMap.put(oitem.Id, oitem);
                oitem.Ship_Date__c = system.today();
                oitem.SBQQ__Status__c = 'Activated';
                oitem.SBQQ__BillingFrequency__c ='Monthly';
                oitem.Statement_of_Position_SOP_Amount__c = 200;
                oitem.blng__NextChargeDate__c = system.today();
            }
            update lOrderItem;
            system.debug( 'No of Queries issued 5 >>'+Limits.getQueries());
            
            Set<String> OrderIdSet = new Set<String>();
            OrderIdSet.add(OrderLst[0].Id);
            
            Fulfillment__c ffheader = new Fulfillment__c();
            ffheader.Active__c=true;
            ffheader.Order__c=OrderLst[0].Id;
            insert ffheader;
            
            List<id> fflist = new List<id>();
            
            fflist.add(OrderLst[0].id);
            
            List<Fulfillment_Line__c> ffline = new List<Fulfillment_Line__c>();
            Fulfillment_Line__c ffline1 = new Fulfillment_Line__c();
            ffline1.Ship_Status__c='Provisioning Complete';
            ffline1.Ship_Date__c= System.today();
            ffline1.Fullfillment__c= ffheader.Id;
            ffline.add(ffline1);
            insert ffline;
            
            User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1];
            
            
            OrderProductTriggerHandler.updateOrderStatus(OrderIdSet);
            //OrderProductTriggerHandler.afterInsert(OrderItemMap);
            
            system.runAs(adminUser){
                ShipCompleteInlineEditCtrl shpcomp = new ShipCompleteInlineEditCtrl();  
                List<Fulfillment_Line__c>  fulfill_ln1 = ShipCompleteInlineEditCtrl.getFulfillmentLines(ffline[0].id) ;
                String str= JSON.serialize(ffline);
                List<Fulfillment_Line__c>  fulfill_ln2= ShipCompleteInlineEditCtrl.updateFulfillments(str) ;              
                InvokableGenerateFulfillments.invokeFulfillmentCreation(fflist);                
                
            }
            Test.stopTest();
        }
    }
    @isTest
    static void updatefulfillmentCompletiondateReturnAfterUpdate() {
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<SBQQ__Quote__c> lQuoteUpdated1 = [SELECT Id FROM SBQQ__Quote__c];
        
        System.runAs(userObj) {
            
            List<Order> OrderLst = new List<Order>();
            OrderLst =[Select id,Source__c from Order where SBQQ__Quote__c = :lQuoteUpdated1[0].Id];
            OrderLst[0].Billing_Alignment_Date__c = System.today()-10;
            OrderLst[0].Source__c = 'ES'; 
            OrderLst[0].Sub_Type__c='Revision';
            update OrderLst;
            Test.startTest();
            Map<Id,OrderItem> OrderItemMap = new Map<Id,OrderItem>();
            
            List<OrderItem> lOrderItem = [Select Id from OrderItem where Order.SBQQ__Quote__c = : lQuoteUpdated1[0].Id];
            for(OrderItem oitem : lOrderItem){
                OrderItemMap.put(oitem.Id, oitem);
                oitem.Ship_Date__c = system.today();
                oitem.SBQQ__Status__c = 'Activated';
                oitem.SBQQ__BillingFrequency__c ='Monthly';
                oitem.Statement_of_Position_SOP_Amount__c = 200;
                oitem.blng__NextChargeDate__c = system.today();
            }
            globalApexManager.avoidRecursion(null);
            update lOrderItem;
            system.debug( 'No of Queries issued 5 >>'+Limits.getQueries());
            
            Set<String> OrderIdSet = new Set<String>();
            OrderIdSet.add(OrderLst[0].Id);
            
            Fulfillment__c ffheader = new Fulfillment__c();
            ffheader.Active__c=true;
            ffheader.Order__c=OrderLst[0].Id;
            insert ffheader;
            
            List<id> fflist = new List<id>();
            
            fflist.add(OrderLst[0].id);
            
            List<Fulfillment_Line__c> ffline = new List<Fulfillment_Line__c>();
            Fulfillment_Line__c ffline1 = new Fulfillment_Line__c();
            ffline1.Ship_Status__c='Provisioning Complete';
            ffline1.Ship_Date__c= System.today();
            ffline1.Fullfillment__c= ffheader.Id;
            ffline.add(ffline1);
            insert ffline;
            
            User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1];
            
            
            OrderProductTriggerHandler.updateOrderStatus(OrderIdSet);
            //OrderProductTriggerHandler.afterInsert(OrderItemMap);
            
            system.runAs(adminUser){
                ShipCompleteInlineEditCtrl shpcomp = new ShipCompleteInlineEditCtrl();  
                List<Fulfillment_Line__c>  fulfill_ln1 = ShipCompleteInlineEditCtrl.getFulfillmentLines(ffline[0].id) ;
                String str= JSON.serialize(ffline);
                List<Fulfillment_Line__c>  fulfill_ln2= ShipCompleteInlineEditCtrl.updateFulfillments(str) ;              
                InvokableGenerateFulfillments.invokeFulfillmentCreation(fflist);                
                
            }
            Test.stopTest();
        }
    }
    
    /** <T02> ENDS **/
    @isTest
    Static void UpdateOrderProductBillingFrequency() {
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<SBQQ__Quote__c> lQuoteUpdated1 = [SELECT Id FROM SBQQ__Quote__c];
        
        System.runAs(userObj) {
            
            List<Order> OrderLst = new List<Order>();
            List<OrderItem> lOrderItem = [Select Id from OrderItem where Order.SBQQ__Quote__c = : lQuoteUpdated1[0].Id];
            OrderLst =[Select id,Source__c from Order where SBQQ__Quote__c = :lQuoteUpdated1[0].Id];
            Test.startTest();
            /**End**/    
            //SBQQ__Quote__c quoterec = AccountHold.getisAccountHeldVarQuote(lQuoteUpdated1[0].Id);
            String str3= UpdateOrderProductBillingFrequency.UpdateOrderProductBillingFreq(OrderLst[0].id, 'One-Time/Accelerate',false);
            String str= UpdateOrderProductBillingFrequency.UpdateOrderProductBillingFreq(OrderLst[0].id, 'Annual',false);            
            String str1= UpdateOrderProductBillingFrequency.UpdateOrderProductBillingFreq(OrderLst[0].id, 'Monthly',true);
            Boolean bool1= UpdateOrderProductBillingFrequency.CheckOrderProductBillingFreq(OrderLst[0].id);
            delete lOrderItem;
            //<T04>
            String str2= UpdateOrderProductBillingFrequency.UpdateOrderProductBillingFreq(OrderLst[0].id,'Monthly',false);

 
            Test.stopTest();
        }
    } 
    @isTest
    Static void UpdateOrderProductBillingFrequency2() {
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<SBQQ__Quote__c> lQuoteUpdated1 = [SELECT Id FROM SBQQ__Quote__c];
        
        System.runAs(userObj) {
            
            List<Order> OrderLst = new List<Order>();
            List<OrderItem> lOrderItem = [Select Id from OrderItem where Order.SBQQ__Quote__c = : lQuoteUpdated1[0].Id];
            OrderLst =[Select id,Source__c from Order where SBQQ__Quote__c = :lQuoteUpdated1[0].Id];
            Test.startTest();
            /**End**/    
            //SBQQ__Quote__c quoterec = AccountHold.getisAccountHeldVarQuote(lQuoteUpdated1[0].Id);
            String str3= UpdateOrderProductBillingFrequency.UpdateOrderProductBillingFreq(OrderLst[0].id, 'Invoice Plan',false);
            String str= UpdateOrderProductBillingFrequency.UpdateOrderProductBillingFreq(OrderLst[0].id, 'Annual',false);            
            String str1= UpdateOrderProductBillingFrequency.UpdateOrderProductBillingFreq(OrderLst[0].id, 'Invoice Plan',true);
            Test.stopTest();
        }
    } 
    @isTest
    Static void calculateBTOD() {
    Date NCD = Date.Today();
    Date EndDate = Date.Today().addMonths(11);
    OrderProductTriggerHandler.calcBTOD(NCD,EndDate,'Annual');
    OrderProductTriggerHandler.calcBTOD(NCD,EndDate,'Semiannual');
    OrderProductTriggerHandler.calcBTOD(NCD,EndDate,'Quarterly');
    OrderProductTriggerHandler.calcBTOD(NCD,EndDate,'Monthly');
    OrderProductTriggerHandler.calcBTOD(NCD,EndDate,'Invoice Plan');
    
    
    }
    @isTest
    static void orderItemInsert(){
        Test.startTest();
        List<Account> lAccount = [SELECT Id FROM Account LIMIT 1];
        List<Opportunity> lOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        List<blng__LegalEntity__c> lLegalEntity = [SELECT Id FROM blng__LegalEntity__c LIMIT 1];
        List<PricebookEntry> lPriceBookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
        List<Product2> lProduct2 = [SELECT Id FROM Product2 LIMIT 1];   
        List<blng__RevenueRecognitionRule__c> lRevRecRule = [SELECT Id FROM blng__RevenueRecognitionRule__c LIMIT 1]; 
        Id pricebookId = Test.getStandardPricebookId(); 
        
        sObject sObj = new Order();
        UtilityTestData.mOrderData.put('SBQQ__PaymentTerm__c','Other');
        UtilityTestData.mOrderData.put('OpportunityId',lOpportunity[0].Id);
        UtilityTestData.mOrderData.put('Name','Order for Revenue Agreement Batch');
        UtilityTestData.mOrderData.put('Legal_Entity__c',lLegalEntity[0].Id);
        UtilityTestData.mOrderData.put('Pricebook2Id',pricebookId);
        UtilityTestData.mOrderData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOrderData.put('Type','Amendment');
        UtilityTestData.mOrderData.put('Source__c','Fee');
        UtilityTestData.mOrderData.put('EffectiveDate',String.valueOf(Date.today()));
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
        
        Test.stopTest();
    }
    
    @isTest
    Static void updateBillingDatesTest() {
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<SBQQ__Quote__c> lQuoteUpdated1 = [SELECT Id FROM SBQQ__Quote__c];
        
        System.runAs(userObj) {
            
            List<Order> OrderLst = new List<Order>();
            List<OrderItem> lOrderItem = [Select Id from OrderItem where Order.SBQQ__Quote__c = : lQuoteUpdated1[0].Id];
            OrderLst =[Select id,Source__c from Order where SBQQ__Quote__c = :lQuoteUpdated1[0].Id];
            Test.startTest();
            /**End**/    
            //SBQQ__Quote__c quoterec = AccountHold.getisAccountHeldVarQuote(lQuoteUpdated1[0].Id);
            String str3= UpdateOrderProductBillingFrequency.updateBillingDates(OrderLst[0].id, Date.today().addDays(10),Date.today().addDays(5));
            Test.stopTest();
        }//END static testMethod void setCorrectStage()
    } 
    /*
    @isTest
    Static void updateBillingDatesTest() {
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and Name = 'Datamigration Master' and IsActive = true limit 1];
        SBQQ__Quote__c quoteRec = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        System.runAs(userObj) {
            List<OrderItem> lOrderItem = [Select Id, blng__OverrideNextBillingDate__c, blng__BillThroughDateOverride__c, orderId,
                                          SBQQ__BillingFrequency__c, SBQQ__ChargeType__c, blng__InvoiceRunProcessingStatus__c, blng__NextBillingDate__c
                                          from OrderItem where Order.SBQQ__Quote__c = : quoteRec.Id];
            system.debug('Nishit '+lOrderItem[0]);
            
            List<Order> OrderLst = new List<Order>();
            for(OrderItem oi : lOrderItem){
                oi.SBQQ__BillingFrequency__c ='Annual';
                oi.Ship_Date__c = system.today()+1;
                oi.SBQQ__DefaultSubscriptionTerm__c = 1;
                oi.SBQQ__Status__c = 'Activated';
                oi.Statement_of_Position_SOP_Amount__c = 200;
                oi.blng__NextChargeDate__c = system.today();
            }
            update lOrderItem;
            update new Order(Id = lOrderItem[0].orderId, status = 'Activated');
            Test.startTest();
            String str3= UpdateOrderProductBillingFrequency.updateBillingDates(lOrderItem[0].orderId, Date.today().addDays(10),Date.today().addDays(5));
            Test.stopTest();           
        } 
    }*/
}