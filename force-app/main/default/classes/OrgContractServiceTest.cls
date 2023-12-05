/*
 * Name         :   OrgContractServiceTest
 * Author       :   Vignesh Divakaran
 * Created Date :   7/10/2023
 * Description  :   Test class for OrgContractService.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                             Tag
 **********************************************************************************************************
 Vignesh Divakaran      7/10/2023       F2A-594         Initial version.                        N/A
 */

@isTest
public class OrgContractServiceTest {

    private final static String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
    
    /*
    Method Name : setup
    Description : Test setup method.
    Parameters  : None
    Return Type : None
    */
    @testSetup 
    public static void setup() {
        User objUser = [SELECT Id FROM User WHERE Name = 'Deployment master' AND IsActive = true LIMIT 1];

        System.runAs(objUser){

            User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
            settings.Ignore_Validation_Rules__c = true;
            upsert settings User_Exemptions__c.Id;
           
            sObject sObj, sObj1, sObj2;

            //Billing rule
            sObj = new blng__BillingRule__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngBillingRuleData);
            List<blng__BillingRule__c> lBillingRule = (List<blng__BillingRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //Revenue recognition rule
            sObj = new blng__RevenueRecognitionRule__c();
            sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mblngRevRecRuleData);
            List<blng__RevenueRecognitionRule__c> lRevRecRule = (List<blng__RevenueRecognitionRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});    
            System.assertEquals(lRevRecRule.size(),1);
            
