@isTest
public class DealStrategyApprovalsHandlerTest{
    
    private static Deal_Strategy_Approvals__c dealStrategyApproval;
    
/*
**this method creates data required for testing purpose 
*/
    @testSetup static void setupData(){
        
        Id cometitorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor Account').getRecordTypeId();
        sObject sObjAccount = new Account();
        UtilityTestData.mAccountData.put('RecordtypeId',cometitorRecordTypeId);
        sObjAccount  = UtilityTest.putFieldRecord(sObjAccount,UtilityTestData.mAccountData);
        
        
        sObject sObjAccount1  = new Account();
        UtilityTestData.mAccountData.put('RecordtypeId',cometitorRecordTypeId);
        UtilityTestData.mAccountData.put('Status__c','New');
        sObjAccount1 = UtilityTest.putFieldRecord(sObjAccount1,UtilityTestData.mAccountData);
        
        List<Account> accountlst = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObjAccount,sObjAccount1});
        
        sObject sObjContact = new contact();
        UtilityTestData.mContactData.put('AccountId', accountlst[1].Id);
        sObjContact = UtilityTest.putFieldRecord(sObjContact,UtilityTestData.mContactData);
        
        sObject sObjContact1 = new contact();      
        UtilityTestData.mContactData.put('Account', accountlst[1].Id);
        sObjContact1 = UtilityTest.putFieldRecord(sObjContact1,UtilityTestData.mContactData);
        
        List<contact> contactlst = (List<contact>) UtilityTest.makeInsert(new List<sObject>{sObjContact,sObjContact1});
        System.assertEquals(contactlst.size(),2);
        
        sObject sObjOpportunity = new opportunity();
        UtilityTestData.mOpportunityData.put('AccountId',sObjAccount.Id);
        UtilityTestData.mOpportunityData.put('CloseDate ',Date.parse('02/12/2020')+'');
        UtilityTestData.mOpportunityData.put('StageName','Validate');
        UtilityTestData.mOpportunityData.put('Type','Direct');
        UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
        sObjOpportunity = UtilityTest.putFieldRecord(sObjOpportunity,UtilityTestData.mOpportunityData);
        
        sObject sObjOpportunity1 = new opportunity();
        UtilityTestData.mOpportunityData.put('Name','Test opportunity1');
        UtilityTestData.mOpportunityData.put('AccountId',sObjAccount.Id);
        UtilityTestData.mOpportunityData.put('CloseDate ',Date.parse('02/12/2020')+'');
        UtilityTestData.mOpportunityData.put('StageName','Validate');
        UtilityTestData.mOpportunityData.put('Type','Direct');
        UtilityTestData.mOpportunityData.put('CurrencyIsoCode','USD');
        sObjOpportunity1 = UtilityTest.putFieldRecord(sObjOpportunity1,UtilityTestData.mOpportunityData);
        List<opportunity> opportunitylst = (List<opportunity>) UtilityTest.makeInsert(new List<sObject>{sObjOpportunity,sObjOpportunity1});
        
        dealStrategyApproval = new Deal_Strategy_Approvals__c();
        dealStrategyApproval.Opportunity__c = opportunitylst[0].Id;
        dealStrategyApproval.Approval_Expiration_Date__c = Date.today().addDays(10);
        dealStrategyApproval.Status__c = 'New';
        dealStrategyApproval.Request_Type__c = 'Margin Analysis';
        insert dealStrategyApproval;

    }
    
    //method to test
    @isTest
    public static void testUpdates(){
        Test.startTest();
        
        list<Deal_Strategy_Approvals__c> dealStrategyApprovalList =  [SELECT Id FROM Deal_Strategy_Approvals__c Limit 1];
        dealStrategyApprovalList[0].Status__c = 'In Progress';
        update dealStrategyApprovalList;
        
        Test.stopTest();
    }
    
    
}