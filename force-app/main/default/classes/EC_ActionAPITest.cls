@isTest(seeAlldata=false)
private class EC_ActionAPITest {
    
    @isTest
    private static void testAPI(){
        Test.startTest();
        EC_ActionAPI.ActionUpsertWrapper ac = new EC_ActionAPI.ActionUpsertWrapper();
        ac.action = new EC_Action__c(AEM_Action_Id__c='testAction111',Action_Label__c='test api Action2',Object__c='Case',Queue__c='INFA_CSO',Record_Type__c='test');
        List<EC_Questions__c> qc = new List<EC_Questions__c>{new EC_Questions__c(AEM_Question_Id__c='testquestion111',Data_Type__c='text',Field_API_Name__c='CSM_Summary__c',Is_Required__c=true,Label__c='Engagement Details_upd1',Sort_Order__c=1),new EC_Questions__c(AEM_Question_Id__c='testquestion222',Data_Type__c='text',Field_API_Name__c='CSM_Summary__c',Is_Required__c=true,Label__c='Engagement Details_upd1',Sort_Order__c=1)};
        ac.questions = qc;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
     
         req.requestURI = '/services/apexrest/ECActionUpsert';  //Request URL
         req.httpMethod = 'POST';//HTTP Request Type
         req.requestBody = Blob.valueof(JSON.serialize(ac));
         RestContext.request = req;
         RestContext.response= res;
         EC_ActionAPI.doPost(ac);
         Test.stopTest();
    }
    @isTest
    private static void testAPI2(){
        Test.startTest();
        EC_ActionAPI.ActionUpsertWrapper ac = new EC_ActionAPI.ActionUpsertWrapper();
        ac.action = new EC_Action__c(AEM_Action_Id__c='testAction111',Action_Label__c='test api Action2',Object__c='Case',Queue__c='INFA_CSO',Record_Type__c='test');
        List<EC_Questions__c> qc = new List<EC_Questions__c>{new EC_Questions__c(AEM_Question_Id__c='testquestion111',Data_Type__c='text',Field_API_Name__c='CSM_Summary__c',Is_Required__c=true,Label__c='Engagement Details_upd1',Sort_Order__c=1)};
        ac.questions = qc;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
     
         req.requestURI = '/services/apexrest/ECActionUpsert';  //Request URL
         req.httpMethod = 'POST';//HTTP Request Type
         req.requestBody = Blob.valueof(JSON.serialize(ac));
         RestContext.request = req;
         RestContext.response= res;
         EC_ActionAPI.doPost(ac);
         Test.stopTest();
    }
}