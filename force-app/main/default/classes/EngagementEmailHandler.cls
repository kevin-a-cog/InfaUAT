/*
    @created by       : balajip
    @created on       : 01/13/2020
    @Purpose          : email service handler to process the Inbound emails to Engagement object
    @Testclass        : 
    @JIRA             : 
    
Change History
****************************************************************************************************
ModifiedBy     Date        Jira No.    Tag     Description
****************************************************************************************************
balajip        11/24/2021  I2RT-5015   T01     removed the code that creates Case Comment
balajip        12/12/2021  I2RT-5014   T02     to create an Engagement Record even if no valid Case Reference found
balajip        12/22/2021  I2RT-5011   T03     to not create an Engagement if the Case is already tagged to an active Engagement
balajip        01/12/2022  I2RT-5228   T04     to remove junk from Engagement Detail field
balajip        01/24/2022  I2RT-5326   T05     to make sure refid is matched with Engagement record in a Case Sensitive manner
balajip        02/23/2022  I2RT-5495   T06     to capture the User, that sent the email, on the new Engagement
balajip        07/19/2022  I2RT-6178   T07     to capture errors and notify GCS Escalation Managers
balajip        09/01/2022  I2RT-7043   T08     to notify multiple email addresses on error
balajip        09/05/2022  I2RT-6867   T09     to exclude Lite cases when finding a Case 
balajip        09/05/2022  I2RT-7061   T10     to truncate the value set for HTML and Text body of the EmailMessage record created  
balajip        09/05/2022  I2RT-7176   T11     to capture the inline images in the Description and the Email Messages  
balajip        10/17/2022  I2RT-7444   T12     to handle the scenario when HTML Body of the email is empty
balajip        11/23/2022  I2RT-7436   T13     to not overwrite the Text Body when HTML Body is updated
*/

