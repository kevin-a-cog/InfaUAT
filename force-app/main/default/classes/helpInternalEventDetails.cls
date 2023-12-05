/*
* Name         :   helpInternalEventDetails
* Author       :   Deeksha Shetty
* Created Date :   12/05/2022
* Description  :   Controller class for Internal Events Component.

Change History
**********************************************************************************************************
Modified By            Date            Jira No.        Description                                 Tag
**********************************************************************************************************
Deeksha Shetty      12/05/2022      N/A             Initial version.                            N/A
*/


public without sharing class helpInternalEventDetails {
    
    @AuraEnabled(Cacheable=true)
    public static List<EventsLandingWrapper> eventData(){
        try{            
            List<Event> eventDetail = [SELECT Id, Location, Subject, ActivityDate, StartDateTime, EndDateTime, Type, CreatedBy.Name,CreatedById,CreatedDate,LastModifiedDate,
                                      Description, Event_Type__c FROM Event where Event_Type__c!=null AND isChild=False ORDER BY CreatedDate DESC ] ;
            List<EventsLandingWrapper> eVlist = new List<EventsLandingWrapper>();
            for(Event ev :eventDetail){
                EventsLandingWrapper ewrap = new EventsLandingWrapper();
                ewrap.Id = ev.Id;
                ewrap.Location = ev.Location;
                ewrap.Subject = ev.Subject;
                datetime dt = ev.StartDateTime;
                ewrap.StartDateTime = dt.format('dd/MM/YYYY hh:mm a');
                datetime dt1 = ev.EndDateTime;
                ewrap.EndDateTime = dt1.format('dd/MM/YYYY hh:mm a');
                ewrap.Type = ev.Type;
                ewrap.Description = ev.Description;
                ewrap.EventType = ev.Event_Type__c;
                ewrap.CreatedBy = ev.CreatedBy.Name;
                ewrap.CreatedById = ev.CreatedById;
                DateTime dT2 = ev.CreatedDate;
                ewrap.CreatedDate = dT2.format('MM/dd/YYYY');
                ewrap.Link = '/lightning/cmp/c__helpInternalEventsWrapper?c__crecordId='+ev.Id; 
                eVlist.add(ewrap);                
            }
             return eVlist;
            
            
        }
        Catch(Exception e){
            system.debug('Error in Events Data : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
    }
    
    
    @AuraEnabled(Cacheable=true)
    public static EventsLandingWrapper eventdisplayOnId(String eventId){
        try{            
            List<Event> eventDetail = [SELECT Id, Location, Subject, ActivityDate, StartDateTime, EndDateTime, Type,CreatedBy.Name,CreatedById,CreatedDate,LastModifiedDate, 
                                      Description, Event_Type__c FROM Event where Id=:eventId] ;
            EventsLandingWrapper ewrap = new EventsLandingWrapper();
            for(Event ev :eventDetail){                
                ewrap.Id = ev.Id;
                ewrap.Location = ev.Location;
                ewrap.Subject = ev.Subject;
                ewrap.RealStartDateTime = ev.StartDateTime;
                ewrap.StartDateTime = ewrap.RealStartDateTime.format('dd/MM/YYYY hh:mm a');
                ewrap.RealEndDateTime = ev.EndDateTime;
                ewrap.EndDateTime = ewrap.RealEndDateTime.format('dd/MM/YYYY hh:mm a');
                ewrap.Type = ev.Type;
                ewrap.Description = ev.Description;
                ewrap.EventType = ev.Event_Type__c;
                ewrap.CreatedBy = ev.CreatedBy.Name;
                ewrap.CreatedById = ev.CreatedById;
                DateTime dT = ev.CreatedDate;
                ewrap.CreatedDate = dT.format('MM/dd/YYYY');
                DateTime dT1 = ev.LastModifiedDate;
                ewrap.LastModifiedDate =dT1.format('MM/dd/YYYY');
                ewrap.Link = '/lightning/cmp/c__helpInternalEventsWrapper?c__crecordId='+ev.Id;
                               
            }
             return ewrap;
        }
        Catch(Exception e){
            system.debug('Error in Ideas Display : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
        
    }
    
    
    
    @AuraEnabled
    public static String createEvent(String Subject, String Description, Datetime StartDateTime, Datetime EndDateTime, String Location, String Type) {
        try{
            Event objEvent = new Event();
            objEvent.Subject = Subject;
            objEvent.Description = Description;
            objEvent.StartDateTime = StartDateTime;
            objEvent.EndDateTime = EndDateTime;
            objEvent.Location = Location;
            objEvent.Type = Type;
            objEvent.IsVisibleInSelfService = true;
            objEvent.Event_Type__c = 'External';
            insert objEvent;
            if(objEvent.Id != null){                               
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
    
    
    @AuraEnabled
    public static String modifyEvent(String eventId,String Subject, String Description, Datetime StartDateTime, Datetime EndDateTime, String Location, String Type){
        try{            
            List<Event> eventDetail = [SELECT Id, Location, Subject, ActivityDate, StartDateTime, EndDateTime, Type, 
                                       Description, Event_Type__c FROM Event where Id=:eventId] ;            
            
            if(eventDetail.size()>0){
                for(Event objEvent : eventDetail){                                                        
                    objEvent.Subject = Subject;
                    objEvent.Description = Description;
                    objEvent.StartDateTime = Datetime.valueof(StartDateTime);
                    objEvent.EndDateTime = Datetime.valueof(EndDateTime);
                    objEvent.Location = Location;
                    objEvent.Type = Type;
                    update eventDetail;                    
                }
            }
                     
            return 'Success';
        }
        Catch(Exception e){
            system.debug('Error in ModifyEvent : ' +e.getMessage() + ' Stack trace : ' + e.getStackTraceString());
            throw new AuraHandledException('Something went wrong: '+e.getMessage());            
        }
        
    }
    
    
    
    
    
    
    
    public class EventsLandingWrapper{
        @AuraEnabled public String Id;
        @AuraEnabled public String Location;
        @AuraEnabled public String Subject;
        @AuraEnabled public String CreatedBy;
        @AuraEnabled public String CreatedById;
        @AuraEnabled public Datetime RealStartDateTime;
        @AuraEnabled public Datetime RealEndDateTime; 
        @AuraEnabled public String StartDateTime;
        @AuraEnabled public String EndDateTime;        
        @AuraEnabled public String Type;
        @AuraEnabled public String Description;
        @AuraEnabled public String EventType;
        @AuraEnabled public String Link;
        @AuraEnabled public String CreatedDate;
    	@AuraEnabled public String LastModifiedDate;
    }
    
    
    
    

}