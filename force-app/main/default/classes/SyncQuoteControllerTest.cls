/*
Class:          SyncQuoteControllerTest
@Author:        Sumitkumar Mittal
@Created Date:  05/10/2018
@Description:   test class for SyncQuoteController
Change History
***************************************************************************************
ModifiedBy          Date        Requested By        Description                 Tag

***************************************************************************************
*/

@isTest
private class SyncQuoteControllerTest {
    
    private Final Static String vEmployee = Label.Profile_Employee;
    private Final Static String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
    
    @testSetup
    static void setupObjectTestData() {    
        
        Id pbId = Test.getStandardPricebookId();
        //Insert Account setup data
        sObject sObj = new Account();
        sObject sObj1 = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Insert contact
        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Inserting an Opportunity
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('StageName', 'Identify');
        UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_NEW_SALES_RT).getRecordTypeId());
        UtilityTestData.mOpportunityData.put('Type', 'Upsell');    
        //UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c', 'Primary');   
        UtilityTestData.mOpportunityData.put('Name', 'Primary');
        UtilityTestData.mOpportunityData.put('CloseDate', System.Today() + ''); 
        //UtilityTestData.mOpportunityData.put('DaaS_Subscription__c', '0');
        //UtilityTestData.mOpportunityData.put('Cloud_Subscription__c', '0');
        //UtilityTestData.mOpportunityData.put('On_Prem_Perpetual__c', '0');
        //UtilityTestData.mOpportunityData.put('On_Prem_Subscription__c', '0'); 
        UtilityTestData.mOpportunityData.put('Split_Percentage__c', '30');    
        UtilityTestData.mOpportunityData.put('Pricebook2Id', pbId);            
        sObj = new Opportunity();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        
        //System.assertEquals(lOpportunityPrimary.size(), 1);
        
        //update the pricebook on Opty
        //sObj = new Opportunity(id = lOpportunityPrimary[0].Id, Pricebook2Id = pbId);
        //lOpportunityPrimary = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        
        //List<Opportunity> lstOppty = new List<Opportunity>([SELECT Pricebook2Id FROM Opportunity WHERE Id =: lOpportunityPrimary[0].Id]); 
        
        //List<PricebookEntry> lstPBE = new List<PricebookEntry>([Select Id from PricebookEntry WHERE PriceBook2Id =: lstOppty[0].Pricebook2Id]);   
        
        //Creating Secondary Opportunity
        sObj1 = new Opportunity();
        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        //UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c','Secondary');
        UtilityTestData.mOpportunityData.put('Name', 'Secondary');
        UtilityTestData.mOpportunityData.put('Split_Percentage__c', '70'); 
        UtilityTestData.mOpportunityData.put('Pricebook2Id ', pbId); 
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        //update the pricebook on Opty
        sObj = new Opportunity(id = lOpportunity[0].Id, Pricebook2Id = pbId);
        sObj1 = new Opportunity(id = lOpportunity[1].Id, Pricebook2Id = pbId);
        lOpportunity = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj,sObj1});
        
        //Insert Opportunity Contact Roles
        UtilityTestData.mOpportunityContactRoleData.put('OpportunityId', lOpportunity[0].Id);
        UtilityTestData.mOpportunityContactRoleData.put('ContactId', lContact[0].Id);
        sObj = new OpportunityContactRole();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityContactRoleData);
        List<OpportunityContactRole> lContactRoles = (List<OpportunityContactRole>) UtilityTest.makeInsert(new List<sObject>{sObj});    
        
        //Insert Opportunity Team members
        UtilityTestData.mOpportunityTeamMemberData.put('OpportunityId', lOpportunity[0].Id);
        UtilityTestData.mOpportunityTeamMemberData.put('UserId',UserInfo.getUserId());
        sObj = new OpportunityTeamMember ();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityTeamMemberData);
        List<OpportunityTeamMember> lOpportunityTeamMembers = (List<OpportunityTeamMember>) UtilityTest.makeInsert(new List<sObject>{sObj});    
        
        //create standard Pricebook
        
        sObj = new Pricebook2(Id = pbId,IsActive = True);
        List<Pricebook2> lPriceBookId = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        
        sObj = new Product2();
        UtilityTestData.mProduct2Data.put('Family', 'DaaS Subscription');
        UtilityTestData.mProduct2Data.put('ProductCode', 'Pro-X1');
        UtilityTestData.mProduct2Data.put('IsActive', 'True');
        UtilityTestData.mProduct2Data.put('SBQQ__ChargeType__c','Recurring');
        UtilityTestData.mProduct2Data.put('SBQQ__BillingFrequency__c','Monthly');
        UtilityTestData.mProduct2Data.put('SBQQ__BillingType__c','Advance');
        UtilityTestData.mProduct2Data.put('Offering_Type__c','Cloud Hosted Subscription');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);        
         sObj1 = new Product2();
        UtilityTestData.mProduct2Data.put('Family', 'DaaS Subscription');
        UtilityTestData.mProduct2Data.put('ProductCode', 'Pro-X2');
        UtilityTestData.mProduct2Data.put('IsActive', 'True');
        UtilityTestData.mProduct2Data.put('SBQQ__ChargeType__c','Recurring');
        UtilityTestData.mProduct2Data.put('SBQQ__BillingFrequency__c','Monthly');
        UtilityTestData.mProduct2Data.put('SBQQ__BillingType__c','Advance');
        UtilityTestData.mProduct2Data.put('Offering_Type__c','Cloud Hosted Subscription');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProduct2Data);  
        
        sObject sObj2 = new Product2();           
        UtilityTestData.mProduct2Data.put('Family', 'Cloud Subscription');
        UtilityTestData.mProduct2Data.put('ProductCode', 'Pro-X3');
        UtilityTestData.mProduct2Data.put('IsActive', 'True'); 
        UtilityTestData.mProduct2Data.put('SBQQ__ChargeType__c','Recurring');
        UtilityTestData.mProduct2Data.put('SBQQ__BillingFrequency__c','Monthly');
        UtilityTestData.mProduct2Data.put('SBQQ__BillingType__c','Advance');
        UtilityTestData.mProduct2Data.put('Offering_Type__c','Cloud Hosted Subscription');    
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mProduct2Data);        
        sObject sObj3 = new Product2();
        UtilityTestData.mProduct2Data.put('Family', 'DaCloud Subscription');
        UtilityTestData.mProduct2Data.put('ProductCode', 'Pro-X4');
        UtilityTestData.mProduct2Data.put('IsActive', 'True');
        //UtilityTestData.mProduct2Data.put('Orderable__c', 'True');
        UtilityTestData.mProduct2Data.put('SBQQ__ChargeType__c','Recurring');
        UtilityTestData.mProduct2Data.put('SBQQ__BillingFrequency__c','Monthly');
        UtilityTestData.mProduct2Data.put('SBQQ__BillingType__c','Advance');
        UtilityTestData.mProduct2Data.put('Offering_Type__c','Cloud Hosted Subscription');
        sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mProduct2Data);
        sObject sObj4 = new Product2();
        UtilityTestData.mProduct2Data.put('Family', 'On-Premise Perpetual');
        UtilityTestData.mProduct2Data.put('ProductCode', 'Pro-X5');
        UtilityTestData.mProduct2Data.put('IsActive', 'True');
        //UtilityTestData.mProduct2Data.put('Orderable__c', 'False');
        UtilityTestData.mProduct2Data.put('SBQQ__ChargeType__c','Recurring');
        UtilityTestData.mProduct2Data.put('SBQQ__BillingFrequency__c','Monthly');
        UtilityTestData.mProduct2Data.put('SBQQ__BillingType__c','Advance');
        UtilityTestData.mProduct2Data.put('Offering_Type__c','Cloud Hosted Subscription');
        sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mProduct2Data);
        sObject sObj5 = new Product2();
        UtilityTestData.mProduct2Data.put('Family', 'On-Premise Perpetual1');
        UtilityTestData.mProduct2Data.put('ProductCode', 'Pro-X6');
        UtilityTestData.mProduct2Data.put('IsActive', 'True');
        //UtilityTestData.mProduct2Data.put('Orderable__c', 'False');
        UtilityTestData.mProduct2Data.put('SBQQ__ChargeType__c','Recurring');
        UtilityTestData.mProduct2Data.put('SBQQ__BillingFrequency__c','Monthly');
        UtilityTestData.mProduct2Data.put('SBQQ__BillingType__c','Advance');
        UtilityTestData.mProduct2Data.put('Offering_Type__c','Cloud Hosted Subscription');
        sObj5 = UtilityTest.putFieldRecord(sObj5, UtilityTestData.mProduct2Data);
        sObject sObj6 = new Product2();
        UtilityTestData.mProduct2Data.put('Family', 'On-Premise Subscription');
        UtilityTestData.mProduct2Data.put('ProductCode', 'Pro-X8');
        UtilityTestData.mProduct2Data.put('IsActive', 'True');
        UtilityTestData.mProduct2Data.put('SBQQ__ChargeType__c','Recurring');
        UtilityTestData.mProduct2Data.put('SBQQ__BillingFrequency__c','Monthly');
        UtilityTestData.mProduct2Data.put('SBQQ__BillingType__c','Advance');
        UtilityTestData.mProduct2Data.put('Offering_Type__c','Cloud Hosted Subscription');
        sObj6 = UtilityTest.putFieldRecord(sObj6, UtilityTestData.mProduct2Data);        
        sObject sObj7 = new Product2();
        UtilityTestData.mProduct2Data.put('Family', 'On-Premise Subscription');
        UtilityTestData.mProduct2Data.put('ProductCode', 'Pro-X9');
        UtilityTestData.mProduct2Data.put('IsActive', 'True');
        UtilityTestData.mProduct2Data.put('SBQQ__ChargeType__c','Recurring');
        UtilityTestData.mProduct2Data.put('SBQQ__BillingFrequency__c','Monthly');
        UtilityTestData.mProduct2Data.put('SBQQ__BillingType__c','Advance');
        UtilityTestData.mProduct2Data.put('Offering_Type__c','Cloud Hosted Subscription');
        sObj7 = UtilityTest.putFieldRecord(sObj7, UtilityTestData.mProduct2Data);
        List<Product2> lProduct = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1, sObj2, sObj3,sObj4, sObj5, sObj6, sObj7});
        System.assertEquals(lProduct.size(), 8);
        
        // 1. Insert a price book entry for the standard price book.
        UtilityTestData.mPriceBookEntryData.put('UnitPrice', '1000');
        sObj = new PriceBookEntry(Pricebook2Id = pbId , Product2Id=lProduct[0].Id + '');        
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);        
        sObj1 = new PriceBookEntry(Pricebook2Id = pbId , Product2Id=lProduct[1].Id + '' );
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mPriceBookEntryData);        
        sObj2 = new PriceBookEntry(Pricebook2Id = pbId , Product2Id=lProduct[2].Id + '' );
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mPriceBookEntryData);        
        sObj3 = new PriceBookEntry(Pricebook2Id = pbId , Product2Id=lProduct[3].Id + '' );
        sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mPriceBookEntryData);        
        sObj4 = new PriceBookEntry(Pricebook2Id = pbId , Product2Id=lProduct[4].Id + '' );
        sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mPriceBookEntryData);        
        sObj5 = new PriceBookEntry(Pricebook2Id = pbId , Product2Id=lProduct[5].Id + '' );
        sObj5 = UtilityTest.putFieldRecord(sObj5, UtilityTestData.mPriceBookEntryData);        
        sObj6= new PriceBookEntry(Pricebook2Id = pbId , Product2Id=lProduct[6].Id + '' );
        sObj6 = UtilityTest.putFieldRecord(sObj6, UtilityTestData.mPriceBookEntryData);        
        sObj7 = new PriceBookEntry(Pricebook2Id = pbId , Product2Id=lProduct[7].Id + '' );
        sObj7 = UtilityTest.putFieldRecord(sObj7, UtilityTestData.mPriceBookEntryData);
        List<PriceBookEntry> lPriceBookEntry = (List<PriceBookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1, sObj2,sObj3, sObj4, sObj5, sObj6, sObj7});
        System.assertEquals(lPriceBookEntry.size(),8);
        Test.startTest();
        //Add OLI on Primary Opportunity
        sObject sObjOppLineItem = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunity[0].Id);
        UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[0].Id);
        sObjOppLineItem = UtilityTest.putFieldRecord(sObjOppLineItem ,UtilityTestData.mOpportunityProdData);        
        
        sObject sObjOppLineItem1 = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunity[1].Id);
        UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[1].Id);
        sObjOppLineItem1 = UtilityTest.putFieldRecord(sObjOppLineItem1 ,UtilityTestData.mOpportunityProdData);
        
        sObject sObjOppLineItem2 = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunity[0].Id);
        UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[2].Id);
        sObjOppLineItem2 = UtilityTest.putFieldRecord(sObjOppLineItem2 ,UtilityTestData.mOpportunityProdData);
        
        sObject sObjOppLineItem3 = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunity[1].Id);
        UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[3].Id);
        sObjOppLineItem3 = UtilityTest.putFieldRecord(sObjOppLineItem3 ,UtilityTestData.mOpportunityProdData);
        
        sObject sObjOppLineItem4 = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunity[0].Id);
        UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[4].Id);
        sObjOppLineItem4 = UtilityTest.putFieldRecord(sObjOppLineItem4 ,UtilityTestData.mOpportunityProdData);
        
        sObject sObjOppLineItem5 = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunity[1].Id);
        UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[5].Id);
        sObjOppLineItem5 = UtilityTest.putFieldRecord(sObjOppLineItem5 ,UtilityTestData.mOpportunityProdData);
        
        sObject sObjOppLineItem6 = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunity[0].Id);
        UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[6].Id);
        sObjOppLineItem6 = UtilityTest.putFieldRecord(sObjOppLineItem6 ,UtilityTestData.mOpportunityProdData);
        
        sObject sObjOppLineItem7 = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunity[1].Id);
        UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[7].Id);
        sObjOppLineItem7 = UtilityTest.putFieldRecord(sObjOppLineItem7 ,UtilityTestData.mOpportunityProdData);
        
        List<OpportunityLineItem> lstOpportunityLineItem = (List<OpportunityLineItem>) UtilityTest.makeInsert(new List<sObject>{sObjOppLineItem,
            sObjOppLineItem1,
            sObjOppLineItem2,
            sObjOppLineItem3,
            sObjOppLineItem4,
            sObjOppLineItem5,
            sObjOppLineItem6,
            sObjOppLineItem7});
        system.assertEquals(lstOpportunityLineItem.size(),8);  
        Test.stopTest();
        
    }//END static void setupTestData()
    
    
    /*
Below methods are covering the class. Commented as the check for secondary is not needed .
*/
    @isTest
     static void myUnitTest_OLI_InsertUpdate() {
        
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(userObj) { 
            Test.StartTest();
            
            List<Opportunity> lOpportunityPrimary = (List<Opportunity>) UtilityTest.executeQuery('Select Id, Split_Percentage__c from Opportunity where Split_Percentage__c = 30 Limit 1');
            system.assertEquals(lOpportunityPrimary.size(),1);
            List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.executeQuery('Select Id from Opportunity where Split_Percentage__c = 70 Limit 1'); //Removed where Primary_or_Secondary__c =\'Secondary\'
            system.assertEquals(lOpportunity.size(),1);
            
            List<PriceBookEntry> lPriceBookEntryOrderableTrue = (List<PriceBookEntry>) UtilityTest.executeQuery('Select Id from PriceBookEntry Limit 1');
            system.assertEquals(lPriceBookEntryOrderableTrue.size(),1);
            
            sObject sObjOppLineItem = new OpportunityLineItem();
            UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunity[0].Id);
            UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntryOrderableTrue[0].Id);
            sObjOppLineItem = UtilityTest.putFieldRecord(sObjOppLineItem ,UtilityTestData.mOpportunityProdData);
            sObject sObjOppLineItem1 = new OpportunityLineItem();
            UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunityPrimary[0].Id);
            UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntryOrderableTrue[0].Id);
            sObjOppLineItem1 = UtilityTest.putFieldRecord(sObjOppLineItem1 ,UtilityTestData.mOpportunityProdData);
            sObject sObjOppLineItem2 = new OpportunityLineItem();
            UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunityPrimary[0].Id);
            UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntryOrderableTrue[0].Id);
            sObjOppLineItem2 = UtilityTest.putFieldRecord(sObjOppLineItem2 ,UtilityTestData.mOpportunityProdData);
            sObject sObjOppLineItem3 = new OpportunityLineItem();
            UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunityPrimary[0].Id);
            UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntryOrderableTrue[0].Id);
            sObjOppLineItem3 = UtilityTest.putFieldRecord(sObjOppLineItem3 ,UtilityTestData.mOpportunityProdData);
            
            List<OpportunityLineItem> lstOpportunityLineItem = (List<OpportunityLineItem>) UtilityTest.makeInsert(new List<sObject>{sObjOppLineItem, sObjOppLineItem1, sObjOppLineItem2, sObjOppLineItem3});
            system.assertEquals(lstOpportunityLineItem.size(), 4);
            
            sObject sObj = new Opportunity(Id = lOpportunity[0].Id /*,Related_Opportunity__c = lOpportunityPrimary[0].id*/, Split_From__c = lOpportunityPrimary[0].id);
            List<Opportunity> lOpptySecUpdate = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            
            
            sObj = new Opportunity(Id = lOpportunityPrimary[0].Id /*,Related_Opportunity__c = lOpportunity[0].id*/);
            List<Opportunity> lOpptyPrimaryUpdate = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj});
            
            String result = syncQuoteController.syncQuoteSecondary(lOpportunity[0].Id, 0.3);
            System.assert(result.contains('True'));
            String result1=syncQuoteController.syncQuotePrimary(lOpportunityPrimary[0].Id,lOpportunityPrimary[0].Split_Percentage__c);
            System.assert(result1.contains('False'));
            Test.StopTest();
        }
        
    }
  
    
    /**
* This method will test the functionality to update field:Sales Price of Opportunity Line Items for Primary Opportunity
* 
*/
    @isTest
    static void unitTestSyncQuotePrimary() {
        //insert quote;   
        Test.startTest();
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<Opportunity> lOpportunityPrimary = (List<Opportunity>) UtilityTest.executeQuery('Select Id, Split_Percentage__c from Opportunity where Name =\'Primary\' Limit 1');
        system.assertEquals(lOpportunityPrimary.size(),1);
        List<Account> lAccount = (List<Account>) UtilityTest.executeQuery('Select Id from Account Limit 1');
        system.assertEquals(lAccount.size(),1);
        List<Contact> lContact = (List<Contact>) UtilityTest.executeQuery('Select Id from Contact Limit 1');
        system.assertEquals(lContact.size(),1);
        
        System.runAs(userObj) {           
            
            sObject sObj = new SBQQ__Quote__c();
            UtilityTestData.mSBQuoteData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunityPrimary[0].Id);
            UtilityTestData.mSBQuoteData.put('Shipping_Preference__c','Email');
            UtilityTestData.mSBQuoteData.put('BillToAccount__c',lAccount[0].Id);
            UtilityTestData.mSBQuoteData.put('ShiptToAccount__c',lAccount[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
            //List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});   
         
            String result=syncQuoteController.syncQuotePrimary(lOpportunityPrimary[0].Id,lOpportunityPrimary[0].Split_Percentage__c);
            System.assert(!result.contains('True'));
            
        }
         Test.stopTest();
    }
    
    /**
* This method will tests the Sales price is properly updated or not.
* 
*/
    @isTest
    static void unitTestUpdatedSalesPrice() {
        
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(userObj) { 
            Decimal split_Percentage=30;
            Decimal total_ACV=2;
            Decimal current_TCV=0;
            
            Decimal result=syncQuoteController.getUpdatedSalesPrice(split_Percentage/100,total_ACV,current_TCV);
            System.assertEquals(0.6, result);
            
            total_ACV=null;
            current_TCV=null;
            result=syncQuoteController.getUpdatedSalesPrice(split_Percentage/100,total_ACV,current_TCV);
            System.assertEquals(-1, result);
            
            total_ACV=null;
            current_TCV=2;
            result=syncQuoteController.getUpdatedSalesPrice(split_Percentage/100,total_ACV,current_TCV);
            System.assertEquals(0.6, result);
        }
    }
    
    @isTest
    public static void unitTestExceptions() {
        
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        
        System.runAs(userObj) { 
            
            Decimal split_Percentage=0;
            Decimal total_ACV=2;
            Decimal current_TCV=0;
            
            Decimal result=syncQuoteController.getUpdatedSalesPrice(split_Percentage/100,total_ACV,current_TCV);
            System.assertEquals(-1, result);
            
            total_ACV=null;
            current_TCV=null;
            result=syncQuoteController.getUpdatedSalesPrice(split_Percentage/100,total_ACV,current_TCV);
            System.assertEquals(-1, result);
            
            total_ACV=null;
            current_TCV=2;
            result=syncQuoteController.getUpdatedSalesPrice(split_Percentage/100,total_ACV,current_TCV);
            System.assertEquals(-1, result);
        }
        
    }

    @isTest
    static void syncQuotePrimaryTest() {
        //insert quote;   
        Test.startTest();
        User userObj = [select Id, Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        List<Opportunity> lOpportunityPrimary = (List<Opportunity>) UtilityTest.executeQuery('Select Id, Split_Percentage__c from Opportunity where Name =\'Primary\' Limit 1');
        system.assertEquals(lOpportunityPrimary.size(),1);
        List<Account> lAccount = (List<Account>) UtilityTest.executeQuery('Select Id from Account Limit 1');
        system.assertEquals(lAccount.size(),1);
        List<Contact> lContact = (List<Contact>) UtilityTest.executeQuery('Select Id from Contact Limit 1');
        system.assertEquals(lContact.size(),1);
        
        System.runAs(userObj) {           
            
            sObject sObj = new SBQQ__Quote__c();
            UtilityTestData.mSBQuoteData.put('SBQQ__Account__c',lAccount[0].Id);
            UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunityPrimary[0].Id);
            UtilityTestData.mSBQuoteData.put('Shipping_Preference__c','Email');
            UtilityTestData.mSBQuoteData.put('BillToAccount__c',lAccount[0].Id);
            UtilityTestData.mSBQuoteData.put('ShiptToAccount__c',lAccount[0].Id);
            sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
            List<SBQQ__Quote__c> lSBQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});   
         
            String result=syncQuoteController.syncQuotePrimary(lOpportunityPrimary[0].Id,lOpportunityPrimary[0].Split_Percentage__c);
            
        }
         Test.stopTest();
    }
    
}