global without sharing class EngagementEmailHandler implements Messaging.InboundEmailHandler {
    
    public static final String STATUS_NEW = '0';
    public static final String STATUS_READ = '1';
    public static final String STATUS_REPLIED = '2';
    public static final String STATUS_SENT = '3';
    public static final String STATUS_FORWARDED = '4';
    public static final String STATUS_DRAFT = '5';

    global static globalApexManager GAM = new globalApexManager();

    public EngagementEmailHandler() {

    }

    public static String parseRefId(String textToParse){
        Integer firstindex = textToParse.indexOfIgnoreCase('Ref{');
        String refid = '';
        if (firstindex >= 0){
            Integer lastindex = textToParse.indexOfIgnoreCase('}',firstindex+3);
            refid =  textToParse.substring(firstindex,lastindex+1);
        }
        return refid;
    }

    private static String getMatchedString(String regex, String content){
        String matchedString = '';
        
        Matcher matcher = Pattern.compile(regex).matcher(content);
        if(matcher.matches()){
            matchedString = matcher.group(1);
        }

        return matchedString;
    }

    public static Case findCase(Messaging.inboundEmail email){
        Case oCase;
        String sCaseReference = '';
        String sCaseNumber = '';
        try{
            String caseRefRegex = '.*?(ref:_.*?:ref).*';
            sCaseReference = getMatchedString(caseRefRegex, email.subject);
            System.debug('@Developer --> sCaseReference :' + sCaseReference);

            //@Akhilesh 8 Oct 2021 -- start
            //when ref id not found in subject try to search in plainTextBody of email
            if(sCaseReference == ''){
                //caseRefRegex = '(?si).*(ref:_.*?:ref).*';
                caseRefRegex = '(?si).*?(ref:_[0-9A-Za-z]{9}\\._[0-9A-Za-z]{11}:ref).*';
                sCaseReference = getMatchedString(caseRefRegex, email.plainTextBody);
                System.debug('@Developer --> sCaseReference :' + sCaseReference);
            }
            //@Akhilesh 8 Oct 2021 -- end

            if(sCaseReference != ''){
                //@Akhilesh 11 Oct 2021 -- start
                String sTempCaseReference = '%' + sCaseReference + '%';
                System.debug('@Developer --> sTempCaseReference :' + sTempCaseReference);
    
                for(Case c : [Select Id, IsEscalated, Escalation_Reason__c, Engagement__c, Engagement__r.Status__c,
                                AccountId, Support_Account__c From Case
                                Where Old_Ref_Id__c like :sTempCaseReference 
                                  And RecordType.DeveloperName != 'Case_Lite' //T09, T12
                                limit 1])
                {
                    oCase = c;
                }
                //@Akhilesh 11 Oct 2021 -- end
            }
            else{
                String caseNumberRegex = '.*?(\\d{8,}).*';
                sCaseNumber = getMatchedString(caseNumberRegex, email.subject);
                System.debug('@Developer --> sCaseNumber :' + sCaseNumber);
                
                //@Akhilesh 8 Oct 2021 -- start
                //when case number not found in subject try to search in plainTextBody of email
                if(sCaseNumber == ''){
                    caseNumberRegex = '(?si).*?(\\d{8,}).*';
                    sCaseNumber = getMatchedString(caseNumberRegex, email.plainTextBody);
                    System.debug('@Developer --> sCaseNumber :' + sCaseNumber);
                }
                //@Akhilesh 8 Oct 2021 -- end

                //I2RT-4807 - checking for 7 digit Case Number without the leading zero
                if(sCaseNumber == ''){
                    caseNumberRegex = '.*?(\\d{7,}).*';
                    sCaseNumber = getMatchedString(caseNumberRegex, email.subject);
                    System.debug('@Developer --> sCaseNumber :' + sCaseNumber);
                }
                if(sCaseNumber == ''){
                    caseNumberRegex = '(?si).*?(\\d{7,}).*';
                    sCaseNumber = getMatchedString(caseNumberRegex, email.plainTextBody);
                    System.debug('@Developer --> sCaseNumber :' + sCaseNumber);
                }

                if(sCaseNumber != ''){
                    //I2RT-4807
                    if(sCaseNumber.length() == 7){
                        sCaseNumber = '0' + sCaseNumber;
                    }

                    // Try with old case number match first then with (new) case number field i.e. old case then new case
                    //@Akhilesh 11 Oct 2021 -- start
                    for(Case c : [Select Id, IsEscalated, Escalation_Reason__c, Engagement__c, Engagement__r.Status__c,
                                AccountId, Support_Account__c From Case
                                Where Old_Case_Number__c = :sCaseNumber
                                  And RecordType.DeveloperName != 'Case_Lite' //T09, T12
                                limit 1])
                    {
                        oCase = c;
                    }
                    //@Akhilesh 11 Oct 2021 -- end
                    
                    //when old case number doesnot match
                    if(oCase == null){
                        for(Case c : [Select Id, IsEscalated, Escalation_Reason__c, Engagement__c, Engagement__r.Status__c,
                                        AccountId, Support_Account__c From Case
                                        Where CaseNumber = :sCaseNumber
                                          And RecordType.DeveloperName != 'Case_Lite' //T09, T12
                                        limit 1])
                        {
                            oCase = c;
                        }
                    }
                }
            }
        }
        catch(Exception ex){
            GAM.CreateLogs('EngagementEmailHandler --> findCase, ' + 'exception while finding case.. ' + email.messageId, ex.getMessage());
        }   
        System.debug('@Developer --> oCase :' + oCase);

        return oCase;
    }

    //I2RT-4458
    public static void sendResponse(Engagement__c engagement, String toAddress){
        String fromAddress = System.Label.GCS_Escalation_Email_Address;
        List<OrgWideEmailAddress> lstOrgWideEmailAddress = [Select Id From OrgWideEmailAddress 
                                        Where Address = :fromAddress];

        List<EmailTemplate> lstEmailTemplate = [Select Id, Subject, Body, HtmlValue From EmailTemplate 
                                                    Where DeveloperName = 'Email_Escalation_Response'];

        if(!lstEmailTemplate.isEmpty()){
            EmailTemplate emailTemplate = lstEmailTemplate.get(0);
            Messaging.SingleEmailMessage singleEmail = Messaging.renderStoredEmailTemplate(emailTemplate.Id, null, engagement.Id);
            singleEmail.setOrgWideEmailAddressId(lstOrgWideEmailAddress.get(0).Id);
            singleEmail.setToAddresses(new List<String>{toAddress});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { singleEmail });
        }
    }

    //T03
    public static Engagement__c createEngagement(Messaging.inboundEmail email, Case cse, User usrEmailSender){
        //T04
        String detail = '';
        if (email.htmlBody != null) {
            detail = email.htmlBody;
            
            if(detail.indexOf('<body') >= 0 && detail.indexOf('</body>') > 0){
                detail = detail.substring(detail.indexOf('<body'), detail.indexOf('</body>'));
            }
        } else if (email.plainTextBody != null){
            detail = email.plainTextBody;
        }

        Engagement__c engagement = new Engagement__c();
        engagement.RecordTypeId = EngagementService.getRecordTypeId(EngagementService.RECORD_TYPE_NAME_SUPPORT_ESCALATION);
        engagement.Name = email.subject.left(80);
        engagement.Title__c = email.subject.left(255);
        //T07 truncate the value to 32K characters
        engagement.Detail__c = detail.left(32000); //T04
        //engagement.Source__c = 'Customer';
        engagement.Category__c = 'Escalation';
        //T06
        if(usrEmailSender != null){
            engagement.Requested_By__c = usrEmailSender.Id;
        }
        engagement.ownerId =  SkillService.mapQueueNameToQueueId.get(SkillService.getSkillByName(SkillService.SKILL_ESCALATION_MANAGER).Queue_Name__c);
        if(cse != null){
            if(cse.Support_Account__c != null){
                engagement.Support_Account__c = cse.Support_Account__c;
            }
            if(cse.AccountId != null){
                engagement.Account__c = cse.AccountId;
            }
        }
        insert engagement;

        //T11 - process the inline images.
        String updateDetail = updateInlineImages(email, engagement.Id, engagement.Detail__c);
        engagement.Detail__c = updateDetail.left(32000);
        update engagement;

        return engagement;
    }

    //T11 - captures the inine images as content document and replaces the same in the given email content.
    private static String updateInlineImages(Messaging.inboundEmail email, Id parentId, String emailContent){
        String updatedEmailContent = emailContent;

        //T12 proceed only if the emailContent is not empty
        if(email.binaryAttachments != null && String.isNotEmpty(emailContent)){
            System.debug('@Developer --> email.binaryAttachments :' + email.binaryAttachments);
            
            Map< String, Attachment > mapAttachments = new Map< String, Attachment >(); 
            for(Messaging.InboundEmail.BinaryAttachment oBinaryAttachment : email.binaryAttachments) {
                System.debug('@Developer --> oBinaryAttachment :' + oBinaryAttachment);
                
                boolean bInlineImageAttachment = false;
                
                String contentId = '';
                for ( Messaging.InboundEmail.Header header : oBinaryAttachment.headers ) {
                    System.debug('@Developer --> header :' + header);
                    
                    if(header.name == 'Content-Disposition'){
                        String contentDispositionValue = header.value;
                        System.debug('@Developer --> contentDispositionValue :' + contentDispositionValue);
                        if(contentDispositionValue.startsWith('inline;')){
                            bInlineImageAttachment = true;
                        } 
                    }
                    
                    if (header.name == 'Content-ID') {
                        contentId = header.value;
                        System.debug('@Developer --> contentId :' + contentId);
                        if(contentId != '' && contentId != null){ 
                            contentId = contentId.replaceAll('<', '').replaceAll('>', '');
                        } 
                    }
                }
                
                if(bInlineImageAttachment){
                    mapAttachments.put(contentId, new Attachment(Name = oBinaryAttachment.fileName, 
                                                                 body = oBinaryAttachment.body, 
                                                                 ParentId = parentId, 
                                                                 ContentType = oBinaryAttachment.mimeTypeSubType));
                }
            }
            System.debug('@Developer --> mapAttachments :' + mapAttachments);
            if(!mapAttachments.isEmpty()){
                insert mapAttachments.values();
            
                for(String contentId : mapAttachments.keySet()) {
                    System.debug('@Developer --> contentId :' + contentId);
                    
                    String imgSrc = '/servlet/servlet.FileDownload?file=' + mapAttachments.get(contentId).Id;
                    System.debug('@Developer --> imgSrc :' + imgSrc);
                    
                    updatedEmailContent = updatedEmailContent.replaceAll('cid:' + contentId, imgSrc);
                }    
            }
        }
        return updatedEmailContent;
    }

    //T03
    public static void createCaseComment(Messaging.inboundEmail email, Case cse, Engagement__c engagement, User usrEmailSender, String commentText){
        Case_Comment__c caseComment = new Case_Comment__c();
        caseComment.Case__c = cse.Id;
        caseComment.Inbound__c = false;
        caseComment.Status__c = CaseCommentService.STATUS_SUBMITTED;    
        caseComment.Visibility__c = CaseCommentService.VISIBILITY_INTERNAL;  
        //caseComment.Type__c = CaseCommentService.TYPE_ESCALATION;
        caseComment.Comment__c = commentText;
        caseComment.Created_By__c = email.fromAddress;
        if(usrEmailSender != null){
            caseComment.OwnerId = usrEmailSender.Id;
            caseComment.Created_By__c = usrEmailSender.Name;
        }
        insert caseComment;
    }

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
        try{ //T07
            //System.debug('handleInboundEmail-Entry');

            GAM.CreateLogs('EngagementEmailHandler --> handleInboundEmail, ' + email.messageId, 'email.toAddresses :' + email.toAddresses);
            GAM.CreateLogs('EngagementEmailHandler --> handleInboundEmail, ' + email.messageId, 'email.fromAddress :' + email.fromAddress);
            GAM.CreateLogs('EngagementEmailHandler --> handleInboundEmail, ' + email.messageId, 'email.ccaddresses :' + email.ccAddresses);
            GAM.CreateLogs('EngagementEmailHandler --> handleInboundEmail, ' + email.messageId, 'email.FromName :' + email.FromName);
            GAM.CreateLogs('EngagementEmailHandler --> handleInboundEmail, ' + email.messageId, 'email.subject :' + email.subject);
            GAM.CreateLogs('EngagementEmailHandler --> handleInboundEmail, ' + email.messageId, 'email.htmlBody :' + email.htmlBody);
            GAM.CreateLogs('EngagementEmailHandler --> handleInboundEmail, ' + email.messageId, 'email.plainTextBody :' + email.plainTextBody);
            GAM.CreateLogs('EngagementEmailHandler --> handleInboundEmail, ' + email.messageId, 'email.binaryAttachments :' + email.binaryAttachments);
            GAM.CreateLogs('EngagementEmailHandler --> handleInboundEmail, ' + email.messageId, 'email.textAttachments :' + email.textAttachments);
            GAM.CreateLogs('EngagementEmailHandler --> handleInboundEmail, ' + email.messageId, 'email.headers :' + email.headers);

            Boolean isNewEngagementCreated = false;

            Boolean isInternalEmail = false;
            if(email.fromAddress.containsIgnoreCase('informatica')){
                isInternalEmail = true;
            }

            User usrEmailSender;
            List<User> lstUser = [Select Id, Name, Email From User Where Email=:email.fromAddress]; //T03
            GAM.CreateLogs('EngagementEmailHandler --> handleInboundEmail, ' + email.messageId, 'lstUser---> '+lstUser);
            if(!lstUser.isEmpty()){
                usrEmailSender = lstUser.get(0);
            }
            
            // I2RT-4426
            // get the refid from the email body
            String refid = parseRefId(email.plainTextBody);
            GAM.CreateLogs('EngagementEmailHandler --> handleInboundEmail, ' + email.messageId, 'RefId from body: '+refid);
            if(String.isEmpty(refid)){
                // get the refid from the subject
                refid = parseRefId(email.subject);
                GAM.CreateLogs('EngagementEmailHandler --> handleInboundEmail, ' + email.messageId, 'RefId from subject: '+refid);
            }

            String ownerEmail='';

            Engagement__c engagement; 
            List<Engagement__c> lstEngagement = [Select Id, Thread_Id__c, Owner.Email 
                                                    From Engagement__c 
                                                    Where Thread_Id__c = :refid];
            
            //T05 check if the refid equals the Thread Id value in a Case Sensitive manner.
            for(Engagement__c eng : lstEngagement){
                if(refid.equals(eng.Thread_Id__c)){
                    engagement = eng;
                    break;
                }
            }

            if(engagement != null){
                if(engagement.Owner.Email!=null){
                    ownerEmail = engagement.Owner.Email;
                }
                System.debug('ownerEmail-->'+ownerEmail);
            }else if(isInternalEmail){
                Case cse = findCase(email);
                
                //T03
                String commentText = '';
                //get the Engagement the Case is linked if its active
                if(cse != null){
                    if(cse.Engagement__c != null && cse.Engagement__r.Status__c != EngagementService.STATUS_CLOSED){
                        engagement = [Select Id, Engagement_Number__c, Thread_Id__c, Owner.Email From Engagement__c Where Id = :cse.Engagement__c];
                        commentText = 'The case has been escalated via an email to GEMS';
                    }
                }
                
                //T03
                //create a new Engagement if no Case found OR if the Case found is not linked to an active Engagement.
                if(engagement == null){
                    //T02 - create an Engagement Record even if no valid Case Reference found
                    engagement = createEngagement(email, cse, usrEmailSender);
                    isNewEngagementCreated = true;

                    engagement = [Select Id, Engagement_Number__c, Thread_Id__c, Owner.Email From Engagement__c Where Id = :engagement.Id];

                    if(cse != null){
                        cse.IsEscalated = true;
                        cse.Escalation_Reason__c = 'Case Escalated from Sales/CSM';
                        cse.Engagement__c = engagement.Id;
                        update cse;

                        RaiseHandService.raiseEscalation(cse.Id, engagement.Id);

                        commentText = 'The case has been escalated and linked to GEMS ' + engagement.Engagement_Number__c;
                    }else{ //T03
                        RaiseHandService.raiseEscalation(engagement.Id);
                    }
                }
            
                //T01 - Create internal case comment
                if(String.isNotEmpty(commentText)){
                    createCaseComment(email, cse, engagement, usrEmailSender, commentText);
                }
            }

            //T12 - don't process if the email contains no reference and is from external user.
            if(engagement != null){
                String refIdStringToAdd = '********* Do not remove this text {' + engagement.Thread_Id__c + '} *********';

                //T12 moved the logic to create the Email Message record to a seperate method
                EmailMessage emailMessage = createEmailMessage(email, engagement, usrEmailSender, ownerEmail, refIdStringToAdd);
    
                //T12 throw exception if both the HTML and Text body are missing.
                if(emailMessage.HtmlBody == null || emailMessage.TextBody == null){
                    throw new EmailWithNoBodyException('The email has no content, the email body is empty!');
                }
                
                //T12 suppressing the exceptions that is thrown once after the email message record is created.
                try{
                    //T12 moved the logic to process the attachments to a seperate method
                    processAttachments(email, emailMessage, refIdStringToAdd);
                
                    //I2RT-4458
                    if(isInternalEmail && isNewEngagementCreated){
                        sendResponse(engagement, email.fromAddress);
                    }    
                }catch(Exception ex){
                    GAM.CreateLogs('EngagementEmailHandler --> handleInboundEmail, ' + email.messageId, 'exception while processing attachments OR sending response - ' + ex.getMessage());
                }    
            }
        }catch(Exception ex){//T07
            GAM.CreateLogs('EngagementEmailHandler --> handleInboundEmail, ' + email.messageId, 'catch all exception - ' + ex.getMessage());
            notifyError(email, ex.getMessage() + '\n' + ex.getStackTraceString()); //T10
        }

        try{
            GAM.InsertDebugLogs();
        }catch(Exception ex){
            System.debug('exception while inserting debug logs.. ' + ex.getMessage());
        }

        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        result.success = true;
        return result;
    }

    //T07
    public static void notifyError(Messaging.inboundEmail email, String errorMsg){ //T10
        String toAddresses = System.Label.GCS_Escalation_Managers_Email_Address; //T08
        String emailSubject = 'Error while processing escalation email!';
        String emailBody = 'Error occurred while processing the escalation email with the subject line: ';
        emailBody += '\n' + email.Subject;
        emailBody += '\n\nReceived From: ' + email.FromAddress; //T12
        emailBody += '\n\nError Message: ';
        emailBody += '\n' + errorMsg;

        String escalationEmailAddress = System.Label.GCS_Escalation_Email_Address;
        List<OrgWideEmailAddress> lstOrgWideEmailAddress = [Select Id From OrgWideEmailAddress 
                                        Where Address = :escalationEmailAddress];

        //T10 - attach the original email content
        List<Messaging.EmailFileAttachment> lstAttachment = new List<Messaging.EmailFileAttachment>();
        if(email.htmlBody != null){
            Messaging.EmailFileAttachment attachHTMLBody = new Messaging.EmailFileAttachment();
            attachHTMLBody.setFileName(email.subject.left(255) + '.html');
            attachHTMLBody.setBody(Blob.valueOf(email.htmlBody));
            attachHTMLBody.setContentType('application/html');
            attachHTMLBody.setInline(false);
            lstAttachment.add(attachHTMLBody);
        }

        if(email.plainTextBody != null){
            Messaging.EmailFileAttachment attachTextBody = new Messaging.EmailFileAttachment();
            attachTextBody.setFileName(email.subject.left(255) + '.txt');
            attachTextBody.setBody(Blob.valueOf(email.plainTextBody));
            attachTextBody.setContentType('text/plain');
            attachTextBody.setInline(false);
            lstAttachment.add(attachTextBody);
        }

        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
        singleEmail.setSubject(emailSubject);
        singleEmail.setPlainTextBody(emailBody);
        if(!lstOrgWideEmailAddress.isEmpty()){
            singleEmail.setOrgWideEmailAddressId(lstOrgWideEmailAddress.get(0).Id);
        }
        singleEmail.setToAddresses(toAddresses.split(',')); //T08
        //T10
		singleEmail.setFileAttachments(lstAttachment);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { singleEmail });
    }

    //T12 moved the logic to create the Email Message record to this method
    private static EmailMessage createEmailMessage(Messaging.inboundEmail email, Engagement__c engagement, User usrEmailSender, String ownerEmail, String refIdStringToAdd){
        EmailMessage emailMessage = new EmailMessage();
        emailMessage.FromAddress = email.fromAddress;

        if(email.htmlBody != null){
            emailMessage.HtmlBody = email.htmlBody.left(130500); //T10
        }else{
            //T13 set the text body as the HTML body when HTML Body is empty
            if(email.plainTextBody != null){
                String textBody = email.plainTextBody;
                textBody = textBody.replaceAll('\r\n', '<br/>');
                textBody = textBody.replaceAll('\n', '<br/>');
                emailMessage.HtmlBody = textBody.left(130500);
            }else{
                emailMessage.HtmlBody = '';
            }
        }
        GAM.CreateLogs('EngagementEmailHandler --> createEmailMessage, ' + email.messageId, 'emailMessage.HtmlBody-->'+emailMessage.HtmlBody);

        if(email.plainTextBody != null){	
            emailMessage.TextBody = email.plainTextBody.left(130500); //T10	
        }else{	
            emailMessage.TextBody = '';	
        }	
        //T12 - add the refid only if not already present	
        if(String.isNotEmpty(refIdStringToAdd) && emailMessage.TextBody.indexOf(refIdStringToAdd) == -1){	
            emailMessage.TextBody += '\n\n' + refIdStringToAdd;    	
        }	
        GAM.CreateLogs('EngagementEmailHandler --> createEmailMessage, ' + email.messageId, 'emailMessage.TextBody-->'+emailMessage.TextBody);

        //emailMessage.Incoming = true;
        emailMessage.Subject = email.subject;
        emailMessage.MessageDate=System.now();
        
        if(email.toAddresses!=null && email.toAddresses.size()>0){
            emailMessage.ToAddress = String.join(email.toAddresses, ';');
        }
        GAM.CreateLogs('EngagementEmailHandler --> createEmailMessage, ' + email.messageId, 'emailMessage.ToAddress-->'+emailMessage.ToAddress);

        if(email.ccAddresses!=null && email.ccAddresses.size()>0){
            emailMessage.CcAddress = String.join(email.ccAddresses, ';');
        }       
        GAM.CreateLogs('EngagementEmailHandler --> createEmailMessage, ' + email.messageId, 'emailMessage.CcAddress-->'+emailMessage.CcAddress);

        if(engagement != null){
            emailMessage.Engagement__c = engagement.Id;
            emailMessage.RelatedToId = emailMessage.Engagement__c;    
        }

        if(ownerEmail.equalsIgnoreCase(email.fromAddress)){
            if(email.subject!=null && email.subject!=''){
                if(email.subject.startsWith('RE')){
                    emailMessage.Status__c = 'Replied';
                    emailMessage.Status = STATUS_REPLIED;
                    emailMessage.Incoming = false;
                }else if(email.subject.startsWith('FW')){
                    emailMessage.Status__c = 'Forwarded';
                    emailMessage.Status = STATUS_FORWARDED;
                    emailMessage.Incoming = false;
                }else{
                    emailMessage.Status__c = 'Sent';
                    emailMessage.Status = STATUS_SENT;
                    emailMessage.Incoming = false;
                }
            }
        }else{
            emailMessage.Status__c = 'New';
            emailMessage.Status = STATUS_NEW;
            emailMessage.Incoming = true;
        }
        
        if(usrEmailSender != null){
            emailMessage.Created_By__c = usrEmailSender.Id;
        }  

        emailMessage.Last_Modified_Date__c=datetime.now();
        
        GAM.CreateLogs('EngagementEmailHandler --> createEmailMessage, ' + email.messageId, 'emailMessage.Last_Modified_Date__c-->'+emailMessage.Last_Modified_Date__c);
        //System.debug('emailMessage before insert-->'+emailMessage);
        
        insert emailMessage;
        return emailMessage;
    }

    //T12 moved the logic to process the attachments to this method
    private static void processAttachments(Messaging.inboundEmail email, EmailMessage emailMessage, String refIdStringToAdd){
        Boolean hasChanged = false; //T13

        List<Attachment> lstAttachments = new List<Attachment>();
        if(email.textAttachments != null){
            for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                Attachment attachment = new Attachment();
                if(tAttachment.fileName!=null){
                    attachment.Name = tAttachment.fileName;
                }
                if(tAttachment.body!=null){
                    attachment.Body = Blob.valueOf(tAttachment.body);
                }
                attachment.ParentId = emailMessage.Id;
                lstAttachments.add(attachment);
            }    
        }

        if(email.binaryAttachments != null){
            //T11 - to skip the inline images as these are handled subsequently in the method updateInlineImages
            for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                boolean bInlineImageAttachment = false;                    
                for (Messaging.InboundEmail.Header header : bAttachment.headers ) {
                    if(header.name == 'Content-Disposition' && header.value.startsWith('inline;')){
                        bInlineImageAttachment = true;
                    } 
                }
                
                if (!bInlineImageAttachment){
                    Attachment attachment = new Attachment();
                    if(bAttachment.fileName!=null){
                        attachment.Name = bAttachment.fileName;
                    }
                    if(bAttachment.body!=null){
                        attachment.Body = bAttachment.body;
                    }
                    attachment.ParentId = emailMessage.Id;
                    lstAttachments.add(attachment);    
                }
            }
        }

        if(!lstAttachments.isEmpty()){
            database.SaveResult[] myResult=database.insert(lstAttachments,false);

            //update email message
            emailMessage.Has_Attachments__c=true;
            hasChanged = true;//T13
        }

        //T11 - process the inline images.
        String updatedHtmlBody = updateInlineImages(email, emailMessage.Id, emailMessage.HtmlBody);
        if(emailMessage.HtmlBody != updatedHtmlBody){
            emailMessage.Has_Attachments__c=true;
            emailMessage.HtmlBody = updatedHtmlBody.left(130500);
            hasChanged = true;//T13
        }
        GAM.CreateLogs('EngagementEmailHandler --> processAttachments, ' + email.messageId, ' 1. emailMessage.HtmlBody-->'+emailMessage.HtmlBody);

        //T12 - add the refid only if not already present
        if(String.isNotEmpty(refIdStringToAdd) && emailMessage.HtmlBody.indexOf(refIdStringToAdd) == -1){
            emailMessage.HtmlBody += '<br><br>' + refIdStringToAdd;
            hasChanged = true;//T13
        }    
        GAM.CreateLogs('EngagementEmailHandler --> processAttachments, ' + email.messageId, ' 2. emailMessage.HtmlBody-->'+emailMessage.HtmlBody);

        //T13 update only if something changed
        if(hasChanged){
            //T13 update the Text Body so that its not overwritten with the content of HTML body.	
            emailMessage.TextBody = emailMessage.TextBody + '*';
            update emailMessage;
        }
    }

    //T12 - custom exception to be thrown when the email contains no HTML or Text body
    public class EmailWithNoBodyException extends Exception {}
}