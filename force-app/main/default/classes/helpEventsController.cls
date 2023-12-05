/*
* Name         :   helpEventsController
* Author       :   Deeksha Shetty
* Created Date :   11/02/2022
* Description  :   Controller class for Event Landing page and related Events in detail page of IN.

Change History
*********************************************************************************************************************
Modified By            Date            Jira No.        Description                                                Tag
*********************************************************************************************************************
Deeksha Shetty      11/02/2022      N/A             Initial version.                                              N/A
Saumya Gaikwad      29/06/2022      N/A             Added method fetchJoinedEvents                              I2RT-6453
Utkarsh Jain        19-JULY-2022    I2RT-6756       Related events under user group should be Ascending.           1
Utkarsh Jain        21-JULY-2022    I2RT-6786       Related events under user group should be Ascending.           2
Deeksha Shetty      27-July,2022    I2RT-6706       Notification criteria - Events                                 3
Deeksha Shetty      16-Aug,2022     I2RT-6906       UG-Ability for the anonymous users/authenticated users         4
                                                    to view the UG events 
Saumya Gaikwad      29/08/2022      I2RT-6601       Years shown in the Filter should be dynamic                    5   
Deeksha Shetty      24-Aug,2022     I2RT-6997       User not able to join event when he is part of the user group  6
Saumya Gaikwad      21/09/2022      I2RT-7048       Events component changes in authenticated landing page         7
Deeksha Shetty      17/10/2022      I2RT-7272       Giving option for the admin/Leader to edit the events without  8
                                                    notifying the user
Prashanth Bhat      05/09/2023.     I2RT-8834       Added logic to handle timezone offset.                         9
*/

