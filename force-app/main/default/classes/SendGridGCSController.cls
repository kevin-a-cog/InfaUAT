/*
Class:          SendGridGCSController
@Author:        Venky K
@Created Date:  1-Feb-2021
@Description:   SendGridGCSController class for GCS Usecases to send Sendgrid api for sending emails.

    Change History
*************************************************************************************************************************************
 ModifiedBy     Date        Requested By        Description                                                     Tag
************************************************************************************************************************************
 balajip        01/08/2022  I2RT-6765           To separate the Primary Contact names in the Intial Response
                                                 with a space character                                         T01
 balajip        22/08/2022  I2RT-6867           new JSON attribute added to the request that tells 
                                                 if the link to esupport portal to be shown                     T02
*/
public class SendGridGCSController {

    public static final String FROMSIT = 'supportqa@informatica.com';
    public static final String FROMUAT = 'supportuat@informatica.com';
    public static final String FROMPROD = 'support@informatica.com';
    public static final String FROMNAME = 'Informatica Support';

    
        
    //public static void configureEmail(String casenum, String conname, Boolean priority, String ccomentid, Map<String,String> emaillist, String usecase) {
        @Future(callout=true)
    public static void configureEmail(String sgparams) {
        List<SendGridWrapper.FileObject> lstAttachments;
        Map<String, List<SendGridWrapper.FileObject>> mapAttachments;

        SendGridrequestwrapper sgrr = (SendGridrequestwrapper)JSON.deserialize(sgparams, SendGridrequestwrapper.class); 
        
        String templateid = ' ';
        Boolean issandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;

        List<SendGridWrapper.EmailIdWrapper> toEmailIdWrapperList = new List<SendGridWrapper.EmailIdWrapper>();
        if(sgrr.emaillist != null && sgrr.emaillist.size() > 0){
            for(String emailid: sgrr.emaillist.keyset()){                
                SendGridWrapper.EmailIdWrapper toEmailIdWrapperRecord = new SendGridWrapper.EmailIdWrapper();
                toEmailIdWrapperRecord.email = emailid;
                toEmailIdWrapperRecord.name = sgrr.emaillist.get(emailid).replace('\'', '&#39;');
                toEmailIdWrapperList.add(toEmailIdWrapperRecord);
            }
        }
        
        SendGridWrapper.EmailIdWrapper fromEmailIdWrapperRecord = new SendGridWrapper.EmailIdWrapper();
        SendGridWrapper.EmailIdWrapper replyToEmailIdWrapperRecord = new SendGridWrapper.EmailIdWrapper();
        String orgname = URL.getSalesforceBaseUrl().toExternalForm();

        if(issandbox){
            if(orgname.contains('infa--uat')){
                fromEmailIdWrapperRecord.email = FROMUAT;
                replyToEmailIdWrapperRecord.email = FROMUAT;
            } else {
                fromEmailIdWrapperRecord.email = FROMSIT;
                replyToEmailIdWrapperRecord.email = FROMSIT;
            }            
        } else {
           fromEmailIdWrapperRecord.email = FROMPROD;
           replyToEmailIdWrapperRecord.email = FROMPROD;
           //fromEmailIdWrapperRecord.email = FROMSIT;
           //replyToEmailIdWrapperRecord.email = FROMSIT;
        }
        

        fromEmailIdWrapperRecord.name = FROMNAME;        
        replyToEmailIdWrapperRecord.name = FROMNAME;
        

        //Set Template parameters. These will vary by template  
        
        List<SendGridWrapper.Personalizations> personationsList = new List<SendGridWrapper.Personalizations>();
        SendGridWrapper.Personalizations personalizationsRecord = new SendGridWrapper.Personalizations();        
        personalizationsRecord.to = toEmailIdWrapperList;    

        //EmailTemplate em = [SELECT Body, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'GeneralResponse'];
        //system.debug(em.Subject);
        //String ret = SalesforceUtils.mergeText(em.Subject, sgrr.ccomentid).get(sgrr.ccomentid);
        //system.debug(ret);
        //personalizationsRecord.subject = ret;
        
        //This is needed if we build template in SendGrid. We can pass the merge fields as attribute like below
              
       
                         
            

        SendGridWrapper.Dynamictemplate dt = new SendGridWrapper.Dynamictemplate();        
        dt.name = sgrr.conname.replace('\'', '&#39;');
        dt.casetype = 'Case';
        dt.casenumber = sgrr.casenum;
        Case_Comment__c cc = [Select Id,Case__r.Subject,Case__r.Priority,Case__r.Forecast_Product__c,Comment__c,Createdby.CommunityNickname,CreatedbyId,Createdby.Name from Case_Comment__c where Id = :sgrr.ccomentid];
        
        /* List<Id> integrationids = new List<Id>();
        Boolean isintegration = false;
        for(Service_Cloud_General_Setting__mdt sc : [Select Id,Integration_Users__c from Service_Cloud_General_Setting__mdt where DeveloperName= 'Integration_Users' LIMIT 1])    {
            integrationids = sc.Integration_Users__c.split(';');
        }
        
        for(Id idval : integrationids){
            if(cc.CreatedbyId == idval) {isintegration = true;break;}
        }*/
        
        if(cc.createdby.name.toLowercase().contains('integration') || cc.createdby.name.toLowercase().contains('deployment')){
            dt.EngineerName = 'Informatica Support';
        } else { 
            dt.EngineerName = cc.Createdby.CommunityNickname; 
        }
        dt.todaydate = system.today();        
        dt.subject = cc.Case__r.subject.replace('\'', '&#39;');          
        system.debug('subject:'+dt.subject);
        dt.priority = cc.Case__r.Priority;
        dt.product = cc.Case__r.Forecast_Product__c;
        dt.sendersignature = dt.EngineerName;
        mapAttachments = generateDocumentRecords(cc.Comment__c);
        for(String strBody : mapAttachments.keySet()) {
            dt.emailbody = strBody;
            lstAttachments = mapAttachments.get(strBody);
        }
        
        system.debug('body:'+dt.emailbody);
        Case c = [Select Id,Case_Timezone_Name__c,Version__c,Status, AAE_Area_of_expertise__c,RCA_Pending_flag__c,ContactId,GCS_AAE_Session_Time__c, Record_Type_Name__c,Success_Offering__c,Contact_Salutation__c,contact.Name,Support_Account__c,Support_Account__r.Name,Intial_Response_time__c FROM Case where CaseNumber =:sgrr.casenum];
        
        
        if(c.Status == 'Booked') {dt.aaebooked = true;}
        if(c.Status == 'Cancelled') {dt.aaecancelled = true;}
        if(c.Status == 'Scheduled') {dt.aaescheduled = true;} 
        if(c.Status == 'Delivered') {dt.aaedelivered = true;}
        
        if(c.Status == 'New') {dt.isnew = true;}
        if(c.Status == 'Assess') {dt.isassess = true;}
        if(c.Status == 'Research') {dt.isresearch = true;}
        if(c.Status == 'Solution') {dt.issolution = true;dt.showaccept = true;}
        if(c.Status == 'Solution' && c.RCA_Pending_flag__c == 'Yes' && c.Record_Type_Name__c == 'Operations'){dt.showaccept = false;}
        if(c.Status == 'Closed') {dt.isclosed = true;}
        
        dt.responsetime = c.Intial_Response_time__c; 
        dt.successoffering = c.Success_Offering__c;
        dt.version = c.Version__c;
        if(c.Record_Type_Name__c == 'Administrative'){
            dt.showprodversion = false;
        } else{
            dt.showprodversion = true;
        }
        
        dt.esupporturl = Label.eSupport;
        //T02 - to not show the link to eSupport portal for Lite cases.
        dt.isCaseLite = false;
        if(c.Record_Type_Name__c == 'Case Lite'){
            dt.isCaseLite = true;
        }
        dt.viewcaseurl = Label.eSupport + '/casedetails?caseId=' + c.Id;
        //dt.viewcaseurl = EncodingUtil.urlEncode(Label.eSupport + '/casedetails?caseId=' + c.Id,'UTF-8');     //  Encoding it to handle redirection from Okta to IN to eSupport  I2RT-I2RT-4639   
        dt.acceptsolution = Label.eSupport +'/casedetails?caseId='+ c.Id+ '&fromemail=accept';
        dt.declinesolution = Label.eSupport +'/casedetails?caseId='+  c.Id+ '&fromemail=decline';
        dt.needmoretime = Label.eSupport +'/casedetails?caseId='+  c.Id+ '&fromemail=moretime';
        dt.timezone = c.Case_Timezone_Name__c;
        if(!String.isBlank(c.Contact_Salutation__c ))
            dt.salutation = c.Contact_Salutation__c;        
        system.debug('need more time'+dt.needmoretime);
        if(c.ContactId != null)
            dt.primaryname = c.Contact.Name.replace('\'', '&#39;');
        
        
        
        SendGrid_Templates__mdt stmdt = [Select Id,Template_Id__c,DeveloperName from SendGrid_Templates__mdt where Domain__c = 'Service Cloud' and Use_Case__c = :sgrr.usecase];
        templateid = stmdt.Template_Id__c;

        if(sgrr.usecase == 'GCS Initial Response' || sgrr.usecase == 'GCS Initial Response AAE'){            
            AccountContactRelation acr = new AccountContactRelation();
            for(AccountContactRelation acrelation: [Select Id,ContactId,Contact.Name from AccountContactRelation where AccountId = :c.Support_Account__c and Primary__c = true]){
                if(string.isblank(dt.primaryconname)){
                    dt.primaryconname = acrelation.Contact.Name.replace('\'', '&#39;'); 
                } else{
                    dt.primaryconname = dt.primaryconname + ', '; //T01
                    dt.primaryconname =  dt.primaryconname + acrelation.Contact.Name.replace('\'', '&#39;'); 
                }
            }                    
            if(c != null && c.Support_Account__c != null)
                dt.accname = c.Support_Account__r.Name;               
        }    
        
        if(c.Record_Type_Name__c == 'Ask An Expert'){
                dt.sessiondetails = c.GCS_AAE_Session_Time__c;
                dt.productarea = c.AAE_Area_of_expertise__c;
                dt.isaae = true;
                dt.casetype = 'Ask An Expert Session';
                /*for(Case_Contact__c casecon: [Select Id,Contact__r.Name,Contact__c from Case_Contact__c where Case__c = :c.Id]){
                    if(casecon.Contact__c != c.ContactId && !string.isblank(casecon.Contact__c)){
                        if(String.isblank(dt.alternatecontacts)){
                            dt.alternatecontacts  = casecon.Contact__r.Name;
                        }else {
                            dt.alternatecontacts  = dt.alternatecontacts  + ',' + casecon.Contact__r.Name;
                        }
                    }
                }*/
                            
            }
        

        personalizationsRecord.dynamic_template_data = dt;

        SendGridWrapper.Uniqueargs cav = new SendGridWrapper.Uniqueargs();
        cav.ccid = sgrr.ccomentid;
        personalizationsRecord.custom_args = cav;        
        personationsList.add(personalizationsRecord);
        
        
        //Setting sandbox mode by default it is set to false. Sendgrid will not send emails for sandbox mode
        SendGridWrapper.Mail_settings mailSetting = new SendGridWrapper.Mail_settings();
        SendGridWrapper.Enable_Mode sandBoxMode = new SendGridWrapper.Enable_Mode();
        sandBoxMode.enable = false;
        mailSetting.sandbox_mode = sandBoxMode;
        
        //Set click tracking to true to capture the clicks
        SendGridWrapper.Tracking_settings trackingSettings = new SendGridWrapper.Tracking_settings();
        SendGridWrapper.Enable_Mode trackingMode = new SendGridWrapper.Enable_Mode();
        trackingMode.enable = true;
        trackingSettings.click_tracking = trackingMode;
        
        //To set priority of the email
        SendGridWrapper.Header headersRecord = new SendGridWrapper.Header();
        if(sgrr.priority){
            headersRecord.priority = 'Urgent';
            headersRecord.importance = 'High';
        }

            
        
        /*List<SendGridWrapper.Content> contentList = new List<SendGridWrapper.Content>();
        SendGridWrapper.Content contentRecord = new SendGridWrapper.Content();
        
        contentRecord.type = 'text/html';
        //contentRecord.value = '<h1>Hello Send Grid!!</h1> <p>This is my first email.</p>';
        contentRecord.value = CaseCommentController.fetchMergedQuickText('GeneralResponse',sgrr.ccomentid);
        contentList.add(contentRecord);
        SendGridEmailService.sendemail(personationsList,fromEmailIdWrapperRecord,replyToEmailIdWrapperRecord,mailSetting,trackingSettings,headersRecord,contentList);*/

        //SendGridEmailService.sendemail(templateid,personationsList,fromEmailIdWrapperRecord,replyToEmailIdWrapperRecord,mailSetting,trackingSettings,headersRecord);

        //Now we send the email including attachments, if any.
        SendGridEmailService.sendemail(templateid,personationsList,fromEmailIdWrapperRecord,replyToEmailIdWrapperRecord,mailSetting,trackingSettings,headersRecord, lstAttachments);    
    }

