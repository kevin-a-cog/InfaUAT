@isTest
public class InvoiceTriggerHandlerTest {
    
    
    private Final Static String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
    private Final Static String ACC_Prospect_Account_Record_Type = Label.Prospect_Account_Record_Type;
    
    @testSetup
    public static void testMethod1(){
        User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1];
        
        system.runAs(adminUser){
            
            sObject sObj = new blng__BillingRule__c();
            sObject sObj1 = new Account();
            
            sObj = new blng__LegalEntity__c();
            UtilityTestData.mLegalEntityData.put('Name','test');
            UtilityTestData.mLegalEntityData.put('Legal_Entity_Code__c','test123');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalEntityData);
            List<blng__LegalEntity__c> lLegalEntity = (List<blng__LegalEntity__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
         
            sObj = new blng__BillingRule__c();
            UtilityTestData.mblngBillingRuleData.put('Name','Combine Partial Periods');
            UtilityTestData.mblngBillingRuleData.put('blng__PartialPeriodTreatment__c','Combine');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngBillingRuleData);
            
            sObj1 = new blng__BillingRule__c();
            UtilityTestData.mblngBillingRuleData.put('Name','Combine Partial Periods LIFO');
            UtilityTestData.mblngBillingRuleData.put('blng__PartialPeriodTreatment__c','Combine');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mblngBillingRuleData);
            
            List<blng__BillingRule__c> lBillingRule = (List<blng__BillingRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
            blng__FinanceBook__c FB = new blng__FinanceBook__c (Name = 'AR',blng__Active__c = TRUE,blng__FinancePeriodDuration__c='Monthly',blng__PeriodType__c='Accounting');
            blng__FinanceBook__c FB1 = new blng__FinanceBook__c (Name = 'Revenue',blng__Active__c = TRUE,blng__FinancePeriodDuration__c='Monthly',blng__PeriodType__c='Revenue');
            List<blng__FinanceBook__c > FBList = new List<blng__FinanceBook__c > {FB,FB1};
            insert FBList;
            
            blng__RevenueDistributionMethod__c RDM = new blng__RevenueDistributionMethod__c(Name='From Order.Full Recognition',blng__Active__c=TRUE,blng__Type__c='Order',blng__DistributionMethod__c='Full Recognition',blng__MonthlyRecognitionProration__c='Number of Days',blng__RevenueTransactionCreationProcess__c='Automatic',blng__FullRecognitionDate__c='Order Product Start Date');
            blng__RevenueDistributionMethod__c RDM1 = new blng__RevenueDistributionMethod__c(Name='From Invoice.Monthly Basis',blng__Active__c=TRUE,blng__Type__c='Invoice',blng__DistributionMethod__c='Monthly',blng__MonthlyRecognitionProration__c='Number of Days',blng__RevenueTransactionCreationProcess__c='Automatic',blng__RevenueScheduleTermStartDate__c='Invoice Line Start Date',blng__RevenueScheduleTermEndDate__c='Invoice Line End Date');
            List<blng__RevenueDistributionMethod__c > RDMList = new List<blng__RevenueDistributionMethod__c > {RDM,RDM1};
            insert RDMList;
            
            blng__GLRule__c GLRule = new blng__GLRule__c(Name = 'Recognize Revenue',blng__Active__c=TRUE);
            insert GLRule;
            
            blng__BillingTreatment__c BT = new blng__BillingTreatment__c (Name = 'BT-Combine Partial Periods',blng__Active__c=TRUE,blng__BillingFinanceBook__c=FBList[0].Id,blng__BillingLegalEntity__c=lLegalEntity[0].Id,blng__BillingRule__c=lBillingRule[0].Id,blng__CancellationRule__c='Legacy');
            blng__BillingTreatment__c BT1 = new blng__BillingTreatment__c (Name = 'BT-Combine Partial Periods LIFO',blng__Active__c=TRUE,blng__BillingFinanceBook__c=FBList[0].Id,blng__BillingLegalEntity__c=lLegalEntity[0].Id,blng__BillingRule__c=lBillingRule[1].Id,blng__CancellationRule__c='LIFO based on Termination Date');
            List<blng__BillingTreatment__c > BTList = new List<blng__BillingTreatment__c > {BT,BT1};
            insert BTList;
            
            
            sObj = new blng__RevenueRecognitionRule__c();
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mblngRevRecRuleData);
            
            sObj1 = new blng__RevenueRecognitionRule__c();
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mblngRevRecRuleData);
            
            List<blng__RevenueRecognitionRule__c> lRevRecRule = (List<blng__RevenueRecognitionRule__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
            blng__RevenueRecognitionTreatment__c RT = new blng__RevenueRecognitionTreatment__c (Name='RT-Order Act',blng__Active__c=TRUE,blng__ProcessingOrder__c=100,blng__Type__c='Percentage',blng__Percentage__c=100,blng__RevenueScheduleCreationAction__c='Order Activation',blng__RevenueFinanceBook__c=FBList[1].Id,blng__RevenueLegalEntity__c=lLegalEntity[0].Id,blng__RevenueRecognitionRule__c=lRevRecRule[0].Id,blng__RevenueDistributionMethod__c=RDMList[0].Id,blng__RevenueGLRule__c=GLRule.Id);
            blng__RevenueRecognitionTreatment__c RT1 = new blng__RevenueRecognitionTreatment__c (Name='RT-Invoice Post',blng__Active__c=TRUE,blng__ProcessingOrder__c=100,blng__Type__c='Percentage',blng__Percentage__c=100,blng__RevenueScheduleCreationAction__c='Invoice Posting',blng__RevenueFinanceBook__c=FBList[1].Id,blng__RevenueLegalEntity__c=lLegalEntity[0].Id,blng__RevenueRecognitionRule__c=lRevRecRule[1].Id,blng__RevenueDistributionMethod__c=RDMList[1].Id,blng__RevenueGLRule__c=GLRule.Id);
            List<blng__RevenueRecognitionTreatment__c> RRTList = new List<blng__RevenueRecognitionTreatment__c> {RT,RT1};
            insert RRTList;
            
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
            List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
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
            
            List<pricebookEntry> lPriceBookEntry = (List<pricebookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
            User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
            settings.Ignore_Validation_Rules__c = true;
            upsert settings User_Exemptions__c.Id;
           
            
            ConsumptionSchedule CS = new ConsumptionSchedule(Name='Overage',BillingTerm = 1,BillingTermUnit='Month',RatingMethod='Tier',Type='Range',SBQQ__Category__c='Rates',RecordTypeId='0126S000001EdfR',blng__BillingRule__c=lBillingRule[1].Id,blng__RevenueRecognitionRule__c=lRevRecRule[1].Id,blng__TaxRule__c=lTaxRule[0].Id);
            insert CS;
            
            ConsumptionRate CR = new ConsumptionRate(ConsumptionScheduleId = CS.Id,CurrencyIsoCode='USD',LowerBound=0,ProcessingOrder=1,PricingMethod='PerUnit',Price = 1,RecordTypeId='0126S000001EdfP');
            insert CR;
            
            CS.IsActive = TRUE;
            update CS;
            
            ProductConsumptionSchedule PCS = new ProductConsumptionSchedule(ConsumptionScheduleId = CS.Id,ProductId = lProduct2[1].Id);
            insert PCS;
            
            sObj1 = new Account();
            UtilityTestData.mAccountData.put('Name','Testing');
            UtilityTestData.mAccountData.put('Peoplesoft_External_ID__c','Testing');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mAccountData);
            
            List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj1});
            
            sObj = new Contact();
            UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mContactData.put('Peoplesoft_External_ID__c','ContactTest');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
            List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            
            
            
            
            sObj = new Order();
            UtilityTestData.mOrderData.put('Name','InvoiceTriggerHandlerTest');
            UtilityTestData.mOrderData.put('Type','New');
            UtilityTestData.mOrderData.put('CMS_Approved__c','True'); 
            UtilityTestData.mOrderData.put('Provisioning_Complete_Date__c',System.today()+''); 
            UtilityTestData.mOrderData.put('SBQQ__PriceCalcStatus__c','Completed');
            UtilityTestData.mOrderData.put('Shipping_Email__c','test@email.com');
            UtilityTestData.mOrderData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mOrderData.put('SoldToAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('SoldToContact__c',lContact[0].Id);
            UtilityTestData.mOrderData.put('EndUserAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('EndUserContact__c',lContact[0].Id);
            UtilityTestData.mOrderData.put('ShipToAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderData.put('BilltoAccount__c',lAccount[0].Id);
            //UtilityTestData.mOrderData.put('Billing_Alignment_Date__c',String.valueOf(Date.today()-50));
            UtilityTestData.mOrderData.put('Status','Draft'); 
            UtilityTestData.mOrderData.put('EffectiveDate',String.valueOf(Date.today()-50));
            UtilityTestData.mOrderData.put('BillingName_PSFTID__c','1');
            UtilityTestData.mOrderData.put('BillingAddress_PSFTID__c','1');
            UtilityTestData.mOrderData.put('EndUserAddress_PSFTID__c','1');
            UtilityTestData.mOrderData.put('ShippingName_PSFTID__c','1');
            UtilityTestData.mOrderData.put('ShippingAddress_PSFTID__c','1');
            UtilityTestData.mOrderData.put('SoldAddress_PSFTID__c','1');
             UtilityTestData.mOrderData.put('Legal_Entity__c',lLegalEntity[0].Id);
            UtilityTestData.mOrderData.put('Pricebook2Id',pricebookId);
            UtilityTestData.mOrderData.put('blng__BillingDayOfMonth__c',String.valueOf((Date.today()-50).Day()));
            UtilityTestData.mOrderData.put('blng__BillingAccount__c',lAccount[0].Id);
            
            UtilityTestData.mOrderData.put('Do_Not_Send_Invoices_to_Customer__c','Do Not Send Next Invoice to Customer(P)');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderData);
             List<Order> lOrder = (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj});
           
            sObj = new OrderItem();
            UtilityTestData.mOrderItemData.put('OrderId',lOrder[0].Id);
            //UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',lQuoteLI[0].Id);
            UtilityTestData.mOrderItemData.put('PricebookEntryId',lPriceBookEntry[0].Id);
            UtilityTestData.mOrderItemData.put('Product2Id',lProduct2[0].Id);
            UtilityTestData.mOrderItemData.put('ServiceDate',String.valueOf(Date.today()-50));
             UtilityTestData.mOrderItemData.put('EndDate',String.valueOf(Date.today()-50));
             UtilityTestData.mOrderItemData.put('SBQQ__BillingType__c','');
            UtilityTestData.mOrderItemData.put('SBQQ__DefaultSubscriptionTerm__c','1');
            UtilityTestData.mOrderItemData.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
            UtilityTestData.mOrderItemData.put('SBQQ__SubscriptionPricing__c','Percent Of Total');
            UtilityTestData.mOrderItemData.put('Ship_Date__c',String.valueOf(Date.today()));
            UtilityTestData.mOrderItemData.put('SBQQ__Status__c ','Draft');
            UtilityTestData.mOrderItemData.put('SBQQ__Activated__c','FALSE');
            UtilityTestData.mOrderItemData.put('blng__BillingRule__c',lBillingRule[0].Id);
            UtilityTestData.mOrderItemData.put('blng__TaxRule__c',lTaxRule[0].Id);
            UtilityTestData.mOrderItemData.put('blng__InvoiceRunProcessingStatus__c','Pending Billing');
            UtilityTestData.mOrderItemData.put('blng__BillingAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderItemData.put('blng__BillingTreatment__c',BTList[0].Id);
            UtilityTestData.mOrderItemData.put('blng__LegalEntity__c',lLegalEntity[0].Id);
            UtilityTestData.mOrderItemData.put('SBQQ__BillingFrequency__c','');
            UtilityTestData.mOrderItemData.put('SBQQ__ChargeType__c','One-Time');
             UtilityTestData.mOrderItemData.put('Name','Cancel and Rebill');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderItemData);
            
            sObj1 = new OrderItem();
            UtilityTestData.mOrderItemData.put('OrderId',lOrder[0].Id);
            //UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',lQuoteLI[0].Id);
            UtilityTestData.mOrderItemData.put('PricebookEntryId',lPriceBookEntry[1].Id);
            UtilityTestData.mOrderItemData.put('Product2Id',lProduct2[1].Id);
            UtilityTestData.mOrderItemData.put('ServiceDate',String.valueOf(Date.today()-50));
             UtilityTestData.mOrderItemData.put('EndDate',String.valueOf(Date.today()-50));
             UtilityTestData.mOrderItemData.put('SBQQ__BillingType__c','');
            UtilityTestData.mOrderItemData.put('SBQQ__DefaultSubscriptionTerm__c','1');
            UtilityTestData.mOrderItemData.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
            UtilityTestData.mOrderItemData.put('SBQQ__SubscriptionPricing__c','Percent Of Total');
            UtilityTestData.mOrderItemData.put('Ship_Date__c',String.valueOf(Date.today()));
            UtilityTestData.mOrderItemData.put('SBQQ__Status__c ','Draft');
            UtilityTestData.mOrderItemData.put('SBQQ__Activated__c','FALSE');
            UtilityTestData.mOrderItemData.put('blng__BillingRule__c',lBillingRule[0].Id);
            UtilityTestData.mOrderItemData.put('blng__TaxRule__c',lTaxRule[0].Id);
            UtilityTestData.mOrderItemData.put('blng__InvoiceRunProcessingStatus__c','Pending Billing');
            UtilityTestData.mOrderItemData.put('blng__BillingAccount__c',lAccount[0].Id);
            UtilityTestData.mOrderItemData.put('blng__BillingTreatment__c',BTList[0].Id);
            UtilityTestData.mOrderItemData.put('blng__LegalEntity__c',lLegalEntity[0].Id);
            UtilityTestData.mOrderItemData.put('SBQQ__BillingFrequency__c','');
            UtilityTestData.mOrderItemData.put('SBQQ__ChargeType__c','One-Time');
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOrderItemData);
            
            List<OrderItem> lOrderItem = (List<OrderItem>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
            
            
            Test.startTest();
            lOrder[0].status = 'Activated';
            lOrder[0].SBQQ__PriceCalcStatus__c = 'Completed';
            update lOrder[0];
            
            sObj = new Related_Order_and_Contract__c();
            UtilityTestData.mROC.put('Order__c',lOrder[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mROC);
          
            List<Related_Order_and_Contract__c> lROC = (List<Related_Order_and_Contract__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
             sObj = new blng__RevenueSchedule__c();
            UtilityTestData.mRevSchedule.put('blng__RevenueRecognitionTreatment__c',RRTList[0].Id);
            UtilityTestData.mRevSchedule.put('blng__OrderProduct__c',lOrderItem[0].Id);
            UtilityTestData.mRevSchedule.put('RMCS_Contract_Line_Number__c','Test Rev Agree Batch');
            UtilityTestData.mRevSchedule.put('Product__c',lProduct2[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRevSchedule);
            
            sObj1 = new blng__RevenueSchedule__c();
            UtilityTestData.mRevSchedule.put('blng__RevenueRecognitionTreatment__c',RRTList[0].Id);
            UtilityTestData.mRevSchedule.put('blng__OrderProduct__c',lOrderItem[1].Id);
            UtilityTestData.mRevSchedule.put('RMCS_Contract_Line_Number__c','Test Rev Agree Batch');
             UtilityTestData.mRevSchedule.put('Sent_to_RMCS__c','TRUE');
            UtilityTestData.mRevSchedule.put('Product__c',lProduct2[1].Id);
            sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mRevSchedule);
                   
            List<blng__RevenueSchedule__c> lRS= (List<blng__RevenueSchedule__c>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
            database.executebatch(new revenueAgreementBatch(),1);
            
            List<blng__UsageSummary__c> usageSummaryList = new List<blng__UsageSummary__c> ();
            List<blng__Usage__c> usageList = new List<blng__Usage__c> ();
            List<blng__Invoice__c> invList = new List<blng__Invoice__c> ();
            Id orderId;
            
           
                
            for(blng__UsageSummary__c US : [Select Id,blng__OrderProduct__c,blng__Order__r.Id,blng__MatchingId__c,blng__SummaryStartDate__c,blng__SummaryEndDate__c,blng__NextBillingDate__c,blng__Status__c from blng__UsageSummary__c ORDER By CreatedDate DESC])
            {
                orderId = US.blng__Order__r.Id; 
                US.blng__MatchingId__c = orderId;
                US.blng__Status__c='Queued For Invoice';
                US.blng__NextBillingDate__c = Date.today()-51;
                US.blng__UsageCount__c = 1;
                US.blng__UnitPrice__c = 1;
                US.blng__Subtotal__c = 100;
                US.blng__TotalQuantity__c = 100;
                US.blng__UnbilledQuantity__c = 100;
                usageSummaryList.add(US);
                DateTime USSD = US.blng__SummaryStartDate__c;
                DateTime USED = US.blng__SummaryEndDate__c;
                blng__Usage__c usage = new blng__Usage__c (blng__UsageSummary__c=US.Id,blng__MatchingId__c = orderId,blng__StartDateTime__c=USSD ,blng__EndDateTime__c=USED,blng__Quantity__c=100);
                usageList.add(usage);
            }
            
               insert usageList;
            
             SBQQ.TriggerControl.disable();
                update usageSummaryList;
             SBQQ.TriggerControl.enable();
            
            List<OrderItem> oiList = new List<OrderItem> ();
            for(OrderItem oi : [SELECT Id,SBQQ__Status__c,SBQQ__Activated__c,blng__BillingAccount__c,blng__BillingTreatment__c,TotalPrice,SBQQ__BillingType__c,blng__HoldBilling__c,blng__LegalEntity__c,ServiceDate,blng__BillableUnitPrice__c,blng__BillingRule__c,blng__OverrideBillableUnitPrice__c,SBQQ__BillingFrequency__c,SBQQ__OrderedQuantity__c,EndDate,blng__NextBillingDate__c,blng__NextChargeDate__c,SBQQ__ChargeType__c,Order.AccountId,OrderId,blng__InvoiceRunProcessingStatus__c,CurrencyIsoCode FROM OrderItem])
               oiList.add(new OrderItem(Id=oi.Id,blng__InvoiceRunProcessingStatus__c='Pending Billing',blng__OverrideNextBillingDate__c = null,blng__BillableUnitPrice__c=oi.TotalPrice,blng__RevenueScheduleStatus__c='Queued'));
            
            update oiList;
            
                    
            lOrder[0].blng__BillNow__c = TRUE;
            update lOrder[0];
            
            Map<Id,SObject> updateMapList = new Map<Id,Sobject> ();
            for(blng__InvoiceLine__c IL : [Select Id,blng__Invoice__c ,blng__OrderProduct__c,blng__OrderProduct__r.OrderId, blng__UsageSummary__c,blng__RevenueScheduleStatus__c, blng__Subtotal__c, blng__Quantity__c,blng__InvoiceLineStatus__c from blng__InvoiceLine__c]){
                
                    usageSummaryList[0].blng__Invoice__c = IL.blng__Invoice__c ;
                    usageSummaryList[0].blng__InvoiceLine__c = IL.Id;
                    updateMapList.put(usageSummaryList[0].Id,usageSummaryList[0]);
                
                lRS[0].blng__InvoiceLine__c = IL.Id;//IL.blng__OrderProduct__c == lRS[0].blng__OrderProduct__c ? IL.Id : null;
                lRS[1].blng__InvoiceLine__c = IL.Id;// IL.blng__OrderProduct__c == lRS[1].blng__OrderProduct__c ? IL.Id : null;
                updateMapList.put(lRS[0].Id,lRS[0]);
                updateMapList.put(lRS[1].Id,lRS[1]);
                }
                
                update updateMapList.values();
            Test.stopTest();
        }
    }   
    
    @isTest
    public static void updateQuoteOrderOpportunityActivated() {
        
       
        //User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        User adminUser = [SELECT id FROM User WHERE Profile.Name = 'System Administrator' AND Name = 'Deployment Master' LIMIT 1];
         
        system.runAs(adminUser){
            
            List<Order> lOrder = [Select Id, AccountId,CMS_Approved__c, SBQQ__PriceCalcStatus__c, SBQQ__Contracted__c, Status from Order where Name = 'InvoiceTriggerHandlerTest' Limit 2];
            system.assertEquals(lOrder.size(),1);
            Test.startTest();
            
            blng__Invoice__c invoice = new blng__Invoice__c();
            invoice.Invoice_Sent__c =false;
            invoice.blng__Account__c  = lOrder[0].AccountId;
            invoice.blng__Order__c  = lOrder[0].Id;
            insert invoice;
            
            
            invoice.Invoice_Sent__c = true;
            invoice.External_ID__c = '12345';
            update invoice;
            
            
            Test.stopTest();
            
            
       
            
            
            
            
        }
    }
    
    @isTest
    public static void invoiceCancelRebill() {
    
    
            List<blng__Invoice__c> invList = new List<blng__Invoice__c> ();
            globalApexManager.allowRun('InvoiceBeforeUpdate');
            globalApexManager.allowRun('InvoiceAfterUpdate');
            for(blng__Invoice__c Inv : [Select Id from blng__Invoice__c where blng__InvoiceStatus__c = 'Draft'])
            {
                invList.add(new blng__Invoice__c(Id=Inv.Id,blng__InvoiceStatus__c='Rebilled'));
            }
            SBQQ.TriggerControl.disable();
                update invList;
             SBQQ.TriggerControl.enable();
            
    }

    @isTest
    public static void invoiceOverage1() {        
        List<blng__RevenueSchedule__c> rsList = new List<blng__RevenueSchedule__c> ();
        //globalApexManager.allowRun('InvoiceBeforeUpdate');
        //globalApexManager.allowRun('InvoiceAfterUpdate');
        blng__InvoiceLine__c IL = [Select Id,blng__Invoice__c ,blng__OrderProduct__c,blng__OrderProduct__r.OrderId, blng__OrderProduct__r.Product2Id,
                                   blng__UsageSummary__c,blng__RevenueScheduleStatus__c, blng__Subtotal__c, 
                                   blng__Quantity__c,blng__InvoiceLineStatus__c from blng__InvoiceLine__c
                                    LIMIT 1
                                  ];
        //update new Product2(Id = IL.blng__OrderProduct__r.Product2Id, GTM_Model__c = 'Flex IPU', Option_Scale__c = 'Overage');
        update new Order(Id = IL.blng__OrderProduct__r.OrderId, Source__c = 'Ecommerce - Paygo');
        sObject sObj1 = new blng__RevenueSchedule__c();
        UtilityTestData.mRevSchedule.put('blng__RevenueRecognitionTreatment__c',[Select Id FROM blng__RevenueRecognitionTreatment__c LIMIT 1].Id);
        UtilityTestData.mRevSchedule.put('blng__OrderProduct__c',IL.blng__OrderProduct__c);
        UtilityTestData.mRevSchedule.put('RMCS_Contract_Line_Number__c','Test Rev Agree Batch');
        UtilityTestData.mRevSchedule.put('Sent_to_RMCS__c','TRUE');
        UtilityTestData.mRevSchedule.put('Product__c',IL.blng__OrderProduct__r.Product2Id);
        UtilityTestData.mRevSchedule.put('blng__InvoiceLine__c',IL.Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mRevSchedule);
        List<blng__RevenueSchedule__c> lRS= (List<blng__RevenueSchedule__c>) UtilityTest.makeInsert(new List<sObject>{sObj1});
    }
    @isTest
    public static void invoiceOverage2() {        
        List<blng__RevenueSchedule__c> rsList = new List<blng__RevenueSchedule__c> ();
        //globalApexManager.allowRun('InvoiceBeforeUpdate');
        //globalApexManager.allowRun('InvoiceAfterUpdate');
        blng__InvoiceLine__c IL = [Select Id,blng__Invoice__c ,blng__OrderProduct__c,blng__OrderProduct__r.OrderId, blng__OrderProduct__r.Product2Id,
                                   blng__UsageSummary__c,blng__RevenueScheduleStatus__c, blng__Subtotal__c, blng__OrderProduct__r.SBQQ__RequiredBy__c,
                                   blng__Quantity__c,blng__InvoiceLineStatus__c from blng__InvoiceLine__c
                                    LIMIT 1
                                  ];
        system.debug('nishit'+[Select Id from OrderItem where Id != :IL.blng__OrderProduct__c LIMIT 1].Id);
        update new Product2(Id = IL.blng__OrderProduct__r.Product2Id, GTM_Model__c = 'Flex IPU', Option_Scale__c = 'Overage');
        update new OrderItem(Id = IL.blng__OrderProduct__c, SBQQ__RequiredBy__c = [Select Id from OrderItem where Id != :IL.blng__OrderProduct__c LIMIT 1].Id);
        //update new Order(Id = IL.blng__OrderProduct__r.OrderId, Source__c = 'Ecommerce - Paygo');
        sObject sObj1 = new blng__RevenueSchedule__c();
        UtilityTestData.mRevSchedule.put('blng__RevenueRecognitionTreatment__c',[Select Id FROM blng__RevenueRecognitionTreatment__c LIMIT 1].Id);
        UtilityTestData.mRevSchedule.put('blng__OrderProduct__c',IL.blng__OrderProduct__c);
        UtilityTestData.mRevSchedule.put('RMCS_Contract_Line_Number__c','Test Rev Agree Batch');
        UtilityTestData.mRevSchedule.put('Sent_to_RMCS__c','TRUE');
        UtilityTestData.mRevSchedule.put('Product__c',IL.blng__OrderProduct__r.Product2Id);
        UtilityTestData.mRevSchedule.put('blng__InvoiceLine__c',IL.Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mRevSchedule);
        try{
            UtilityTest.makeInsert(new List<sObject>{sObj1});
        }
        catch(Exception ex){
            system.debug('exception in invoiceOverage2');
        }
        
    }

}