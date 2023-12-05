/***************************************************************************
*        Name        :        CreateEntitlementPerAssetTest
*        Author      :        Anil  Solanki
*        Date        :        21 January 2020
*        Description :        Test class for CreateEntitlementPerAsset
****************************************************************************

Change History
*********************************************************************************************************************************
ModifiedBy          Date          Requested By         JIRA#              Description                                          Tag
*********************************************************************************************************************************
Ambica Pyati        1/15/2020     Sarojini            F2A-223    Create all enetitlements after Contarct  

*********************************************************************************************************************************
*/

@isTest
public class CreateEntitlementPerAssetTest {
    
    @testSetup
    static void setupObjectTestData() {

        User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1];
        
        system.runAs(adminUser){
            sObject sObj = new blng__BillingRule__c();
            sObject sObj1 = new blng__BillingRule__c();
            sObject sObj2 = new blng__BillingRule__c();
            
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
            
            sObj = new blng__BillingRule__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngBillingRuleData);
            List<blng__BillingRule__c> lBillingRule = (List<blng__BillingRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new blng__RevenueRecognitionRule__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngRevRecRuleData);
            List<blng__RevenueRecognitionRule__c> lRevRecRule = (List<blng__RevenueRecognitionRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new blng__TaxRule__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngTaxRuleData);
            List<blng__TaxRule__c> lTaxRule = (List<blng__TaxRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            
            sObj = new Product2();
            UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
            UtilityTestData.mProduct2Data.put('SBQQ__AssetConversion__c','One per unit');
            UtilityTestData.mProduct2Data.put('Generates_Entitlement__c','true');
            UtilityTestData.mProduct2Data.put('Product_Family__c','Support');
            
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
            
            sObj1 = new Product2();
            UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
            UtilityTestData.mProduct2Data.put('SBQQ__AssetConversion__c','One per quote line');
            UtilityTestData.mProduct2Data.put('Generates_Entitlement__c','true');/** Test**/
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProduct2Data);
            
