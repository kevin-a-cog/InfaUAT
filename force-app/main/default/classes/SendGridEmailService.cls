/*
Class:          SendGridEmailService
@Author:        Venky K
@Created Date:  1-Feb-2021
@Description:   SendGridEmailService class for sending emails.

Change History
****************************************************************************************************
ModifiedBy     Date        Jira No.    Tag     Description
****************************************************************************************************
balajip        01/28/2022  I2RT-5011   T01     added logic to remove the extra backslash character in the request body

*/

public class SendGridEmailService {

    public static final String ENDPOINT = 'https://api.sendgrid.com/v3/mail/send';
    public SendGridEmailService() {

    }

	public static void sendemail(String templateid, List<SendGridWrapper.Personalizations> personationsList, SendGridWrapper.EmailIdWrapper fromEmailIdWrapperRecord,SendGridWrapper.EmailIdWrapper replyToEmailIdWrapperRecord,SendGridWrapper.Mail_settings mailSetting, SendGridWrapper.Tracking_settings trackingSettings, SendGridWrapper.Header headersRecord){
		sendemail(templateid, personationsList, fromEmailIdWrapperRecord, replyToEmailIdWrapperRecord, mailSetting, trackingSettings, headersRecord, null);
	}
    
    public static void sendemail(String templateid, List<SendGridWrapper.Personalizations> personationsList, SendGridWrapper.EmailIdWrapper fromEmailIdWrapperRecord,
			SendGridWrapper.EmailIdWrapper replyToEmailIdWrapperRecord,SendGridWrapper.Mail_settings mailSetting, SendGridWrapper.Tracking_settings trackingSettings, 
			SendGridWrapper.Header headersRecord, List<SendGridWrapper.FileObject> lstAttachments){
        SendGridWrapper.SendGridRequestWrapper mainWrapper = new SendGridWrapper.SendGridRequestWrapper();
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
        
        string strRequestBody = String.escapeSingleQuotes(JSON.serialize(mainWrapper));
        system.debug('request body'+strRequestBody);
        strRequestBody = strRequestBody.replace('\\"','\"'); 
        //T01 - to remove the extra backslash character
        strRequestBody = strRequestBody.replace('\\\\','\\'); 
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
}