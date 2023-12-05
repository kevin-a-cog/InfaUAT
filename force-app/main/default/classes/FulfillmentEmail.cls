/*
@created by       : Harshita J
@created on       : 10/28/2022
@Purpose          : EmailMessage Trigger.
@Testclass        : FulfillMentEmailTest
@JIRA             : 
@Tag              : T01
 
*/

global  without sharing class  FulfillmentEmail implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
           globalApexManager GAM = new globalApexManager();
           Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
           EmailMessage emailMessage = new EmailMessage();
           String strHTMLBody = email.htmlBody;
            String  myPlainText;
           if(email.plainTextBody!=null){
               myPlainText = email.plainTextBody;
           }
           else{
              myPlainText = strHTMLBody.stripHtmlTags(); 
           }
           Integer firstindex = myPlainText.indexOfIgnoreCase('Ref{'); 
           Integer lastindex = myPlainText.indexOfIgnoreCase('}',firstindex+3);
           String refid =  myPlainText.substring(firstindex,lastindex+1);
           
            list<Fulfillment__c> fullfillment =  [select id,Thread_Id__c,Owner.Email from Fulfillment__c where Thread_Id__c = :refid];
            
            emailMessage.FromAddress = email.fromAddress;        
            emailMessage.HtmlBody = strHTMLBody;
            emailMessage.TextBody = email.plainTextBody;
            emailMessage.Incoming = true;
            emailMessage.Subject = email.subject;
            emailMessage.MessageDate=System.now();
            emailMessage.Status = '1';
            
            if(email.toAddresses!=null && email.toAddresses.size()>0){
                emailMessage.toAddress = email.toAddresses[0];
                for(Integer i=1; i< email.toAddresses.size(); i++){        
                    emailMessage.toAddress = emailMessage.toAddress + ';' + email.toAddresses[i];
                }
            }
             if(email.ccAddresses!=null && email.ccAddresses.size()>0){
                emailMessage.CcAddress=  email.ccAddresses[0];
                for(Integer i=1; i< email.ccAddresses.size(); i++)
                { 
                    emailMessage.CcAddress = emailMessage.CcAddress + ';' + email.ccAddresses[i];
                }
            }
            if(fullfillment!=null && fullfillment.size()>0){
             emailMessage.RelatedToId= fullfillment[0].Id;
            }
            if(email.fromAddress!=null && email.fromAddress!=''){
             emailMessage.FromName = email.fromAddress;
            }
             emailMessage.Last_Modified_Date__c=datetime.now();
             try{
                insert emailMessage;

                //insert attachments
                List<Attachment> lstAttachments = new List<Attachment>();
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

                for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
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

                Set<Id> emailsWithAttachments=new Set<Id>();
                if(!lstAttachments.isEmpty()){
                    database.SaveResult[] myResult=database.insert(lstAttachments,false);

                    //update email message
                    emailMessage.Has_Attachments__c=true;
                    update emailMessage;

                }

            }catch(Exception e){
               GAM.CreateExceptionRecords('FulfillmentEmail.handleInboundEmail() -> ' + e.getCause(),e.getmessage(), fullfillment[0].Id);
            }
          return result;
      }

}