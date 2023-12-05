/*
Class:          OpportunityLineItemTriggerHandlerTest
@Author:        Sumitkumar Mittal
@Created Date:  04/27/2018
@Description:   test class for OpportunityLineItemTriggerHandler
Change History
******************************************************************
ModifiedBy          Date        Requested By        Description                 Tag

******************************************************************
*/

@isTest
private class OpportunityLineItemTriggerHandlerTest {
    
    private final static String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
    
    @testSetup
    static void setupObjectTestData() {
        User userObj = [select Id, Name from User where Name = 'Deployment master' and IsActive = true limit 1];
        System.runAs(userObj){
            //Query NA, APJ and EA territories
            List<Territory2> lTerritoryNA = (List<Territory2>) UtilityTest.executeQuery('Select Id from Territory2 where Name LIKE \'%NA%\'');
            
            sObject sObj = new Account();
            
            UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
            UtilityTestData.mAccountData.put('BillingCountry','United States');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
            List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //Insert Contact Data
            
            sObj = new Contact();
            
            UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mContactData.put('MailingCountry','United States');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //Billing rule data
            sObj = new blng__BillingRule__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngBillingRuleData);
            List<blng__BillingRule__c> lBillingRule = (List<blng__BillingRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new blng__RevenueRecognitionRule__c();
            sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mblngRevRecRuleData);
            List<blng__RevenueRecognitionRule__c> lRevRecRule = (List<blng__RevenueRecognitionRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});    
            System.assertEquals(lRevRecRule.size(),1);
            