public without sharing class helpEventsController {
    public static globalApexManager GAM = new globalApexManager();
    
    @AuraEnabled(cacheable=true)
    public static List<Event> getEvents() {
        return [Select Id,Subject, StartDateTime, EndDate, EndDateTime,CreatedBy.Name,CreatedDate, Type from Event ];
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<Event> getEventsById(String eventId) {
        return [Select Id,Subject, StartDateTime, EndDate, EndDateTime,CreatedBy.Name,CreatedDate, Type from Event where Id=:eventId];
    }
    
    //Fetching the Labels From Metadata
    @AuraEnabled(cacheable=true)
    public static help_Infa_Custom_Label__mdt getmetadatarecords(){
        try{
            help_Infa_Custom_Label__mdt recordlist = [SELECT PastEventMsg__c, EventEndStatus__c,EventJoinSuccess__c, EventYetToHappen__c, NotifyUserMsg__c,     
                                                      MailHelpText__c,helpTextTZ__c FROM help_Infa_Custom_Label__mdt 
                                                      WHERE developerName = 'helpEvents'];
            return recordlist;
        }
        Catch(Exception e){
            system.debug('Error in metadata : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());             
        }
    }
    
    //JOIN EVENT
    @AuraEnabled
    public static JoinEventWrapper addUserToEvent(String eventId, String userId){
        try {
            help_Infa_Custom_Label__mdt metadatalabel = getmetadatarecords();
            Event e = [Select Id,ActivityDate,User_Group_Id__c from Event where Id=:eventId];
            if (e.ActivityDate < System.today()){
                JoinEventWrapper wrap = new JoinEventWrapper();
                wrap.statusMessage = metadatalabel.EventEndStatus__c;
                wrap.returnMessage = 'Past Event';
                return wrap;
            }
            else{
                /*Tag 4 starts */
                if(e.User_Group_Id__c!=null){                    
                    string ugId = e.User_Group_Id__c;
                    List<CollaborationGroupMember> mem = [SELECT Id from CollaborationGroupMember where 
                                                          CollaborationGroupId=:ugId AND MemberId=:userinfo.getUserId()]; /* Tag 6 */
                    if(mem.size()==0){
                        CollaborationGroupMember record = new CollaborationGroupMember(CollaborationGroupId=e.User_Group_Id__c,MemberId=userinfo.getUserId());
                        insert record;                        
                    }
                                       
                }
                /*Tag 4 ends */
                List<EventRelation> evlist = [Select Id,Status from EventRelation where Eventid=:eventId and RelationId=:userId ];
                List<EventRelation> updationList = new List<EventRelation>();
                if(evlist.size()>0){
                    for(EventRelation ev: evlist){
                        ev.Status = 'Accepted';
                        updationList.add(ev);
                    }
                    if(updationList.size()>0) update updationList;
                }
                else{
                    EventRelation eventRelation = new EventRelation();
                    eventRelation.EventId = eventId;
                    eventRelation.RelationId = userId;
                    eventRelation.Status = 'Accepted';  //when user joins event, he is accepting the invite 
                    insert eventRelation;
                }
                
                
                JoinEventWrapper wrap = new JoinEventWrapper();
                wrap.statusMessage = metadatalabel.EventJoinSuccess__c;
                wrap.returnMessage = 'User Added';
                return wrap;
            }
            
        } catch (Exception e) {
            system.debug('Error in adding user to EVENT : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }
    }
    
    
    //DECLINE EVENT    
    @AuraEnabled
    public static String DeclineEvent(String recId,String userId){
        try {
            List<EventRelation> evlist = [Select Id,Status from EventRelation where Eventid=:recId and RelationId=:userId ];           
            evlist[0].Status = 'Declined';  //when user Declines event
            update evlist;
            return 'Declined';
        }
        
        catch (Exception e) {
            system.debug('Error in declining event : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }
    }
    
    
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getUserGroups(){
        try{
            String networkId = Network.getNetworkId();
            List<CollaborationGroup> lstCollaborationGroup = [Select Id, Name 
                                                              From CollaborationGroup
                                                              Where NetworkId = :networkId];
            lstCollaborationGroup.sort();
            Map<String, String> mapUserGroupIdToName = new Map<String, String>();
            for(CollaborationGroup collabGroup : lstCollaborationGroup){
                mapUserGroupIdToName.put(collabGroup.Id, collabGroup.Name);
            }
            return mapUserGroupIdToName;
        }
        Catch(Exception e){
            system.debug('Error in getting UGs : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }
        
    }
    
    
    @AuraEnabled(Cacheable=true)
    public static List<String> getEventTypePicklistValues(){
        try{
            Schema.DescribeFieldResult objFieldDescribe = Event.Type.getDescribe();
            List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
            List<String> eventTypes = new List<String>();
            for (Schema.PicklistEntry objPickList : lstPickListValues) {
                eventTypes.add(objPickList.getLabel());
                eventTypes.sort();
            }
            return eventTypes;
            
        }
        Catch(Exception e){
            system.debug('Error in Event Type Picklist values : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
        
    }
    
    @AuraEnabled
    public static filterWrappers fetchFilterAfterTabSwitch(){
        try{                                    
            Map<String, String> ugMap = new Map<String, String>();
            ugMap = getUserGroups();
            filterWrappers wrap = new filterWrappers();
            wrap.TypeFilter = getEventTypePicklistValues();
            wrap.UserGroupFilter = ugMap;                   
            return wrap;            
        }
        Catch(Exception e){
            system.debug('Error in fetchFilterAfterTabSwitch : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    public static String getSortOrder(String sortOrder){
        String sortOrderFormatted = 'DESC';
        if(String.isNotEmpty(sortOrder)){
            sortOrderFormatted = sortOrder; 
        }
        return sortOrderFormatted;
    }
    
    @AuraEnabled
    public static list<EventListWrapper> getAllEvents(String sortOrder, String searchTerm){               
        String sortOrderFormatted = getSortOrder(sortOrder);
        List<EventListWrapper> lstEventDetail = new List<EventListWrapper>();
        //this is to disable button if user has already joined that event.
        List<EventRelation> evntrelationlist = [SELECT eventId,Status FROM EventRelation where RelationId=:userinfo.getUserId()];
        Map<Id,EventRelation> evrelatiomap = new Map<Id,EventRelation>();
        for(EventRelation ev : evntrelationlist){
            evrelatiomap.put(ev.eventId,ev);
        }
        
        Map<Id,CollaborationGroup> colabmap = new Map<Id,CollaborationGroup>([Select Id, Name from CollaborationGroup]);
        String searchKey = '';
        if(String.isNotEmpty(searchTerm.trim())){
            searchKey = '%' + String.escapeSingleQuotes(searchTerm) + '%';
        }
        
        String networkId = Network.getNetworkId();
        String sitelabel = System.Label.IN_CommunityName;
        String soql;
        String eventtype = 'External';
        try{            
            soql = 'Select Id, Subject, Description, Type, Location, ActivityDate, ActivityDateTime,OwnerId, StartDateTime,Event_Type__c,User_Group_Id__c';
            soql += ' From Event Where Type!=null AND Event_Type__c=:eventtype AND IsChild=false';  //showing only all public groups                  
            //Where NetworkId =: networkId
            if(String.isNotEmpty(searchKey)){
                soql += ' AND Subject like :searchKey';
            }
            soql += ' Order By ActivityDate ' + sortOrderFormatted;
            
            List<Event> lstEvent = Database.query(soql);
            Set<Id> privateGroupId = new Set<Id>();
            Set<Id> publicGroupId = new Set<Id>();
            
             /* Tag 4 starts*/
            
            //this is to show user only the private group events that they are part of.
            if(userinfo.getUserType()!='Guest'){
                List<CollaborationGroupMember> privategrouplist = [SELECT CollaborationGroupId FROM 
                                                                   CollaborationGroupMember where CollaborationGroup.CollaborationType='Private'
                                                                   AND memberid=:userinfo.getUserId()];
                if(privategrouplist.size()>0){
                    for(CollaborationGroupMember cm : privategrouplist){
                        privateGroupId.add(cm.CollaborationGroupId);
                    }
                    if(privateGroupId.size()>0){
                        List<Event> eventlistforprivategroups =[Select Id, Subject, Description, Type, Location, ActivityDate, ActivityDateTime,OwnerId, 
                                                                StartDateTime,Event_Type__c,User_Group_Id__c From Event 
                                                                Where Type!=null AND IsChild=false AND User_Group_Id__c IN:privateGroupId];
                        if(eventlistforprivategroups.size()>0) lstEvent.addAll(eventlistforprivategroups); 
                    }                                                   
                }
                
            }
            //this is to show all users public group events.
            
            List<CollaborationGroup> publicGroupList = [SELECT Id FROM CollaborationGroup WHERE CollaborationType='Public'];
            if(publicGroupList.size()>0){
                for(CollaborationGroup cg : publicGroupList){
                    publicGroupId.add(cg.Id);
                }
                if(publicGroupId.size()>0){
                    List<Event> eventForPublicUG =[Select Id, Subject, Description, Type, Location, ActivityDate, ActivityDateTime,OwnerId, 
                                                   StartDateTime,Event_Type__c,User_Group_Id__c From Event 
                                                   Where Type!=null AND IsChild=false AND User_Group_Id__c IN:publicGroupId];                    
                    if(eventForPublicUG.size()>0) lstEvent.addAll(eventForPublicUG);                    
                }                                
            }
            
            /* Tag 4 ends*/
            
            
            for(Event evntObj : lstEvent){
                EventListWrapper evntDetail = new EventListWrapper();
                evntDetail.Id = evntObj.Id;
                evntDetail.Subject = evntObj.Subject;
                evntDetail.Description = evntObj.Description;
                evntDetail.Type = evntObj.Type;
                evntDetail.Location = evntObj.Location;
                DateTime dt = evntObj.StartDateTime;
                evntDetail.TodayDate = System.now().format('YYYY-MM-dd HH:mm:ss');
                evntDetail.FilterDate = dt.format('YYYY-MM-dd HH:mm:ss');
                evntDetail.ActivityDate = dt.format('EEE')+', '+dT.day()+' '+dT.format('MMM')+' '+dT.year();
                evntDetail.ActivityTime = dt.format('hh:mm a z');      
                evntDetail.Link = sitelabel+'eventdetails?id=' + evntObj.Id;    
                evntDetail.MonthYear = dt.month() + '' + dt.year();            
                /* Tag 5 Starts */
                evntDetail.month =  String.valueOf(dt.month());
                evntDetail.year =  String.valueOf(dt.year());             
                /* Tag 5 Ends */
                if(evrelatiomap.keyset().contains(evntObj.Id) && evrelatiomap.get(evntObj.Id).Status=='Accepted' ){
                    evntDetail.disablebutton = true;
                }
                
                if(evntObj.User_Group_Id__c !=null){
                    if(colabmap.keyset().contains(evntObj.User_Group_Id__c)){
                        evntDetail.UserGroupData = colabmap.get(evntObj.User_Group_Id__c).Name;
                    }                    
                }
                
                if(evntObj.StartDateTime < System.now()){
                    evntDetail.disablebutton = true;
                }
                
                if(evntObj.OwnerId == userinfo.getUserId()){
                    evntDetail.disablebutton = true;
                }
                
                evntDetail.EventType = evntObj.Event_Type__c;
                lstEventDetail.add(evntDetail);
            }
        } catch(Exception e){
            system.debug('Error in getAll Events: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());  
        }
        return lstEventDetail; 
    }
    
    @AuraEnabled
    public static list<EventListWrapper> getMyEvents(String userId, String sortOrder, String searchTerm){
        String sortOrderFormatted = getSortOrder(sortOrder);
        List<EventListWrapper> lstEventDetail = new List<EventListWrapper>();
        Map<Id,CollaborationGroup> colabmap = new Map<Id,CollaborationGroup>([Select Id, Name from CollaborationGroup]);        
        String searchKey = '';
        if(String.isNotEmpty(searchTerm.trim())){
            searchKey = '%' + String.escapeSingleQuotes(searchTerm) + '%';
        }
        
        String networkId = Network.getNetworkId();
        
        String sitelabel = System.Label.IN_CommunityName;
        try{
            String accstatus = 'Accepted';            
            String soql = 'Select Id, EventId, RelationId,Status, Event.Subject, Event.Description, Event.Type, Event.Location,Event.Event_Type__c,';
            soql += ' Event.ActivityDate, Event.ActivityDateTime, Event.StartDateTime,Event.User_Group_Id__c';
            soql += ' From EventRelation'; 
            soql += ' Where RelationId=:userId AND Event.Event_Type__c!=null AND Status=:accstatus';
            if(String.isNotEmpty(searchKey)){
                soql += ' AND Event.Subject like:searchKey';
            }
            soql += ' Order By Event.ActivityDate ' + sortOrderFormatted;
            List<EventRelation> lstEventRelation = Database.query(soql);
            for(EventRelation evntRelation : lstEventRelation){
                EventListWrapper evntDetail = new EventListWrapper();
                evntDetail.Id = evntRelation.EventId;      
                evntDetail.Subject = evntRelation.Event.Subject;
                evntDetail.Description = evntRelation.Event.Description;
                evntDetail.Type = evntRelation.Event.Type;
                evntDetail.Location = evntRelation.Event.Location;
                DateTime dt = evntRelation.Event.StartDateTime;
                evntDetail.FilterDate = dt.format('YYYY-MM-dd HH:mm:ss');
                evntDetail.TodayDate = System.now().format('YYYY-MM-dd HH:mm:ss');
                evntDetail.ActivityDate = dt.format('EEE')+', '+dt.day()+' '+dt.format('MMM')+' '+dt.year();
                evntDetail.ActivityTime = dt.format('hh:mm a z');
                evntDetail.disablebutton = true;
                
                evntDetail.Link = sitelabel+'eventdetails?id=' + evntRelation.Event.Id;                               
                
                if(evntRelation.Event.User_Group_Id__c !=null){
                    if(colabmap.keyset().contains(evntRelation.Event.User_Group_Id__c)){
                        evntDetail.UserGroupData = colabmap.get(evntRelation.Event.User_Group_Id__c).Name;
                    }                    
                }
                evntDetail.disablebutton = true;                
                lstEventDetail.add(evntDetail);
                
            }
        } catch(Exception e){
            system.debug('Error in getMY Events: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage()); 
        }
        return lstEventDetail; 
    }
    
    @AuraEnabled
    public static UpcomingEventsWrapper getUpcomingEventsByUser(String userId, String sortOrder, String startDate, String endDate,Boolean onLoad){
        UpcomingEventsWrapper upEventWrapper = new UpcomingEventsWrapper();        
        String sortOrderFormatted = getSortOrder(sortOrder);
        List<EventListWrapper> upcomingEventsLst = new List<EventListWrapper>();
        List<EventListWrapper> userEventsLst = new List<EventListWrapper>();
        Map<Id,CollaborationGroup> colabmap = new Map<Id,CollaborationGroup>([Select Id, Name from CollaborationGroup]);        
        String networkId = Network.getNetworkId();        
        Date myDate = Date.valueOf(startDate);
        Date myEndDate = Date.valueOf(endDate); //Tag-7 
        String startDateTime;
        //Tag-9
        if(!onLoad){
            startDateTime = String.valueOfGmt(DateTime.newInstance(myDate.year(), mydate.month(), mydate.day())).replace(' ','T')+'Z' ; //To handle date received in yyyy-mm-dd format to convert it to UTC on specific day click
        }
        else if(onLoad){
            startDateTime = DateTime.valueOf(startDate.replace('T',' ').replace('Z','')).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); //To prevent the Time data loss convert exact time UTC along with date
        }
     // string endDateTime = DateTime.newInstance(myEndDate.year(), myEndDate.month(), myEndDate.day()).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); //Tag-7
        String endDateTime = DateTime.valueOf(endDate.replace('T',' ').replace('Z','')).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); //To prevent the Time data loss
        startDate = DateTime.newInstance(myDate.year(), mydate.month(), mydate.day()).format('yyyy-MM-dd');
        endDate = DateTime.newInstance(myEndDate.year(), myEndDate.month(), myEndDate.day()).format('yyyy-MM-dd'); //Tag-7

        try{         
            String myEventsSOQL = 'Select Id, EventId,Event.WhoId, RelationId,Status, Event.Subject, Event.Description, Event.Type, Event.Location,Event.Event_Type__c,';
            myEventsSOQL += ' Event.ActivityDate, Event.ActivityDateTime, Event.StartDateTime,Event.User_Group_Id__c, Event.EndDate, Event.EndDateTime ';
            myEventsSOQL += ' From EventRelation'; 
            myEventsSOQL += ' Where  Event.Event_Type__c !=null and Event.IsChild = false and Status = \'Accepted\' and RelationId = \'' + userId + '\'';
            String condition = '';
            if(startDate == '' || startDate == null) condition += ' AND Event.ActivityDate >= TODAY'; 
            else condition += ' AND Event.ActivityDate <= '+ startDate + ' AND Event.EndDate >= '+ startDate;
            myEventsSOQL += condition + ' Order By Event.StartDateTime ' + sortOrderFormatted;
            myEventsSOQL += ' LIMIT 10  OFFSET 0 ';
            String upComEventsSOQL = 'Select Id, WhoId, Subject, Description, Type, Location, Event_Type__c, ';
            upComEventsSOQL += ' ActivityDate, ActivityDateTime, StartDateTime, Enddate, enddatetime, (Select Id,Status,RelationId From EventRelations)';
            upComEventsSOQL += ' From Event'; 
            upComEventsSOQL += ' Where  Event_Type__c = \'External\' and IsChild = false and ActivityDateTime >= ' + startDateTime + ' and ActivityDateTime <= ' + endDateTime;
            upComEventsSOQL += ' Order By StartDateTime ' + sortOrderFormatted;
            upComEventsSOQL += ' LIMIT 50  OFFSET 0 '; 
            List<EventRelation> lstMyEventRelation = Database.query(myEventsSOQL);
            List<Event> lstUpComEventRelation = Database.query(upComEventsSOQL);
            upEventWrapper.userEvents = prepMyEventsList(lstMyEventRelation, userId, startDate);// endDate
            upEventWrapper.upcomingEvents = prepUpComEventsList(lstUpComEventRelation, startDate, userId);
            
        } catch(Exception e){
            GAM.CreateExceptionRecords('getUpcomingEventsByUser', e.GetMessage() + e.getStackTraceString(), userinfo.getUserId());
        }
        return upEventWrapper; 
    }
    
    public static List<EventListWrapper> prepMyEventsList(List<EventRelation> eventRecords,String userId, String selectedDate){//, String endDate
        String sitelabel = System.Label.IN_CommunityName;
        List<EventListWrapper> eventsLst = new List<EventListWrapper>();
        for(EventRelation evntRelation : eventRecords){
            EventListWrapper evntDetail = new EventListWrapper();
            evntDetail.Id = evntRelation.EventId;
            evntDetail.Subject = evntRelation.Event.Subject; 
            evntDetail.Description = evntRelation.Event.Description;
            evntDetail.Type = evntRelation.Event.Type;
            evntDetail.Location = evntRelation.Event.Location;
            
            DateTime dtStart = evntRelation.Event.ActivityDateTime;
            DateTime dtEnd = evntRelation.Event.EndDateTime;
            
            evntDetail.FilterDate = dtStart.year()+'-'+dtStart.month()+'-'+dtStart.day();
            evntDetail.ActivityDate = dtStart.format('EEE')+', '+ getOrdinal(dtStart.day()) +' '+dtStart.format('MMM')+' '+dtStart.year();
            evntDetail.ActivityTime = dtStart.format('hh:mm a')+' '+ dtStart.format('z');
            evntDetail.disablebutton = true;               
            evntDetail.Link = sitelabel+'eventdetails?id=' + evntRelation.Event.Id;               
            date userSelectedDate = selectedDate == null ? date.today() : date.valueOf(selectedDate); 
            
            if(evntRelation.RelationId == userId && evntRelation.Status == 'Accepted' && eventsLst.size() < 5){
                eventsLst.add(evntDetail);
            }
        }
        return eventsLst;
    }
    
    public static List<EventListWrapper> prepUpComEventsList(List<Event> eventRecords, String selectedDate, String userId){
        System.debug('prepUpComEventsList =' +eventRecords);
        String sitelabel = System.Label.IN_CommunityName;
        List<EventListWrapper> eventsLst = new List<EventListWrapper>();
        for(Event evnt : eventRecords){
            EventListWrapper evntDetail = new EventListWrapper();
            Boolean isEventAcceptedByUser = false;
            
            for(EventRelation er: evnt.EventRelations){
                if(er.RelationId == userId){
                    if(er.Status == 'Accepted'){
                        isEventAcceptedByUser = true;
                        break;
                    }
                }
            }
            evntDetail.Id = evnt.Id;
            evntDetail.IsFollowing = isEventAcceptedByUser;
            evntDetail.Subject =evnt.Subject;
            evntDetail.Description = evnt.Description;
            evntDetail.Type = evnt.Type;
            evntDetail.Location = evnt.Location;
            DateTime dt = evnt.ActivityDateTime;
            evntDetail.FilterDate = dt.year()+'-'+dt.month()+'-'+dt.day();
            evntDetail.ActivityDate = dt.format('EEE')+', '+ getOrdinal(dt.day()) +' '+dt.format('MMM')+' '+dt.year();
            evntDetail.ActivityTime = dt.format('hh:mm a')+' '+ dt.format('z');
            evntDetail.disablebutton = true;               
            evntDetail.Link = sitelabel+'eventdetails?id=' + evnt.Id;               
            date userSelectedDate = selectedDate == null ? date.today() : date.valueOf(selectedDate); 

            if(dt.date() >= date.today() && eventsLst.size() < 5 && !isEventAcceptedByUser){
                eventsLst.add(evntDetail);
            }  
        }
        
        return eventsLst;
    }
    
    public static string getOrdinal(integer i){
        string num = string.valueof(i);
        string suffix = 'th';
        string ordinal = '';
        i = integer.valueof(num.right(2));
        if(10 < i && i < 14) {
            ordinal =  num + suffix;
        }else{
            string onesDigit = num.right(1);
            if(onesDigit == '1'){
                suffix = 'st';
            }else if(onesDigit == '2'){
                suffix = 'nd';
            }else if(onesDigit == '3'){
                suffix = 'rd';
            }
            ordinal = num+suffix;
        }
        return ordinal;
    }
    
    /*@AuraEnabled
public static list<EventListWrapper> getRecommendedEvents(String user, String sortOrder, String searchTerm){
return getAllEvents(sortOrder, searchTerm);
}*/
    
    
    /*
Method Name : getRelatedEvents
Description : This method fetches and returns the related events specific to the event.
Parameters  : Id, called from getRelatedEvents, recordId.
Return Type : List<Event>.
*/
    @AuraEnabled
    public static List<EventListWrapper> getRelatedEvents(Id recordId) {
        try{
            Id currentUserProfileId = UserInfo.getProfileId();        
            String profileName = [SELECT Name FROM Profile WHERE Id =: currentUserProfileId].Name; //Retrieve profile name
            
            List<Event> lstRelatedEvents = new List<Event>();
            String sitelabel = System.Label.IN_CommunityName;
            List<Event> lstEvents = [Select Id,IsVisibleInSelfService from Event where Id =: recordId];
            List<EventListWrapper> lstEventDetail = new List<EventListWrapper>();
            Map<String,EventRelation> evntrelationlist = new Map<String,EventRelation>([SELECT Status,eventId FROM EventRelation where RelationId=:userinfo.getUserId()]);
            Map<Id,CollaborationGroup> colabmap = new Map<Id,CollaborationGroup>([Select Id, Name from CollaborationGroup]);
            
            if(!lstEvents.isEmpty()){
                lstRelatedEvents = [Select Id,Subject,Description,StartDateTime,Type,ActivityDate,User_Group_Id__c,
                                    EndDateTime,Location,IsVisibleInSelfService,Event_Type__c from Event 
                                    where IsVisibleInSelfService = :lstEvents[0].IsVisibleInSelfService AND Type!=null
                                    AND IsChild = false AND Event_Type__c!=null order by ActivityDate desc LIMIT 3];
            }
            for(Event evntObj : lstRelatedEvents){
                EventListWrapper evntDetail = new EventListWrapper();
                evntDetail.Id = evntObj.Id;  
                evntDetail.Subject = evntObj.Subject;
                evntDetail.Description = evntObj.Description;
                evntDetail.Type = evntObj.Type;
                evntDetail.Location = evntObj.Location;
                DateTime dt = evntObj.StartDateTime;
                evntDetail.FilterDate = dt.year()+'-'+dt.month()+'-'+dt.day();
                evntDetail.ActivityDate = dt.format('EEE')+', '+dT.day()+' '+dT.format('MMM')+' '+dT.year();
                evntDetail.ActivityTime = dt.format('hh:mm a z');                
                evntDetail.Link = sitelabel+'eventdetails?id=' + evntObj.Id;
                
                
                if(evntObj.User_Group_Id__c !=null){
                    if(colabmap.keyset().contains(evntObj.User_Group_Id__c)){
                        evntDetail.UserGroupData = colabmap.get(evntObj.User_Group_Id__c).Name;
                    }                    
                }
                if(evntrelationlist.keyset().contains(evntObj.Id) && evntrelationlist.get(evntObj.Id).Status=='Accepted' ){
                    evntDetail.disablebutton = true;
                }
                if(userinfo.getUserType() == 'Guest'){
                    evntDetail.disablebutton = true;
                }
                if(evntObj.StartDateTime < System.today()){
                    evntDetail.disablebutton = true;
                }
                
                
                evntDetail.EventType = evntObj.Event_Type__c;
                lstEventDetail.add(evntDetail);
            }
            
            
            return lstEventDetail;
            
        }
        Catch(Exception e){
            system.debug('GET related events: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static EventListWrapper ModifyEvent(Id eventId) {
        try{
            List<Event> modifyEvents = [Select Id,Subject,Description,StartDateTime,Type,ActivityDate,User_Group_Id__c,
                                        EndDateTime,Location,IsVisibleInSelfService,Event_Type__c from Event 
                                        where Id=:eventId];
            EventListWrapper evntDetail = new EventListWrapper();
            if(modifyEvents.size()>0){
                for(Event evntObj: modifyEvents){                
                    evntDetail.Id = evntObj.Id;
                    evntDetail.Subject = evntObj.Subject;
                    evntDetail.Description = evntObj.Description;
                    evntDetail.Type = evntObj.Type;
                    evntDetail.Location = evntObj.Location;
                    evntDetail.StartDateTime = evntObj.StartDateTime;
                    evntDetail.EndDateTime = evntObj.EndDateTime;                
                }
            }        
            return evntDetail;
        }
        Catch(Exception e){
            system.debug('Modify Events: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }
        
    }
    
    
    @AuraEnabled
    public static String saveModifiedEvent(String sub,String descrip,Datetime startdt,Datetime endt, String loc,String type,String eventId,Boolean notifyUser) {
        try{
            Event modifiedList = [Select Id,Subject,Description,StartDateTime,Type,ActivityDate,User_Group_Id__c,Event_type__c,
                                  EndDateTime,Location from Event 
                                  where Id=:eventId];            
            modifiedList.Subject = sub!= null ? sub : modifiedList.Subject;
            modifiedList.Description = descrip!= null ? descrip : modifiedList.Description;
            modifiedList.StartDateTime = startdt!= null ? startdt : modifiedList.StartDateTime;           
            modifiedList.EndDateTime = endt!= null ? endt : modifiedList.EndDateTime;
            modifiedList.Location = loc!= '' ? loc : modifiedList.Location;
            modifiedList.Type = type!= null ? type : modifiedList.Type;
            update modifiedList;
            
            /* Tag 8 starts*/
            if(modifiedList.User_Group_Id__c!=null && notifyUser){
                helpGroupsController.sendMailPostEventCreation(modifiedList.User_Group_Id__c,modifiedList.Id,'Modify'); //Tag 3 - send Mail for User Group
            }
            else if(modifiedList.Event_type__c=='External' && notifyUser){
                INSendGridController.sendEmailOnExternalEvents(modifiedList.Id); // Send Mail for External Event
            }
            else{
                System.debug('Notify User is Not Enabled');
            }
            
            List<EventRelation> evntrelationlist = [SELECT status FROM EventRelation where eventId=:eventId AND Status ='New'];
            if(evntrelationlist.size()>0){
                for(EventRelation er:evntrelationlist ){
                    er.status = 'Accepted';
                }
                update evntrelationlist;                
            }
            /* Tag 8 ends*/
                       
            return modifiedList.Id;
        }
        catch (Exception e) {
            system.debug('Error in saving Modified Events : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static String deleteEvent(String eventId) {
        try{
            Event deleteList = [Select Id from Event where Id=:eventId];
            if(deleteList!=null){
                delete deleteList;
            }                                    
            return 'Deleted';
        }
        catch (Exception e) {
            system.debug('Error in Delete Event : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }
        
    }
    
    
    @AuraEnabled
    public static List<EventListWrapper> getGroupRelatedEvents(string recordId) {
        try{
            List<Event> lstRelatedEvents = new List<Event>();
            String sitelabel = System.Label.IN_CommunityName;
            Id currentUserProfileId = UserInfo.getProfileId();        
            String profileName = [SELECT Name FROM Profile WHERE Id =: currentUserProfileId].Name; //Retrieve profile name
            List<Event> lstEvents = new list<Event> (); 
            List<EventListWrapper> lstEventDetail = new List<EventListWrapper>();
            Map<String,EventRelation> evntrelationlist = new Map<String,EventRelation>([SELECT eventId FROM EventRelation where RelationId=:userinfo.getUserId()]);
            Map<Id,CollaborationGroup> colabmap = new Map<Id,CollaborationGroup>([Select Id, Name from CollaborationGroup]);
            // <Tag - 01 - start>
            lstEvents = [Select Id,Subject,Description,StartDateTime,Type,ActivityDate,User_Group_Id__c,EndDateTime,Location,IsVisibleInSelfService,Event_Type__c from Event WHERE User_Group_Id__c =:recordId AND Type!=null AND IsChild = false AND ActivityDate >= :System.today() order by ActivityDate ASC LIMIT 6];
            // <Tag - 01 - end>
            if(!lstEvents.isEmpty()){
                for(Event evntObj : lstEvents){
                    EventListWrapper evntDetail = new EventListWrapper();
                    evntDetail.Id = evntObj.Id;      
                    evntDetail.Subject = evntObj.Subject;
                    evntDetail.Description = evntObj.Description;
                    evntDetail.Type = evntObj.Type;
                    evntDetail.Location = evntObj.Location;
                    DateTime dt = evntObj.StartDateTime;
                    evntDetail.FilterDate = dt.year()+'-'+dt.month()+'-'+dt.day();
                    evntDetail.ActivityDate = dt.format('EEE')+', '+dT.day()+' '+dT.format('MMM')+' '+dT.year();
                    evntDetail.ActivityTime = dt.format('hh:mm a z');
                    evntDetail.Link = sitelabel+'eventdetails?id=' + evntObj.Id;
                    if(evntObj.User_Group_Id__c !=null){
                        evntDetail.UserGroupData = colabmap.get(evntObj.User_Group_Id__c).Name;
                    }
                    if(evntrelationlist.keyset().contains(evntObj.Id)){
                        evntDetail.disablebutton = true;
                    }
                    if(userinfo.getUserType() == 'Guest'){
                        evntDetail.disablebutton = true;
                    }
                    if(evntObj.StartDateTime < System.today()){
                        evntDetail.disablebutton = true;
                    }
                    
                    
                    evntDetail.EventType = evntObj.Event_Type__c;
                    lstEventDetail.add(evntDetail);
                }
                
            }
            else{
                EventListWrapper wrap = new EventListWrapper();
                wrap.NoEventsData = 'No Data';
                lstEventDetail.add(wrap);
            }            
            return lstEventDetail;
        }
        Catch(Exception e){
            system.debug('GET Group Related events: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<EventRelation> returnUsersWhoJoinedEvents(String userId){
        try{
            List<EventRelation> evntrelationlist = [SELECT RelationId, eventId FROM EventRelation where RelationId=: userId AND Status ='Accepted'];
            return evntrelationlist;
        }
        Catch(Exception e){
            system.debug('Join event users: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
            
        }
        
    }
    
    
    @AuraEnabled
    public Static String sendMail(String userId, String eventId){
        try{
            String useremail;
            if(UserId != null){
                useremail = [SELECT Email From User where Id=:userId].Email;
            }
            List<Event> objEvent1 = [Select Id,Subject,Description,StartDateTime,Type,ActivityDate,User_Group_Id__c,
                                     EndDateTime,Location,IsVisibleInSelfService,Event_Type__c from Event 
                                     where Id=:eventId];
            Event objEvent = objEvent1[0];
            String endtime = objEvent.EndDateTime.format('HHmmssZ');
            String starttime = objEvent.StartDateTime.format('HHmmssZ');
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //Set To Addresss
            mail.setToAddresses(new List<String>{useremail});
            EmailTemplate emailTemplate =[Select Id from EmailTemplate where DeveloperName = 'Event_Join_Request'];
            mail.setTemplateID(emailTemplate.Id);
            mail.setWhatId(eventId);
            mail.settargetobjectid(userId);
            mail.setSaveAsActivity(false);
            mail.setTreatTargetObjectAsRecipient(false);
          
            //Create Meeting Body
            String strMetadata = '';             
            strMetadata += 'BEGIN:VCALENDAR\n';
            strMetadata += 'VERSION:2.0 \n';
            strMetadata += 'PRODID:-//salesforce.com//Calendar//EN \n';
            strMetadata += 'BEGIN:VEVENT\n';
            strMetadata += 'UID:'+eventId+'\n';
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
            
            //Meeting Email Attachment
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.Filename = 'meeting.ics'; 
            attach.ContentType = 'text/calendar';     
            attach.Inline = true;     
            attach.Body = Blob.valueOf(strMetadata);
            
            //Attach Meeting Attachment
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});
            //Send Email
            Messaging.SendEmailResult[] er = Messaging.sendEmail(new Messaging.Email[] { mail });
            return 'Email Sent';
            
        }
        Catch(Exception e){
            system.debug('Send Email Failed : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }              
    }
    
    
    @AuraEnabled
    public static List<EventListWrapper> getUpcomingEvents() {
        try{
            List<Event> lstRelatedEvents = new List<Event>();
            String sitelabel = System.Label.IN_CommunityName;
            List<Event> lstEvents = [Select Id,Subject,Description,StartDateTime,Type,ActivityDate,
                                     EndDateTime,Location,Event_Type__c,IsVisibleInSelfService
                                     from Event where StartDateTime >:System.now() and Event_Type__c='External' and IsChild = false 
                                     ORDER BY StartDateTime ASC LIMIT 3];
            List<EventListWrapper> lstEventDetail = new List<EventListWrapper>();
            Map<Id,CollaborationGroup> colabmap = new Map<Id,CollaborationGroup>([Select Id, Name from CollaborationGroup]);
            
            if(!lstEvents.isEmpty()){
                for(Event evntObj : lstEvents){
                    EventListWrapper evntDetail = new EventListWrapper();
                    evntDetail.Id = evntObj.Id;
                    evntDetail.Subject = evntObj.Subject;
                    evntDetail.Description = evntObj.Description;
                    evntDetail.Type = evntObj.Type;
                    evntDetail.Location = evntObj.Location;
                    DateTime dt = evntObj.StartDateTime;
                    evntDetail.FilterDate = dt.year()+'-'+dt.month()+'-'+dt.day();
                    evntDetail.ActivityDate = dt.format('EEE')+', '+dT.day()+' '+dT.format('MMM')+' '+dT.year();
                    evntDetail.ActivityTime = dt.format('hh:mm a z');                           
                    evntDetail.EventType = evntObj.Event_Type__c;
                    lstEventDetail.add(evntDetail);
                }
            }                 
            
            return lstEventDetail;
            
        }
        Catch(Exception e){
            system.debug('GET related events: ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static UpcomingEventsWrapper getUpcomingEventsByTitle(String eventTitles, String userId, String selectedDate){
        UpcomingEventsWrapper upEventWrapper = new UpcomingEventsWrapper();
        List<String> eventTitlesList = (List<String>)JSON.deserialize(eventTitles, List<String>.class);
        // Datetime myDate = Date.valueOf(selectedDate);
        // String newDate = DateTime.newInstance(myDate.year(), mydate.month(), mydate.day()).format('yyyy-MM-dd');
        // String startDateTime = DateTime.newInstance(myDate.year(), mydate.month(), mydate.day()).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        Map<Id, EventListWrapper> eventsLst = new Map<Id, EventListWrapper>();
        String query = 'Select Id, EventId,Event.WhoId, RelationId,Status, Event.Subject, Event.Description, Event.Type,'+'Event.Location,Event.Event_Type__c, Event.ActivityDate, Event.ActivityDateTime, Event.StartDateTime,'+'Event.User_Group_Id__c, Event.EndDate, Event.EndDateTime '+'From EventRelation where   Event.Event_Type__c !=null and Event.IsChild = false and Status = \'Accepted\' and RelationId = \'' + userId + '\'' +' AND DAY_ONLY(convertTimezone(Event.ActivityDateTime)) <= '+ selectedDate + ' AND Event.EndDate >= '+ selectedDate + 'order by Event.ActivityDateTime';
            
        List<EventRelation> eventRelationList = Database.query(query); 
        String sitelabel = System.Label.IN_CommunityName; 
        for(EventRelation evntRelation : eventRelationList){
            EventListWrapper evntDetail = new EventListWrapper();
            evntDetail.Id = evntRelation.EventId;
            // <Tag - 02 - start>
            evntDetail.Subject = evntRelation.Event.Subject;
            // <Tag - 02 - end>
            evntDetail.Description = evntRelation.Event.Description;
            evntDetail.Type = evntRelation.Event.Type;
            evntDetail.Location = evntRelation.Event.Location;
            DateTime dtStart = evntRelation.Event.ActivityDateTime;
            evntDetail.FilterDate = dtStart.year()+'-'+dtStart.month()+'-'+dtStart.day();
            evntDetail.ActivityDate = dtStart.format('EEE')+', '+ getOrdinal(dtStart.day()) +' '+dtStart.format('MMM')+' '+dtStart.year();
            evntDetail.ActivityTime = dtStart.format('hh:mm a')+' '+ dtStart.format('z');
            evntDetail.disablebutton = true;               
            evntDetail.Link = sitelabel+'eventdetails?id=' + evntRelation.Event.Id;               
            
            eventsLst.put(evntRelation.EventId, evntDetail);
            
        }
        upEventWrapper.userEvents = eventsLst.values();
        return upEventWrapper;
    }
    
    @AuraEnabled
    public static List<joinedEventWrapper> fetchJoinedEvents(String userId){
        List<joinedEventWrapper> joinedEventWrapperList  = new List<joinedEventWrapper>();
        List<EventRelation> EventRelationList = [Select Id,EventId,Event.ActivityDateTime,Event.EndDateTime,Event.Subject FROM EventRelation where RelationId=: userId 
                                                 AND Status ='Accepted' and Event.Event_type__c != null];
        
        for(EventRelation EventRelationObj : EventRelationList){
            DateTime dtStart = EventRelationObj.Event.ActivityDateTime;
            DateTime dtEnd = EventRelationObj.Event.EndDateTime;
            joinedEventWrapper joinedEventWrapperObj = new joinedEventWrapper();
            joinedEventWrapperObj.startDateTime = EventRelationObj.Event.ActivityDateTime;      
            joinedEventWrapperObj.endDateTime = EventRelationObj.Event.EndDateTime;
            joinedEventWrapperObj.startDateGMT = date.newInstance(dtStart.yearGmt(), dtStart.monthGmt(), dtStart.dayGmt());
            joinedEventWrapperObj.endDateGMT = date.newInstance(dtEnd.yearGmt(), dtEnd.monthGmt(), dtEnd.dayGmt());
            joinedEventWrapperObj.startDate = date.newInstance(dtStart.year(), dtStart.month(), dtStart.day());
            joinedEventWrapperObj.subject = EventRelationObj.Event.Subject;
            joinedEventWrapperObj.display = 'background';
            joinedEventWrapperList.add(joinedEventWrapperObj);
        }
        return JoinedEventWrapperList;
    }
    
    public class JoinEventWrapper{
        @AuraEnabled public String statusMessage;
        @AuraEnabled public String returnMessage;
    }  
    
    public class UpcomingEventsWrapper{
        @AuraEnabled public List<EventListWrapper> upcomingEvents;
        @AuraEnabled public List<EventListWrapper> userEvents;
    }
    
    public class filterWrappers{       
        @AuraEnabled public List<String> TypeFilter;
        @AuraEnabled public Map<String, String> UserGroupFilter;
    }    
    
    
    public class EventListWrapper{
        @AuraEnabled public String Id; 
        @AuraEnabled public String Name; 
        @AuraEnabled public String Subject;
        @AuraEnabled public String Description; 
        @AuraEnabled public String Type; 
        @AuraEnabled public String Location; 
        @AuraEnabled public String ActivityDate;
        @AuraEnabled public String ActivityTime; 
        @AuraEnabled public String FilterDate; 
        @AuraEnabled public String ParentCommunityName; 
        @AuraEnabled public String Link; 
        @AuraEnabled public Boolean IsFollowing; 
        @AuraEnabled public String UserGroupData; 
        @AuraEnabled public String EventType; 
        @AuraEnabled public boolean disablebutton=false;
        @AuraEnabled public datetime StartDateTime; 
        @AuraEnabled public datetime EndDateTime; 
        @AuraEnabled public String NoEventsData; 
        @AuraEnabled public String TodayDate;
        @AuraEnabled public String MonthYear; 
        @AuraEnabled public String month; 
        @AuraEnabled public String year;
    }
    
    public class joinedEventWrapper{
        @AuraEnabled public Date startDateGMT;
        @AuraEnabled public Date endDateGMT;
        @AuraEnabled public DateTime startDateTime;
        @AuraEnabled public Date startDate;
        @AuraEnabled public DateTime endDateTime;
        @AuraEnabled public String subject;
        @AuraEnabled public String display;
    }
    
}