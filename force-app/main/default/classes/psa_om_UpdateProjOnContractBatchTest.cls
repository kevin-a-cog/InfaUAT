/*
@created by       : MAHESH GANTI
@created on       : 12/28/2020
@Purpose          : Test class for psa_om_UpdateProjectOnContractBatch 

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
@isTest
public class psa_om_UpdateProjOnContractBatchTest {
    
    @testSetup
    static void setupObjectTestData() {
        sObject sObj;
        
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
    }

    static testMethod void testContractBatch(){
        List<Contract> contList = [SELECT id,Name,SBQQ__Opportunity__c,PSA_OM_Project__c FROM Contract];
        system.debug('*****contList***'+contList);
        Test.startTest();
            psa_om_UpdateProjectOnContractBatch contBatch = new psa_om_UpdateProjectOnContractBatch();
            Id batchId = Database.executeBatch(contBatch);
            // psa_om_AmmendOpportunityHandler.updateProjectIdOnContract(contList);
        Test.stopTest(); 
    }
    
}