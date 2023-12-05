@isTest
public class FulfillMentEmailTest {
    
   static testMethod void testInboundEmail() {
        Test.startTest(); 
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        Fulfillment__c fll= new Fulfillment__c();
        fll.Ship_To_Address__c= 'test address';
        insert fll;
        
        fulfillment__c fllc = [select id,thread_Id__c from Fulfillment__c limit 1];
        email.subject = 'testing testing';
        email.fromAddress = 'test87123@gmail.com';
        List<String> toAdd =new List<String>{'someaddress1@email.com'};
        email.toAddresses = toAdd;
        email.ccAddresses = toAdd;
        
        email.plainTextBody = 'email body '+fllc.Thread_Id__c;
        Messaging.InboundEmail.BinaryAttachment binaryattachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryattachment.body = blob.valueOf('my attachment text');
        binaryattachment.fileName = 'textfileone.txt';
        binaryattachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryattachment };
            
        Messaging.InboundEmail.TextAttachment txtattachment = new Messaging.InboundEmail.TextAttachment();
        txtattachment.body = 'my attachment text';
        txtattachment.fileName = 'textfileone.txt';
        txtattachment.mimeTypeSubType = 'text/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { txtattachment };

            
        FulfillmentEmail testInbound = new FulfillmentEmail();
        testInbound.handleInboundEmail(email, env);
        Test.stopTest();
       
    }
}