/*
Class:          RelinkOpptyControllerTest
@Author:        Anusha Akella
@Created Date:  8/26/2021
@Description:   test class for RelinkOpptyController
Change History
******************************************************************
ModifiedBy          Date        Requested By        Description                 Tag

******************************************************************
*/
@isTest
public class RelinkOpptyControllerTest {
    
    private Final Static String vEmployee = Label.Profile_Employee;
    private Final Static String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
    
    @testSetup
    static void setupObjectTestData() {
        
        //Insert Account setup data
        sObject sObj = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);  
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        system.debug('lAccount --- '+lAccount);
        //Insert contact
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
		
        
        SObject sObj1 = new Opportunity();
        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Type','Direct');
        UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
        //UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId());        
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mOpportunityData);   
        
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        //create standard Pricebook
        Id StandardPbId = Test.getStandardPricebookId();
        
        //Insert Opportunity Team members
        UtilityTestData.mOpportunityTeamMemberData.put('OpportunityId', sObj.Id);
        UtilityTestData.mOpportunityTeamMemberData.put('UserId',UserInfo.getUserId());
        sObj = new OpportunityTeamMember ();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityTeamMemberData);
        List<OpportunityTeamMember> lOpportunityTeamMembers = (List<OpportunityTeamMember>) UtilityTest.makeInsert(new List<sObject>{sObj});  
    }
    @isTest
    static void testSubmitQuoteDetails() {
        List<Account> lAccount = [Select Id,Name from Account Limit 1];
        system.debug('lAccount --- '+lAccount);
        List<Opportunity> lOpportunity = [Select Id From Opportunity];
        Test.startTest();
        sObject sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('AccountId',lAccount[0].Id);        
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpportunity[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Type__c','Amendment');
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
        
        sObject sObj1 = new Contract(Id = lContract[0].id,Status = 'Activated');
        lContract = (List<Contract>) UtilityTest.makeUpdate(new List<sObject>{sObj1}); 
        
        lOpportunity[1].SBQQ__AmendedContract__c = lContract[0].ID;
        
        sObj1 = new SBQQ__Quote__c(Id = lQuote[0].id, SBQQ__MasterContract__c = lContract[0].id);
        lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeUpdate(new List<sObject>{sObj1}); 
        RelinkOpptyController.submitQuoteDetails(lQuote[0].Id,lOpportunity[1].Id);
        Test.stopTest();
    }
    @isTest
    static void testLookUp() {
        List<Opportunity> lOpportunity = [Select Id,New_Org_Opportunity_Number__c,Name From Opportunity];
        Test.startTest();
        List<Opportunity> lSearchedOpportunity = RelinkOpptyController.lookUp(lOpportunity[0].Name,'Opportunity','');
        Test.stopTest();
        system.assertEquals(lSearchedOpportunity[0].Name, lOpportunity[0].Name, 'Opportunity doesnt match');
    }
}