/*
Class:          ScheduleLimitsMonitoringAlerts 
@Author:        Mohammed Anies
@Created Date:  15 July 2020
@Description:   Class to capture details of orglimits and store in org limits history object


Change History
*****************************************************************************************************************************
ModifiedBy          Date        Requested By        Description                                             Tag
******************************************************************************************************************************
Uday Gangula        10/30/2023  Prasanth Sagar      SFPLAT-108; Automate Validation Rules to Clari on Oppty  <T01> (FYI.. This method will hit the 101 Error if there are more than 100 Validation Rules updated at one time)
*/
public class ScheduleLimitsMonitoringAlerts implements Schedulable{
     public static globalApexManager GAM = new globalApexManager();
    
    
/*
* The method reads the data from standard system object OrgLimits and
* stores the value in Org Limits History object
* @param SchedulableContext SC
* @return return-Void
* @throws exception - mail is sent for exception
*/
    
    public void execute(SchedulableContext SC){
        sendOrgLimits();
        sendValidationsModifiedToday(); //<T01>
    }
    
    public static void sendOrgLimits(){
        boolean isSendMail;
        try{
            integer threshold;
            List<Org_Limits_History__c> lstOrgLimitsHistory = new List<Org_Limits_History__c>();
            List<Org_Limits_History__c> lstAlertOrgLimitsHistory = new List<Org_Limits_History__c>();
            
            //get the parameter like threshold and flag for sending email from Limit parameter mdt
            Limit_Monitoring_Parameter__mdt parametersObjectSendMail = [SELECT Label,Parameter_Value__c FROM Limit_Monitoring_Parameter__mdt WHERE DeveloperName = 'Is_Send_Alert_Mail' LIMIT 1];
            if(parametersObjectSendMail != null){
                isSendMail = Boolean.valueOf(parametersObjectSendMail.Parameter_Value__c);
            }
            Limit_Monitoring_Parameter__mdt parametersObject = [SELECT Label,Parameter_Value__c FROM Limit_Monitoring_Parameter__mdt WHERE DeveloperName = 'Threshold_Percentage' LIMIT 1];
            if(parametersObject != null){
                threshold = Integer.valueOf(parametersObject.Parameter_Value__c);
            }
            
            if(Test.isRunningTest()){
                threshold = 1;
            }
            
            //Get all Org_Limits_History__c in last 24 hours which has crossed threshold
            Map<string, Org_Limits_History__c> mapTodayLimits = new Map<string, Org_Limits_History__c>([SELECT ID, Limit_Name__c from Org_Limits_History__c  WHERE CREATEDDATE = TODAY AND Limits_Actual_value__c >:threshold]);
            
            //get limit details from System.OrgLimits Map and insert the values to Org Limits History object.
            //Also identify if the limits have reached the threshold defined in the limits parameter mdt
            Map<String,System.OrgLimit> mapAllLimits = OrgLimits.getMap();
            Datetime recordedDatetime = Datetime.now();
            if(mapAllLimits.size() > 0 && mapAllLimits != null){
                for(String limitName : mapAllLimits.keySet()){
                    Org_Limits_History__c orgLimit = new Org_Limits_History__c();
                    orgLimit.Name = mapAllLimits.get(limitName).getName()+'_'+ recordedDatetime;
                    orgLimit.Limit_Name__c = mapAllLimits.get(limitName).getName();
                    orgLimit.Limit_Max_Value__c = mapAllLimits.get(limitName).getLimit();
                    orgLimit.Limits_Actual_value__c= mapAllLimits.get(limitName).getValue();
                    orgLimit.Limit_Recorded_Time__c = recordedDatetime;
                    
                    lstOrgLimitsHistory.Add(orgLimit);
                    IF(orgLimit.Limit_Max_Value__c > 0){
                        Decimal decimallimitPercentage = (orgLimit.Limits_Actual_value__c / orgLimit.Limit_Max_Value__c)*100 ;
                        Double limitPercentage = decimallimitPercentage.setScale(2);                        
                        if(limitPercentage > (Double)threshold){
                           //Check if limit is not inserted in last 24 hours
                            if(!mapTodayLimits.Containskey(limitName))
                            {
                                lstAlertOrgLimitsHistory.Add(orgLimit);
                            }
                        }
                    }
                }
                if(lstOrgLimitsHistory.size() > 0){
                    insert lstOrgLimitsHistory;
                }
                
                //if any limits have reached the threshold and send mail is set to true. then send email by invoking sendNotificationMail method
                if(lstAlertOrgLimitsHistory.size() > 0){
                    String mailBody = '<html><body>';
                    mailBody +='<b> Following Limits reached the defined threshold of '+ threshold + '%</b><br/><br/>';
                    mailBody = mailBody + '<table border="3">';
                    mailBody = mailBody + '<tr bgcolor="#BFBFBF" border="solid">';
                    mailBody = mailBody + '<td><b><font color="black">Limit Name</font></b></td>';
                    mailBody = mailBody + '<td><b><font color="black">Max Value</font></b></td>';
                    mailBody = mailBody + '<td><b><font color="black">Actual Value</font></b></td>';
                    mailBody = mailBody + '<td><b><font color="black">Usage</font></b></td>'+  '</tr>';
                    for(Org_Limits_History__c alertLimitName : lstAlertOrgLimitsHistory){
                        mailBody = mailBody + '<tr>';
                        mailBody = mailBody + '<td>' + alertLimitName.Limit_Name__c+ '</td>';
                        mailBody = mailBody + '<td>' + alertLimitName.Limit_Max_Value__c+ '</td>';
                        mailBody = mailBody + '<td>' + alertLimitName.Limits_Actual_value__c + '</td>';
                        mailBody = mailBody + '<td>' + ((Decimal)((alertLimitName.Limits_Actual_value__c / alertLimitName.Limit_Max_Value__c)*100)).setScale(2) + '</td>';
                        mailBody = mailBody + '</tr>';
                    }
                    mailBody = mailBody + '</body></html>';
                    if(isSendMail == true){
                        sendNotificationMail('Org Limits Alert',mailBody,false);
                    }     
                }  
            }//end of if limits monitored
        }
        catch(Exception executeException){
            String mailBody = '<html><body>';
            mailBody = mailBody + '<b> Exception:'+ executeException.getMessage() + '</b><br/><br/>';
            mailBody = mailBody + '<b> StackTrace:'+ executeException.getStackTraceString() + '</b><br/><br/>';
            
            mailBody = mailBody + '</body></html>';
            if(isSendMail == true)
                sendNotificationMail('Exception:Org Limits Execution', mailBody,true);
        }
    }
    
