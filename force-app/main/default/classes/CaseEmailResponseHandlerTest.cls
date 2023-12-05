/*
Author Name   : Akhilesh Soni
Class Name    : CaseEmailResponseHandlerTest
Created Date  : Dec 26, 2020
Description   : test class for CaseEmailResponseHandler [Inbound email handler service class] 
*/

@isTest
private class CaseEmailResponseHandlerTest {
    @isTest private static void unitTest_WithoutCaseNumber(){
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();       
        email.subject = 'test';
        email.fromName = 'test Contact';
        email.fromAddress = 'testuser@test.com';
        email.plainTextBody = 'Hello, this a test email body.';
        email.plainTextBody = 'Hello, this a test email body.';
        email.toAddresses = new List<String>{'testuser@test.com'};
            email.htmlBody='hello';
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.name ='Content-Disposition';
        header.value='inline';
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        attachment.headers = new Messaging.InboundEmail.Header[] { header };
            email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
                
                
                CaseEmailResponseHandler oCaseEmailResponseHandler = new CaseEmailResponseHandler();
        Messaging.InboundEmailResult result = oCaseEmailResponseHandler.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);   
    }    
    
    @isTest private static void unitTest_WithCaseNumber(){
        Case oCase = new Case();
        oCase.Status = 'New';
        oCase.Origin = 'Web';
        insert oCase;
        
        Case_Contact__c oCaseContact = new Case_Contact__c();
        oCaseContact.Case__c = oCase.Id;
        //oCaseContact.Name = 'other Contact';
        oCaseContact.Email__c = 'otheruser@test.com';
        insert oCaseContact;
        
        for(Case c : [Select Id,CaseNumber From Case Where Id = :oCase.Id]){
            oCase = c;
        }
        System.debug('@Developer --> oCase.CaseNumber :' + oCase.CaseNumber);
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();       
        email.subject = 'test ' +  oCase.CaseNumber;
        email.fromName = 'test Contact';
        email.fromAddress = 'testuser@test.com';
        email.plainTextBody = 'Hello, this a test email body.';
        envelope.fromAddress = 'testuser@test.com';
        email.toAddresses = new List<String>{'testuser@test.com'};
             email.ccAddresses = new List<String>{'testuserxc@test.com'};
            email.htmlBody='hello appendonsend rplyfwdmsg';
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.name ='Content-ID';
        header.value='inline<hksd>';
        
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        attachment.headers = new Messaging.InboundEmail.Header[] { header };
            email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
                
                CaseEmailResponseHandler oCaseEmailResponseHandler = new CaseEmailResponseHandler();
        Messaging.InboundEmailResult result = oCaseEmailResponseHandler.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);   
    }    
    
    
    @isTest private static void unitTest_ContentDisposition(){
        Case oCase = new Case();
        oCase.Status = 'New';
        oCase.Origin = 'Web';
        insert oCase;
        
        Case_Contact__c oCaseContact = new Case_Contact__c();
        oCaseContact.Case__c = oCase.Id;
        //oCaseContact.Name = 'other Contact';
        oCaseContact.Email__c = 'otheruser@test.com';
        insert oCaseContact;
        
        for(Case c : [Select Id,CaseNumber From Case Where Id = :oCase.Id]){
            oCase = c;
        }
        System.debug('@Developer --> oCase.CaseNumber :' + oCase.CaseNumber);
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();       
        email.subject = 'test ' +  oCase.CaseNumber;
        email.fromName = 'test Contact';
        email.fromAddress = 'testuser@test.com';
        email.plainTextBody = 'Hello, this a test email body.';
        envelope.fromAddress = 'testuser@test.com';
        email.toAddresses = new List<String>{'testuser@test.com'};
            email.htmlBody='hello';
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.name ='Content-Disposition';
        header.value='inline;';
        
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        attachment.headers = new Messaging.InboundEmail.Header[] { header };
            email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
                
                CaseEmailResponseHandler oCaseEmailResponseHandler = new CaseEmailResponseHandler();
        Messaging.InboundEmailResult result = oCaseEmailResponseHandler.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);   
    }  
    
        
    @isTest private static void internalExceptionTest(){
        Case oCase = new Case();
        oCase.Status = 'New';
        oCase.Origin = 'Web';
        insert oCase;
        
        Case_Contact__c oCaseContact = new Case_Contact__c();
        oCaseContact.Case__c = oCase.Id;
        //oCaseContact.Name = 'other Contact';
        oCaseContact.Email__c = 'otheruser@test.com';
        insert oCaseContact;
        
        for(Case c : [Select Id,CaseNumber From Case Where Id = :oCase.Id]){
            oCase = c;
        }
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();       
        email.subject = 'test ' +  oCase.CaseNumber;
        email.fromName = 'test Contact';
        email.fromAddress = 'testuser@test.com';
        email.plainTextBody = 'Hello, this a test email body.';
        envelope.fromAddress = 'testuser@test.com';
        email.toAddresses = new List<String>{'testuser@test.com'};
            email.htmlBody='hello';
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.name ='Content-Disposition';
        header.value='inline<hksd>';
        
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.headers = new Messaging.InboundEmail.Header[] { header };
            email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
                
                CaseEmailResponseHandler oCaseEmailResponseHandler = new CaseEmailResponseHandler();
        Messaging.InboundEmailResult result = oCaseEmailResponseHandler.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);   
    }  
    
            
    @isTest private static void overallExceptionTest(){
        Case oCase = new Case();
        oCase.Status = 'New';
        oCase.Origin = 'Web';
        insert oCase;
        
        Case_Contact__c oCaseContact = new Case_Contact__c();
        oCaseContact.Case__c = oCase.Id;
        //oCaseContact.Name = 'other Contact';
        oCaseContact.Email__c = 'otheruser@test.com';
        insert oCaseContact;
        
        for(Case c : [Select Id,CaseNumber From Case Where Id = :oCase.Id]){
            oCase = c;
        }
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();       
        email.subject = 'test ' +  oCase.CaseNumber;
        email.fromName = 'test Contact';
        email.fromAddress = 'testuser@test.com';
        email.plainTextBody = 'Hello, this a test email body.';
        envelope.fromAddress = 'testuser@test.com';
       
                CaseEmailResponseHandler oCaseEmailResponseHandler = new CaseEmailResponseHandler();
        Messaging.InboundEmailResult result = oCaseEmailResponseHandler.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);   
    }  
}