@isTest
public with sharing class EstimationSummaryTriggerTest {
    
    private Final static String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
    private Final static String ACC_Prospect_Account_Record_Type = Label.Prospect_Account_Record_Type;
    @TestSetup
    static void setup(){
        IPUE_TestUtils.setupAllData();
        IPUE_TestUtils.setupFormData();

        Opportunity testOpp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        Estimation_Summary__c testSummary = IPUE_TestUtils.createEstimationSummary(false, testOpp.Id);
        Form__c testForm = [SELECT Id FROM Form__c LIMIT 1];
        testSummary.Form__c = testForm.Id;
        testSummary.Account__c = testOpp.AccountId;
        testSummary.Primary__c = true;
        insert testSummary;    
    }

    @isTest
    private static void testPrimaryOnInsert(){
        try{
            Opportunity testOpp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
            Estimation_Summary__c summaryToInsert = IPUE_TestUtils.createEstimationSummary(false, testOpp.Id);

            summaryToInsert.Primary__c = true;

            insert summaryToInsert;
            
        }catch(Exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains('There can only be one Primary Estimation Summary per Opportunity')? true:false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }

    @isTest
    private static void testPrimaryOnUpdate(){
        try{
            Opportunity testOpp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
            Estimation_Summary__c summaryToInsert = IPUE_TestUtils.createEstimationSummary(false, testOpp.Id);

            summaryToInsert.Primary__c = false;

            insert summaryToInsert;

            summaryToInsert.Primary__c = true;
            
        }catch(Exception e){
            Boolean expectedExceptionThrown = e.getMessage().contains('There can only be one Primary Estimation Summary per Opportunity')? true:false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
}