@isTest
public class InfaSalesUtilityTest {
    
    @TestSetup
    static void setup(){

        sObject  sObj;
        //Billing rule data
        sObj = new blng__BillingRule__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngBillingRuleData);
        List<blng__BillingRule__c> lBillingRule = (List<blng__BillingRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new blng__RevenueRecognitionRule__c();
        sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mblngRevRecRuleData);
        List<blng__RevenueRecognitionRule__c> lRevRecRule = (List<blng__RevenueRecognitionRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});    
        
        sObj = new blng__TaxRule__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngTaxRuleData);
        List<blng__TaxRule__c> lTaxRule = (List<blng__TaxRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

        sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
        UtilityTestData.mAccountData.put('BillingCountry','United States');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mContactData.put('MailingCountry','United States');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});

        IPUE_TestUtils.setupAllData();
        IPUE_TestUtils.setupFormData();

        Opportunity testOpp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        testOpp.SubStage__c = 'Sales Won';
        testOpp.Competitive_Replacement__c = 'Unknown';
        testOpp.Economic_Buyer__c = 'test';
        testOpp.Decision_Criteria__c =  'test';
        testOpp.Decision_Process__c =  'test';
        testOpp.BANT_Qualification__c =  'Unknown';
        testOpp.Champion__c =  'Unknown';
        testOpp.Competitors__c =  'Alation';
        testOpp.Technology_Ecosystem__c =  'Amazon Web Services';
        testOpp.Delivery__c =  'IPS Implementation';
        testOpp.Incumbent_Competitors__c =  'Alation';
        update testOpp;

        Estimation_Summary__c testSummary = IPUE_TestUtils.createEstimationSummary(false, testOpp.Id);
        Form__c testForm = [SELECT Id FROM Form__c LIMIT 1];
        testSummary.Form__c = testForm.Id;
        testSummary.Account__c = testOpp.AccountId;
        testSummary.Primary__c = true;
        insert testSummary;    

        // sObj = new SBQQ__Quote__c();
        // UtilityTestData.mSBQuoteData.put('SoldToAccount__c', lAccount[0].Id + '');
        // UtilityTestData.mSBQuoteData.put('ShiptToAccount__c', lAccount[0].Id + '');
        // UtilityTestData.mSBQuoteData.put('BillToAccount__c', lAccount[0].Id + '');
        // UtilityTestData.mSBQuoteData.put('EndUserAccount__c', lAccount[0].Id + '');
        // UtilityTestData.mSBQuoteData.put('SoldToContact__c', lContact[0].Id + '');
        // UtilityTestData.mSBQuoteData.put('EndUserContact__c', lContact[0].Id + '');
        // UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'true');        
        // UtilityTestData.mSBQuoteData.put('CurrencyIsoCode', 'USD');  // Currency updated
        // UtilityTestData.mSBQuoteData.put('SBQQ__Type__c', 'Quote');
        // UtilityTestData.mSBQuoteData.put('Route_To_Market__c', 'Market Place Private');
        // UtilityTestData.mSBQuoteData.put('Detail_RTM__c', 'Amazon AWS via Partner');
        // UtilityTestData.mSBQuoteData.put('Override_Default_Language__c', 'en_US');
        // UtilityTestData.mSBQuoteData.put('Partner_Override_Default_Language__c', 'en_US');
        // UtilityTestData.mSBQuoteData.put('Special_Remarks1__c', 'Testing');
        // UtilityTestData.mSBQuoteData.put('Partner_Special_Remarks__c', 'Testing');
        
        // Sobject sobj2 = new SBQQ__Quote__c();
        // UtilityTestData.mSBQuoteData.put('Price_Holds__c', 'true');   
        // sobj2 = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);

        
        // UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c', System.Today() + '');        
        // sObj = new SBQQ__Quote__c();
        // sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        // List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

        String productMapString = System.Label.IpuWarningProductMap;
        /*Map<String,String> ipuTypeToProductId = new Map<String,String>();
        for(String prodLiteral : productMapString.split(',')){

            List<String> productMap = prodLiteral.split('-');
            
            if(!ipuTypeToProductId.containsKey(productMap[0])){
                ipuTypeToProductId.put(productMap[0],productMap[1]);
            }
        }*/
        
        sObj = new SBQQ__DiscountSchedule__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mDisSch);
        Sobject sObj3 = new SBQQ__DiscountSchedule__c();
        sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mDisSch);

        List<SBQQ__DiscountSchedule__c> lDisSch = (List<SBQQ__DiscountSchedule__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj3});

        sObj = new Product2();
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c', lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c', lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c', lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('Amoritization_Schedule__c', 'DaaS');
        UtilityTestData.mProduct2Data.put('External_Id__c', productMapString);
        UtilityTestData.mProduct2Data.put('GTM_Model__c','IPU' );
        UtilityTestData.mProduct2Data.put('Name', 'Flex');
        UtilityTestData.mProduct2Data.put('SBQQ__DiscountSchedule__c',lDisSch[0].Id);
        UtilityTestData.mProduct2Data.put('External_Id__c',productMapString);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);

        sObj3 = new Product2();
        UtilityTestData.mProduct2Data.put('GTM_Model__c','Flex IPU' );
        UtilityTestData.mProduct2Data.put('Name', 'IPU1');
        UtilityTestData.mProduct2Data.put('SBQQ__DiscountSchedule__c',lDisSch[0].Id);
        sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mProduct2Data);

        List<Product2> lProduct = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj});
    }

    @IsTest
    private static void recalculateIpuWarningsTest1(){

        List<SBQQ__Quote__c> lQuote = [SELECT Id,SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE SBQQ__Primary__c = true LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'Flex'];

        Sobject sObj = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',prod.Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
        List<SBQQ__QuoteLine__c> lSBQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

        Test.startTest();
            InfaSalesUtility.recalculateIpuWarnings(new List<Id>{lQuote[0].SBQQ__Opportunity2__c});
        Test.stopTest();
    }

    @IsTest
    private static void recalculateIpuWarningsTest2(){

        List<SBQQ__Quote__c> lQuote = [SELECT Id,SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE SBQQ__Primary__c = true LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'Flex'];

        Sobject sObj = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',prod.Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
        List<SBQQ__QuoteLine__c> lSBQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        Test.startTest();
        lQuote[0].SBQQ__Primary__c = false;
        lQuote[0].Price_Holds__c = true;
        update lQuote[0];
        InfaSalesUtility.recalculateIpuWarnings(new List<Id>{lQuote[0].SBQQ__Opportunity2__c});
        Test.stopTest();
    }
}