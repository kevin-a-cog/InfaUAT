/*
@created by       : MAHESH GANTI
@created on       : 07/28/2021
@Purpose          : Test class for psa_om_SyncOpptyToProjectBatch 

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
@isTest
public class psa_om_SyncOpptyToProjectBatchTest {
    
    @testSetup
    static void setupObjectTestData() {
        sObject sObj;
        Id acctRecordTypeId = [SELECT ID FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName  = 'Customer_Account' LIMIT 1].Id;
        
        sObj = new Account();
        UtilityTestData.mAccountData.put('Name','Testing');
        UtilityTestData.mAccountData.put('RecordTypeId',acctRecordTypeId);
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
        //UtilityTestData.mOpportunityData.put('PSA_Field_Change_Timestamp__c',System.Now().addDays(-1)+'');
        UtilityTestData.mOpportunityData.put('psa_om_Start_Date__c',System.today()+'');
        UtilityTestData.mOpportunityData.put('psa_om_End_Date__c',System.today()+10+'');
        UtilityTestData.mOpportunityData.put('psa_om_IPS_Package__c','Jumpstart: Advanced EDC Success Pack');
        UtilityTestData.mOpportunityData.put('PSA_OM_Project_Type__c','JumpStart');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        lOpportunity[0].PSA_Field_Change_Timestamp__c = System.Now().addDays(-1);
        update lOpportunity;

        sObj = new pse__Proj__c();
        UtilityTestData.mProjectData.put('pse__Account__c',lAccount[0].Id);
        UtilityTestData.mProjectData.put('pse__Project_Manager__c',lContact[0].Id);
        UtilityTestData.mProjectData.put('pse__Project_Type__c','Customer Project');
        UtilityTestData.mProjectData.put('psa_pm_Project_Sub_Type__c','JumpStart');//pse__Stage__c 
        UtilityTestData.mProjectData.put('pse__Is_Active__c','true');//
        UtilityTestData.mProjectData.put('pse__Is_Billable__c','true');//
        UtilityTestData.mProjectData.put('psa_pm_Require_Product_On_Timecards__c','false');
        UtilityTestData.mProjectData.put('pse__Opportunity__c',lOpportunity[0].Id);
        UtilityTestData.mProjectData.put('pse__Start_Date__c',System.today().addDays(-6)+'');
        UtilityTestData.mProjectData.put('pse__End_Date__c',System.today().addDays(10)+'');//
        UtilityTestData.mProjectData.put('pse__Allow_Self_Staffing__c','true');    
        UtilityTestData.mProjectData.put('psa_pm_Time_Approval_Method__c','Auto-Approve');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProjectData);
     
    }

    static testMethod void testOpptySyncBatch(){
        List<Opportunity> opptyList = [SELECT id,Name,PSA_Field_Change_Timestamp__c FROM Opportunity];
        system.debug('*****opptyList***'+opptyList);
        Test.startTest();
            psa_om_SyncOpptyToProjectBatch oppBatch = new psa_om_SyncOpptyToProjectBatch();
            Id batchId = Database.executeBatch(oppBatch);
        Test.stopTest(); 
    }
    
}