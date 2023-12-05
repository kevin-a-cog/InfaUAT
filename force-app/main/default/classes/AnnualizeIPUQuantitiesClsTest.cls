@isTest 
public with sharing class AnnualizeIPUQuantitiesClsTest {
    @testSetup
    static void setupObjectTestData() {
        User userObj = [select Id, Name from User where Name = 'Deployment master' and IsActive = true limit 1];
        System.runAs(userObj){
            Test.startTest();
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
            UtilityTestData.mProduct2Data.put('Option_Scale__c', 'Base Product');
            UtilityTestData.mProduct2Data.put('Product_Category__c', 'Add-ons');
            UtilityTestData.mProduct2Data.put('GTM_Model__c', System.Label.IPU_Product_GTM_Value);
            UtilityTestData.mProduct2Data.put('Product_Description_Schedule_Text__c', 'Product_Description_Schedule_Text__c');
            
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);

            sObject sObj1 = new Product2();
            UtilityTestData.mProduct2Data.put('blng__BillingRule__c', lBillingRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c', lRevRecRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__TaxRule__c', lTaxRule[0].Id);
            UtilityTestData.mProduct2Data.put('Amoritization_Schedule__c', 'DaaS');
            UtilityTestData.mProduct2Data.put('Option_Scale__c', 'Base Product');
            UtilityTestData.mProduct2Data.put('Product_Category__c', 'Wrapper');
            UtilityTestData.mProduct2Data.put('GTM_Model__c', System.Label.IPU_Product_GTM_Value);
            UtilityTestData.mProduct2Data.put('Product_Description_Schedule_Text__c', 'Product_Description_Schedule_Text__c');
            
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProduct2Data);
            List<Product2> lProduct = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1});
            //create/update standard Pricebook1
            Id priceBookId  = Test.getStandardPricebookId();
            
            sObj = new Pricebook2(ID = priceBookId, IsActive = True);
            List<Pricebook2> lPriceBook = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            sObj = new PriceBookEntry();
            UtilityTestData.mPriceBookEntryData.put('Pricebook2Id', lPriceBook[0].Id + '');
            UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct[0].Id + '');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);

            sObj1 = new PriceBookEntry();
            UtilityTestData.mPriceBookEntryData.put('Pricebook2Id', lPriceBook[0].Id + '');
            UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct[1].Id + '');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mPriceBookEntryData);  

            List<PriceBookEntry> lPBEntry = (List<PriceBookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1});
            //System.assertEquals(lPBEntry.size(),2);        
            
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
             sObj1 = new Opportunity(Territory2Id =lTerritoryAPJ[0].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityData);        
            sObject sObj2 = new Opportunity(Territory2Id =lTerritoryEA[0].Id);
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mOpportunityData);
            
            //Below opportunities are without Territories data into it
            sObject sObj3 = new Opportunity();        
            sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mOpportunityData);
            
            sObject sObj4 = new Opportunity();        
            sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mOpportunityData);        
            
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1,sObj2,sObj3,sObj4});
            
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
            UtilityTestData.mSBQuoteData.put('Partner_Override_Default_Language__c', 'en_US');
            UtilityTestData.mSBQuoteData.put('Special_Remarks1__c', 'Testing');
            UtilityTestData.mSBQuoteData.put('Partner_Special_Remarks__c', 'Testing');
            UtilityTestData.mSBQuoteData.put('SBQQ__PaymentTerms__c', 'Net 30');
            UtilityTestData.mSBQuoteData.put('SBQQ__SubscriptionTerm__c', 30+'');
            UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[0].Id+'');
            UtilityTestData.mSBQuoteData.put('SBQQ__Account__c', lAccount[0].Id + '');
            UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c', System.Today() + '');
            UtilityTestData.mSBQuoteData.put('Quote_Description__c', 'Test quote for IPU commit recs creation');
            sObj = new SBQQ__Quote__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
            List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            sObj = new Contract();
            UtilityTestData.mContractData.put('AccountId', lAccount[0].Id);
            UtilityTestData.mContractData.put('Status','Draft');
            UtilityTestData.mContractData.put('SBQQ__Opportunity__c',lOpportunity[0].Id);
            UtilityTestData.mContractData.put('StartDate',System.today()+'');
            UtilityTestData.mContractData.put('SBQQ__Quote__c',lQuote[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContractData);
            List<Contract> lContract = (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj}); 
            Test.stopTest();
        }
    }

    @isTest
    static void insertTestQuoteTypeNew() {
        User userObj = [select Id, Name from User where Name = 'Deployment master' and IsActive = true limit 1];
        System.runAs(userObj){
            Test.startTest();
            List<SBQQ__Quote__c> quoteList= (List<SBQQ__Quote__c>) UtilityTest.executeQuery('Select Id from SBQQ__Quote__c ');
            List<Product2> prodList= (List<Product2>) UtilityTest.executeQuery('Select Id from Product2');    
            Date qlendDate = System.today().addMonths(30);
            sObject sObj = new SBQQ__QuoteLine__c();
            sObject sObj1 = new SBQQ__QuoteLine__c();
            sObject sObj2 = new SBQQ__QuoteLine__c();
            sObject sObj3 = new SBQQ__QuoteLine__c();
            //NA
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', prodList[0].Id);
            UtilityTestData.mQuoteLineData.put('Product_Category__c', 'Wrapper');
            UtilityTestData.mQuoteLineData.put('End_Date_Output_QL__c', qlendDate+'');
            
            sObj = new SBQQ__QuoteLine__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
            
            //NA
            sObj1 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__EndDate__c', System.Today() + '');
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', prodList[1].Id);
            UtilityTestData.mQuoteLineData.put('End_Date_Output_QL__c', qlendDate+'');
            UtilityTestData.mQuoteLineData.put('Product_Category__c', 'Add-ons');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
            
            sObj2 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__EndDate__c', System.Today() + '');
            UtilityTestData.mQuoteLineData.put('End_Date_Output_QL__c', qlendDate+'');
            UtilityTestData.mQuoteLineData.put('Product_Category__c', 'Add-ons');
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', prodList[1].Id);
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);             
            List<SBQQ__QuoteLine__c> lQuoteLI = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1, sObj2});
            AnnualizeIPUQuantitiesCls ac = new AnnualizeIPUQuantitiesCls();
            AnnualizeIPUQuantitiesCls.prorateMultiplierVal = 2.5;
            ac.createAnnualCommitments(quoteList[0].Id);
            List<IPU_Annual_Commitment__c> ipuac = [select Id from IPU_Annual_Commitment__c where Quote__c = :quoteList[0].Id];
            System.assertEquals(ipuac.size(), 3);
            Test.stopTest();
        }
    }

    @isTest
    static void testForAmend() {
        User userObj = [select Id, Name from User where Name = 'Deployment master' and IsActive = true limit 1];
        System.runAs(userObj){
            List <Contract> contractlst = [SELECT Id FROM Contract LIMIT 1];
            List<Contact> lContact = [select id from Contact limit 1];
            List<Account> lAccount = [Select Id from Account Limit 1];
            List<Opportunity> loppty = [Select Id from Opportunity Limit 1];
            List<Product2> lProduct = [Select Id from Product2];
            Date qlendDate = System.today().addMonths(30);
            Test.startTest();
            List<SBQQ__Quote__c> quoteList= (List<SBQQ__Quote__c>) UtilityTest.executeQuery('Select Id from SBQQ__Quote__c');
            List<Product2> prodList= new List<Product2>();
            Id wrapperProdId, addOnsProdId;
            for(Product2 pr : (List<Product2>) UtilityTest.executeQuery('Select Id,Product_Category__c from Product2 where Product_Category__c in (\'Add-ons\',\'Wrapper\') order by Product_Category__c desc'))
            {
                if(pr.product_Category__c == 'Wrapper')
                {
                    wrapperProdId = pr.Id;
                }
                if(pr.product_Category__c == 'Add-Ons')
                {
                    addOnsProdId = pr.Id;
                }
            }
            sObject sObj = new SBQQ__QuoteLine__c();
            sObject sObj1 = new SBQQ__QuoteLine__c();
            sObject sObj2 = new SBQQ__QuoteLine__c();
            sObject sObj3 = new SBQQ__QuoteLine__c();
            //NA
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', wrapperProdId);//lProduct[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c', '12');
            UtilityTestData.mQuoteLineData.put('Product_Category__c', 'Wrapper');
            UtilityTestData.mQuoteLineData.put('End_Date_Output_QL__c', qlendDate+'');
            sObj = new SBQQ__QuoteLine__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
            
            //NA
            sObj1 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__EndDate__c', System.Today() + '');
            UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c', '12');
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', addOnsProdId);
            UtilityTestData.mQuoteLineData.put('Product_Category__c', 'Add-ons');
            UtilityTestData.mQuoteLineData.put('End_Date_Output_QL__c', qlendDate+'');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
            
            sObj2 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__EndDate__c', System.Today() + '');
            UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c', '12');
            UtilityTestData.mQuoteLineData.put('Product_Category__c', 'Add-ons');
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', addOnsProdId);
            UtilityTestData.mQuoteLineData.put('End_Date_Output_QL__c', qlendDate+'');
            //UtilityTestData.mQuoteLineData.Remove('SBQQ__SubscriptionTerm__c');
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);
            
            sObj3 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', quoteList[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__EndDate__c', System.Today() + '');
            UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c', '12');
            UtilityTestData.mQuoteLineData.put('Product_Category__c', 'Add-ons');
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', addOnsProdId);
            UtilityTestData.mQuoteLineData.put('End_Date_Output_QL__c', qlendDate+'');
            sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lQuoteLI = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1, sObj2,sObj3});
            lQuoteLI[1].SBQQ__RequiredBy__c = lQuoteLI[0].Id;
            lQuoteLI[2].SBQQ__RequiredBy__c = lQuoteLI[0].Id;
            lQuoteLI[3].SBQQ__RequiredBy__c = lQuoteLI[0].Id;
            update lQuoteLI;
            
            sObject sObjSBQQSubscription = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c', wrapperProdId);//lProduct[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',contractlst[0].ID);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__EndDate__c',qlendDate+'');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','10');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lQuoteLI[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',qlendDate+'');
            UtilityTestData.mSBQQSubscriptionData.put('Product_Category__c','Add-ons');
            sObjSBQQSubscription = UtilityTest.putFieldRecord(sObjSBQQSubscription,UtilityTestData.mSBQQSubscriptionData);
            
            sObject sObjSBQQSubscription1 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c', addOnsProdId);//lProduct[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',contractlst[0].ID);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__EndDate__c',qlendDate+'');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','10');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lQuoteLI[1].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',qlendDate+'');
            sObjSBQQSubscription1 = UtilityTest.putFieldRecord(sObjSBQQSubscription1, UtilityTestData.mSBQQSubscriptionData);
            sObject sObjSBQQSubscription2 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c', addOnsProdId);//lProduct[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',contractlst[0].ID);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__EndDate__c',qlendDate+'');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','10');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lQuoteLI[2].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',qlendDate+'');
            sObjSBQQSubscription2 = UtilityTest.putFieldRecord(sObjSBQQSubscription2, UtilityTestData.mSBQQSubscriptionData);
            
            List<SBQQ__Subscription__c > sbbqSubscriptionlst  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObjSBQQSubscription, sObjSBQQSubscription1, sObjSBQQSubscription2});
			sbbqSubscriptionlst[1].SBQQ__RequiredById__c = sbbqSubscriptionlst[0].Id;
            sbbqSubscriptionlst[2].SBQQ__RequiredById__c = sbbqSubscriptionlst[0].Id;
            update sbbqSubscriptionlst;
            UtilityTestData.mSBQuoteData.put('SoldToAccount__c', lAccount[0].Id + '');
            UtilityTestData.mSBQuoteData.put('ShiptToAccount__c', lAccount[0].Id + '');
            UtilityTestData.mSBQuoteData.put('BillToAccount__c', lAccount[0].Id + '');
            UtilityTestData.mSBQuoteData.put('EndUserAccount__c', lAccount[0].Id + '');
            UtilityTestData.mSBQuoteData.put('SoldToContact__c', lContact[0].Id + '');
            UtilityTestData.mSBQuoteData.put('EndUserContact__c', lContact[0].Id + '');
            UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'true');        
            UtilityTestData.mSBQuoteData.put('CurrencyIsoCode', 'USD');  // Currency updated
            UtilityTestData.mSBQuoteData.put('SBQQ__Type__c', 'Amendment');
            UtilityTestData.mSBQuoteData.put('Route_To_Market__c', 'Market Place Private');
            UtilityTestData.mSBQuoteData.put('Detail_RTM__c', 'Amazon AWS via Partner');
            UtilityTestData.mSBQuoteData.put('Override_Default_Language__c', 'en_US');
            UtilityTestData.mSBQuoteData.put('Partner_Override_Default_Language__c', 'en_US');
            UtilityTestData.mSBQuoteData.put('Special_Remarks1__c', 'Testing');
            UtilityTestData.mSBQuoteData.put('Partner_Special_Remarks__c', 'Testing');
            UtilityTestData.mSBQuoteData.put('SBQQ__PaymentTerms__c', 'Net 30');
            UtilityTestData.mSBQuoteData.put('SBQQ__SubscriptionTerm__c', 30+'');
            UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', loppty[0].Id+'');
            UtilityTestData.mSBQuoteData.put('SBQQ__Account__c', lAccount[0].Id + '');
            UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c', System.Today() + '');
            UtilityTestData.mSBQuoteData.put('Quote_Description__c', 'Test quote for IPU commit recs creation');
            sObj = new SBQQ__Quote__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
            List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            Test.stopTest();
            sObj = new SBQQ__QuoteLine__c();
            sObj1 = new SBQQ__QuoteLine__c();
            sObj2 = new SBQQ__QuoteLine__c();
            sObj3 = new SBQQ__QuoteLine__c();
            //NA
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', lQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', wrapperProdId);//lProduct[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c', '12');
            UtilityTestData.mQuoteLineData.put('Product_Category__c', 'Wrapper');
            UtilityTestData.mQuoteLineData.put('End_Date_Output_QL__c', qlendDate+'');
            UtilityTestData.mQuoteLineData.put('SBQQ__UpgradedSubscription__c', sbbqSubscriptionlst[0].Id+'');
            sObj = new SBQQ__QuoteLine__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
            
            //NA
            sObj1 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', lQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__EndDate__c', System.Today() + '');
            UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c', '12');
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', addOnsProdId);//lProduct[0].Id);
            UtilityTestData.mQuoteLineData.put('Product_Category__c', 'Add-ons');
            UtilityTestData.mQuoteLineData.put('End_Date_Output_QL__c', qlendDate+'');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
            UtilityTestData.mQuoteLineData.put('SBQQ__UpgradedSubscription__c', sbbqSubscriptionlst[1].Id+'');
            
            sObj2 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', lQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__EndDate__c', System.Today() + '');
            UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c', '12');
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', addOnsProdId);//lProduct[0].Id);
            UtilityTestData.mQuoteLineData.put('Product_Category__c', 'Add-ons');
            UtilityTestData.mQuoteLineData.put('End_Date_Output_QL__c', qlendDate+'');
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);
            UtilityTestData.mQuoteLineData.put('SBQQ__EffectiveQuantity__c', -100+'');
            
            sObj3 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', lQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__EndDate__c', System.Today() + '');
            UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c', '12');
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', addOnsProdId);//lProduct[0].Id);
            UtilityTestData.mQuoteLineData.put('Product_Category__c', 'Add-ons');
            UtilityTestData.mQuoteLineData.put('End_Date_Output_QL__c', qlendDate+'');
            UtilityTestData.mQuoteLineData.put('SBQQ__EffectiveQuantity__c', 100+'');
            
            sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mQuoteLineData);
            Sobject sObj4 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c', lQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__EndDate__c', System.Today() + '');
            UtilityTestData.mQuoteLineData.put('SBQQ__SubscriptionTerm__c', '12');
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c', addOnsProdId);//lProduct[0].Id);
            UtilityTestData.mQuoteLineData.put('Product_Category__c', 'Add-ons');
            UtilityTestData.mQuoteLineData.put('End_Date_Output_QL__c', qlendDate+'');
            UtilityTestData.mQuoteLineData.put('SBQQ__UpgradedSubscription__c', sbbqSubscriptionlst[2].Id+'');
            
            sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mQuoteLineData);
                        
            lQuoteLI = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1, sObj2, sobj3, sObj4});
            lQuoteLI[1].SBQQ__RequiredBy__c = lQuoteLI[0].Id;
            lQuoteLI[2].SBQQ__RequiredBy__c = lQuoteLI[0].Id;
            lQuoteLI[3].SBQQ__RequiredBy__c = lQuoteLI[0].Id;
            lQuoteLI[2].SBQQ__UpgradedSubscription__c = sbbqSubscriptionlst[1].Id;
            lQuoteLI[2].SBQQ__UpgradedSubscription__c = null;
            lQuoteLI[3].SBQQ__UpgradedSubscription__c = null;
            update lQuoteLI; 
            AnnualizeIPUQuantitiesCls ac = new AnnualizeIPUQuantitiesCls();
            AnnualizeIPUQuantitiesCls.prorateMultiplierVal = 2.5;
            ac.createAnnualCommitments(lQuote[0].Id);
            List<IPU_Annual_Commitment__c> ipuac = [select Id from IPU_Annual_Commitment__c where Quote__c = :lQuote[0].Id];
            System.assertEquals(ipuac.size(), 6);
        }
    }
}