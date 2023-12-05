/*
Class:          csmPlanInterlockControllerTest
@Author:        Pavithra Velumani 
@Created Date:  16-Nov-2021
@Description:   Test class for csmPlanInterlockController
    Change History
*************************************************************************************************************************************
    ModifiedBy               Date        Requested By        Description                                         Tag
************************************************************************************************************************************
*/
@isTest
public class csmPlanInterlockControllerTest {
    
    //Method to setup test data
    @testSetup
    static void setupObjectTestData() {
        
        //Account
        sObject Account = new Account();
        Account = UtilityTest.putFieldRecord(Account, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{Account});
        
        //Opportunity
        UtilityTestData.mOpportunityData.put('AccountId',lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('RecordTypeId',Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal Opportunity').getRecordTypeId()); 
        sObject Opty = new Opportunity();
        Opty = UtilityTest.putFieldRecord(Opty, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpty = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{Opty});
        
        //Plan insertion        
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan');
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});  
        
        //Related opportunity Plan(Interlock)
        UtilityTestData.mRelatedOpportunityPlan.put('Opportunity__c',lOpty[0].Id);
        UtilityTestData.mRelatedOpportunityPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mRelatedOpportunityPlan.put('Plan__c',lPlan[0].Id);
        UtilityTestData.mRelatedOpportunityPlan.put('RecordTypeId',Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByDeveloperName().get('Related_Opportunity_Plan').getRecordTypeId());        
        sObject relOptyPlan = new Related_Opportunity_Plan__c();
        relOptyPlan = UtilityTest.putFieldRecord(relOptyPlan, UtilityTestData.mRelatedOpportunityPlan);        
        List<Related_Opportunity_Plan__c> lRelOptyPlan = (List<Related_Opportunity_Plan__c>) UtilityTest.makeInsert(new List<sObject>{relOptyPlan});  
    }  

    @isTest
    public static void testManagePlanInterlocks(){
        List<Plan__c> lPlan = [Select Id from Plan__c];
        csmPlanInterlockController.getRecords(lPlan[0].Id);
    }
    
    @isTest
    public static void testRecordsDeletion(){
         List<Plan__c> lPlan = [Select Id from Plan__c];
        List<Related_Opportunity_Plan__c> lInterlock = new List<Related_Opportunity_Plan__c>();
        csmPlanInterlockController.getRecordsDeleted(lInterlock);
        
		Related_Opportunity_Plan__c interlock = new Related_Opportunity_Plan__c();
        csmPlanInterlockController.getRecordsInserted(interlock);
        csmPlanInterlockController.lookupSearch('Opp',new List<String>(),'Opportunity',null);
    }
}