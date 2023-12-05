/*
@created by       : MAHESH GANTI
@created on       : 12/28/2020
@Purpose          : Test class for psa_om_AmmendOpportunityHandler 

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
@isTest
public class psa_om_AmmendOpportunityHandlerTest {
    
    @testSetup
    static void setupObjectTestData() {
        sObject sObj;
        sObject sObj1;
        sObject sObj2;
        
        
        sObj = new Account();
        UtilityTestData.mAccountData.put('Name','Testing');
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
        UtilityTestData.mOpportunityData.put('StageName','Validate');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        Test.startTest();
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('AccountId',lAccount[0].Id);        
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunity[0].Id);
        UtilityTestData.mSBQuoteData.put('Shipping_Preference__c','Email');
        UtilityTestData.mSBQuoteData.put('SBQQ__BillingName__c','Test user');
        UtilityTestData.mSBQuoteData.put('SBQQ__ShippingName__c','Test user');
        UtilityTestData.mSBQuoteData.put('Shipping_Email__c','test@email.com');
        UtilityTestData.mSBQuoteData.put('PO__c','123213');
        UtilityTestData.mSBQuoteData.put('BillToAccount__c',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('ShiptToAccount__c',lAccount[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Contract();
        UtilityTestData.mContractData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mContractData.put('Status','Draft');
        UtilityTestData.mContractData.put('SBQQ__Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mContractData.put('StartDate',System.today()+'');
        UtilityTestData.mContractData.put('Business_Model__c','Standard');
        UtilityTestData.mContractData.put('SBQQ__Quote__c',lQuote[0].Id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContractData);
        List<Contract> lContract = (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new pse__Proj__c();
        UtilityTestData.mProjectData.put('pse__Account__c',lAccount[0].Id);
        UtilityTestData.mProjectData.put('pse__Project_Manager__c',lContact[0].Id);
        UtilityTestData.mProjectData.put('pse__Project_Type__c','Customer Project');
        UtilityTestData.mProjectData.put('psa_pm_Project_Sub_Type__c','JumpStart');
        UtilityTestData.mProjectData.put('pse__Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mProjectData.put('pse__Is_Active__c','true');//
        UtilityTestData.mProjectData.put('pse__Start_Date__c',System.today().addDays(1)+'');
        UtilityTestData.mProjectData.put('pse__End_Date__c',System.today().addDays(10)+''); 
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProjectData);
        List<pse__Proj__c> lProject = (List<pse__Proj__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        Test.stopTest();
        
    }
    
    static testMethod void testupdateProjectIdOnContract(){
        List<Contract> contList = [SELECT id,Name,SBQQ__Opportunity__c,PSA_OM_Project__c FROM Contract];
        system.debug('*****contList***'+contList);
        Test.startTest();
        psa_om_AmmendOpportunityHandler.updateProjectIdOnContract(contList);
        Test.stopTest(); 
    }
    
    static testMethod void testpopulateProjectOnAmendOpportunity(){
        sObject sObj1;
        List<Account> lAccount = [SELECT Id from Account];
        List<Opportunity> lOpportunity = [SELECT Id from Opportunity];
        List<SBQQ__Quote__c> lQuote = [SELECT Id from SBQQ__Quote__c];
        List<pse__Proj__c> lProject = [SELECT Id from pse__Proj__c];
        
        sObj1 = new Contract();
        UtilityTestData.mContractData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mContractData.put('Status','Draft');
        UtilityTestData.mContractData.put('SBQQ__Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mContractData.put('StartDate',System.today()+'');
        UtilityTestData.mContractData.put('Business_Model__c','Standard');
        UtilityTestData.mContractData.put('SBQQ__Quote__c',lQuote[0].Id);
        UtilityTestData.mContractData.put('PSA_OM_Project__c',lProject[0].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mContractData);
        List<Contract> newContract = (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj1});
        
        sObj1 = new Opportunity();
        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Type','Direct');
        UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
        UtilityTestData.mOpportunityData.put('StageName','Validate');
        UtilityTestData.mOpportunityData.put('SBQQ__AmendedContract__c',newContract[0].Id);
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityData);
        
        Test.startTest();
        List<Opportunity> newOppRec = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj1});
        Test.stopTest(); 
    }
    
    static testMethod void testcheckIfProjectExistsForPSOpps(){
        sObject sObj;
        sObject sObj2;
        List<Account> lAccount = [SELECT Id from Account];
        
        sObj2 = new Opportunity();
        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Type','Direct');
        UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
        UtilityTestData.mOpportunityData.put('StageName','Validate');
        sObj2 = UtilityTest.putFieldRecord(sObj2, UtilityTestData.mOpportunityData);
        Test.startTest();
        List<Opportunity> validOppRec = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj2});
        
        Id StandardPbId = Test.getStandardPricebookId();
        sObj = new Opportunity(id = validOppRec[0].Id, Pricebook2Id = StandardPbId,StageName = 'Working');
        List<Opportunity> updateOppRec1 = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{sObj});
        system.debug('AFTER PRICEBOOK UPDATE'+updateOppRec1[0].StageName);
        
        sObj = new Product2();
        UtilityTestData.mProduct2Data.put('Family', 'DaaS Subscription');
        UtilityTestData.mProduct2Data.put('ProductCode', 'Pro-X1');
        UtilityTestData.mProduct2Data.put('IsActive', 'True');
        UtilityTestData.mProduct2Data.put('Offering_Type__c', 'Professional Services');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProduct2Data);
        List<Product2> lProduct = (List<Product2>) UtilityTest.makeInsert(new List<sObject>{sObj});
        Test.stopTest();
        sObj = new PriceBookEntry(UnitPrice=1000, isActive = true, UseStandardPrice = false, Pricebook2Id = StandardPbId, Product2Id=lProduct[0].Id + '' );
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPriceBookEntryData);
        List<PriceBookEntry> lPriceBookEntry = (List<PriceBookEntry>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObject sObjOppLineItem = new OpportunityLineItem();
        UtilityTestData.mOpportunityProdData.put('OpportunityId', validOppRec[0].Id);
        UtilityTestData.mOpportunityProdData.put('PricebookEntryId', lPriceBookEntry[0].Id);
        sObjOppLineItem = UtilityTest.putFieldRecord(sObjOppLineItem ,UtilityTestData.mOpportunityProdData);
        List<OpportunityLineItem> lstOpportunityLineItem = (List<OpportunityLineItem>) UtilityTest.makeInsert(new List<sObject>{sObjOppLineItem});
        
        
        sObject updOppRec = new Opportunity(Id = updateOppRec1[0].Id ,StageName = 'Closed Won');
        system.debug('before stage update'+updOppRec);
        List<Opportunity> lOpptyUpdate = (List<Opportunity>) UtilityTest.makeUpdate(new List<sObject>{updOppRec});
        system.debug('After stage update'+updOppRec);
         
        
    }
    
}