            sObj2 = new Product2();
            UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
            UtilityTestData.mProduct2Data.put('SBQQ__AssetConversion__c','One per unit');
            UtilityTestData.mProduct2Data.put('Generates_Entitlement__c','true');/** Test**/
            UtilityTestData.mProduct2Data.put('CPQ_Product_Type__c','Perpetual');
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mProduct2Data);
            List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
            Id pricebookId = Test.getStandardPricebookId();         
            
            sObj = new Pricebook2(Id = pricebookId,IsActive = True);
            //sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPricebook2Data);
            List<Pricebook2> lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            
            sObj = new pricebookEntry();
            UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',lPriceBook2[0].Id);
            UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);
            
            sObj1 = new pricebookEntry();
            UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',lPriceBook2[0].Id);
            UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[1].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mPriceBookEntryData);
            
            /**sObj2 = new pricebookEntry();
            UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',lPriceBook2[0].Id);
            UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[2].Id);
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mPriceBookEntryData);**/
            
            List<pricebookEntry> lPriceBookEntry = (List<pricebookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
            User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
            settings.Ignore_Validation_Rules__c = true;
            upsert settings User_Exemptions__c.Id;
            
            sObj = new Account();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
            List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new Contact();
            UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            
            sObj = new Opportunity();
            UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mOpportunityData.put('Type','Direct');
            UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
            UtilityTestData.mOpportunityData.put('StageName','Closed Won');
            UtilityTestData.mOpportunityData.put('Pricebook2Id',priceBookId);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            Test.startTest();
            //lOpportunity[0].Pricebook2Id = priceBookId;
            //update lOpportunity[0];
            
            sObj = new SBQQ__Quote__c();
            UtilityTestData.mSBQuoteData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c', lOpportunity[0].Id + '');
            UtilityTestData.mSBQuoteData.put('SBQQ__PricebookId__c',priceBookId);
            UtilityTestData.mSBQuoteData.put('SBQQ__PriceBook__c',priceBookId);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
            List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            
            sObj1 = new SBQQ__Quote__c(Id = lSBQuote[0].Id ,SBQQ__Status__c = 'Approved', ApprovalStatus__c='Approved', ShiptToAccount__c=lAccount[0].Id, BillToAccount__c=lAccount[0].Id, EndUserAccount__c=lAccount[0].Id, SoldToAccount__c=lAccount[0].Id, EndUserContact__c=lContact[0].Id, BillToContact__c=lContact[0].Id, ShipToContact__c=lContact[0].Id, SoldToContact__c=lContact[0].Id); //<T1> Last two arguments);
            List<SBQQ__Quote__c> lQuoteUpdated = (List<SBQQ__Quote__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            system.assertEquals(lQuoteUpdated.size(),1);
            
            sObj = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuoteUpdated[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[0].Id);
            UtilityTestData.mQuoteLineData.put('Purchase_Order_PO_Number__c','1');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','2');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
            
            sObj1 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lQuoteUpdated[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[1].Id);
            UtilityTestData.mQuoteLineData.put('Purchase_Order_PO_Number__c','1');
            UtilityTestData.mQuoteLineData.put('SBQQ__RequiredBy__c',null);
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','2');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lSBQuoteLine1 = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            Test.stopTest();
        }
    }
    
    //Method to test handle Asset
    static testMethod void handleAssetTest() {
        
        
        //User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true AND Name = 'Deployment Master' LIMIT 1];
        //System.debug('@CreateEntitlementPerAsset -> handleAssetTest -> Outside Starting -> SOQL: '+Limits.getQueries());
        sObject sObj;
        sObject sObj1;
        
        //system.runAs(adminUser){
            
            List<Account> lAccount =[Select Id from Account]; 
            
            List<Product2> lProduct2 =[Select Id,Generates_Entitlement__c from Product2 ];
            
            List<SBQQ__Quote__c> lQuote = [Select Id,(Select Id,SBQQ__Product__r.Product_Family__c,SBQQ__Quantity__c,SBQQ__RequiredBy__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c,
            SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c,SBQQ__RequiredBy__c 
            from SBQQ__LineItems__r) from SBQQ__Quote__c LIMIT 1];
            
            
            /*List<SBQQ__QuoteLine__c> lQuoteLine = [Select Id,SBQQ__Product__r.Product_Family__c,SBQQ__Quantity__c,SBQQ__RequiredBy__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c,
                                                   SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c,SBQQ__RequiredBy__c 
                                                   from SBQQ__QuoteLine__c ];*/
            List<SBQQ__QuoteLine__c> lQuoteLine = lQuote[0].SBQQ__LineItems__r;
            
            sObj = new SBQQ__Quote__c(Id = lQuote[0].id ,SBQQ__Ordered__c = True);
            //System.debug('@CreateEntitlementPerAsset -> handleAssetTest -> Outside Pause -> SOQL: '+Limits.getQueries());
            //System.debug('@CreateEntitlementPerAsset -> handleAssetTest -> Test.startTest Starting -> SOQL: '+Limits.getQueries());
            Test.startTest();
            List<SBQQ__Quote__c> lQuoteUpdated1 = (List<SBQQ__Quote__c>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            system.assertEquals(lQuoteUpdated1.size(),1);
            
            system.debug('@@lProduct2'+lProduct2);
            lProduct2[0].Generates_Entitlement__c=true;
            lProduct2[1].Generates_Entitlement__c=true;
            update lProduct2;
            system.debug('@@lProduct2-V2'+lProduct2);
            
            List<Order> lOrder = [Select Id,(Select Id,Product2.Generates_Entitlement__c,SBQQ__QuoteLine__c,
            SBQQ__QuoteLine__r.SBQQ__Quantity__c ,SBQQ__QuoteLine__r.Related_Asset__c,
            SbQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c,
            SbQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c,
            SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Family__c,
            SBQQ__QuoteLine__r.Related_Asset__r.SBQQ__QuoteLine__c from OrderItems) from Order];
            
            
            
            /*List<OrderItem> lOrderItem = [Select Id,Product2.Generates_Entitlement__c,SBQQ__QuoteLine__c,
                                          SBQQ__QuoteLine__r.SBQQ__Quantity__c ,SBQQ__QuoteLine__r.Related_Asset__c,
                                          SbQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c,
                                          SbQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c,
                                          SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Family__c,
                                          SBQQ__QuoteLine__r.Related_Asset__r.SBQQ__QuoteLine__c from OrderItem];*/
            List<OrderItem> lOrderItem = lOrder[0].OrderItems;
            System.debug('@@@@@OrderProducts' + lOrderItem.size() + '@@@@@@@Details' +lOrderItem);
            
            
            sObj = new Contract(StartDate = System.Today().addDays(-300));
            UtilityTestData.mContractData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mContractData.put('SBQQ__Order__c',lOrder[0].Id);
            UtilityTestData.mContractData.put('SBQQ__Quote__c',lQuote[0].Id);
            UtilityTestData.mContractData.put('StartDate', System.Today().addDays(-300)+'');
            UtilityTestData.mContractData.put('EndDate',System.Today().addDays(100)+'');
            UtilityTestData.mContractData.put('ContractTerm','10');
            sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mContractData);
            List<Contract> lContract  =  (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});
            //Test.startTest();
            sObj = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','2');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lQuoteLine[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',lOrderItem[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mSBQQSubscriptionData);
            List<SBQQ__Subscription__c > lSubscription1  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            System.debug('@@@@@lSubscription1' + lSubscription1.size() + '@@@@@@@Details' +lSubscription1);
            
            sObj1 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','2');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lQuoteLine[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',lOrderItem[1].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RequiredById__c',lSubscription1[0].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1,UtilityTestData.mSBQQSubscriptionData);
            List<SBQQ__Subscription__c > lSubscription2  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj1});
            
            lSubscription2[0].SBQQ__RootId__c = lSubscription2[0].Id;
            update lSubscription2[0];
            System.debug('@@@@@lSubscription2' + lSubscription2.size() + '@@@@@@@Details' +lSubscription2);
            
            lQuoteLine[0].SBQQ__RenewedSubscription__c = lSubscription1[0].Id;
            lQuoteLine[1].SBQQ__RequiredBy__c = lQuoteLine[0].Id;
            lQuoteLine[0].SBQQ__Quantity__c=2;
            lQuoteLine[1].SBQQ__Quantity__c=2;
            update lQuoteLine;
            
            sObj = new Asset();
            UtilityTestData.mAssetData.put('Name','Test Asset1');
            UtilityTestData.mAssetData.put('Status','Provisioning Complete');
            UtilityTestData.mAssetData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mAssetData.put('Product2Id',lProduct2[0].Id);
            UtilityTestData.mAssetData.put('SBQQ__OrderProduct__c',lOrderItem[0].Id);
            UtilityTestData.mAssetData.put('SBQQ__CurrentSubscription__c',lSubscription1[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAssetData); 
            
            sObj1 = new Asset();
            UtilityTestData.mAssetData.put('Name','Test Asset1');
            UtilityTestData.mAssetData.put('Status','Provisioning Complete');
            UtilityTestData.mAssetData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mAssetData.put('Product2Id',lProduct2[1].Id);
            UtilityTestData.mAssetData.put('SBQQ__OrderProduct__c',lOrderItem[1].Id);
            UtilityTestData.mAssetData.put('SBQQ__CurrentSubscription__c',lSubscription2[0].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAssetData); 
            List<Asset > lAsset  =  (List<Asset>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            System.debug('@@@@@lAsset' + lAsset.size() + '@@@@@@@Details' +lAsset);
            
            List<SBQQ__Subscription__c> SubscList = [Select Id, Name ,SBQQ__StartDate__c, SBQQ__EndDate__c,SBQQ__Quantity__c,
                                                                                              SBQQ__Account__c,  
                                                                                              SBQQ__RootId__c,
                                                                                              SBQQ__RequiredById__c,
                                                                                              SBQQ__Product__r.Name,
                                                                                              SBQQ__OrderProduct__c,
                                                                                              SBQQ__OrderProduct__r.ServiceDate,
                                                                                              SBQQ__OrderProduct__r.EndDate,
                                                                                              SBQQ__OrderProduct__r.product2.Name,
                                                                                              SBQQ__OrderProduct__r.product2.Product_family__c,
                                                                                              SBQQ__OrderProduct__r.product2.Generates_Entitlement__c ,
                                                                                              SBQQ__Product__r.Generates_Entitlement__c, 
                                                                                              SBQQ__OrderProduct__r.SBQQ__QuoteLine__c,  
                                                                                              SBQQ__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Family__c,    
                                                                                              SBQQ__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__Quantity__c,
                                                                                              SBQQ__OrderProduct__r.SbQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c,
                                                                                              SBQQ__OrderProduct__r.SbQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c from SBQQ__Subscription__c];
            
            
            System.debug('@@@@@SubscList' + SubscList.size() + '@@@@@@@Details' +SubscList);
            Map<Id, SBQQ__Subscription__c> MapSubAsset = new Map<Id, SBQQ__Subscription__c>();
            
            
            MapSubAsset.put(lAsset[0].Id, SubscList[0]);
            MapSubAsset.put(lAsset[1].Id, SubscList[1]);
            
            List<Contract> contractList = [Select Id from Contract];
            //System.debug('@CreateEntitlementPerAsset -> handleAssetTest -> Test.stopTest Ending -> SOQL: '+Limits.getQueries());
            Test.stopTest();
            //System.debug('@CreateEntitlementPerAsset -> handleAssetTest -> Outside Restart -> SOQL: '+Limits.getQueries());
            List<Entitlement> lstEntitlements = CreateEntitlementPerAsset.getEntitlement(contractList, MapSubAsset);
            if(lstEntitlements.size() > 0){
                upsert lstEntitlements;
            }  
            //Test.stopTest();
            List<Entitlement> lEntitlement = [Select id, name from Entitlement];
            //System.debug('@CreateEntitlementPerAsset -> handleAssetTest -> Outside Ending -> SOQL: '+Limits.getQueries());
            System.debug('@@@@@lEntitlement' + lEntitlement.size() + '@@@@@@@Details' +lEntitlement); 
            
            
        //}
    }
    
	//Method to test handle Asset
    static testMethod void createEntitlementTest() {
        
        
        //User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true AND Name = 'Deployment Master' LIMIT 1];
        
        sObject sObj;
        sObject sObj1;
        
        //system.runAs(adminUser){
            //Test.startTest();
            List<Account> lAccount =[Select Id from Account]; 
            
            List<Product2> lProduct2 =[Select Id,Generates_Entitlement__c from Product2 ];
            
            List<SBQQ__Quote__c> lQuote = [Select Id,(Select Id,SBQQ__Product__r.Product_Family__c,SBQQ__Quantity__c,SBQQ__RequiredBy__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c,
            SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c,SBQQ__RequiredBy__c 
            from SBQQ__LineItems__r) from SBQQ__Quote__c LIMIT 1];
            
            /*List<SBQQ__QuoteLine__c> lQuoteLine = [Select Id,SBQQ__Product__r.Product_Family__c,SBQQ__Quantity__c,SBQQ__RequiredBy__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c,
                                                   SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c,SBQQ__RequiredBy__c 
                                                   from SBQQ__QuoteLine__c ];*/
            List<SBQQ__QuoteLine__c> lQuoteLine = lQuote[0].SBQQ__LineItems__r;
            
            sObj = new SBQQ__Quote__c(Id = lQuote[0].id ,SBQQ__Ordered__c = True);
            Test.startTest();
            List<SBQQ__Quote__c> lQuoteUpdated1 = (List<SBQQ__Quote__c>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            system.assertEquals(lQuoteUpdated1.size(),1);
            
            system.debug('@@lProduct2'+lProduct2);
            
            lProduct2[0].Generates_Entitlement__c=true;
            lProduct2[1].Generates_Entitlement__c=true;
            update lProduct2;
            system.debug('@@lProduct2-V2'+lProduct2);
            
            List<Order> lOrder = [Select Id,(Select Id,Product2.Generates_Entitlement__c,SBQQ__QuoteLine__c,
            SBQQ__QuoteLine__r.SBQQ__Quantity__c ,SBQQ__QuoteLine__r.Related_Asset__c,
            SbQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c,
            SbQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c,
            SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Family__c,
            SBQQ__QuoteLine__r.Related_Asset__r.SBQQ__QuoteLine__c from OrderItems) from Order];
            
            /*List<OrderItem> lOrderItem = [Select Id,Product2.Generates_Entitlement__c,SBQQ__QuoteLine__c,
                                          SBQQ__QuoteLine__r.SBQQ__Quantity__c ,SBQQ__QuoteLine__r.Related_Asset__c,
                                          SbQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c,
                                          SbQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c,
                                          SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Family__c,
                                          SBQQ__QuoteLine__r.Related_Asset__r.SBQQ__QuoteLine__c from OrderItem];*/
            List<OrderItem> lOrderItem = lOrder[0].OrderItems;
            System.debug('@@@@@OrderProducts' + lOrderItem.size() + '@@@@@@@Details' +lOrderItem);
            
            
            sObj = new Contract(StartDate = System.Today().addDays(-300));
            UtilityTestData.mContractData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mContractData.put('SBQQ__Order__c',lOrder[0].Id);
            UtilityTestData.mContractData.put('SBQQ__Quote__c',lQuote[0].Id);
            UtilityTestData.mContractData.put('StartDate', System.Today().addDays(-300)+'');
            UtilityTestData.mContractData.put('EndDate',System.Today().addDays(100)+'');
            UtilityTestData.mContractData.put('ContractTerm','10');
            sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mContractData);
            List<Contract> lContract  =  (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','2');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lQuoteLine[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',lOrderItem[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mSBQQSubscriptionData);
            List<SBQQ__Subscription__c > lSubscription1  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            System.debug('@@@@@lSubscription1' + lSubscription1.size() + '@@@@@@@Details' +lSubscription1);
            
            sObj1 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','2');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lQuoteLine[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',lOrderItem[1].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RequiredById__c',lSubscription1[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RootId__c',lSubscription1[0].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1,UtilityTestData.mSBQQSubscriptionData);
            List<SBQQ__Subscription__c > lSubscription2  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj1});
            
            lSubscription2[0].SBQQ__RootId__c = lSubscription2[0].Id;
            update lSubscription2[0];
            System.debug('@@@@@lSubscription2' + lSubscription2.size() + '@@@@@@@Details' +lSubscription2);
            
            lQuoteLine[0].SBQQ__RenewedSubscription__c = lSubscription1[0].Id;
            lQuoteLine[1].SBQQ__RequiredBy__c = lQuoteLine[0].Id;
            lQuoteLine[0].SBQQ__Quantity__c=2;
            lQuoteLine[1].SBQQ__Quantity__c=2;
            update lQuoteLine;
            
            sObj = new Asset();
            UtilityTestData.mAssetData.put('Name','Test Asset1');
            UtilityTestData.mAssetData.put('Status','Provisioning Complete');
            UtilityTestData.mAssetData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mAssetData.put('Product2Id',lProduct2[0].Id);
            UtilityTestData.mAssetData.put('SBQQ__OrderProduct__c',lOrderItem[0].Id);
            UtilityTestData.mAssetData.put('SBQQ__CurrentSubscription__c',lSubscription1[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAssetData); 
            
            sObj1 = new Asset();
            UtilityTestData.mAssetData.put('Name','Test Asset1');
            UtilityTestData.mAssetData.put('Status','Provisioning Complete');
            UtilityTestData.mAssetData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mAssetData.put('Product2Id',lProduct2[1].Id);
            UtilityTestData.mAssetData.put('SBQQ__OrderProduct__c',lOrderItem[1].Id);
            UtilityTestData.mAssetData.put('SBQQ__CurrentSubscription__c',lSubscription2[0].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAssetData); 
            List<Asset > lAsset  =  (List<Asset>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            System.debug('@@@@@lAsset' + lAsset.size() + '@@@@@@@Details' +lAsset);
            
            List<SBQQ__Subscription__c> SubscList = [Select Id, Name ,SBQQ__StartDate__c, SBQQ__EndDate__c,SBQQ__Quantity__c,
                                                                                              SBQQ__Account__c,  
                                                                                              SBQQ__RootId__c,
                                                                                              SBQQ__RequiredById__c,
                                                                                              SBQQ__Product__r.Name,
                                                                                              SBQQ__OrderProduct__c,
                                                                                              SBQQ__OrderProduct__r.ServiceDate,
                                                                                              SBQQ__OrderProduct__r.EndDate,
                                                                                              SBQQ__OrderProduct__r.product2.Name,
                                                                                              SBQQ__OrderProduct__r.product2.Product_family__c,
                                                                                              SBQQ__OrderProduct__r.product2.Generates_Entitlement__c ,
                                                                                              SBQQ__Product__r.Generates_Entitlement__c, 
                                                                                              SBQQ__OrderProduct__r.SBQQ__QuoteLine__c,  
                                                                                              SBQQ__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Family__c,    
                                                                                              SBQQ__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__Quantity__c,
                                                                                              SBQQ__OrderProduct__r.SbQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c,
                                                                                              SBQQ__OrderProduct__r.SbQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c from SBQQ__Subscription__c];
            
            
            System.debug('@@@@@SubscList' + SubscList.size() + '@@@@@@@Details' +SubscList);
            Map<Id, SBQQ__Subscription__c> MapSubAsset = new Map<Id, SBQQ__Subscription__c>();
            
            
            MapSubAsset.put(lAsset[0].Id, SubscList[0]);
            MapSubAsset.put(lAsset[1].Id, SubscList[1]);
            
            List<Contract> contractList = [Select Id from Contract];
            Test.stopTest();
            CreateEntitlementPerAsset.getEntitlement(contractList, MapSubAsset) ;  
            
            List<Entitlement> lEntitlement = [Select id, name from Entitlement];
            System.debug('@@@@@lEntitlement' + lEntitlement.size() + '@@@@@@@Details' +lEntitlement); 
            //Test.stopTest();
            
        //}
    }  
    
    //Method to test handle Asset
    static testMethod void handleSupportProducts() {
        
        
        //User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive= true AND Name = 'Deployment Master' LIMIT 1];
        
        sObject sObj;
        sObject sObj1;
        
        //system.runAs(adminUser){
            
            List<Account> lAccount =[Select Id from Account]; 
            
            List<Product2> lProduct2 =[Select Id,Generates_Entitlement__c from Product2 ];
            
            List<SBQQ__Quote__c> lQuote = [Select Id,(Select Id,SBQQ__Product__r.Product_Family__c,SBQQ__Quantity__c,SBQQ__RequiredBy__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c,
            SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c,SBQQ__RequiredBy__c 
            from SBQQ__LineItems__r) from SBQQ__Quote__c LIMIT 1];
            
            
            /*List<SBQQ__QuoteLine__c> lQuoteLine = [Select Id,SBQQ__Product__r.Product_Family__c,SBQQ__Quantity__c,SBQQ__RequiredBy__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c,
                                                   SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c,SBQQ__RequiredBy__c 
                                                   from SBQQ__QuoteLine__c ];*/
            List<SBQQ__QuoteLine__c> lQuoteLine = lQuote[0].SBQQ__LineItems__r;

            sObj = new SBQQ__Quote__c(Id = lQuote[0].id ,SBQQ__Ordered__c = True);
            Test.startTest();
            List<SBQQ__Quote__c> lQuoteUpdated1 = (List<SBQQ__Quote__c>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            system.assertEquals(lQuoteUpdated1.size(),1);
            
            system.debug('@@lProduct2'+lProduct2);
            
            lProduct2[0].Generates_Entitlement__c=true;
            lProduct2[1].Generates_Entitlement__c=true;
            update lProduct2;
            system.debug('@@lProduct2-V2'+lProduct2);
            
            List<Order> lOrder = [Select Id,(Select Id,Product2.Generates_Entitlement__c,SBQQ__QuoteLine__c,
            SBQQ__QuoteLine__r.SBQQ__Quantity__c ,SBQQ__QuoteLine__r.Related_Asset__c,
            SbQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c,
            SbQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c,
            SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Family__c,
            SBQQ__QuoteLine__r.Related_Asset__r.SBQQ__QuoteLine__c from OrderItems) from Order];
            
            
            /*List<OrderItem> lOrderItem = [Select Id,Product2.Generates_Entitlement__c,SBQQ__QuoteLine__c,
                                          SBQQ__QuoteLine__r.SBQQ__Quantity__c ,SBQQ__QuoteLine__r.Related_Asset__c,
                                          SbQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c,
                                          SbQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c,
                                          SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Family__c,
                                          SBQQ__QuoteLine__r.Related_Asset__r.SBQQ__QuoteLine__c from OrderItem];*/
            List<OrderItem> lOrderItem = lOrder[0].OrderItems;

            System.debug('@@@@@OrderProducts' + lOrderItem.size() + '@@@@@@@Details' +lOrderItem);
            
            
            sObj = new Contract(StartDate = System.Today().addDays(-300));
            UtilityTestData.mContractData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mContractData.put('SBQQ__Order__c',lOrder[0].Id);
            UtilityTestData.mContractData.put('SBQQ__Quote__c',lQuote[0].Id);
            UtilityTestData.mContractData.put('StartDate', System.Today().addDays(-300)+'');
            UtilityTestData.mContractData.put('EndDate',System.Today().addDays(100)+'');
            UtilityTestData.mContractData.put('ContractTerm','10');
            sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mContractData);
            List<Contract> lContract  =  (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});
            //Test.startTest();
            sObj = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','2');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lQuoteLine[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',lOrderItem[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj,UtilityTestData.mSBQQSubscriptionData);
            List<SBQQ__Subscription__c > lSubscription1  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            System.debug('@@@@@lSubscription1' + lSubscription1.size() + '@@@@@@@Details' +lSubscription1);
            
            sObj1 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].ID);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','2');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__SubscriptionEndDate__c',System.Today().addDays(300)+'');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__QuoteLine__c',lQuoteLine[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__OrderProduct__c',lOrderItem[1].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RequiredById__c',lSubscription1[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RootId__c',lSubscription1[0].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1,UtilityTestData.mSBQQSubscriptionData);
            List<SBQQ__Subscription__c > lSubscription2  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj1});
            
            /**
            lSubscription2[0].SBQQ__RootId__c = lSubscription2[0].Id;
            update lSubscription2[0];
            System.debug('@@@@@lSubscription2' + lSubscription2.size() + '@@@@@@@Details' +lSubscription2);
			**/
            
            lQuoteLine[0].SBQQ__RenewedSubscription__c = lSubscription1[0].Id;
            lQuoteLine[1].SBQQ__RequiredBy__c = lQuoteLine[0].Id;
            lQuoteLine[0].SBQQ__Quantity__c=2;
            lQuoteLine[1].SBQQ__Quantity__c=2;
            update lQuoteLine;
            
            sObj = new Asset();
            UtilityTestData.mAssetData.put('Name','Test Asset1');
            UtilityTestData.mAssetData.put('Status','Provisioning Complete');
            UtilityTestData.mAssetData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mAssetData.put('Product2Id',lProduct2[0].Id);
            UtilityTestData.mAssetData.put('SBQQ__OrderProduct__c',lOrderItem[0].Id);
            UtilityTestData.mAssetData.put('SBQQ__CurrentSubscription__c',lSubscription1[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAssetData); 
            
            sObj1 = new Asset();
            UtilityTestData.mAssetData.put('Name','Test Asset1');
            UtilityTestData.mAssetData.put('Status','Provisioning Complete');
            UtilityTestData.mAssetData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mAssetData.put('Product2Id',lProduct2[1].Id);
            UtilityTestData.mAssetData.put('SBQQ__OrderProduct__c',lOrderItem[1].Id);
            UtilityTestData.mAssetData.put('SBQQ__CurrentSubscription__c',lSubscription2[0].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAssetData); 
            List<Asset > lAsset  =  (List<Asset>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            System.debug('@@@@@lAsset' + lAsset.size() + '@@@@@@@Details' +lAsset);

            sObj = new Entitlement();
            UtilityTestData.mEntitlement.put('StartDate', System.today()+'');
            UtilityTestData.mEntitlement.put('EndDate', System.today().addDays(1)+'');
            UtilityTestData.mEntitlement.put('AssetId', lAsset[0].Id);
            UtilityTestData.mEntitlement.put('AccountId', lAsset[0].AccountId);
            UtilityTestData.mEntitlement.put('Support_Level__c', 'Premium Success');
            UtilityTestData.mEntitlement.put('Subscription__c', lAsset[0].SBQQ__CurrentSubscription__c);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEntitlement); 

            sObj1 = new Entitlement();
            UtilityTestData.mEntitlement.put('StartDate', System.today()+'');
            UtilityTestData.mEntitlement.put('EndDate', System.today().addDays(1)+'');
            UtilityTestData.mEntitlement.put('AssetId', lAsset[1].Id);
            UtilityTestData.mEntitlement.put('AccountId', lAsset[1].AccountId);
            UtilityTestData.mEntitlement.put('Support_Level__c', 'Premium Success');
            UtilityTestData.mEntitlement.put('Subscription__c', lAsset[1].SBQQ__CurrentSubscription__c);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mEntitlement); 
            List<Entitlement> lstEntitlements = (List<Entitlement>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
            List<SBQQ__Subscription__c> SubscList = [Select Id, Name ,SBQQ__StartDate__c, SBQQ__EndDate__c,SBQQ__Quantity__c,
                                                                                              SBQQ__Contract__c,
                                                                                              SBQQ__Account__c,  
                                                                                              SBQQ__RootId__c,
                                                                                              SBQQ__RequiredById__c,
                                                                                              SBQQ__Product__r.Name,
                                                                                              SBQQ__OrderProduct__c,
                                                                                              SBQQ__OrderProduct__r.ServiceDate,
                                                                                              SBQQ__OrderProduct__r.EndDate,
                                                                                              SBQQ__OrderProduct__r.product2.Name,
                                                                                              SBQQ__OrderProduct__r.product2.Product_family__c,
                                                                                              SBQQ__OrderProduct__r.product2.Generates_Entitlement__c ,
                                                                                              SBQQ__Product__r.Generates_Entitlement__c, 
                                                                                              SBQQ__OrderProduct__r.SBQQ__QuoteLine__c,  
                                                                                              SBQQ__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__Product__r.Product_Family__c,    
                                                                                              SBQQ__OrderProduct__r.SBQQ__QuoteLine__r.SBQQ__Quantity__c,
                                                                                              SBQQ__OrderProduct__r.SbQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c,
                                                                                              SBQQ__OrderProduct__r.SbQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c from SBQQ__Subscription__c];
            
            
            System.debug('@@@@@SubscList' + SubscList.size() + '@@@@@@@Details' +SubscList);
            Map<Id, SBQQ__Subscription__c> MapSubAsset = new Map<Id, SBQQ__Subscription__c>();
            
            
            MapSubAsset.put(lAsset[0].Id, SubscList[0]);
            MapSubAsset.put(lAsset[1].Id, SubscList[1]);
            
            List<Contract> contractList = [Select Id from Contract];
            Test.stopTest();
            CreateEntitlementPerAsset.getEntitlement(contractList, MapSubAsset);  
            //Test.stopTest();
            List<Entitlement> lEntitlement = [Select id, name from Entitlement];
            System.debug('@@@@@lEntitlement' + lEntitlement.size() + '@@@@@@@Details' +lEntitlement); 
            
            
        //}
    }
    
}