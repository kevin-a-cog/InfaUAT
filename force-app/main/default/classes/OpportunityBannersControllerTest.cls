/*
Class:  OpportunityBannersControllerTest
        @Author:        Sreerekha
        @Created Date:  25 May 2023
        @Jira:          SALESRT-15120
        @Description:   Test Class for OpportunityBannersController Class.
*/

@isTest
public with sharing class OpportunityBannersControllerTest {
    @testSetup
    static void setupObjectTestData() {
        sObject sObj = new blng__BillingRule__c();
        
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
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
        
        sObject sObjProd = new Product2();
        UtilityTestData.mProduct2Data.put('Name','Test Product');
        UtilityTestData.mProduct2Data.put('blng__BillingRule__c',lBillingRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__RevenueRecognitionRule__c',lRevRecRule[0].Id);
        UtilityTestData.mProduct2Data.put('blng__TaxRule__c',lTaxRule[0].Id);
        //UtilityTestData.mProduct2Data.put('Orderable__c','False');
        sObjProd = UtilityTest.putFieldRecord(sObjProd, UtilityTestData.mProduct2Data);
        List<Product2> lProduct2 = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj,sObjProd});
        
        
        Id pricebookId = Test.getStandardPricebookId(); 
        
        sObj = new Pricebook2(Id = pricebookId,IsActive = True);
        List<Pricebook2> lPriceBook2 = (List<Pricebook2>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        
        sObj = new pricebookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',pricebookId);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);
        
        sObject sObjPBE = new pricebookEntry();
        UtilityTestData.mPriceBookEntryData.put('Pricebook2Id',pricebookId);
        UtilityTestData.mPriceBookEntryData.put('Product2Id',lProduct2[1].Id);
        sObjPBE = UtilityTest.putFieldRecord(sObjPBE, UtilityTestData.mPriceBookEntryData);
        List<pricebookEntry> lPriceBookEntry = (List<pricebookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj,sObjPBE});
        
        User_Exemptions__c settings = User_Exemptions__c.getOrgDefaults();
        settings.Ignore_Validation_Rules__c = true;
        upsert settings User_Exemptions__c.Id;
        
        sObj = new Account();
        UtilityTestData.mAccountData.put('RecordTypeId',Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId());  
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);

        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new blng__LegalEntity__c();
        UtilityTestData.mLegalEntityData.put('Name','test');
        UtilityTestData.mLegalEntityData.put('Business_Unit_Code__c','US001');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mLegalEntityData);
        List<blng__LegalEntity__c> lLegalEntity = (List<blng__LegalEntity__c>) UtilityTest.makeInsert(new List<sObject>{sObj});

        sObj = new Contact();
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //Creating Primary Opportunity
        sObject sObjPrimaryOpp = new Opportunity();
        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Primary_or_Secondary__c','Primary');
        sObjPrimaryOpp = UtilityTest.putFieldRecord(sObjPrimaryOpp, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunityP = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObjPrimaryOpp});
        
        //update the pricebook on Opty
        sObj = new Opportunity(id = lOpportunityP[0].Id, Pricebook2Id = pricebookId);
        lOpportunityP = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj});

        sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('AccountId',lAccount[0].Id);        
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunityP[0].Id);
        UtilityTestData.mSBQuoteData.put('Shipping_Preference__c','Email');
        UtilityTestData.mSBQuoteData.put('SBQQ__BillingName__c','Test user');
        UtilityTestData.mSBQuoteData.put('SBQQ__ShippingName__c','Test user');
        UtilityTestData.mSBQuoteData.put('Shipping_Email__c','test@email.com');
        UtilityTestData.mSBQuoteData.put('SBQQ__ShippingCountry__c','USA');
        UtilityTestData.mSBQuoteData.put('Legal_Entity__c',lLegalEntity[0].Id);
        UtilityTestData.mSBQuoteData.put('PO__c','123213');
        UtilityTestData.mSBQuoteData.put('BillToAccount__c',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('ShiptToAccount__c',lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Contract();
        UtilityTestData.mContractData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mContractData.put('Status','Draft');
        UtilityTestData.mContractData.put('SBQQ__Opportunity__c',lOpportunityP[0].Id);
        UtilityTestData.mContractData.put('SBQQ__RenewalOpportunity__c',lOpportunityP[0].Id);
        UtilityTestData.mContractData.put('Amendment_Contracted_Date_Time__c', System.today().addDays(1) + '');
        UtilityTestData.mContractData.put('StartDate',System.today()+'');
        UtilityTestData.mContractData.put('SBQQ__Quote__c',lQuote[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContractData);
        List<Contract> lContract = (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});  
    }

    @isTest
        static void checkAllocationPR(){

        User userObj = [select Id, Name from User where Name = 'INFA Integrator'  and IsActive = true limit 1];
        List<Opportunity> Opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<Account> Acc = [SELECT Id from Account LIMIT 1];

        System.runAs(userObj) {
            //Create partner relationship record
            UtilityTestData.mPartnerRelationshipData.put('Opportunity__c',Opp[0].Id);
            UtilityTestData.mPartnerRelationshipData.put('Partner_Role__c','OEM');
            UtilityTestData.mPartnerRelationshipData.put('Partner_Account__c',Acc[0].Id);
            UtilityTestData.mPartnerRelationshipData.put('Allocated__c','100');
            
            Test.startTest();
                //Create Partner_Relationship__c sObject
                sObject partreln = new Partner_Relationship__c();
                partreln = UtilityTest.putFieldRecord(partreln, UtilityTestData.mPartnerRelationshipData);
                List<SObject> tempList = (List<Partner_Relationship__c>)UtilityTest.makeInsert(new list<sObject>{partreln});
                
                Boolean result = OpportunityBannersController.checkAllocationPR(Opp[0].Id);
            Test.stopTest();
        }
    }

    @isTest
    private static void testCheckOutOfSync(){

        List<Opportunity> oppList = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
            Boolean result = OpportunityBannersController.checkOutOfSync(oppList[0].Id);
            System.assertEquals(true, result);
        Test.stopTest();
    }
}