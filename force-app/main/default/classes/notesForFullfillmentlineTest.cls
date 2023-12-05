/****************************************************************************************************************
Class:          notesForFullfillmentlineTest
@Author:        chandana gowda
@Created Date:  9/4/2019.
@Description:   Class for Testing the creation of notes consolidating the PDS of all products associated with the
Fulfillment Line
*******************************************************************************************************************
Change History 
*******************************************************************************************************************
*/
@isTest(SeeAllData = false)
public class notesForFullfillmentlineTest {
    
    @testSetup
    public static void setupObjectTestData() {
        
        Sobject sObj = new Product2();
        applyBillingAndRevenueRules((product2)sObj);
        
        List<Product2> lProduct2 = getOnPremiseSubscriptionProduct(sObj);
        //List<Product2> lProduct = [select id,Name,Delivery_Method__c,License_Screen_Type__c,License_Generation__c,Offering_Type__c,Edition__c,Provisionable_New__c from Product2 ];
        lProduct2[0].License_Screen_Type__c ='Cloud';
        lProduct2[0].License_Generation__c='Production';
        lProduct2[0].Offering_Type__c='Cloud Hosted Subscription';        
        update lProduct2[0];
        
        createInstallBaseForProduct(lProduct2[0]);
        Id pricebookId = Test.getStandardPricebookId(); 
        List<pricebookEntry> lPriceBookEntry = createPriceBookEntriesForProduct(lProduct2[0],pricebookId);
        
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;
        
        Sobject sObj1 = new Account();
        UtilityTestData.mAccountData.put('Name','Testing');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountData);
        
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj1});
        
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
        
        lOpportunity[0].Pricebook2Id = pricebookId;
        update lOpportunity[0];
        
        
        sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunity[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        Test.startTest();
        
        List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new SBQQ__QuoteLine__c();
        UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[0].Id);
        UtilityTestData.mQuoteLineData.put('SBQQ__ChargeType__c','Recurring');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingFrequency__c','Monthly');
        UtilityTestData.mQuoteLineData.put('SBQQ__BillingType__c','Advance');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mQuoteLineData);
        
        List<SBQQ__QuoteLine__c> lSBQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj});  
        List<SBQQ__QuoteLine__c> lQuoteLine    =[Select id,SBQQ__Product__r.Name, SBQQ__Product__r.License_Screen_Type__c FROM SBQQ__QuoteLine__c];    
        system.debug('*****lSBQuoteLine.name'+lQuoteLine[0].SBQQ__Product__r.Name);
        system.debug('*****lSBQuoteLine.License'+lQuoteLine[0].SBQQ__Product__r.License_Screen_Type__c);
        
        
        sObj1 = new SBQQ__Quote__c(Id = lSBQuote[0].Id ,SBQQ__Status__c = 'Approved', ApprovalStatus__c='Approved', ShiptToAccount__c=lAccount[0].Id, BillToAccount__c=lAccount[0].Id, EndUserAccount__c=lAccount[0].Id, SoldToAccount__c=lAccount[0].Id, EndUserContact__c=lContact[0].Id, BillToContact__c=lContact[0].Id, ShipToContact__c=lContact[0].Id, SoldToContact__c=lContact[0].Id); //<T1> Last two arguments);
        
        List<SBQQ__Quote__c> lQuoteUpdated = (List<SBQQ__Quote__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
        system.assertEquals(lQuoteUpdated.size(),1);
        
        sObj1 = new Opportunity(Id = lOpportunity[0].id ,StageName = 'Closed Won', Analysis_Takeaways__c = 'Test', Ease_of_Renewal__c = '3- Not Easy', Next_Renewal_Considerations__c = 'Test', Next_Renewal_Likelyhood__c = 'May Renew 50/50', Stakeholders_Communication__c = 'Test', Stage_Reason__c='Won : Test class', Red_Flags__c = 'Pricing',Delivery__c='IPS Implementation', Solutions__c = 'Big Data', Next_Steps__c = 'Test', Current_Status__c  = 'Draft Opportunity Closing Plan');
        List<Opportunity> lOpportunityUpdated = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
        system.assertEquals(lOpportunityUpdated.size(),1);
        Test.stopTest();
    }
    
    public static List<Sobject> getOnPremiseSubscriptionProduct(Sobject Sobj){
        UtilityTestData.mProduct2Data.put('Name','Test cloud Product');
        UtilityTestData.mProduct2Data.put('Delivery_Method__c','Hosted Multi Tenant');
        UtilityTestData.mProduct2Data.put('License_Screen_Type__c','Cloud');
        UtilityTestData.mProduct2Data.put('License_Generation__c','Production');
        UtilityTestData.mProduct2Data.put('Pricing_Business_Model__c','Subscription');
        UtilityTestData.mProduct2Data.put('Forecast_Product__c','Cloud Data Integration');
        UtilityTestData.mProduct2Data.put('Product_Category__c','Add-ons');
        UtilityTestData.mProduct2Data.put('Tax_Product_Type__c','Services');
        UtilityTestData.mProduct2Data.put('Offering_Type__c','Cloud Hosted Subscription');
        UtilityTestData.mProduct2Data.put('SBQQ__ChargeType__c','Recurring');
        UtilityTestData.mProduct2Data.put('SBQQ__BillingFrequency__c','Monthly');
        UtilityTestData.mProduct2Data.put('SBQQ__BillingType__c','Advance');
        UtilityTestData.mProduct2Data.put('SBQQ__SubscriptionTerm__c','12');
        UtilityTestData.mProduct2Data.put('Provisionable_New__c','true');
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
        List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj});
        return lProduct2;
        
    }
    
    public Static void createInstallBaseForProduct(Sobject productSobj){
        
        
        /*RecordType rt = [Select Name, Id From RecordType 
                         where sObjectType='InstallBase__c' and DeveloperName ='On_Premise'
                         and isActive=true]; */
        
        Id onPremiseRecTypeId = Schema.SObjectType.InstallBase__c.getRecordTypeInfosByName().get('On Premise').getRecordTypeId();
        
        sObject sObj1 = new InstallBase__c();
        UtilityTestData.mInstallBase.put('Name', 'PowerCenter');
        UtilityTestData.mInstallBase.put('RecordTypeId',onPremiseRecTypeId);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mInstallBase);
        List<InstallBase__c> lInstallBase = (List<InstallBase__c>) UtilityTest.makeInsert(new List<sObject>{sObj1});
        
        
        sObject sObj2 = new InstallBase_Mapping__c();
        UtilityTestData.mInstallBaseMapping.put('Install_Base__c',lInstallBase[0].Id);
        UtilityTestData.mInstallBaseMapping.put('Product__c',productSobj.Id);
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mInstallBaseMapping);        
        List<InstallBase_Mapping__c> lInstallBaseMapping = (List<InstallBase_Mapping__c>) UtilityTest.makeInsert(new List<sObject>{sObj2});  
        
        sObject sObj3 = new Versions__c();
        sObj3.put('Install_Base__c',lInstallBase[0].Id);
        sObj3.put('Effective_Date__c', Date.today().addDays(-1));
        sObj3.put('Description__c', 'Version 1 for Powercenter InstallBase' );
        sObj3.put('Active_Version__c', true );
        sObj3.put('Current_Version__c', true );
        sObj3.put('Name', '10.2' );
        Insert sObj3;
        
    }
    
    public Static List<Sobject> createPriceBookEntriesForProduct(Sobject productsobj,Id pricebookId){
        
        Sobject sObj = new Pricebook2(Id = pricebookId,IsActive = True);
        List<Pricebook2> lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        
        sObj = new pricebookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',lPriceBook2[0].Id);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',productsobj.Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);
        
        List<pricebookEntry> lPriceBookEntry = (List<pricebookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        return lPriceBookEntry;
    }
    
    public Static Sobject applyBillingAndRevenueRules(Product2 product){
        
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
        product.put('blng__BillingRule__c',lBillingRule[0].Id);
        product.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        product.put('blng__TaxRule__c',lTaxRule[0].Id);
        product.put('Offering_Type__c','Cloud Hosted Subscription');
        return product;
        
    }
    
    //Method to test the creation of notes on fulfillment Line
    public static @IsTest void testCreatePDS(){
        
        Test.startTest();
        
        List<Product2> products = [Select Id,name,License_Screen_Type__c,License_Generation__c,Offering_Type__c,Provisionable_New__c,Edition__c from product2];
        
        System.assert(products.size()>0, 'Products does not exist');
        
        products[0].License_Screen_Type__c = 'Cloud';
        products[0].License_Generation__c = 'Production';
        products[0].Offering_Type__c = 'Cloud Hosted Subscription';
        products[0].Edition__c = 'abc';
        update products[0];  
        
        System.debug('product Provisionable_New__c 1:'+products[0]);    
        Formula.recalculateFormulas(products);
        
        List<Product2> productList = [Select Id,name,License_Screen_Type__c,License_Generation__c,Offering_Type__c,Provisionable_New__c,Edition__c from product2 where Id=:products[0].Id];
        system.debug('productList'+productList);
        
        Product2 prod = productList[0];
        if(prod.Offering_Type__c=='Maintenance' ||
           prod.Offering_Type__c=='Subscription Support' ||
           prod.Offering_Type__c=='Professional Services' ||
           prod.Offering_Type__c=='Fee' ||
           prod.Offering_Type__c=='Passthrough' ||
           prod.Offering_Type__c=='Other' ||
           prod.Edition__c.contains('Royalty Fee')){
               
               system.debug('Inside provisionable flag false check');
           }
        
        
        List<SBQQ__Quote__c> quoteList = [Select Id,name from SBQQ__Quote__c limit 1];
        List<Account> AccountList = [Select Id,name from Account Limit 1];
        
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(Id = quoteList[0].id ,SBQQ__Ordered__c = True,SBQQ__Account__c = AccountList[0].Id);
        update quote1;
        
        List<Order> orders = [Select Id,Status  from Order];
        System.assert(orders.size()>0, 'Orders Not created.');
        
        List<OrderItem> orderProducts = [Select Id,Product2.Name,Product2.License_Screen_Type__c,Product2.License_Generation__c,Product2.Edition__c,Product2.Offering_Type__c,Product2.Provisionable_New__c from OrderItem where OrderId=:orders[0].Id];
        System.assert(orderProducts.size()>0, 'Order Products Not created.');
        
        //Fulfillment Lines should created when the order is udpated to provisioning completed.
        orders[0].status='Activated' ;
        orders[0].SBQQ__PriceCalcStatus__c='Completed';
        orders[0].Generate_Date__c= System.today()-5 ;
        update orders[0];
        System.debug('orders[0]'+ orders[0]);
        
        orders = [Select Id,status,Provisioning_Complete_Date__c from order where Id=:orders[0].Id];
        System.assert(orders[0].status.equals('Activated'));
        
        List<id> orderids = new List<id>();
        orderids.add(orders[0].id);
        
        InvokableGenerateFulfillments.invokeFulfillmentCreation(orderids);
        
        List<Fulfillment__c> fulfillments = [Select Id,name,Active__c from Fulfillment__c where Order__c = :orders[0].Id];
        System.assert(fulfillments.size()>0, 'fulfillments not created.');
        List<Fulfillment_Line__c> fulfillmentLines =  [Select Id,name,Ship_Status__c,Ship_via__c,Ship_Date__c,License_Screen_Type2__c,Skip_Fulfillment__c from Fulfillment_Line__c where Fullfillment__c = :fulfillments[0].Id];
        
        System.assert(fulfillmentLines.size()>0, 'fulfillment lines not created.');
        
        Map<Id,Related_Fulfillment_Line__c> mapRelatedFulfillmentLine = new Map<Id,Related_Fulfillment_Line__c>([SELECT Id,Name,Fullfillment_Line__c from Related_Fulfillment_Line__c]);
        Id fulfillmentLine = mapRelatedFulfillmentLine.values()[0].Fullfillment_Line__c;                
        
        List<Id> relatedFFlineIdList = new List<Id>();
        relatedFFlineIdList.addAll(mapRelatedFulfillmentLine.keySet());
        
        notesForFullfillmentline.createPDS(relatedFFlineIdList);
        Test.stopTest(); 
        
        List<ContentDocumentLink> lcntNote = [select ID FROM ContentDocumentLink WHERE LinkedEntityId = :fulfillmentLine];
        System.assert(lcntNote.size() >0, 'Notes for FFlines are not created');
        
        
    }     
}