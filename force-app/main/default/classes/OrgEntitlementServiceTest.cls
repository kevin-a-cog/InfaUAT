/*
 * Name			:	OrgEntitlementServiceTest
 * Author		:	Vignesh Divakaran
 * Created Date	: 	2/16/2023
 * Description	:	Test class for OrgEntitlementService.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Vignesh Divakaran		2/16/2023		N/A				Initial version.			N/A
 */

@isTest
public with sharing class OrgEntitlementServiceTest {

    private Final Static String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;

    /*
	 Method Name : setup
	 Description : Test setup method.
	 Parameters	 : None
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
            // UtilityTestData.mProduct2Data.put('SBQQ__ConfigurationEvent__c', 'Always');
            // UtilityTestData.mProduct2Data.put('SBQQ__OptionLayout__c', 'Tabs');
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
            // UtilityTestData.mProduct2Data.put('SBQQ__ConfigurationEvent__c', 'Always');
            // UtilityTestData.mProduct2Data.put('SBQQ__OptionLayout__c', 'Tabs');
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
            // UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c', dtToday+'');
            // UtilityTestData.mQuoteLineData.put('End_Date_Output_QL__c', qlendDate+'');
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
            // UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c', dtToday+'');
            // UtilityTestData.mQuoteLineData.put('End_Date_Output_QL__c', qlendDate+'');
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
            // UtilityTestData.mQuoteLineData.put('SBQQ__StartDate__c', dtToday+'');
            // UtilityTestData.mQuoteLineData.put('End_Date_Output_QL__c', qlendDate+'');
            UtilityTestData.mQuoteLineData.put('SBQQ__PricebookEntryId__c', lPricebookEntries[2].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__RequiredBy__c', lQuotelineWrapper[0].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
            List<SBQQ__QuoteLine__c> lQuotelineAddons = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1});

            SBQQ__Quote__c objQuote = new SBQQ__Quote__c(Id=lQuote[0].Id,SBQQ__Status__c='Approved',ApprovalStatus__c='Approved');
            update objQuote;

            /*Opportunity objOpportunity = new Opportunity(Id=lOpportunity[0].Id, StageName='Closed Won');
            update objOpportunity;*/

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

            SBQQ.TriggerControl.enable();

            Test.stopTest();
        }
    }

    /*
	 Method Name : testNNB
	 Description : Testing NNB order with Flex IPU products.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testNNB() {
        User objUser = [SELECT Id FROM User WHERE Name = 'Deployment master' AND IsActive = true LIMIT 1];
        System.runAs(objUser){
            Test.startTest();

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
            SBQQ.TriggerControl.disable();
            if(!lstUsageSummaries.isEmpty()){
                insert lstUsageSummaries;
            }
            SBQQ.TriggerControl.enable();

            Id orderId = [SELECT Id FROM Order LIMIT 1]?.Id;
            Assert.isFalse(orderId == null, 'Order is not created');

            OrgEntitlementService.createOrgEntitlements(orderId);
            ManageFulfillmentCtrl.createFulfillments(orderId);
            OrgEntitlementService.updateFLOnOrgEntitlementLine(orderId);

            List<Org_Entitlement__c> lstOrgEntitlements = [SELECT Id FROM Org_Entitlement__c];
            Assert.isFalse(lstOrgEntitlements.isEmpty(), 'Org Entitlement is not created');

            OrgEntitlementService.deleteOrgEntitlements(orderId);

            Test.stopTest();
        }
    }

    /*
	 Method Name : testAmend
	 Description : Testing Amend order with downsell & ramp up.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testAmend() {
        User objUser = [SELECT Id FROM User WHERE Name = 'Deployment master' AND IsActive = true LIMIT 1];
        System.runAs(objUser){
            Test.startTest();

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
            SBQQ.TriggerControl.disable();
            if(!lstUsageSummaries.isEmpty()){
                insert lstUsageSummaries;
            }
            SBQQ.TriggerControl.enable();

            Id orderId = [SELECT Id FROM Order LIMIT 1]?.Id;
            Assert.isFalse(orderId == null, 'Order is not created');

            OrgEntitlementService.createOrgEntitlements(orderId);
            ManageFulfillmentCtrl.createFulfillments(orderId);
            OrgEntitlementService.updateFLOnOrgEntitlementLine(orderId);

            List<Org_Entitlement__c> lstOrgEntitlements = [SELECT Id FROM Org_Entitlement__c];
            Assert.isFalse(lstOrgEntitlements.isEmpty(), 'Org Entitlement is not created');

            OrgEntitlementService.getOrgEntitlementForAmend(new Set<Id>{orderId}, new Map<Id, List<OrderItem>>());

            Test.stopTest();
        }
    }

    /*
	 Method Name : testIPU
	 Description : Testing NNB order with IPU products.
	 Parameters	 : None
	 Return Type : None
	 */
    @isTest
    public static void testIPU() {
        User objUser = [SELECT Id FROM User WHERE Name = 'Deployment master' AND IsActive = true LIMIT 1];
        System.runAs(objUser){
            Test.startTest();

            List<Product2> lstProducts = new List<Product2>();
            List<OrderItem> lstOrderLines = new List<OrderItem>();

            //Now, we change the consumption model for IPU products
            for(Product2 objProduct : [SELECT Id, GTM_Model__c FROM Product2]){
                objProduct.GTM_Model__c = System.Label.IPU;
                lstProducts.add(objProduct);
            }

            if(!lstProducts.isEmpty()){
                update lstProducts;
            }

            //Now, we change the prorate multiplier for IPU products
            for(OrderItem objOrderLine : [SELECT Id, SBQQ__ProrateMultiplier__c FROM OrderItem]){
                objOrderLine.SBQQ__ProrateMultiplier__c = 30;
                lstOrderLines.add(objOrderLine);
            }

            //Now, we create usage summaries
            Date dtStartDate = System.today();
            Date dtEndDate = System.today().addMonths(1).addDays(-1);
            List<blng__UsageSummary__c> lstUsageSummaries = new List<blng__UsageSummary__c>();

            for(OrderItem objOrderLine : [SELECT Id,EndDate,OrderId,Order.AccountId FROM OrderItem WHERE Product_Category__c = 'Add-ons' LIMIT 1]){
                Decimal decProrateMultipler = 30;
                while(decProrateMultipler > 0){
                    blng__UsageSummary__c objUsageSummary = new blng__UsageSummary__c();
                    objUsageSummary.blng__SummaryStartDate__c = dtStartDate;
                    objUsageSummary.blng__SummaryEndDate__c = dtEndDate;
                    objUsageSummary.blng__OrderProduct__c = objOrderLine.Id;
                    objUsageSummary.blng__Order__c = objOrderLine.OrderId;
                    objUsageSummary.blng__Account__c = objOrderLine.Order?.AccountId;
                    lstUsageSummaries.add(objUsageSummary);
                    decProrateMultipler--;
                    dtStartDate = dtStartDate.addMonths(1);
                    dtEndDate = decProrateMultipler > 1 ? dtStartDate.addMonths(1).addDays(-1) : objOrderLine.EndDate;
                }
            }
            SBQQ.TriggerControl.disable();
            if(!lstOrderLines.isEmpty()){
                update lstOrderLines;
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

            List<Org_Entitlement__c> lstOrgEntitlements = [SELECT Id FROM Org_Entitlement__c];
            Assert.isFalse(lstOrgEntitlements.isEmpty(), 'Org Entitlement is not created');

            OrgEntitlementService.getOrgEntitlementForAmend(new Set<Id>{orderId}, new Map<Id, List<OrderItem>>());

            Test.stopTest();
        }
    }
}