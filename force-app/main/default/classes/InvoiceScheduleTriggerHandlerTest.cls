@isTest
public class InvoiceScheduleTriggerHandlerTest {
    private Final Static String ACC_Prospect_Account_Record_Type = Label.Prospect_Account_Record_Type;
	
    @testSetup
    static void setupObjectTestData() {
        //Create Account
        sObject sObj = new Account();
        UtilityTestData.mAccountData.put('RecordTypeId', Schema.SObjectType.Account.getRecordTypeInfosByName().get(ACC_Prospect_Account_Record_Type).getRecordTypeId());
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData); 
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        //Create Billing Rule, Tax Rule and Revenue Recognition Rule
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
        
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;
        
        sObject sObjb = new blng__BillingRule__c();
        sObject sObjc = new blng__BillingRule__c();
        sObject sObjd = new blng__BillingRule__c();
        
        sObjb = new blng__BillingRule__c();        
        sObjb = UtilityTest.putFieldRecord(sObjb, UtilityTestData.mblngBillingRuleData);
        List<blng__BillingRule__c> lBillingRule = (List<blng__BillingRule__c>) UtilityTest.makeInsert(new List<sObject>{sObjb});
        
        sObjb = new blng__RevenueRecognitionRule__c();
        sObjb = UtilityTest.putFieldRecord(sObjb, UtilityTestData.mblngRevRecRuleData);
        List<blng__RevenueRecognitionRule__c> lRevRecRule = (List<blng__RevenueRecognitionRule__c>) UtilityTest.makeInsert(new List<sObject>{sObjb});
        
        sObjb = new blng__TaxRule__c();
        sObjb = UtilityTest.putFieldRecord(sObjb, UtilityTestData.mblngTaxRuleData);
        List<blng__TaxRule__c> lTaxRule = (List<blng__TaxRule__c>) UtilityTest.makeInsert(new List<sObject>{sObjb});
        
        //Create Product2
        sObj = new Product2();
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
        UtilityTestData.mProduct2Data.put('Name','Test Debook Product 2');
        UtilityTestData.mProduct2Data.put('SBQQ__SubscriptionPricing__c','Fixed Price');
        UtilityTestData.mProduct2Data.put('SBQQ__SubscriptionTerm__c','12');
        UtilityTestData.mProduct2Data.put('SBQQ__PricingGuidance__c',null);
        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
        List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj});
        //Create PriceBook
        Id pricebookId = Test.getStandardPricebookId();
        sObj = new Pricebook2(Id = pricebookId,IsActive = True);
        List<Pricebook2> lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        
        sObj = new pricebookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',lPriceBook2[0].Id);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[0].Id);
        UtilityTestData.mPriceBookEntryData.put('UnitPrice','100');
        UtilityTestData.mPriceBookEntryData.put('IsActive','TRUE');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData); 
        List<pricebookEntry> lPriceBookEntry = (List<pricebookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj});
         
        Test.startTest();
        //Create Order
        sObj = new Order();
        UtilityTestData.mOrderData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOrderData.put('EffectiveDate',System.today().addYears(1)+'');
        UtilityTestData.mOrderData.put('EndDate',System.today().addYears(2)+'');
        UtilityTestData.mOrderData.put('Status','Draft');
        UtilityTestData.mOrderData.put('Type','New');
        UtilityTestData.mOrderData.put('Asset_Creation_Status__c','Initiated');
        UtilityTestData.mOrderData.put('Pricebook2Id',lPriceBookEntry[0].Pricebook2Id);
        sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mOrderData);
        List<Order> lOrder  =  (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj});  
        //Create Bill Plan
        sObj = new Invoice_Schedule__c ();
        UtilityTestData.mBillPlanDataAmt.put('Bill_Amount__c','100');
        UtilityTestData.mBillPlanDataAmt.put('Order__c',lOrder[0].Id);
        UtilityTestData.mBillPlanDataAmt.put('Invoice_Date__c',System.TODAY()+'');
        UtilityTestData.mBillPlanDataAmt.put('CurrencyIsoCode','USD');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mBillPlanDataAmt);
        List<Invoice_Schedule__c> lSBillPlan = (List<Invoice_Schedule__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        //Create Billing Schedule and Billing Transaction
        //generateBillingScheduleTransactionAC.createBillingScheduleTransaction(lOrder[0].Id,'New');     
        Test.stopTest();
    }
    //Test Class to check deleting Bill Plan after Billing Transaction is created
    @IsTest
    static void deleteBillPlan(){
		User u  = new User();
        //Run as User in Revenue Team and not as System Admin or App Support
        List<User> revTeamUsers = [SELECT Id, Name FROM User WHERE Id IN (SELECT AssigneeId FROM PermissionSetAssignment
                        		   WHERE PermissionSet.Name = 'Revenue_Team') AND isActive=true AND Profile.Name <> 'System Administrator'];
        List<User> userList = [SELECT Id, Name FROM User WHERE Id IN :revTeamUsers AND Id NOT IN (SELECT AssigneeId FROM PermissionSetAssignment
                        	   WHERE PermissionSet.Name = 'Application_Support') LIMIT 1];
        system.debug('userList:'+userList[0]);
        Test.startTest();
        System.runAs(userList[0]) {
            try{
                List<Invoice_Schedule__c> lBillPlan = [SELECT Id FROM Invoice_Schedule__c LIMIT 1];
                system.debug('lBillPlan:'+lBillPlan);
                delete lBillPlan;               
            }
            Catch(Exception e){                
            }
        }
        Test.stopTest();
    }
    //Test Class to check updating Invoice Date on Bill Plan after Billing Transaction is created
    @IsTest
    static void updateBillPlan(){
        //Run as User in Revenue Team and not as System Admin or App Support
        List<User> revTeamUsers = [SELECT Id, Name FROM User WHERE Id IN (SELECT AssigneeId FROM PermissionSetAssignment
                        		   WHERE PermissionSet.Name = 'Revenue_Team') AND isActive=true AND Profile.Name <> 'System Administrator'];
        List<User> userList = [SELECT Id, Name FROM User WHERE Id IN :revTeamUsers AND Id NOT IN (SELECT AssigneeId FROM PermissionSetAssignment
                        	   WHERE PermissionSet.Name = 'Application_Support') LIMIT 1];
        system.debug('userList:'+userList[0]);
        Test.startTest();
        System.runAs(userList[0]) {
            try{
                List<Invoice_Schedule__c> lBillPlan = [SELECT Id FROM Invoice_Schedule__c LIMIT 1];
                sObject sObj = lBillPlan[0];
                UtilityTestData.mBillPlanDataAmt.put('Invoice_Date__c',System.TODAY()+'2');
                sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mBillPlanDataAmt);
                List<Invoice_Schedule__c> lSBillPlan = (List<Invoice_Schedule__c>) UtilityTest.makeUpdate(new List<sObject>{sObj});        
    		}
            Catch(Exception e){                
            }
        }
        Test.stopTest();
    }
}