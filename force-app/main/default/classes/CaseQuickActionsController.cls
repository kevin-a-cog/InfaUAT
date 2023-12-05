/*
 Change History
 ****************************************************************************************************************
 Modified By			Date			Jira No.		Description										    Tag
 ****************************************************************************************************************
 N/A		            N/A     		Utopia			Initial version.								    N/A
 Vignesh Divakaran		3/22/2023		I2RT-7749		Cancel zoom meeting when AAE case is cancelled.	    T01
 Vignesh Divakaran		9/20/2023		I2RT-9063		Replaced standard with custom object Service		T02
 														Appointment.
 */

public class CaseQuickActionsController {
    @AuraEnabled
    public static string getEmailBody(String caseId,String templateName/*, String folderName*/){
        Set<String> overrideFolderforLanguages = new Set<String>{'Dutch','Chinese','Korean'};
        Boolean Operations = false;
        String folderName = '';
        Set<String> folderset = new Set<String>();
        try {
            Case currentCase = [SELECT Id,ContactId,Contact.INFA_Language__c,Record_Type_Name__c FROM Case WHERE Id =: caseId Limit 1];
            folderName = currentCase?.Contact?.INFA_Language__c;
            if(currentCase.Record_Type_Name__c == 'Operations'){
                    Operations = true;
            }
            if(!string.isEmpty(folderName)){
                
                /*if(currentCase != null && currentCase.ContactId != null && currentCase.Contact.INFA_Language__c != null && currentCase.Contact.INFA_Language__c != folderName){
                    Contact updateContactLanguage = new Contact();
                    updateContactLanguage.Id = currentCase.ContactId;
                    updateContactLanguage.INFA_Language__c = folderName;
                    Update updateContactLanguage;
                }*/
                
                integer indexOfSpace = folderName.indexOf(' ');
                if(indexOfSpace != -1)
                folderName = folderName.substring(0, indexOfSpace);
            } else {
                folderName = 'English';
            }
            if(overrideFolderforLanguages.contains(folderName)){
                folderName = 'English';
            }
            folderName = 'Case QuickText Templates '+folderName;
            folderset.add(folderName);
            if(Operations){
                folderName = 'Case QuickText Templates Operations';
                folderset.add(folderName);
            }
            
            system.debug('templateName= '+templateName);
            system.debug('folderName= '+folderName);
            List<EmailTemplate> emailTemplates = New List<EmailTemplate>();
            String emailBody = '';
            
            system.debug('folderName= '+folderName);
            
            emailTemplates = [SELECT ID,HtmlValue FROM EmailTemplate WHERE Name =: templateName AND Folder.Name IN: folderset];
            if(!emailTemplates.isEmpty()){
                /*
                Messaging.SingleEmailMessage[] previewEmails = new Messaging.SingleEmailMessage[]{};
                Messaging.SingleEmailMessage mailToSent = new Messaging.SingleEmailMessage();
                mailToSent.setUseSignature(false);
                mailToSent.setSaveAsActivity(false);
                mailToSent.setTemplateId(emailTemplates[0].Id);
                mailToSent.setTargetObjectId([SELECT Id FROM Contact WHERE Email != null LIMIT 1].Id);
                mailToSent.setWhatId(caseId);
                previewEmails.add(mailToSent);
                Savepoint sp = Database.setSavepoint();
                Messaging.sendEmail(previewEmails);
                Database.rollback(sp);
                emailBody = mailToSent.getHTMLBody();
                */

                String userTimeZoneName;

                if(String.isNotEmpty(currentCase?.ContactId)){
                    String timeZoneId = [Select Id,TimeZone_Lookup__c from Contact where Id =: currentCase.ContactId]?.TimeZone_Lookup__c;
                    for(TimeZone__c timezone : [Select Id,Name,TimeZoneSidKey__c from TimeZone__c where Id =: timeZoneId]){
                        userTimeZoneName = timezone?.TimeZoneSidKey__c;
                    }
                    if(String.isEmpty(userTimeZoneName)){
                        userTimeZoneName = [Select Id,TimeZoneSidKey from User where Id =: UserInfo.getUserId()]?.TimeZoneSidKey;
                    }
                }
                else{
                    userTimeZoneName = [Select Id,TimeZoneSidKey from User where Id =: UserInfo.getUserId()]?.TimeZoneSidKey;
                }

                emailBody = renderTemplate(currentCase.Id, emailTemplates[0].HtmlValue, userTimeZoneName, 'dd-MMMMM-yyyy hh:mm a z');

            }
            system.debug('emailBody= '+emailBody);
            return emailBody;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string createCaseCommentRecord(String caseId, String caseComment, String actionType){
        try {
            system.debug('@caseId- '+caseId);
            system.debug('@caseComment- '+caseComment);
            Case_Comment__c newCaseComment = new Case_Comment__c();
            newCaseComment.Comment__c = caseComment;
            newCaseComment.Case__c = caseId;
            newCaseComment.Visibility__c = 'External';          //Amarender - Changed to External from Internal as part of I2RT-3379
            switch on actionType {
                when 'Decline Solution' {
                    newCaseComment.Inbound__c = true;
                    newCaseComment.Status__c = 'Submitted';
                }
                when else {
                    newCaseComment.Inbound__c = false;
                    newCaseComment.Status__c = 'Submitted';
                }
            }
            Insert newCaseComment;
            return newCaseComment.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean checkopenjiras(String caseId){
        Boolean returnval = false;
        try {
            for(zsfjira__ZIssue_Case__c zic : [select id,zsfjira__ZIssueId__r.zsfjira__Status__c from  zsfjira__ZIssue_Case__c where zsfjira__CaseId__c = :caseId and zsfjira__ZIssueId__r.zsfjira__Status__c  != 'Closed']){
                returnval = true;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());            
        }
        return returnval;
    }

    @AuraEnabled
    public static void updateCaseStatus(String caseId, string status, string caseCommentNotes){
      // @piyush        
        system.debug('caseCommentNotes---> ' + caseCommentNotes);
        
        case oCase = [Select Id,Service_Appointment__c,Status From Case where Id = :caseId]; //<T02>
        oCase.status = status;
        Update oCase; 

        if(status == 'Cancelled'){
            //---------------------------------------<T01>-----------------------------
            Id eventId = [SELECT Id FROM Event WHERE IsChild = false AND WhatId =: oCase.Id AND Cancel_Allowed__c = true LIMIT 1]?.Id;
            if(eventId != null){
                GCSCancelZoomMeetingController.getMeetingCanceledInFuture(eventId);
            }
                List<Service_Appointment__c> lstServiceAppointments = [Select Id From Service_Appointment__c WHERE Id =: oCase.Service_Appointment__c LIMIT 1]; //<T02>
                if(!lstServiceAppointments.isEmpty()){
                    delete lstServiceAppointments;
                }
            //---------------------------------------</T01>-----------------------------      
        }

        Case_Comment__c newCaseComment = new Case_Comment__c();
        newCaseComment.Comment__c = caseCommentNotes;
        newCaseComment.Case__c = caseId;
        newCaseComment.Visibility__c = 'External';         
        newCaseComment.Inbound__c = false;
        newCaseComment.Status__c = 'Submitted';
        Insert newCaseComment;
        
    }

    //Vignesh D: Method to render lightning email template
    public static String renderTemplate(Id recordId, String templateContent, String timeZoneName, String formattedDateTime){
        Set<String> mergeFields = new Set<String>();
        Map<String, String> fieldNames = new Map<String, String>();
        String queryFields;

        Schema.SObjectType sobjectType = recordId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        Map<String, Schema.SObjectField> fieldsMap = fields(sobjectType);
        
        //get merge fields from the template
        String mergeFieldPattern = '\\{\\{\\{.+?\\}\\}\\}';
        Pattern p = Pattern.compile(mergeFieldPattern);
        Matcher m = p.matcher(templateContent);
        while(m.find()){
            mergeFields.add(m.group(0));
        }

        if(mergeFields.size() > 0){
            //get fieldNames from mergeFields
            for(String mergeField : mergeFields){
                String prefix = '{{{'+sobjectName+'.';
                String suffix = '}}}';
                String fieldName = mergeField;
                fieldName = fieldName.replace(prefix, '');
                fieldName = fieldName.replace(suffix, '');
                fieldNames.put(mergeField, fieldName);
                System.debug('FieldName: '+fieldName);
            }

            queryFields = String.join(fieldNames.values(), ',');
            String query = 
                'Select ' + queryFields + 
                ' from ' + sobjectName + 
                ' where Id = :recordId';

                System.debug('Debug : '+query);
            sObject sobj = Database.query(query);

            for(String mergeField : mergeFields){
                String fieldName = fieldNames.get(mergeField);

                if(sobj.get(fieldName) != null){
                    if(fieldsMap.get(fieldName).getDescribe().getType() == Schema.DisplayType.DateTime){
                        DateTime dt = DateTime.valueOf(sobj.get(fieldName));
                        String formattedDT = dt.format(formattedDateTime, timeZoneName);
                        templateContent = templateContent.replace(mergeField, formattedDT);
                    }
                    else{
                        templateContent = templateContent.replace(mergeField, String.valueOf(sobj.get(fieldName)));
                    }
                }
                else{
                    templateContent = templateContent.replace(mergeField, '');
                }

            }
        }

        return templateContent;
    }

    private static Map<String, Schema.SObjectField> fields(Schema.sObjectType t) {
        Set<String> result = new Set<String>();
        Map<String, Schema.SObjectField> fields = t.getDescribe().fields.getMap();
        return fields;
    }
}