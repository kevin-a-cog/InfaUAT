@isTest
public class IPUE_CustomListViewCntlrTest {

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
    static void testGetWrapperOfSObjectFieldColumnActionValues(){
        Map<String,Object>resultMap=IPUE_CustomListViewCntlr.getWrapperOfSObjectFieldColumnActionValues('Estimation Summary For Community',false,'',null);
    	String query=(String)resultMap.get('Query');
        //adding next offset
        query+=' OFFSET '+((IPUE_CustomListViewCntlr.DataTableResponse)resultMap.get('DataTableWrapper')).queryLimit;
        IPUE_CustomListViewCntlr.getWrapperOfSObjectFieldColumnActionValues('Estimation Summary For Community',true,query,null);
    }
    
    @isTest
    static void testGetWrapperOfSObjectFieldColumnActionValues1(){
        IPUE_CustomListViewCntlr.DataTableColumns wrapperCl = new IPUE_CustomListViewCntlr.DataTableColumns('Test','Test__c','String');
    }
}