    @future(callout=true)
    public static void sendValidationsModifiedToday() //<T01>
    {
        try{
            List<ValidationDetail> validationDetails = new List<ValidationDetail>();
            String baseURL = URL.getSalesforceBaseUrl().toExternalForm();       
            string objects = System.Label.ValidationAlertObjects;
            List<String> splitList = objects.split(',');
            String inCondition = '';
            for(string strRecord : splitList){
                inCondition = inCondition + '\''+ strRecord + '\',';
            }
            inCondition = inCondition.removeEnd(',');
                    
            string strQuery = EncodingUtil.URLENCODE('SELECT Id,EntityDefinition.DeveloperName,ValidationName FROM ValidationRule where EntityDefinition.DeveloperName IN ('+ inCondition + ') and LastModifiedDate = TODAY','UTF-8');                               
            string strFullQuery = System.Label.Validation_Alert_Rest_Call + strQuery;
            String restResult = restGetValidations( baseURL + strFullQuery, 'GET', UserInfo.getSessionId());                
            
            validationRuleJSONFormat objfromJSON = validationRuleJSONFormat.parse(restResult);
            List<validationRuleJSONFormat.ValidationRecordsResult> objRecords = objfromJSON.records;
            if(objRecords.isEmpty()){
                return;
            }
            for(validationRuleJSONFormat.ValidationRecordsResult objValidation: objRecords){            
                string strQueryMetadata = EncodingUtil.URLENCODE('SELECT Id,ValidationName,Metadata FROM ValidationRule where Id = \'' + objValidation.Id + '\' LIMIT 1','UTF-8');        
                
                strFullQuery = System.Label.Validation_Alert_Rest_Call + strQueryMetadata;                              
                
                restResult = restGetValidations( baseURL + strFullQuery, 'GET', UserInfo.getSessionId());   
                
                validationRuleJSONFormat metadataJsonFormat = validationRuleJSONFormat.parse(restResult);               
                
                ValidationDetail objValidationDetail = new ValidationDetail();
                objValidationDetail.Id = objValidation.Id;
                objValidationDetail.ValidationName = objValidation.ValidationName;
                objValidationDetail.description = metadataJsonFormat.records[0].Metadata.description;
                objValidationDetail.errorConditionFormula = metadataJsonFormat.records[0].Metadata.errorConditionFormula;
                objValidationDetail.errorMessage = metadataJsonFormat.records[0].Metadata.errorMessage;
                objValidationDetail.active = metadataJsonFormat.records[0].Metadata.active;
                objValidationDetail.EntityName = objValidation.EntityDefinition.DeveloperName;
                validationDetails.add(objValidationDetail);            
            }         
            
            string header ='EntityName, Id, ValidationName,description,errorMessage,active,errorConditionFormula  \n';
            String finalstr = header;
            for(ValidationDetail obj:validationDetails){
                string strErrorConditionFormula = obj.errorConditionFormula.replace(',', ' &&& ');
                string strValidationDescription = obj.description.replace(',', ' &&& ');
                string strValidationerrorMessage = obj.errorMessage.replace(',', ' &&& ');
                strErrorConditionFormula = strErrorConditionFormula.replace('\r\n', '');
                strErrorConditionFormula = strErrorConditionFormula.replace('\n', '');
                strErrorConditionFormula = strErrorConditionFormula.replace('\r', '');
                strValidationDescription = strValidationDescription.replace('\r\n', '');
                strValidationDescription = strValidationDescription.replace('\n', '');
                strValidationDescription = strValidationDescription.replace('\r', '');
                String Recordstring = obj.EntityName+','+obj.id+','+obj.ValidationName+','+strValidationDescription+','+strValidationerrorMessage+','+obj.active+','+strErrorConditionFormula+'\n';
                finalstr = finalstr+Recordstring;       
            }
            
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();

            blob excel = blob.valueOf(finalstr);                        
            attach.setBody(excel);
            attach.setFileName('Validation Rules.csv');
            attach.setContentType('text/csv');

            string mailSubject = System.label.Validation_Alert_Email_Subject +' '+ date.today().format() +' are '+ objects;
            string mailBody = System.label.Validation_Alert_Email_Body;
            string toEmail = System.Label.Send_Validation_Alert_To_Email;
            string[] toEmailList = toEmail.split(',');
            string ccEmail = System.Label.Send_Validation_Alert_CC_Email;
            string[] ccEmailList = ccEmail.split(',');

            Messaging.singleEmailMessage Emailwithattch = new Messaging.singleEmailMessage();
            Emailwithattch.setSubject(mailSubject);         
            Emailwithattch.setToaddresses(toEmailList);
            Emailwithattch.setCCaddresses(ccEmailList);
            Emailwithattch.setPlainTextBody(mailBody);
            Emailwithattch.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
            
            // Sends the email 
            Messaging.SendEmailResult [] emailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {Emailwithattch});
            
            //system.debug('emailResult : '+ emailResult);
        }catch(exception e){
            GAM.CreateExceptionRecords('ScheduleLimitsMonitoringAlerts', 'Exception in sendValidationsModifiedToday method',e.getMessage());
        }
    }
    
    public static String restGetValidations(String endPoint, String requestMethod, String userSessionId) {
        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setHeader('Authorization', 'Bearer ' + userSessionId);
        httpRequest.setTimeout(120000);
        httpRequest.setEndpoint(endPoint);
        httpRequest.setMethod(requestMethod);
        HttpResponse httpResponse = http.send(httpRequest);
        return httpResponse.getBody();
    }
    
