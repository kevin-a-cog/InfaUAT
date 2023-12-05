@isTest
public class GenericRecordHeaderControllerTest {
    
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
    static void testFetchRecordConfig(){
        List<Estimation_Summary__c>estSummary= [SELECT Id FROM Estimation_Summary__c LIMIT 1];
        Map<String,Object> resultMap=GenericRecordHeaderController.fetchRecordConfig(estSummary[0].Id,'Estimation Summary');
        System.assertEquals(resultMap.get('Status'), 'Success');   
    }
    @isTest
    static void testFollowRecord(){
        List<Estimation_Summary__c>estSummary= [SELECT Id FROM Estimation_Summary__c LIMIT 1];
        Map<String,Object> resultMap=GenericRecordHeaderController.followRecord(estSummary[0].Id,true);
        System.assertEquals(resultMap.get('Status'), 'Success'); 
        
        Map<String,Object> resultMap1=GenericRecordHeaderController.followRecord(estSummary[0].Id,false);
        System.assertEquals(resultMap.get('Status'), 'Success'); 
    }

}