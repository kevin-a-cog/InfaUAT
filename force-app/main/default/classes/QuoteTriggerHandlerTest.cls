@isTest
private class QuoteTriggerHandlerTest{
    
    private Final static String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
    private Final static String ACC_Prospect_Account_Record_Type = Label.Prospect_Account_Record_Type;
    
    @testSetup
    static void setupObjectTestData() {
        User userObj = [select Id, Name from User where Name = 'Deployment master' and IsActive = true limit 1];
        System.runAs(userObj){
            //Query NA, APJ and EA territories
            List<Territory2> lTerritoryNA = (List<Territory2>) UtilityTest.executeQuery('Select Id from Territory2 where Name LIKE \'%NA%\'');
            List<Territory2> lTerritoryAPJ = (List<Territory2>) UtilityTest.executeQuery('Select Id from Territory2 where Name LIKE \'%AP%\'');
            List<Territory2> lTerritoryEA = (List<Territory2>) UtilityTest.executeQuery('Select Id from Territory2 where Name LIKE \'EA%\'');
            
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
            
            sObj = new Pricebook2(ID = priceBookId, IsActive = True);
            List<Pricebook2> lPriceBook = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            System.assertEquals(lPriceBook.size(), 1);
            
            sObj = new PriceBookEntry();
            UtilityTestData.mPriceBookEntryData.put('Pricebook2Id', lPriceBook[0].Id + '');
            UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct[0].Id + '');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);
            List<PriceBookEntry> lPBEntry = (List<PriceBookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj});
            System.assertEquals(lPBEntry.size(),1);        
            
            // Insert new Opportunity
            String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;            
            UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
            UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
            UtilityTestData.mOpportunityData.put('Type', 'Direct');
            UtilityTestData.mOpportunityData.put('StageName', 'Final Negotiation');
            UtilityTestData.mOpportunityData.put('Substage__c', 'Selected');
            UtilityTestData.mOpportunityData.put('Sales_Play__c', 'Data Quality');
            UtilityTestData.mOpportunityData.put('CloseDate', System.today().addDays(60) + '');
            
            sObj = new Opportunity(Territory2Id = lTerritoryNA[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);        
            sObject sObj1 = new Opportunity(Territory2Id =lTerritoryAPJ[0].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityData);        
            sObject sObj2 = new Opportunity(Territory2Id =lTerritoryEA[0].Id);
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mOpportunityData);
            
            //Below opportunities are without Territories data into it
            sObject sObj3 = new Opportunity();        
            sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mOpportunityData);
            
            sObject sObj4 = new Opportunity();        
            sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mOpportunityData);        
            
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3,sObj4});
            
            //Insert Opportunity Contact Roles, Sold To
            UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunity[0].Id);
            UtilityTestData.mOpportunityContactRoleData.put('ContactId',lContact[0].Id);
            UtilityTestData.mOpportunityContactRoleData.put('Role', 'End User');
            sObj = new OpportunityContactRole();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityContactRoleData);
            
            UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunity[1].Id);
            UtilityTestData.mOpportunityContactRoleData.put('ContactId',lContact[0].Id);
            UtilityTestData.mOpportunityContactRoleData.put('Role', 'Sold To');
            sObj1 = new OpportunityContactRole();
            sObj1= UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityContactRoleData);
            
            UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunity[2].Id);
            UtilityTestData.mOpportunityContactRoleData.put('ContactId',lContact[0].Id);
            UtilityTestData.mOpportunityContactRoleData.put('Role', 'Shipping Contact');
            sObj2 = new OpportunityContactRole();
            sObj2= UtilityTest.putFieldRecord(sObj2, UtilityTestData.mOpportunityContactRoleData);
            
            UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunity[3].Id);
            UtilityTestData.mOpportunityContactRoleData.put('ContactId',lContact[0].Id);
            UtilityTestData.mOpportunityContactRoleData.put('Role', 'Billing Contact');
            sObj3 = new OpportunityContactRole();
            sObj3= UtilityTest.putFieldRecord(sObj3, UtilityTestData.mOpportunityContactRoleData);
            List<OpportunityContactRole> lContactRoles = (List<OpportunityContactRole>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1, sObj2, sObj3});
            System.assertEquals(lContactRoles.size(), 4);
            
            UtilityTestData.mSBQuoteData.put('SoldToAccount__c', lAccount[0].Id + '');
            UtilityTestData.mSBQuoteData.put('ShiptToAccount__c', lAccount[0].Id + '');
            UtilityTestData.mSBQuoteData.put('BillToAccount__c', lAccount[0].Id + '');
            UtilityTestData.mSBQuoteData.put('EndUserAccount__c', lAccount[0].Id + '');
            UtilityTestData.mSBQuoteData.put('SoldToContact__c', lContact[0].Id + '');
            UtilityTestData.mSBQuoteData.put('EndUserContact__c', lContact[0].Id + '');
            UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'true');        
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
            
            UtilityTestData.mContractData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mContractData.put('Status','Draft');
            UtilityTestData.mContractData.put('SBQQ__Opportunity__c',lOpportunity[0].Id);
            UtilityTestData.mContractData.put('StartDate',System.today()+'');
            UtilityTestData.mContractData.put('SBQQ__Quote__c',lQuote[0].Id);
            sObj = new Contract();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContractData);
            List<Contract> lContract = (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});        
            
            // Insert new Quote
            UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[0].Id + '');
            UtilityTestData.mSBQuoteData.put('SBQQ__PriceBook__c', lPricebook2[0].Id + '');
            UtilityTestData.mSBQuoteData.put('SBQQ__PricebookId__c', lPricebook2[0].Id + '');
            UtilityTestData.mSBQuoteData.put('Legal_Entity__c', lLegalEntity[0].Id + '');
            UtilityTestData.mSBQuoteData.put('SoldToAccount__c', lAccount[0].Id + '');
            UtilityTestData.mSBQuoteData.put('ShiptToAccount__c', lAccount[0].Id + '');
            UtilityTestData.mSBQuoteData.put('BillToAccount__c', lAccount[0].Id + '');
            UtilityTestData.mSBQuoteData.put('EndUserAccount__c', lAccount[0].Id + '');
            UtilityTestData.mSBQuoteData.put('SoldToContact__c', lContact[0].Id + '');
            UtilityTestData.mSBQuoteData.put('EndUserContact__c', lContact[0].Id + '');
            UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'true');        
            UtilityTestData.mSBQuoteData.put('CurrencyIsoCode', 'USD');  // Currency updated
            UtilityTestData.mSBQuoteData.put('SBQQ__Type__c', 'Renewal');
            UtilityTestData.mSBQuoteData.put('Detail_RTM__c', 'Microsoft Azure');
            UtilityTestData.mSBQuoteData.put('SBQQ__PaymentTerms__c', 'Other');
            UtilityTestData.mSBQuoteData.put('Route_To_Market__c', 'Partner');
            UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c', System.Today() + '');
            
            sObj = new SBQQ__Quote__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
            
            sObj1 = new SBQQ__Quote__c();
            UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[1].Id + '');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mSBQuoteData);
            
            sObj2 = new SBQQ__Quote__c();
            UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[2].Id + '');
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mSBQuoteData);
            
            sObj3 = new SBQQ__Quote__c();
            UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[3].Id + '');
            UtilityTestData.mSBQuoteData.put('SBQQ__Type__c', 'Renewal');
            sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mSBQuoteData);
            
            UtilityTestData.mSBQuoteData.put('SBQQ__Type__c', 'Amendment');
            UtilityTestData.mSBQuoteData.put('SBQQ__SubscriptionTerm__c', '12');
            UtilityTestData.mSBQuoteData.put('SBQQ__BillingName__c', 'Quote Billing Name');
            UtilityTestData.mSBQuoteData.put('SBQQ__PaymentTerms__c', 'Other');
            UtilityTestData.mSBQuoteData.put('SBQQ__ShippingName__c', 'Quote Shipping Name');
            UtilityTestData.mSBQuoteData.put('Shipping_Email__c', 'testmail@test.com');
            UtilityTestData.mSBQuoteData.put('SBQQ__Status__c', 'Approved');
            UtilityTestData.mSBQuoteData.put('BillingAddress_PSFTID__c', 'Billing Address');
            UtilityTestData.mSBQuoteData.put('EditLinesFieldSetName__c', 'Standard');
            UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunity[4].Id + '');
            UtilityTestData.mSBQuoteData.put('SBQQ__MasterContract__c',lContract[0].Id + '');
            UtilityTestData.mSBQuoteData.put('Additional_Customer_Signature_Blocks__c', '1');
            UtilityTestData.mSBQuoteData.put('Compliance_Settlement__c', 'True');
            UtilityTestData.mSBQuoteData.put('Custom_Support_SLAs__c', 'Testing');
            UtilityTestData.mSBQuoteData.put('ELA_Terms__c', 'Testing');
            UtilityTestData.mSBQuoteData.put('INFA_Signature_Blocks__c', '1');
            UtilityTestData.mSBQuoteData.put('IPS_Custom_Travel_Policy__c', 'Testing');
            UtilityTestData.mSBQuoteData.put('IPS_Price_Holds__c', 'True');
            UtilityTestData.mSBQuoteData.put('License_Price_Protection__c', 'Testing');
            UtilityTestData.mSBQuoteData.put('Route_To_Market__c', 'Market Place Private');
            UtilityTestData.mSBQuoteData.put('Detail_RTM__c', 'Amazon AWS');
            UtilityTestData.mSBQuoteData.put('Tax_Update_Status__c', 'Running');
            UtilityTestData.mSBQuoteData.put('ApprovalStatus__c', 'Pending');
                     
            sObj4 = new SBQQ__Quote__c(SBQQ__StartDate__c = system.today());
            sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mSBQuoteData);
            
            Test.startTest();
            
            List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3,sObj4});
            
            //Create QuoteLineItem
            sObj = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Discount__c','90');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
            
            sObj1 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[1].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[0].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
            
            sObj2 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[2].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[0].Id);
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);
            
            sObj3 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[3].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[0].Id);
            sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mQuoteLineData);
            
            sObj4 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[4].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct[0].Id);
            sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mQuoteLineData);        
            
            List<SBQQ__QuoteLine__c> lSBQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3,sObj4});
            
            //Create related Order record
            sObj = new Order();
            UtilityTestData.mOrderData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mOrderData.put('SoldToAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('SoldToContact__c',lContact[0].Id);
            UtilityTestData.mOrderData.put('EndUserAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('EndUserContact__c',lContact[0].Id);
            UtilityTestData.mOrderData.put('ShipToAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('BilltoAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('SBQQ__Quote__c',lSBQuote[0].Id);
            UtilityTestData.mOrderData.put('SBQQ__PaymentTerm__c','Other');
            UtilityTestData.mOrderData.put('Pricebook2Id',lPriceBook2[0].Id);
            UtilityTestData.mOrderData.put('Billing_Alignment_Date__c',System.today()+'');
            UtilityTestData.mOrderData.put('Ready_for_Billing_Received__c','False'); 
            UtilityTestData.mOrderData.put('Status','Review Completed'); 
            UtilityTestData.mOrderData.put('SBQQ__PriceCalcStatus__c','Completed'); 
            UtilityTestData.mOrderData.put('EffectiveDate',System.today()+'');
            UtilityTestData.mOrderData.put('blng__BillingDayOfMonth__c',String.valueOf(System.today().Day()));
            UtilityTestData.mOrderData.put('SBQQ__PaymentTerm__c','Other');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderData);
            
            sObj1 = new Order();
            UtilityTestData.mOrderData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mOrderData.put('SoldToAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('SoldToContact__c',lContact[0].Id);
            UtilityTestData.mOrderData.put('EndUserAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('EndUserContact__c',lContact[0].Id);
            UtilityTestData.mOrderData.put('ShipToAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('BilltoAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('SBQQ__Quote__c',lSBQuote[1].Id);
            UtilityTestData.mOrderData.put('SBQQ__PaymentTerm__c','Other');
            UtilityTestData.mOrderData.put('Pricebook2Id',lPriceBook2[0].Id);
            UtilityTestData.mOrderData.put('Billing_Alignment_Date__c',System.today()+'');
            UtilityTestData.mOrderData.put('EffectiveDate',System.today()+'');
            UtilityTestData.mOrderData.put('blng__BillingDayOfMonth__c',String.valueOf(System.today().Day()));
            UtilityTestData.mOrderData.put('Type','Amendment');
            UtilityTestData.mOrderData.put('Ready_for_Billing_Received__c','False'); 
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOrderData);
            
            List<Order> lOrder = (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1});
            
            sObject sObjPT = new Payment_Term__c();
            UtilityTestData.mpaymentTerm.put('Order__c',sObj.Id);
            sObjPT = UtilityTest.putFieldRecord(sObjPT, UtilityTestData.mpaymentTerm);
            List<Payment_Term__c> lpaymentTerm = (List<Payment_Term__c>) UtilityTest.makeInsert(new List<sObject>{sObjPT});
            sObject sObjPT1 = new Payment_Term__c(Id = lpaymentTerm[0].Id ,Payment_Term__c= 20);
            List<Payment_Term__c> lpaymentTermUpdate = (List<Payment_Term__c>) UtilityTest.makeUpdate(new List<sObject>{sObjPT1});
            
            
            
            Test.stopTest();
        }
    }
    
    //Below method is to check the functional flow on Opportunity Insert
    //Insert the quote with the Renewal contrct value updated in the Opportunity
    @isTest
    static void insertQuoteTest() {
        
        Test.startTest();
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.executeQuery('Select Id, Territory2Id from Opportunity limit 5');
        system.assertEquals(lOpportunity.size(),5);
        List<Contract> lContract = (List<Contract>) UtilityTest.executeQuery('Select Id,SBQQ__RenewalTerm__c from Contract Limit 1');
        List<Order> lOrder = (List<Order>) UtilityTest.executeQuery('Select Id from Order Limit 1'); 
        sObject sObj = new Contract(id = lContract[0].Id, SBQQ__Order__c = lOrder[0].Id,SBQQ__RenewalTerm__c = 12);
        List<Contract> lContractUpdate = (List<Contract>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        System.AssertEquals(lContractUpdate.size(),1);
        
        sObject sObj1 = new Opportunity(id = lOpportunity[0].Id, SBQQ__RenewedContract__c = lContract[0].Id);
        sObject sObj2 = new Opportunity(id = lOpportunity[1].Id, SBQQ__RenewedContract__c = lContract[0].Id);
        sObject sObj3 = new Opportunity(id = lOpportunity[2].Id, SBQQ__RenewedContract__c = lContract[0].Id);
        sObject sObj4 = new Opportunity(id = lOpportunity[3].Id, SBQQ__RenewedContract__c = lContract[0].Id);
        sObject sObj5 = new Opportunity(id = lOpportunity[4].Id, SBQQ__RenewedContract__c = lContract[0].Id);
        List<Opportunity> lOpptyUpdate = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj1, sObj2, sObj3, sObj4, sObj5});
        System.AssertEquals(lOpptyUpdate.size(),5);
        
        sObj3 = new SBQQ__Quote__c(SBQQ__StartDate__c = System.Today());
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[0].Id + '');
        sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj3});
        System.AssertEquals(lSBQuote.size(),1);
        Test.stopTest();
        
        
    }

    //Insert the qoute with the related contact value populated and Amendment type of the Quote
    @isTest
    static void insertQuoteTest1() {
        Test.startTest();
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.executeQuery('Select Id, Territory2Id from Opportunity limit 5');
        system.assertEquals(lOpportunity.size(),5);
        List<Contract> lContract = (List<Contract>) UtilityTest.executeQuery('Select Id from Contract Limit 1');
        List<Order> lOrder = (List<Order>) UtilityTest.executeQuery('Select Id from Order Limit 1');
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.executeQuery('Select Id, Name, SBQQ__SubscriptionTerm__c, Territory__c, SBQQ__EndDate__c, SBQQ__StartDate__c from SBQQ__Quote__c Where INFA_Signature_Blocks__c = \'1\'  Limit 1');
        system.assertEquals(lQuote.size(),1);
        
        sObject sObj = new Contract(id = lContract[0].Id, SBQQ__Order__c = lOrder[0].Id, SBQQ__Quote__c = lQuote[0].Id);
        List<Contract> lContractUpdate = (List<Contract>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        System.AssertEquals(lContractUpdate.size(),1);
        
        sObject sObj1 = new Opportunity(id = lOpportunity[0].Id, SBQQ__RenewedContract__c = lContract[0].Id );
        sObject sObj2 = new Opportunity(id = lOpportunity[1].Id, SBQQ__RenewedContract__c = lContract[0].Id );
        sObject sObj3 = new Opportunity(id = lOpportunity[2].Id, SBQQ__RenewedContract__c = lContract[0].Id );
        sObject sObj4 = new Opportunity(id = lOpportunity[3].Id, SBQQ__RenewedContract__c = lContract[0].Id );
        sObject sObj5 = new Opportunity(id = lOpportunity[4].Id, SBQQ__RenewedContract__c = lContract[0].Id );
        List<Opportunity> lOpptyUpdate = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj1, sObj2, sObj3, sObj4, sObj5});
        System.AssertEquals(lOpptyUpdate.size(),5);            
        
        sObj3 = new SBQQ__Quote__c(Related_Contract__c = lContract[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[0].Id + '');
        UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c', System.Today() + '');
        sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mSBQuoteData);
        
        UtilityTestData.mSBQuoteData.put('SBQQ__Type__c', 'Amendment');
        UtilityTestData.mSBQuoteData.put('SBQQ__SubscriptionTerm__c', '12');
        UtilityTestData.mSBQuoteData.put('SBQQ__EndDate__c', System.today().addDays(365)+'');
        UtilityTestData.mSBQuoteData.put('SBQQ__PaymentTerms__c', 'Net 30');
        UtilityTestData.mSBQuoteData.put('SBQQ__ShippingName__c', 'Quote Shipping Name');
        UtilityTestData.mSBQuoteData.put('Shipping_Email__c', 'testmail@test.com');
        UtilityTestData.mSBQuoteData.put('SBQQ__Status__c', 'Approved');
        UtilityTestData.mSBQuoteData.put('BillingAddress_PSFTID__c', 'Billing Address');
        UtilityTestData.mSBQuoteData.put('EditLinesFieldSetName__c', 'Standard');
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunity[4].Id + '');
        UtilityTestData.mSBQuoteData.put('SBQQ__MasterContract__c',lContract[0].Id + '');
        UtilityTestData.mSBQuoteData.put('CurrencyIsoCode', 'USD');
        UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'True');           
        sObj4 = new SBQQ__Quote__c(Related_Contract__c = lContract[0].Id); 
        sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj3, sObj4});                       
        System.AssertEquals(lSBQuote.size(),2);
        
        Test.stopTest();        
    }

    //Insert the qoute with Type 'NEW'
    @isTest
    static void insertTestQuoteTypeNew() {
        Test.startTest();
        //User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.executeQuery('Select Id, Territory2Id from Opportunity limit 5');
        system.assertEquals(lOpportunity.size(),5);
        List<Contract> lContract = (List<Contract>) UtilityTest.executeQuery('Select Id from Contract Limit 1');
        List<Order> lOrder = (List<Order>) UtilityTest.executeQuery('Select Id from Order Limit 1');
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.executeQuery('Select Id, Name, SBQQ__SubscriptionTerm__c, Territory__c, SBQQ__EndDate__c, SBQQ__StartDate__c from SBQQ__Quote__c Where INFA_Signature_Blocks__c = \'1\'  Limit 1');
        system.assertEquals(lQuote.size(),1);
        
        sObject sObj = new Contract(id = lContract[0].Id, SBQQ__Order__c = lOrder[0].Id, SBQQ__Quote__c = lQuote[0].Id);
        List<Contract> lContractUpdate = (List<Contract>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        System.AssertEquals(lContractUpdate.size(),1);
        
        sObject sObj1 = new Opportunity(id = lOpportunity[0].Id, SBQQ__RenewedContract__c = lContract[0].Id , OrderableIn__c = 'New');
        sObject sObj2 = new Opportunity(id = lOpportunity[1].Id, SBQQ__RenewedContract__c = lContract[0].Id , OrderableIn__c = 'New');
        sObject sObj3 = new Opportunity(id = lOpportunity[2].Id, SBQQ__RenewedContract__c = lContract[0].Id , OrderableIn__c = 'New');
        sObject sObj4 = new Opportunity(id = lOpportunity[3].Id, SBQQ__RenewedContract__c = lContract[0].Id , OrderableIn__c = 'New');
        sObject sObj5 = new Opportunity(id = lOpportunity[4].Id, SBQQ__RenewedContract__c = lContract[0].Id , OrderableIn__c = 'New');
        List<Opportunity> lOpptyUpdate = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj1, sObj2, sObj3, sObj4, sObj5});
        System.AssertEquals(lOpptyUpdate.size(),5);
        
        List<blng__LegalEntity__c> lLegalEntity = [Select Id from blng__LegalEntity__c limit 1];
        
        UtilityTestData.mSBQuoteData.put('SBQQ__Type__c', 'Quote');
        UtilityTestData.mSBQuoteData.put('SBQQ__SubscriptionTerm__c', '12');
        UtilityTestData.mSBQuoteData.put('SBQQ__BillingName__c', 'Quote Billing Name');
        UtilityTestData.mSBQuoteData.put('SBQQ__PaymentTerms__c', 'Net 30');
        UtilityTestData.mSBQuoteData.put('SBQQ__ShippingName__c', 'Quote Shipping Name');
        UtilityTestData.mSBQuoteData.put('Shipping_Email__c', 'testmail@test.com');
        UtilityTestData.mSBQuoteData.put('SBQQ__Status__c', 'Approved');
        UtilityTestData.mSBQuoteData.put('BillingAddress_PSFTID__c', 'Billing Address');
        UtilityTestData.mSBQuoteData.put('EditLinesFieldSetName__c', 'Standard');
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunity[4].Id + '');
        UtilityTestData.mSBQuoteData.put('CurrencyIsoCode', 'USD');
        UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'True');           
        UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'True');   
        UtilityTestData.mSBQuoteData.put('Legal_Entity__c', lLegalEntity[0].Id);                 
        sObj4 = new SBQQ__Quote__c(Related_Contract__c = lContract[0].Id);
        
        
        List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj4});                       
        System.AssertEquals(lSBQuote.size(),1);
        
        //QuoteTriggerHandler.updateSBQQ_Quote(lSBQuote);
        
        Test.stopTest();
    }
    
    //Update the existing Quote for firing the trigger for update operation
    @isTest
    static void updateQuoteOrderUpdate() {
        
        //User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.executeQuery('Select Id, Territory2Id from Opportunity limit 5');
        system.assertEquals(lOpportunity.size(),5);
        List<Contact> lContact = (List<Contact>) UtilityTest.executeQuery('Select Id from Contact Limit 1');
        Test.startTest();
        
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.executeQuery('Select Id, Apply_PO_to_All_Lines__c,Name, SBQQ__SubscriptionTerm__c, Territory__c, SBQQ__EndDate__c, SBQQ__StartDate__c from SBQQ__Quote__c Limit 1');
        List<Contract> lContract = (List<Contract>) UtilityTest.executeQuery('Select Id from Contract Limit 1');
        List<SBQQ__Quote__c> lQuote1 = (List<SBQQ__Quote__c>) UtilityTest.executeQuery('Select Id, Apply_PO_to_All_Lines__c,Name, SBQQ__SubscriptionTerm__c, Territory__c, SBQQ__EndDate__c, SBQQ__StartDate__c from SBQQ__Quote__c Where INFA_Signature_Blocks__c = \'1\'  Limit 1');
        system.assertEquals(lQuote1.size(),1);
        List<Order> lOrder = (List<Order>) UtilityTest.executeQuery('Select Id from Order Limit 1');
        
        sObject sObj = new Contract(id = lContract[0].Id, SBQQ__Order__c = lOrder[0].Id, SBQQ__Quote__c = lQuote1[0].Id);
        List<Contract> lContractUpdate = (List<Contract>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        System.AssertEquals(lContractUpdate.size(),1);
        
        sObject sObj1 = new Opportunity(id = lOpportunity[0].Id, SBQQ__RenewedContract__c = lContract[0].Id );
        sObject sObj2 = new Opportunity(id = lOpportunity[1].Id, SBQQ__RenewedContract__c = lContract[0].Id );
        sObject sObj3 = new Opportunity(id = lOpportunity[2].Id, SBQQ__RenewedContract__c = lContract[0].Id );
        sObject sObj4 = new Opportunity(id = lOpportunity[3].Id, SBQQ__RenewedContract__c = lContract[0].Id );
        sObject sObj5 = new Opportunity(id = lOpportunity[4].Id, SBQQ__RenewedContract__c = lContract[0].Id );
        List<Opportunity> lOpptyUpdate = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj1, sObj2, sObj3, sObj4, sObj5});
        System.AssertEquals(lOpptyUpdate.size(),5);
        
        Map<Id,SBQQ__Quote__c> mapQuote = new Map<Id,SBQQ__Quote__c>();
        mapQuote.put(lQuote[0].Id, lQuote[0]);
        //QuoteTriggerHandler.updateQuoteLine(mapQuote, mapQuote);
        
        sObj1 = new SBQQ__Quote__c(id = lQuote[0].Id, SBQQ__Type__c = 'Amendment', Route_To_Market__c= 'Market Place Private',
                                   ApprovalStatus__c = 'Approved',
                                   SBQQ__MasterContract__c= lContract[0].Id, SBQQ__StartDate__c  = Date.today().addDays(40) );
        List<SBQQ__Quote__c> lQuoteUpdate = (List<SBQQ__Quote__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
        System.AssertEquals(lQuoteUpdate.size(),1);            
        
        Test.stopTest();
    }
    @isTest
    static void quoteIgnorInsertAndUpdate() {
        // User query
        
        //User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.executeQuery('Select Id, Territory2Id from Opportunity limit 1');
        system.assertEquals(lOpportunity.size(),1);
        
        //System.runAs(userObj) {          
        Test.startTest();
        sObject sObj = new SBQQ__Quote__c(SBQQ__StartDate__c = System.Today());
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[0].Id + '');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        globalApexManager.avoidRecursion('QuoteBeforeInsert');
        globalApexManager.avoidRecursion('QuoteAfterInsert');
        List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        Test.stopTest();            
        //}
    }
    
    //Insert the quote with the Renewal contract and no Order 
    @isTest
    static void insertRenewalQuoteWithoutOrderTest() {
         Test.startTest();
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.executeQuery('Select Id, Territory2Id from Opportunity limit 5');
        system.assertEquals(lOpportunity.size(),5);
        List<Contract> lContract = (List<Contract>) UtilityTest.executeQuery('Select Id from Contract Limit 2');
        List<Order> lOrder = (List<Order>) UtilityTest.executeQuery('Select Id from Order Limit 1'); 
        
        //Test.startTest();
        
        sObject sObj = new Contract(id = lContract[0].Id,BillingAddress_PSFTID__c = 'test', BillingName_PSFTID__c = 'Test1' , ShippingAddress_PSFTID__c = 'Shipping test' , 
                                    ShippingName_PSFTID__c = 'Shipping test2' , EndUserAddress_PSFTID__c = 'end user test' , SoldAddress_PSFTID__c = 'sold test1',
                                    EndUserCity__c = 'e test city',EndUserCountry__c = ' e test country ', EndUserPostalCode__c = 'e test code',EndUserStateProvince__c ='e test state', 
                                    EndUserStreet__c ='e test street', SoldCity__c = 's test city',SoldCountry__c= 's country test',SoldPostalCode__c = 's test code',SoldStateProvince__c = 's test state',
                                    SoldStreet__c = ' s street test',BillingCity = 'b test city',BillingCountry= 'b test country',BillingPostalCode = ' b test code',BillingState= ' b test state',
                                    BillingStreet = 'b test street',ShippingCity = ' shipping test city',ShippingCountry = 'shipping test country',ShippingPostalCode = 'shipping test code',
                                    ShippingState = 'shipping test state',ShippingStreet = ' shipping test street',Shipping_Email__c = 'test@test.com',SBQQ__RenewalTerm__c = 12);
        List<Contract> lContractUpdate = (List<Contract>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        System.AssertEquals(lContractUpdate.size(),1);
        
        sObject sObj1 = new Opportunity(id = lOpportunity[0].Id, SBQQ__RenewedContract__c = lContract[0].Id);
        sObject sObj2 = new Opportunity(id = lOpportunity[1].Id, SBQQ__RenewedContract__c = lContract[0].Id);
        sObject sObj3 = new Opportunity(id = lOpportunity[2].Id, SBQQ__RenewedContract__c = lContract[0].Id);
        sObject sObj4 = new Opportunity(id = lOpportunity[3].Id, SBQQ__RenewedContract__c = lContract[0].Id);
        sObject sObj5 = new Opportunity(id = lOpportunity[4].Id, SBQQ__RenewedContract__c = lContract[0].Id);
        List<Opportunity> lOpptyUpdate = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj1, sObj2, sObj3, sObj4, sObj5});
        System.AssertEquals(lOpptyUpdate.size(),5);
        
        sObj3 = new SBQQ__Quote__c(SBQQ__StartDate__c = System.Today());
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[0].Id + '');
        UtilityTestData.mSBQuoteData.put('SBQQ__ShippingCountry__c', 'India');
        sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj3});
        System.AssertEquals(lSBQuote.size(),1);
        Test.stopTest();
    }
    
    //Insert the quote with the Contact Addres
    @isTest
    static void insertQuoteTestWithAddress() {
        
        List<Contact> lContact = (List<Contact>) UtilityTest.executeQuery('Select Id from Contact Limit 1');
        
        Test.startTest();
        
        sObject sObj = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObject sObj5 = new Opportunity(); 
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        sObj5 = UtilityTest.putFieldRecord(sObj5, UtilityTestData.mOpportunityData);
        
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj5});
        
        sObj5 = new Contact(FirstName = 'Test1');
        UtilityTestData.mContactData.put('MailingStreet' , 'Test Street');
        UtilityTestData.mContactData.put('MailingCity' , 'Test City');
        UtilityTestData.mContactData.put('MailingPostalCode' , 'Test Postal Code');
        UtilityTestData.mContactData.put('MailingCountry' , 'Test Country');
        UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
        sObj5 = UtilityTest.putFieldRecord(sObj5, UtilityTestData.mContactData);
        
        List<Contact> lContacts = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj5});
        System.debug('lContacts' + lContacts );
        
        sObject sObj3 = new SBQQ__Quote__c(SBQQ__StartDate__c = System.Today());
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[0].Id + '');
        sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mSBQuoteData);
        
        List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj3});
        System.AssertEquals(lSBQuote.size(),1);
        
        sObj3 = new SBQQ__Quote__c(id = lSBQuote[0].Id);
        UtilityTestData.mSBQuoteData.put('BillToContact__c', lContacts[0].Id);
        UtilityTestData.mSBQuoteData.put('ShipToContact__c', lContacts[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__ShippingCountry__c', 'India');
        UtilityTestData.mSBQuoteData.put('EndUserContact__c', lContacts[0].Id);
        sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> lSBQuoteUpdated = (List<SBQQ__Quote__c>) UtilityTest.makeUpdate(new List<sObject>{sObj3});
        System.AssertEquals(lSBQuoteUpdated.size(),1);
        Test.stopTest();
    }
    
    //Insert the quote with the with no address on Contact
    @isTest
    static void insertQuoteTestWithNoAddress() {
        List<Contact> lContact = (List<Contact>) UtilityTest.executeQuery('Select Id from Contact Limit 1');
        
        Test.startTest();
        sObject sObja = new Account();
        sObja = UtilityTest.putFieldRecord(sObja, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObja});
        
        sObject sObj5 = new Opportunity();        
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        sObj5 = UtilityTest.putFieldRecord(sObj5, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj5});
        sObj5 = new Contact(FirstName = 'Test1');
        UtilityTestData.mContactData.remove('MailingStreet');
        UtilityTestData.mContactData.remove('MailingCity');
        UtilityTestData.mContactData.remove('MailingPostalCode');
        UtilityTestData.mContactData.remove('MailingCountry');
        UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
        sObj5 = UtilityTest.putFieldRecord(sObj5, UtilityTestData.mContactData);
        
        List<Contact> lContacts = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj5});
        System.debug('lContacts' + lContacts );
        
        UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunity[0].Id);
        UtilityTestData.mOpportunityContactRoleData.put('ContactId',lContacts[0].Id);
        UtilityTestData.mOpportunityContactRoleData.put('Role', 'Sold To');
        sObject sObj = new OpportunityContactRole();
        sObj= UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityContactRoleData);
        List<OpportunityContactRole> lContactRoles = (List<OpportunityContactRole>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObject sObj3 = new SBQQ__Quote__c(SBQQ__StartDate__c = System.Today());
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[0].Id + '');
        sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mSBQuoteData);
        
        List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj3});
        System.AssertEquals(lSBQuote.size(),1);
        
        Test.stopTest();
    }
    @isTest
    static void createCMSRequestTest(){
        
        Test.startTest();
        List<Opportunity> lOpportunity = [Select Id, AccountId from Opportunity WHERE StageName = 'Final Negotiation' limit 1];
        List<blng__LegalEntity__c> lLegalEntity = [Select Id from blng__LegalEntity__c limit 1];
        
        List<Engagement__c> lstEngagement = [SELECT Id FROM Engagement__c];
        delete lstEngagement;
        
        //Test.startTest();
        sObject sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('SBQQ__Account__c',lOpportunity[0].AccountId);
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunity[0].Id);
        UtilityTestData.mSBQuoteData.put('Legal_Entity__c',lLegalEntity[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c',System.today()+'');
        UtilityTestData.mSBQuoteData.put('SBQQ__EndDate__c',System.today().addMonths(12)+'');
        UtilityTestData.mSBQuoteData.put('Shipping_Preference__c','Email');
        UtilityTestData.mSBQuoteData.put('SBQQ__BillingName__c','Test user');
        UtilityTestData.mSBQuoteData.put('SBQQ__ShippingName__c','Test user');
        UtilityTestData.mSBQuoteData.put('Shipping_Email__c','test@email.com');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        lstEngagement = [SELECT Id FROM Engagement__c];
        //System.assertEquals(1,lstEngagement.size());
        Test.stopTest();
    } 
    @isTest
    static void upsertERPSiteTest(){
          Test.startTest();
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<SBQQ__Quote__c> lSBQuote = [Select Id,SoldToAccount__c from SBQQ__Quote__c limit 1];   
        Account soldToAcc = new Account(Id = lSBQuote[0].SoldToAccount__c,Peoplesoft_External_ID__c = 'TestErp'); 
         
       // Test.startTest();
        update soldToAcc;                  
        
        System.runAs(userObj){
            List<Id> lstQuotetoUpdate = new List<Id>();
            lstQuotetoUpdate.add(lSBQuote[0].Id);
            sObject sObj = new SBQQ__Quote__c(id = lSBQuote[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__ShippingState__c', 'TX');
            UtilityTestData.mSBQuoteData.put('Exemption_number__c', 'EXMP1211');        
            UtilityTestData.mSBQuoteData.put('OneSource_Last_Call_Time__c', System.Now()+'');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
            lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            
            QuoteTriggerHandler.upsertERPSite(lstQuotetoUpdate);
            
            sObj = new SBQQ__Quote__c(id = lSBQuote[0].Id); 
            UtilityTestData.mSBQuoteData.put('Exemption_number__c', '');  
            UtilityTestData.mSBQuoteData.put('Calculated_Tax_Amount__c', '546');       
            UtilityTestData.mSBQuoteData.put('OneSource_Last_Call_Time__c', System.Now().addMonths(1)+'');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
            lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeUpdate(new List<sObject>{sObj}); 
            
            QuoteTriggerHandler.upsertERPSite(lstQuotetoUpdate);
            
            sObj = new SBQQ__Quote__c(id = lSBQuote[0].Id); 
            UtilityTestData.mSBQuoteData.put('SBQQ__ShippingState__c', 'CA'); 
            UtilityTestData.mSBQuoteData.put('Calculated_Tax_Amount__c', '0');       
            UtilityTestData.mSBQuoteData.put('OneSource_Last_Call_Time__c', System.Now().addMonths(2)+'');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
            lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeUpdate(new List<sObject>{sObj}); 
            
            QuoteTriggerHandler.upsertERPSite(lstQuotetoUpdate);
        }       
        Test.stopTest();
    }
      
    //Insert the qoute with the related contact value populated and Amendment type of the Quote
    @isTest
    static void cloneRTMPartnerAccountTest1() {
       
        User userObj = [select Id, Name from User where Name = 'Deployment master' and IsActive = true limit 1];
        System.runAs(userObj){
            Test.startTest();
            
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.executeQuery('Select Id, Territory2Id from Opportunity limit 5');

            List<Contract> lContract = (List<Contract>) UtilityTest.executeQuery('Select Id from Contract Limit 1');
            List<Order> lOrder = (List<Order>) UtilityTest.executeQuery('Select Id from Order Limit 1');
            List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.executeQuery('Select Id, Name, SBQQ__SubscriptionTerm__c, Territory__c, SBQQ__EndDate__c, SBQQ__StartDate__c from SBQQ__Quote__c Where INFA_Signature_Blocks__c = \'1\'  Limit 1');
            system.assertEquals(lQuote.size(),1);
            
            sObject sObj = new Contract(id = lContract[0].Id, SBQQ__Order__c = lOrder[0].Id, SBQQ__Quote__c = lQuote[0].Id);
            List<Contract> lContractUpdate = (List<Contract>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            
            sObject sObj1 = new Opportunity(id = lOpportunity[0].Id, SBQQ__RenewedContract__c = lContract[0].Id );
            sObject sObj2 = new Opportunity(id = lOpportunity[1].Id, SBQQ__RenewedContract__c = lContract[0].Id );
            sObject sObj3 = new Opportunity(id = lOpportunity[2].Id, SBQQ__RenewedContract__c = lContract[0].Id );
            sObject sObj4 = new Opportunity(id = lOpportunity[3].Id, SBQQ__RenewedContract__c = lContract[0].Id );
            sObject sObj5 = new Opportunity(id = lOpportunity[4].Id, SBQQ__RenewedContract__c = lContract[0].Id );
            List<Opportunity> lOpptyUpdate = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj1, sObj2, sObj3, sObj4, sObj5});       
            
            sObject sObjAcc = new Account();
            UtilityTestData.mAccountData.put('RecordTypeId', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId());
            sObjAcc = UtilityTest.putFieldRecord(sObjAcc, UtilityTestData.mAccountData);  
            List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObjAcc});
            
            sObj3 = new SBQQ__Quote__c(Related_Contract__c = lContract[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[0].Id + '');
            UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c', System.Today() + '');
            sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mSBQuoteData);
    
            sObject sObj6 = new RTM_Partner_Account__c();
            UtilityTestData.mPartnerAccountData.put('Partner_Account__c', lAccount[0].Id);
            UtilityTestData.mPartnerAccountData.put('Quote__c',lQuote[0].Id);
            sObj6 = UtilityTest.putFieldRecord(sObj6, UtilityTestData.mPartnerAccountData);
            List<RTM_Partner_Account__c> lRTMPartnerAccount = (List<RTM_Partner_Account__c>) UtilityTest.makeInsert(new List<sObject>{sObj6});
            
            UtilityTestData.mSBQuoteData.put('SBQQ__Type__c', 'Amendment');
            UtilityTestData.mSBQuoteData.put('SBQQ__SubscriptionTerm__c', '12');
            UtilityTestData.mSBQuoteData.put('SBQQ__EndDate__c', System.today().addDays(365)+'');
            UtilityTestData.mSBQuoteData.put('SBQQ__PaymentTerms__c', 'Net 30');
            UtilityTestData.mSBQuoteData.put('SBQQ__ShippingName__c', 'Quote Shipping Name');
            UtilityTestData.mSBQuoteData.put('Shipping_Email__c', 'testmail@test.com');
            UtilityTestData.mSBQuoteData.put('SBQQ__Status__c', 'Approved');
            UtilityTestData.mSBQuoteData.put('BillingAddress_PSFTID__c', 'Billing Address');
            UtilityTestData.mSBQuoteData.put('EditLinesFieldSetName__c', 'Standard');
            UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunity[4].Id + '');
            UtilityTestData.mSBQuoteData.put('SBQQ__MasterContract__c',lContract[0].Id + '');
            UtilityTestData.mSBQuoteData.put('CurrencyIsoCode', 'USD');
            UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'True');           
            sObj4 = new SBQQ__Quote__c(Related_Contract__c = lContract[0].Id); 
            sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mSBQuoteData);
            List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj3, sObj4});                       
            System.AssertEquals(lSBQuote.size(),2);
            
            List<RTM_Partner_Account__c> lRTMPartnerAccount1 = [Select Id, Tier__c from RTM_Partner_Account__c where Quote__c =: lSBQuote[0].Id];
            System.AssertEquals(lRTMPartnerAccount1.size(),1);
            Test.stopTest();        
        }
    }
    
    @isTest
    static void materialRightstest(){
        User userObj = [select Id, Name from User where Name = 'Deployment master' and IsActive = true limit 1];
        System.runAs(userObj){
            Test.startTest();
            List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.executeQuery('Select Id, Apply_PO_to_All_Lines__c,Name, SBQQ__SubscriptionTerm__c, Territory__c, SBQQ__EndDate__c, SBQQ__StartDate__c from SBQQ__Quote__c Limit 1');
          
            List<String> recordIdList = new List<String>();
            recordIdList.add(lQuote[0]?.Id);
            CheckMaterialRights.checkmaterialRightsMethod(recordIdList);
            CheckMaterialRights.checkmaterialRightsFuture(recordIdList);
            Test.stopTest();
        }
    }
    
    @isTest
    static void quoteDeletetest(){
        User userObj = [select Id, Name from User where Name = 'Deployment master' and IsActive = true limit 1];
        System.runAs(userObj){
            Test.startTest();
            SBQQ__Quote__c lQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
            try{
                delete lQuote;
            }catch(exception e){
                
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void quoteDeletetest2(){
        User userObj = [select Id, Name from User where Name = 'Deployment master' and IsActive = true limit 1];
        System.runAs(userObj){
            Test.startTest();
            SBQQ__Quote__c lQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
            
            Global_Config__c settings = Global_Config__c.getOrgDefaults();
            settings.Mute_Triggers__c = true;
            upsert settings Global_Config__c.Id;
            
            try{
                delete lQuote;
            }catch(exception e){
                
            }
            Test.stopTest();
        }
    }
    @isTest
    static void validateEndDateOnEarlyRenewaltest(){
        User userObj = [select Id, Name from User where Name = 'Deployment master' and IsActive = true limit 1];
        System.runAs(userObj){
            Test.startTest();
            SBQQ__Quote__c lQuote = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__MasterContract__c != null LIMIT 1];
            lQuote.Amend_Type__c = 'Early Renewal - Extend End Date';
            lQuote.SBQQ__Status__c = 'In Review';
            try{
                update lQuote;
            }catch(exception e){
                
            }
            Test.stopTest();
        }
    }    
}