/*
 * Name         :   ServiceAppointmentTriggerHelper
 * Author       :   Vignesh Divakaran
 * Created Date :   9/19/2023
 * Description  :   This is an helper class.

 Change History
 ***********************************************************************************************************************************
 Modified By            Date            Jira No.        Tag     Description                                
 ***********************************************************************************************************************************
 Vignesh Divakaran      9/19/2023       I2RT-9063       N/A     Initial version.
 Shashikanth			10/18/2023		I2RT-7702		T01     Updated 'GCS_AAE_Session_Time__c' time format to 12hrs
 */

 public class ServiceAppointmentTriggerHelper {

    public static globalApexManager GAM = new globalApexManager();
    public static final Id ASK_AN_EXPERT_RECORDTYPEID = Schema.SObjectType.Service_Appointment__c.getRecordTypeInfosByName().get('Ask An Expert').getRecordTypeId();
    public static final Id CASE_ASK_AN_EXPERT_RECORDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ask An Expert').getRecordTypeId();

    /**
    * this method validates booked Ask An Expert slots and throws error when the limit is exceeded for the current month
    * @param lstNewServiceAppointments
    * @return return-void
    * @throws exception - NA
    */
    public void validateSlotLimit(List<Service_Appointment__c> lstNewServiceAppointments){
        Set<String> setSupportAccountIds = new Set<String>();
        Set<Integer> setMonth = new Set<Integer>();
        Set<Integer> setYear = new Set<Integer>();
        Set<Id> setTimeSlotIds = new Set<Id>();
        Map<String, Time_Slot_AAE__c> mapTimeSlots;
        Map<String, Integer> monthWiseRecordSize = new Map<String, Integer>();

        for(Service_Appointment__c objServiceAppointment : lstNewServiceAppointments){
            if(objServiceAppointment.RecordTypeId == ASK_AN_EXPERT_RECORDTYPEID){
                setTimeSlotIds.add(objServiceAppointment.Time_Slot_AAE__c);
                setSupportAccountIds.add(objServiceAppointment.Support_Account__c);
            }
        }

        mapTimeSlots = new Map<String, Time_Slot_AAE__c>([SELECT Start_Time__c, End_Time__c, Product__c FROM Time_Slot_AAE__c WHERE Id IN :setTimeSlotIds LIMIT 1000]);
        
        for(Service_Appointment__c objServiceAppointment : lstNewServiceAppointments){
            if(objServiceAppointment.RecordTypeId == ASK_AN_EXPERT_RECORDTYPEID){
                setMonth.add(mapTimeSlots.get(objServiceAppointment.Time_Slot_AAE__c)?.Start_Time__c.month());
                setYear.add(mapTimeSlots.get(objServiceAppointment.Time_Slot_AAE__c)?.End_Time__c.year());
            }
        }
        
        for(Service_Appointment__c objExistingSA : [SELECT Id,
                                                        Time_Slot_AAE__r.Start_Time__c
                                                        FROM Service_Appointment__c 
                                                        WHERE CALENDAR_MONTH(Time_Slot_AAE__r.Start_Time__c) IN :setMonth AND 
                                                        CALENDAR_YEAR(Time_Slot_AAE__r.Start_Time__c) IN :setYear AND 
                                                        Support_Account__c IN :setSupportAccountIds AND 
                                                        RecordTypeId = :ASK_AN_EXPERT_RECORDTYPEID]){ 
            Integer existMonth = objExistingSA.Time_Slot_AAE__r.Start_Time__c.month();
            Integer existYear = objExistingSA.Time_Slot_AAE__r.Start_Time__c.year();
            String storeMonthYear = existMonth + '-' + existYear;
            if(monthWiseRecordSize.containsKey(storeMonthYear)){                             
                Integer countMonthRec = monthWiseRecordSize.get(storeMonthYear) + 1;
                monthWiseRecordSize.put(storeMonthYear,countMonthRec);   
            }
            else{
                monthWiseRecordSize.put(storeMonthYear,1);
            }
        }

        for(Service_Appointment__c objServiceAppointment : lstNewServiceAppointments){
            
            if(objServiceAppointment.RecordTypeId == ASK_AN_EXPERT_RECORDTYPEID){  
                Integer currentMonth = mapTimeSlots.get(objServiceAppointment.Time_Slot_AAE__c)?.Start_Time__c.month();
                Integer currentYear = mapTimeSlots.get(objServiceAppointment.Time_Slot_AAE__c)?.Start_Time__c.year();
                String currentDateWithoutDay = currentMonth + '-' + currentYear;

                if(monthWiseRecordSize.containsKey(currentDateWithoutDay)){
                    Integer noOfRecBaseMonth = monthWiseRecordSize.get(currentDateWithoutDay);
                    if(noOfRecBaseMonth > 1){
                        objServiceAppointment.addError('Slots already booked for this calendar month');
                    }
                }
            } 
        }
    }

    /**
    * this method creates a case for every service appointment of type ask an expert
    * @param lstNewServiceAppointments
    * @return return-void
    * @throws exception - NA
    */
    public void createCase(List<Service_Appointment__c> lstNewServiceAppointments){
        Group objGroup = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Ask An Expert' LIMIT 1];
        List<Id> lstTimeSlotIds = new List<Id>();
        List<Case> lstCases = new List<Case>();
        Set<Id> setCreatedByIds = new Set<Id>();
        Map<String, Time_Slot_AAE__c> mapTimeSlots;
        Map<Id, User> mapUsers;

        for(Service_Appointment__c objServiceAppointment : lstNewServiceAppointments) {

            //First we get the Time Slots (if any) of the new Service Appointments.
            if(objServiceAppointment.Time_Slot_AAE__c != null) {
                lstTimeSlotIds.add(objServiceAppointment.Time_Slot_AAE__c);
            }
            //Now, we add the service appointment created by id
            setCreatedByIds.add(objServiceAppointment.CreatedById);
        }
        
        if(!lstTimeSlotIds.isEmpty()) {
            mapTimeSlots = new Map<String, Time_Slot_AAE__c>([SELECT Start_Time__c, End_Time__c, Product__c FROM Time_Slot_AAE__c WHERE Id IN :lstTimeSlotIds LIMIT 1000]);
            mapUsers = new Map<Id, User>([SELECT Id, ContactId, Contact.TimeZone_Lookup__c, Contact.TimeZone_Lookup__r.TimeZoneSidKey__c, Contact.TimeZone_Lookup__r.Name FROM User WHERE Id IN :setCreatedByIds LIMIT 1000]);
        
            //We prepare the data for the Case records.
            for(Service_Appointment__c objServiceAppointment : lstNewServiceAppointments) {
                User objCurrentUser = mapUsers.get(objServiceAppointment.CreatedById);
                Case objCase = new Case();
                objCase.RecordTypeId = CASE_ASK_AN_EXPERT_RECORDTYPEID;
                objCase.Support_Account__c = objServiceAppointment.Support_Account__c;
                objCase.Subject = objServiceAppointment.Subject__c;
                objCase.Description = objServiceAppointment.Description__c;
                objCase.Service_Appointment__c = objServiceAppointment.Id;
                objCase.AAE_Session_Information__c = objServiceAppointment.Description__c;
                objCase.AAE_Area_of_expertise__c = objServiceAppointment?.Area__c;
                objCase.Category__c = objServiceAppointment?.Category__c;
                objCase.OwnerId = objGroup.Id;
                objCase.ContactId = objCurrentUser.ContactId;
                if(objCurrentUser.Contact.TimeZone_Lookup__c != null && objCurrentUser.Contact.TimeZone_Lookup__r.TimeZoneSidKey__c != null){
                    objCase.GCS_AAE_Session_Time__c = mapTimeSlots.get(objServiceAppointment.Time_Slot_AAE__c).Start_Time__c.format('dd MMM yyyy, hh:mm a', objCurrentUser.Contact.TimeZone_Lookup__r.TimeZoneSidKey__c) + ' - ' + //<T01>
                        mapTimeSlots.get(objServiceAppointment.Time_Slot_AAE__c).End_Time__c.format('dd MMM yyyy, hh:mm a', objCurrentUser.Contact.TimeZone_Lookup__r.TimeZoneSidKey__c) + ' (' + objCurrentUser.Contact.TimeZone_Lookup__r.Name.substringBeforeLast('(') + ')';    //<T01>
                }
                else{
                    objCase.GCS_AAE_Session_Time__c = mapTimeSlots.get(objServiceAppointment.Time_Slot_AAE__c).Start_Time__c.format('dd MMM yyyy, hh:mm a') + ' - ' + //<T01>
                        mapTimeSlots.get(objServiceAppointment.Time_Slot_AAE__c).End_Time__c.format('dd MMM yyyy, hh:mm a') + ' ((GMT' + mapTimeSlots.get(objServiceAppointment.Time_Slot_AAE__c).//<T01>
                        Start_Time__c.format('Z') + ') ' + mapTimeSlots.get(objServiceAppointment.Time_Slot_AAE__c).Start_Time__c.format('zzzz') + ')';
                }
                objCase.Expert_Assistance_Requested_Date__c = mapTimeSlots.get(objServiceAppointment.Time_Slot_AAE__c).Start_Time__c;
                objCase.Forecast_Product__c = mapTimeSlots.get(objServiceAppointment.Time_Slot_AAE__c).Product__c;
                objCase.Status = 'Booked';
                objCase.Next_Action__c = 'Case Owner';
                objCase.Origin = 'Community';
                lstCases.add(objCase);	
            }
        
            //We create the cases.
            insert lstCases;
            CaseController.initialResponseCaseComment(lstCases[0].Id);
        }        
    }

    /**
    * this method creates an event linking Ask An Expert Service Appointment and Case. 
    * @param mapNewServiceAppointments
    * @return return-void
    * @throws exception - NA
    */
    public void createEvent(Map<Id, Service_Appointment__c> mapNewServiceAppointments){
        List<Event> lstEvents = new List<Event>();
        List<Case> lstCases = [SELECT Id,
                                      Subject,
                                      Service_Appointment__c,
                                      Service_Appointment__r.Time_Slot_AAE__r.Start_Time__c,
                                      Service_Appointment__r.Time_Slot_AAE__r.End_Time__c 
                                      FROM Case 
                                      WHERE RecordTypeId = :CASE_ASK_AN_EXPERT_RECORDTYPEID AND 
                                      Status = 'Booked' AND 
                                      Service_Appointment__c IN :mapNewServiceAppointments.keySet() AND
                                      Service_Appointment__r.Time_Slot_AAE__c != null];

        for(Case objCase : lstCases){
            Event objEvent = new Event();
            objEvent.WhatId = objCase.Id;
            objEvent.Service_Appointment_AAE__c = objCase.Service_Appointment__c;
            objEvent.Subject = objCase.Subject;
            objEvent.ActivityDateTime = objCase.Service_Appointment__r.Time_Slot_AAE__r.Start_Time__c;
            objEvent.StartDateTime = objCase.Service_Appointment__r.Time_Slot_AAE__r.Start_Time__c;
            objEvent.EndDateTime = objCase.Service_Appointment__r.Time_Slot_AAE__r.End_Time__c;
            lstEvents.add(objEvent);
        }

        if(!lstEvents.isEmpty())
            insert lstEvents;
    }
}