/*
Class             : SendGridINEmailService
@Author:          : Prashanth Bhat   
@Created Date     : 09-08-2023  
@Description      : SendGridINEmailService class for sending emails.
@Test Coverage by : INSendGridControllerTest
Change History
**********************************************************************************************************************
ModifiedBy           Date        Jira No.        Description                                                  Tag 
**********************************************************************************************************************
Prashanth Bhat       09-08-2023  I2RT-9050       SendGrid Callout Wrapper changed to SendGridINWrapper        N/A      

*/
public class SendGridINEmailService {
    public static final String ENDPOINT = 'https://api.sendgrid.com/v3/mail/send';
    public SendGridINEmailService() {
        
    }
    
    public static void sendemail(String templateid, List<SendGridINWrapper.Personalizations> personationsList, SendGridINWrapper.EmailIdWrapper fromEmailIdWrapperRecord,SendGridINWrapper.EmailIdWrapper replyToEmailIdWrapperRecord,SendGridINWrapper.Mail_settings mailSetting, SendGridINWrapper.Tracking_settings trackingSettings, SendGridINWrapper.Header headersRecord){
        sendemail(templateid, personationsList, fromEmailIdWrapperRecord, replyToEmailIdWrapperRecord, mailSetting, trackingSettings, headersRecord, null);
    }
    
    /* 
    * 
    Method Name : sendemail
    Description : This method sends the email to community Followers using the SendGrid service when a discussion is created/updated.
    Parameters	: SendGrid Wrapper class Instance
    Return Type : None
    */
    public static void sendemail(String templateid, List<SendGridINWrapper.Personalizations> personationsList, SendGridINWrapper.EmailIdWrapper fromEmailIdWrapperRecord,
                                 SendGridINWrapper.EmailIdWrapper replyToEmailIdWrapperRecord,SendGridINWrapper.Mail_settings mailSetting, SendGridINWrapper.Tracking_settings trackingSettings, 
                                 SendGridINWrapper.Header headersRecord, List<SendGridINWrapper.FileObject> lstAttachments){
                                     try{
                                         SendGridINWrapper.SendGridRequestWrapper mainWrapper = new SendGridINWrapper.SendGridRequestWrapper();
                                         mainWrapper.personalizations = personationsList;
                                         mainWrapper.from_z = fromEmailIdWrapperRecord;
                                         mainWrapper.reply_to = replyToEmailIdWrapperRecord;         
                                         mainWrapper.mail_settings = mailSetting;
                                         //mainWrapper.content = contentList;
                                         mainWrapper.tracking_settings = trackingSettings;
                                         mainWrapper.headers = headersRecord;        
                                         //If template is designed in SendGrid we can pass template id and merge fields information
                                         mainWrapper.template_id = templateid; //GCSSITUser   
                                         if(lstAttachments != null && !lstAttachments.isEmpty()) {
                                             mainWrapper.attachments = lstAttachments;
                                         }
                                         
                                         
                                         string strRequestBody = JSON.serialize(mainWrapper);
                                          
                                         strRequestBody = strRequestBody.replace('from_z', 'from');
                                         system.debug('request body'+strRequestBody);
                                         
                                         HttpRequest request = new HttpRequest();
                                         request.setMethod('POST');
                                         request.setEndpoint(ENDPOINT);
                                         request.setTimeout(120000);
                                         request.setHeader('Content-Type', 'application/json');
                                         
                                         
                                         //String authorizationHeader = 'Bearer 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';
                                         String authorizationHeader = Label.SendgridAPIKey;       
                                         request.setHeader('Authorization', authorizationHeader);
                                         
                                         if(String.isNotBlank(strRequestBody)){
                                             request.setBody(strRequestBody);
                                         }
                                         
                                         System.debug('request===' + request);
                                         System.debug('strRequestBody===' + strRequestBody);
                                         
                                         HttpResponse httpResponse = new Http().send(request); 
                                         System.debug('httpResponse===' + httpResponse);
                                         System.debug('httpResponse Status===' + httpResponse.getStatus());
                                         System.debug('httpResponse Status Code===' + httpResponse.getStatusCode());
                                         System.debug('httpResponse  Body===' + httpResponse.getBody());
                                     }
                                     catch(Exception exp){
                                         System.debug('Error occured in SendGridINEmailService.sendemail :'+exp.getMessage());
                                     }
                                 }                        
    
}