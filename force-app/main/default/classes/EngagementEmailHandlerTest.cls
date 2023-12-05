/*
    @created by       : balajip
    @created on       : 02/15/2020
    @Purpose          : Test class for EngagementEmailHandler
    @Testclass        : 
    @JIRA             : 
    
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************
 balajip        07/19/2022  I2RT-6178   T01     to cover the new method notifyError
 balajip        10/17/2022  I2RT-0000   T02     updated the method call notifyError
 */
@isTest
public with sharing class EngagementEmailHandlerTest {
    
    @testSetup
    static void setupObjectTestData() {
        
        sObject sObj;
        List<sObject> lstSObj = new List<sObject>();
        sObj = new ProfileSkill();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillEscalation);
        sObj.put('Omni_Skill_Name__c', 'Escalation_Manager');
		lstSObj.add(sObj);
        sObj = new ProfileSkill();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillProductSME);
        lstSObj.add(sObj);
        sObj = new ProfileSkill();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mProfileSkillProductPS);
        lstSObj.add(sObj);
        UtilityTest.makeInsert(lstSObj);
      	
        Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
        Id CustomerAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId();
        
        sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Customer Account');
        UtilityTestData.mAccountData.put('RecordTypeId', CustomerAccountRecType);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewCustomerAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Account();
        UtilityTestData.mAccountData.put('Name', 'Test Support Account');
        UtilityTestData.mAccountData.put('ParentId', lNewCustomerAccount[0].Id);
        UtilityTestData.mAccountData.put('RecordTypeId', SupportAccountRecType);
        UtilityTestData.mAccountData.put('BillingCountry', 'USA');
        UtilityTestData.mAccountData.put('Active__c', 'true');
        UtilityTestData.mAccountData.put('End_Date__c', System.today()+100+'');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lNewSupportAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //create a Case record
        sObj = new Case();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCasePowerCenter);
        sObj.put('OwnerId', UserInfo.getUserId());
        sObj.put('Priority', 'P2');
        sObj.put('Support_Account__c', lNewSupportAccount[0].Id);
        UtilityTest.makeInsert(new List<sObject>{sObj});

        //create a Case record
        sObj = new Case();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mCase);
        UtilityTest.makeInsert(new List<sObject>{sObj});
        
        //create an Engagement record
        sObj = new Engagement__c();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mEngagementEscalation);
        UtilityTest.makeInsert(new List<sObject>{sObj});
    }
    
    static testMethod void testInboundEmail() {
        Engagement__c engagement = [Select Id From Engagement__c];
        engagement.OwnerId = UserInfo.getUserId();
        update engagement;
        engagement = [Select Id, Thread_Id__c, Owner.Email From Engagement__c];
        
        List<EmailMessage> emails=new List<EmailMessage>();
        EmailMessage emailMsg = new EmailMessage();
        emailMsg.FromAddress = 'test@abc.org';
        emailMsg.Incoming = false;
        emailMsg.ToAddress= 'test@xyz.org';
        emailMsg.Subject = 'Test email';
        emailMsg.HtmlBody = 'Test email body';
        emailMsg.RelatedToId = engagement.Id; 
        emailMsg.Engagement__c = engagement.Id; 
        emails.add(emailMsg);
        insert emails;
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.subject = 'Create Contact';
        email.fromAddress = engagement.Owner.Email;
        if(email.fromAddress == null){
            email.fromAddress = 'test@informatica.com';
        }
        
        List<String> toAdd =new List<String>{'someaddress1@email.com'};
        List<String> ccadd =new List<String>{'someaddress1@email.com'};
        email.toAddresses = toAdd;
        email.ccAddresses = ccadd;
        
        email.plainTextBody = 'email body '+engagement.Thread_Id__c;
        System.debug('email.plainTextBody-->'+email.plainTextBody);
        Messaging.InboundEmail.BinaryAttachment binaryattachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryattachment.body = blob.valueOf('my attachment text');
        binaryattachment.fileName = 'textfileone.txt';
        binaryattachment.mimeTypeSubType = 'text/plain';
        Messaging.InboundEmail.Header header1 = new Messaging.InboundEmail.Header(); 
        header1.name = 'Content-Disposition';
        header1.value = 'inline;';
        Messaging.InboundEmail.Header header2 = new Messaging.InboundEmail.Header(); 
        header2.name = 'Content-ID';
        header2.value = '25345345345345345';
        binaryattachment.headers = new Messaging.InboundEmail.Header[] {header1, header2};

        Messaging.InboundEmail.BinaryAttachment binaryattachment2 = new Messaging.InboundEmail.BinaryAttachment();
        binaryattachment2.body = blob.valueOf('my attachment text 2222');
        binaryattachment2.fileName = 'textfileone.txt';
        binaryattachment2.mimeTypeSubType = 'text/plain';
        Messaging.InboundEmail.Header header3 = new Messaging.InboundEmail.Header(); 
        header3.name = 'Content-ID';
        header3.value = '456456456456456456';
        binaryattachment2.headers = new Messaging.InboundEmail.Header[] {header3};
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryattachment, binaryattachment2 };
            
        Messaging.InboundEmail.TextAttachment txtattachment = new Messaging.InboundEmail.TextAttachment();
        txtattachment.body = 'my attachment text';
        txtattachment.fileName = 'textfileone.txt';
        txtattachment.mimeTypeSubType = 'text/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { txtattachment };

        Test.startTest(); 
        EngagementEmailHandler testInbound = new EngagementEmailHandler();
        testInbound.handleInboundEmail(email, env);
        
        try{
            EngagementEmailHandler.sendResponse(engagement, email.fromAddress);        
        }catch(Exception ex){}
        
        try{
            Case cse = [Select Id From Case Limit 1];
            User usr = [Select Id, Name, Email From User Where Id=:UserInfo.getUserId()]; //T03
            EngagementEmailHandler.createCaseComment(email, cse, engagement, usr, 'case comment text');        
        }catch(Exception ex){}

        Test.stopTest();
    }
    
    
    static testMethod void testInboundEmailOne() {
        
        Case cse = [Select Id, CaseNumber From Case Limit 1];
        
        List<EmailMessage> emails=new List<EmailMessage>();
        EmailMessage emailMsg = new EmailMessage();
        emailMsg.FromAddress = 'test@abc.org';
        emailMsg.Incoming = false;
        emailMsg.ToAddress= 'test@xyz.org';
        emailMsg.Subject = 'Test email';
        emailMsg.HtmlBody = 'Test email body';
        emails.add(emailMsg);
        insert emails;
        
        Test.startTest(); 
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.subject = cse.CaseNumber;
        if(email.fromAddress == null){
            email.fromAddress = 'test@informatica.com';
        }
        
        List<String> toAdd =new List<String>{'someaddress1@email.com'};
        List<String> ccadd =new List<String>{'someaddress1@email.com'};
        email.toAddresses = toAdd;
        email.ccAddresses = ccadd;
        
        email.plainTextBody = 'email body ';//+engagement.Thread_Id__c;
        email.HtmlBody = 'email body ';//+engagement.Thread_Id__c;
        System.debug('email.plainTextBody-->'+email.plainTextBody);
        Messaging.InboundEmail.BinaryAttachment binaryattachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryattachment.body = blob.valueOf('my attachment text');
        binaryattachment.fileName = 'textfileone.txt';
        binaryattachment.mimeTypeSubType = 'text/plain';
        Messaging.InboundEmail.Header header3 = new Messaging.InboundEmail.Header(); 
        header3.name = 'Content-ID';
        header3.value = '456456456456456456';
        binaryattachment.headers = new Messaging.InboundEmail.Header[] {header3};
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryattachment };
            
        Messaging.InboundEmail.TextAttachment txtattachment = new Messaging.InboundEmail.TextAttachment();
        txtattachment.body = 'my attachment text';
        txtattachment.fileName = 'textfileone.txt';
        txtattachment.mimeTypeSubType = 'text/plain';
        //txtattachment.ParentId = emailMsg.Id;
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { txtattachment };
            
        EngagementEmailHandler testInbound = new EngagementEmailHandler();
        testInbound.handleInboundEmail(email, env);
        //T01
        try{
            EngagementEmailHandler.notifyError(email, 'test error message'); //T02
        }catch(Exception ex){}
        Test.stopTest();
    }
}