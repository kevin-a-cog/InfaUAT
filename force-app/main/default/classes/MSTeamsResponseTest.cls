@isTest
public class MSTeamsResponseTest {

    @testSetup
    public static void testData(){
        Id devRecordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        Account acc = new Account(Name='Test Account',RecordTypeId=devRecordTypeId1,BillingCountry = 'India',BillingStreet= '298 S. Ringo Street', BillingState = 'AR', BillingPostalCode = '72201');
        insert acc;
    }
    
    @isTest
    public static void doPostExceptionTest(){
        MSTeamsResponse.doPost();
    }
    
    @isTest
    public static void doPostTest(){
        Id devRecordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        Account acc = new Account(Name='Test Account',RecordTypeId=devRecordTypeId1,BillingCountry = 'India',BillingStreet= '298 S. Ringo Street', BillingState = 'AR', BillingPostalCode = '72201');
        insert acc;
         MSTeamsResponse.MSTeamsResponseJSON reqst=new MSTeamsResponse.MSTeamsResponseJSON();
        reqst.recordid = acc.Id;
        reqst.fieldname = 'BillingCountry';
        reqst.responseid = 'US';
        String JsonMsg=JSON.serialize(reqst);
        Test.startTest();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/MSTeamsResponse';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        MSTeamsResponse.doPost();
        Test.stopTest();
    }
   	
}