/*
    Class:          IPUServices
    @Author:        Nishant Bansal
    @Created Date:  March 03 20213
    @Description:  Test Class
    */
    /*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
    ********************************************************************************************************************************************
*/
@isTest
public with sharing class IPUServicesTest {  
    @TestSetup
    static void setup(){
        IPUE_TestUtils.setupAllData();
        IPUE_TestUtils.setupFormData();
    }
    
    @isTest
    private static void testInsertOppIPUServices(){
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        Estimation_Summary__c testSummary = IPUE_TestUtils.createEstimationSummary(false, testOpp.Id);
        
        Form__c testForm = [SELECT Id FROM Form__c LIMIT 1];
        
        testSummary.Form__c = testForm.Id;
        
        insert testSummary;
        
        Estimation_Summary__c testSummary1 = IPUE_TestUtils.createEstimationSummary(false, testOpp.Id);
        testSummary1.Form__c = testForm.Id;
        testSummary1.Primary__c = true;
        insert testSummary1;
        
        IPUE_EstimationModelHelper.createEstimationModel(testSummary);
        
        testSummary.Primary__c = true;
        update testSummary;
    }
    
    
}