/*
@created by       : balajip
@created on       : 10/06/2021
@Purpose          : Controller for NotificationSubscription LWC
@Testclass        : NotificationSubscriptionControllerTest
@JIRA             :
Change History
****************************************************************************************************
ModifiedBy      Date        Jira No.    Tag     Description
****************************************************************************************************
balajip         05/24/2022  I2RT-6268   T01     Added feature to be able to configure Queue or Related Users for notification
Vignesh D       07/28/2022  I2RT-6864   T02     SOQL injection fixed
Narpavi Prabu   25/08/2022  AR-2892     T03     Added feature for refer the plan team in notiifcation field criteria
cgowda          08/08/2022  PAYGIT-2    T04     Added feature to be able to configure the notifcations to be sent to Platform
nibansal        07/03/2023  SALESRT-14945       Added feature(Opportunity Team Member) to be able to configure the notifcations to be sent to Platform 
Isha B          26/07/2023  I2RT-8234    T06    Fix for Infinite spinner for RO users - added new fields & value population in the FieldInfo wrapper 
*/
public class NotificationSubscriptionController {
    public static Map<String, Notification_Criteria_Object__mdt> mapObjectNameToSettings = new Map<String, Notification_Criteria_Object__mdt>();
    static{
        /**T04 - Added field Allow_Notify_Platform__c*/
        List<Notification_Criteria_Object__mdt> lstObjectSetting = [Select Id, MasterLabel, DeveloperName, Object_API_Name__c, Template_Name__c, Template_Folder_Name__c, Extension_Class_Name__c, Applicable_Apps__c,Allow_Notify_Platform__c
                                                                    From Notification_Criteria_Object__mdt];
        for(Notification_Criteria_Object__mdt objectSetting : lstObjectSetting){
            mapObjectNameToSettings.put(objectSetting.Object_API_Name__c, objectSetting);
        }
    }
    /**Get the list of email tempates **/
    @AuraEnabled
    public static List<String> getTemplates(String objName){
        List<String> lstTemplateOption = new List<String>();
        String templateFolderName = '';
        Notification_Criteria_Object__mdt objectSetting = mapObjectNameToSettings.get(objName);
        if(mapObjectNameToSettings.containsKey(objName)){
            templateFolderName = mapObjectNameToSettings.get(objName).Template_Folder_Name__c;
        }
        if(String.isNotEmpty(templateFolderName)){
            List<EmailTemplate> lstTemplate = [Select Id, Name, DeveloperName From EmailTemplate
                                               Where Folder.DeveloperName = :templateFolderName and IsActive=true];
            for(EmailTemplate emailTemplate : lstTemplate){
                lstTemplateOption.add(emailTemplate.Name + ':' + emailTemplate.DeveloperName);
            }
        }
        return lstTemplateOption;
    }
    @AuraEnabled
    public static Notification.Message getTemplatePreview(String templateName, String objectAPIName){
        Notification.Message message = new Notification.Message();
        try {
            String soql = 'Select Id From ' + String.escapeSingleQuotes(objectAPIName) + ' Order By CreatedDate Desc Limit 1'; //<T02>
            List<SObject> lstRecord = Database.query(soql);
            List<EmailTemplate> lstEmailTemplate = new List<EmailTemplate>();
            lstEmailTemplate = [Select Id, Subject, Body, HtmlValue From EmailTemplate Where DeveloperName = :templateName and IsActive=true];
            if(!lstEmailTemplate.isEmpty() && !lstRecord.isEmpty()) {
                String recordId = lstRecord.get(0).Id;
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(lstEmailTemplate.get(0).Id, null, recordId);
                message.title = mail.getSubject();
                message.bodyText = mail.getPlainTextBody();
                message.bodyHTML = mail.getHtmlBody();
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('message html = ' + message.bodyHTML);
        return message;
    }
    @AuraEnabled
    public static wrapperClass getfilterCriteriaFields(String objName){
        try {
            wrapperClass wrp = new wrapperClass();
            Map<String, Notification_Criteria_Field__mdt> mapFieldNameToFieldDetail = new Map<String, Notification_Criteria_Field__mdt>();
            Map<String, String> fieldAPIDatatypeMap = new Map<String, String>();
            List<Notification_Criteria_Field__mdt> lstCriteriaField = Notification_Criteria_Field__mdt.getAll().values();
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(objName).getDescribe().fields.getMap();
            for(Notification_Criteria_Field__mdt criteriaField : lstCriteriaField){
                if(criteriaField.Object_Name__c == objName){
                    mapFieldNameToFieldDetail.put(criteriaField.Field_API_Name__c, criteriaField);
                    if(fieldMap.containsKey((criteriaField.Field_API_Name__c).toLowercase())){
                        fieldAPIDatatypeMap.put(criteriaField.Field_API_Name__c,String.valueOf(fieldMap.get(criteriaField.Field_API_Name__c).getDescribe().getType()));
                    }
                    else if(criteriaField.Field_API_Name__c.contains('.')){
                        List<String> tempStrList = new List<String>();
                        tempStrList = criteriaField.Field_API_Name__c.split('\\.');
                        String relatedFieldAPIName;
                        String targetField = tempStrList[1];
                        system.debug('targetField-->'+targetField);
                        //<T04>
                        if(!criteriaField.Is_Child__c)
                        {
                            System.debug('tempStrList >> '+ tempStrList);
                            if(tempStrList[0].contains('__r')){
                                relatedFieldAPIName = tempStrList[0].replace('__r','__c');
                            }else{
                                relatedFieldAPIName = tempStrList[0] +'Id';
                            }
                            System.debug('relatedFieldAPIName >> '+ relatedFieldAPIName);
                            System.debug('targetField >> '+ targetField);
                            /** Get the Parent object Name **/
                            Schema.DescribeFieldResult fieldResult = schemaMap.get(objName).getDescribe().fields.getMap().get(relatedFieldAPIName).getDescribe();
                            String parentObjectName = fieldResult.getReferenceTo()[0].getDescribe().getName();
                            System.debug('parentObjectName >> '+ parentObjectName);
                            fieldAPIDatatypeMap.put(criteriaField.Field_API_Name__c,String.valueOf(schemaMap.get(parentObjectName).getDescribe().fields.getMap().get(targetField).getDescribe().getType()));
                        }
                        //<T04> - Condition to check the child object
                        else if(criteriaField.Is_Child__c)
                        {
                            String childobjectAPIName;
                            if(tempStrList[0].contains('__r')){
                                childobjectAPIName = tempStrList[0].replace('__r','__c');
                                relatedFieldAPIName= tempStrList[1];
                            }
                            Schema.DescribeFieldResult fieldResult = schemaMap.get(childobjectAPIName).getDescribe().fields.getMap().get(relatedFieldAPIName).getDescribe();
                            String parentObjectName = fieldResult.getReferenceTo()[0].getDescribe().getName();
                            System.debug('parentObjectName >> '+ parentObjectName);
                            fieldAPIDatatypeMap.put(criteriaField.Field_API_Name__c,String.valueOf(schemaMap.get(parentObjectName).getDescribe().fields.getMap().get(targetField).getDescribe().getType()));
                        }
                        //</T04>
                    }else{
                        fieldAPIDatatypeMap.put(criteriaField.Field_API_Name__c,'STRING');
                    }
                }
            }
            wrp.filterCriteriaMap.putAll(mapFieldNameToFieldDetail);
            wrp.fieldAPIDatatypeMap.putAll(fieldAPIDatatypeMap);
            wrp.fieldLabelList = mapFieldNameToFieldDetail.values();
            return wrp;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<FieldInfo> getFieldInfo(String objName){
        try {
            List<FieldInfo> lstFieldInfo = new List<FieldInfo>();
            List<Notification_Criteria_Field__mdt> lstCriteriaField = Notification_Criteria_Field__mdt.getAll().values();
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(objName).getDescribe().fields.getMap();
            //lookupRefObjectName
            for(Notification_Criteria_Field__mdt criteriaField : lstCriteriaField){
                if(criteriaField.Object_Name__c == objName){
                    String datatype = '';
                    String referredFieldAPIName = criteriaField.Field_API_Name__c;
                    String referredObjectName = objName;
                    String lookupRefObjectName=''; //T06
                    String lookupFields='';//T06
                    if(fieldMap.containsKey((criteriaField.Field_API_Name__c).toLowercase())){
                        if(String.isNotEmpty(criteriaField.Reference__c)){
                            if('User'.equalsIgnoreCase(criteriaField.Reference__c)){
                                datatype = 'REFERENCE';
                                referredFieldAPIName = 'User__c';
                                referredObjectName = 'Notification_User__c';
                                lookupRefObjectName='User'; //T06
                               // lookupFields='Name,Alias'; //T06
                            }
                        }else{
                            datatype = String.valueOf(fieldMap.get(criteriaField.Field_API_Name__c).getDescribe().getType());
                            lookupRefObjectName=getLookupRefObjectName(datatype, referredFieldAPIName ,fieldMap); //T06                           
                        }
                    }
                    else if(criteriaField.Field_API_Name__c.contains('.')){
                        List<String> apiNameParts = criteriaField.Field_API_Name__c.split('\\.');
                        System.debug('apiNameParts >> '+ apiNameParts);
                        String actualFieldAPIName;
                        String apinameofobject;
                        if(!criteriaField.Is_Child__c)
                        {
                            if(apiNameParts[0].contains('__r')){
                                actualFieldAPIName = apiNameParts[0].replace('__r','__c');
                            }else{
                                actualFieldAPIName = apiNameParts[0] +'Id';
                            }
                            System.debug('actualFieldAPIName >> '+ actualFieldAPIName);
                            /** Get the Parent object Name **/
                            Schema.DescribeFieldResult fieldResult = schemaMap.get(objName).getDescribe().fields.getMap().get(actualFieldAPIName).getDescribe();
                            //System.debug('fieldResult >> ' + fieldResult);
                            //System.debug('fieldResult.getReferenceTo()[0].getDescribe() >> ' + fieldResult.getReferenceTo()[0].getDescribe());
                            //System.debug('fieldResult.getReferenceTo()[1].getDescribe() >> ' + fieldResult.getReferenceTo()[1].getDescribe());
                            referredObjectName = fieldResult.getReferenceTo()[0].getDescribe().getName();
                            System.debug('referredObjectName >> '+ referredObjectName);
                            referredFieldAPIName = apiNameParts[1];
                            System.debug('referredFieldAPIName >> '+ referredFieldAPIName);
                            Map<String, Schema.SObjectField> parentObjSchemaMap = schemaMap.get(referredObjectName).getDescribe().fields.getMap();
                            datatype = String.valueOf(parentObjSchemaMap.get(referredFieldAPIName)?.getDescribe().getType());
                            lookupRefObjectName= getLookupRefObjectName(datatype, referredFieldAPIName ,parentObjSchemaMap); //T06
                        }
                        //<T04> - Added logic for child object
                        else if(criteriaField.Is_Child__c)
                        {
                            if(apiNameParts[0].contains('__r'))
                            {
                                apinameofobject = apiNameParts[0].replace('__r','__c');
                                actualFieldAPIName= apiNameParts[1];
                                if(actualFieldAPIName.contains('User__c'))
                                {
                                    if(criteriaField.Reference__c == 'Queue'){
                                        datatype = 'PICKLIST';
                                        lookupRefObjectName=''; //T06
                                    }else{
                                        referredFieldAPIName = 'User__c';
                                        referredObjectName = 'Notification_User__c';
                                        datatype = String.valueOf(schemaMap.get(referredObjectName).getDescribe().fields.getMap().get(referredFieldAPIName).getDescribe().getType());
                                        lookupRefObjectName='User';//T06
                                        
                                    }
                                }else{
                                    System.debug('apinameofobject Name >> '+ apinameofobject);
                                    System.debug('actualFieldAPIName >> '+ actualFieldAPIName);
                                    datatype = String.valueOf(schemaMap.get(apinameofobject).getDescribe().fields.getMap().get(actualFieldAPIName).getDescribe().getType());
                                    lookupRefObjectName=getLookupRefObjectName(datatype, actualFieldAPIName ,fieldMap); //T06
                                    system.debug('Data Type for child field -->'+ datatype);
                                }
                            }
                        }
                        //</T04>
                    }else{
                        datatype = 'STRING';
                        lookupRefObjectName=''; //T06
                    }
                    if(referredFieldAPIName.contains('RecordTypeId')){
                        datatype = 'PICKLIST';
                        lookupRefObjectName=''; //T06
                    }
                    if(referredFieldAPIName.contains('OwnerId')){
                        if(criteriaField.Reference__c == 'Queue'){
                            datatype = 'PICKLIST';
                            lookupRefObjectName='';//T06
                        }else{
                            referredFieldAPIName = 'User__c';
                            referredObjectName = 'Notification_User__c';
                            lookupRefObjectName='User';//T06
                        }
                    }
                    FieldInfo fieldInfo = new FieldInfo();
                    fieldInfo.apiName = criteriaField.Field_API_Name__c;
                    fieldInfo.label = criteriaField.Field_Label__c;
                    fieldInfo.datatype = datatype;
                    fieldInfo.referredFieldAPIName = referredFieldAPIName;
                    fieldInfo.referredObjectName = referredObjectName;
                    fieldInfo.sortOrder = Integer.valueOf(criteriaField.Sort_Order__c);
                    fieldInfo.isActive = criteriaField.Is_Active__c;
                    //Added for <T04>
                    fieldInfo.isChild = criteriaField.Is_Child__c;
                    fieldInfo.lookupRefObjectName = String.isNotBlank(lookupRefObjectName)?lookupRefObjectName:''; //T06                   
                    fieldInfo.lookupFields=String.isNotEmpty(lookupFields)?lookupFields:(String.isNotEmpty(criteriaField.Lookup_Fields__c)?criteriaField.Lookup_Fields__c:''); //T06
                 
                    
                    //T06
                    lstFieldInfo.add(fieldInfo);                    
                }
            }
            return lstFieldInfo;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**Get the picklist values **/
    @AuraEnabled
    public static Map<String, String> getPicklistValues(String objName ,String fieldName){
        Map<String,String> picklistValMap = new Map<String,String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        List<String> targetFieldsList = getTargetFields(objName,fieldName);
        String targetObjectName = targetFieldsList[0];
        String targetFieldName 	= targetFieldsList[1];
        Schema.DescribeFieldResult targetResult = schemaMap.get(targetObjectName).getDescribe().fields.getMap().get(targetFieldName).getDescribe();
        List<Schema.PicklistEntry> sPicklistEntry = targetResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : sPicklistEntry){
            picklistValMap.put(pickListVal.getLabel(),pickListVal.getValue());
        }
        System.debug('picklistValMap >> '+ picklistValMap);
        return picklistValMap;
    }
    /** Get Target Object and Fields **/
    @AuraEnabled
    public static List<String> getTargetFields(String objName, string fieldName){
        List<String> targetFieldList = new List<String>();
        String targetObjectName;
        String targetFieldName;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        List<Notification_Criteria_Field__mdt> lstCriteriaField = Notification_Criteria_Field__mdt.getAll().values();
        for(Notification_Criteria_Field__mdt criteriafields: lstCriteriaField)
        {
            if(criteriafields.Field_API_Name__c == fieldName)
            {
                if( fieldName.contains('.'))
                {
                    system.debug('Fieldname-->'+ fieldName);
                    List<String> tempStrList = new List<String>();
                    tempStrList = fieldName.split('\\.');
                    System.debug('tempStrList-->'+tempStrList);
                    String relatedFieldAPIName;
                    String targetField;
                    String relatedobjectAPIName;
                    if(!criteriafields.Is_Child__c)
                    {
                        targetField = tempStrList[1];
                        System.debug('criteriafields Is_Child__c false--> '+criteriafields.Is_Child__c);
                        if(tempStrList[0].contains('__r')){
                            relatedFieldAPIName = tempStrList[0].replace('__r','__c');
                        }else{
                            relatedFieldAPIName = tempStrList[0] +'Id';
                        }
                        /** Get the Parent object Name **/
                        Schema.DescribeFieldResult fieldResult = schemaMap.get(objName).getDescribe().fields.getMap().get(relatedFieldAPIName).getDescribe();
                        String parentObjectName = fieldResult.getReferenceTo()[0].getDescribe().getName();
                        System.debug('parentObjectName >> '+ parentObjectName);
                        targetObjectName = parentObjectName;
                        targetFieldName = tempStrList[1];
                    }
                    //<T04> - Included get the field Info
                    if(criteriafields.Is_Child__c)
                    {
                        System.debug('criteriafields Is_Child__c true--> '+criteriafields.Is_Child__c);
                        if(tempStrList[0].contains('__r'))
                        {
                            relatedobjectAPIName = tempStrList[0].replace('__r','__c');
                            relatedFieldAPIName =  tempStrList[1];
                        }
                        targetObjectName = relatedobjectAPIName;
                        targetFieldName = tempStrList[1];
                    }
                    //<T04>
                } else{
                    targetObjectName = objName;
                    targetFieldName = fieldName;
                }
            }
        }
        System.debug('targetObjectName >> '+ targetObjectName);
        System.debug('targetFieldName >> '+ targetFieldName);
        targetFieldList.add(targetObjectName);
        targetFieldList.add(targetFieldName);
        return targetFieldList;
    }
    /** To get the Record Types **/
    @AuraEnabled
    public static Map<String, String> getRecordTypes(String objectAPIName){
        Map<String, String> mapRecordTypeIdToName = new Map<String, String>();
        List<RecordType> lstRecordType = [Select Id, Name, DeveloperName, SobjectType, IsActive
                                          From RecordType
                                          Where SobjectType = :objectAPIName
                                          Order By Name];
        for(RecordType recordType : lstRecordType){
            mapRecordTypeIdToName.put(recordType.Name, recordType.Id);
        }
        return mapRecordTypeIdToName;
    }
    /** To get the QueueNames if the field is OwnerID **/
    @AuraEnabled
    public static Map<String, String> getQueueNames(String objectAPIName, String fieldAPIName){
        List<String> targetFieldInfo = getTargetFields(objectAPIName, fieldAPIName);
        String targetObjectName = targetFieldInfo[0];
        String targetFieldName 	= targetFieldInfo[1];
        Map<String, String> mapQueueIdToName = new Map<String, String>();
        List<QueueSobject> lstQueue = [SELECT Id, QueueId, Queue.Name, SobjectType
                                       FROM QueueSobject WHERE SobjectType = :targetObjectName
                                       Order By Queue.Name];
        for(QueueSobject queue : lstQueue){
            mapQueueIdToName.put(queue.Queue.Name, queue.QueueId);
        }
        return mapQueueIdToName;
    }
    /** To get the User details **/
    @AuraEnabled
    public static User getUserData(Id userId){
        User usr = [Select Id, Phone, Email From User Where Id = :userId];
        return usr;
    }
    /** To Save the records **/
    @AuraEnabled
    public static List<String> saveNotificationCriteria(Notification_Criteria__c criteria, string userList, string detailList,boolean isEdit){
        List<String> lstRecordIdToRefresh = new List<Id>();
        List<Notification_Criteria_Detail__c> notificationDetailList = (List<Notification_Criteria_Detail__c>)JSON.deserialize(detailList,List<Notification_Criteria_Detail__c>.class);
        List<Notification_User__c> notificationUserList = (List<Notification_User__c>)JSON.deserialize(userList,List<Notification_User__c>.class);
        System.debug('criteria = ' + JSON.serialize(criteria));
        System.debug('notificationUserList = ' + notificationUserList);
        upsert criteria;
        lstRecordIdToRefresh.add(criteria.Id);
        if(criteria.Id != null || criteria.Id !=''){
            List<Notification_Criteria_Detail__c> lExistingnotifDetails = [Select Id from Notification_Criteria_Detail__c where Notification_Criteria__c =:criteria.Id];
            List<Notification_User__c> lExistingnotifUsers = [Select Id from Notification_User__c where Notification_Criteria__c =:criteria.Id];
            if(lExistingnotifDetails.size()>0){
                delete lExistingnotifDetails;
                for(Notification_Criteria_Detail__c criteriaDetail : lExistingnotifDetails){
                    lstRecordIdToRefresh.add(criteriaDetail.Id);
                }
            }
            if(lExistingnotifUsers.size()>0){
                delete lExistingnotifUsers;
                for(Notification_User__c criteriaUser : lExistingnotifUsers){
                    lstRecordIdToRefresh.add(criteriaUser.Id);
                }
            }
        }
        //Create criteria details
        for(Notification_Criteria_Detail__c detail : notificationDetailList){
            detail.Notification_Criteria__c = criteria.Id;
        }
        //Create Notification Users
        for(Notification_User__c nUser :notificationUserList){
            nUser.Notification_Criteria__c = criteria.Id;
        }
        if(notificationDetailList.size()>0){
            for(Notification_Criteria_Detail__c criteriaDetail : notificationDetailList){
                if(criteriaDetail.Field_Data_Type__c == 'REFERENCE'){
                    String recordName = '';
                    String recordId = criteriaDetail.Value__c;
                    String objectAPIName = findObjectNameFromRecordIdPrefix(recordId);
                    String soql = 'Select Name From ' + objectAPIName + ' Where Id = :recordId';
                    List<sObject> lstSObject = Database.query(soql);
                    if(!lstSObject.isEmpty()){
                        recordName = (String)lstSObject.get(0).get('Name');
                    }
                    criteriaDetail.Lookup_Record_Name__c = recordName;
                }
            }
            insert notificationDetailList;
            for(Notification_Criteria_Detail__c criteriaDetail : notificationDetailList){
                lstRecordIdToRefresh.add(criteriaDetail.Id);
            }
        }
        if(notificationUserList.size()>0){
            insert notificationUserList;
            for(Notification_User__c criteriaUser : notificationUserList){
                lstRecordIdToRefresh.add(criteriaUser.Id);
            }
        }
        return lstRecordIdToRefresh;
    }
    public static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix){
        String objectName = '';
        try{
            //Get prefix from record ID
            //This assumes that you have passed at least 3 characters
            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);
            //Get schema information
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe();
            //Loop through all the sObject types returned by Schema
            for(Schema.SObjectType stype : gd.values()){
                //if (!sObj.contains('__')) to exclude managed package objects
                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                System.debug('Prefix is ' + prefix);
                //Check if the prefix matches with requested prefix
                if(prefix!=null && prefix.equals(myIdPrefix)){
                    objectName = r.getName();
                    System.debug('Object Name! ' + objectName);
                    break;
                }
            }
        }catch(Exception e){
            System.debug(e);
        }
        return objectName;
    }
    /** get the related records from criteria ID **/
    @AuraEnabled
    public static List<String> getObjectNames(){
        String currentAppName = '';
        List<UserAppInfo> lstUserAppInfo = [Select Id, AppDefinitionId
                                            From UserAppInfo Where UserId=:UserInfo.getUserId()];
        if(!lstUserAppInfo.isEmpty()){
            List<AppDefinition> lstAppDefinition = [Select Label, DeveloperName From AppDefinition
                                                    Where DurableId = :lstUserAppInfo.get(0).AppDefinitionId];
            if(!lstAppDefinition.isEmpty()){
                currentAppName = lstAppDefinition.get(0).DeveloperName;
            }
        }
        List<String> lstOption = new List<String>();
        List<String> lstOptionAll = new List<String>();
        for(Notification_Criteria_Object__mdt objectSetting : mapObjectNameToSettings.values()){
            String value = objectSetting.MasterLabel + ':' + objectSetting.Object_API_Name__c;
            lstOptionAll.add(value);
            if(String.isNotEmpty(currentAppName) && objectSetting.Applicable_Apps__c.contains(currentAppName)){
                lstOption.add(value);
            }
        }
        if(lstOption.isEmpty()){
            lstOptionAll.sort();
            return lstOptionAll;
        }
        lstOption.sort();
        return lstOption;
    }
    /** get the related records from criteria ID **/
    @AuraEnabled
    public static criteriaWrapperClass getrelatedRecords(String criteriaId){
        criteriaWrapperClass wrp = new criteriaWrapperClass();
        /**T04 - added new fields, required for platform notification */
        List<Notification_Criteria__c> lstNotificationSubscription = [Select Id, Name, Object__c, MS_Teams_Email__c, SF_Chatter_Post_Email__c, Notification_Type__c, Evaluation_Trigger__c, Custom_Logic__c, Condition__c, Active__c, Template_Name__c,Platform_Notification_Expiration__c FROM Notification_Criteria__c Where Id = :criteriaId];
        List<Notification_Criteria_Detail__c> notificationDetailList = [Select Id,Field_Name__c,Field_API_Name__c,Operator__c,Value__c ,Lookup_Record_Name__c from Notification_Criteria_Detail__c where Notification_Criteria__c =:criteriaId];
        //T01 included fields Queue_Name__c and Related_Fields__c
        List<Notification_User__c> notificationUserList = [Select Id,User__c,User_Type__c,Account_Case_Fields__c,Team_Member_Role__c,Related_Fields__c,User_Email__c,User_Phone__c,Queue_Name__c,Platform_Recipient_Role__c from Notification_User__c where Notification_Criteria__c =:criteriaId];
        wrp.notificationSubscription = lstNotificationSubscription.get(0);
        wrp.notificationDetailList = notificationDetailList;
        wrp.notificationUserList = notificationUserList;
        return wrp;
    }
    @AuraEnabled
    public static Boolean allowNotificationAPI(String objectAPIName){
        return mapObjectNameToSettings.get(objectAPIName).Allow_Notify_Platform__c;
    }
    /**Get the list of Account/Case Fields**/
    @AuraEnabled
    public static List<String> getAccountCaseFields(String objName){
        List<String> accountCaseFields = new List<String>();
        String accountField = '';
        String caseField = '';
        String teamRoles ='';
        String accTeamRoles ='';
        String ptRoles='';
        String relatedFields = ''; //T01
        String queues=''; //T01
        String oppTeamRoles='';
        String oppFields='';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        System.debug('getacfields'+objName);
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(objName).getDescribe().fields.getMap();
        for(Schema.SobjectField field : fieldMap.values()){
            if(field.getDescribe().getType() == Schema.DisplayType.REFERENCE){
                for(Schema.SObjectType sObj : field.getDescribe().getReferenceTo()){
                    if(String.valueOf(sObj) == 'Account'){
                        accountField += String.valueOf(field.getDescribe().getName()) +',';
                    }else if(String.valueOf(sObj) == 'Case'){
                        caseField += String.valueOf(field.getDescribe().getName()) +',';
                    }else if(String.valueOf(sObj) == 'Opportunity'){
                        oppFields += String.valueOf(field.getDescribe().getName()) +',';
                    }
                }
            }
        }
        List<Schema.PicklistEntry> lpicklistValues = AccountTeamMember.TeamMemberRole.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry  : lpicklistValues){
            accTeamRoles += entry.getValue() + ',';
        }
        for(CaseTeamRole role : [Select Id, Name from CaseTeamRole]){
            teamRoles += role.Name + ',';
        }
        List<Schema.PicklistEntry> lpicklistValuesPT = Plan_Team__c.Role__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry  : lpicklistValuesPT){
            ptRoles += entry.getValue() + ',';
        }
        //T01 - get the list of Related Fields for the given object
        List<Notification_Recipient_Field__mdt> lstRecipientField = Notification_Recipient_Field__mdt.getAll().values();
        for(Notification_Recipient_Field__mdt recipientField : lstRecipientField){
            if(recipientField.Object_Name__c == objName && recipientField.Is_Active__c){
                relatedFields += recipientField.Field_Label__c + '-' + recipientField.Field_API_Name__c +',';
            }
        }
        //T01 - get the list of Queues for the given object.
        List<QueueSobject> lstQueue = [SELECT Id, QueueId, Queue.Name, SobjectType
                                       FROM QueueSobject WHERE SobjectType = :objName
                                       Order By Queue.Name];
        for(QueueSobject que : lstQueue){
            queues += que.Queue.Name + '-' + que.QueueId +',';
        }

        List<Schema.PicklistEntry> oppPicklistValues = OpportunityTeamMember.TeamMemberRole.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry entry  : oppPicklistValues){
            oppTeamRoles += entry.getValue() + ',';
        }

        accountField = accountField.removeEnd(',');
        caseField = caseField.removeEnd(',');
        accTeamRoles = accTeamRoles.removeEnd(',');
        teamRoles = teamRoles.removeEnd(',');
        ptRoles = ptRoles.removeEnd(',');
        relatedFields = relatedFields.removeEnd(','); //T01
        queues = queues.removeEnd(','); //T01
        oppFields = oppFields.removeEnd(',');
        oppTeamRoles = oppTeamRoles.removeEnd(',');
        System.debug('accountField >> '+ accountField);
        System.debug('caseField >> '+ caseField);
        System.debug('accTeamRoles >> '+ accTeamRoles);
        System.debug('teamRoles >> '+ teamRoles);
        System.debug('relatedFields >> '+ relatedFields); //T01
        System.debug('queues >> '+ queues); //T01
        accountCaseFields.add(accountField);
        accountCaseFields.add(accTeamRoles);
        accountCaseFields.add(teamRoles);
        accountCaseFields.add(ptRoles);
        accountCaseFields.add(relatedFields); //T01
        accountCaseFields.add(queues); //T01
        accountCaseFields.add(oppTeamRoles); 
        accountCaseFields.add(oppFields); 
        return accountCaseFields;
    }
    
