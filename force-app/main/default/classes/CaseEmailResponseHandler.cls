/*
Author Name   : Akhilesh Soni
Class Name    : CaseEmailResponseHandler
Created Date  : Dec 22, 2020
Description   : Inbound email handler service class for case comments and case contact creation
**********************************************************************************************************
MODIFIED BY         MODIFIED Date   JIRA          DESCRIPTION                                      TAG
**********************************************************************************************************
Venky              15-April-2022   I2RT-4831     To ignore emails sent as response when a meeting
												 invite is accepted 								T01
Vignesh D          19-July-2022    I2RT-6519     Skip case comment creation for tentative and       T02
                                                 declined response on meeting invites

*/

global class CaseEmailResponseHandler implements Messaging.InboundEmailHandler{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope env){
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        try{ 
            System.debug('@Developer --> email.toAddresses :' + email.toAddresses);
            System.debug('@Developer --> email.fromAddress :' + email.fromAddress);
            System.debug('@Developer --> email.ccaddresses :' + email.ccAddresses);
            System.debug('@Developer --> email.FromName :' + email.FromName);
            System.debug('@Developer --> email.subject :' + email.subject);
            System.debug('@Developer --> email.htmlBody :' + email.htmlBody);
            System.debug('@Developer --> email.plainTextBody :' + email.plainTextBody);
            System.debug('@Developer --> email.binaryAttachments :' + email.binaryAttachments);
            System.debug('@Developer --> email.textAttachments :' + email.textAttachments);
            
            
            
            String sHtmlBody = email.htmlBody;
            String sPlainTextBody = email.plainTextBody;
            
            if(sHtmlBody == null) {
                sHtmlBody = sPlainTextBody;
            }
            
            List<Case_Contact__c> cclist = new List<Case_Contact__c>();
            Case oCase;
            Case_Comment__c oCaseComment;
            Case_Contact__c oCaseContact;
            
            String sCaseReference = '';
            String sCaseNumber = '';
            
            try{
                String caseRefRegex = '.*?(ref:_.*?:ref).*';
                Pattern caseRefPattern = Pattern.compile(caseRefRegex);
                Matcher subjectCaseRefMatcher = caseRefPattern.matcher(email.subject);
                
                if(subjectCaseRefMatcher.matches()){
                    sCaseReference = subjectCaseRefMatcher.group(1);
                }
                System.debug('@Developer --> sCaseReference :' + sCaseReference);
                
                //@Akhilesh 8 Oct 2021 -- start
                //when refid is not found in subject try to search in plainTextBody of email
                
                if(sCaseReference == ''){
                    //caseRefRegex = '(?si).*?(ref:_.*?:ref).*';
                    caseRefRegex = '(?si).*?(ref:_[0-9A-Za-z]{9}\\._[0-9A-Za-z]{11}:ref).*';
                    caseRefPattern = Pattern.compile(caseRefRegex);
                    Matcher bodyCaseRefMatcher = caseRefPattern.matcher(sPlainTextBody);
                    
                    if(bodyCaseRefMatcher.matches()){
                        sCaseReference = bodyCaseRefMatcher.group(1);
                    }
                    System.debug('@Developer --> sCaseReference :' + sCaseReference);
                }
                //@Akhilesh 8 Oct 2021 -- end
                
                if(sCaseReference != ''){
                    //@Akhilesh 11 Oct 2021 -- start
                    String sTempCaseReference = '%' + sCaseReference + '%';
                    System.debug('@Developer --> sTempCaseReference :' + sTempCaseReference);
                    
                    for(Case c : [Select Id,CaseNumber,Old_Case_Number__c,Old_Ref_Id__c ,
                                  (Select Id,Email_formula__c
                                   From Case_Contacts__r)
                                  From Case
                                  Where Old_Ref_Id__c like :sTempCaseReference 
                                  limit 1])
                    {
                        oCase = c;
                    }
                    //@Akhilesh 11 Oct 2021 -- end
                }
                else{
                    String caseNumberRegex = '.*?(\\d{8,}).*';
                    Pattern caseNumberPattern = Pattern.compile(caseNumberRegex);
                    Matcher subjectCaseNumberMatcher = caseNumberPattern.matcher(email.subject);
                    
                    if(subjectCaseNumberMatcher.matches()){
                        sCaseNumber = subjectCaseNumberMatcher.group(1);
                    }
                    System.debug('@Developer --> sCaseNumber :' + sCaseNumber);
                    
                    //@Akhilesh 8 Oct 2021 -- start
                    //when case number not found in subject try to search in plainTextBody of email
                    
                    if(sCaseNumber == ''){
                        
                        caseNumberRegex = '(?si).*?(\\d{8,}).*';
                        caseNumberPattern = Pattern.compile(caseNumberRegex);
                        Matcher bodyCaseNumberMatcher = caseNumberPattern.matcher(sPlainTextBody);
                        
                        if(bodyCaseNumberMatcher.matches()){
                            sCaseNumber = bodyCaseNumberMatcher.group(1);
                        }
                        System.debug('@Developer --> sCaseNumber :' + sCaseNumber);
                    }
                    //@Akhilesh 8 Oct 2021 -- end
                    
                    if(sCaseNumber != ''){
                        
                        // Try with old case number match first then with (new) case number field i.e. old case then new case
                        //@Akhilesh 11 Oct 2021 -- start
                        
                        for(Case c : [Select Id,CaseNumber,Old_Case_Number__c,Old_Ref_Id__c ,
                                      (Select Id,Email_formula__c
                                       From Case_Contacts__r)
                                      From Case
                                      Where Old_Case_Number__c = :sCaseNumber
                                      limit 1])
                        {
                            oCase = c;
                        }
                        //@Akhilesh 11 Oct 2021 -- end
                        
                        //when old case number doesnot match
                        if(oCase == null){
                            for(Case c : [Select Id,CaseNumber,Old_Case_Number__c,Old_Ref_Id__c ,
                                          (Select Id,Email_formula__c
                                           From Case_Contacts__r)
                                          From Case
                                          Where CaseNumber = :sCaseNumber
                                          limit 1])
                            {
                                oCase = c;
                            }
                        }
                    }
                }
            }
            catch(Exception ex){
                System.debug('@Developer --> ex.getMessage():' + ex.getMessage());
            }
            System.debug('@Developer --> oCase :' + oCase);
            
            //-----------------------------------<T01/>--------------
            
            if(email.subject.startswith('Accepted: ') || email.subject.startswith('Declined: ') || email.subject.startsWith('Tentative: ')){ //<T02>
                
            }
            else if(oCase != null){
                System.debug('@Developer --> CaseFound => Case Details:' + oCase.Id + '-->' + oCase.CaseNumber );
                oCase.Inbound_comment__c = true;
                oCase.Next_Action__c = 'Case Owner';
                oCaseComment = new Case_Comment__c();
                oCaseComment.Case__c = oCase.Id;
                oCaseComment.Inbound__c = true;
                //oCaseComment.Source__c = 'Email';
                //@Akhilesh 3 Aug 2021 --start
                oCaseComment.Status__c = 'Submitted';    
                oCaseComment.Visibility__c = 'External';  
                oCaseComment.Comment_Category__c = null;
                //@Akhilesh 3 Aug 2021 --end
                
                //I2RT-4364
                if(email.toAddresses.contains(System.Label.GCS_Escalation_Email_Address)){
                    oCaseComment.Type__c = CaseCommentService.TYPE_ESCALATION;
                }
                
                String sBody = '';
                Boolean bRegularExpressionFailed = false;				
                String bodyRegexGmail = '(?si)^(.*?)<div class="gmail_quote">.*';
                Pattern bodyPatternGmail = Pattern.compile(bodyRegexGmail);
                try{
                    Matcher bodyMatcherGmail = bodyPatternGmail.matcher(sHtmlBody);
                    if(bodyMatcherGmail.matches()){
                        sBody = bodyMatcherGmail.group(1);
                    }
                    System.debug('@Developer --> sBody :' + sBody);
                }
                catch(Exception ex){
                    System.debug('@Developer --> ex.getMessage() :' + ex.getMessage());
                    
                    sBody = '';
                    if(ex.getMessage() == 'Script-thrown exception'){
                        bRegularExpressionFailed = true;
                    }
                }
                
                if(sBody == '' || sBody == null){
                    integer nAppendOnSendIndx = -1;
                    integer nReplyFwdMsgIndx = -1;
                    
                    if(sHtmlBody.toLowerCase().contains('appendonsend"') ){
                        nAppendOnSendIndx = sHtmlBody.toLowerCase().indexOf('appendonsend"');
                    }
                    System.debug('@Developer --> nAppendOnSendIndx :' + nAppendOnSendIndx);
                    
                    if(sHtmlBody.toLowerCase().contains('rplyfwdmsg"') ){
                        nReplyFwdMsgIndx = sHtmlBody.toLowerCase().indexOf('rplyfwdmsg"'); 
                    }
                    System.debug('@Developer --> nReplyFwdMsgIndx :' + nReplyFwdMsgIndx);
                    
                    //@Akhilesh 19 Oct 2021 --start
                    if(nAppendOnSendIndx == -1 && nReplyFwdMsgIndx == -1){
                        sBody = sHtmlBody;
                    }
                    else if(nAppendOnSendIndx == -1){
                        sBody = sHtmlBody.left(nReplyFwdMsgIndx) + 'rplyfwdmsg"/></body></html>';
                    }
                    else if(nReplyFwdMsgIndx == -1){
                        sBody = sHtmlBody.left(nAppendOnSendIndx) + 'appendonsend"/></body></html>';
                    }
                    else if(nAppendOnSendIndx < nReplyFwdMsgIndx){
                        sBody = sHtmlBody.left(nAppendOnSendIndx) + 'appendonsend"/></body></html>';
                    }
                    else if(nReplyFwdMsgIndx < nAppendOnSendIndx){
                        sBody = sHtmlBody.left(nReplyFwdMsgIndx) + 'rplyfwdmsg"/></body></html>';
                    }
                    //@Akhilesh 19 Oct 2021 --end
                }
                
                sBody = sBody.replace('<style type="text/css" style="display:none;"> P {margin-top:0;margin-bottom:0;} </style>','');
                sBody = sBody.replaceAll('<title.*?>.*?</title>','');
                
                System.debug('@Developer --> sBody :' + sBody);
                oCaseComment.Comment__c = '<pre>' + sBody + '</pre>';
                
                list<String> lstEmailDetail = new list<String>();
                lstEmailDetail.add(email.fromAddress);
                
                lstEmailDetail.addall(email.toAddresses);
                
                if(email.ccAddresses != null && email.ccAddresses.size() > 0){
                    lstEmailDetail.addall(email.ccAddresses);
                }
                System.debug('@Developer --> email.fromAddress :' + email.fromAddress);
                System.debug('@Developer --> email.toAddresses :' + email.toAddresses);
                System.debug('@Developer --> lstEmailDetail :' + lstEmailDetail);
                
                Set<String> setEmail = new Set<String>();
                Map<String,Id> mapEmailWiseConId = new Map<String,Id>();
                
                for(Case_Contact__c oCC: oCase.Case_Contacts__r){
                    setEmail.add(oCC.Email_formula__c);
                }
                System.debug('@Developer --> setEmail :' + setEmail);
                
                for(Contact con : [Select Id,Email From Contact where Email in :lstEmailDetail]){
                    mapEmailWiseConId.put(con.Email,con.Id);                        
                }
                
                System.debug('@Developer --> mapEmailWiseConId :' + mapEmailWiseConId);
                
                //@Akhilesh 27 SEpt 2021 -- start
                Set<String> setExcludedEmail = new set<String>();
                for(Exclude_Support_Emails__mdt ese : [Select Id,Email__c 
                                                       From Exclude_Support_Emails__mdt 
                                                       Where Email__c != null 
                                                       And Active__c = true])
                {
                    setExcludedEmail.add(ese.Email__c);
                }
                System.debug('@Developer --> setExcludedEmail :' + setExcludedEmail);
                //@Akhilesh 27 SEpt 2021 -- end
                
                for(String sEmail: lstEmailDetail){
                    System.debug('@Developer --> sEmail :' + sEmail);
                    
                    //@Akhilesh 27 SEpt 2021 -- start                            
                    //if(!sEmail.contains('informatica.com') && !sEmail.contains('salesforce.com') && !setEmail.contains(sEmail)){
                    if(!sEmail.contains('salesforce.com') && !setExcludedEmail.contains(sEmail) && !setEmail.contains(sEmail)){
                        oCaseContact = new Case_Contact__c();
                        oCaseContact.Case__c = oCase.Id;
                        //oCaseContact.Name = 'Email Contact';
                        oCaseContact.Email__c = sEmail;
                        if(mapEmailWiseConId.containsKey(sEmail)){
                            oCaseContact.Contact__c = mapEmailWiseConId.get(sEmail);
                        }
                        cclist.add(oCaseContact);
                    }       
                }	
                System.debug('@Developer --> cclist :' + cclist);  
                
                SavePoint oSavePoint = Database.setSavepoint();
                Boolean iscasecontact = false;
                try{
                    //@Akhilesh 18 Oct 2021 -- start
                    String commentBody = oCaseComment.Comment__c;
                    System.debug('@Developer --> commentBody :' + commentBody);
                    
                    //comment is not in proper format restore comment with complete email body to avoid data loss
                    if(commentBody.endsWith('&quot;/&gt;')){ //appendonsend&quot;/&gt; or rplyfwdmsg&quot;/&gt;
                        oCaseComment.Comment__c = sHtmlBody;
                    }
                    //@Akhilesh 18 Oct 2021 -- end
                    
                    if(oCaseComment != null){
                        for(User u : [Select Id,Name From User Where email = :email.fromAddress limit 1]){
                            System.debug('@Developer --> comment Owner :' + u);
                            oCaseComment.OwnerId = u.Id;
                            oCaseComment.Created_By__c = u.Name;
                            iscasecontact = true;
                        }
                        if(!iscasecontact ){ 
                            oCaseComment.Created_By__c = email.fromAddress;
                        }
                        insert oCaseComment;
                        
                        //@Akhilesh 9 Oct 2021 -- start
                        update oCase;
                        //@Akhilesh 9 Oct 2021 -- end
                        
                        List<ContentVersion> lstAttachment = new List<ContentVersion>();               
                        
                        Map< String, Attachment > mapAttachments = new Map< String, Attachment >(); 
                        if(email.binaryAttachments != null){
                            System.debug('@Developer --> email.binaryAttachments :' + email.binaryAttachments);
                            
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
                                                                                 ParentId = oCaseComment.Id, 
                                                                                 ContentType = oBinaryAttachment.mimeTypeSubType));
                                }
                                else{
                                    ContentVersion oContentVersion = new ContentVersion();
                                    oContentVersion.title = oBinaryAttachment.fileName;
                                    oContentVersion.PathOnClient  = oBinaryAttachment.fileName;
                                    oContentVersion.versiondata  = oBinaryAttachment.body;
                                    oContentVersion.IsMajorVersion  = true;
                                    lstAttachment.add(oContentVersion);
                                }
                            }
                            System.debug('@Developer --> mapAttachments :' + mapAttachments);
                            insert mapAttachments.values();
                            
                            for(String contentId : mapAttachments.keySet()) {
                                System.debug('@Developer --> contentId :' + contentId);
                                
                                String imgSrc = '/servlet/servlet.FileDownload?file=' + mapAttachments.get(contentId).Id;
                                System.debug('@Developer --> imgSrc :' + imgSrc);
                                
                                oCaseComment.Comment__c = oCaseComment.Comment__c.replaceAll('cid:' + contentId, imgSrc);
                            }
                            update oCaseComment;
                        }
                        
                        if (email.textAttachments != null) {
                            System.debug('@Developer --> email.textAttachments :' + email.textAttachments);
                            
                            for (Messaging.Inboundemail.TextAttachment oTextAttachment : email.textAttachments) {
                                ContentVersion oContentVersion = new ContentVersion();
                                oContentVersion.title = oTextAttachment.fileName;
                                oContentVersion.PathOnClient  = oTextAttachment.fileName;
                                oContentVersion.versiondata  = blob.valueOf(oTextAttachment.body);
                                oContentVersion.IsMajorVersion  = true;
                                lstAttachment.add(oContentVersion);
                            }
                        }
                        System.debug('@Developer --> lstAttachment :' + lstAttachment);
                        
                        if(lstAttachment.size() > 0){
                            insert lstAttachment;
                        }
                        
                        List<ContentVersion> lstContentVersion = [SELECT Id, ContentDocumentId,Title,FileExtension 
                                                                  FROM ContentVersion
                                                                  WHERE Id IN :lstAttachment];
                        List<ContentDocumentLink> lstContentDocumentLink = new List<ContentDocumentLink>();
                        Set<String> setAttachmentName = new Set<String>();
                        
                        for(ContentVersion oContentVersion : lstContentVersion){
                            
                            //for case comment
                            ContentDocumentLink oContentDocumentLink = new ContentDocumentLink();
                            oContentDocumentLink.LinkedEntityId = oCaseComment.Id;
                            oContentDocumentLink.ContentDocumentId = oContentVersion.ContentDocumentId;
                            oContentDocumentLink.ShareType = 'v';
                            oContentDocumentLink.Visibility = 'AllUsers'; 
                            
                            //@Akhilesh 7 Sept 2021 -- start
                            //setAttachmentName.add(oContentVersion.Title + '.' + oContentVersion.FileExtension);
                            setAttachmentName.add(oContentVersion.Title);
                            //@Akhilesh 7 Sept 2021 -- end
                            
                            lstContentDocumentLink.add(oContentDocumentLink);
                            
                            //for case 
                            oContentDocumentLink = new ContentDocumentLink();
                            oContentDocumentLink.LinkedEntityId = oCase.Id;
                            oContentDocumentLink.ContentDocumentId = oContentVersion.ContentDocumentId;
                            oContentDocumentLink.ShareType = 'v';
                            oContentDocumentLink.Visibility = 'AllUsers'; 
                            lstContentDocumentLink.add(oContentDocumentLink);
                        }
                        
                        System.debug('@Developer --> lstContentDocumentLink :' + lstContentDocumentLink);
                        if(lstContentDocumentLink.size() > 0){
                            insert lstContentDocumentLink;
                        }
                        
                        System.debug('@Developer --> setAttachmentName :' + setAttachmentName);                        
                        
                        oCaseComment.Comment__c += '<br>Lookout for these attachments in the case,<br>' + String.join(new List<String>(setAttachmentName), '<br>');
                        
                        if(lstContentDocumentLink.size() > 0){
                            update oCaseComment;
                        }
                    }
                    
                    system.debug('caseContact= '+cclist.size());
                    if(cclist.size() > 0 ){
                        insert cclist;    
                    }
                } 
                catch(Exception ex){
                    System.debug('@Developer --> Exception StackTrace :' + ex.getStackTraceString());
                    System.debug('@Developer --> Exception :' + ex.getMessage());
                    Database.rollback(oSavePoint);                    
                }
                //I2RT-4727
            }
            else{
                System.debug('@Developer -->Case Not found creating email message:' );
                
                SavePoint oSavePoint = Database.setSavepoint();
                try{
                    //@Akhilesh 8 Oct 2021 -- start
                    //when case reference itself not found creating a email message to track the email
                    EmailMessage oEmailMessage = new EmailMessage();
                    oEmailMessage.Status = '0';
                    oEmailMessage.Subject = email.subject;
                    oEmailMessage.FromName = email.fromName;
                    oEmailMessage.FromAddress = email.fromAddress;
                    oEmailMessage.ToAddress	= String.join(email.toAddresses,';');
                    
                    if(email.ccAddresses != null && email.ccAddresses.size() > 0){
                        oEmailMessage.CcAddress	= String.join(email.ccAddresses,';');
                    }
                    
                    if(email.htmlBody.length() > 131000){
                        oEmailMessage.HtmlBody = email.htmlBody.left(131000);
                    }
                    else{
                        oEmailMessage.HtmlBody = email.htmlBody;    
                    }
                    
                    if(email.plainTextBody.length() > 131000){
                        oEmailMessage.TextBody = email.plainTextBody.left(131000);
                    }
                    else{
                        oEmailMessage.TextBody = email.plainTextBody;    
                    }
                    /*
oEmailMessage.HasAttachment = false;
if(email.textAttachments != null || email.binaryAttachments != null){
oEmailMessage.HasAttachment = true;
}*/
                    
                    insert oEmailMessage;
                    System.debug('@Developer --> oEmailMessage.Id :' + oEmailMessage.Id);
                    
                    List<ContentVersion> lstAttachment = new List<ContentVersion>();                
                    if (email.binaryAttachments != null) {
                        System.debug('@Developer --> email.binaryAttachments :' + email.binaryAttachments);
                        for(Messaging.InboundEmail.BinaryAttachment oBinaryAttachment : email.binaryAttachments) {
                            ContentVersion oContentVersion = new ContentVersion();
                            oContentVersion.title = oBinaryAttachment.fileName;
                            oContentVersion.PathOnClient  = oBinaryAttachment.fileName;
                            oContentVersion.versiondata  = oBinaryAttachment.body;
                            oContentVersion.IsMajorVersion  = true;
                            lstAttachment.add(oContentVersion);
                        }
                    }
                    System.debug('@Developer --> lstAttachment :' + lstAttachment);
                    
                    if (email.textAttachments != null) {
                        System.debug('@Developer --> email.textAttachments :' + email.textAttachments);
                        for (Messaging.Inboundemail.TextAttachment oTextAttachment : email.textAttachments) {
                            ContentVersion oContentVersion = new ContentVersion();
                            oContentVersion.title = oTextAttachment.fileName;
                            oContentVersion.PathOnClient  = oTextAttachment.fileName;
                            oContentVersion.versiondata  = blob.valueOf(oTextAttachment.body);
                            oContentVersion.IsMajorVersion  = true;
                            lstAttachment.add(oContentVersion);
                        }
                    }
                    System.debug('@Developer --> lstAttachment :' + lstAttachment);
                    
                    if(lstAttachment.size() > 0){
                        insert lstAttachment;
                    }
                    
                    List<ContentVersion> lstContentVersion = [SELECT Id, ContentDocumentId,Title,FileExtension 
                                                              FROM ContentVersion
                                                              WHERE Id IN :lstAttachment];
                    
                    List<ContentDocumentLink> lstContentDocumentLink = new List<ContentDocumentLink>();
                    
                    for(ContentVersion oContentVersion : lstContentVersion){
                        //for EmailMessage
                        ContentDocumentLink oContentDocumentLink = new ContentDocumentLink();
                        oContentDocumentLink.LinkedEntityId = oEmailMessage.Id;
                        oContentDocumentLink.ContentDocumentId = oContentVersion.ContentDocumentId;
                        oContentDocumentLink.ShareType = 'v';
                        oContentDocumentLink.Visibility = 'AllUsers'; 
                        lstContentDocumentLink.add(oContentDocumentLink);
                    }
                    
                    System.debug('@Developer --> lstContentDocumentLink :' + lstContentDocumentLink);
                    if(lstContentDocumentLink.size() > 0){
                        insert lstContentDocumentLink;
                    }								
                } 
                catch(Exception ex){
                    System.debug('@Developer --> Exception StackTrace :' + ex.getStackTraceString());
                    System.debug('@Developer --> Exception :' + ex.getMessage());
                    Database.rollback(oSavePoint);                    
                }
                //@Akhilesh 8 Oct 2021 -- end
                
                
                
                try{
                    sendResponse(email.fromAddress);
                }catch(Exception ex){
                    System.debug('CaseEmailResponseHandler.handleInboundEmail.. Error occurred while trying to send auto response' + ex.getMessage());
                }
            }
        }
        catch (Exception ex){
            System.debug('@Developer --> Exception :' + ex.getMessage());
        }
        result.success = true;
        return result;
    }
    
    //I2RT-4727
    public static void sendResponse(String toAddress){
        String fromAddress = System.Label.No_Reply_Email_Address;
        List<OrgWideEmailAddress> lstOrgWideEmailAddress = [Select Id From OrgWideEmailAddress Where Address = :fromAddress];
        
        List<EmailTemplate> lstEmailTemplate = [Select Id, Subject, Body, HtmlValue From EmailTemplate 
                                                Where DeveloperName = 'Unable_To_Process_Email'];
        
        if(!lstEmailTemplate.isEmpty()){
            EmailTemplate emailTemplate = lstEmailTemplate.get(0);
            Messaging.SingleEmailMessage singleEmail = Messaging.renderStoredEmailTemplate(emailTemplate.Id, null, null);
            singleEmail.setOrgWideEmailAddressId(lstOrgWideEmailAddress.get(0).Id);
            //singleEmail.setReplyTo(fromAddress);
            //singleEmail.setSenderDisplayName('No-Reply at Informatica Support');
            singleEmail.setToAddresses(new List<String>{toAddress});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { singleEmail });
        }
    }
}