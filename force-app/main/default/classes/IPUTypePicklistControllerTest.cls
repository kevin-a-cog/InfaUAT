/*
    Class:          IPUTypePicklistControllerTest
    @Author:        Nishant Bansal
    @Created Date:  06/12/2023
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy              Date          JIRA No.      Requested By      Description             Tag
    ********************************************************************************************************************************************
	* Nishant Bansal       04-06-2023      SALESRT-15257
*/
@isTest
public with sharing class IPUTypePicklistControllerTest {  
    @TestSetup
    static void setup(){
        IPUE_TestUtils.setupAllData();
        IPUE_TestUtils.setupFormData();
    }
    
    @isTest
    private static void testFindIPUPicklistValues(){
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        Estimation_Summary__c testSummary = IPUE_TestUtils.createEstimationSummary(false, testOpp.Id);
        
        Form__c testForm = [SELECT Id FROM Form__c LIMIT 1];
        testForm.Available_IPU_Types__c  = 'Flex IPU;IPU';
        testForm.IPU_Type__c = 'Flex IPU';
        update testForm;
        
        testSummary.Form__c = testForm.Id;
        
        insert testSummary;
        
        Estimation_Summary__c testSummary1 = IPUE_TestUtils.createEstimationSummary(false, testOpp.Id);
        testSummary1.Form__c = testForm.Id;
        testSummary1.Primary__c = true;
        insert testSummary1;
        
        IPUTypePicklistController.findIPUPicklistValues(testSummary.Id);
        
        IPUTypePicklistController.updateIPUType(testSummary.Id,'IPU');
        
        Estimation_Summary__c estSummary = [SELECT Id, IPU_Type__c FROM Estimation_Summary__c WHERE Id =: testSummary1.Id];
        system.assertEquals(estSummary.IPU_Type__c,'Flex IPU');
        
        
    }
    
    
}