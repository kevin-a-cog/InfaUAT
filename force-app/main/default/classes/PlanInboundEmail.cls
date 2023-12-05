/*
@created by       : Venky K
@created on       : 4/29/2020
@Purpose          : EmailMessage Trigger.
@Testclass        : 
@JIRA             : 
@Tag              : T01


Change History
*****************************************************************************************************************
ModifiedBy            Date        Requested By        Description                         Jira No.       Tag
*****************************************************************************************************************
Aishwarya Badri     13-08-2020                                                            AR-1185         
Karthi G            13-02-2023                        Has Atttachment field issue fix     AR-3101       <T01>

*/

global  without sharing class  PlanInboundEmail implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
        Boolean boolDuplicatedEmail = false;
        Datetime datTLast10Minutes = Datetime.now().addMinutes(-10);
        String strHTMLBody = email.htmlBody;
        EmailMessage emailMessage1 = new EmailMessage();
        Plan_Comment__c objPlanComment = new Plan_Comment__c();
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();  
        List<Related_Opportunity_Plan__c> relatedOppty= new List<Related_Opportunity_Plan__c>();
        List<Plan__c> pl= new List<Plan__c>();
        List<Attachment> attachments = new List<Attachment>();
        Set<Id> emailsWithAttachments=new Set<Id>();
        List<EmailMessage> lstEmailMessages=new List<EmailMessage>();
        // Add the email plain text into the local variable 
        String  myPlainText = email.plainTextBody;   
        String planOwnerEmail='';
        String relatedPlanOpptyOwnerEmail='';                                                  
        
        Integer firstindex = myPlainText.indexOfIgnoreCase('Ref{'); 
        
        Integer lastindex = myPlainText.indexOfIgnoreCase('}',firstindex+3);
        String refid =  myPlainText.substring(firstindex,lastindex+1);    
        Integer refindex = myPlainText.indexOfIgnoreCase('ref:');    
        system.debug('RefId from body:'+refid);
        // Set<Id> refId=new Set<Id>();
        List<Plan__c> lstPlan=new List<Plan__c>();
        List<Related_Opportunity_Plan__c> lstInterlock=new List<Related_Opportunity_Plan__c>();
        pl = [select id,Thread_Id__c,Owner.Email, CSM_isAutoPilot__c,User_Queue_Id__c from Plan__c where Thread_Id__c = :refid ];
        system.debug('refid>>>>>><<<<<<<' +pl);
        
        //We replace unnecesary HTML code, if present.
        if(String.isNotBlank(strHTMLBody)) {
            strHTMLBody = strHTMLBody.replace(' xmlns:o="urn:schemas-microsoft-com:office:office" ' + 
            'xmlns:w="urn:schemas-microsoft-com:office:word" xmlns:m="http://schemas.microsoft.com/office/2004/12/omml" ' + 
            'xmlns="http://www.w3.org/TR/REC-html40"', '').replace('<title>Document</title>', '');
        }
                                
        //Now we check if this is an email originally comming from sendgrind.
        if(String.isNotBlank(email.plainTextBody) && email.plainTextBody.indexOfIgnoreCase('{SendGrid}') >= 0 && pl != null && !pl.isEmpty()) {
            //Now we remove the trailing data.
            if(String.isBlank(strHTMLBody)) {
                strHTMLBody = email.plainTextBody;
            }
            strHTMLBody = removeTrail(strHTMLBody);

            //Now we prepare the comment.
            objPlanComment.Visibility__c = 'External';
            objPlanComment.Type__c = 'Inbound';
            objPlanComment.Inbound__c = true;
            objPlanComment.Comment__c = strHTMLBody;
            if(strHTMLBody?.length()>32768 || Test.isRunningTest()){
                objPlanComment.Comment__c = strHTMLBody?.stripHtmlTags().left(32768);
            }
            objPlanComment.Plan__c = pl[0].Id;
            objPlanComment.Status__c = 'Submitted';
            objPlanComment.Created_By__c = email.fromAddress;
            for(User objUser : [SELECT Name FROM User WHERE IsActive = TRUE AND email = :email.fromAddress LIMIT 1]) {
                objPlanComment.Created_By__c = objUser.Name;
            }
            insert objPlanComment;

            //Now generate the inline attachments and normal ones.
            if(generateInlineFilesAndAttachments(null, objPlanComment, email)) {
                update objPlanComment;
            }
        } else {            
            //This is not a Sendgrid email, so we proceed normally.
            if(pl!=null && pl.size() > 0) 
            {
                for(Plan__c p :pl)
                {
                    if(p.Thread_Id__c!=null)
                    {
                        if(refid.equals(p.Thread_Id__c))
                        {
                            lstPlan.add(p);
                            break;
                        }
                    }
                    
                }
            }
                if(lstPlan.isEmpty())
                    {
                        
                        relatedOppty=[select Id,Thread_Id__c,OwnerId,Owner.Email,Plan__c,Plan__r.OwnerId,Plan__r.Owner.Email from Related_Opportunity_Plan__c where Thread_Id__c = :refid];
                        for(Related_Opportunity_Plan__c interlock :relatedOppty)
                        {
                            if(interlock.Thread_Id__c!=null)
                            {
                                if(refid.equals(interlock.Thread_Id__c))
                                {
                                    lstInterlock.add(interlock);
                                    break;
                                }
                            }
                        }
                    }
                
            if(lstPlan!=null && lstPlan.size()>0)
            { 
                if(lstPlan[0].Owner.Email!=null)
                    planOwnerEmail=lstPlan[0].Owner.Email;

                    //AR-3222
                    if(CSM_Static_Value__mdt.getInstance('CSM_Create_Autopilot_Comment_from_Email')?.Value__c =='TRUE' && lstPlan[0].CSM_isAutoPilot__c){
                        objPlanComment.Visibility__c = 'Internal';
                        objPlanComment.Type__c = 'Cassini';
                        objPlanComment.Sub_Type__c = 'Auto Pilot';
                        String s = 'Alert: New message received from the customer. Once the engagement is completed, kindly utilize the reply feature here to conclude the engagement.<br>Inbound Type : Email from Customer <br> Message: <br>';
                        if(strHTMLBody?.length()>32768 || Test.isRunningTest()){
                            s+=removeTrail(strHTMLBody);
                            s = s?.stripHtmlTags().left(32768);
                        }
                        else{
                            s=strHTMLBody;
                        }
                        objPlanComment.Comment__c = s;
                        objPlanComment.Plan__c = pl[0].Id;
                        objPlanComment.Status__c = 'Submitted';
                        objPlanComment.OwnerId = pl[0].User_Queue_Id__c;
                        objPlanComment.Attention_Request_Status__c = 'New';
                        for(User objUser : [SELECT Name FROM User WHERE IsActive = TRUE AND email = :email.fromAddress LIMIT 1]) {
                            objPlanComment.Created_By__c = objUser.Name;
                        }
                        insert objPlanComment;
                    }
            }else if(lstInterlock!=null && lstInterlock.size()>0)
            {
                //get interlcoks plan owner email and store it in relatedOpptyOwnerEmail
                if(lstInterlock[0].Plan__c!=null && lstInterlock[0].Plan__r.OwnerId!=null && lstInterlock[0].Plan__r.Owner.Email!=null)
                    
                relatedPlanOpptyOwnerEmail=lstInterlock[0].Plan__r.Owner.Email;
                System.debug('relatedPlanOpptyOwnerEmail-->'+relatedPlanOpptyOwnerEmail);
            }
            
            emailMessage1.FromAddress = email.fromAddress;        
            emailMessage1.HtmlBody = strHTMLBody;
            emailMessage1.TextBody = email.plainTextBody;
            //emailMessage1.Incoming = true;
            emailMessage1.Subject = email.subject;
            emailMessage1.MessageDate=System.now();
            emailMessage1.Status = '1';
            
            if(email.toAddresses!=null && email.toAddresses.size()>0)
            {
                emailMessage1.toAddress = email.toAddresses[0];
                for(Integer i=1; i< email.toAddresses.size(); i++){        
                    emailMessage1.toAddress = emailMessage1.toAddress + ';' + email.toAddresses[i];
                }
            }
            
            
            if(email.ccAddresses!=null && email.ccAddresses.size()>0)
            {
                emailMessage1.CcAddress=  email.ccAddresses[0];
                for(Integer i=1; i< email.ccAddresses.size(); i++)
                { 
                    emailMessage1.CcAddress = emailMessage1.CcAddress + ';' + email.ccAddresses[i];
                }
            }
            
            System.debug('emailMessage1.CcAddress-->'+emailMessage1.CcAddress);
            
            if(lstPlan!=null && lstPlan.size()>0)
            {
                emailMessage1.Plan__c= lstPlan[0].Id;
                emailMessage1.RelatedToId= lstPlan[0].Id;
            }else if(lstInterlock!=null && lstInterlock.size()>0)
            {
                emailMessage1.Interlock__c= lstInterlock[0].Id;
                emailMessage1.RelatedToId= lstInterlock[0].Id;
            }
            
            
            
            
            
            
            System.debug('from address-->'+email.fromAddress);
            System.debug('toAddresses-->'+email.toAddresses);
            System.debug('planOwnerEmail-->'+planOwnerEmail);
            System.debug('relatedPlanOpptyOwnerEmail-->'+relatedPlanOpptyOwnerEmail);
            
            
            
            
            if(email.fromAddress!=null && email.fromAddress!='')
            {
                if(email.fromAddress==planOwnerEmail || email.fromAddress==relatedPlanOpptyOwnerEmail)
                {
                    if(email.subject!=null && email.subject!='')
                    {
                        if(email.subject.startsWith('RE'))
                        {
                            emailMessage1.Status__c='Replied';
                            emailMessage1.Incoming = false;
                        }else if(email.subject.startsWith('FW'))
                        {
                            emailMessage1.Status__c='Forwarded';
                            emailMessage1.Incoming = false;
                        }else
                        {
                            emailMessage1.Status__c='Sent';
                            emailMessage1.Incoming = false;
                        }
                    }
                }else
                {
                    emailMessage1.Status__c='New';
                    emailMessage1.Incoming = true;
                }
            }                      
            
            if(email.fromAddress!=null && email.fromAddress!='')
            {
                emailMessage1.FromName = email.fromAddress;
                List<User> usr=[select Id,email, Name from User where isActive=true and email=:email.fromAddress];
                System.debug('usr--->'+usr);
                if(usr!=null && usr.size()>0)
                {
                    emailMessage1.Created_By__c=usr[0].Id;   
                    emailMessage1.FromName = usr[0].Name;
                }  
            }
            emailMessage1.Last_Modified_Date__c=datetime.now();
            System.debug('mailMessage1.Last_Modified_Date__c-->'+emailMessage1.Last_Modified_Date__c);
            System.debug('emailMessage1 before insert-->'+emailMessage1);
            try
            {
                //Now we check if this is an immediate reply from the Customer Success email account.
                for(EmailMessage objEmailMessage : [SELECT TextBody FROM EmailMessage WHERE RelatedToId = :emailMessage1.RelatedToId AND CreatedDate >= :datTLast10Minutes LIMIT 10000]) {
                    if(objEmailMessage.TextBody.replaceAll('[^ -~]+', ' ').replace(' ', '').trim() == email.plainTextBody.replaceAll('[^ -~]+', ' ').replace(' ', '').trim()) {
                        boolDuplicatedEmail = true;
                        break;
                    }
                }

                //If this is not an immediate reply from the Customer Success email account, we insert the Email Message.
                if(!boolDuplicatedEmail) {
                    insert emailMessage1;

                    //Now generate the inline attachments and normal ones.
                    if(generateInlineFilesAndAttachments(emailMessage1, null, email)) {
                        emailMessage1.Has_Attachments__c = true;
                        update emailMessage1;
                    }
                }
            }catch(Exception e)
            {
                System.debug('Exception e-->'+e.getMessage());
            }

            result.success = true;
        }                
        return result;
    }

    /*
     Method Name : removeTrail
     Description : This method removes the trailing messages from the given string.
     Parameters  : String, called from removeTrail, strBody String body.
     Return Type : String
     */
    public static String removeTrail(String strBody) {
        Boolean boolIndexChanged = false;
        Integer intAppendOnSendIndex = -1;
        Integer intReplyForwardMessageIndex = -1;
        String strResult = strBody;
        Matcher objBodyMatcherGmail;

        //If we received data.
        if(String.isNotBlank(strResult)) {

            //Gmail.
            try {
                objBodyMatcherGmail = Pattern.compile('(?si)^(.*?)<div class="gmail_quote">.*').matcher(strResult);
                if(objBodyMatcherGmail.matches()) {
                    strResult = objBodyMatcherGmail.group(1);
                }
            } catch(Exception ex) {}

            //Indexes.
            if(strResult.toLowerCase().contains('appendonsend"') ) {
                intAppendOnSendIndex = strResult.toLowerCase().indexOf('appendonsend"');
                boolIndexChanged = true;
            }
            if(strResult.toLowerCase().contains('rplyfwdmsg"') ) {
                intReplyForwardMessageIndex = strResult.toLowerCase().indexOf('rplyfwdmsg"');
                boolIndexChanged = true;
            }

            //If the index changed.
            if(boolIndexChanged) {
                if(intAppendOnSendIndex == -1) {
                    strResult = strResult.left(intReplyForwardMessageIndex) + 'rplyfwdmsg"/></body></html>';
                } else if(intReplyForwardMessageIndex == -1) {
                    strResult = strResult.left(intAppendOnSendIndex) + 'appendonsend"/></body></html>';
                } else if(intAppendOnSendIndex < intReplyForwardMessageIndex) {
                    strResult = strResult.left(intAppendOnSendIndex) + 'appendonsend"/></body></html>';
                } else if(intReplyForwardMessageIndex < intAppendOnSendIndex) {
                    strResult = strResult.left(intReplyForwardMessageIndex) + 'rplyfwdmsg"/></body></html>';
                }
            }

            //Now we apply specific filtering from CSM.
            strResult = strResult.replace('\r\n', ' ');
            strResult = strResult.replace('\n', ' ');
            strResult = strResult.replace('\r', ' ');
            strResult = strResult.replaceAll('<div style="border:none;border-top:solid #B5C4DF 1.0pt;padding:3.0pt 0cm 0cm 0cm"(.*)', '</div></body></html>');
            strResult = strResult.replaceAll('<table class="ql-table-blob" style="border-bottom-width: thin; border-bottom-style: solid; height: 2px; width: 100%;"><tbody><tr><th><\\/th><\\/tr><\\/tbody><\\/table>(.*)', '</body></html>');
            strResult = strResult.replaceAll('<p class="MsoNormal" style="margin-bottom:12.0pt"><b><span style="font-size:12.0pt;color:black">From: <\\/span><\\/b><span style="font-size:12.0pt;color:black">(.*)', '</div></body></html>');
            
            //We remove the rest.
            strResult = strResult.replace('<style type="text/css" style="display:none;"> P {margin-top:0;margin-bottom:0;} </style>', '');
            strResult = strResult.replaceAll('<title.*?>.*?</title>', '');
            strResult = '<pre>' + strResult + '</pre>';

            //If not proper format, we restore the original comment to avoid data loss.
            if(strResult.endsWith('&quot;/&gt;')) {
                strResult = strBody;
            }
        }
        return strResult;
    }

    /*
     Method Name : generateInlineFilesAndAttachments
     Description : This method generates the files from inline images and attachments, and updates the body and original record.
     Parameters  : Object, called from generateInlineFilesAndAttachments, objEmailMessage Email message.
                   Object, called from generateInlineFilesAndAttachments, objPlanComment Plan comment.
                   Object, called from generateInlineFilesAndAttachments, objEmail Original email.
     Return Type : Boolean
     */
    private Boolean generateInlineFilesAndAttachments(EmailMessage objEmailMessage, Plan_Comment__c objPlanComment, Messaging.inboundEmail objEmail) {
        Boolean boolInlineAttachments = false;
        Integer intCounter = 0;
        String strBody;
        String strInlineAttachmentCid;
        Attachment objAttachment;
        ContentVersion objContentVersion;
        ContentDocumentLink objContentDocumentLink;
        Set<Id> setContentVersionIds = new Set<Id>();
        List<ContentDocumentLink> lstContentDocumentLinks = new List<ContentDocumentLink>();
        Map<String, ContentVersion> mapFiles = new Map< String, ContentVersion>();
        Map<String, Attachment> mapAttachments = new Map< String, Attachment>();

        //First we extract the body.
        if(objPlanComment != null && String.isNotBlank(objPlanComment.Comment__c)) {
            strBody = objPlanComment.Comment__c;
        } else if(objEmailMessage != null && String.isNotBlank(objEmailMessage.HtmlBody)) {
            strBody = objEmailMessage.HtmlBody;
        }

        //Now we make sure we have binary attachments.
        if(objEmail.textAttachments != null && !objEmail.textAttachments.isEmpty()) {
            boolInlineAttachments = true; //<T01>
            //Now we check each attachment.
            for(Messaging.Inboundemail.TextAttachment objRecord : objEmail.textAttachments) {
                intCounter++;
                objContentVersion = new ContentVersion();
                objContentVersion.ContentLocation = 'S';
                objContentVersion.PathOnClient = objRecord.fileName;
                objContentVersion.Title = objRecord.fileName;
                objContentVersion.VersionData = Blob.valueOf(objRecord.body);
                mapFiles.put(String.valueOf(intCounter), objContentVersion);
            }
        }

        //Now we check text attachments.
        if(objEmail.binaryAttachments != null && !objEmail.binaryAttachments.isEmpty()) {

            //Now we check each attachment.
            for(Messaging.Inboundemail.BinaryAttachment objRecord : objEmail.binaryAttachments) {

                //First we get the id.
                strInlineAttachmentCid = getImageReference(objRecord.headers);
                 system.debug('strBody>>>>'+strBody);
                 system.debug('strInlineAttachmentCid >>>>'+'src="cid:' + strInlineAttachmentCid + '"');
                //If it is an inline attachment.
                if(String.isNotBlank(strInlineAttachmentCid) && strBody.contains('src="cid:' + strInlineAttachmentCid + '"')) {
                    boolInlineAttachments = true;
                    objAttachment = new Attachment();
                    objAttachment.Body = objRecord.body;
                    objAttachment.Name = objRecord.fileName;
                    if(objEmailMessage != null) {
                        objAttachment.ParentId = objEmailMessage.Id;
                    } else if(objPlanComment != null) {
                        objAttachment.ParentId = objPlanComment.Id;
                    }
                    mapAttachments.put(strInlineAttachmentCid, objAttachment);
                } else {

                    //If it is a normal attachment.
                    boolInlineAttachments = true; //<T01>
                    intCounter++;
                    objContentVersion = new ContentVersion();
                    objContentVersion.ContentLocation = 'S';
                    objContentVersion.PathOnClient = objRecord.fileName;
                    objContentVersion.Title = objRecord.fileName;
                    objContentVersion.VersionData = objRecord.body;
                    mapFiles.put(String.valueOf(intCounter), objContentVersion);
                }
            }
        }

        //If we have Files to create.
        if(!mapFiles.isEmpty()) {
            insert mapFiles.values();

            //Now we create the relationship between the Plan Comment and the Files.
            for(ContentVersion objRecord : mapFiles.values()) {
                setContentVersionIds.add(objRecord.Id);
            }
            for(ContentVersion objRecord : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :setContentVersionIds LIMIT 10000]) {
                objContentDocumentLink = new ContentDocumentLink();
                if(objEmailMessage != null) {
                    objContentDocumentLink.LinkedEntityId = objEmailMessage.Id;
                } else if(objPlanComment != null) {
                    objContentDocumentLink.LinkedEntityId = objPlanComment.Id;
                }
                objContentDocumentLink.ContentDocumentId = objRecord.ContentDocumentId;
                objContentDocumentLink.shareType = 'V';
                lstContentDocumentLinks.add(objContentDocumentLink);
            }
            if(!lstContentDocumentLinks.isEmpty()) {
                insert lstContentDocumentLinks;
            }
        }

        //If we have attachments to create.
        if(!mapAttachments.isEmpty()) {
            insert mapAttachments.values();

            //Now we replace the CID in Plan Comment.
            replaceCIDWithAttachmentId(objEmailMessage, objPlanComment, mapAttachments);
        }
        return boolInlineAttachments;
    }

    /*
     Method Name : getImageReference
     Description : This method extracts the CID of an inline image.
     Parameters  : Object, called from getImageReference, lstHeaders String body.
     Return Type : String
     */
    private String getImageReference(List<Messaging.InboundEmail.Header> lstHeaders) {
        String strId;
        for(Messaging.InboundEmail.Header objHeader : lstHeaders) {
            if(String.isNotBlank(objHeader.value) && (objHeader.name.startsWith('Content-ID') || objHeader.name.startsWith('X-Attachment-Id') || objHeader.value.startsWith('ii') || 
                    objHeader.value.startsWith('< image'))) {
                strId = objHeader.value;
                if(strId.startsWith('<')) {
                    strId = strId.removeStart('<');
                }
                if(strId.endsWith('>')) {
                    strId = strId.removeEnd('>');
                }
                break;
            }
        }
        return strId;
    }

    /*
     Method Name : replaceCIDWithAttachmentId
     Description : This method converts CIDs in Attachments.
     Parameters  : Object, called from replaceCIDWithAttachmentId, objEmailMessage Email Message.
                   Object, called from replaceCIDWithAttachmentId, objPlanComment Plan Comment.
                   Map, called from replaceCIDWithAttachmentId, mapAttachments Attachments.
     Return Type : None
     */
    public static void replaceCIDWithAttachmentId(EmailMessage objEmailMessage, Plan_Comment__c objPlanComment, Map<String, Attachment> mapAttachments) {
        String strBody;
        String strCID;
        Matcher objMatcher;

        //First, we make sure we received data.
        if(objPlanComment != null && String.isNotBlank(objPlanComment.Comment__c)) {
            strBody = objPlanComment.Comment__c;
        } else if(objEmailMessage != null && String.isNotBlank(objEmailMessage.HtmlBody)) {
            strBody = objEmailMessage.HtmlBody;
        }

        //If there's a body to analyze.
        if(String.isNotBlank(strBody)) {
            
            //We create the RegEx.
            objMatcher = Pattern.compile('(src="(cid:.*?)")').matcher(strBody);
    
            //Now we find all the occurrences and replace them with the record value.
            while(objMatcher.find()) {
    
                //First we convert the image to blob.
                strCID = objMatcher.group().removeStart('src="cid:').removeEnd('"');
                if(mapAttachments.get(strCID) != null) {
                    strBody = strBody.replace('cid:' + strCID, '/servlet/servlet.FileDownload?file=' + mapAttachments.get(strCID).Id);
                }
            }

            //Now we assign it back to the corresponding record.
            if(objPlanComment != null && String.isNotBlank(objPlanComment.Comment__c)) {
                objPlanComment.Comment__c = strBody;
            } else if(objEmailMessage != null && String.isNotBlank(objEmailMessage.HtmlBody)) {
                objEmailMessage.HtmlBody = strBody;
            }
        }
    }
}