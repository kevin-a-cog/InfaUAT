/*
Class:  A2R_ControllerTest
        @Author:        Ambica Pyati
        @Created Date:  09/11/2018
        @Description:   Test Class for A2R_Controller Class.


*/
/*
Change History:
vsabbella 12/4/2018 create Email Message Records to test process builder.
VenkyK    05/13/2020 To increase code coverage  T02
Ambica    11/17/20   Remove ortoo references T03
*/
@isTest
private class A2R_ControllerTest{
    @testSetup
    static void setupObjectTestData() {
        sObject sObj = new Account();
        sObject sObj1 = new Account();
        sObj = new Account();
        UtilityTestData.mAccountData.put('Signature_Success__c','TRUE');    
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        sObj = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname1');
        UtilityTestData.mContactData.put('LastName','LastName1');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        
        sObj1 = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname2');
        UtilityTestData.mContactData.put('LastName','LastName2');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mContactData);
        
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        List<Territory2> lTerritory = (List<Territory2>) UtilityTest.executeQuery('Select Id from Territory2');

        
        String OPP_RENEWAL_RT = 'Renewal Opportunity';
        String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
                        
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
        UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
        UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_RENEWAL_RT).getRecordTypeId());
        UtilityTestData.mOpportunityData.put('Type', 'Renewal');
        UtilityTestData.mOpportunityData.put('StageName', 'Validate');
        UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Commit');
        sObj = new Opportunity();     
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        sObj = new Account_LOB__c();
        UtilityTestData.mAccountLOB.put('Account__c',lAccount[0].id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountLOB);
        List<Account_LOB__c> lAccountLOB = (List<Account_LOB__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
            
        sObj = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].id);
        UtilityTestData.mPlan.put('Line_of_Business__c',lAccountLOB[0].id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj= new Related_Opportunity_Plan__c();
        UtilityTestData.mRelatedopportunityPlan.put('Plan__c',lPlan[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Account__c',lAccount[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Opportunity__c',lOpportunity[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Ignore_ABV__c','TRUE');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRelatedopportunityPlan);
        List<Related_Opportunity_Plan__c> lRelatedopportunityPlan = (List<Related_Opportunity_Plan__c>) UtilityTest.makeInsert(new List<sObject>{sObj});


    }
  
    
    //T02 this will also test AdoptionSrvcInterLockCtrl
    static testMethod void testSMGNotification2(){
        User u1 = [SELECT id FROM User Where Profile.Name = 'System Administrator' AND IsActive = true Limit 1];
        List<Related_Opportunity_Plan__c> lRelatedopportunityPlan = [Select Id,Name,Plan__c,Project_name__c,Project_Manager_Owner__c from Related_Opportunity_Plan__c Limit 1];
        
        lRelatedopportunityPlan[0].Project_name__c = 'IPS Project';
        lRelatedopportunityPlan[0].Project_Manager_Owner__c = 'Test user';
        lRelatedopportunityPlan[0].RecordTypeId = Label.ProfessionalServicesRecId;
        system.runAs(u1){
          update lRelatedopportunityPlan[0];
        }
        
    }
}