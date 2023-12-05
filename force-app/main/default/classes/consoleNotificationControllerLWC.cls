/*
        Class:          consoleNotificationControllerLWC
        @Author:        Jiju
        @Created Date:  11-August-2021
        @Description:   Console Notifications 
        @JIRA :         I2RT-3660

 Change History
 *********************************************************************************************************************************************
   ModifiedBy                  Date          JIRA No.          Requested By               Description                               Tag
 *********************************************************************************************************************************************
   Vignesh Divakaran           29-Jun-2022   I2RT-6153         NA                         Replace GCS_Segment__c with Segment__c    T01
                                                                                          field and add Hypercare flag to the 
                                                                                          NotificationDetails wrapper                       
   Shashikanth                 23-Aug-2023   I2RT-8959         NA                         Preferred icon to be added in queue       T02
                                                                                          assignment widget
*/
public class consoleNotificationControllerLWC {
    @AuraEnabled
    public static UserDetails getUserDetails(){
        UserDetails userDetailsObj = new UserDetails();
        User userRecord = getLoggedInUserDetails();
        String UserId = userRecord.Id;
        userDetailsObj.isMute = userRecord.Notification_Sound_Muted__c;
        userDetailsObj.queryString = getQueueDetails(userRecord);
        Boolean showSettingIcon = false;
        for(PermissionSetAssignment psa : [Select Id,AssigneeId,PermissionSetGroupId,PermissionSetGroup.DeveloperName from PermissionSetAssignment where AssigneeId =: UserId]){
            if(psa.PermissionSetGroup.DeveloperName =='GCS_Admin' || psa.PermissionSetGroup.DeveloperName =='GCS_Manager'){
                showSettingIcon = true;
            }
        }
        userDetailsObj.showSettings = showSettingIcon;
        return userDetailsObj;
    }
    private static String getQueueDetails(User userRecord) {
        String userGCSTeam = userRecord.GCS_Team__c == null ? 'No Team' : userRecord.GCS_Team__c;
        List<Custom_Notification_Filter__c> userCustomNotifyList = getUserFilterDetails(userGCSTeam);
        List<String> queuesNamesList = new List<String>();
        for(Custom_Notification_Filter__c userFilter : userCustomNotifyList){
            if(!String.IsBlank(userFilter.Queue_Membership__c)){
                List<String> tempQueuesNamesList = userFilter.Queue_Membership__c.split(';');
                queuesNamesList.addAll(tempQueuesNamesList);
            }
        }
        if(userCustomNotifyList.size() > 0){
            if(!queuesNamesList.IsEmpty()){
                List<Group> queueList = getQueuesList(queuesNamesList);
                String queryString = 'Blank';
                for(Group Q : queueList) {
                    if(queryString == 'Blank'){
                        queryString = '?OwnerId='+String.valueOf(Q.Id);
                    }else{
                        queryString += '&OwnerId='+String.valueOf(Q.Id);
                    }
                }
                return queryString;
            }else{
                return '?OwnerId=NULL';
            }
        }else{
            return '?OwnerId=NULL';
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<NotificationDetails> getCustomNotifsList(){
        Map<Id, List<CaseMileStone>> caseMilestonesMap = new Map<Id, List<CaseMileStone>>();
        List<NotificationDetails> customNotifyList = new List<NotificationDetails>();
        List<Case> filteredCaseList = new List<Case>();
        List<String> queuesNamesList = new List<String>();
        Set<Id> caseIdSet = new Set<Id>();
        String queryString = 'Blank';
        String supportLevel = '';
        NotificationDetails customNotify = new NotificationDetails();
        User userRecord = getLoggedInUserDetails();
        String userGCSTeam = userRecord.GCS_Team__c == null ? 'No Team' : userRecord.GCS_Team__c;
        List<Custom_Notification_Filter__c> userFilterList = getUserFilterDetails(userGCSTeam);
        for(Custom_Notification_Filter__c userFilter : userFilterList){
            if(!String.IsBlank(userFilter.Queue_Membership__c)){
                List<String> tempqueuesNamesList = userFilter.Queue_Membership__c.split(';');
                queuesNamesList.addAll(tempqueuesNamesList);
            }
        }
        
        if(!queuesNamesList.IsEmpty()){
            List<Group> queueList = getQueuesList(queuesNamesList);
            for(Group queue : queueList){
                if(queryString == 'Blank'){
                    queryString = 'OwnerId=\''+String.valueOf(queue.Id)+'\'';
                }else{
                    queryString += ' OR OwnerId=\''+String.valueOf(queue.Id)+'\'';
                }
            }
        }else{
            return new List<NotificationDetails>();
        }
        String query = getCaseQuery(queryString);
        List<Case> caseList = Database.query(query);
        if(!caseList.IsEmpty()){
            for(Case c : caseList){
                caseIdSet.add(c.Id);
            }
            List<CaseMilestone> milestonesList = getCaseMilestonesList(caseIdSet);
            if(!milestonesList.IsEmpty()){
                caseMilestonesMap = getCaseIdByMilestonesMap(milestonesList);
            }
            for(Case caseRecord : caseList){
                for(Custom_Notification_Filter__c userFilter : userFilterList){
                    if((userFilter.Queue_Membership__c == null || userFilter.Queue_Membership__c == '' || userFilter.Queue_Membership__c.indexOf(caseRecord.Owner.Name) != -1) &&
                       (userFilter.Filter_Support_Levels__c == null || userFilter.Filter_Support_Levels__c == '' || (caseRecord.Success_Offering__c != null && userFilter.Filter_Support_Levels__c.indexOf(caseRecord.Success_Offering__c) != -1)) &&
                       (userFilter.Filter_Regions__c == null || userFilter.Filter_Regions__c == '' || (caseRecord.Case_TimeZone_Global_Region__c != null && userFilter.Filter_Regions__c.indexOf(caseRecord.Case_TimeZone_Global_Region__c) != -1)) && 
                       (userFilter.Filter_Product_Lines__c == null ||userFilter.Filter_Product_Lines__c == '' || (caseRecord.Forecast_Product__c != null && userFilter.Filter_Product_Lines__c.indexOf(caseRecord.Forecast_Product__c) != -1)) &&
                       (userFilter.Filter_Products__c == null || userFilter.Filter_Products__c == '' || (caseRecord.Component__c != null && userFilter.Filter_Products__c.indexOf(caseRecord.Component__c) != -1)) && 
                       (userFilter.Filter_Segment__c == null || userFilter.Filter_Segment__c == '' || (caseRecord.Segment__c!= null && userFilter.Filter_Segment__c.indexOf(caseRecord.Segment__c) != -1)) &&
                       (userFilter.Filter_Priority__c == null || userFilter.Filter_Priority__c == '' || (caseRecord.Priority != null && userFilter.Filter_Priority__c.indexOf(caseRecord.Priority) != -1)) &&
                       (userFilter.Filter_Timezone__c == null || userFilter.Filter_Timezone__c == '' || (caseRecord.Case_Timezone_Name__c != null && userFilter.Filter_Timezone__c.indexOf(caseRecord.Case_Timezone_Name__c) != -1))){
                           customNotify = new NotificationDetails();
                           customNotify.caseId = caseRecord.Id;
                           customNotify.caseNumber = caseRecord.CaseNumber;
                           customNotify.priority = caseRecord.Priority;
                           customNotify.product = caseRecord.Forecast_Product__c;
                           customNotify.subject = caseRecord.subject;
                           customNotify.caseOwnerName = caseRecord.Owner.Name;
                           customNotify.supportAccountName = caseRecord.Support_Account__r.Name;
                           customNotify.timezone = caseRecord.Case_Timezone__r.Name;
                           customNotify.isAAE = caseRecord.Record_Type_Name__c == 'Ask An Expert'?True:False;
                           customNotify.isP1 = caseRecord.Priority == 'P1'?True:False;
                           customNotify.isP2 = caseRecord.Priority == 'P2'?True:False;
                           customNotify.isP3 = caseRecord.Priority == 'P3'?True:False;
                           customNotify.isBCSPCase = caseRecord.Case_Support_Add_On__c == 'BCSP'?True:False;
                           customNotify.isHypercare = caseRecord.Segment__c == 'Hypercare'?True:False; //<T01>
                           customNotify.isStrategic = caseRecord.Segment__c == 'Strategic'?True:False;
                           customNotify.isPreferred = caseRecord.Segment__c == 'Preferred'?True:False;  //<T02>
                           customNotify.isCritical = caseRecord.Segment__c == 'Critical'?True:False;
                           customNotify.isStandardIcon = caseRecord.Success_Offering__c == 'Standard'?True:False;
                           customNotify.isEnterpriseIcon = caseRecord.Success_Offering__c == 'Enterprise'?True:False;
                           customNotify.isMissionCriticalIcon = caseRecord.Success_Offering__c == 'Mission Critical'?True:False;
                           customNotify.isPremierIcon = caseRecord.Success_Offering__c == 'Premier'?True:False;
                           customNotify.isBasicSuccessIcon = caseRecord.Success_Offering__c == 'Basic Success'?True:False;
                           customNotify.isPremiumSuccessIcon = caseRecord.Success_Offering__c == 'Premium Success'?True:False;
                           customNotify.isSignatureSuccessIcon = caseRecord.Success_Offering__c == 'Signature Success'?True:False;
                           customNotify.iRTargetTime = '';
                           if(caseMilestonesMap.get(caseRecord.Id) != null){
                               for(CaseMilestone cm : caseMilestonesMap.get(caseRecord.Id)){
                                   if(!cm.IsCompleted){
                                       if(cm.MilestoneType.Name == 'Initial Response'){
                                           customNotify.isIRTargetTime = true;
                                           if(!cm.IsViolated){
                                               customNotify.iRTargetTime = cm.TargetDate.format();
                                           } else{
                                               customNotify.iRTargetTime = cm.TargetDate.format()+'!';
                                           }
                                       }
                                   }
                               }
                           }
                           customNotifyList.add(customNotify);
                           Break;
                       }
                }
            }
        }
        return customNotifyList;
    }
    
    @AuraEnabled
    public static String updateCaseOwner(String Message) {
        List<String> parameters = Message.split(';');
        String caseIdParameter = parameters[0];
        String ownerNamePrameter = parameters[1];
        List<Case> caseList = [Select Id, Owner.Name, OwnerId, Owner.Type from Case where Id =: caseIdParameter];
        if(caseList.size() > 0){
            Case csHolder = caseList[0];
            if(csHolder.Owner.Name == ownerNamePrameter){
                csHolder.OwnerId = UserInfo.getUserId();
                try{
                    Database.SaveResult sresult = Database.Update(csHolder);
                    if (sresult.isSuccess()) {
                        return 'Success';
                    }else{
                        return 'Could not assign record.';
                    }
                }catch(exception e){
                    return 'Could not assign record.';
                }
            }else{
                return 'Already assigned to '+csHolder.Owner.Name;
            }
        }
        return Message;
    }
    
    @AuraEnabled
    public static Void updateMuteInfo(String Message) {
        Id userId = UserInfo.getUserId();
        User userObj = new User();
        userObj.Id = userId;
        if(Message == 'Mute'){
            userObj.Notification_Sound_Muted__c = True;
        }else if(Message == 'Unmute'){
            userObj.Notification_Sound_Muted__c = False;
        }
        Update userObj;
    }
    
    private static List<Custom_Notification_Filter__c> getUserFilterDetails(String userGCSTeam){
        return [Select 
                  Id, 
                  Filter_Priority__c, 
                  Filter_Segment__c,
                  GCS_Team__c,
                  User__c, 
                  Filter_Product_Lines__c, 
                  Filter_Products__c, 
                  Filter_Regions__c, 
                  Filter_Support_Levels__c, 
                  Filter_Timezone__c, 
                  Queue_Membership__c 
                from 
                  Custom_Notification_Filter__c 
                where 
                  User__c =: UserInfo.getUserId() 
                  OR GCS_Team__c  =: userGCSTeam];
    }
    private static List<Group> getQueuesList(List<String> queuesNamesList){
        return [SELECT 
                  Id, 
                  Name, 
                  DeveloperName, 
                  Email, 
                  Type 
                FROM 
                  Group 
                WHERE 
                  Type='Queue' 
                  AND Name IN: queuesNamesList];
    }
    private static String getCaseQuery(String queryString){
        return 'SELECT '+
                 'Id,'+
                 'OwnerId,'+
                 'Owner.type,'+
                 'Owner.Name,'+
                 'Case_Timezone_Name__c,'+
                 'Success_Offering__c,'+
                 'Support_Account__r.Name,'+
                 'Live_Assistance_Request_Reason__c,'+
                 'Record_Type_Name__c,'+
                 'Case_Support_Add_On__c,'+
                 'Case_TimeZone_Global_Region__c,'+
                 'Contact.INFA_Language__c,'+
                 'Forecast_Product__c,'+
                 'Component__c,'+
                 'Segment__c,'+
                 'CaseNumber,'+
                 'Case_Timezone__r.Name,'+
                 'IsEscalated,'+
                 'Priority,'+
                 'Status,'+
                 'Subject,Support_Level__c,'+
                 'Escalation_Reason__c,'+
                 'Case_InActive__c,'+
                 'Case_Last_Activity__c,'+
                 'RecordType.Name,'+
                 'Parent.Entitlement.Support_Level__c,'+
                 'LastModifiedById,'+
                 'LastModifiedDate,'+
                 'CreatedDate '+
               'FROM '+
                 'Case '+
               'WHERE ('+queryString+') '+
                 'AND (Status!=\'Closed\' AND Status!=\'Resolved\') '+
                 'AND (Record_Type_Name__c = \'Technical\' OR Record_Type_Name__c = \'Operations\' OR Record_Type_Name__c =\'Ask An Expert\')';
    }
    private static List<CaseMilestone> getCaseMilestonesList(Set<Id> caseIdSet){
        return [SELECT 
                  Id,
                  CaseId,
                  TargetDate,
                  IsCompleted,
                  IsViolated,
                  TimeRemainingInMins,
                  MilestoneType.Name 
                FROM 
                  CaseMilestone 
                WHERE 
                  CaseID IN: caseIdSet];
    }
    private static Map<Id, List<CaseMileStone>> getCaseIdByMilestonesMap(List<CaseMileStone> milestonesList){
        Map<Id, List<CaseMileStone>> caseMilestonesMap = new Map<Id, List<CaseMileStone>>();
        List<CaseMilestone> tempList;
        for(CaseMilestone milestone : milestonesList){
            if(caseMilestonesMap.get(milestone.CaseId) == null){
                tempList = new List<CaseMilestone>();
            }else{
                tempList = caseMilestonesMap.get(milestone.CaseId);
            }
            tempList.add(milestone);
            caseMilestonesMap.put(milestone.CaseId, tempList);
        }
        return caseMilestonesMap;
    }
    private static User getLoggedInUserDetails(){
        return [Select 
                  Id, 
                  Notification_Sound_Muted__c, 
                  GCS_Team__c 
                from 
                  User 
                where 
                  Id =:UserInfo.getUserId()];
    }

    //Encapsulated Class for the existing notification details.
    public class NotificationDetails {
        @AuraEnabled
        public string caseId {get;set;}
        @AuraEnabled
        public string caseNumber {get;set;}
        @AuraEnabled
        public string priority {get;set;}
        @AuraEnabled
        public boolean isP1 {get; set;}
        @AuraEnabled
        public boolean isP2 {get; set;}
        @AuraEnabled
        public boolean isP3 {get; set;}
        @AuraEnabled
        public boolean isAAE {get; set;}
        @AuraEnabled
        public boolean isBCSPCase {get; set;}
        @AuraEnabled
        public boolean isEscalated {get; set;}
        @AuraEnabled
        public boolean isHypercare {get; set;} //<T01>
        @AuraEnabled
        public boolean isStrategic {get; set;}
        @AuraEnabled
        public boolean isPreferred {get; set;}   //<T02>
        @AuraEnabled
        public boolean isCritical {get; set;}
        @AuraEnabled
        public String product {get; set;}
        @AuraEnabled
        public String strategicType {get; set;}
        @AuraEnabled
        public String supportAccountName {get; set;}
        @AuraEnabled
        public String escalationReason {get; set;}
        @AuraEnabled
        public String status {get; set;}
        @AuraEnabled
        public String subject {get; set;}
        @AuraEnabled
        public String iRTargetTime {get; set;}
        @AuraEnabled
        public Boolean isIRTargetTime {get; set;}
        @AuraEnabled
        public String supportLevel {get; set;}
        @AuraEnabled
        public String timezone {get; set;}
        @AuraEnabled
        public String caseOwnerName {get; set;}
        @AuraEnabled
        public boolean isStandardIcon {get; set;}
        @AuraEnabled
        public boolean isEnterpriseIcon {get; set;}
        @AuraEnabled
        public boolean isMissionCriticalIcon {get; set;}
        @AuraEnabled
        public boolean isPremierIcon {get; set;}
        @AuraEnabled
        public boolean isBasicSuccessIcon {get; set;}
        @AuraEnabled
        public boolean isPremiumSuccessIcon {get; set;}
        @AuraEnabled
        public boolean isSignatureSuccessIcon {get; set;}

        public NotificationDetails() {
            isAAE = false;
            isBasicSuccessIcon = false;
            isBCSPCase = false;
            isCritical = false;
            isEnterpriseIcon = false;
            isEscalated = false;
            isIRTargetTime = false;
            isMissionCriticalIcon = false;
            isPremierIcon = false;
            isPremiumSuccessIcon = false;
            isP1 = false;
            isP2 = false;
            isP3 = false;
            isSignatureSuccessIcon = false;
            isStandardIcon = false;
            isHypercare = false; //<T01>
            isStrategic = false;
            caseId = '';
            caseNumber = '';
            caseOwnerName = '';
            escalationReason = '';
            iRTargetTime = '';
            priority = '';
            product = '';
            status = '';
            strategicType = '';
            subject = '';
            supportAccountName = '';
            supportLevel = '';
            timezone = '';
        }
    }
    public class UserDetails {
        @AuraEnabled
        public string queryString {get;set;}
        @AuraEnabled
        public Boolean isMute {get;set;}
        @AuraEnabled
        public Boolean showSettings {get;set;}
        public UserDetails() {
            queryString = '';
            isMute = false;
            showSettings = false;
        }
    }
        
}