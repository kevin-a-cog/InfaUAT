/*
* Name         :   EventDetailController
* Author       :   Vignesh Divakaran
* Created Date :   11/02/2021
* Description  :   Controller class for Event Detail page of Informatica Network.

Change History
**********************************************************************************************************
Modified By            Date            Jira No.        Description                                                   Tag
**********************************************************************************************************
Vignesh Divakaran      11/02/2021      N/A             Initial version.                                              N/A
Deeksha Shetty         18/10/2022     I2RT-7272       Giving option for the admin/Leader to edit the events without   T1
                                                      notifying the user
*/
public without sharing class EventDetailController {
    
    //Fetching the Labels From Metadata
    @AuraEnabled
    public static help_Infa_Custom_Label__mdt getmetadatarecords(){
        try{
            help_Infa_Custom_Label__mdt recordlist = [SELECT PastEventMsg__c, EventEndStatus__c,EventJoinSuccess__c, EventYetToHappen__c    
                                                      FROM help_Infa_Custom_Label__mdt WHERE developerName = 'helpEvents'];
            System.debug('recordlist='+recordlist);
            return recordlist;
        }
        Catch(Exception e){
            system.debug('Error in metadata : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());             
        }
    }
    
    @AuraEnabled
    public static DisplayActionItems findEventStatus(String recId){
        try{
            List<User> ulicense = [Select Id From User Where Profile.UserLicense.Name = 'Salesforce' AND Id=:UserInfo.getUserId()];
            
            String joineventstatus, activitydatestatus, editmodifystatus, owneroftheevent;
            Event objEvent = [Select ActivityDate,user_group_Id__c,createdById from Event where Id =:recId];
            Map<Id,CollaborationGroup> colabmap = new Map<Id,CollaborationGroup>([Select Id, Name from CollaborationGroup 
                                                                                  where ownerId=:userinfo.getUserId() and Id=:objEvent.user_group_Id__c]);
            if(colabmap.size()>0 || ulicense.size()>0){
                editmodifystatus = 'ShowEditDeletePopup';
            }
            List<EventRelation> evlist = [Select Id,Status from EventRelation where Eventid=:recId and RelationId=:userinfo.getUserId()];
            System.debug('evlist='+evlist);
            
            if(objEvent.createdById == userinfo.getUserId()){
                owneroftheevent = 'Owner';
            }
            else if(evlist.size()>0 && evlist[0].Status == 'Accepted'){
                joineventstatus = 'EnableDeclineAction';
                
            }
            else if(evlist.size()>0 && evlist[0].Status == 'Declined'){
                joineventstatus = 'EnableJoinAction';
            }
            
            if(objEvent.ActivityDate < System.Today()){
                activitydatestatus =  'Past';
            }
            else if(objEvent.ActivityDate > System.Today()){
                activitydatestatus = 'Future';
            }
            DisplayActionItems action = new DisplayActionItems();
            action.JoinEventStatus = joineventstatus;
            action.ActivityDateStatus = activitydatestatus;
			action.EditDeleteDisplay =   editmodifystatus;
            action.isOwner = owneroftheevent;
            if(objEvent.user_group_Id__c !=null) action.UserGroupId = objEvent.user_group_Id__c;  //T1
            return action;
            
        }
        catch (Exception e) {
            system.debug('Error in Activity action item : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }
        
    }
    
        /*
    Method Name : getExportToCalendar
    Description : This method returns a string containing vcalender metadata .
    Parameters  : String, called from getExportToCalendar, recordId.
    Return Type : String.
    */
    @AuraEnabled
    public static vCalendar getExportToCalendar(String strRecordId) {
        try{
            Event objEvent = [Select Id,Subject,Description,Location,StartDateTime,EndDateTime from Event where Id =: strRecordId];
            vCalendar objVcalender = new vCalendar();            
            String timezonestr = String.valueOf(UserInfo.getTimeZone());
            String endtime = objEvent.EndDateTime.format('HHmmssZ');
            String starttime = objEvent.StartDateTime.format('HHmmssZ');
            
            System.debug(timezonestr);
            String strMetadata = '';             
            strMetadata += 'BEGIN:VCALENDAR\n';        
            strMetadata += 'VERSION:2.0\n';
            strMetadata += 'PRODID:-//salesforce.com//Calendar//EN \n';
            strMetadata += 'BEGIN:VEVENT\n';
            strMetadata += 'UID:'+strRecordId+'\n';
            strMetadata += 'DTSTAMP;TZID=America/New_York:'+System.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'')+'\n';
            strMetadata += 'SUMMARY:'+objEvent.Subject+'\n';
            strMetadata += 'DESCRIPTION:'+objEvent.Description.stripHTMLtags()+'\n';
            strMetadata += 'CATEGORIES:salesforce.com'+'\n';
            strMetadata += 'CREATED;TZID=America/New_York:'+System.now().format('yyyyMMdd\'T\'HHmmss\'Z\'','America/New_York')+'\n';
            strMetadata += 'LAST-MODIFIED;TZID=America/New_York:'+System.now().format('yyyyMMdd\'T\'HHmmss\'Z\'','America/New_York')+'\n';
            strMetadata += 'STATUS:CONFIRMED'+'\n';
            strMetadata += 'LOCATION:'+objEvent.Location+'\n';            
            strMetadata += 'DTSTART;TZID=America/New_York:'+objEvent.StartDateTime.formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'')+'\n';
            strMetadata += 'DTEND;TZID=America/New_York:'+objEvent.EndDateTime.formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'')+'\n';
            strMetadata += 'END:VEVENT \n'+'END:VCALENDAR\n';        
            
            objVcalender.FileName = objEvent.Subject;
            objVcalender.FileLink = strMetadata;
                      
            return objVcalender;
        }
        catch (Exception e) {
            system.debug('Error in Export Calendar : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }
        
    }
    
        /*
    Method Name : getEventParticipants
    Description : This method returns list of all participants of the event.
    Parameters  : String, called from getEventParticipants, strRecordId.
    Return Type : String.
    */
    @AuraEnabled
    public static List<EventParticipant> getEventParticipants(String strRecordId) {
        try{
            Set<Id> setParticipantIds = new Set<Id>();
            List<EventParticipant> lstEventParticipants = new List<EventParticipant>();
            
            for(EventRelation objEventRelation : [Select Id,RelationId from EventRelation where EventId =: strRecordId]){
                setParticipantIds.add(objEventRelation.RelationId);
            }
            
            for(Contact objContact : [Select Id,Name,Email from Contact where Id IN :setParticipantIds]){
                EventParticipant objEventParticipant = new EventParticipant();
                objEventParticipant.Name = objContact.Name;
                objEventParticipant.Email = objContact.Email;
                lstEventParticipants.add(objEventParticipant);
            }
            
            for(User objUser: [Select Id,Name,Email from User where Id IN :setParticipantIds]){
                EventParticipant objEventParticipant = new EventParticipant();
                objEventParticipant.Name = objUser.Name;
                objEventParticipant.Email = objUser.Email;
                lstEventParticipants.add(objEventParticipant);
            }
            
            return lstEventParticipants;
        }
        catch (Exception e) {
            system.debug('Error in getEventParticipants : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }
        
    }
    
        /*
    Method Name : createEvent
    Description : This method creates an event.
    Parameters  : String, called from createEvent, strEvent.
    Return Type : String.
    */
    @AuraEnabled
    public static String createEvent(String strEvent) {
        try{
            System.debug('strEvent='+strEvent);
            Event objEvent = new Event();
            objEvent = (Event) JSON.deserialize(strEvent, event.class);
            
            if(objEvent != null){
                
                //Set event as public by default
                objEvent.IsVisibleInSelfService = true;
                objEvent.Event_Type__c = 'External';
                insert objEvent;
                
                //Add current user to Event Relation
                EventRelation objEventRelation = new EventRelation();
                objEventRelation.EventId = objEvent.Id;
                objEventRelation.RelationId = UserInfo.getUserId();
                objEventRelation.Status ='Accepted';
            }
            
            return objEvent.Id;
        }
        catch (Exception e) {
            system.debug('Error in CreateEvent : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }
        
    }
    
    
        /*
    Method Name : getEvent
    Description : This method returns Event object record.
    Parameters  : String, called from getEvent, strRecordId.
    Return Type : Event.
    */
    @AuraEnabled
    public static EventWrapper getEvent(String strRecordId) {
        try{
            help_Infa_Custom_Label__mdt metadatalabel = getmetadatarecords();
            
            Event objEvent = new Event();
            EventWrapper objEventWrapper = new EventWrapper();
            List<EventOption> lstEventOptions = new List<EventOption>();
            Map<Id,CollaborationGroup> colabmap = new Map<Id,CollaborationGroup>([Select Id, Name from CollaborationGroup]); //to get groupName
            
            List<Event> lstEvents = [Select Id,Subject,ActivityDate,Description,StartDateTime,EndDateTime,Location,IsVisibleInSelfService,Type,User_Group_Id__c
                                     from Event where Id =: strRecordId];
            
            if(!lstEvents.isEmpty()){
                objEvent = lstEvents[0];
                
                //Monday, Jan 03, 2022 12:00 PM to 2:00 PM PST
                DateTime startDT = objEvent.StartDateTime;
                DateTime endDT = objEvent.EndDateTime;
                
                objEventWrapper.FormattedDateTime = startDT.format('EEEE, MMM d, y hh:mm a') + ' to ' + endDT.format('EEEE, MMM d, y hh:mm a') + ' '+startDT.format('z') ;
                             
                //Now, we check if the event is already liked by the user.
                List<Community_Interactions__c> lstCommunityInteractLike = [Select Id from Community_Interactions__c where Id__c = :objEvent.Id and User__c = :UserInfo.getUserId() and Type__c = 'Event' and IsLiked__c = true LIMIT 1];
                EventOption objEventOption = new EventOption();
                objEventOption.Name = 'Event Like';
                objEventOption.ToggleSwitch = !lstCommunityInteractLike.isEmpty() ? true : false;
                lstEventOptions.add(objEventOption);
                
                //Now, we check if the event is already followed by the user.
                List<Community_Interactions__c> lstCommunityInteracFollow = [Select Id from Community_Interactions__c where Id__c = :objEvent.Id and User__c = :UserInfo.getUserId() and Type__c = 'Event' and Follow__c =true LIMIT 1 ];
                objEventOption = new EventOption();
                objEventOption.Name = 'Event Follow';
                objEventOption.ToggleSwitch = !lstCommunityInteracFollow.isEmpty() ? true : false;
                lstEventOptions.add(objEventOption);
                
                objEventWrapper.objEvent = objEvent;
                //to Fetch Group Name                
                if(objEvent.User_Group_Id__c !=null){
                    if(colabmap.keyset().contains(objEvent.User_Group_Id__c)){
                        objEventWrapper.groupName = colabmap.get(objEvent.User_Group_Id__c).Name;
                    }                    
                }
                
                //to Fetch Event Status
                if(objEvent.StartDateTime < System.now()){
                    objEventWrapper.EventStatus = metadatalabel.EventEndStatus__c;
                }
                else{
                    objEventWrapper.EventStatus = metadatalabel.EventYetToHappen__c;
                }
                
                objEventWrapper.lstEventOptions = lstEventOptions;
                
            }
            
            return objEventWrapper;
        }
        catch (Exception e) {
            system.debug('Error in getEvent : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }
        
    }
    
        /*
    Method Name : likeEvent
    Description : This method creates a record on community interactions indicating that the user has liked the event.
    Parameters  : (Id, String), called from likeEvent, (recordId, action).
    Return Type : objEventOption.
    */
    @AuraEnabled
    public static EventOption likeEvent(Id recordId, String action) {
        try{
            EventOption objEventOption = new EventOption();
            
            if(UserInfo.getUserType() != 'Guest' && recordId.getSObjectType().getDescribe().getName() == 'Event' && String.isNotBlank(action)){
                
                Community_Interactions__c objCommunityInteraction = new Community_Interactions__c();
                List<Community_Interactions__c> lstCommunityInteractionsToUpsert = new List<Community_Interactions__c>();
                List<Community_Interactions__c> lstCommunityInteractions = [Select Id__c,Type__c,IsLiked__c from Community_Interactions__c where Id__c = :recordId and User__c = :UserInfo.getUserId() and Type__c = 'Event' LIMIT 1];
                
                if(action == 'Like'){
                    
                    if(lstCommunityInteractions.isEmpty()){
                        
                        //Create a like record for the event and user.
                        objCommunityInteraction.Id__c = recordId;
                        objCommunityInteraction.Type__c = 'Event';
                        objCommunityInteraction.IsLiked__c = true;
                        objCommunityInteraction.User__c  = UserInfo.getUserId();
                        lstCommunityInteractionsToUpsert.add(objCommunityInteraction);
                    }
                    else{
                        objCommunityInteraction = lstCommunityInteractions[0];
                        
                        //Update like on the existing  for the event and user.
                        if(!objCommunityInteraction.IsLiked__c){
                            objCommunityInteraction.IsLiked__c = true;
                            lstCommunityInteractionsToUpsert.add(objCommunityInteraction);
                        }
                    }
                    
                    if(!lstCommunityInteractionsToUpsert.isEmpty()){
                        upsert lstCommunityInteractionsToUpsert;
                        objEventOption.Name = 'Event Like';
                        objEventOption.ToggleSwitch = true;
                    }
                }
                else if(action == 'UnLike'){
                    if(lstCommunityInteractions.isEmpty()){
                        
                        //Create a like record for the event and user.
                        objCommunityInteraction.Id__c = recordId;
                        objCommunityInteraction.Type__c = 'Event';
                        objCommunityInteraction.IsLiked__c = false;
                        objCommunityInteraction.User__c  = UserInfo.getUserId();
                        lstCommunityInteractionsToUpsert.add(objCommunityInteraction);
                    }
                    else{
                        objCommunityInteraction = lstCommunityInteractions[0];                        
                        //Update like on the existing  for the event and user.
                        if(objCommunityInteraction.IsLiked__c){
                            objCommunityInteraction.IsLiked__c = false;
                            lstCommunityInteractionsToUpsert.add(objCommunityInteraction);
                        }
                    }
                    if(!lstCommunityInteractionsToUpsert.isEmpty()){
                        upsert lstCommunityInteractionsToUpsert;
                        objEventOption.Name = 'Event Like';
                        objEventOption.ToggleSwitch = false;
                    }
                }
                
            }
            
            return objEventOption;
        }
        catch (Exception e) {
            system.debug('Error in likeEvent : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }
        
    }
    
    /*
    Method Name : followEvent
    Description : This method follows and unfollows the event.
    Parameters  : (Id, String), called from followEvent, (recordId, action).
    Return Type : objEventOption.
    */
    
    @AuraEnabled
    public static EventOption followEvent(Id recordId, String action) {
        try{
            EventOption objEventOption = new EventOption();
            
            if(UserInfo.getUserType() != 'Guest' && recordId.getSObjectType().getDescribe().getName() == 'Event' && String.isNotBlank(action)){
                
                Community_Interactions__c objCommunityInteraction = new Community_Interactions__c();
                List<Community_Interactions__c> lstCommunityInteractionsToUpsert = new List<Community_Interactions__c>();
                List<Community_Interactions__c> lstCommunityInteractions = [Select Id__c,Type__c,Follow__c  from Community_Interactions__c where Id__c = :recordId and User__c = :UserInfo.getUserId() and Type__c = 'Event' LIMIT 1];
                
                if(action == 'Follow'){
                    
                    if(lstCommunityInteractions.isEmpty()){
                        
                        //Create a Follow record for the event and user.
                        objCommunityInteraction.Id__c = recordId;
                        objCommunityInteraction.Type__c = 'Event';
                        objCommunityInteraction.Follow__c  = true;
                        objCommunityInteraction.User__c  = UserInfo.getUserId();
                        lstCommunityInteractionsToUpsert.add(objCommunityInteraction);
                    }
                    else{
                        objCommunityInteraction = lstCommunityInteractions[0];
                        
                        //Update Follow on the existing  for the event and user.
                        if(!objCommunityInteraction.Follow__c){
                            objCommunityInteraction.Follow__c  = true;
                            lstCommunityInteractionsToUpsert.add(objCommunityInteraction);
                        }
                    }
                    
                    if(!lstCommunityInteractionsToUpsert.isEmpty()){
                        upsert lstCommunityInteractionsToUpsert;
                        objEventOption.Name = 'Event Follow';
                        objEventOption.ToggleSwitch = true;
                    }
                }
                else if(action == 'UnFollow'){
                    if(lstCommunityInteractions.isEmpty()){                        
                        //Create a Follow record for the event and user.
                        objCommunityInteraction.Id__c = recordId;
                        objCommunityInteraction.Type__c = 'Event';
                        objCommunityInteraction.Follow__c  = false;
                        objCommunityInteraction.User__c  = UserInfo.getUserId();
                        lstCommunityInteractionsToUpsert.add(objCommunityInteraction);
                    }
                    else{
                        objCommunityInteraction = lstCommunityInteractions[0];                        
                        //Update Follow on the existing  for the event and user.
                        if(objCommunityInteraction.Follow__c){
                            objCommunityInteraction.Follow__c  = false;
                            lstCommunityInteractionsToUpsert.add(objCommunityInteraction);
                        }
                    }
                    if(!lstCommunityInteractionsToUpsert.isEmpty()){
                        upsert lstCommunityInteractionsToUpsert;
                        objEventOption.Name = 'Event Follow';
                        objEventOption.ToggleSwitch = false;
                    }
                }
                
            }
            
            return objEventOption;
        }
        catch (Exception e) {
            system.debug('Error in likeEvent : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }
        
    }
    
        
    /*@AuraEnabled
    public static EventOption followEvent(Id recordId, String action) {
        try{
            EventOption objEventOption = new EventOption();
            
            if(UserInfo.getUserType() != 'Guest' && recordId.getSObjectType().getDescribe().getName() == 'Event' && String.isNotBlank(action)){
                
                Id eventRecordId = [Select Id from Event where Id =: recordId]?.Id;
                List<EntitySubscription> lstEntitySubscriptions = [Select Id from EntitySubscription where ParentId =: eventRecordId AND SubscriberId =: UserInfo.getUserId()];
                
                if(action == 'Follow'){
                    
                    if(lstEntitySubscriptions.isEmpty()){    
                        //Create a record on EntitySubscription
                        EntitySubscription objEntitySubscription = new EntitySubscription();
                        objEntitySubscription.ParentId = recordId;
                        objEntitySubscription.SubscriberId = UserInfo.getUserId();
                        insert objEntitySubscription;
                        objEventOption.Name = 'Event Follow';
                        objEventOption.ToggleSwitch = true;
                    }
                    
                }
                else if(action == 'UnFollow'){
                    
                    if(!lstEntitySubscriptions.isEmpty()){
                        EntitySubscription objEntitySubscription = lstEntitySubscriptions[0];
                        delete objEntitySubscription;
                        objEventOption.Name = 'Event Follow';
                        objEventOption.ToggleSwitch = false;
                    }
                }
                
            }
            
            return objEventOption;
        }
        catch (Exception e) {
            system.debug('Error in followEvent : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }
        
        
    }*/
    
        /*
    Method Name : getEventAttendeeStatus
    Description : This method return  the event attendees by status (accepted, declined & no response) and their corresponding count.
    Parameters  : Id, called from getEventAttendeeStatus, recordId.
    Return Type : List<EventAttendeeStatus>.
    */
    @AuraEnabled
    public static List<EventAttendeeStatus> getEventAttendeeStatus(Id recordId) {
        try{
            List<EventAttendeeStatus> lstEventAttendeeStatus = new List<EventAttendeeStatus>();
            
            if(recordId.getSObjectType().getDescribe().getName() == 'Event'){
                
                AggregateResult[] groupedResults = [SELECT Count(Id) c,Status FROM EventRelation where EventId =:recordId and Status != null GROUP BY Status];
                
                for(AggregateResult ar : groupedResults){
                    EventAttendeeStatus objEventAttendeeStatus = new EventAttendeeStatus();
                    objEventAttendeeStatus.strStatus = (String)ar.get('Status');
                    objEventAttendeeStatus.intCount = (Integer)ar.get('c');
                    lstEventAttendeeStatus.add(objEventAttendeeStatus);
                }
            }
            
            return lstEventAttendeeStatus;
        }
        catch (Exception e) {
            system.debug('Error in getEventAttendeeStatus : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }
        
    }
    
    /*
Method Name : getRelatedEvents
Description : This method fetches and returns the related events specific to the event.
Parameters  : Id, called from getRelatedEvents, recordId.
Return Type : List<Event>.
*/
    @AuraEnabled
    public static List<Event> getRelatedEvents(Id recordId) {
        try{
            List<Event> lstRelatedEvents = new List<Event>();
            List<Event> lstEvents = [Select Id,IsVisibleInSelfService from Event where Id =: recordId];
            
            if(!lstEvents.isEmpty()){
                lstRelatedEvents = [Select Id,Subject,Description,StartDateTime,EndDateTime,Location,IsVisibleInSelfService from Event where IsVisibleInSelfService = :lstEvents[0].IsVisibleInSelfService AND IsChild = false order by createddate desc LIMIT 3];
            }
            
            
            return lstRelatedEvents;
            
        }
        catch (Exception e) {
            system.debug('Error in getRelatedEvents : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }
        
        
    }
    
    public class DisplayActionItems{
        @AuraEnabled
        public String JoinEventStatus {get; set;}
        @AuraEnabled
        public String ActivityDateStatus {get; set;}
        @AuraEnabled
        public String EditDeleteDisplay  {get; set;}
        @AuraEnabled
        public String isOwner  {get; set;}
        @AuraEnabled
        public String UserGroupId  {get; set;} //T1
    }
    
    /* Wrapper class to hold information about vcalendar */
    public class vCalendar{
        @AuraEnabled
        public String FileName {get; set;}       
        @AuraEnabled
        public String FileLink {get; set;}             
    }
    
    /* Wrapper class to hold information about event participant */
    public class EventParticipant{
        @AuraEnabled
        public String Name {get; set;}       
        @AuraEnabled
        public String Email {get; set;}             
    }
    
    /* Wrapper class to hold information about event option */
    public class EventOption{
        @AuraEnabled
        public String Name {get; set;}       
        @AuraEnabled
        public Boolean ToggleSwitch {get; set;}    
    }
    
    /* Wrapper class to hold information about event */
    public class EventWrapper{
        @AuraEnabled
        public Event objEvent {get; set;}   
        @AuraEnabled
        public String groupName {get; set;}
        @AuraEnabled
        public String EventStatus {get; set;}
        @AuraEnabled
        public String FormattedDateTime {get; set;}
        @AuraEnabled
        public List<EventOption> lstEventOptions {get; set;}
        
        @AuraEnabled public help_Infa_Custom_Label__mdt getmetadata =getmetadatarecords();
    }
    
    /* Wrapper class to hold information about event attendees status */
    public class EventAttendeeStatus{
        @AuraEnabled
        public String strStatus {get; set;}       
        @AuraEnabled
        public Integer intCount {get; set;}    
    }
}