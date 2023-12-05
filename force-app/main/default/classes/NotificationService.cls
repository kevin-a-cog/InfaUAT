/*
    @created by       : balajip
    @created on       : 03/02/2020
    @Purpose          : contains the methods that defines the domain logic pertaining to Notifications
    @Testclass        : 
    @JIRA             : 
    
Change History
****************************************************************************************************
ModifiedBy      Date        Jira No.    Tag     Description
****************************************************************************************************
balajip         03/09/2022  I2RT-5624   T01     To use the values from Trigger Context for checking 
                                                    if the criteria is satisfied instead of the values fetched afresh
balajip         07/11/2022  I2RT-6637   T02     Added option to be able to specify a list of 
                                                    Notification Subscription record Ids to be processed 
Narpavi Prabu   26/8/2022   AR-2892     T03    Added feature to include the criteria of plan team
cgowda          08/08/2022  PAYGIT-2    T04    Added feature to be able to configure the notifcations to be sent to Platform
Narpavi Prabu   15/9/2022   AR-2924     T05    Include the notification rule Id in the channel sent to User 
                                               Fixed the Plan Team Notification to all CSP Objects 
Narpavi Prabu   22/12/2022  AR-3008     T06    Include the condition to send  notification only for primary CSM and CSM Manager 
                                               role is selected in Plan Team
Nishant         07/03/2023 SALESRT-14945       Included the logic for Opportunity Team Member
Nishant         19/06/2023 SALESRT-13388       To uncheck the checkbox on contract after notification is sent
Isha B          21/06/2023  I2RT-8498    T07       Fixed case team logic 
Isha B          05/07/2023  I2RT-8616    T08    Populated the notification userIds in this class  to be used in the NotificationPowerAutomate Class.
                                                Removed redundant piece of code 
                                                
Isha B           10/07/2023  I2RT-8616   T09     opportunity team handling in NotificationService class and removed redundant piece of code
Isha B           12/07/2023  I2RT-8616   T10     Resolved duplicate notification issue in power automate Notifications 
Vignesh D        27/07/2023  I2RT-8640   T11     Added guard logic to query certification request business owner & created by user.
*******************************************************************************************************************************
*/

