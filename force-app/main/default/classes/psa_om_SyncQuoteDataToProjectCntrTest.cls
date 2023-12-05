/*
@created by       : MAHESH GANTI
@created on       : 12/28/2020
@Purpose          : Test class for psa_om_SyncQuoteDataToProjectController

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
Ramya Ravi 		02/04/2021      Prasanth 		 										
****************************************************************************************************************************
*/
@isTest(seeAllData=false)
public class psa_om_SyncQuoteDataToProjectCntrTest {

    @testSetup
    static void setupObjectTestData() {
        
        sObject sObj = new Account();
        UtilityTestData.mAccountData.put('Name','SOLUTION TYPE TESTING');
        UtilityTestData.mAccountData.put('Geo__c','NA');
        UtilityTestData.mAccountData.put('Signature_Success__c','true');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);         
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});

       // Sobject pseContact = new Contact();
       // UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
       // pseContact = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
       // List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{pseContact});

        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('RecordTypeId',Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId()); 
        sObject Opty = new Opportunity();
        Opty = UtilityTest.putFieldRecord(Opty, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpty = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{Opty});       

        // Insert new Quote
      
          sObj = new SBQQ__Quote__c();
        UtilityTestData.mSBQuoteData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('Shipping_Preference__c','Email');
        UtilityTestData.mSBQuoteData.put('SBQQ__BillingName__c','Test user');
        UtilityTestData.mSBQuoteData.put('SBQQ__ShippingName__c','Test user');
        UtilityTestData.mSBQuoteData.put('Shipping_Email__c','test@email.com');
        UtilityTestData.mSBQuoteData.put('PO__c','123213');
        UtilityTestData.mSBQuoteData.put('BillToAccount__c',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('ShiptToAccount__c',lAccount[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Opportunity2__c',lOpty[0].Id);
        UtilityTestData.mSBQuoteData.put('SBQQ__Primary__c', 'true');        
        UtilityTestData.mSBQuoteData.put('CurrencyIsoCode', 'USD');
        UtilityTestData.mSBQuoteData.put('SBQQ__Type__c', 'Quote');
        UtilityTestData.mSBQuoteData.put('SBQQ__StartDate__c', System.Today() + '');
        UtilityTestData.mSBQuoteData.put('PSA_OM_Planned_Margin__c', 'TEST PLANNED MARGIN');
        UtilityTestData.mSBQuoteData.put('PSA_OM_Customer_Signoff__c', 'Timecards');
        UtilityTestData.mSBQuoteData.put('PSA_OM_Budget_Hours__c', '400');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mSBQuoteData);
        List<SBQQ__Quote__c> lQuote = (List<SBQQ__Quote__c>) UtilityTest.makeInsert(new List<sObject>{sObj});       

        Sobject pseProject = new pse__Proj__c();
        UtilityTestData.mProjectData.put('pse__Account__c',lAccount[0].Id);
       // UtilityTestData.mProjectData.put('pse__Project_Manager__c',lContact[0].Id);
        UtilityTestData.mProjectData.put('pse__Project_Type__c','Customer Project');
        UtilityTestData.mProjectData.put('psa_pm_Project_Sub_Type__c','Baseline/Std Pkg');
        UtilityTestData.mProjectData.put('pse__Opportunity__c',lOpty[0].Id);
        UtilityTestData.mProjectData.put('pse__Start_Date__c',System.today().addDays(1)+'');
        UtilityTestData.mProjectData.put('pse__End_Date__c',System.today().addDays(10)+'');
        UtilityTestData.mProjectData.put('pse__Allow_Self_Staffing__c','true');
        UtilityTestData.mProjectData.put('pse__Is_Active__c','true');
        pseProject = UtilityTest.putFieldRecord(pseProject, UtilityTestData.mProjectData);
        List<pse__Proj__c> lProject = (List<pse__Proj__c>) UtilityTest.makeInsert(new List<sObject>{pseProject});
    }

    static testMethod void testSolutionTypeRecordsCreation(){
        
        List<pse__Proj__c> prjRec = [SELECT Id,Name,pse__Opportunity__c FROM pse__Proj__c];
        system.debug('*****'+prjRec);
        Id projId = prjRec[0].Id;
        Test.startTest();
            psa_om_SyncQuoteDataToProjectController.syncQuoteDate(projId);
        Test.stopTest(); 
    }

}