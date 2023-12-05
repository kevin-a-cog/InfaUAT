public with sharing class csmPlanQuickActionController {

    @AuraEnabled
    public static string getEmailBody(String strPlanId,String templateName){
        List<EmailTemplate> emailTemplates = New List<EmailTemplate>();
            String emailBody = '';
        emailTemplates = [SELECT ID,HtmlValue FROM EmailTemplate WHERE Name =: templateName];
        if(!emailTemplates.isEmpty()){
            String  userTimeZoneName = [Select Id,TimeZoneSidKey from User where Id =: UserInfo.getUserId()].TimeZoneSidKey;
            emailBody = renderTemplate(strPlanId, emailTemplates[0].HtmlValue, userTimeZoneName, 'dd-MMMMM-yyyy hh:mm a z');
        }
        return emailBody;    
    }
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
                if(fieldsMap.get(fieldName)!=null && fieldsMap.get(fieldName).getDescribe().getType() == Schema.DisplayType.Reference) {
                    if(fieldName.endsWith('__c')) {
                        fieldName = fieldName.replace('__c', '__r.Name');
                    } else {
                        fieldName = fieldName.replaceAll('(Id)(?!.*\\1)', '.Name');
                    }
                }
                fieldNames.put(mergeField, fieldName);
            }
                queryFields = String.join(fieldNames.values(), ',');
                String query = 
                    'Select ' + queryFields + 
                    ' from ' + sobjectName + 
                    ' where Id = :recordId';
                sObject sobj = Database.query(query);
    
                for(String mergeField : mergeFields){
                    String fieldName = fieldNames.get(mergeField);
    
                if(fieldName.contains('.')) {
                    templateContent = templateContent.replace(mergeField, extractFieldValues(sobj,fieldName));
                }else if(sobj.get(fieldName) != null){
                        if(fieldsMap.get(fieldName).getDescribe().getType() == Schema.DisplayType.DateTime){
                            DateTime dt = DateTime.valueOf(sobj.get(fieldName));
                            String formattedDT = dt.format(formattedDateTime, timeZoneName);
                            templateContent = templateContent.replace(mergeField, formattedDT);
                        }
                        else{
                            templateContent = templateContent.replace(mergeField, String.valueOf(sobj.get(fieldName)));
                        }
                }else{
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

    public static string extractFieldValues(sObject sb, string fieldAPIName){
        string fvalue='';
        if(fieldAPIName.contains('.')){
            List<string> splitedFields = fieldAPIName.split('\\.');
            try{
                for(integer i=0;i<splitedFields.size()-1;i++){
                    sb=sb.getSobject(splitedFields[i]);   
                }
                fvalue = string.valueof(sb.get(splitedFields[splitedFields.size()-1]));
            }catch(exception ex){
                system.debug('******exception while fetching fieldValues as relationship '+fieldAPIName+'  value is blank.'+ex.getmessage()); 
                fvalue='';
            }
            
        }else if(sb.get(fieldAPIName)!=null){
            fvalue = string.valueOf(sb.get(fieldAPIName));
        }
        return fvalue;
    }
}