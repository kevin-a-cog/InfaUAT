/*
* Name			:	customLookUpControllerTest
* Author		:	Deva M
* Created Date	: 	28/09/2021
* Description	:	Test class for customLookUpController

Change History
**********************************************************************************************************
Modified By			Date			Jira No.		Description					Tag
**********************************************************************************************************
Deva M				28/09/2021		N/A				Initial version.			N/A
*/
@isTest
public class customLookUpControllerTest {
    static Id AccRecTypeId_PrtnrAccnt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();  
    static Id OpptyRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Sales Opportunity').getRecordTypeId();
    static Id OpptyRec1TypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Channel Opportunity').getRecordTypeId();
    @testSetup
    static void setupObjectTestData() {
        //create reselller partner account
        UtilityTestData.mAccountData.put('RecordTypeId',AccRecTypeId_PrtnrAccnt);
        UtilityTestData.mAccountData.put('PAL_PO_Completed__c','true');
        UtilityTestData.mAccountData.put('Payment_Terms__c','Net 60');
        UtilityTestData.mAccountData.put('Contract_Signed__c','true');
        UtilityTestData.mAccountData.put('RecorFCPA_Status__cdTypeId','Compliant');
        UtilityTestData.mAccountData.put('Sales_Percentage_of_Annual_Revenue__c','23');
        UtilityTestData.mAccountData.put('Year_Founded__c','2017');
        UtilityTestData.mAccountData.put('Vertical_Focus__c','Healthcare');
        UtilityTestData.mAccountData.put('Geographic_Area__c','North America');
        UtilityTestData.mAccountData.put('NumberOfEmployees','1');
        UtilityTestData.mAccountData.put('Email_Domain__c','PRM Test');
        UtilityTestData.mAccountData.put('Partner_Type__c','Software Reseller');
        sObject partnerAcc = new Account();
        partnerAcc = UtilityTest.putFieldRecord(partnerAcc, UtilityTestData.mAccountData);
        //Add all accounts to acclist
        List<Account> accList = (List<Account>) UtilityTest.makeInsert(new List<sObject>{partnerAcc}); 
        Account accRecord = accList[0];
        /*------------------------------------------------Test Opportunity---------------------------------------------------------------*/
        //Create Opportunity record
        UtilityTestData.mOpportunityData.put('RecordTypeId',OpptyRec1TypeId);
        UtilityTestData.mOpportunityData.put('Name','TestOppty');
        UtilityTestData.mOpportunityData.put('AccountId',accRecord.id);
        UtilityTestData.mOpportunityData.put('Sales_Play__c','Data Quality');
        UtilityTestData.mOpportunityData.put('Type','Direct');
        UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');        
        UtilityTestData.mOpportunityData.put('CloseDate','2018-02-05');
        
        //Create Opportunity sObject
        sObject channeloppty = new Opportunity();
        channeloppty = UtilityTest.putFieldRecord(channeloppty, UtilityTestData.mOpportunityData);
        
        //Create Opportunity record
        UtilityTestData.mOpportunityData.put('RecordTypeId',OpptyRecTypeId);
        UtilityTestData.mOpportunityData.put('Name','TestOppty1');
        
        //Add all opportunity to list
        List<Opportunity> opptyList = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{channeloppty});
        
        sObject sObj = new Contract();
        UtilityTestData.mContractData.put('AccountId', accRecord.Id);
        UtilityTestData.mContractData.put('Status','Draft');
        UtilityTestData.mContractData.put('SBQQ__Opportunity__c',opptyList[0].Id);
        UtilityTestData.mContractData.put('StartDate',System.today()+'');
        UtilityTestData.mContractData.put('Business_Model__c','Standard');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContractData);
        List<Contract> lContract = (List<Contract>) UtilityTest.makeInsert(new List<sObject>{sObj});
        Test.startTest();
        //create lead        
        UtilityTestData.mLeadData.put('FirstName','test3 referral');
        UtilityTestData.mLeadData.put('LastName ','test3');
        UtilityTestData.mLeadData.put('Email','test3@testr3.q');
        UtilityTestData.mLeadData.put('Deal_Registration_Name__c','testLeadConvert1113');
        UtilityTestData.mLeadData.put('Deal_Registration_Type__c','Referral');            
        UtilityTestData.mLeadData.put('Accept_Terms_and_Conditions__c','True');
        UtilityTestData.mLeadData.put('Primary_Role_in_Sale__c','Informatica Sales Sourced/Partner Assists');
        UtilityTestData.mLeadData.put('Reseller_SI_Partner__c',accRecord.id);
        UtilityTestData.mLeadData.put('Newly_Identified_Opportunity_Sourced__c','No');
        
        sObject lead = new Lead();
        lead = UtilityTest.putFieldRecord(lead, UtilityTestData.mLeadData);
        List<lead> leadList = (List<lead>) UtilityTest.makeInsert(new List<sObject>{lead});
        /*------------------------------------------------Test Partner Relationship---------------------------------------------------------*/
        //Create partner relationship record
        UtilityTestData.mPartnerRelationshipData.put('Opportunity__c',opptyList[0].id);
        UtilityTestData.mPartnerRelationshipData.put('Partner_Role__c','OEM');
        UtilityTestData.mPartnerRelationshipData.put('Partner_Account__c',accRecord.id);
        UtilityTestData.mPartnerRelationshipData.put('DEV_PRM_IsConverted__c','false');
        //Create Partner_Relationship__c sObject
        sObject partreln = new Partner_Relationship__c();
        partreln = UtilityTest.putFieldRecord(partreln, UtilityTestData.mPartnerRelationshipData);       
        List<SObject> tempList = (List<Partner_Relationship__c>)UtilityTest.makeInsert(new list<sObject>{partreln});        
    }
    
    @isTest
    public static void fetchLookUpValuesTest() {
        Partner_Relationship__c partRecord=[Select Id from Partner_Relationship__c limit 1];
        try{
            customLookUpController.fetchLookUpValues('testLeadConvert1113', 'Lead', partRecord.Id);
        }
        catch(Exception e){}
    }
    
    @isTest
    public static void DRValueTest() {
        Partner_Relationship__c partRecord=[Select Id from Partner_Relationship__c limit 1];
        lead leadRecord=[Select Id from lead limit 1];
        customLookUpController.DRValue(leadRecord.Id,  partRecord.Id);
    }
}