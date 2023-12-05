/* 
Class - UserEventsHandler
Description - This class is used to handle the User aligned events 
Author - Amarender


Change History
****************************************************************************************************
ModifiedBy      Date        Jira No.    Tag     Description
****************************************************************************************************
balajip         11/22/2021  I2RT-4425   T01     added condition to SOQL to filter out duplicate entries
Isha            04/03/2023  I2RT-6727   T02     Modified query and condition for FTO . Taken user's timezone into account
Isha B         06-jun-20223  I2RT-8528  T03    Replaced IsAllDayEvent with custom field IsAllDayEvent__c

*/
public without sharing class UserEventsHandler {
    
    @AuraEnabled(cacheable=true)
    public static EventListWrapper userUpcomingEvents(string userId ){
        try {
            List<EventDetailWrapper> weekendSupportList = new List<EventDetailWrapper>();
            List<EventDetailWrapper> holidaySupportList = new List<EventDetailWrapper>();
            List<EventDetailWrapper> FTOSupportList = new List<EventDetailWrapper>();
            User usr;//T02
            String usrTimezonelabel='';
            DateTime curTimeUserTZ; 
            if(userId!=NULL){ //T02
                usr=[SELECT Id, TimeZoneSidKey,toLabel(TimeZoneSidKey) timezonelabel FROM User WHERE Id=:userId limit 1]; //get the User's Timezone                
                usrTimezonelabel=(String)usr.get('timezonelabel'); 
                String sidKey=(String)usr.TimeZoneSidKey;
                TimeZone userTZ=Timezone.getTimeZone(sidkey);
                 curTimeUserTZ=System.now().addSeconds(userTZ.getOffset(System.now())/1000);//get the gmt time and convert to user's timezone 
              
            }//T02
            
            List<Event> lstEvent = [Select Id, IsAllDayEvent,IsAllDayEvent__c,OwnerId,Subject,Type, DurationInMinutes,IsRecurrence,StartDateTime, EndDateTime ,Owner.IsActive,ActivityDate ,EndDate
                                        From Event 
			                             Where OwnerId = :userId 
                                         AND( (StartDateTime <= Today And EndDateTime >= Today)
                                                OR (StartDateTime <= YESTERDAY And EndDateTime >= YESTERDAY)
                                                OR (StartDateTime <= TOMORROW And EndDateTime >= TOMORROW)                                               
                                                OR EndDateTime >=TODAY
                                             )                                                                                      
                                        order by  StartDateTime asc]; // T02->currDateUserTZ filter change
                
            for( Event userEvent : lstEvent){

                 //Get the start and end datetime of the event
            DateTime startTime = userEvent.StartDateTime;
            DateTime endTime = userEvent.StartDateTime.addMinutes(userEvent.DurationInMinutes); //add 1440 minutes (1 day)
                if(endTime >= curTimeUserTZ){
            
                    if(userEvent.Subject != null && userEvent.Subject != '' && userEvent.Subject.contains('Weekend Support')){
                        weekendSupportList.add(createEventDetailWrapperObj(userEvent.subject,userEvent.ActivityDate,userEvent.enddate,userEvent.StartDateTime,userEvent.EndDateTime,''));//T02
                    }
                    if(userEvent.Subject != null && userEvent.Subject != '' && userEvent.Subject.contains('Holiday Support')){
                        holidaySupportList.add(createEventDetailWrapperObj(userEvent.subject,userEvent.ActivityDate,userEvent.enddate,userEvent.StartDateTime,userEvent.EndDateTime,'')); //T02
                    }
                    if( userEvent.Type!=null && userEvent.Type=='FTO' && userEvent.IsAllDayEvent__c==true){         //T03          
                        FTOSupportList.add(createEventDetailWrapperObj(userEvent.subject,userEvent.ActivityDate,userEvent.enddate,userEvent.StartDateTime,userEvent.EndDateTime,usrTimezonelabel)); //T02
                    }
                }
            }
            EventListWrapper userUpcomingEvents = new EventListWrapper();
            userUpcomingEvents.weekendSupport = weekendSupportList;
            userUpcomingEvents.holidaySupport = holidaySupportList;
            userUpcomingEvents.fto = FTOSupportList;
            
            return userUpcomingEvents;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static EventDetailWrapper createEventDetailWrapperObj(String subject, Date startdate, Date enddate, Datetime startdatetime,Datetime enddatetime,String usrTimezonelabel){ //T02

        EventDetailWrapper eventdetailwrap=new EventDetailWrapper();
        eventdetailwrap.subject=subject;
        eventdetailwrap.startdate=String.valueOf(startdate);
        eventdetailwrap.enddate=String.valueOf(enddate);
        eventdetailwrap.startdatetime=String.valueOf(startdatetime);
        eventdetailwrap.enddatetime=String.valueOf(enddatetime);
        eventdetailwrap.usrtimezone=usrTimezonelabel!=null?usrTimezonelabel:'';
        return eventdetailwrap;

    }

    public class EventListWrapper{ //T02
        @AuraEnabled
        public List<EventDetailWrapper> weekendSupport{get;set;}
        @AuraEnabled
        public List<EventDetailWrapper> holidaySupport{get;set;}
        @AuraEnabled
        public List<EventDetailWrapper> fto{get;set;}
    }

    public class EventDetailWrapper{//T02
        @AuraEnabled
        public String subject{get;set;}
        @AuraEnabled
        public String startdate{get;set;}
        @AuraEnabled
        public String enddate{get;set;}
        @AuraEnabled
        public String startdatetime{get;set;}
        @AuraEnabled
        public String enddatetime{get;set;}
        @AuraEnabled
        public String usrtimezone{get;set;}
    }
}