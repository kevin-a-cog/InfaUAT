@isTest
public class TestPlanInboundEmail {
    
    
    static testMethod void testInboundEmail() {
        sObject sObj = new Account();
        sObject sObj1 = new Account();
        sObj = new Account();
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountData);
        List<Account> lAccount = (List<Account>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        UtilityTestData.mContactData.put('AccountId',lAccount[0].Id);
        sObj = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname1');
        UtilityTestData.mContactData.put('LastName','LastName1');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mContactData);
        
        sObj1 = new Contact();
        UtilityTestData.mContactData.put('FirstName','Firstname2');
        UtilityTestData.mContactData.put('LastName','LastName2');
        sObj1 = UtilityTest.putFieldRecord(sObj1, UtilityTestData.mContactData);
        
        List<Contact> lContact = (List<Contact>) UtilityTest.makeInsert(new List<sObject>{sObj,sObj1});
        
        List<Territory2> lTerritory = (List<Territory2>) UtilityTest.executeQuery('Select Id from Territory2');
        
        
        String OPP_RENEWAL_RT = 'Renewal Opportunity';
        String OPP_NEW_SALES_RT = Label.New_Sales_Opportunity;
        
        UtilityTestData.mOpportunityData.put('AccountId', lAccount[0].Id);
        UtilityTestData.mOpportunityData.put('Territory2Id', lTerritory[0].Id);
        UtilityTestData.mOpportunityData.put('End_User__c', lContact[0].Id);
        UtilityTestData.mOpportunityData.put('RecordTypeId', Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPP_RENEWAL_RT).getRecordTypeId());
        UtilityTestData.mOpportunityData.put('Type', 'Renewal');
        UtilityTestData.mOpportunityData.put('StageName', 'Validate');
        UtilityTestData.mOpportunityData.put('ForecastCategoryName', 'Commit');
        UtilityTestData.mOpportunityData.put('CloseDate', String.valueOf(System.today()));
        sObj = new Opportunity();     
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mOpportunityData);
        List<Opportunity> lOpportunity = (List<Opportunity>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        
        sObj = new Account_LOB__c();
        UtilityTestData.mAccountLOB.put('Account__c',lAccount[0].id);
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mAccountLOB);
        List<Account_LOB__c> lAccountLOB = (List<Account_LOB__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
        
        sObj = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].id);
        UtilityTestData.mPlan.put('Line_of_Business__c',lAccountLOB[0].id);
        UtilityTestData.mPlan.put('Plan_Operational_Model__c','Named CSM');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mPlan);
        List<Plan__c> lPlan = (List<Plan__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
       
        sObj= new Related_Opportunity_Plan__c();
        UtilityTestData.mRelatedopportunityPlan.put('Plan__c',lPlan[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Account__c',lAccount[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Opportunity__c',lOpportunity[0].id);
        UtilityTestData.mRelatedopportunityPlan.put('Thread_Id__c','Ref{00D01.4bvV:a3q01.DOMg}');
        UtilityTestData.mRelatedopportunityPlan.put('RecordType.Name','Related Opportunity Plan');
        UtilityTestData.mRelatedopportunityPlan.put('Ignore_ABV__c','TRUE');
        UtilityTestData.mRelatedopportunityPlan.put('Ignore_ABV__c','TRUE');
        sObj = UtilityTest.putFieldRecord(sObj, UtilityTestData.mRelatedopportunityPlan);
        List<Related_Opportunity_Plan__c> lRelatedopportunityPlan = (List<Related_Opportunity_Plan__c>) UtilityTest.makeInsert(new List<sObject>{sObj});
       // Id RecordTypeIdSMG = Schema.SObjectType.Related_Opportunity_Plan__c.getRecordTypeInfosByName().get('Renewal(SMG)').getRecordTypeId();
        Related_Opportunity_Plan__c interlock4=new Related_Opportunity_Plan__c();
        interlock4.Plan__c=lPlan[0].id;
        interlock4.Account__c=lAccount[0].id;
        interlock4.Opportunity__c=lOpportunity[0].id;
       //  interlock4.Thread_Id__c='Ref{00DL.5y0LE:a3qL.DOPV}';
       // interlock4.recordtypeid=RecordTypeIdSMG;
        interlock4.Interlock_Type__c='Jumpstart';
        interlock4.Ignore_ABV__c=true;
        insert interlock4;
        List<Related_Opportunity_Plan__c> interlockList =[select Thread_Id__c,Owner.Email,OwnerId from Related_Opportunity_Plan__c where Id= :interlock4.Id]; 
        List<Plan__c> planList=[select Thread_Id__c,Owner.Email,OwnerId from Plan__c where Id= : lPlan[0].id]; 
        System.debug('Thread Id from query-->'+interlockList[0].Thread_Id__c);
        System.debug('Owner Id-->'+interlockList[0].OwnerId);
        User usr=[select id,Name,Email from User where Id=:interlockList[0].OwnerId];
        User usr1=[select id,Name,Email from User where Id=:planList[0].OwnerId];
        System.debug('User-->'+usr); 
        System.debug('User Email-->'+usr.Email); 
        
        sObj1 = new Plan__c();
        UtilityTestData.mPlan.put('Account__c',lAccount[0].id);
        UtilityTestData.mPlan.put('Line_of_Business__c',lAccountLOB[0].id);
        UtilityTestData.mPlan.put('Plan_Operational_Model__c','Named CSM');
        UtilityTestData.mPlan.put('CSM_isAutoPilot__c','true');
        UtilityTestData.mPlan.put('User_Queue_Id__c',Userinfo.getuserid());
        Plan__c p1 = (Plan__c)UtilityTest.putFieldRecord(sObj1, UtilityTestData.mPlan);
        insert p1;
        Plan__c pl=[Select Id, Thread_Id__c from Plan__c where Id=:p1.Id LIMIT 1];
        List<EmailMessage> emails=new List<EmailMessage>();
        EmailMessage email1 = new EmailMessage();
        email1.FromAddress = 'test@abc.org';
        email1.Incoming = false;
        email1.ToAddress= 'test@xyz.org';
        email1.Subject = 'Test email';
        //email1.HtmlBody = 'Test email body';
        //email1.RelatedToId = lRelatedopportunityPlan[0].Id; 
        //email1.Interlock__c = lRelatedopportunityPlan[0].Id; 
        email1.RelatedToId = interlock4.Id; 
        email1.Interlock__c = interlock4.Id;
                emails.add(email1);
     
         EmailMessage email5 = new EmailMessage();
        email5.FromAddress = 'test@abc.org';
        email5.Incoming = false;
        email5.ToAddress= 'test@xyz.org,tesdt@ty.com';
        email5.Subject = 'Test email';
        email5.HtmlBody = 'Test email body';
        //email1.RelatedToId = lRelatedopportunityPlan[0].Id; 
        //email1.Interlock__c = lRelatedopportunityPlan[0].Id; 
        email5.RelatedToId = interlock4.Id; 
        email5.Interlock__c = interlock4.Id; 
        emails.add(email5);

       
        insert emails;
        
        Test.startTest(); 
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.subject = 'Create Contact';
        // email.fromAddress = 'someaddress@email.com';
        email.fromAddress = usr.Email;
        List<String> toAdd =new List<String>{'someaddress1@email.com'};
            List<String> ccadd =new List<String>{'someaddress1@email.com'};
                email.toAddresses = toAdd;
        email.ccAddresses = ccadd;
        
        //email.plainTextBody = 'email body Ref{00DL.5y0LE:a3Q41.17B6O}';
        email.plainTextBody = 'email body '+interlockList[0].Thread_Id__c;
        System.debug('email.plainTextBody-->'+email.plainTextBody);
        Messaging.InboundEmail.BinaryAttachment binaryattachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryattachment.body = blob.valueOf('my attachment text');
        binaryattachment.fileName = 'textfileone.txt';
        binaryattachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryattachment };
            
            Messaging.InboundEmail.TextAttachment txtattachment = new Messaging.InboundEmail.TextAttachment();
        txtattachment.body = 'my attachment text';
        txtattachment.fileName = 'textfileone.txt';
        txtattachment.mimeTypeSubType = 'text/plain';
        //  txtattachment.ParentId = email1.Id;
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { txtattachment };
                 
        Messaging.InboundEmail email2 = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env1 = new Messaging.InboundEnvelope();
        
        email2.subject = 'Create Contact';
        // email.fromAddress = 'someaddress@email.com';
        email2.fromAddress = usr1.Email;
        
        List<Messaging.InboundEmail.Header> head2 = new List<Messaging.InboundEmail.Header>();
         Messaging.InboundEmail.Header h2= new Messaging.InboundEmail.Header();
         h2.Name = 'Content-ID';
         h2.Value='<126788>';
         head2.add(h2);
         
        List<String> toAdd1 =new List<String>{'someaddress1@email.com'};
            List<String> ccadd1 =new List<String>{'someaddress1@email.com'};
                email2.toAddresses = toAdd1;
        email2.ccAddresses = ccadd1;
        
        //email.plainTextBody = 'email body Ref{00DL.5y0LE:a3Q41.17B6O}';
        email2.plainTextBody = 'email body '+'{SendGrid}^ -~'+planList[0].Thread_Id__c;
        email2.htmlBody =  'email body src="cid:126788"'+planList[0].Thread_Id__c;
        System.debug('email.plainTextBody-->'+email2.plainTextBody);
        Messaging.InboundEmail.BinaryAttachment binaryattachment1 = new Messaging.InboundEmail.BinaryAttachment();
        binaryattachment1.body = blob.valueOf('my attachment text');
        binaryattachment1.fileName = 'textfileone.txt';
        binaryattachment1.headers = head2;
        binaryattachment1.mimeTypeSubType = 'text/plain';
        email2.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryattachment1 };
            
            Messaging.InboundEmail.TextAttachment txtattachment1 = new Messaging.InboundEmail.TextAttachment();
        txtattachment1.body = 'my attachment text';
        txtattachment1.fileName = 'textfileone.txt';
        txtattachment1.mimeTypeSubType = 'text/plain';
        //  txtattachment.ParentId = email1.Id;
        email2.textAttachments = new Messaging.inboundEmail.TextAttachment[] { txtattachment1 };
            
         Messaging.InboundEmail email3 = new Messaging.InboundEmail() ;
         Messaging.InboundEnvelope env2 = new Messaging.InboundEnvelope();   
         email3.subject = 'Create Contact1';
         email3.fromAddress = usr1.Email;
         List<String> toAdd2 =new List<String>{'sometestaddress1@email.com'};
         List<String> ccadd2 =new List<String>{'sometestaddress1@email.com'};
         email3.toAddresses = toAdd2;
         email3.ccAddresses = ccadd2;
         email3.plainTextBody = 'email body test'+'{SendGrid}^ -~'+interlockList[0].Thread_Id__c; 
         email3.htmlBody =  'email body'+interlockList[0].Thread_Id__c;
         List<Messaging.InboundEmail.Header> head1 = new List<Messaging.InboundEmail.Header>();
         Messaging.InboundEmail.Header h1= new Messaging.InboundEmail.Header();
         h1.Name = 'Content-ID';
         h1.Value='<12324>';
         head1.add(h1);
       //  Ref{00D01.4bvV:a3Q01.58ac} 
       // Plan__c  plan = new Plan__c ();
        //plan.Thread_Id__c = 'Ref{00D01.4bvV:a3Q01.58ac}';
        //insert plan;
         Messaging.InboundEmail email4 = new Messaging.InboundEmail() ;
         Messaging.InboundEnvelope env4 = new Messaging.InboundEnvelope();   
         email4.subject = 'Create Contact1';
         email4.fromAddress = usr1.Email;
         List<String> toAdd4 =new List<String>{'sometestaddress1@email.com','true@email.com'};
         List<String> ccadd4 =new List<String>{'sometestaddress1@email.com'};
         email4.toAddresses = toAdd2;
         email4.ccAddresses = ccadd2;
         email4.plainTextBody = 'email body test'+'{SendGrid}^ -~'+interlockList[0].Thread_Id__c; 
         email4.htmlBody =  'email body appendonsend'+interlockList[0].Thread_Id__c;

         Messaging.InboundEmail email15 = new Messaging.InboundEmail() ;
         Messaging.InboundEnvelope env5 = new Messaging.InboundEnvelope();   
         email15.subject = 'Create Contact1';
         email15.fromAddress = usr1.Email;
         List<String> toAdd5 =new List<String>{'sometestaddress1@email.com','true@email.com'};
         List<String> ccadd5 =new List<String>{'sometestaddress1@email.com'};
         email15.toAddresses = toAdd5;
         email15.ccAddresses = ccadd5;
         email15.plainTextBody = 'email body test '+pl.Thread_Id__c; 
         email15.htmlBody =  'email body appendonsend '+pl.Thread_Id__c;
       
        
        Messaging.InboundEmail.BinaryAttachment binaryattachment2 = new Messaging.InboundEmail.BinaryAttachment();
        binaryattachment2.body = blob.valueOf('my attachment text 35');
        binaryattachment2.headers = head1 ;
        binaryattachment2.fileName = 'textfileone1.txt';
        binaryattachment2.mimeTypeSubType = 'text/plain';
        email3.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryattachment2 };
        email4.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binaryattachment2 };

        Case cse=new Case();
        insert cse;
 
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=cse.id;
        insert attach;
        
        Plan_Comment__c pc = new Plan_Comment__c();
        pc.Visibility__c = 'External';
        pc.Type__c = 'Inbound';
        pc.Inbound__c = true;
        pc.Status__c = 'Submitted';
        pc.Importance__c = 'High';
        pc.Comment__c = 'src="cid:12324"';
        pc.Plan__c = planList[0].Id;
        pc.Created_By__c = email.fromAddress;
        
        Map<String, Attachment> mapAttachments = new Map<String, Attachment>();
            mapAttachments.put('attach',attach);
        PlanInboundEmail  testInbound=new PlanInboundEmail();        
        testInbound.handleInboundEmail(email15, env5);
        testInbound.handleInboundEmail(email, env);
        testInbound.handleInboundEmail(email2, env1);
        testInbound.handleInboundEmail(email3, env2);
        testInbound.handleInboundEmail(email4, env4);

        PlanInboundEmail.replaceCIDWithAttachmentId(email1,pc,mapAttachments);
                PlanInboundEmail.replaceCIDWithAttachmentId(email5,null,mapAttachments);

        Test.stopTest();
        
    }
    
    
    
    
}