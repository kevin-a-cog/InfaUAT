/*
Class:          AssociatePlanToInterlockTest
@Author:        Chandana Gowda 
@Created Date:  24-Jan-2020
@Description:   Test class to test the invocable method linking of plan and interlock 
    Change History
*************************************************************************************************************************************
    ModifiedBy               Date        Requested By        Description                                         Tag
************************************************************************************************************************************
*/
@isTest
public with sharing class AssociatePlanToInterlockTest {
    
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
        
        //Account LOB
        UtilityTestData.mAccountLOB.put('Account__c',lAccount[0].Id);
        sObject AccLOB = new Account_LOB__c();
        AccLOB = UtilityTest.putFieldRecord(AccLOB, UtilityTestData.mAccountLOB);
        List<Account_LOB__c> lAccLOB = (List<Account_LOB__c>) UtilityTest.makeInsert(new List<sObject>{AccLOB});
        
        //Account Product
        UtilityTestData.mAccountProduct.put('Account__c',lAccount[0].Id);
        sObject AccProd = new Account_Product__c();
        AccProd = UtilityTest.putFieldRecord(AccProd, UtilityTestData.mAccountProduct);
        List<Account_Product__c> lAccProd = (List<Account_Product__c>) UtilityTest.makeInsert(new List<sObject>{AccProd});
        
        //Related opportunity Plan(Interlock)
        UtilityTestData.mRelatedOpportunityPlan.put('Opportunity__c',lOpty[0].Id);
        UtilityTestData.mRelatedOpportunityPlan.put('Account__c',lAccount[0].Id);
        UtilityTestData.mRelatedOpportunityPlan.put('RecordTypeId',Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByName().get('Renewal(SMG)').getRecordTypeId());        
        sObject relOptyPlan = new Related_Opportunity_Plan__c();
        relOptyPlan = UtilityTest.putFieldRecord(relOptyPlan, UtilityTestData.mRelatedOpportunityPlan);        
        List<Related_Opportunity_Plan__c> lRelOptyPlan = (List<Related_Opportunity_Plan__c>) UtilityTest.makeInsert(new List<sObject>{relOptyPlan});  
    }  

    //Method to Test the association of plan and interlock on plan creation
    @isTest
    public static void linkPlanAndInterlock(){
        List<Account> lAccount = [SELECT Id from Account];
        List<Account_LOB__c> lAccLOB = [SELECT Id FROM Account_LOB__c];
        
        //Plan insertion
        UtilityTestData.mPlan.put('Account__c',lAccount[0].Id);
        sObject Plan = new Plan__c();
        UtilityTestData.mPlan.put('Name','Test Plan');
        UtilityTestData.mPlan.put('Line_of_Business__c',lAccLOB[0].Id);
        Plan = UtilityTest.putFieldRecord(Plan, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{Plan});  
        List<Id> lstPlanIds = new List<Id>();

        for(Plan__c pl:lPlan){
            lstPlanIds.add(pl.Id);
        }

        AssociatePlanToInterlock.linkPlanAndInterlock(lstPlanIds);
        List<Related_Opportunity_Plan__c> lstInterlock = [SELECT ID FROM Related_Opportunity_Plan__c WHERE Plan__c = :lstPlanIds[0]];

        //Only one interlock associated to the plan
        System.assertEquals(1, lstInterlock.size());      
    }      

}