            sObj = new blng__TaxRule__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngTaxRuleData);
            List<blng__TaxRule__c> lTaxRule = (List<blng__TaxRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            System.assertEquals(lTaxRule.size(),1);
            
            sObj = new blng__LegalEntity__c();
            UtilityTestData.mLegalEntityData.put('Name','test');
            UtilityTestData.mLegalEntityData.put('Business_Unit_Code__c','US001');
            UtilityTestData.mLegalEntityData.put('Multi_Country_Mapping1__c','India');
            UtilityTestData.mLegalEntityData.put('Multi_Country_Mapping2__c','India');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalEntityData);
            
            List<blng__LegalEntity__c> lLegalEntity = (List<blng__LegalEntity__c>) UtilityTest.makeInsert(new List<sObject>{sObj});  
            
            //Pricebook data
            sObj = new Pricebook2();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPricebook2Data);
            List<Pricebook2> lPricebook2 = (List<Pricebook2>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new Product2();
            UtilityTestData.mProduct2Data.put('blng__BillingRule__c', lBillingRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c', lRevRecRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__TaxRule__c', lTaxRule[0].Id);
            UtilityTestData.mProduct2Data.put('Amoritization_Schedule__c', 'DaaS');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
            List<Product2> lProduct = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj});
            System.assertEquals(lProduct.size(), 1);
            
            //create/update standard Pricebook1
            Id priceBookId  = Test.getStandardPricebookId();
            
            sObj = new PriceBookEntry();
            UtilityTestData.mPriceBookEntryData.put('Pricebook2Id', priceBookId);
            UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct[0].Id + '');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);
            List<PriceBookEntry> lPBEntry = (List<PriceBookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            // Insert new Opportunity
            String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
            UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
            UtilityTestData.mOpportunityData.put('Pricebook2Id', priceBookId);
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'Direct');
            UtilityTestData.mOpportunityData.put('StageName', 'Final Negotiation');
            UtilityTestData.mOpportunityData.put('Substage__c', 'Selected');
            UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
            UtilityTestData.mOpportunityData.put('Name', 'Test Oppty 1');
            UtilityTestData.mOpportunityData.put('CloseDate', System.today().addDays(60) + '');
            sObj = new Opportunity(Territory2Id = lTerritoryNA[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);

            UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'Direct');
            UtilityTestData.mOpportunityData.put('StageName', 'Final Negotiation');
            UtilityTestData.mOpportunityData.put('Substage__c', 'Selected');
            UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
            UtilityTestData.mOpportunityData.put('Name', 'Test Oppty 2');
            UtilityTestData.mOpportunityData.put('CloseDate', System.today().addDays(60) + '');
            UtilityTestData.mOpportunityData.put('Pricebook2Id', priceBookId);
            sObject sObj1 = new Opportunity();
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityData);
            
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
            //Insert Opportunity Contact Roles, Sold To
            UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunity[0].Id);
            UtilityTestData.mOpportunityContactRoleData.put('ContactId',lContact[0].Id);
            UtilityTestData.mOpportunityContactRoleData.put('Role', 'End User');
            sObj = new OpportunityContactRole();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityContactRoleData);
            
            UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunity[1].Id);
            UtilityTestData.mOpportunityContactRoleData.put('ContactId',lContact[0].Id);
            UtilityTestData.mOpportunityContactRoleData.put('Role', 'End User');
            sObj1 = new OpportunityContactRole();
            sObj1= UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityContactRoleData);

            List<OpportunityContactRole> lContactRoles = (List<OpportunityContactRole>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1});
                        
            Test.startTest();
            
            UtilityTestData.mSBQuoteData.put('SoldToAccount__c', lAccount[0].Id + '');
            UtilityTestData.mSBQuoteData.put('ShiptToAccount__c', lAccount[0].Id + '');
            UtilityTestData.mSBQuoteData.put('BillToAccount__c', lAccount[0].Id + '');
            UtilityTestData.mSBQuoteData.put('EndUserAccount__c', lAccount[0].Id + '');
            UtilityTestData.mSBQuoteData.put('SoldToContact__c', lContact[0].Id + '');
            UtilityTestData.mSBQuoteData.put('EndUserContact__c', lContact[0].Id + '');
            UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'false');        
            UtilityTestData.mSBQuoteData.put('CurrencyIsoCode', 'USD');  // Currency updated
            UtilityTestData.mSBQuoteData.put('SBQQ__Type__c', 'Quote');
            UtilityTestData.mSBQuoteData.put('Route_To_Market__c', 'Market Place Private');
            UtilityTestData.mSBQuoteData.put('Detail_RTM__c', 'Amazon AWS via Partner');
            UtilityTestData.mSBQuoteData.put('Override_Default_Language__c', 'en_US');
            UtilityTestData.mSBQuoteData.put('SBQQ__PaymentTerms__c', 'Other');
            UtilityTestData.mSBQuoteData.put('Partner_Override_Default_Language__c', 'en_US');
            UtilityTestData.mSBQuoteData.put('Special_Remarks1__c', 'Testing');
            UtilityTestData.mSBQuoteData.put('Partner_Special_Remarks__c', 'Testing');            
            UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c', System.Today() + '');        
            sObj = new SBQQ__Quote__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
            List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

            //Create QuoteLineItem
            sObj = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Discount__c','20');
            UtilityTestData.mQuoteLineData.put('Transaction_Type__c','New');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lSBQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

            Test.stopTest();
        }
    }
  
	@isTest
    static void testTransactionTypeUpdate() {
        Test.startTest();

        List<PriceBookEntry> lPriceBookEntry = [SELECT Id,Pricebook2Id from PriceBookEntry];

        Opportunity lOpportunity = [SELECT Id,Pricebook2Id FROM Opportunity WHERE Name = 'Test Oppty 2' LIMIT 1];
        lOpportunity.Pricebook2Id = lPriceBookEntry[0].Pricebook2Id;
        update lOpportunity;

        SBQQ__QuoteLine__c quoteLine = [SELECT ID FROM SBQQ__QuoteLine__c LIMIT 1];

        sObject sObjOppLineItem = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunity.Id);
        UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[0].Id);
        utilityTestData.mOpportunityProdData.put('Transaction_Type__c', 'Upsell');
        utilityTestData.mOpportunityProdData.put('UnitPrice', '100');
        utilityTestData.mOpportunityProdData.put('SBQQ__QuoteLine__c', quoteLine.Id);
        sObjOppLineItem = UtilityTest.putFieldRecord(sObjOppLineItem ,UtilityTestData.mOpportunityProdData);
        sObject sObjOppLineItem1 = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunity.Id);
        UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[0].Id);
        utilityTestData.mOpportunityProdData.put('Transaction_Type__c', 'Renewal');
        utilityTestData.mOpportunityProdData.put('UnitPrice', '100');
        utilityTestData.mOpportunityProdData.put('SBQQ__QuoteLine__c', quoteLine.Id);
        sObjOppLineItem1 = UtilityTest.putFieldRecord(sObjOppLineItem1 ,UtilityTestData.mOpportunityProdData);
        sObject sObjOppLineItem2 = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunity.Id);
        UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[0].Id);
        utilityTestData.mOpportunityProdData.put('Transaction_Type__c', 'Offset');
        utilityTestData.mOpportunityProdData.put('UnitPrice', '100');
        utilityTestData.mOpportunityProdData.put('SBQQ__QuoteLine__c', quoteLine.Id);
        sObjOppLineItem2 = UtilityTest.putFieldRecord(sObjOppLineItem2 ,UtilityTestData.mOpportunityProdData);
        sObject sObjOppLineItem3 = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunity.Id);
        UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[0].Id);
        utilityTestData.mOpportunityProdData.put('Transaction_Type__c', 'Cancelled');
        utilityTestData.mOpportunityProdData.put('UnitPrice', '100');
        utilityTestData.mOpportunityProdData.put('SBQQ__QuoteLine__c', quoteLine.Id);
        sObjOppLineItem3 = UtilityTest.putFieldRecord(sObjOppLineItem3 ,UtilityTestData.mOpportunityProdData);
        sObject sObjOppLineItem4 = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunity.Id);
        UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[0].Id);
        utilityTestData.mOpportunityProdData.put('Transaction_Type__c', 'New');
        utilityTestData.mOpportunityProdData.put('UnitPrice', '100');
        utilityTestData.mOpportunityProdData.put('SBQQ__QuoteLine__c', quoteLine.Id);
        sObjOppLineItem4 = UtilityTest.putFieldRecord(sObjOppLineItem4 ,UtilityTestData.mOpportunityProdData);
        List<OpportunityLineItem> lstOpportunityLineItem = (List<OpportunityLineItem>) UtilityTest.makeInsert(new List<sObject>{sObjOppLineItem, sObjOppLineItem1, sObjOppLineItem2, sObjOppLineItem3,sObjOppLineItem4});

        OpportunityLineItem oliItem = [SELECT Id,New_ACV__c,Upsell_ACV__c FROM OpportunityLineItem WHERE Transaction_Type__c = 'New' LIMIT 1];
        System.assertNotEquals(oliItem.New_ACV__c,0);
        
        Test.stopTest();
    }
  
	@isTest
    static void testSOPAmountUpdate() {
        Test.startTest();

        List<PriceBookEntry> lPriceBookEntry = [SELECT Id,Pricebook2Id from PriceBookEntry];

        Opportunity lOpportunity = [SELECT Id,Pricebook2Id FROM Opportunity WHERE Name = 'Test Oppty 2' LIMIT 1];
        lOpportunity.Pricebook2Id = lPriceBookEntry[0].Pricebook2Id;
        update lOpportunity;

        SBQQ__QuoteLine__c quoteLine = [SELECT ID FROM SBQQ__QuoteLine__c LIMIT 1];

        sObject sObjOppLineItem = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunity.Id);
        UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[0].Id);
        utilityTestData.mOpportunityProdData.put('Transaction_Type__c', 'Upsell');
        utilityTestData.mOpportunityProdData.put('Statement_of_Position_SOP_Amount__c', '100');
        sObjOppLineItem = UtilityTest.putFieldRecord(sObjOppLineItem ,UtilityTestData.mOpportunityProdData);
        sObject sObjOppLineItem1 = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunity.Id);
        UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[0].Id);
        utilityTestData.mOpportunityProdData.put('Transaction_Type__c', 'Renewal');
        utilityTestData.mOpportunityProdData.put('Statement_of_Position_SOP_Amount__c', '100');
        sObjOppLineItem1 = UtilityTest.putFieldRecord(sObjOppLineItem1 ,UtilityTestData.mOpportunityProdData);
        sObject sObjOppLineItem2 = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunity.Id);
        UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[0].Id);
        utilityTestData.mOpportunityProdData.put('Transaction_Type__c', 'Offset');
        utilityTestData.mOpportunityProdData.put('Statement_of_Position_SOP_Amount__c', '100');
        sObjOppLineItem2 = UtilityTest.putFieldRecord(sObjOppLineItem2 ,UtilityTestData.mOpportunityProdData);
        sObject sObjOppLineItem3 = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunity.Id);
        UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[0].Id);
        utilityTestData.mOpportunityProdData.put('Transaction_Type__c', 'Cancelled');
        utilityTestData.mOpportunityProdData.put('Statement_of_Position_SOP_Amount__c', '100');
        sObjOppLineItem3 = UtilityTest.putFieldRecord(sObjOppLineItem3 ,UtilityTestData.mOpportunityProdData);
        sObject sObjOppLineItem4 = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunity.Id);
        UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[0].Id);
        utilityTestData.mOpportunityProdData.put('Transaction_Type__c', 'New');
        utilityTestData.mOpportunityProdData.put('Statement_of_Position_SOP_Amount__c', '100');
        sObjOppLineItem4 = UtilityTest.putFieldRecord(sObjOppLineItem4 ,UtilityTestData.mOpportunityProdData);
        List<OpportunityLineItem> lstOpportunityLineItem = (List<OpportunityLineItem>) UtilityTest.makeInsert(new List<sObject>{sObjOppLineItem, sObjOppLineItem1, sObjOppLineItem2, sObjOppLineItem3,sObjOppLineItem4});
        
        Test.stopTest();
    }
}