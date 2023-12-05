/*
    @created by       : Venky K
    @created on       : 10/05/2021
    @Purpose          : Test class for EntitledProductServicesBatch.
    @Testclass        : 
    @JIRA             : 
    @Tag              : T01
    
    
 Change History
 ****************************************************************************************************
    ModifiedBy      Date        Requested By        Description               Jira No.       Tag 
 ****************************************************************************************************
 Isha Bansal       24-08-2023                    Included xsSupportDate method   I2RT-8853   T01
 */

@istest
private class TestEntitledProductServicesBatch {
    @testSetup
     static void setupTestData(){
      Id runningUsrid=UserInfo.getuserid();
         User u = [Select Id from user where alias ='dmaster' limit 1];
         system.runas(u){
           
          Global_Config__c gc = new Global_Config__c();
             gc.Mute_Triggers__c = true;
             gc.SetupOwnerId=UserInfo.getuserid();
             gc.Mute_Notifications__c=true;
             insert gc;

             User_Exemptions__c usrExemption =new  User_Exemptions__c (); //T01
             usrExemption.Ignore_Validation_Rules__c=true;
            usrExemption.SetupOwnerId=runningUsrid;
             insert usrExemption;
          
       
         sObject sObj;
         sObject sObj2;
        //create an Account record
        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        sObj = new Account();//
        UtilityTestData.mAccountData.put('Name', 'HMDM Gordon Food Service, Inc.');
        UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecType);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj}); 
        
         sObj2 = new Account();//
        UtilityTestData.mAccountData.put('Name', 'abc Service, Inc2.');
        UtilityTestData.mAccountData.put('RecordTypeId', SupportAccountRecType); 
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mAccountData);
        List<Account> lAccount1 = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj2});
        
        UtilityTestData.mContactData.put('AccountId', lAccount[0].Id);
        sObj = new Contact(Email = 'testing1email@test.com');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
         
         sObj = new blng__LegalEntity__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalEntityData);
        List<blng__LegalEntity__c> lLegalEntity = (List<blng__LegalEntity__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
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
        UtilityTestData.mProduct2Data.put('Offering_Type__c','On-Premise Perpetual License');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
         List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj});
         lProduct2[0].Name = 'Extended Support';
         update lProduct2[0];
         
         Id pricebookId = Test.getStandardPricebookId();         
        
        sObj = new Pricebook2(Id = pricebookId,IsActive = True);
        //sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPricebook2Data);
        List<Pricebook2> lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
         
         sObj = new SBQQ__Quote__c();
            UtilityTestData.mSBQuoteData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c',System.today()+ '');
            UtilityTestData.mSBQuoteData.put('SBQQ__EndDate__c',System.today().addYears(1)+ '');
            UtilityTestData.mSBQuoteData.put('SBQQ__SubscriptionTerm__c','12');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
            List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
         
          sObj = new Order();
        UtilityTestData.mOrderData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOrderData.put('EffectiveDate',System.today()+'');
        UtilityTestData.mOrderData.put('EndDate',System.today().addYears(1)+'');
        UtilityTestData.mOrderData.put('Status','Draft');
        UtilityTestData.mOrderData.put('Asset_Creation_Status__c','Initiated');
        UtilityTestData.mOrderData.put('Pricebook2Id',lPriceBook2[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mOrderData);
            List<Order> lOrder  =  (List<Order>) UtilityTest.makeInsert(new List<sObject>{sObj});
         
         
         sObj = new Contract(StartDate = System.Today().addDays(-300));
            UtilityTestData.mContractData.put('AccountId',lAccount[0].Id);
            UtilityTestData.mContractData.put('StartDate', System.today()+'');
            UtilityTestData.mContractData.put('EndDate',System.today().addYears(1)+'');
            UtilityTestData.mContractData.put('ContractTerm','12');
            UtilityTestData.mContractData.put('BillingStreet','Test Street');
            UtilityTestData.mContractData.put('BillingCity','Test City');
            UtilityTestData.mContractData.put('BillingState','Test State');
            UtilityTestData.mContractData.put('BillingPostalCode','98714-4927');
            UtilityTestData.mContractData.put('BillingCountry','Test Country');
            UtilityTestData.mContractData.put('ShippingStreet','Test Street');
            UtilityTestData.mContractData.put('ShippingCity','Test City');
            UtilityTestData.mContractData.put('ShippingState','Test State');
            UtilityTestData.mContractData.put('ShippingPostalCode','98714-4927');
            UtilityTestData.mContractData.put('ShippingCountry','Test Country');
            UtilityTestData.mContractData.put('SBQQ__Order__c',lOrder[0].Id);
            //UtilityTestData.mContractData.put('SBQQ__Quote__c',lQuote[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj ,UtilityTestData.mContractData);
            List<Contract> lContract  =  (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});
         
         
         sObj2 = new SBQQ__Subscription__c();
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Contract__c',lContract[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Product__c',lProduct2[0].Id);
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__Quantity__c','1');
            UtilityTestData.mSBQQSubscriptionData.put('SBQQ__RenewalQuantity__c','1');
            sObj2 = UtilityTest.putFieldRecord(sObj2,UtilityTestData.mSBQQSubscriptionData);
            List<SBQQ__Subscription__c > lSubscription  =  (List<SBQQ__Subscription__c>) UtilityTest.makeInsert(new List<sObject>{sObj2});
         
         sObj2 = new SBQQ__QuoteLine__c();
            UtilityTestData.mQuoteLineData.put('SBQQ__Quote__c',lSBQuote[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__Product__c',lProduct2[0].Id);
            UtilityTestData.mQuoteLineData.put('SBQQ__PriorQuantity__c','1');
            UtilityTestData.mQuoteLineData.put('SBQQ__Quantity__c','2');
            UtilityTestData.mQuoteLineData.put('SBQQ__UpgradedSubscription__c',lSubscription[0].Id);
            sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mQuoteLineData);
            
            List<SBQQ__QuoteLine__c> lSBQuoteLine = (List<SBQQ__QuoteLine__c>) UtilityTest.makeInsert(new List<sObject>{sObj2});
         
          
         
        
        
         sObj2 = new pricebookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',lPriceBook2[0].Id);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[0].Id);
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mPriceBookEntryData);
        
        List<pricebookEntry> lPriceBookEntry = (List<pricebookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj2});
        
         
            sObj = new OrderItem();
            UtilityTestData.mOrderItemData.put('ServiceDate',System.today()+'');
            UtilityTestData.mOrderItemData.put('EndDate',System.today().addYears(1)+'');
            UtilityTestData.mOrderItemData.put('SBQQ__QuoteLine__c',lSBQuoteLine[0].Id);
            UtilityTestData.mOrderItemData.put('SBQQ__QuotedQuantity__c','-3');
            UtilityTestData.mOrderItemData.put('SBQQ__OrderedQuantity__c','-3');
            UtilityTestData.mOrderItemData.put('Quantity','-3');
            UtilityTestData.mOrderItemData.put('Product2Id',lProduct2[0].Id);
            UtilityTestData.mOrderItemData.put('OrderId',lOrder[0].Id);
            UtilityTestData.mOrderItemData.put('PricebookEntryId',lPriceBookEntry[0].Id);
            UtilityTestData.mOrderItemData.put('UnitPrice','2000');
            UtilityTestData.mOrderItemData.put('Ship_Date__c',System.today()+'');
            UtilityTestData.mOrderItemData.put('Purchase_Order_PO_Number__c','131311');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOrderItemData);
         //List<OrderItem> amendedOrderItems = (List<OrderItem>) UtilityTest.makeInsert(new List<sObject>{sObj});
         
         
         sObj = new Entitled_Product__c();
            UtilityTestData.mEntitledProduct.put('Support_Account__c', lAccount[0].Id);
            UtilityTestData.mEntitledProduct.put('Name', 'Axon Data Governance(Hosted Multi Tenant)');
            UtilityTestData.mEntitledProduct.put('Product__c', 'Axon Data Governance');
            UtilityTestData.mEntitledProduct.put('Delivery_Method__c', 'Hosted Multi Tenant');
            UtilityTestData.mEntitledProduct.put('Active__c', 'True');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEntitledProduct);
            List<Entitled_Product__c> lEntitledProduct = (List<Entitled_Product__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            sObj = new Technical_Product_Line__c();
            UtilityTestData.mtechnicalProductLine.put('Name', 'Axon Data Governance');
            UtilityTestData.mtechnicalProductLine.put('Forecast_Product__c', 'Axon Data Governance');
            UtilityTestData.mtechnicalProductLine.put('Delivery_Method__c', 'On Premise;Hosted Single Tenant;Hosted Multi Tenant;Perpetual');
            UtilityTestData.mtechnicalProductLine.put('Version__c', '9.2.1;9.2.2;9.2.4');
            UtilityTestData.mtechnicalProductLine.put('Component_SubComponent__c', 'Installation:Installation;Documentation:Documentation;ActiveVOS Console:Error~Permission;Performance:Job~Process performance;Hosted Application:Custom configuration~Product configuration~Logs~Others;Hosted Infrastructure:CPU~Memory~Disk~Others');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mtechnicalProductLine);
            List<Technical_Product_Line__c> lTechProdLine = (List<Technical_Product_Line__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
            //create an asset
            Asset assetrec = new Asset();
            assetrec.name = 'test';  
            assetrec.Support_Account__c = lAccount1[0].Id;
            assetrec.Entitled_Product__c = lEntitledProduct[0].Id;
            assetrec.accountid = lAccount[0].Id;
            insert assetrec;
            
            
            //create an Entitlement record
            sObj = new Entitlement();
            UtilityTestData.mEntitlement.put('AccountId',lAccount[0].Id);
            UtilityTestData.mEntitlement.put('Status','Active');
            UtilityTestData.mEntitlement.put('StartDate',system.today().addDays(-10)+'');
            UtilityTestData.mEntitlement.put('EndDate',system.today().addYears(1)+'');
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEntitlement);
            List<Entitlement> lEntitlement = (List<Entitlement>) UtilityTest.makeInsert(new List<sObject>{sObj});
            lEntitlement[0].assetid = assetrec.Id;
            //lEntitlement[0].Order_Product__c = amendedOrderItems[0].Id;
            update lEntitlement[0];
            
            List<SlaProcess> lstEntitlementProcess = [SELECT Id, Name FROM SlaProcess WHERE Name='Signature Success' and IsActive = true LIMIT 1];
            system.debug('@@lstEntitlementProcess= '+lstEntitlementProcess);
            if (lstEntitlementProcess.size()>0)
            {
                Entitlement updateEntitlementRec = new Entitlement();
                updateEntitlementRec.Id = lEntitlement[0].Id;
                updateEntitlementRec.SlaProcessId = lstEntitlementProcess[0].id;
                update updateEntitlementRec;        
            } 
         
         
          RecordType rt1 = [select id,Name from RecordType where SobjectType='Case' and DeveloperName='Technical' Limit 1];
        //create a Case record
        sObj = new Case();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
        sObj.put('OwnerId', UserInfo.getUserId());
        sObj.put('ContactId', lContact[0].Id);
        sObj.put('AccountId', lAccount[0].Id);
        sObj.put('Forecast_Product__c','Product 360 (Media Manager)');
         sObj.put('Environment__c','QA');
        sObj.put('Support_Account__c', lAccount1[0].Id);
        sObj.put('RecordTypeId', rt1.Id);
        UtilityTest.makeInsert(new List<sObject>{sObj});
       
      }
     }
   
    public static testMethod void testbatch(){ 
        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
    	Test.startTest();
            Account acc = [select id from Account where recordtypeid = :SupportAccountRecType limit 1];
            Set<Id> supportaccids = new Set<Id>();
         	supportaccids.add(acc.Id);
			EntitledProductServicesBatch esb = new EntitledProductServicesBatch(supportaccids);
			database.executeBatch(esb);
        Test.stopTest();
    }   
    

    public static testMethod void xsSupportDate(){ //T01
     
        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();

      Entitled_Product__c ep=[select Id,Extended_Support__c,Extended_Support_End_Date__c from Entitled_Product__c limit 1];
      ep.Extended_Support__c=true;      
      ep.Extended_Support_End_Date__c=Date.today()-2; //validations are muted for logged n user in test data setup  
      update ep;
          
      
    Test.startTest();
          Account acc = [select id from Account where recordtypeid = :SupportAccountRecType limit 1];
          Set<Id> supportaccids = new Set<Id>();
          supportaccids.add(acc.Id);
       EntitledProductServicesBatch esb = new EntitledProductServicesBatch(supportaccids);
       database.executeBatch(esb);
      Test.stopTest();
      ep=[select Id,Extended_Support__c,Extended_Support_End_Date__c from Entitled_Product__c limit 1];
      system.assertEquals(ep.Extended_Support__c, false);
     
      
  }    
    
}