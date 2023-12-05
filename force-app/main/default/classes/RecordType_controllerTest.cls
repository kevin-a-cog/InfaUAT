/*
Class:          RecordType_controllerTest 
@Author:        Chandana Gowda  
@Created Date:  5/2/2019
@Description:   Test class for RecordType_Rendering controller.

Change History
*************************************************************************************************************************************
ambica                  11/17/20                       Removed ortoo referenes                        <T01>
*************************************************************************************************************************************
*/
@isTest
public class RecordType_controllerTest {
    
    @testSetup
    static void setupObjectTestData() {        
        //Account
        sObject Account = new Account();
        Account = UtilityTest.putFieldRecord(Account, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{Account});
        
        //Account LOB
        UtilityTestData.mAccountLOB.put('Account__c',lAccount[0].Id);
        sObject AccLOB = new Account_LOB__c();
        AccLOB = UtilityTest.putFieldRecord(AccLOB, UtilityTestData.mAccountLOB);
        List<Account_LOB__c> lAccLOB = (List<Account_LOB__c>) UtilityTest.makeInsert(new List<sObject>{AccLOB});
        
        /* <T01>
        //e2a Business Unit
        sObject e2aBusinessUnit = new ortoo_e2a__Business_Unit__c();
        e2aBusinessUnit = UtilityTest.putFieldRecord(e2aBusinessUnit, UtilityTestData.me2aBusinessUnit);
        List<ortoo_e2a__Business_Unit__c> le2aBusinessUnit = (List<ortoo_e2a__Business_Unit__c>) UtilityTest.makeInsert(new List<sObject>{e2aBusinessUnit}); 
        <T01> */
        
        //Plan
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan');
        UtilityTestData.mPlan.put('Line_of_Business__c',lAccLOB[0].Id);
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});
        
    }

    static testMethod void testRecordType_controller() {
       // User u1 = [SELECT id FROM User Where Profile.Name = 'System Administrator' AND IsActive = true Limit 1];
        //System.RunAs(u1) {
            test.StartTest();
                String objectName='Related_Opportunity_Plan__c';
                Id planId=[Select Id from Plan__c LIMIT 1].Id;
                Id AccId=[Select Id,Account__c from Plan__c LIMIT 1].Account__c;
                Map<String,Id> Result=RecordType_controller.FetchAccData(planId);
                System.assertEquals(Result.size(), 2);
                List<RecordType> recordTypeInterlock = [select Id from RecordType where sObjectType = :objectName];
                Map<Id, String> recordtypemap=RecordType_controller.fetchRecordTypeValues(objectName);
                //system.assertEquals(recordtypemap.size(),recordTypeInterlock.size());
            test.stopTest();
        //}
    }    
    
    static testMethod void testfetchRecordTypeDetails() {
        test.StartTest();
        String objectName='Account';
        List<RecordType> recordTypeQueryList = [select Id from RecordType where sObjectType = :objectName];
        List<RecordType> recordtypelist=RecordType_controller.fetchRecordTypeDetails(objectName);
        test.stopTest();
    }
}