public without sharing virtual class NotificationService {

    public static final String TRIGGER_CREATE_ONLY = 'Create';
    public static final String TRIGGER_CREATE_EDIT = 'Create/Edit';
    
    public static final Map<String, Set<String>> mapNotifTypeToSystem = new Map<String, Set<String>>{
        'Salesforce Bell - Desktop' => new Set<String>{'Salesforce Bell'},
        'Salesforce Bell - Mobile' => new Set<String>{'Salesforce Bell'},
        'SMS' => new Set<String>{'Microsoft Power Automate'},
        'Email' => new Set<String>{'Microsoft Power Automate'},
        'Salesforce Chatter Post' => new Set<String>{'Salesforce Chatter', 'Microsoft Power Automate'},
        'Microsoft Teams Private message' => new Set<String>{'Microsoft Power Automate'},
        'Microsoft Teams Channel Email' => new Set<String>{'Microsoft Power Automate'},
        'MESSAGE_BUBBLE' => new Set<String>{'Notify Platform'},
        'MESSAGE_BOX' => new Set<String>{'Notify Platform'},
        'BELL_NOTIFICATION' => new Set<String>{'Notify Platform'},
        'BANNER' => new Set<String>{'Notify Platform'}
    };

 

    public enum NotificationEvent {
        CASE_NEW, CASE_UPDATE, CASE_ADDED_TO_ENGAGEMENT,
        CASE_COMMENT_NEW,
        RAISE_HAND_NEW,
        ENGAGEMENT_NEW
    }

    public enum TriggerMode {
        RECORD_INSERT, RECORD_UPDATE
    }
    
    public static Map<String, Notification_Criteria_Object__mdt> mapObjectNameToSettings = new Map<String, Notification_Criteria_Object__mdt>();
    public static Map<String, List<Notification_Criteria_Field__mdt>> mapObjectNameToFields = new Map<String, List<Notification_Criteria_Field__mdt>>();

    static {
        for(Notification_Criteria_Field__mdt fieldMeta : [Select Id, Object_Name__c, Field_API_Name__c, Field_Label__c From Notification_Criteria_Field__mdt]){
            List<Notification_Criteria_Field__mdt> lstFieldMeta = new List<Notification_Criteria_Field__mdt>();
            if(mapObjectNameToFields.containsKey(fieldMeta.Object_Name__c)){
                lstFieldMeta = mapObjectNameToFields.get(fieldMeta.Object_Name__c);
            }else{
                mapObjectNameToFields.put(fieldMeta.Object_Name__c, lstFieldMeta);
            }
            lstFieldMeta.add(fieldMeta);
        }

        for(Notification_Criteria_Object__mdt criteriaObject : [Select Id, Object_API_Name__c, Extension_Class_Name__c, Template_Name__c, Applicable_Apps__c From Notification_Criteria_Object__mdt]){
            mapObjectNameToSettings.put(criteriaObject.Object_API_Name__c, criteriaObject);
        }
    }

    public NotificationEvent event;
    public String objectName;
    public String objectAPIName;
    public Notification_Criteria_Object__mdt objectSettings;

    protected SObject recordNew;
    protected SObject recordOld;
    protected SObject record;
    protected TriggerMode triggerMode;
    protected List<Id> lstCriteriaId; //T02

    protected String newLine = '\n';
  
    protected Map<String, Set<Id>> mapNotifTypeToUserIds = new Map<String, Set<Id>>();
    protected Map<String, Set<Notification.CriteriaInfo>> mapNotifTypeToCriteria = new Map<String, Set<Notification.CriteriaInfo>>();

    private String messageTitle;
    private String messageBodyText;
    private String messageBodyHTML;

    public NotificationService(){ 

    }

    protected virtual String getTitle(){
        if(String.isEmpty(messageTitle)){
            messageTitle = 'notification message title';
        }
        return messageTitle;
    }

    protected virtual String getTextMsgBody(){
        if(String.isEmpty(messageBodyText)){
            messageBodyText = 'notification message body for text';
        }
        return messageBodyText;
    }

    protected virtual String getEmailMsgBody(){
        if(String.isEmpty(messageBodyHTML)){
            messageBodyHTML = 'notification message body for email';
        }
        return messageBodyHTML;
    }

    public static void notify(List<SObject> newList, Map<Id, SObject> oldMap, List<Id> lstCriteriaId){ //T02
        NotificationServiceQueue serviceQueue = new NotificationServiceQueue(newList, oldMap, lstCriteriaId); //T02
        //T01 - to prevent Too many queueable jobs limit exception
        if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()){
            Id jobId = System.enqueueJob(serviceQueue);
        }
        
    }

    public static void notify(List<SObject> newList, Map<Id, SObject> oldMap){
        notify(newList, oldMap, null);
    }
    
    public static void notify(SObject recordNew, SObject recordOld){
        notify(recordNew, recordOld, null);
    }
    
    public static void notify(SObject recordNew, SObject recordOld, List<Id> lstCriteriaId){ //T02
        NotificationService service = new NotificationService();
        
        String objectAPIName = recordNew.getSObjectType().getDescribe().getName();
        String objectName = recordNew.getSObjectType().getDescribe().getLabel();

        Notification_Criteria_Object__mdt objectSettings = NotificationService.mapObjectNameToSettings.get(objectAPIName);

        String className = 'NotificationService';
        if(!String.isEmpty(objectSettings.Extension_Class_Name__c)){
            className = objectSettings.Extension_Class_Name__c;
        }
        Type notificationService = Type.forName(className);

        try{
            service = (NotificationService)notificationService.newInstance();            
        }catch(Exception ex){
            system.debug('--exception occured ---'+ex.getLineNumber() + ex.getStackTraceString());
        }
        service.objectAPIName = objectAPIName;
        service.objectName = objectName;
        service.recordNew = recordNew;
        service.recordOld = recordOld;
        service.objectSettings = objectSettings;
        service.lstCriteriaId = lstCriteriaId; //T02
        service.process();
    }

    public void process() {
        //initialize
        init();
        
        //get all field values including related record fields
        queryRecordDetails();

        //case team members
        getSubscribedTeamMembers();

        //subscribers
        getNotificationUsers();
        //To update the Source object
        NotificationServiceSourceObjectUpdate.updateOppTriggerToFalse(objectAPIName, recordNew);
        NotificationServiceSourceObjectUpdate.updateContractTriggerToFalse(objectAPIName, recordNew);//SALESRT-13388
        //send notification
        sendNotification();
    }

    private void init(){
        triggerMode = NotificationService.TriggerMode.RECORD_UPDATE;

        if(recordOld == null){
            triggerMode = NotificationService.TriggerMode.RECORD_INSERT;
        }
    }

    private void queryRecordDetails(){
        Set<String> setFieldName = new Set<String>();
        for(Notification_Criteria_Field__mdt fieldMeta : mapObjectNameToFields.get(objectAPIName)){
            setFieldName.add(fieldMeta.Field_API_Name__c);
        }
        
        for(Notification_Recipient_Field__mdt recipientField : Notification_Recipient_Field__mdt.getAll().values()){
            if(recipientField.Object_Name__c == objectAPIName && (recipientField.Field_API_Name__c == 'Support_Account__r.Certification_Request__r.Owner__c' || recipientField.Field_API_Name__c == 'Support_Account__r.Certification_Request__r.CreatedById')){ //<T11>
                setFieldName.add('Support_Account__c');
            }
            else if(recipientField.Object_Name__c == objectAPIName){
                setFieldName.add(recipientField.Field_API_Name__c);
            }
        }

        Id recordId = recordNew.Id;

        String soql = 'Select Id';
		Boolean planteam = false;
        for(String fieldAPIName : setFieldName){

            //<T03> - Included the condition
             if(!fieldAPIName.contains('Plan_Team__r')){
                    soql += ', ' + fieldAPIName;
                }else if(objectAPIName != 'Plan__c' && !planteam)
				{
				 soql+= ','+ 'Plan__c';
				 planteam = true;
				}
        }
        soql += ' From ' + objectAPIName + ' Where Id = :recordId';

        record = Database.query(soql);
    }

    protected virtual void getSubscribedTeamMembers(){

    }

    private void getNotificationUsers(){
        List<Notification_Criteria__c> lstCriteria = new List<Notification_Criteria__c>();
        //T02 - if a list of Ids are provided, then fetch only those. if not, fetch all the records for the Object.
        if(lstCriteriaId != null){
            lstCriteria = [Select Id, Name, Object__c, Condition__c, Notification_Type__c, Evaluation_Trigger__c, Template_Name__c, SF_Chatter_Post_Email__c,Platform_Notification_Expiration__c,
                            (Select Id, User__c, Active__c, User_Type__c, Team_Member_Role__c, Account_Case_Fields__c, Related_Fields__c, Queue_Name__c,Platform_Recipient_Role__c From Notification_Users__r),
                            (Select Id, Field_API_Name__c From Notification_Criteria_Details__r)
                            From Notification_Criteria__c
                            Where Object__c = :objectAPIName And Id in :lstCriteriaId];
        }else{
            lstCriteria = [Select Id, Name, Object__c, Condition__c, Notification_Type__c, Evaluation_Trigger__c, Template_Name__c, SF_Chatter_Post_Email__c,Platform_Notification_Expiration__c,
                            (Select Id, User__c, Active__c, User_Type__c, Team_Member_Role__c, Account_Case_Fields__c, Related_Fields__c, Queue_Name__c,Platform_Recipient_Role__c From Notification_Users__r),
                            (Select Id, Field_API_Name__c From Notification_Criteria_Details__r)
                            From Notification_Criteria__c
                            Where Object__c = :objectAPIName And Active__c = TRUE];
        }

        for(Notification_Criteria__c criteria : lstCriteria){    
            //check if the criteria condition is satisfied
            if(evaluateCriteria(criteria)){
                System.debug('NotificationService, criteria satisfied, Id = ' + criteria.Id);
                if(!globalApexManager.avoidRecursion(criteria.Id)){
                    Notification.Message message = fetchMessageDetails(criteria.Template_Name__c,criteria.Id,criteria.Name);
                    Notification.CriteriaInfo criteriaInfo = new Notification.CriteriaInfo();
                    criteriaInfo.criteria = criteria;
                    criteriaInfo.message = message;
                   

                    Set<String> setUserId = new Set<String>();
                    Set<String> setUserIdPowerAutomate = new Set<String>();     //T10 . do not include usertype='user'          
                    for(Notification_User__c notifUser : criteria.Notification_Users__r){
                        if(notifUser.Active__c){
                            if(notifUser.User_Type__c == 'User' && notifUser.User__c != null){
                                setUserId.add(notifUser.User__c);
                            }else if(notifUser.User_Type__c == 'Related User' && notifUser.Related_Fields__c != null){
                                for (String relatedFieldName : notifUser.Related_Fields__c.split(',')){
                                    if(relatedFieldName == 'Support_Account__r.Certification_Request__r.Owner__c' || relatedFieldName == 'Support_Account__r.Certification_Request__r.CreatedById'){ //<T11>
                                        Object fieldValue = getFieldValue(record, 'Support_Account__c');
                                        if(fieldValue != null){
                                            String supportAccountId = String.valueOf(fieldValue);
                                            Date dtToday = GlobalUtility.getOrganizationDate();
                                            List<Certification_Request__c> lstCertificationRequests = [SELECT CreatedById,Owner__c FROM Certification_Request__c WHERE Support_Account__c = :supportAccountId AND Status__c = 'Approved' AND Start_Date__c <= :dtToday AND End_Date__c >= :dtToday AND Request_Type__c = 'Hypercare' ORDER BY CreatedDate DESC LIMIT 1];
                                            if(!lstCertificationRequests.isEmpty()){
                                                Id createdById = lstCertificationRequests[0].CreatedById;
                                                Id businessOwnerId = lstCertificationRequests[0]?.Owner__c;
                                                setUserId.add(createdById);
                                                setUserId.add(businessOwnerId);
                                                setUserIdPowerAutomate.add(createdById);
                                                setUserIdPowerAutomate.add(businessOwnerId);
                                            }
                                        }
                                    }
                                    else{
                                        Object fieldValue = getFieldValue(record, relatedFieldName);
                                        if(fieldValue != null && String.valueOf(fieldValue).startsWith('005')){
                                            setUserId.add((Id)fieldValue);                                        
                                            setUserIdPowerAutomate.add((Id)fieldValue);  //T10                                     
                                        }
                                    }
                                }
                            }else if(notifUser.User_Type__c == 'Queue' && notifUser.Queue_Name__c != null){
                                for (GroupMember groupMember : [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId = :notifUser.Queue_Name__c]){
                                    if(((String)groupMember.UserOrGroupId)?.startsWithIgnoreCase('005')){
                                        setUserId.add(groupMember.UserOrGroupId); //T07
                                        setUserIdPowerAutomate.add(groupMember.UserOrGroupId); //T10
                                    }
                                   // setUserId.add(groupMember.UserOrGroupId);
                                }
                            }
                            
                            try{
                                //<T05>-Included the plan team in condition
                                if(notifUser.User_Type__c == 'Account Team' || notifUser.User_Type__c == 'Case Team' || notifUser.User_Type__c == 'Plan Team' || notifUser.User_Type__c == 'Opportunity Team'){  
                                    System.debug('Inside Plan team -->'+ notifUser.User_Type__c);                  
                                    Set<Id> accountSet = new Set<Id>();
                                    Set<Id> caseSet = new Set<Id>();
                                    Set<Id> planteamset = new Set<Id>();
                                    Set<Id> oppIdSet = new Set<Id>();
                                    List<String> teamMemberRole = new List<String>();
                                    if(notifUser.Team_Member_Role__c <> null){
                                        teamMemberRole = notifUser.Team_Member_Role__c.split(',');
                                    }
                                    //<T05> - Modified query for plan team
                                    String query;
                                    if(notifUser.User_Type__c == 'Account Team' && notifUser.Account_Case_Fields__c != null){
                                        query = 'SELECT Id,';
                                        query += notifUser.Account_Case_Fields__c;
                                    }
                                    else if(notifUser.User_Type__c == 'Plan Team' && criteriaInfo.criteria.Object__c != 'Plan__c'){
                                        query = 'SELECT Id,';
                                        query += 'Plan__c';
                                    } else if(notifUser.User_Type__c == 'Opportunity Team' && criteriaInfo.criteria.Object__c != 'Opportunity' && notifUser.Account_Case_Fields__c != null){ //T09
                                        query = 'SELECT Id,';
                                        query += notifUser.Account_Case_Fields__c;
                                    }
                                    else if(notifUser.User_Type__c == 'Case Team' && criteriaInfo.criteria.Object__c != 'Case' && doesFieldExist(objectAPIName,'Case__c')){ //T07
                                        query = 'SELECT Id,';
                                       query += 'Case__c';
                                    }
                                    else{
                                        query = 'SELECT Id';
                                    }
                                    
                                    query += ' FROM ';
                                    query += criteriaInfo.criteria.Object__c;
                                    query += ' WHERE Id=\'';
                                    query +=  record.Id +'\'';                            

                                    for (sObject record : Database.query(query)){
                                        if(notifUser.User_Type__c == 'Account Team' && notifUser.Account_Case_Fields__c != null){
                                            accountSet.add((Id)record.get(notifUser.Account_Case_Fields__c));
                                        }
                                        else if(notifUser.User_Type__c == 'Case Team' && criteriaInfo.criteria.Object__c == 'Case'){
                                            caseSet.add(record.Id);
                                        }
                                        else if(notifUser.User_Type__c == 'Case Team' && criteriaInfo.criteria.Object__c != 'Case' && doesFieldExist(objectAPIName,'Case__c')){
                                         caseSet.add((Id)record.get('Case__c')); //T07  -> Case comment, collaborate,                                      
                                        //<T05>-Inculded condition for CSP Objects for Plan team Notiifcation
                                        }
                                        else if(notifUser.User_Type__c == 'Plan Team' && criteriaInfo.criteria.Object__c == 'Plan__c'){
                                           planteamset.add(record.Id); 
                                        }
                                        else if(notifUser.User_Type__c == 'Plan Team' && criteriaInfo.criteria.Object__c != 'Plan__c'){
                                           planteamset.add((Id)record.get('Plan__c'));        
                                        }     
					                    else if(notifUser.User_Type__c == 'Opportunity Team' && criteriaInfo.criteria.Object__c == 'Opportunity'){
                                           oppIdSet.add(record.Id);
                                    }
                                        else if(notifUser.User_Type__c == 'Opportunity Team' && criteriaInfo.criteria.Object__c != 'Opportunity'){ //T09
                                            oppIdSet.add((Id)record.get(notifUser.Account_Case_Fields__c));
                                        }
                                    }
                                    
                                    if(notifUser.User_Type__c == 'Account Team'){
                                        String accQueryStr = 'SELECT AccountId,TeamMemberRole,UserId FROM AccountTeamMember WHERE AccountId IN :accountSet';
                                        for(AccountTeamMember member : Database.query(accQueryStr)){
                                            if((teamMemberRole <> null && teamMemberRole.size() > 0 && teamMemberRole.contains(member.TeamMemberRole)) || (teamMemberRole.size() == 0)){
                                                setUserId.add(member.UserId); 
                                                setUserIdPowerAutomate.add(member.UserId); //T10
                                            }
                                        }   
                                    }else if(notifUser.User_Type__c == 'Case Team'){
                                        if(caseSet.size()>0){
                                            for(Case_Team__c caseTM:[SELECT Id, User__c, Role__c FROM Case_Team__c WHERE Case__c IN : caseSet]){
                                                if(caseTM.User__c!=null && ((teamMemberRole <> null && teamMemberRole.size() > 0 && String.isNotBlank(caseTM.Role__c) && teamMemberRole.contains(caseTM.Role__c))
                                                                            || (teamMemberRole.size() == 0))){
                                                    setUserId.add(caseTM.User__c); 
                                                    setUserIdPowerAutomate.add(caseTM.User__c); //T10
                                                }
                                            }//for loop ends here
                                               
                                            for(Case caseRec:[select Id,Owner_Manager_Id__c from Case WHERE Id IN : caseSet limit 1] ){ //T07
                                               if(teamMemberRole.contains('Manager') && caseRec.Owner_Manager_Id__c!=NULL) {
                                                setUserId.add(caseRec.Owner_Manager_Id__c);
                                                setUserIdPowerAutomate.add(caseRec.Owner_Manager_Id__c);//T10
                                                }
                                            }
                                        }
                                    }else if(notifUser.User_Type__c == 'Plan Team'){
                                        if(planteamset.size()>0){
                                            system.debug('Inside Plan Team');
                                            for(Plan_Team__c planTM:[SELECT Id, User__c, Role__c,Primary__c FROM Plan_Team__c WHERE Plan__c IN : planteamset]){
                                                if(planTM.User__c!=null && ((teamMemberRole <> null && teamMemberRole.size() > 0 && String.isNotBlank(planTM.Role__c) && teamMemberRole.contains(planTM.Role__c))
                                                                            || (teamMemberRole.size() == 0)))
                                                {
                                                    system.debug('Inside Plan Team if');
                                                    //<T06>  
                                                    system.debug('Test Plan team'+planTM.Role__c );
                                                    system.debug('Primary'+planTM.Primary__c); 
                                                        if(planTM.Role__c == 'CSM' || planTM.Role__c == 'CSM Manager')
                                                        {                                                              
                                                                if((planTM.Primary__c))
                                                                {
                                                                    setUserId.add(planTM.User__c); 
                                                                    setUserIdPowerAutomate.add(planTM.User__c); 
                                                                    system.debug('Inside CSM---->'+ setUserId.size());
                                                                    system.debug('Primary User Only'+setUserId); 
                                                                }
                                                                                                                          
                                                        }
                                                       else if(planTM.Role__c !='CSM' || planTM.Role__c !='CSM Manager')
                                                       {
                                                            setUserId.add(planTM.User__c); 
                                                            setUserIdPowerAutomate.add(planTM.User__c);
                                                            system.debug('Inside else CSM---->'+ setUserId);
                                                            system.debug('Inside else CSM size---->'+ setUserId.size());

                                                        }
                                                    //</T06>
                                                }
                                            }
                                        }
                                    } else if(notifUser.User_Type__c == 'Opportunity Team'){
                                        
                                        for(OpportunityTeamMember member : [SELECT Id, OpportunityId, TeamMemberRole, UserId FROM OpportunityTeamMember WHERE OpportunityId IN : oppIdSet]) {
                                            if((teamMemberRole <> null && teamMemberRole.size() > 0 && teamMemberRole.contains(member.TeamMemberRole)) || (teamMemberRole.size() == 0)){
                                                setUserId.add(member.UserId);
                                                setUserIdPowerAutomate.add(member.UserId);
                                            }
                                            
                                        }

                                    }
                                }
                            } catch(Exception e){
                                system.debug('Exception occured'+e.getmessage()+e.getLineNumber());
                            }   
                        }
                    }
                                      
                    List<String> setNotifType = criteria.Notification_Type__c.split(';');
                    for(String notifType : setNotifType){
                        Set<String> setNotifSystem = mapNotifTypeToSystem.get(notifType);
                    
                        for(String notifSystem : setNotifSystem){
                         //   if(!('Salesforce Chatter Post'.equals(notifType) && 'Microsoft Power Automate'.equals(notifSystem)) || String.isNotEmpty(criteriaInfo.criteria.SF_Chatter_Post_Email__c)){ //T08 commented this to run for all notif types
                                Set<Notification.CriteriaInfo> setCriteriaInfo = new Set<Notification.CriteriaInfo>();
                                if('Microsoft Power Automate'.equals(notifSystem)){ //T10
                                    criteriaInfo.setUserId = setUserIdPowerAutomate;  
                                }else{
                                    criteriaInfo.setUserId = setUserId;  
                                }
                                if(mapNotifTypeToCriteria.containsKey(notifSystem)){
                                    setCriteriaInfo = mapNotifTypeToCriteria.get(notifSystem);
                                }else{
                                    mapNotifTypeToCriteria.put(notifSystem, setCriteriaInfo);
                                }
                                setCriteriaInfo.add(criteriaInfo);        
                          //  } //T08
                        }
                    }  
                }
            }
        }
    }

    private void sendNotification(){
        Set<String> setNotifType = new Set<String>();
        setNotifType.addAll(mapNotifTypeToCriteria.keySet());
        setNotifType.addAll(mapNotifTypeToUserIds.keySet());

        for(String notifType : setNotifType){
            Notification notification;
            switch on notifType {
                when 'Salesforce Bell' {
                    notification = new NotificationBell();
                }
                when 'Salesforce Chatter' {
                    notification = new NotificationChatter();
                }
                when 'Microsoft Power Automate' {
                    notification = new NotificationPowerAutomate();
                }
                when 'Notify Platform' {
                    notification = new NotificationPlatform();
                }
            }
            if(notification!=null){
                notification.event = event;
                notification.recordId = recordNew.Id;
                notification.recordData = record;

                if(mapNotifTypeToCriteria.containsKey(notifType)){
                    notification.setCriteriaInfo = mapNotifTypeToCriteria.get(notifType);
                }
                notification.send();    
            }
        }
        
    }

    private Boolean evaluateCriteria(Notification_Criteria__c criteria){
        Boolean returnValue = false;

        Boolean qualifies = false;
        if(triggerMode == NotificationService.TriggerMode.RECORD_INSERT){
            qualifies = true;
        }else if(triggerMode == NotificationService.TriggerMode.RECORD_UPDATE){
            if(TRIGGER_CREATE_ONLY.equals(criteria.Evaluation_Trigger__c)){
                qualifies = false;
            }else if(TRIGGER_CREATE_EDIT.equals(criteria.Evaluation_Trigger__c)){
                //check if any of the criteria field values got updated
                for(Notification_Criteria_Detail__c criteriaDetail : criteria.Notification_Criteria_Details__r){
                    String fieldName = criteriaDetail.Field_API_Name__c;
    
                    if(!fieldName.contains('.')){
                        if(record.get(fieldName) != recordOld.get(fieldName)){
                            qualifies = true;
                            break;
                        }    
                    }
                }
            }
        }

        //check if the criteria condition is satisfied
        if(qualifies && String.isNotEmpty(criteria.Condition__c)){
            System.debug('record = ' + record);
            
            //evaluate the condition with new values
            Boolean passedWithNewValues = evaluateCondition(record, null, criteria.Condition__c);

            //
            if(passedWithNewValues){
                if(triggerMode == NotificationService.TriggerMode.RECORD_UPDATE && TRIGGER_CREATE_EDIT.equals(criteria.Evaluation_Trigger__c)){
                    //evaluate the condition with old values
                    Boolean passedWithOldValues = evaluateCondition(record, recordOld, criteria.Condition__c);
                    if(!passedWithOldValues){
                        returnValue = true;
                    }else{
                        returnValue = false;
                    }
                }else{
                    returnValue = true;
                }
            }else{
                returnValue = false;
            }
        }

        //System.debug('returnValue = ' + returnValue);
        return returnValue;
    }

    private Boolean evaluateCondition(SObject record, SObject recordOld, String condition){
        Boolean returnValue = false;

        //T01
        Map<String, Object> recordNewMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(recordNew));
        
        Map<String, Object> context = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(record));
        System.debug('context 0 = ' + context);
        //T01 - to set the values from the Trigger context
        for(String fieldName : recordNewMap.keySet()){
            context.put(fieldName, recordNewMap.get(fieldName));
        }
        System.debug('context 1 = ' + context);

        if(recordOld != null){
            Map<String, Object> contextOldValues = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(recordOld));
            //context.putAll(contextOldValues);
            for (String key : context.keySet()){
                if(contextOldValues.containsKey(key)){
                    context.put(key, contextOldValues.get(key));
                }else{
                    context.put(key, null);
                }
            }
        }
		
		//<T03>		
		if(condition.contains('Plan_Team__r'))       
		{
            
            ScriptEngine scriptEngine1 = ScriptEngine.getInstance();	
			
				Boolean childcondition = false;
				Id planId = String.valueof(record.getSObjectType() )== 'Plan__c'?(id)record.get('id'):(id)record.get('Plan__c');
            for(Plan_Team__c pt:[Select id,Role__c,User__c,Primary__c from Plan_Team__c where Plan__c=:planId])
				{				
                   
                    context.put('Plan_Team__r',(Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(pt)));
					 try{
					 
					 Object result = scriptEngine1.eval(condition, context);
					if((Boolean)result){
					return (Boolean)result;
					}

					 }
					 catch(Exception ex){
					System.debug('exception = ' + (ex.getMessage()));
				    }
                }
        }	
			
        //</T03>
						

		ScriptEngine scriptEngine = ScriptEngine.getInstance();	
		
        System.debug('context 2 = ' + context);

        System.debug('condition = ' + condition);

        try{
					
				Object result = scriptEngine.eval(condition, context);
          
            System.debug('result = ' + result);
            returnValue = (Boolean)result;
        }catch(Exception ex){
            System.debug('exception = ' + ex.getMessage());
        }

        return returnValue;
    }


    private Notification.Message fetchMessageDetails(String templateName,String criteriaId,String criterianame){
        System.debug('Criteria Template Name = ' + templateName);
        if (String.isEmpty(templateName)){
            if(!String.isEmpty(objectSettings.Template_Name__c)){
                templateName = objectSettings.Template_Name__c;
                System.debug('Custom Settings Template Name = ' + templateName);
            }else{
                templateName = objectName.replaceAll(' ', '_') + '_Notification';
                System.debug('Default Template Name = ' + templateName);
            }
        }
        
        List<EmailTemplate> lstEmailTemplate = new List<EmailTemplate>();
        lstEmailTemplate = [Select Id, Subject, Body, HtmlValue From EmailTemplate Where DeveloperName = :templateName];

        Notification.Message message = new Notification.Message();
        //<T05>
        String strHTMLCode;
        String strTextCode;
        String notficationruletext= '';
        notficationruletext += '\n'+'\n';
        notficationruletext +=  'Notification ID:'+' '+criteriaId;     
        notficationruletext += '\n'+'Notification Name:'+' '+criterianame;   

        String notficationruleHtmltext= '';
        notficationruleHtmltext += '\n'+'\n';
        notficationruleHtmltext += 'Notification Name:'+' '+'<a href="'+URL.getSalesforceBaseUrl().toExternalForm() +'/' +criteriaId+'">'+criterianame+'</a>';     
        //</T05>
       //<T05> - Append the Notification rule details in the messgae
        if(!lstEmailTemplate.isEmpty()) {
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(lstEmailTemplate.get(0).Id, null, recordNew.Id);
            message.title = mail.getSubject();
            if(mail.getHtmlBody() !=null)
            {
                if(mail.getHtmlBody().contains('{{{NotificationRule}}}'))
                {
                    strHTMLCode= mail.getHtmlBody();              
                    message.bodyHTML = strHTMLCode.replace('{{{NotificationRule}}}', notficationruleHtmltext);
                }else{
                    message.bodyHTML = mail.getHtmlBody()+notficationruleHtmltext;
                }
            }
            if(mail.getPlainTextBody() !=null)
            {

                if(mail.getPlainTextBody().contains('{{{NotificationRule}}}')) {
                
                    strTextCode = mail.getPlainTextBody();
                    message.bodyText = strTextCode.replace('{{{NotificationRule}}}', notficationruletext);
                }else{
                    message.bodyText = mail.getPlainTextBody()+ notficationruletext;
                }  
            }
                             
        }else{
            message.title = getTitle();
            if(getEmailMsgBody() !=null)
            {
                if(getEmailMsgBody().contains('{{{NotificationRule}}}'))
                {
                    strHTMLCode= getEmailMsgBody();              
                    message.bodyHTML = strHTMLCode.replace('{{{NotificationRule}}}', notficationruleHtmltext);
                }else{
                    message.bodyHTML = getEmailMsgBody()+notficationruleHtmltext;
                }
            }
            if(getTextMsgBody() !=null)
            {
                if(getTextMsgBody().contains('{{{NotificationRule}}}')) {
                
                    strTextCode =getTextMsgBody();
                    message.bodyText = strTextCode.replace('{{{NotificationRule}}}', notficationruletext);
                }else{
                    message.bodyText = getTextMsgBody()+notficationruletext;
                } 
            }                                  
        }
        return message;
       
    }

    private Object getFieldValue(sObject record, String fieldName){
        Object fieldValue;
        system.debug('NotificationService, getFieldValue, fieldName = ' + fieldName);

        while(fieldName.contains('.')){
            String relatedFieldName = fieldName.substringBefore('.').replace('__r', '__c');
            system.debug('NotificationService, getFieldValue, relatedFieldName = ' + fieldName);
            if(record.isSet(relatedFieldName) && record.getSObject(fieldName.substringBefore('.')) != null){
                system.debug('NotificationService, getFieldValue, rescord.isset is true');
                record = (sObject)record.getSObject(fieldName.substringBefore('.'));
                fieldName = fieldName.substringAfter('.');
                system.debug('NotificationService, getFieldValue, fieldName 2 = ' + fieldName);
            }else{
                return null;
            }
        }
        system.debug('NotificationService, getFieldValue, fieldName 3 = ' + fieldName);

        if(record.isSet(fieldName) && record.get(fieldName) != null){
            fieldValue = record.get(fieldName);
        }
        return fieldValue;
    }

     /**
     * @description Method to check if field exists for  the object     
     * params: objName = object API name , fieldName : field API name
     * return : boolean. returns true if field exists on the object,else false 
     */  
    private boolean doesFieldExist(String objName, string fieldName){ //T07
        try {
            SObject so = Schema.getGlobalDescribe().get(objName).newSObject();
            return so.getSobjectType().getDescribe().fields.getMap().containsKey(fieldName);
        }
        catch(Exception ex) { }         
        return false;
    }
    
}