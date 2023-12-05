@isTest
private class CSMChurnForecastControllerTest {
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
        opty.put('OARR_Cloud1__c',1000);
        Opty = UtilityTest.putFieldRecord(Opty, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpty = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{Opty});
        
        //Plan insertion        
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan');
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mPlan.put('Plan_Operational_Model__c','Other');
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
    public static void testmethod1() {

        List<Plan__c> lstPlan =[Select Id from Plan__c LIMIT 1];
        List<Opportunity> lstOpty =[Select Id from Opportunity LIMIT 1];

        Test.startTest();
        Opportunity op= lstOpty[0];
        op.Cloud_Churn_Forecast__c=200;
        update op;
        CSMChurnForecastController.ChurnWrapper wrp = new CSMChurnForecastController.ChurnWrapper();
        CSMChurnForecastController.getDisplayChurnForecast(lstPlan[0].Id);
        CSMChurnForecastController.getOptyRecords(lstPlan[0].Id);
        CSMChurnForecastController.saveChurnForecast(lstOpty);
        CSMChurnForecastController.notifyChurnUpdates(new List<Id>{op.Id});
        Test.stopTest();

    }
}