/*
* The method sends mail to the defined recipients in the limit monitoring parameter mdt
* @param subject : email subject
* @param eamilBody : email body - varies depending on the type of mail sent
* @param isException : if true, mail is sent to recipients defined in exception mailing list, if false sent to alert mailing list
* @return return-Void
* @throws exception - mail is sent for exception
*/
    public static void sendNotificationMail(String subject, String emailBody, boolean isException){
        try{
            string notificationMaillist = '';
            if(isException){
                Limit_Monitoring_Parameter__mdt parametersObject = [SELECT Label,Parameter_Value__c FROM Limit_Monitoring_Parameter__mdt WHERE DeveloperName = 'Exception_Mailing_List' LIMIT 1];
                if(parametersObject != null){
                    notificationMaillist = parametersObject.Parameter_Value__c;    
                }
            }
            else{
                Limit_Monitoring_Parameter__mdt parametersObject = [SELECT Label,Parameter_Value__c FROM Limit_Monitoring_Parameter__mdt WHERE DeveloperName = 'Alert_Mailing_List' LIMIT 1];
                if(parametersObject != null){
                    notificationMaillist = parametersObject.Parameter_Value__c;    
                }
            }
            List<String> mailingList = notificationMaillist.split(',');
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSenderDisplayName('Salesforce Admin');
            mail.setSubject(subject);
            mail.setHtmlBody(emailBody);
            
            List<String> sendTo = new List<String>(); 
            for(String mailId : mailingList ){
                sendTo.add(mailId);    
            }
            mail.setToAddresses(sendTo);
            mails.add(mail);
            Messaging.sendEmail(mails);
            return;
        }
        Catch(Exception emailSend){
            return;
        }
    }//end of notification mail    
}