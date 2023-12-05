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
*  @Created Date:  05/03/2018
*  @Description:   Test class for OrderTriggerHandlerclass with the updated test framework
* Change History
********************************************************************************************************
* ModifiedBy          Date        Requested By        Description                                                       Tag
* Wasim Akram       1/14/2020       Liz             Fixed errors that occurred due to Process Builder check for Quote   <T1>
*                                                   Business Model for Contract update/insert
*Pavithra V         1/07/2021       F2A-329         To update the Ship date on the order product to be in line with     <T2>
order generation date for all the products  
* Anusha Akella    13-Sep-2021     SALESRT-13240            Updated the Meddicc fields in the opty update <T03>
*Sreerekha 		   25-Jul-2023     I2C-1916					Introduce additional Ship to Contact & Email on the Order  <T04>
******************************************************************
*/
@isTest
private class OrderTriggerHandlerTest {
    
    private Final static String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
    private Final static String ACC_Prospect_Account_Record_Type = Label.Prospect_Account_Record_Type;
    
    @testSetup
    static void setupObjectTestData() {
        
        User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1];
        
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
            sObj = new Product2();        
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
            //system.debug('++++++' + sObj);
            
            sObj1 = new Product2();
            UtilityTestData.mProduct2Data.put('Name','Test');
            
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProduct2Data);
            
            sObject sObj2 = new Product2();
            UtilityTestData.mProduct2Data.put('Name','Test2');
            UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
            UtilityTestData.mProduct2Data.put('Offering_Type__c','On-Premise One Time Term License'); 
            UtilityTestData.mProduct2Data.put('SBQQ__SubscriptionTerm__c','12');    
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
            UtilityTestData.mAccountData.put('PO_Required__c','True');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            
            sObj1 = new Account();
            UtilityTestData.mAccountData.put('Name','Testing');
            UtilityTestData.mAccountData.put('PO_Required__c','True');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountData);
            
            List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
            sObj = new Account_LOB__c();
            UtilityTestData.mAccountLOB.put('Account__c',lAccount[0].id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountLOB);
            
            sObj1 = new Account_LOB__c();
            UtilityTestData.mAccountLOB.put('Account__c',lAccount[1].id);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountLOB);
            
            sObj2 = new Account_LOB__c();
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
            sObj1 = new Contact();
            UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mContactData.put('FirstName','test Con FirstName11');
            UtilityTestData.mContactData.put('LastName','test Con LastName11');
            UtilityTestData.mContactData.put('Email','test123@test.com');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mContactData);
            List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
            
            sObj = new Opportunity();
            UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('Type','Direct');
            UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
            UtilityTestData.mOpportunityData.put('StageName','Validate');
            UtilityTestData.mOpportunityData.put('Name','OrderTriggerHandler');
            UtilityTestData.mOpportunityData.put('Pricebook2Id',lPriceBook2[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //lOpportunity[0].Pricebook2Id = lPriceBook2[0].Id;
            //update lOpportunity[0];
            
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
            
            //<T1>
            sObj = new SBQQ__Quote__c();
            UtilityTestData.mSBQuoteData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__PriceBook__c',lPriceBook2[0].Id);
            UtilityTestData.mSBQuoteData.put('Price_Book_2__c',lPriceBook2[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__PricebookId__c',lPriceBook2[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__PriceBook__c',lPriceBook2[0].Id);
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
            UtilityTestData.mSBQuoteData.put('Additional_Ship_to_Contact__c',lContact[0].Id); //<T04>
            UtilityTestData.mSBQuoteData.put('Additional_Shipping_Email__c','test@gmail.com'); //<T04>
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
            List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            //<T1>
            sObj = new Contract();
            UtilityTestData.mContractData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mContractData.put('Status','Draft');
            UtilityTestData.mContractData.put('SBQQ__Opportunity__c',lOpportunity[0].Id);
            UtilityTestData.mContractData.put('StartDate',System.today()+'');
            //<T1>
            UtilityTestData.mContractData.put('SBQQ__Quote__c',lQuote[0].Id);
            //<T1>
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContractData);
            List<Contract> lContract = (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new SBQQ__Quote__c();
            UtilityTestData.mSBQuoteData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunity[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__PriceBook__c',lPriceBook2[0].Id);
            UtilityTestData.mSBQuoteData.put('Price_Book_2__c',lPriceBook2[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__PricebookId__c',lPriceBook2[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__PriceBook__c',lPriceBook2[0].Id);
            UtilityTestData.mSBQuoteData.put('Legal_Entity__c',lLegalEntity[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__MasterContract__c',lContract[0].Id);
            UtilityTestData.mSBQuoteData.put('Shipping_Preference__c','Email');
            UtilityTestData.mSBQuoteData.put('SBQQ__BillingName__c','Test user');
            UtilityTestData.mSBQuoteData.put('SBQQ__ShippingName__c','Test user');
            UtilityTestData.mSBQuoteData.put('Shipping_Email__c','test@email.com');
            UtilityTestData.mSBQuoteData.put('SBQQ__PaymentTerms__c','Other');
            UtilityTestData.mSBQuoteData.put('PO__c','123213');
            UtilityTestData.mSBQuoteData.put('BillToAccount__c',lAccount[0].Id);
            UtilityTestData.mSBQuoteData.put('ShiptToAccount__c',lAccount[0].Id);
            UtilityTestData.mSBQuoteData.put('BillToContact__c',lContact[0].Id);
            UtilityTestData.mSBQuoteData.put('ShipToContact__c',lContact[0].Id);
            UtilityTestData.mSBQuoteData.put('EndUserContact__c',lContact[0].Id);
            UtilityTestData.mSBQuoteData.put('SoldToContact__c',lContact[0].Id);
            UtilityTestData.mSBQuoteData.put('Additional_Ship_to_Contact__c',lContact[0].Id); //<T04>
            UtilityTestData.mSBQuoteData.put('Additional_Shipping_Email__c','test@gmail.com'); //<T04>
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
            List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new Payment_Term__c();
            UtilityTestData.mpaymentTerm.put('Quote__c',lSBQuote[0].Id);
            UtilityTestData.mpaymentTerm.put('Start_Date__c',String.valueOf(Date.today().addDays(30)));
            UtilityTestData.mpaymentTerm.put('End_Date__c',String.valueOf(Date.today().addDays(45)));
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mpaymentTerm);
            List<Payment_Term__c> lpaymentTerm = (List<Payment_Term__c>) UtilityTest.makeInsert(new List<sObject>{sObj});             
            
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
            
            sObj2 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[2].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__PricebookEntryId__c',lPriceBookEntry[2].Id);
            UtilityTestData.mQuoteLineData.put('Purchase_Order_PO_Number__c','11234561');
            UtilityTestData.mQuoteLineData.put('SBQQ__ListPrice__c','200');
            UtilityTestData.mQuoteLineData.put('SBQQ__NetPrice__c','200');
            UtilityTestData.mQuoteLineData.put('SBQQ__Number__c','1');
            UtilityTestData.mQuoteLineData.put('SBQQ__ChargeType__c','Recurring');
            UtilityTestData.mQuoteLineData.put('SBQQ__BillingType__c','Advance');
            UtilityTestData.mQuoteLineData.put('Transaction_Type__c','New');
            UtilityTestData.mQuoteLineData.put('SBQQ__EffectiveStartDate__c',System.today().AddDays(1) + '');
            UtilityTestData.mQuoteLineData.put('SBQQ__BillingFrequency__c','Invoice Plan');
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);  
            
            Test.startTest();
            sObj1 = new Opportunity(Id = lOpportunity[0].id ,StageName = 'Closed Won', Analysis_Takeaways__c = 'Test', Ease_of_Renewal__c = '3- Not Easy', Next_Renewal_Considerations__c = 'Test', Next_Renewal_Likelyhood__c = 'May Renew 50/50', Stakeholders_Communication__c = 'Test', Stage_Reason__c='Won : Test class', Red_Flags__c = 'Pricing',Delivery__c='IPS Implementation', Solutions__c = 'IPU Expansion', Next_Steps__c = 'Test', Current_Status__c  = 'Draft Opportunity Closing Plan');//<T03>
            //sObj1 = new Opportunity(Id = lOpportunity[0].id ,StageName = 'Closed Won', Analysis_Takeaways__c = 'Test', Ease_of_Renewal__c = '3- Not Easy', Next_Renewal_Considerations__c = 'Test', Next_Renewal_Likelyhood__c = 'May Renew 50/50', Stakeholders_Communication__c = 'Test', Stage_Reason__c='Won : Test class', Red_Flags__c = 'Pricing',Delivery__c='IPS Implementation', Solutions__c = 'Big Data', Next_Steps__c = 'Test', Current_Status__c  = 'Draft Opportunity Closing Plan',Metrics__c  ='test',Economic_Buyer__c  = lContact[0].Id,Decision_Criteria__c  ='test',Decision_Process__c  ='test',Champion__c  = lContact[0].Id);//<T03>
            List<Opportunity> lOpportunityUpdated = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            system.assertEquals(lOpportunityUpdated.size(),1);
            
            List<SBQQ__QuoteLine__c> lSBQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj2});
            
            sObj1 = new SBQQ__Quote__c(Id = lSBQuote[0].Id ,SBQQ__Status__c = 'Approved', SBQQ__Primary__c = True,SBQQ__Ordered__c = True, ApprovalStatus__c='Approved', ShiptToAccount__c=lAccount[0].Id, BillToAccount__c=lAccount[0].Id, EndUserAccount__c=lAccount[0].Id, SoldToAccount__c=lAccount[0].Id, EndUserContact__c=lContact[0].Id, BillToContact__c=lContact[0].Id, ShipToContact__c=lContact[0].Id, SoldToContact__c=lContact[0].Id); //<T1> Last two arguments);
            //sObj2 = new SBQQ__Quote__c(Id = lQuote[0].Id ,SBQQ__Status__c = 'Approved',  SBQQ__Primary__c = True,SBQQ__Ordered__c = True,ApprovalStatus__c='Approved', ShiptToAccount__c=lAccount[0].Id, BillToAccount__c=lAccount[0].Id, EndUserAccount__c=lAccount[0].Id, SoldToAccount__c=lAccount[0].Id, EndUserContact__c=lContact[0].Id, BillToContact__c=lContact[0].Id, ShipToContact__c=lContact[0].Id, SoldToContact__c=lContact[0].Id); //<T1> Last two arguments);
            
            List<SBQQ__Quote__c> lQuoteUpdated = (List<SBQQ__Quote__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            
            Test.stopTest();
        }
    }   
    
    @isTest
    static void updateQuoteOrderOpportunityActivated() {
        
        Test.startTest();
        //User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1];
        
        system.runAs(adminUser){
            
            List<Order> lOrder = [Select Id, CMS_Approved__c, SBQQ__PriceCalcStatus__c, SBQQ__Contracted__c, Status from Order where Order.Opportunity.Name = 'OrderTriggerHandler' Limit 2];
            system.assertEquals(lOrder.size(),1);
            List<Account> lAccount = [Select Id from Account limit 1];
            system.assertEquals(lAccount.size(),1);
            List<Contact> lContact = [Select Id from Contact limit 1];
            system.assertEquals(lContact.size(),1);
            
            Map<Id, Order> oldMap = new Map<Id, Order>();
            oldMap.put(lOrder[0].Id, lOrder[0]);
            List<Order> newList = new List<Order>();
            Set<Id> orderSet = new Set<Id>();
            
            sObject sObjOrder = new Order(id = lOrder[0].Id);
            UtilityTestData.mOrderData.put('CMS_Approved__c','True'); 
            UtilityTestData.mOrderData.put('Provisioning_Complete_Date__c',System.today()+''); 
            UtilityTestData.mOrderData.put('SBQQ__PriceCalcStatus__c','Completed');
            UtilityTestData.mOrderData.put('Shipping_Email__c','test@email.com');
            UtilityTestData.mOrderData.put('SoldToAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('SoldToContact__c',lContact[0].Id);
            UtilityTestData.mOrderData.put('EndUserAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('EndUserContact__c',lContact[0].Id);
            UtilityTestData.mOrderData.put('ShipToAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('BilltoAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('Billing_Alignment_Date__c',System.today()+'');
            //UtilityTestData.mOrderData.put('Status','Activated'); //<T04>
            UtilityTestData.mOrderData.put('EffectiveDate',System.today()+'');
            sObjOrder = UtilityTest.putFieldRecord(sObjOrder, UtilityTestData.mOrderData);
            
            List<Order> lOrderUpdated1 = (List<Order>) UtilityTest.makeUpdate(new List<sObject>{sObjOrder});
            Test.stopTest();
            
            system.assertEquals(lOrderUpdated1.size(),1);   
            
            // newList.add((Order)sObjOrder);
            orderSet.add(lOrderUpdated1[0].Id);
            //OrderTriggerHandler.handleBeforeUpdate(newList);
            // OrderTriggerHandler.handleAfterUpdate(newList, oldMap);
            //ActivateOrderFuture.reviewCompletedOrder(orderSet);
            
            //Nothing to Assert
            
            
        }
    }
    /**<T02>**/
    @isTest
    static void updateOrderGenerateDate() {
        
        User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1];
        
        system.runAs(adminUser){
            
            Test.startTest();
            List<Order> lOrder = [Select Id, CMS_Approved__c, SBQQ__PriceCalcStatus__c, SBQQ__Contracted__c, Status from Order where Order.Opportunity.Name = 'OrderTriggerHandler' Limit 2];
            system.assertEquals(lOrder.size(),1);
            
            List<Account> lAccount = [Select Id from Account limit 1];
            system.assertEquals(lAccount.size(),1);
            
            List<Contact> lContact = [Select Id from Contact limit 1];
            system.assertEquals(lContact.size(),1);
            
            System.debug('lOrder[0].Status' + lOrder[0].Status);
            lOrder[0].SoldToAccount__c = lAccount[0].Id;
            lOrder[0].SoldToContact__c = lContact[0].Id;
            lOrder[0].EndUserAccount__c = lAccount[0].Id;
            lOrder[0].EndUserContact__c = lContact[0].Id;
            lOrder[0].ShipToAccount__c = lAccount[0].Id;
            lOrder[0].BilltoAccount__c =lAccount[0].Id;
            lOrder[0].BilltoAccount__c =lAccount[0].Id;
            lOrder[0].Generate_Date__c = System.today()-3;
            
            update lOrder;
            
            System.debug('lOrder[0].Status' + lOrder[0].Status);
            
            Test.stopTest();
        }
    }
    /**<T02>**/
    @isTest
    static void updateQuoteOrderOpportunityBillContract() {
        Test.startTest();
        User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1];
        
        system.runAs(adminUser){
            
            List<Order> lOrder = [Select Id, CMS_Approved__c, SBQQ__PriceCalcStatus__c, SBQQ__Contracted__c, Status from Order where Order.Opportunity.Name = 'OrderTriggerHandler' Limit 2];
                         
            List<Account> lAccount = [Select Id from Account limit 1];
            system.assertEquals(lAccount.size(),1);
            List<Contact> lContact = [Select Id from Contact limit 1];
            system.assertEquals(lContact.size(),1);
            
            //<T04>
            sObject sObj = new Contact();
            UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mContactData.put('FirstName','Shipping Contact');
            UtilityTestData.mContactData.put('LastName','test Con LastName12');
            UtilityTestData.mContactData.put('Email','test1@test.com');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            List<Contact> lShippingContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
            //<T04> ends
            
            Map<Id, Order> oldMap = new Map<Id, Order>();
            oldMap.put(lOrder[0].Id, lOrder[0]);
            List<Order> newList = new List<Order>();
            Set<Id> orderSet = new Set<Id>();
            
            sObject sObjOrder = new Order(id = lOrder[0].Id);
            UtilityTestData.mOrderData.put('Revenue_Agreement_Processed__c','True');
            UtilityTestData.mOrderData.put('Additional_Ship_to_Contact__c',lShippingContact[0].Id); //<T04>
            sObjOrder = UtilityTest.putFieldRecord(sObjOrder, UtilityTestData.mOrderData);
            
            
            List<Order> lOrderUpdated1 = (List<Order>) UtilityTest.makeUpdate(new List<sObject>{sObjOrder});
            system.assertEquals(lOrderUpdated1.size(),1);   
            
            // newList.add((Order)sObjOrder);
            //orderSet.add(lOrderUpdated1[0].Id);
            // OrderTriggerHandler.handleBeforeUpdate(newList);
            // OrderTriggerHandler.handleAfterUpdate(newList, oldMap);
            //ActivateOrderFuture.activateOrder(orderSet);
            
            //Nothing to Assert
            
            Test.stopTest();
            
        }
    }
    @isTest
    static void createInvoiceGroupTest() {
        Test.startTest();
        User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1];
        
        system.runAs(adminUser){
            
            Map<Id,Order> mapOrder = new Map<Id,Order>([Select Id, CMS_Approved__c, SBQQ__PriceCalcStatus__c, SBQQ__Contracted__c, Status from Order where Order.Opportunity.Name = 'OrderTriggerHandler' Limit 2]);  
            OrderTriggerHandler.createInvoiceGroup(new List<Id>(mapOrder.keySet()));         
            Test.stopTest();            
        }
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
    @isTest
    static void revisionOrderTest(){
        Test.startTest();
        List<Order> lOrder = [SELECT Id,OpportunityId FROM Order LIMIT 1];
        List<Opportunity> lOpportunity = [SELECT Id FROM Opportunity WHERE Id =:lOrder[0].OpportunityId LIMIT 1];
        
        //Update to Revision Opportunity
        lOpportunity[0].Enable_Downstream__c = 'Fulfillment';
        update lOpportunity;          
        
        //Activate the Order
        lOrder[0].Sub_Type__c = Label.RevisionLabel;
        lOrder[0].Status = 'Activated';
        lOrder[0].SBQQ__PriceCalcStatus__c = 'Not Needed';
        update lOrder;
        
        Test.stopTest();
    }
    @isTest
    static void AccelerateBillFreqToInvoicePlan() {
        
        Test.startTest();
        //User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1];
        
        system.runAs(adminUser){
            
            List<Order> lOrder = [Select Id, CMS_Approved__c, SBQQ__PriceCalcStatus__c, SBQQ__Contracted__c, Status from Order where Order.Opportunity.Name = 'OrderTriggerHandler' Limit 2];
            system.assertEquals(lOrder.size(),1);
            List<Account> lAccount = [Select Id from Account limit 1];
            system.assertEquals(lAccount.size(),1);
            List<Contact> lContact = [Select Id from Contact limit 1];
            system.assertEquals(lContact.size(),1);
            
            Map<Id, Order> oldMap = new Map<Id, Order>();
            oldMap.put(lOrder[0].Id, lOrder[0]);
            List<Order> newList = new List<Order>();
            Set<Id> orderSet = new Set<Id>();
            
            sObject sObjOrder = new Order(id = lOrder[0].Id);
            UtilityTestData.mOrderData.put('CMS_Approved__c','True'); 
            UtilityTestData.mOrderData.put('Provisioning_Complete_Date__c',System.today()+''); 
            UtilityTestData.mOrderData.put('SBQQ__PriceCalcStatus__c','Completed');
            UtilityTestData.mOrderData.put('Shipping_Email__c','test@email.com');
            UtilityTestData.mOrderData.put('SoldToAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('SoldToContact__c',lContact[0].Id);
            UtilityTestData.mOrderData.put('EndUserAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('EndUserContact__c',lContact[0].Id);
            UtilityTestData.mOrderData.put('ShipToAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('BilltoAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('Billing_Alignment_Date__c',System.today()+'');
            UtilityTestData.mOrderData.put('Status','Activated'); 
            UtilityTestData.mOrderData.put('EffectiveDate',System.today()+'');
            sObjOrder = UtilityTest.putFieldRecord(sObjOrder, UtilityTestData.mOrderData);
            
            List<Order> lOrderUpdated1 = (List<Order>) UtilityTest.makeUpdate(new List<sObject>{sObjOrder});
            Test.stopTest();
            
            system.assertEquals(lOrderUpdated1.size(),1);   
            
            // newList.add((Order)sObjOrder);
            orderSet.add(lOrderUpdated1[0].Id);
            //OrderTriggerHandler.handleBeforeUpdate(newList);
            // OrderTriggerHandler.handleAfterUpdate(newList, oldMap);
            //ActivateOrderFuture.reviewCompletedOrder(orderSet);
            
            //Nothing to Assert
            
            
        }
    }
    
    @isTest
    static void AccelerateBillFreqToInvoicePlan2() {
        
        Test.startTest();
        //User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1];
        
        system.runAs(adminUser){
            
            List<Order> lOrder = [Select Id, CMS_Approved__c, SBQQ__PriceCalcStatus__c, SBQQ__Contracted__c, Status from Order where Order.Opportunity.Name = 'OrderTriggerHandler' Limit 2];
             List<OrderItem> lOrderLI = [Select Id, ServiceDate from OrderItem where OrderID =: lOrder[0].ID Limit 1];
            lOrderLI[0].ServiceDate = System.today().AddDays(10) ; 
            update lOrderLI[0];
            system.assertEquals(lOrder.size(),1);
            List<Account> lAccount = [Select Id from Account limit 1];
            system.assertEquals(lAccount.size(),1);
            List<Contact> lContact = [Select Id from Contact limit 1];
            system.assertEquals(lContact.size(),1);
            
            Map<Id, Order> oldMap = new Map<Id, Order>();
            oldMap.put(lOrder[0].Id, lOrder[0]);
            List<Order> newList = new List<Order>();
            Set<Id> orderSet = new Set<Id>();
            
            sObject sObjOrder = new Order(id = lOrder[0].Id);
            UtilityTestData.mOrderData.put('CMS_Approved__c','True'); 
            UtilityTestData.mOrderData.put('Provisioning_Complete_Date__c',System.today()+''); 
            UtilityTestData.mOrderData.put('SBQQ__PriceCalcStatus__c','Completed');
            UtilityTestData.mOrderData.put('Shipping_Email__c','test@email.com');
            UtilityTestData.mOrderData.put('SoldToAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('SoldToContact__c',lContact[0].Id);
            UtilityTestData.mOrderData.put('EndUserAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('EndUserContact__c',lContact[0].Id);
            UtilityTestData.mOrderData.put('ShipToAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('BilltoAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('Billing_Alignment_Date__c',System.today()+'');
            UtilityTestData.mOrderData.put('Status','Activated'); 
            UtilityTestData.mOrderData.put('EffectiveDate',System.today()+'');
            sObjOrder = UtilityTest.putFieldRecord(sObjOrder, UtilityTestData.mOrderData);
            
            List<Order> lOrderUpdated1 = (List<Order>) UtilityTest.makeUpdate(new List<sObject>{sObjOrder});
            Test.stopTest();
            
            system.assertEquals(lOrderUpdated1.size(),1);                       
            orderSet.add(lOrderUpdated1[0].Id);                                    
        }
    }
    
     @isTest
    static void FullDebookQuote() {
        
        Test.startTest();
       
        User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1];
        
        system.runAs(adminUser){
            
            List<SBQQ__Quote__c> QuoteList = [Select Id from SBQQ__Quote__c Limit 1];
            Set<Id> QuoteIds = new Set<Id>();
            QuoteIds.add(QuoteList[0].id);
            Boolean flag = QuoteLineTriggerHandler.recalcQuoteFullDebook(QuoteList,QuoteIds);
            Test.stopTest();                                                          
        }
    }
    @isTest
    static void shipToContactEmailOnOrderTest(){
        Test.startTest();
        List<Order> lOrder = [SELECT Id,OpportunityId,ShipToContactId FROM Order LIMIT 1];
        List<contact> lcontact = [SELECT Id,Email FROM Contact WHERE Email = 'test123@test.com' LIMIT 1];
        
        lOrder[0].ShipToContactId = lcontact[0].Id;
        update lOrder;
        	
        Test.stopTest();
    }
    //<T04>
    @isTest
    Static void amendOrderInsert(){
        
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
    //<T04> ends
}