    public class SendGridrequestwrapper{
        public String casenum;
        public String conname;      
        public Boolean priority;       
        public String ccomentid;
        public Map<String,String> emaillist;
        public String usecase;
    }

    /*
     Method Name : generateDocumentRecords
     Description : This method converts local images into attachments.
     Parameters  : String, called from generateDocumentRecords, strData Data that contains the links to be replaced.
     Return Type : Map<String, List<SendGridWrapper.FileObject>>
     */
    public static Map<String, List<SendGridWrapper.FileObject>> generateDocumentRecords(String strData) {
        Integer intCounter = 0;
        String strResult = strData;
        String strOldURL;
        Matcher objMatcher;
        PageReference objPageReference;
        SendGridWrapper.FileObject objFile;
        List<SendGridWrapper.FileObject> lstAttachments = new List<SendGridWrapper.FileObject>(); 
        Map<String, List<SendGridWrapper.FileObject>> mapAttachments = new Map<String, List<SendGridWrapper.FileObject>>();

        //First, we make sure we received data.
        if(String.isNotBlank(strResult)) {
            
            //We create the RegEx.
            objMatcher = Pattern.compile('(src="(.*?servlet\\/rtaImage.*?)")').matcher(strResult);

            //Now we find all the occurrences and replace them with the record value.
            while(objMatcher.find()) {

                //First we convert the image to blob.
                strOldURL = objMatcher.group().removeStart('src="').removeEnd('"');
                objPageReference = new PageReference(strOldURL.replace('&amp;', '&'));

                //Now we prepare the attachment.
                objFile = new SendGridWrapper.FileObject();
                objFile.filename = 'image' + intCounter + '.jpg';
                objFile.content = EncodingUtil.base64Encode(objPageReference.getContent());
                objFile.type = 'image/jpeg';
                objFile.content_id = 'image' + intCounter;
                objFile.disposition = 'inline';
                lstAttachments.add(objFile);
                intCounter++; 

                //Now we replace the URL.
                strResult = strResult.replace(strOldURL, 'cid:' + objFile.content_id);
            }
        }

        //Now we force the image to 600px.
        strResult = strResult.replace('<img ', '<img style="width:400px !important;" ');

        //Now we return the final data.
        mapAttachments.put(strResult, lstAttachments);
        return mapAttachments;
    }
}