            //Tax rule
            sObj = new blng__TaxRule__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngTaxRuleData);
            List<blng__TaxRule__c> lTaxRule = (List<blng__TaxRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            System.assertEquals(lTaxRule.size(),1);
            
            //Legal entity
            sObj = new blng__LegalEntity__c();
            UtilityTestData.mLegalEntityData.put('Name','test');
            UtilityTestData.mLegalEntityData.put('Business_Unit_Code__c','US001');
            UtilityTestData.mLegalEntityData.put('Multi_Country_Mapping1__c','India');
            UtilityTestData.mLegalEntityData.put('Multi_Country_Mapping2__c','India');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalEntityData);
            List<blng__LegalEntity__c> lLegalEntity = (List<blng__LegalEntity__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

            //Product
            sObj = new Product2();
            UtilityTestData.mProduct2Data.put('Name', 'Test Flex IPU');
            UtilityTestData.mProduct2Data.put('blng__BillingRule__c', lBillingRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c', lRevRecRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__TaxRule__c', lTaxRule[0].Id);
            UtilityTestData.mProduct2Data.put('Family', 'Cloud Subscription');
            UtilityTestData.mProduct2Data.put('Forecast_Product__c', 'IPU');
            UtilityTestData.mProduct2Data.put('Product_Family__c', 'IPU');
            UtilityTestData.mProduct2Data.put('Pricing_Business_Model__c', 'Subscription');
            UtilityTestData.mProduct2Data.put('Processing_Engine__c', 'Traditional DB');
            UtilityTestData.mProduct2Data.put('Delivery_Method__c', 'Hosted Multi Tenant');
            UtilityTestData.mProduct2Data.put('Orderable__c', 'true');
            UtilityTestData.mProduct2Data.put('Is_Parent__c', 'true');
            UtilityTestData.mProduct2Data.put('Amoritization_Schedule__c', 'Cloud');
            UtilityTestData.mProduct2Data.put('Business_Unit__c', 'IPU');
            UtilityTestData.mProduct2Data.put('Edition__c', 'Test Flex IPU');
            UtilityTestData.mProduct2Data.put('License_Metric__c', 'Per IPU');
            UtilityTestData.mProduct2Data.put('Product_Category__c', 'Wrapper');
            UtilityTestData.mProduct2Data.put('Option_Scale__c', 'Base Product');
            UtilityTestData.mProduct2Data.put('Offering_Type__c', 'Cloud Hosted Subscription');
            UtilityTestData.mProduct2Data.put('Pricebook_Category__c', 'NA');
            UtilityTestData.mProduct2Data.put('Life_Cycle__c', 'Active');
            UtilityTestData.mProduct2Data.put('SBQQ__ConfigurationType__c', 'Required');
            UtilityTestData.mProduct2Data.put('SBQQ__ConfigurationEvent__c', 'Always');
            UtilityTestData.mProduct2Data.put('SBQQ__OptionLayout__c', 'Tabs');
            UtilityTestData.mProduct2Data.put('SBQQ__OptionSelectionMethod__c', 'Click');
            UtilityTestData.mProduct2Data.put('SBQQ__PricingMethod__c', 'List');
            UtilityTestData.mProduct2Data.put('SBQQ__ChargeType__c', 'Recurring');
            UtilityTestData.mProduct2Data.put('SBQQ__NonDiscountable__c', 'true');
            UtilityTestData.mProduct2Data.put('SBQQ__IncludeInMaintenance__c', 'true');
            UtilityTestData.mProduct2Data.put('GTM_Model__c', System.Label.IPU_Product_GTM_Value);
            UtilityTestData.mProduct2Data.put('SBQQ__SubscriptionPricing__c', 'Fixed Price');
            UtilityTestData.mProduct2Data.put('SBQQ__SubscriptionTerm__c', '12');
            UtilityTestData.mProduct2Data.put('SBQQ__SubscriptionBase__c', 'List');
            UtilityTestData.mProduct2Data.put('SBQQ__SubscriptionType__c', 'Renewable');
            UtilityTestData.mProduct2Data.put('Provisionable_New__c', 'true');
            UtilityTestData.mProduct2Data.put('License_Generation__c', 'Production');
            UtilityTestData.mProduct2Data.put('License_Screen_Type__c', 'Cloud');
            UtilityTestData.mProduct2Data.put('SBQQ__BillingFrequency__c', 'Annual');
            UtilityTestData.mProduct2Data.put('SBQQ__BillingType__c', 'Advance');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);

            sObj1 = new Product2();
            UtilityTestData.mProduct2Data.put('Name', 'Test Flex IPU - Annual Subscription');
            UtilityTestData.mProduct2Data.put('blng__BillingRule__c', lBillingRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c', lRevRecRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__TaxRule__c', lTaxRule[0].Id);
            UtilityTestData.mProduct2Data.put('Family', 'Cloud Subscription');
            UtilityTestData.mProduct2Data.put('Forecast_Product__c', 'IPU');
            UtilityTestData.mProduct2Data.put('Product_Family__c', 'IPU');
            UtilityTestData.mProduct2Data.put('Pricing_Business_Model__c', 'Subscription');
            UtilityTestData.mProduct2Data.put('Processing_Engine__c', 'Traditional DB');
            UtilityTestData.mProduct2Data.put('Delivery_Method__c', 'Hosted Multi Tenant');
            UtilityTestData.mProduct2Data.put('Orderable__c', 'true');
            UtilityTestData.mProduct2Data.put('Is_Parent__c', 'false');
            UtilityTestData.mProduct2Data.put('Amoritization_Schedule__c', 'Cloud');
            UtilityTestData.mProduct2Data.put('Business_Unit__c', 'IPU');
            UtilityTestData.mProduct2Data.put('Edition__c', 'Test Flex IPU');
            UtilityTestData.mProduct2Data.put('License_Metric__c', 'Per IPU');
            UtilityTestData.mProduct2Data.put('Product_Category__c', 'Add-ons');
            UtilityTestData.mProduct2Data.put('Option_Scale__c', 'Base Product');
            UtilityTestData.mProduct2Data.put('Offering_Type__c', 'Cloud Hosted Subscription');
            UtilityTestData.mProduct2Data.put('Pricebook_Category__c', 'NA');
            UtilityTestData.mProduct2Data.put('Life_Cycle__c', 'Active');
            UtilityTestData.mProduct2Data.put('SBQQ__ConfigurationType__c', 'Allowed');
            UtilityTestData.mProduct2Data.put('SBQQ__OptionSelectionMethod__c', 'Click');
            UtilityTestData.mProduct2Data.put('SBQQ__PricingMethod__c', 'List');
            UtilityTestData.mProduct2Data.put('SBQQ__ChargeType__c', 'Recurring');
            UtilityTestData.mProduct2Data.put('SBQQ__NonDiscountable__c', 'false');
            UtilityTestData.mProduct2Data.put('SBQQ__IncludeInMaintenance__c', 'true');
            UtilityTestData.mProduct2Data.put('GTM_Model__c', System.Label.IPU_Product_GTM_Value);
            UtilityTestData.mProduct2Data.put('SBQQ__SubscriptionPricing__c', 'Fixed Price');
            UtilityTestData.mProduct2Data.put('SBQQ__SubscriptionTerm__c', '12');
            UtilityTestData.mProduct2Data.put('SBQQ__SubscriptionBase__c', 'List');
            UtilityTestData.mProduct2Data.put('SBQQ__SubscriptionType__c', 'Renewable');
            UtilityTestData.mProduct2Data.put('Provisionable_New__c', 'true');
            UtilityTestData.mProduct2Data.put('License_Generation__c', 'Options');
            UtilityTestData.mProduct2Data.put('License_Screen_Type__c', 'Cloud');
            UtilityTestData.mProduct2Data.put('SBQQ__BillingFrequency__c', 'Annual');
            UtilityTestData.mProduct2Data.put('SBQQ__BillingType__c', 'Advance');
            UtilityTestData.mProduct2Data.put('Package__c', 'true');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProduct2Data);

            sObj2 = new Product2();
            UtilityTestData.mProduct2Data.put('Name', 'Test Flex IPU - Annual Subscription Option');
            UtilityTestData.mProduct2Data.put('blng__BillingRule__c', lBillingRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c', lRevRecRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__TaxRule__c', lTaxRule[0].Id);
            UtilityTestData.mProduct2Data.put('Family', 'Cloud Subscription');
            UtilityTestData.mProduct2Data.put('Forecast_Product__c', 'IPU');
            UtilityTestData.mProduct2Data.put('Product_Family__c', 'IPU');
            UtilityTestData.mProduct2Data.put('Pricing_Business_Model__c', 'Subscription');
            UtilityTestData.mProduct2Data.put('Processing_Engine__c', 'Traditional DB');
            UtilityTestData.mProduct2Data.put('Delivery_Method__c', 'Hosted Multi Tenant');
            UtilityTestData.mProduct2Data.put('Orderable__c', 'true');
            UtilityTestData.mProduct2Data.put('Is_Parent__c', 'false');
            UtilityTestData.mProduct2Data.put('Amoritization_Schedule__c', 'Cloud');
            UtilityTestData.mProduct2Data.put('Business_Unit__c', 'IPU');
            UtilityTestData.mProduct2Data.put('Edition__c', 'Test Flex IPU');
            UtilityTestData.mProduct2Data.put('License_Metric__c', 'Per IPU');
            UtilityTestData.mProduct2Data.put('Product_Category__c', 'Add-ons');
            UtilityTestData.mProduct2Data.put('Option_Scale__c', 'Base Product');
            UtilityTestData.mProduct2Data.put('Offering_Type__c', 'Cloud Hosted Subscription');
            UtilityTestData.mProduct2Data.put('Pricebook_Category__c', 'NA');
            UtilityTestData.mProduct2Data.put('Life_Cycle__c', 'Active');
            UtilityTestData.mProduct2Data.put('SBQQ__ConfigurationType__c', 'Allowed');
            UtilityTestData.mProduct2Data.put('SBQQ__OptionSelectionMethod__c', 'Click');
            UtilityTestData.mProduct2Data.put('SBQQ__PricingMethod__c', 'List');
            UtilityTestData.mProduct2Data.put('SBQQ__ChargeType__c', 'Recurring');
            UtilityTestData.mProduct2Data.put('SBQQ__NonDiscountable__c', 'false');
            UtilityTestData.mProduct2Data.put('SBQQ__IncludeInMaintenance__c', 'true');
            UtilityTestData.mProduct2Data.put('GTM_Model__c', System.Label.IPU_Product_GTM_Value);
            UtilityTestData.mProduct2Data.put('SBQQ__SubscriptionPricing__c', 'Fixed Price');
            UtilityTestData.mProduct2Data.put('SBQQ__SubscriptionTerm__c', '12');
            UtilityTestData.mProduct2Data.put('SBQQ__SubscriptionBase__c', 'List');
            UtilityTestData.mProduct2Data.put('SBQQ__SubscriptionType__c', 'Renewable');
            UtilityTestData.mProduct2Data.put('Provisionable_New__c', 'true');
            UtilityTestData.mProduct2Data.put('License_Generation__c', 'Options');
            UtilityTestData.mProduct2Data.put('License_Screen_Type__c', 'Cloud');
            UtilityTestData.mProduct2Data.put('SBQQ__BillingFrequency__c', 'Annual');
            UtilityTestData.mProduct2Data.put('SBQQ__BillingType__c', 'Advance');
            UtilityTestData.mProduct2Data.put('Package__c', 'true');
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mProduct2Data);
            List<Product2> lProduct = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1, sObj2});

            //Pricebook
            Id priceBookId  = Test.getStandardPricebookId();
            sObj = new Pricebook2(ID = priceBookId, IsActive = True);
            List<Pricebook2> lPriceBook = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});

            //Price book entries
            sObj = new PriceBookEntry();
            UtilityTestData.mPriceBookEntryData.put('Pricebook2Id', lPriceBook[0].Id + '');
            UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct[0].Id + '');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);

            sObj1 = new PriceBookEntry();
            UtilityTestData.mPriceBookEntryData.put('Pricebook2Id', lPriceBook[0].Id + '');
            UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct[1].Id + '');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mPriceBookEntryData);  

            sObj2 = new PriceBookEntry();
            UtilityTestData.mPriceBookEntryData.put('Pricebook2Id', lPriceBook[0].Id + '');
            UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct[2].Id + '');
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mPriceBookEntryData);  
            List<PriceBookEntry> lPricebookEntries = (List<PriceBookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1, sObj2});

            //Account
            sObj = new Account();
            UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
            UtilityTestData.mAccountData.put('BillingCountry','United States');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
            List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

            //Contact
            sObj = new Contact();
            UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mContactData.put('MailingCountry','United States');
            UtilityTestData.mContactData.put('Email','test@testinformaticayy.com');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});

            Date dtToday = System.today();
            Date qlendDate = System.today().addMonths(30).addDays(-1);
            
            //Opportunity
            sObj = new Opportunity();
            UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'New');
            UtilityTestData.mOpportunityData.put('CloseDate',System.today()+'');
            UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Commit');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});

            Test.startTest();

            //Quote
            sObj = new SBQQ__Quote__c();
            UtilityTestData.mSBQuoteData.put('SoldToAccount__c', lAccount[0].Id + '');
            UtilityTestData.mSBQuoteData.put('ShiptToAccount__c', lAccount[0].Id + '');
            UtilityTestData.mSBQuoteData.put('BillToAccount__c', lAccount[0].Id + '');
            UtilityTestData.mSBQuoteData.put('EndUserAccount__c', lAccount[0].Id + '');
            UtilityTestData.mSBQuoteData.put('SoldToContact__c', lContact[0].Id + '');
            UtilityTestData.mSBQuoteData.put('EndUserContact__c', lContact[0].Id + '');
            UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'true');        
            UtilityTestData.mSBQuoteData.put('CurrencyIsoCode', 'USD');
            UtilityTestData.mSBQuoteData.put('SBQQ__Type__c', 'Quote');
            UtilityTestData.mSBQuoteData.put('SBQQ__PaymentTerms__c', 'Net 30');
            UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[0].Id+'');
            UtilityTestData.mSBQuoteData.put('Legal_Entity__c', lLegalEntity[0].Id+'');
            UtilityTestData.mSBQuoteData.put('SBQQ__Account__c', lAccount[0].Id + '');
            UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c', dtToday + '');
            UtilityTestData.mSBQuoteData.put('SBQQ__EndDate__c', qlendDate + '');
            UtilityTestData.mSBQuoteData.put('SBQQ__SubscriptionTerm__c', 30 + '');
            UtilityTestData.mSBQuoteData.put('SBQQ__PriceBook__c', lPriceBook[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__PricebookId__c', lPriceBook[0].Id);
            UtilityTestData.mSBQuoteData.put('Quote_Description__c', 'Test quote for IPU commit recs creation');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
            List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

            //QuoteLine
            sObj = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', lQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', lProduct[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c', 1+'');
            UtilityTestData.mQuoteLineData.put('SBQQ__ChargeType__c', 'Recurring');
            UtilityTestData.mQuoteLineData.put('SBQQ__BillingFrequency__c', 'Annual');
            UtilityTestData.mQuoteLineData.put('SBQQ__BillingType__c', 'Advance');
            UtilityTestData.mQuoteLineData.put('SBQQ__PricebookEntryId__c', lPricebookEntries[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
            List<SBQQ__QuoteLine__c> lQuotelineWrapper = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

            sObj = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', lQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', lProduct[1].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c', 1000+'');
            UtilityTestData.mQuoteLineData.put('SBQQ__ChargeType__c', 'Recurring');
            UtilityTestData.mQuoteLineData.put('SBQQ__BillingFrequency__c', 'Annual');
            UtilityTestData.mQuoteLineData.put('SBQQ__BillingType__c', 'Advance');
            UtilityTestData.mQuoteLineData.put('SBQQ__PricebookEntryId__c', lPricebookEntries[1].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__RequiredBy__c', lQuotelineWrapper[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);

            sObj1 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', lQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', lProduct[2].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c', 500+'');
            UtilityTestData.mQuoteLineData.put('SBQQ__ChargeType__c', 'Recurring');
            UtilityTestData.mQuoteLineData.put('SBQQ__BillingFrequency__c', 'Annual');
            UtilityTestData.mQuoteLineData.put('SBQQ__BillingType__c', 'Advance');
            UtilityTestData.mQuoteLineData.put('SBQQ__PricebookEntryId__c', lPricebookEntries[2].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__RequiredBy__c', lQuotelineWrapper[0].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
            List<SBQQ__QuoteLine__c> lQuotelineAddons = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1});

            SBQQ__Quote__c objQuote = new SBQQ__Quote__c(Id=lQuote[0].Id,SBQQ__Status__c='Approved',ApprovalStatus__c='Approved');
            update objQuote;

            SBQQ.TriggerControl.disable();
            sObj = new Order();
            UtilityTestData.mOrderData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mOrderData.put('EffectiveDate',dtToday+'');
            UtilityTestData.mOrderData.put('EndDate',qlendDate+'');
            UtilityTestData.mOrderData.put('Status','Draft');
            UtilityTestData.mOrderData.put('SBQQ__Quote__c',lQuote[0].Id);
            UtilityTestData.mOrderData.put('OpportunityId',lOpportunity[0].Id);
            UtilityTestData.mOrderData.put('Pricebook2Id',lPriceBook[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mOrderData);
            List<Order> lOrder = (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj});

            sObj = new OrderItem();
            UtilityTestData.mOrderItemData.put('ServiceDate',dtToday+'');
            UtilityTestData.mOrderItemData.put('EndDate',qlendDate+'');
            UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',lQuotelineWrapper[0].Id);
            UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','1');
            UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','1');
            UtilityTestData.mOrderItemData.put('Quantity','1');
            UtilityTestData.mOrderItemData.put('Product2Id',lProduct[0].Id);
            UtilityTestData.mOrderItemData.put('OrderId',lOrder[0].Id);
            UtilityTestData.mOrderItemData.put('PricebookEntryId',lPricebookEntries[0].Id);
            UtilityTestData.mOrderItemData.put('UnitPrice','2000');
            UtilityTestData.mOrderItemData.put('Ship_Date__c',dtToday+'');
            UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131311');
            UtilityTestData.mOrderItemData.put('blng__BillingRule__c', lBillingRule[0].Id);
            UtilityTestData.mOrderItemData.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
            UtilityTestData.mOrderItemData.put('blng__TaxRule__c', lTaxRule[0].Id);
            UtilityTestData.mOrderItemData.put('PricebookEntryId', lPricebookEntries[0].Id);
            UtilityTestData.mOrderItemData.put('SBQQ__Status__c', 'Draft');
            UtilityTestData.mOrderItemData.put('SBQQ__Activated__c', 'false');
            UtilityTestData.mOrderItemData.put('Product_Category__c', 'Wrapper');
            UtilityTestData.mOrderItemData.put('SBQQ__ProrateMultiplier__c', 30/12+'');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderItemData);
            List<OrderItem> lOrderlineWrapper = (List<OrderItem>) UtilityTest.makeInsert(new List<sObject>{sObj});

            sObj = new OrderItem();
            UtilityTestData.mOrderItemData.put('ServiceDate',dtToday+'');
            UtilityTestData.mOrderItemData.put('EndDate',qlendDate+'');
            UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',lQuotelineAddons[0].Id);
            UtilityTestData.mOrderItemData.put('SBQQ__RequiredBy__c',lOrderlineWrapper[0].Id);
            UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','1000');
            UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','1000');
            UtilityTestData.mOrderItemData.put('Quantity','1000');
            UtilityTestData.mOrderItemData.put('Product2Id',lProduct[1].Id);
            UtilityTestData.mOrderItemData.put('OrderId',lOrder[0].Id);
            UtilityTestData.mOrderItemData.put('PricebookEntryId',lPricebookEntries[1].Id);
            UtilityTestData.mOrderItemData.put('UnitPrice','2000');
            UtilityTestData.mOrderItemData.put('Ship_Date__c',dtToday+'');
            UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131311');
            UtilityTestData.mOrderItemData.put('blng__BillingRule__c', lBillingRule[0].Id);
            UtilityTestData.mOrderItemData.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
            UtilityTestData.mOrderItemData.put('blng__TaxRule__c', lTaxRule[0].Id);
            UtilityTestData.mOrderItemData.put('PricebookEntryId', lPricebookEntries[1].Id);
            UtilityTestData.mOrderItemData.put('SBQQ__Status__c', 'Draft');
            UtilityTestData.mOrderItemData.put('SBQQ__Activated__c', 'false');
            UtilityTestData.mOrderItemData.put('Product_Category__c', 'Add-ons');
            UtilityTestData.mOrderItemData.put('SBQQ__ProrateMultiplier__c', 30/12+'');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderItemData);

            sObj1 = new OrderItem();
            UtilityTestData.mOrderItemData.put('ServiceDate',dtToday+'');
            UtilityTestData.mOrderItemData.put('EndDate',qlendDate+'');
            UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',lQuotelineAddons[1].Id);
            UtilityTestData.mOrderItemData.put('SBQQ__RequiredBy__c',lOrderlineWrapper[0].Id);
            UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','500');
            UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','500');
            UtilityTestData.mOrderItemData.put('Quantity','500');
            UtilityTestData.mOrderItemData.put('Product2Id',lProduct[2].Id);
            UtilityTestData.mOrderItemData.put('OrderId',lOrder[0].Id);
            UtilityTestData.mOrderItemData.put('PricebookEntryId',lPricebookEntries[2].Id);
            UtilityTestData.mOrderItemData.put('UnitPrice','2000');
            UtilityTestData.mOrderItemData.put('Ship_Date__c',dtToday+'');
            UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131311');
            UtilityTestData.mOrderItemData.put('blng__BillingRule__c', lBillingRule[0].Id);
            UtilityTestData.mOrderItemData.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
            UtilityTestData.mOrderItemData.put('blng__TaxRule__c', lTaxRule[0].Id);
            UtilityTestData.mOrderItemData.put('PricebookEntryId', lPricebookEntries[2].Id);
            UtilityTestData.mOrderItemData.put('SBQQ__Status__c', 'Draft');
            UtilityTestData.mOrderItemData.put('SBQQ__Activated__c', 'false');
            UtilityTestData.mOrderItemData.put('Product_Category__c', 'Add-ons');
            UtilityTestData.mOrderItemData.put('SBQQ__ProrateMultiplier__c', 30/12+'');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOrderItemData);
            List<OrderItem> lOrderlineAddons = (List<OrderItem>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1});

            //Now, we create usage summaries
            Date dtStartDate = System.today();
            Date dtEndDate = System.today().addYears(1).addDays(-1);
            List<blng__UsageSummary__c> lstUsageSummaries = new List<blng__UsageSummary__c>();

            for(OrderItem objOrderLine : [SELECT Id,EndDate,OrderId,Order.AccountId FROM OrderItem WHERE Product_Category__c = 'Add-ons' LIMIT 1]){
                Decimal decProrateMultipler = 30/12;
                while(decProrateMultipler > 0){
                    blng__UsageSummary__c objUsageSummary = new blng__UsageSummary__c();
                    objUsageSummary.blng__SummaryStartDate__c = dtStartDate;
                    objUsageSummary.blng__SummaryEndDate__c = dtEndDate;
                    objUsageSummary.blng__OrderProduct__c = objOrderLine.Id;
                    objUsageSummary.blng__Order__c = objOrderLine.OrderId;
                    objUsageSummary.blng__Account__c = objOrderLine.Order?.AccountId;
                    lstUsageSummaries.add(objUsageSummary);
                    decProrateMultipler--;
                    dtStartDate = dtStartDate.addYears(1);
                    dtEndDate = decProrateMultipler > 1 ? dtStartDate.addYears(1).addDays(-1) : objOrderLine.EndDate;
                }
            }

            if(!lstUsageSummaries.isEmpty()){
                insert lstUsageSummaries;
            }
            SBQQ.TriggerControl.enable();

            Id orderId = [SELECT Id FROM Order LIMIT 1]?.Id;
            Assert.isFalse(orderId == null, 'Order is not created');

            OrgEntitlementService.createOrgEntitlements(orderId);
            ManageFulfillmentCtrl.createFulfillments(orderId);
            OrgEntitlementService.updateFLOnOrgEntitlementLine(orderId);

            List<Fulfillment_Line__c> lstFulfillmentLines = [SELECT Id FROM Fulfillment_Line__c];
            Assert.isFalse(lstFulfillmentLines.isEmpty(), 'Fulfillment Line is not created');

            List<Org_Entitlement__c> lstOrgEntitlements = [SELECT Id FROM Org_Entitlement__c];
            Assert.isFalse(lstOrgEntitlements.isEmpty(), 'Org Entitlement is not created');

            Test.stopTest();
        }
    }

    /*
     Method Name : orgContractCreationTest
     Description : Testing org contract creation
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void orgContractCreationTest() {

        System.runAs(new User(Id = UserInfo.getUserId())){

            User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
            settings.Ignore_Validation_Rules__c = true;
            upsert settings User_Exemptions__c.Id;

            Global_Config__c globalConfig = Global_Config__c.getOrgDefaults();
            globalConfig.Mute_Triggers__c = true;
            upsert globalConfig;

            SBQQ.TriggerControl.disable();

            sObject sObj,sObj1,sObj2;
            Date dtToday = System.today();
            Date qlendDate = System.today().addMonths(30).addDays(-1);

            Id accountId = [SELECT Id FROM Account LIMIT 1]?.Id;
            Id quoteId = [SELECT Id FROM SBQQ__Quote__c LIMIT 1]?.Id;
            Id orderId = [SELECT Id FROM Order LIMIT 1]?.Id;
            List<Product2> lstProducts = [SELECT Id FROM Product2 ORDER BY CreatedDate ASC];
            List<SBQQ__QuoteLine__c> lstQuoteLines = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId ORDER BY CreatedDate ASC];
            List<OrderItem> lstOrderProducts = [SELECT Id FROM OrderItem WHERE OrderId =: orderId ORDER BY CreatedDate ASC];
            List<Asset> lstAssets = new List<Asset>();

            //Server Information
            Server_Information__c objServerInformation = new Server_Information__c();
            objServerInformation.Name = 'Test Server Information';
            objServerInformation.Pod_Name__c = 'Test POD Name';
            objServerInformation.Pod_Region__c = 'AWS-UK';
            objServerInformation.Hosted_Multi_Tenant__c = true;
            insert objServerInformation;

            //Org
            Org__c objOrg = new Org__c();
            objOrg.Name = 'Test Org';
            objOrg.OrgID__c = 'TESTXXYYZZAABBCCDD';
            insert objOrg;

            List<Fulfillment_Line__c> lstFulfillmentLines = [SELECT Id FROM Fulfillment_Line__c ORDER BY CreatedDate ASC];
            Assert.isFalse(lstFulfillmentLines.isEmpty(), 'Fulfillment line is not created');

            for(Fulfillment_Line__c objFulfillmentLine : lstFulfillmentLines){
                objFulfillmentLine.Pod_Location__c = objServerInformation.Id;
                objFulfillmentLine.Org__c = objOrg.Id;
                objFulfillmentLine.Ship_Date__c = System.today();
                objFulfillmentLine.Ship_Status__c = 'Provisioning Complete';
            }

            update lstFulfillmentLines;

            Test.startTest();

            //Contract
            sObj = new Contract();
            UtilityTestData.mContractData.put('AccountId',accountId);
            UtilityTestData.mContractData.put('StartDate', dtToday+'');
            UtilityTestData.mContractData.put('EndDate',qlendDate+'');
            UtilityTestData.mContractData.put('ContractTerm','30');
            UtilityTestData.mContractData.put('BillingStreet','Test Street');
            UtilityTestData.mContractData.put('BillingCity','Test City');
            UtilityTestData.mContractData.put('BillingState','Test State');
            UtilityTestData.mContractData.put('BillingPostalCode','98714-4927');
            UtilityTestData.mContractData.put('BillingCountry','Test Country');
            UtilityTestData.mContractData.put('ShippingStreet','Test Street');
            UtilityTestData.mContractData.put('ShippingCity','Test City');
            UtilityTestData.mContractData.put('ShippingState','Test State');
            UtilityTestData.mContractData.put('ShippingPostalCode','98714-4927');
            UtilityTestData.mContractData.put('ShippingCountry','Test Country');
            UtilityTestData.mContractData.put('SBQQ__Order__c',orderId);
            UtilityTestData.mContractData.put('Status','Draft');
            sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mContractData);
            List<Contract> lContracts = (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //Wrapper Subscription
            sObj = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',accountId);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContracts[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lstProducts[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','1');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',lstOrderProducts[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lstQuoteLines[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','1');
            sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mSBQQSubscriptionData);

            //Addon Subscriptions
            sObj1 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',accountId);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContracts[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lstProducts[1].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','1000');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',lstOrderProducts[1].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lstQuoteLines[1].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','1000');
            sObj1 = UtilityTest.putFieldRecord(sObj1,UtilityTestData.mSBQQSubscriptionData);

            sObj2 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',accountId);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContracts[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lstProducts[2].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','500');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',lstOrderProducts[2].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lstQuoteLines[2].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','500');
            sObj2 = UtilityTest.putFieldRecord(sObj2,UtilityTestData.mSBQQSubscriptionData);
            List<SBQQ__Subscription__c> lSubscriptions = (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});

            //Activate the contract
            Contract objContract = new Contract(Id = lContracts[0].Id);
            objContract.Status = 'Activated';
            update objContract;
            
            //Asset
            Asset objAsset = new Asset();
            objAsset.Name = 'Test Asset';
            objAsset.Product2Id = lstProducts[0].Id;
            objAsset.SBQQ__CurrentSubscription__c = lSubscriptions[0].Id;
            objAsset.SBQQ__QuoteLine__c = lstQuoteLines[0].Id;
            objAsset.SBQQ__OrderProduct__c = lstOrderProducts[0].Id;
            objAsset.accountId = accountId;
            objAsset.AssetServicedById = accountId;
            objAsset.Status = 'Provisioning Complete';
            lstAssets.add(objAsset);

            Asset objAsset1 = new Asset();
            objAsset1.Name = 'Test Asset 1';
            objAsset1.Product2Id = lstProducts[1].Id;
            objAsset1.SBQQ__CurrentSubscription__c = lSubscriptions[1].Id;
            objAsset1.SBQQ__QuoteLine__c = lstQuoteLines[1].Id;
            objAsset1.SBQQ__OrderProduct__c = lstOrderProducts[1].Id;
            objAsset1.accountId = accountId;
            objAsset1.AssetServicedById = accountId;
            objAsset1.Status = 'Provisioning Complete';
            lstAssets.add(objAsset1);

            Asset objAsset2 = new Asset();
            objAsset2.Name = 'Test Asset 2';
            objAsset2.Product2Id = lstProducts[2].Id;
            objAsset2.SBQQ__CurrentSubscription__c = lSubscriptions[2].Id;
            objAsset2.SBQQ__QuoteLine__c = lstQuoteLines[2].Id;
            objAsset2.SBQQ__OrderProduct__c = lstOrderProducts[2].Id;
            objAsset2.accountId = accountId;
            objAsset2.AssetServicedById = accountId;
            objAsset2.Status = 'Provisioning Complete';
            lstAssets.add(objAsset2);

            insert lstAssets;

            AssociateOrgToAsset b = new AssociateOrgToAsset();
            database.executebatch(b, 200);
                
            Test.stopTest();

            List<Org_Contract__c> lstOrgContracts = [SELECT Id FROM Org_Contract__c];
            Assert.isFalse(lstOrgContracts.isEmpty(), 'Org Contract is not created');

            SBQQ.TriggerControl.enable();
        }
    }

    /*
     Method Name : createOrgContractsInvocableTest
     Description : Testing org contract creation by invocable apex
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void createOrgContractsInvocableTest() {

        System.runAs(new User(Id = UserInfo.getUserId())){
            User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
            settings.Ignore_Validation_Rules__c = true;
            upsert settings User_Exemptions__c.Id;

            Global_Config__c globalConfig = Global_Config__c.getOrgDefaults();
            globalConfig.Mute_Triggers__c = true;
            upsert globalConfig;

            SBQQ.TriggerControl.disable();

            sObject sObj,sObj1,sObj2;
            Date dtToday = System.today();
            Date qlendDate = System.today().addMonths(30).addDays(-1);

            Id accountId = [SELECT Id FROM Account LIMIT 1]?.Id;
            Id quoteId = [SELECT Id FROM SBQQ__Quote__c LIMIT 1]?.Id;
            Id orderId = [SELECT Id FROM Order LIMIT 1]?.Id;
            List<Product2> lstProducts = [SELECT Id FROM Product2 ORDER BY CreatedDate ASC];
            List<SBQQ__QuoteLine__c> lstQuoteLines = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId ORDER BY CreatedDate ASC];
            List<OrderItem> lstOrderProducts = [SELECT Id FROM OrderItem WHERE OrderId =: orderId ORDER BY CreatedDate ASC];
            List<Asset> lstAssets = new List<Asset>();

            //Server Information
            Server_Information__c objServerInformation = new Server_Information__c();
            objServerInformation.Name = 'Test Server Information';
            objServerInformation.Pod_Name__c = 'Test POD Name';
            objServerInformation.Pod_Region__c = 'AWS-UK';
            objServerInformation.Hosted_Multi_Tenant__c = true;
            insert objServerInformation;

            //Org
            Org__c objOrg = new Org__c();
            objOrg.Name = 'Test Org';
            objOrg.OrgID__c = 'TESTXXYYZZAABBCCDD';
            insert objOrg;

            List<Fulfillment_Line__c> lstFulfillmentLines = [SELECT Id FROM Fulfillment_Line__c ORDER BY CreatedDate ASC];
            Assert.isFalse(lstFulfillmentLines.isEmpty(), 'Fulfillment line is not created');

            for(Fulfillment_Line__c objFulfillmentLine : lstFulfillmentLines){
                objFulfillmentLine.Pod_Location__c = objServerInformation.Id;
                objFulfillmentLine.Org__c = objOrg.Id;
                objFulfillmentLine.Ship_Date__c = System.today();
                objFulfillmentLine.Ship_Status__c = 'Provisioning Complete';
            }

            update lstFulfillmentLines;

            Test.startTest();

            //Contract
            sObj = new Contract();
            UtilityTestData.mContractData.put('AccountId',accountId);
            UtilityTestData.mContractData.put('StartDate', dtToday+'');
            UtilityTestData.mContractData.put('EndDate',qlendDate+'');
            UtilityTestData.mContractData.put('ContractTerm','30');
            UtilityTestData.mContractData.put('BillingStreet','Test Street');
            UtilityTestData.mContractData.put('BillingCity','Test City');
            UtilityTestData.mContractData.put('BillingState','Test State');
            UtilityTestData.mContractData.put('BillingPostalCode','98714-4927');
            UtilityTestData.mContractData.put('BillingCountry','Test Country');
            UtilityTestData.mContractData.put('ShippingStreet','Test Street');
            UtilityTestData.mContractData.put('ShippingCity','Test City');
            UtilityTestData.mContractData.put('ShippingState','Test State');
            UtilityTestData.mContractData.put('ShippingPostalCode','98714-4927');
            UtilityTestData.mContractData.put('ShippingCountry','Test Country');
            UtilityTestData.mContractData.put('Status','Draft');
            UtilityTestData.mContractData.put('SBQQ__Order__c',orderId);
            sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mContractData);
            List<Contract> lContracts = (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //Wrapper Subscription
            sObj = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',accountId);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContracts[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lstProducts[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','1');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',lstOrderProducts[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lstQuoteLines[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','1');
            sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mSBQQSubscriptionData);

            //Addon Subscriptions
            sObj1 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',accountId);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContracts[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lstProducts[1].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','1000');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',lstOrderProducts[1].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lstQuoteLines[1].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','1000');
            sObj1 = UtilityTest.putFieldRecord(sObj1,UtilityTestData.mSBQQSubscriptionData);

            sObj2 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',accountId);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContracts[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lstProducts[2].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','500');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',lstOrderProducts[2].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lstQuoteLines[2].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','500');
            sObj2 = UtilityTest.putFieldRecord(sObj2,UtilityTestData.mSBQQSubscriptionData);
            List<SBQQ__Subscription__c> lSubscriptions = (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2});

            //Activate the contract
            Contract objContract = new Contract(Id = lContracts[0].Id);
            objContract.Status = 'Activated';
            update objContract;

            //Asset
            Asset objAsset = new Asset();
            objAsset.Name = 'Test Asset';
            objAsset.Product2Id = lstProducts[0].Id;
            objAsset.SBQQ__CurrentSubscription__c = lSubscriptions[0].Id;
            objAsset.SBQQ__QuoteLine__c = lstQuoteLines[0].Id;
            objAsset.SBQQ__OrderProduct__c = lstOrderProducts[0].Id;
            objAsset.accountId = accountId;
            objAsset.AssetServicedById = accountId;
            objAsset.Org__c = objOrg.Id;
            objAsset.Status = 'Provisioning Complete';
            lstAssets.add(objAsset);

            Asset objAsset1 = new Asset();
            objAsset1.Name = 'Test Asset 1';
            objAsset1.Product2Id = lstProducts[1].Id;
            objAsset1.SBQQ__CurrentSubscription__c = lSubscriptions[1].Id;
            objAsset1.SBQQ__QuoteLine__c = lstQuoteLines[1].Id;
            objAsset1.SBQQ__OrderProduct__c = lstOrderProducts[1].Id;
            objAsset1.accountId = accountId;
            objAsset1.AssetServicedById = accountId;
            objAsset1.Org__c = objOrg.Id;
            objAsset1.Status = 'Provisioning Complete';
            lstAssets.add(objAsset1);

            Asset objAsset2 = new Asset();
            objAsset2.Name = 'Test Asset 2';
            objAsset2.Product2Id = lstProducts[2].Id;
            objAsset2.SBQQ__CurrentSubscription__c = lSubscriptions[2].Id;
            objAsset2.SBQQ__QuoteLine__c = lstQuoteLines[2].Id;
            objAsset2.SBQQ__OrderProduct__c = lstOrderProducts[2].Id;
            objAsset2.accountId = accountId;
            objAsset2.AssetServicedById = accountId;
            objAsset2.Org__c = objOrg.Id;
            objAsset2.Status = 'Provisioning Complete';
            lstAssets.add(objAsset2);

            insert lstAssets;

            OrgContractService.createOrgContracts(new List<Id>{lContracts[0].Id});
            OrgContractService.createOrgContracts(new List<Id>{lContracts[0].Id});

            List<Org_Contract__c> lstOrgContracts = [SELECT Id FROM Org_Contract__c];
            Assert.isFalse(lstOrgContracts.isEmpty(), 'Org Contract is not created');

            Test.stopTest();
        }
    }

    /*
     Method Name : upsertRecordsTest
     Description : Testing org contract upsert
     Parameters  : None
     Return Type : None
     */
    @isTest
    public static void upsertRecordsTest() {

        System.runAs(new User(Id = UserInfo.getUserId())){
            sobject sObj = new Account();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
            List<Org__c> lstOrgs = new List<Org__c>();
            Set<Org_Contract__c> setOrgContracts = new Set<Org_Contract__c>();

            //Contract
            Contract objContract = new Contract();
            objContract.Name = 'Test Contract';
            objContract.ContractTerm = 10;
            objContract.AccountId = lAccount[0].Id;
            insert objContract;

            //Orgs
            Org__c objOrg = new Org__c();
            objOrg.Pod_Region__c = 'TEST ORG';
            objOrg.OrgID__c='TESTXXXYYYZZZ0';
            lstOrgs.add(objOrg);

            Org__c objOrg1 = new Org__c();
            objOrg.Pod_Region__c = 'TEST ORG 1';
            objOrg.OrgID__c='TESTXXXYYYZZZ1';
            lstOrgs.add(objOrg1);
            insert lstOrgs;

            List<Org__c> lstOrgsInserted = [SELECT Id FROM Org__c ORDER BY CreatedDate ASC];

            Assert.isFalse(lstOrgsInserted.isEmpty(), 'Org is not created');

            //Org Contracts
            Org_Contract__c objOrgContract = new Org_Contract__c();
            objOrgContract.Org__c = lstOrgsInserted[0].Id;
            objOrgContract.Contract__c = objContract.Id;
            objOrgContract.Status__c = 'Active';
            setOrgContracts.add(objOrgContract);

            Org_Contract__c objOrgContract1 = new Org_Contract__c();
            objOrgContract.Org__c = lstOrgsInserted[1].Id;
            objOrgContract1.Contract__c = objContract.Id;
            objOrgContract1.Status__c = 'Active';
            setOrgContracts.add(objOrgContract1);
            OrgContractService.upsertRecords(setOrgContracts);

            List<Org_Contract__c> lstOrgContracts = [SELECT Id FROM Org_Contract__c];
            Assert.isFalse(lstOrgContracts.isEmpty(), 'Org Contract is not created');
        }
    }
}