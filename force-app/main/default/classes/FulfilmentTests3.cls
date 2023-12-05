@isTest
public class FulfilmentTests3 {
    
    
    @isTest
    static void FulfillmentTestProductDaas() {
        
        User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1];
        
        system.runAs(adminUser){
            /*
            List<Product2> products = [Select Id,name,License_Screen_Type__c,License_Generation__c from product2];
            
            System.assert(products.size()>0, 'Products does not exist');
            
            
            products[0].License_Screen_Type__c = 'Daas';
            products[0].License_Generation__c = 'Base';
            update products[0];  
            */
            
            List<SBQQ__Quote__c> quoteList = [Select Id,name,SBQQ__Account__c from SBQQ__Quote__c limit 1];
            SBQQ__Quote__c quote1 = new SBQQ__Quote__c(Id = quoteList[0].id ,SBQQ__Ordered__c = True);
            update quote1;
            /*
            List<Order> orders = [Select Id,Status  from Order];
            System.assert(orders.size()>0, 'Orders Not created.');
            */
            
            List<OrderItem> orderProducts = [Select Id,Product2.Name,Product2.License_Screen_Type__c, orderId, Order.Status  from OrderItem];
            System.assert(orderProducts.size()>0, 'Order Products Not created.');
            
            // Fulfillment Lines should created when the order is udpated to provisioning completed.
            Order orderObj = new Order();
            orderObj.Id = orderProducts[0].orderId;
            orderObj.status='Activated' ;
            orderObj.SBQQ__PriceCalcStatus__c='Completed';
            Test.startTest();
            update orderObj;
            
            //orders = [Select Id,status,Provisioning_Complete_Date__c from order where Id=:orderObj.Id];
            System.assert(orderObj.status.equals('Activated'));
            List<id> orderids = new List<id>();
            orderids.add(orderObj.id);
            
            InvokableGenerateFulfillments.invokeFulfillmentCreation(orderids);
            
            
            List<Fulfillment__c> fulfillments = [Select Id,name,Active__c from Fulfillment__c where Order__c = :orderObj.Id 
                                                 and Active__c =true];
            System.assert(fulfillments.size()>0, 'fulfillments not created.');
            
            List<Fulfillment_Line__c> fulfillmentLines =  [Select Id,name,Ship_Status__c,Ship_via__c,Ship_Date__c,License_Screen_Type2__c,Skip_Fulfillment__c from Fulfillment_Line__c where Fullfillment__c = :fulfillments[0].Id];
            System.assert(fulfillmentLines.size()>0, 'fulfillment lines not created.');       
            
            List<Related_Fulfillment_Line__c> relatedfflineList = [Select Id,name from Related_Fulfillment_Line__c where Fullfillment_Line__r.Fullfillment__c = :fulfillments[0].Id];
            System.assert(relatedfflineList.size()>0, 'Related Fulfillment Lines not created.'); 
            system.debug( 'limit3>>'+Limits.getQueries());
            
            List<Fulfillment_Version__c> fulfillmentVersions = [Select Id,name,Supplied_Version__c,Order__c,InstallBase__c,Fullfillment_Line__c from Fulfillment_Version__c where Fullfillment_Line__c=:fulfillmentLines[0].Id];
            
            System.assert(fulfillmentVersions.size()>0, 'Fulfillment version not associated.');
            System.assert(fulfillmentVersions[0].Supplied_Version__c!=null, 'Fulfillment Supplied Verion is Empty');
            
            String fulfillmentHeaderId = fulfillments[0].Id;
            Map<String, Integer> fflineRecordsCount = FulfillmentData.getAllffLines(fulfillmentHeaderId);
            System.assert(fflineRecordsCount.size()>0, 'Fulfillment Line records count are not returned'); 
            
            Map<String, List<String>> fields = FulfillmentData.getFulfillmentLineFieldSet('All_Fulfillment_Lines');
            System.assert(fields.size()>0, 'Fulfillment Line FieldSet fields are not returned'); 
            
            List<String> lstString = new List<String>();
            lstString.add(fulfillmentHeaderId);
            lstString.add(fulfillmentLines[0].License_Screen_Type2__c);
            List<Fulfillment_Line__c> ffLines = FulfillmentData.getFulfillmentLinesLWC(lstString);
            System.assert(ffLines.size()>0, 'Fulfillment Lines are not returned');
            
            system.debug( 'limit4>>'+Limits.getQueries());
            
            List<Related_Fulfillment_Line__c> allRelatedFFLines = FulfillmentData.getAllRelatedFFLines(lstString);
            System.assert(allRelatedFFLines.size()>0, 'All Related Fulfillment Lines are not returned');
            
            List<Related_Fulfillment_Line__c> relatedffline = FulfillmentData.getRelatedFulfillmentLines(fulfillmentLines[0].Id);
            System.assert(relatedffline.size()>0, 'Related Fulfillment Lines specific to Fulfillment Line are not returned');
            
            //Provisioning complete the fulfillment lines shoud update the order products to provisioning completed.
            globalApexManager.allowRun('OrderProductAfterUpdate');
            List<Id> fulfillmentLineIds = new List<Id>();
            for(Fulfillment_Line__c fulfillmentLine : fulfillmentLines){
                
                fulfillmentLine.Ship_Status__c='Provisioning Complete';
                fulfillmentLine.Ship_via__c='Electronic';
                //fulfillmentLine.Ship_Date__c=Date.today()+10;
                fulfillmentLine.Skip_Fulfillment__c = true;
                fulfillmentLineIds.add(fulfillmentLine.Id);
            }
            FulfillmentData.updateFulfillments(JSON.serialize(fulfillmentLines));
            
            for(Fulfillment_Line__c fulfillmentLine : fulfillmentLines){
                fulfillmentLine.Ship_Date__c=Date.today()+10;
            }
            FulfillmentData.updateFulfillments(JSON.serialize(fulfillmentLines));
            
        }
        Test.stopTest();
        
    }
    
    Static void createInstallBaseForProduct(Sobject productSobj){
        
        RecordType rt = [Select Name, Id From RecordType 
                         where sObjectType='InstallBase__c' and DeveloperName ='On_Premise'
                         and isActive=true];
        
        sObject sObj1 = new InstallBase__c();
        UtilityTestData.mInstallBase.put('Name', 'PowerCenter');
        UtilityTestData.mInstallBase.put('RecordTypeId',rt.Id );
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mInstallBase);
        
        RecordType api = [Select Name, Id From RecordType 
                          where sObjectType='InstallBase__c' and DeveloperName ='API'
                          and isActive=true];
        
        sObject sObj12 = new InstallBase__c();
        UtilityTestData.mInstallBase.put('Name', 'Informatica Training Units');
        UtilityTestData.mInstallBase.put('RecordTypeId',api.Id );
        sObj12 = UtilityTest.putFieldRecord(sObj12, UtilityTestData.mInstallBase);
        List<InstallBase__c> lInstallBase = (List<InstallBase__c>) UtilityTest.makeInsert(new List<sObject>{sObj1,sObj12});
        
        sObject sObj2 = new InstallBase_Mapping__c();
        UtilityTestData.mInstallBaseMapping.put('Install_Base__c',lInstallBase[0].Id);
        UtilityTestData.mInstallBaseMapping.put('Product__c',productSobj.Id);
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mInstallBaseMapping);
        
        sObject sObj01 = new InstallBase_Mapping__c();
        UtilityTestData.mInstallBaseMapping.put('Install_Base__c',lInstallBase[1].Id);
        UtilityTestData.mInstallBaseMapping.put('Product__c',productSobj.Id);
        sObj01 = UtilityTest.putFieldRecord(sObj01, UtilityTestData.mInstallBaseMapping);
        List<InstallBase_Mapping__c> lInstallBaseMapping = (List<InstallBase_Mapping__c>) UtilityTest.makeInsert(new List<sObject>{sObj2,sObj01});  
        
        sObject sObj3 = new Versions__c();
        sObj3.put('Install_Base__c',lInstallBase[0].Id);
        //sObj3.put('Product__c',productSobj.Id);
        sObj3.put('Effective_Date__c', Date.today().addDays(-1));
        sObj3.put('Description__c', 'Version 1 for Powercenter InstallBase' );
        sObj3.put('Active_Version__c', true );
        sObj3.put('Current_Version__c', true );
        
        sObj3.put('Name', '10.2' );
        
        Insert sObj3;
        
    }
    
    Static List<Sobject> createPriceBookEntriesForProduct(Sobject productsobj,Id standardPB){
        Pricebook2 pb = new Pricebook2(Name = 'Test Price Book', Description = 'Price Book 2009 Products', IsActive = true);
        insert pb;
        
        Id pricebookId = pb.Id;
        
        sObject sObj = new Pricebook2(Id = pricebookId,IsActive = True);
        List<Pricebook2> lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        
        sObj = new pricebookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',standardPB);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',productsobj.Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);
        List<pricebookEntry> lStdPriceBookEntry = (List<pricebookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new pricebookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',lPriceBook2[0].Id);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',productsobj.Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);
        List<pricebookEntry> lPriceBookEntry = (List<pricebookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        return lPriceBookEntry;
    }
    
    Static Sobject applyBillingAndRevenueRules(Product2 product){
        
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
        
        return product;
        
    }
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
            //sObject sObj1 = new Account();
            
            sObj = new blng__BillingRule__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngBillingRuleData);
            List<blng__BillingRule__c> lBillingRule = (List<blng__BillingRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new blng__RevenueRecognitionRule__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngRevRecRuleData);
            List<blng__RevenueRecognitionRule__c> lRevRecRule = (List<blng__RevenueRecognitionRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new blng__TaxRule__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngTaxRuleData);
            List<blng__TaxRule__c> lTaxRule = (List<blng__TaxRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            Sobject sObj1 = new Product2();
            UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
            UtilityTestData.mProduct2Data.put('Name','Test cloud Product');
            UtilityTestData.mProduct2Data.put('Delivery_Method__c','Hosted Multi Tenant');
            UtilityTestData.mProduct2Data.put('License_Screen_Type__c','DaaS');
            UtilityTestData.mProduct2Data.put('License_Generation__c','Base');
            UtilityTestData.mProduct2Data.put('Pricing_Business_Model__c','Subscription');
            UtilityTestData.mProduct2Data.put('Forecast_Product__c','Cloud Data Integration');
            UtilityTestData.mProduct2Data.put('Product_Category__c','Add-ons');
            //UtilityTestData.mProduct2Data.put('Tax_Classification__c','Cloud Subscription');
            UtilityTestData.mProduct2Data.put('Tax_Product_Type__c','Services');
            UtilityTestData.mProduct2Data.put('Offering_Type__c','Cloud Hosted Subscription');
            UtilityTestData.mProduct2Data.put('SBQQ__ChargeType__c','Recurring');
            UtilityTestData.mProduct2Data.put('SBQQ__BillingFrequency__c','Monthly');
            UtilityTestData.mProduct2Data.put('SBQQ__BillingType__c','Advance');
            UtilityTestData.mProduct2Data.put('SBQQ__SubscriptionTerm__c','12');
            UtilityTestData.mProduct2Data.put('Edition__c','Test Edition');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProduct2Data);
            
            sObject psObj1 = new Product2();
            UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
            UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
            UtilityTestData.mProduct2Data.put('Name','Test cloud Product');
            UtilityTestData.mProduct2Data.put('Delivery_Method__c','Hosted Multi Tenant');
            UtilityTestData.mProduct2Data.put('License_Screen_Type__c','Cloud');
            UtilityTestData.mProduct2Data.put('License_Generation__c','Production');
            UtilityTestData.mProduct2Data.put('Pricing_Business_Model__c','Subscription');
            UtilityTestData.mProduct2Data.put('Forecast_Product__c','Cloud Data Integration');
            UtilityTestData.mProduct2Data.put('Product_Category__c','Wrapper');
            UtilityTestData.mProduct2Data.put('Tax_Product_Type__c','Services');
            UtilityTestData.mProduct2Data.put('Offering_Type__c','Cloud Hosted Subscription');
            UtilityTestData.mProduct2Data.put('SBQQ__ChargeType__c','Recurring');
            UtilityTestData.mProduct2Data.put('SBQQ__BillingFrequency__c','Monthly');
            UtilityTestData.mProduct2Data.put('SBQQ__BillingType__c','Advance');
            UtilityTestData.mProduct2Data.put('SBQQ__SubscriptionTerm__c','12');
            UtilityTestData.mProduct2Data.put('Edition__c','Test Edition');
            UtilityTestData.mProduct2Data.put('Option_Scale__c','Base');
            UtilityTestData.mProduct2Data.put('GTM_Model__c','Flex IPU');
            
            psObj1 = UtilityTest.putFieldRecord(psObj1, UtilityTestData.mProduct2Data);
            
            List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj1,psObj1});
            
            List<Product2> lProduct = [select id,Name,Delivery_Method__c,License_Screen_Type__c,License_Generation__c from Product2 ];
            lProduct[0].License_Screen_Type__c ='Cloud';
            lProduct[0].License_Generation__c='Production';
            update lProduct[0];
            
            system.debug('***** lProduct2 name '+lProduct2[0].Name);
            system.debug('***** lProduct2 delivery method '+lProduct[0].Delivery_Method__c );
            system.debug('***** lProduct2 screen type '+lProduct[0].License_Screen_Type__c);
            system.debug('***** lProduct2 generation '+lProduct[0].License_Generation__c);
            createInstallBaseForProduct(lProduct2[0]);
            
            
            Id pricebookId = Test.getStandardPricebookId(); 
            List<pricebookEntry> lPriceBookEntry = createPriceBookEntriesForProduct(lProduct2[0],pricebookId);
            
            
            
            User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
            settings.Ignore_Validation_Rules__c = true;
            upsert settings User_Exemptions__c.Id;
            
            Sobject sObjAcc = new Account();
            UtilityTestData.mAccountData.put('Name','Testing');
            sObj1 = UtilityTest.putFieldRecord(sObjAcc, UtilityTestData.mAccountData);
            
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
            
            Test.startTest();
            sObj = new SBQQ__Quote__c();
            UtilityTestData.mSBQuoteData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunity[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
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
            
            
            sObj1 = new Opportunity(Id = lOpportunity[0].id ,StageName = 'Closed Won', Analysis_Takeaways__c = 'Test', Ease_of_Renewal__c = '3- Not Easy', Next_Renewal_Considerations__c = 'Test', Next_Renewal_Likelyhood__c = 'May Renew 50/50', Stakeholders_Communication__c = 'Test', Stage_Reason__c='Won : Test class', Red_Flags__c = 'Pricing',Delivery__c='IPS Implementation', Solutions__c = 'IPU Expansion', Next_Steps__c = 'Test', Current_Status__c  = 'Draft Opportunity Closing Plan');
            List<Opportunity> lOpportunityUpdated = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj1});
            system.assertEquals(lOpportunityUpdated.size(),1);
            Test.stopTest();
            
        }
    }
    
}