@isTest(seeAllData=false)
public with sharing class SendOutboundMessageControllerTest {
    
 public class ExampleCalloutMock implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('Salesforcescool');
            return res;
        }
 }
 static testMethod void testMethod1() {
   
       Account acc= new account();
        acc.name = 'test Account';
        acc.BillingCountry='us';
        insert acc;
        Order ordernew =new Order();
        ordernew.accountid= acc.id;
        ordernew.BilltoAccount__c= acc.id;
        ordernew.EndUserAccount__c = acc.id;
        ordernew.ShipToAccount__c = acc.id;
        ordernew.EffectiveDate = system.today();
        ordernew.status='Draft';
         insert ordernew;
        Fulfillment__c fll= new Fulfillment__c();
        fll.order__c = ordernew.id;
        fll.Ship_To_Address__c= 'test address';
        insert fll;
     
    Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        SendOutboundMessageController.sendOutboundMessage(fll.id);
    Test.stopTest();    
 }
}