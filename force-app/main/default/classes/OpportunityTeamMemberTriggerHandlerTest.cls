/*
Class:          OpportunityTeamMemberTriggerHandlerTest
@Author:        Sumitkumar Mittal
@Created Date:  04/30/2018
@Description:   test class for OpportunityTeamMemberTriggerHandler
Change History
******************************************************************
ModifiedBy          Date        Requested By        Description                 Tag

******************************************************************
*/

@isTest
private class OpportunityTeamMemberTriggerHandlerTest {
    
    private Final Static String vEmployee = Label.Profile_Employee;
    private Final Static String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
    
    @testSetup
    static void setupObjectTestData() {    
        
        //Insert Account setup data
        sObject sObj = new Account();
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
        UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c', 'Primary');   
        UtilityTestData.mOpportunityData.put('CloseDate', System.Today() + '');       
        sObj = new Opportunity();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunityPrimary = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        System.assertEquals(lOpportunityPrimary.size(), 1);
        
        
        
        //create standard Pricebook
        Id pbId = Test.getStandardPricebookId();
        sObj = new Pricebook2(Id = pbId,IsActive = True);
        List<Pricebook2> lPriceBookId = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        
         //Creating multiple Product2 records
        sObj = new Product2();
        UtilityTestData.mProduct2Data.put('Family', 'DaaS Subscription');
        UtilityTestData.mProduct2Data.put('ProductCode', 'Pro-X1');
        UtilityTestData.mProduct2Data.put('IsActive', 'True');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);        
        sObject sObj1 = new Product2();
        UtilityTestData.mProduct2Data.put('Family', 'DaaS Subscription');
        UtilityTestData.mProduct2Data.put('ProductCode', 'Pro-X2');
        UtilityTestData.mProduct2Data.put('IsActive', 'True');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mProduct2Data);  
        sObject sObj2 = new Product2();           
        UtilityTestData.mProduct2Data.put('Family', 'Cloud Subscription');
        UtilityTestData.mProduct2Data.put('ProductCode', 'Pro-X3');
        UtilityTestData.mProduct2Data.put('IsActive', 'True');     
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mProduct2Data);        
        sObject sObj3 = new Product2();
        UtilityTestData.mProduct2Data.put('Family', 'DaCloud Subscription');
        UtilityTestData.mProduct2Data.put('ProductCode', 'Pro-X4');
        UtilityTestData.mProduct2Data.put('IsActive', 'True');
        UtilityTestData.mProduct2Data.put('Orderable__c', 'True');
        sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mProduct2Data);
        sObject sObj4 = new Product2();
        UtilityTestData.mProduct2Data.put('Family', 'On-Premise Perpetual');
        UtilityTestData.mProduct2Data.put('ProductCode', 'Pro-X5');
        UtilityTestData.mProduct2Data.put('IsActive', 'True');
        UtilityTestData.mProduct2Data.put('Orderable__c', 'False');
        sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mProduct2Data);
        sObject sObj5 = new Product2();
        UtilityTestData.mProduct2Data.put('Family', 'On-Premise Perpetual1');
        UtilityTestData.mProduct2Data.put('ProductCode', 'Pro-X6');
        UtilityTestData.mProduct2Data.put('IsActive', 'True');
        UtilityTestData.mProduct2Data.put('Orderable__c', 'False');
        sObj5 = UtilityTest.putFieldRecord(sObj5, UtilityTestData.mProduct2Data);
        sObject sObj6 = new Product2();
        UtilityTestData.mProduct2Data.put('Family', 'On-Premise Subscription');
        UtilityTestData.mProduct2Data.put('ProductCode', 'Pro-X8');
        UtilityTestData.mProduct2Data.put('IsActive', 'True');
        sObj6 = UtilityTest.putFieldRecord(sObj6, UtilityTestData.mProduct2Data);        
        sObject sObj7 = new Product2();
        UtilityTestData.mProduct2Data.put('Family', 'On-Premise Subscription');
        UtilityTestData.mProduct2Data.put('ProductCode', 'Pro-X9');
        UtilityTestData.mProduct2Data.put('IsActive', 'True');
        sObj7 = UtilityTest.putFieldRecord(sObj7, UtilityTestData.mProduct2Data);
        List<Product2> lProduct = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1, sObj2, sObj3,sObj4, sObj5, sObj6, sObj7});
        System.assertEquals(lProduct.size(), 8);
        
        // 1. Insert a price book entry for the standard price book.
        sObj = new PriceBookEntry(UnitPrice=1000, Pricebook2Id = lPriceBookId[0].Id, Product2Id=lProduct[0].Id + '' );
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);        
        sObj1 = new PriceBookEntry(UnitPrice=1000, Pricebook2Id = lPriceBookId[0].Id, Product2Id=lProduct[1].Id + '' );
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mPriceBookEntryData);        
        sObj2 = new PriceBookEntry(UnitPrice=1000, Pricebook2Id = lPriceBookId[0].Id, Product2Id=lProduct[2].Id + '' );
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mPriceBookEntryData);        
        sObj3 = new PriceBookEntry(UnitPrice=1000, Pricebook2Id = lPriceBookId[0].Id, Product2Id=lProduct[3].Id + '' );
        sObj3 = UtilityTest.putFieldRecord(sObj3, UtilityTestData.mPriceBookEntryData);        
        sObj4 = new PriceBookEntry(UnitPrice=1000, Pricebook2Id = lPriceBookId[0].Id, Product2Id=lProduct[4].Id + '' );
        sObj4 = UtilityTest.putFieldRecord(sObj4, UtilityTestData.mPriceBookEntryData);        
        sObj5 = new PriceBookEntry(UnitPrice=1000, Pricebook2Id = lPriceBookId[0].Id, Product2Id=lProduct[5].Id + '' );
        sObj5 = UtilityTest.putFieldRecord(sObj5, UtilityTestData.mPriceBookEntryData);        
        sObj6= new PriceBookEntry(UnitPrice=1000, Pricebook2Id = lPriceBookId[0].Id, Product2Id=lProduct[6].Id + '' );
        sObj6 = UtilityTest.putFieldRecord(sObj6, UtilityTestData.mPriceBookEntryData);        
        sObj7 = new PriceBookEntry(UnitPrice=1000, Pricebook2Id = lPriceBookId[0].Id, Product2Id=lProduct[7].Id + '' );
        sObj7 = UtilityTest.putFieldRecord(sObj7, UtilityTestData.mPriceBookEntryData);
        List<PriceBookEntry> lPriceBookEntry = (List<PriceBookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj, sObj1, sObj2,sObj3, sObj4, sObj5, sObj6, sObj7});
        System.assertEquals(lPriceBookEntry.size(),8);
        
        //Add OLI on Primary Opportunity
        sObject sObjOppLineItem = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunityPrimary[0].Id);
        UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[0].Id);
        sObjOppLineItem = UtilityTest.putFieldRecord(sObjOppLineItem ,UtilityTestData.mOpportunityProdData);
        
        
        sObject sObjOppLineItem1 = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunityPrimary[0].Id);
        UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[1].Id);
        sObjOppLineItem1 = UtilityTest.putFieldRecord(sObjOppLineItem1 ,UtilityTestData.mOpportunityProdData);
        
        sObject sObjOppLineItem2 = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunityPrimary[0].Id);
        UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[2].Id);
        sObjOppLineItem2 = UtilityTest.putFieldRecord(sObjOppLineItem2 ,UtilityTestData.mOpportunityProdData);
        
        sObject sObjOppLineItem3 = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunityPrimary[0].Id);
        UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[3].Id);
        sObjOppLineItem3 = UtilityTest.putFieldRecord(sObjOppLineItem3 ,UtilityTestData.mOpportunityProdData);
        
        sObject sObjOppLineItem4 = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunityPrimary[0].Id);
        UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[4].Id);
        sObjOppLineItem4 = UtilityTest.putFieldRecord(sObjOppLineItem4 ,UtilityTestData.mOpportunityProdData);
        
        sObject sObjOppLineItem5 = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunityPrimary[0].Id);
        UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[5].Id);
        sObjOppLineItem5 = UtilityTest.putFieldRecord(sObjOppLineItem5 ,UtilityTestData.mOpportunityProdData);
        
        sObject sObjOppLineItem6 = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunityPrimary[0].Id);
        UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[6].Id);
        sObjOppLineItem6 = UtilityTest.putFieldRecord(sObjOppLineItem6 ,UtilityTestData.mOpportunityProdData);
        
        sObject sObjOppLineItem7 = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', lOpportunityPrimary[0].Id);
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
        
    }//END static void setupTestData
    
    /*
Below methods are covering the class OpportunityTeamMemberTriggerHandler
*/
    /*static testMethod void myUnitTest_Insert_Update_Delete_TeamMembers() {
        
        List<Opportunity> lOpportunityPrimary = (List<Opportunity>) UtilityTest.executeQuery('Select Id, Related_Opportunity__c from Opportunity where Primary_or_Secondary__c =\'Primary\' Limit 1');
        system.assertEquals(lOpportunityPrimary.size(),1);
        
        Test.StartTest();
        
        //Insert Opportunity Team members
        UtilityTestData.mOpportunityTeamMemberData.put('OpportunityId', lOpportunityPrimary[0].Id);
        UtilityTestData.mOpportunityTeamMemberData.put('UserId',UserInfo.getUserId());

        sObject sObj = new OpportunityTeamMember ();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityTeamMemberData);
        List<OpportunityTeamMember> lOpportunityTeamMembers = (List<OpportunityTeamMember>) UtilityTest.makeInsert(new List<sObject>{sObj});
        System.assertEquals(lOpportunityTeamMembers.size(), 1);
        
        //Update Team Memeber Role on primary Oppty
        sObj = new OpportunityTeamMember(Id = lOpportunityTeamMembers[0].Id ,TeamMemberRole = 'BDM');
        List<OpportunityTeamMember> lOpptyTeamMemberUpdate = (List<OpportunityTeamMember>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        system.assertEquals(lOpptyTeamMemberUpdate.size(), 1);
        
        ////Delte Team Memeber  on Secondary Oppty
        List<OpportunityTeamMember> lOpptyTeamMemberToBeDelete = (List<OpportunityTeamMember>) UtilityTest.executeQuery('Select Id from OpportunityTeamMember where OpportunityId =\''+lOpportunityPrimary[0].Related_Opportunity__c +'\' Limit 1');
        delete lOpptyTeamMemberToBeDelete[0];
        system.assertEquals(lOpptyTeamMemberToBeDelete.size(),1);
        
        Test.StopTest();
    }*/
}