    private static string getLookupRefObjectName(String datatype,String fieldapi , Map<String, Schema.SObjectField> fieldMap){ //T06    
        String lookupObjectName;    
        try{
            if(datatype=='REFERENCE'){
                lookupObjectName=  fieldMap.get(fieldapi)?.getDescribe()?.getReferenceTo()[0]?.getDescribe()?.getName();
             }
        }catch(Exception e){
            lookupObjectName='';
        }
        return lookupObjectName;
    }

   
    /** Criteria wrapper class **/
    public class criteriaWrapperClass{
        @AuraEnabled
        public Notification_Criteria__c notificationSubscription {get; set;}
        @AuraEnabled
        public List<Notification_Criteria_Detail__c> notificationDetailList {get; set;}
        @AuraEnabled
        public List<Notification_User__c> notificationUserList {get; set;}
        public criteriaWrapperClass(){
            notificationDetailList = new List<Notification_Criteria_Detail__c>();
            notificationUserList = new List<Notification_User__c>();
        }
    }
    public class FieldInfo{
        @AuraEnabled
        public String apiName {get; set;}
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String datatype {get; set;}
        @AuraEnabled
        public String referredObjectName {get; set;}
        @AuraEnabled
        public String referredFieldAPIName {get; set;}
        @AuraEnabled
        public Integer sortOrder {get; set;}
        @AuraEnabled
        public Boolean isActive {get; set;}
        //Added for <T04>
        @AuraEnabled
        public Boolean isChild {get; set;}
        @AuraEnabled
        public String lookupRefObjectName {get; set;} //T06
        @AuraEnabled
        public String lookupFields {get; set;} //T06
        

    }
    /** Wrapper class */
    public class wrapperClass{
        @AuraEnabled
        public Map<String, Notification_Criteria_Field__mdt> filterCriteriaMap {get; set;}
        @AuraEnabled
        public Map<String, String> fieldAPIDatatypeMap {get; set;}
        @AuraEnabled
        public List<Notification_Criteria_Field__mdt> fieldLabelList {get; set;}
        @AuraEnabled
        public Map<String, List<String>> dataTypeOperatorsMap {get; set;}
        public wrapperClass(){
            filterCriteriaMap = new Map<String, Notification_Criteria_Field__mdt>();
            fieldAPIDatatypeMap = new Map<String, String>();
            fieldLabelList = new List<Notification_Criteria_Field__mdt>();
            dataTypeOperatorsMap = new Map<String, List<String>>();
        }
    }
}