/*
 * Name         :   OperationsSchedulerController
 * Author       :   Vignesh Divakaran
 * Created Date :   8/3/2021
 * Description  :   Controller class for Operations Scheduler feature.

 Change History
 ***************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                                 Tag
 ***************************************************************************************************************************
 Vignesh Divakaran      8/3/2021        I2RT-3730           Initial version.                                            NA
 Vignesh Divakaran      4/27/2023       I2RT-7859           Updated public variable from PROD to Production             T01
 Vignesh Divakaran      11/23/2023      I2RT-9461           Replaced standard with custom Service Appointment object    T02
 Vignesh Divakaran      11/29/2023      I2RT-9557           Added logic to handle Daylight Savings time                  T03
 */

 public with sharing class OperationsSchedulerController {

    //Private variables.
    private static String PRODUCTION = 'Production'; //<T01> //<T02>
    private static String STR_DATE_FORMAT = 'MMM dd, yyyy';
    private static Integer WEEKDAY_SLOT_DURATION_IN_MINUTES = 60;
    private static Integer WEEKEND_SLOT_DURATION_IN_MINUTES = 180;
    private static Integer DEFAULT_NUMBER_OF_DAYS_TO_GENERATE_SLOTS = 10;
    private static String DEFAULT_TIMEZONE = 'America/Los_Angeles'; //<T03>
    private static Integer DEFAULT_TIMEZONE_DST_OFFSET = -25200000; //<T03>
    private static List<String> DAYS_OF_WEEK = new List<String>{'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'}; //<T02>

    /*
     Method Name : getAvailableSlots
     Description : This method returns the list of available slots based on the Priority and EnvironmentType provided.
     Parameters  : (String, String) called from getAvailableSlots.
     Return Type : Map of available slots.
     */
    @AuraEnabled
    public static Map<String, List<OperationsSchedulerWrapper>> getAvailableSlots(String priority, String environmentType){

        priority = (priority != null) ? String.escapeSingleQuotes(priority) : priority;
        environmentType = (environmentType != null) ? String.escapeSingleQuotes(environmentType) : environmentType;

        Date endDate;
        DateTime dtNow;
        Date startDate;
        Integer noOfDays;
        String userTZName = getUserTZ();

        OperationsSchedulerWrapper objSlot;
        List<OperationsSchedulerWrapper> lstSlots;
        Map<String, TimeSlotWrapper> timeSlots = new Map<String, TimeSlotWrapper>();
        Map<Date, TimeSlotWrapper> availableDates = new Map<Date, TimeSlotWrapper>();
        Map<String, List<OperationsSchedulerWrapper>> mapSlotsByDay = new Map<String, List<OperationsSchedulerWrapper>>();
        Map<String, List<OperationsSchedulerWrapper>> mapSlotsByDayFiltered = new Map<String, List<OperationsSchedulerWrapper>>();

        noOfDays = DEFAULT_NUMBER_OF_DAYS_TO_GENERATE_SLOTS;
        dtNow = setDateTime(priority, environmentType);

		//Operating Hours
        for(String strDayOfWeek : DAYS_OF_WEEK){ //<T02>
     
            TimeSlotWrapper timeSlotObj = new TimeSlotWrapper();
            timeSlotObj.dayOfWeek = strDayOfWeek;
            timeSlotObj.startTime = Time.newInstance(0,0,0,0); //12:00:00 AM
            timeSlotObj.endTime = Time.newInstance(23,59,59,0); // 11:59:59 PM
            timeSlots.put(strDayOfWeek, timeSlotObj);
        }

        /* Calculating Start Date */
        Boolean startDateFound = false;
        Date currentDate = System.now().dateGMT();
        String currentDate_DayOfWeek = getDayOfWeek(currentDate);

        while(!startDateFound){
            //Check if Current Date's Day is found in the Operating Hours
            if(timeSlots.containsKey(currentDate_DayOfWeek)){
                startDateFound = true;
                startDate = currentDate;
                availableDates.put(startDate, timeSlots.get(currentDate_DayOfWeek));
            }
            else{
                currentDate = currentDate.addDays(1);
                currentDate_DayOfWeek = getDayOfWeek(currentDate);
            }
        }

        /* Calculating End Date */
        Integer noOfDaysCount = 1;
        endDate = startDate.addDays(1);
        Boolean isDateAvailable = false;
        String endDate_DayOfWeek = getDayOfWeek(endDate);

        for(Integer endDateCount = 1; endDateCount < noOfDays; endDateCount++){
            isDateAvailable = false;
            
            while(!isDateAvailable){
                //Check if Current Date's Day is found in the Operating Hours
                if(timeSlots.containsKey(endDate_DayOfWeek)){
                    isDateAvailable = true;
                    availableDates.put(endDate, timeSlots.get(endDate_DayOfWeek));
                    noOfDaysCount++;
                }
                else{
                    endDate = endDate.addDays(1);
                    endDate_DayOfWeek = getDayOfWeek(endDate);
                }
            }

            if(noOfDaysCount < noOfDays){
                endDate = endDate.addDays(1);
                endDate_DayOfWeek = getDayOfWeek(endDate);
            }
        }

        Integer offSetStartHour = 0;
        Integer slotIntervalInMinutes = WEEKDAY_SLOT_DURATION_IN_MINUTES;

        /* Generate dynamic slots for available dates in GMT */
        for(Date availableDate : availableDates.keySet()){

            DateTime availableDateTime = (DateTime) availableDate;
            TimeSlotWrapper timeSlotObj = availableDates.get(availableDate);
            String startTime = getTimeStr(timeSlotObj.startTime);
            String endTime = getTimeStr(timeSlotObj.endTime);
            DateTime counterStartDT = Datetime.newInstanceGMT(availableDate.year(), availableDate.month(), availableDate.day(), Integer.valueOf(startTime.split(':')[0]), 
                                      Integer.valueOf(startTime.split(':')[1]), Integer.valueOf(startTime.split(':')[2]));
            DateTime counterEndDT = Datetime.newInstanceGMT(availableDate.year(), availableDate.month(), availableDate.day(), Integer.valueOf(endTime.split(':')[0]), 
                                    Integer.valueOf(endTime.split(':')[1]), Integer.valueOf(endTime.split(':')[2]));
            lstSlots = new List<OperationsSchedulerWrapper>();
    
            //Add the offsetHours to the day, if present.
            if(offSetStartHour > 0){
                counterStartDT = counterStartDT.addHours(offSetStartHour);
            }
            if(isWeekend(counterStartDT) && offSetStartHour == 0){
                counterStartDT = counterStartDT.addHours(offsetWeekendDayHour(counterStartDT));
            }

            while(counterStartDT < counterEndDT.addSeconds(1)){
                
                slotIntervalInMinutes = isWeekend(counterStartDT) && !isWeekendExactEndDT(counterStartDT) ? WEEKEND_SLOT_DURATION_IN_MINUTES : WEEKDAY_SLOT_DURATION_IN_MINUTES;
                    //Create and add slots, when greater than the dtNow(DateTime)
                    if(counterStartDT >= dtNow) {
                        objSlot = new OperationsSchedulerWrapper();
                        objSlot.boolIsAvailable = true;
                        objSlot.startDT = counterStartDT;
                        objSlot.endDT = counterStartDT.addMinutes(slotIntervalInMinutes);
                        objSlot.numberOfCommonSlots = 1; 
                        if(!isWeekend(counterStartDT)){ //<T03>
                            if(isWeekdayOffHour(counterStartDT, counterStartDT.addMinutes(slotIntervalInMinutes))){
                                objSlot.numberOfReservedSlots = 0;
                            } 
                            else if(isEvenHour(counterStartDT.hourGMT())){
                                objSlot.numberOfReservedSlots = 1;
                            }
                            else{
                                objSlot.numberOfReservedSlots = 0;
                            }
                        }
                        lstSlots.add(objSlot);
                    }

                //Now we prepare the gap for the next slot.
                counterStartDT = counterStartDT.addMinutes(slotIntervalInMinutes);
            }

            //Prepare a map of available dates and the corresponding slots based on the User's TimeZone.
            for(OperationsSchedulerWrapper slot : lstSlots){
                String formattedDate = slot.startDT.format(STR_DATE_FORMAT, userTZName);
                if(mapSlotsByDay.containsKey(formattedDate)){
                    List<OperationsSchedulerWrapper> tempLstSlots = new List<OperationsSchedulerWrapper>();
                    tempLstSlots = mapSlotsByDay.get(formattedDate);
                    tempLstSlots.add(slot);
                    mapSlotsByDay.put(formattedDate, tempLstSlots);
                }else{
                    mapSlotsByDay.put(formattedDate, new List<OperationsSchedulerWrapper>{slot});
                }
            }
            //Calculate the offsetHours to carry forward to the next day, applicable only for cross-over between Weekday and Weekend, and vice versa.
            offSetStartHour = isWeekend(counterStartDT) ? calculateOffSetHours(counterStartDT, counterEndDT.addSeconds(1)) : 0;
        }
        
        DateTime startSOQLDT = DateTime.newInstanceGMT(startDate.year(), startDate.month(), startDate.day(), 0, 0, 0);
        DateTime endSOQLDT = DateTime.newInstanceGMT(endDate.year(), endDate.month(), endDate.day(), 23, 59, 59);

        /* Query Service Appointments and exclude the slots from Common and Reserved Slots. */
        for(Service_Appointment__c objExistingServiceAppointment : [SELECT Id,Start_Date_Time__c,End_Date_Time__c,Environment__c FROM Service_Appointment__c WHERE RecordType.Name = 'Operations' AND Start_Date_Time__c >= :startSOQLDT AND End_Date_Time__c <= :endSOQLDT LIMIT 40000]){ //<T02>
            for(String strDate : mapSlotsByDay.keySet()){
                if(strDate == objExistingServiceAppointment.Start_Date_Time__c.format(STR_DATE_FORMAT, userTZName)){
                    for(OperationsSchedulerWrapper objCurrentSlot : mapSlotsByDay.get(strDate)){
                        
                        //If the Service Appointment is between slots, we mark it as not available.
                        if(objCurrentSlot.boolIsAvailable && ((objExistingServiceAppointment.End_Date_Time__c > objCurrentSlot.startDT && objExistingServiceAppointment.End_Date_Time__c < objCurrentSlot.endDT) || 
                                (objExistingServiceAppointment.Start_Date_Time__c == objCurrentSlot.startDT && objExistingServiceAppointment.End_Date_Time__c == objCurrentSlot.endDT) || 
                                (objExistingServiceAppointment.Start_Date_Time__c > objCurrentSlot.startDT && objExistingServiceAppointment.End_Date_Time__c < objCurrentSlot.endDT) || 
                                (objExistingServiceAppointment.Start_Date_Time__c > objCurrentSlot.startDT && objExistingServiceAppointment.End_Date_Time__c == objCurrentSlot.endDT) || 
                                (objExistingServiceAppointment.Start_Date_Time__c < objCurrentSlot.endDT && objExistingServiceAppointment.Start_Date_Time__c > objCurrentSlot.startDT) ||
                                (objExistingServiceAppointment.Start_Date_Time__c < objCurrentSlot.startDT && objExistingServiceAppointment.End_Date_Time__c > objCurrentSlot.endDT) || 
                                (objExistingServiceAppointment.Start_Date_Time__c < objCurrentSlot.startDT && objExistingServiceAppointment.End_Date_Time__c == objCurrentSlot.endDT) || 
                                (objExistingServiceAppointment.Start_Date_Time__c == objCurrentSlot.startDT && objExistingServiceAppointment.End_Date_Time__c > objCurrentSlot.endDT))) {
                            if(objExistingServiceAppointment.Environment__c == PRODUCTION && objCurrentSlot.numberOfReservedSlots > 0){
                                objCurrentSlot.numberOfReservedSlots = objCurrentSlot.numberOfReservedSlots - 1;
                            }
                            else if(objCurrentSlot.numberOfCommonSlots > 0){
                                objCurrentSlot.numberOfCommonSlots = objCurrentSlot.numberOfCommonSlots - 1;
                            }
                            if(objCurrentSlot.numberOfCommonSlots <= 0 && objCurrentSlot.numberOfReservedSlots <= 0){
                                objCurrentSlot.boolIsAvailable = false;
                            }
                        }
                    }
                    break;
                }
            }
        }

        /* Clean up the slots which are not available. */
        for(String strDate : mapSlotsByDay.keySet()) {
            lstSlots = new List<OperationsSchedulerWrapper>();
            for(OperationsSchedulerWrapper objCurrentSlot : mapSlotsByDay.get(strDate)) {
                if(environmentType == PRODUCTION){ //<T02>
                    if(objCurrentSlot.numberOfCommonSlots > 0 || objCurrentSlot.numberOfReservedSlots > 0) {
                        lstSlots.add(objCurrentSlot);
                    }
                }
                else{
                    if(objCurrentSlot.numberOfCommonSlots > 0){
                            lstSlots.add(objCurrentSlot);
                    }
                }
            }
            //Include available date only when atleast one or more slots are available.
            if(lstSlots.size() > 0){
                mapSlotsByDayFiltered.put(strDate, lstSlots);
            }
        }

       return mapSlotsByDayFiltered;
    }

    /*
     Method Name : getTimeStr
     Description : This method returns GMT formatted time as string.
     Parameters  : (Time) called from getAvailableSlots.
     Return Type : String value of time.
     */
    private static String getTimeStr(Time iTime){
        return DateTime.newInstanceGMT(System.today(),iTime).formatGMT('HH:mm:ss');
    }

    /*
     Method Name : getDayOfWeek
     Description : This method returns day of week based on the date.
     Parameters  : (Date) called from getAvailableSlots.
     Return Type : String value of time.
     */
    private static String getDayOfWeek(Date iDate){
        DateTime dt = (DateTime) iDate;
        String dayOfWeek = dt.formatGMT('EEEE');
        return dayOfWeek;
    }

    /*
     Method Name : setDateTime
     Description : This method returns datetime based on priority and environment type.
     Parameters  : (String, String) called from setDateTime, priority, environmentType parameters.
     Return Type : DateTime value.
     */
    private static DateTime setDateTime(String priority, String environmentType){
        DateTime dt;

        if(String.isNotEmpty(priority) && String.isNotEmpty(environmentType)){
            if(priority == 'P1'){
                if(environmentType == PRODUCTION){ //<T01> //<T02>
                    dt = System.now().addMinutes(45);
                }
                else{
                    dt = System.now().addHours(1);
                }
            }
            else if(priority == 'P2'){
                dt = System.now().addHours(2);
            }
            else if(priority == 'P3'){
                dt = System.now().addHours(4);
            }
        }

        return dt;
    }

    /*
     Method Name : isEvenHour
     Description : This method checks if the given hour is even and return true or false.
     Parameters  : (Integer) called from isEvenHour.
     Return Type : Boolean value.
     */
    private static Boolean isEvenHour(Integer Hour){ //<T03>
        return isDST() ? !(Math.mod(Hour, 2) == 0) :  Math.mod(Hour, 2) == 0;
    }

    /*
     Method Name : isWeekend
     Description : This method checks if the given datetime falls in the weekend.
     Parameters  : (DateTime)
     Return Type : Boolean.
     */
    private static Boolean isWeekend(DateTime dt){ //<T03>
        String dayOfWeek = getDayOfWeek(dt.dateGMT());
        Boolean boolIsDST = isDST();
        Integer hourInGMT = dt.hourGmt();
        Integer intWeekendStartHour = boolIsDST ? 2 : 3;
        Integer intWeekendEndHour = boolIsDST ? 1 : 2;
        
        return ( (dayOfWeek == 'Saturday' && hourInGMT >= intWeekendStartHour) || dayOfWeek == 'Sunday' || (dayOfWeek == 'Monday' && hourInGMT < intWeekendEndHour) ) ? true : (dayOfWeek == 'Monday' && hourInGMT == intWeekendEndHour+1) ? true : false;
    }

    /*
     Method Name : isWeekendExactEndDT
     Description : This method checks for the exact weekend ending and allows to consider the current datetime as weekday.
     Parameters  : (DateTime)
     Return Type : Boolean.
     */
    private static Boolean isWeekendExactEndDT(DateTime dt){ //<T03>
        String dayOfWeek = getDayOfWeek(dt.dateGMT());
        Integer hourInGMT = dt.hourGmt();
        Integer intWeekendEndHour = isDST() ? 2 : 3;
        
        return (dayOfWeek == 'Monday' && hourInGMT == intWeekendEndHour) ? true : false;
    }

    /*
     Method Name : isWeekendExactEndDT
     Description : This method checks for the exact weekend ending and allows to consider the current datetime as weekday.
     Parameters  : (DateTime)
     Return Type : Boolean.
     */
    @TestVisible
    private static Integer offsetWeekendDayHour(DateTime dt){ //<T03>
        String dayOfWeek = getDayOfWeek(dt.dateGMT());
        Boolean boolIsDST = isDST();
        
        if(dayOfWeek == 'Saturday'){
            return 0;
        }
        else if(dayOfWeek == 'Sunday'){
            return boolIsDST ? 2 : 0;
        }
        else if(dayOfWeek == 'Monday'){
            return boolIsDST ? 2 : 0;
        }
        else{
            return 0;
        }
    }

    /*
     Method Name : isWeekdayOffHour
     Description : This method checks if the given datetime falls in the weekday off hours.
     Parameters  : (DateTime)
     Return Type : Boolean.
     */
    private static Boolean isWeekdayOffHour(DateTime startDT, DateTime endDT){ //<T03>
        String startDT_DayOfWeek = getDayOfWeek(startDT.dateGMT());
        String endDT_DayOfWeek = getDayOfWeek(endDT.dateGMT());
        Boolean boolIsDST = isDST();
        Integer startDT_HourInGMT = startDT.hourGmt();
        Integer endDT_HourInGMT = endDT.hourGmt();
        Integer intStartHour = boolIsDST ? 23 : 0;
        Integer intEndHour = boolIsDST ? 1 : 2;

        return isDST() 
        ?
        ((startDT_DayOfWeek == 'Monday' && startDT_HourInGMT >= intStartHour) && (endDT_DayOfWeek == 'Tuesday' && endDT_HourInGMT <= intEndHour)) || 
        (startDT_DayOfWeek == 'Tuesday' && startDT_HourInGMT == intEndHour) ||
        ((startDT_DayOfWeek == 'Tuesday' && startDT_HourInGMT >= intStartHour) && (endDT_DayOfWeek == 'Wednesday' && endDT_HourInGMT <= intEndHour)) || 
        (startDT_DayOfWeek == 'Wednesday' && startDT_HourInGMT == intEndHour) ||
        ((startDT_DayOfWeek == 'Wednesday' && startDT_HourInGMT >= intStartHour) && (endDT_DayOfWeek == 'Thursday' && endDT_HourInGMT <= intEndHour)) || 
        (startDT_DayOfWeek == 'Thursday' && startDT_HourInGMT >= intEndHour) ||
        ((startDT_DayOfWeek == 'Thursday' && startDT_HourInGMT >= intStartHour) && (endDT_DayOfWeek == 'Friday' && endDT_HourInGMT <= intEndHour)) || 
        (startDT_DayOfWeek == 'Friday' && startDT_HourInGMT >= intEndHour) ||
        ((startDT_DayOfWeek == 'Friday' && startDT_HourInGMT >= intStartHour) && (endDT_DayOfWeek == 'Saturday' && endDT_HourInGMT <= intEndHour)) ||
        (startDT_DayOfWeek == 'Saturday' && startDT_HourInGMT == intEndHour)
        : 
        ((startDT_DayOfWeek == 'Tuesday' && startDT_HourInGMT >= intStartHour) && (endDT_DayOfWeek == 'Tuesday' && endDT_HourInGMT <= intEndHour)) || 
        (startDT_DayOfWeek == 'Tuesday' && startDT_HourInGMT == intEndHour) ||
        ((startDT_DayOfWeek == 'Wednesday' && startDT_HourInGMT >= intStartHour) && (endDT_DayOfWeek == 'Wednesday' && endDT_HourInGMT <= intEndHour)) || 
        (startDT_DayOfWeek == 'Wednesday' && startDT_HourInGMT == intEndHour) ||
        ((startDT_DayOfWeek == 'Thursday' && startDT_HourInGMT >= intStartHour) && (endDT_DayOfWeek == 'Thursday' && endDT_HourInGMT <= intEndHour)) || 
        (startDT_DayOfWeek == 'Thursday' && startDT_HourInGMT == intEndHour) ||
        ((startDT_DayOfWeek == 'Friday' && startDT_HourInGMT >= intStartHour) && (endDT_DayOfWeek == 'Friday' && endDT_HourInGMT <= intEndHour)) || 
        (startDT_DayOfWeek == 'Friday' && startDT_HourInGMT == intEndHour) ||
        ((startDT_DayOfWeek == 'Saturday' && startDT_HourInGMT >= intStartHour) && (endDT_DayOfWeek == 'Saturday' && endDT_HourInGMT <= intEndHour)) ||
        (startDT_DayOfWeek == 'Saturday' && startDT_HourInGMT == intEndHour);
    }

    /*
     Method Name : calculateOffSetHours
     Description : This method calculates the offset hours to carry for the next day.
     Parameters  : (DateTime, DateTime) called from getAvailableSlots
     Return Type : Integer.
     */
    @TestVisible
    private static Integer calculateOffSetHours(DateTime startDateTime, DateTime endDateTime){
        if(endDateTime < startDateTime){
            Integer startHour = (Integer) startDateTime.hourGmt();
            Integer endHour = (Integer) endDateTime.hourGmt();
            Integer offSetHour = startHour - endHour;

            return offSetHour > 0 ? offSetHour : 0;
        }
        else{
            return 0;
        }
    }

    /*
     Method Name : getUserTZ
     Description : This method gets the timezone name from the user.
     Parameters  : None
     Return Type : String.
     */
    private static String getUserTZ(){
        String tzName = [Select Id,TimeZoneSidKey from User where Id =: UserInfo.getUserId()]?.TimeZoneSidKey;
        return tzName;
    }

    /*
     Method Name : isExternalUser
     Description : This method checks if the loggedin user is an externaluser.
     Parameters  : None
     Return Type : Boolean.
     */
    private static Boolean isExternalUser(){
        return [Select Id,IsPortalEnabled from User where Id =: UserInfo.getUserId()]?.IsPortalEnabled == true ? true : false;
    }

    /*
     Method Name : isDST
     Description : This method checks if the timezone is in daylight savings time.
     Parameters  : None
     Return Type : Boolean.
     */
    private static Boolean isDST(){ //<T03>
        TimeZone objTimezone = TimeZone.getTimeZone(DEFAULT_TIMEZONE);
        return objTimezone.getOffset(DateTime.newInstanceGMT(System.today(), Time.newInstance(0,0,0,0))) == DEFAULT_TIMEZONE_DST_OFFSET;
    }

    /*
     Method Name : createServiceAppointment
     Description : This method creates a new Service Appointment and an event.
     Parameters  : (Case, List<DateTime>, String) called from rescheduleSession and CaseController.createCase().
     Return Type : String.
     */
    public static void createServiceAppointment(Case objCase, List<DateTime> slotSelected, String strActionType){ //<T02>
        String userTimeZoneName;
        Id operationsRecordTypeId = Schema.SObjectType.Service_Appointment__c.getRecordTypeInfosByName().get('Operations').getRecordTypeId();
        
        Service_Appointment__c objServiceAppointment = new Service_Appointment__c();
        objServiceAppointment.Support_Account__c = objCase.Support_Account__c;
        objServiceAppointment.Subject__c = 'Operations Appointment';
        objServiceAppointment.Description__c = objCase.Description;
        objServiceAppointment.Start_Date_Time__c = slotSelected[0];
        objServiceAppointment.End_Date_Time__c = slotSelected[1];
        objServiceAppointment.Environment__c = objCase.Environment__c;
        objServiceAppointment.RecordTypeId = operationsRecordTypeId;
        insert objServiceAppointment;

        Event objEvent = new Event();
        objEvent.WhatId = objCase.Id;
        objEvent.Service_Appointment_AAE__c = objServiceAppointment.Id;
        objEvent.Subject = 'Operations Appointment';
        objEvent.ActivityDateTime = objServiceAppointment.Start_Date_Time__c;
        objEvent.StartDateTime = objServiceAppointment.Start_Date_Time__c;
        objEvent.EndDateTime = objServiceAppointment.End_Date_Time__c;
        insert objEvent;

        Case objCaseToUpdate = new Case(Id = objCase.Id);
        objCaseToUpdate.Service_Appointment__c = objServiceAppointment.Id;
        update objCaseToUpdate;

        //Get timezone name from case primary contact, if present, else from the logged in user.
        if(String.isNotEmpty(objCase?.ContactId)){
            String timeZoneId = [SELECT Id,TimeZone_Lookup__c FROM Contact WHERE Id =: objCase.ContactId]?.TimeZone_Lookup__c;
            for(TimeZone__c timezone : [SELECT Id,Name,TimeZoneSidKey__c FROM TimeZone__c WHERE Id =: timeZoneId]){
                userTimeZoneName = timezone?.TimeZoneSidKey__c;
            }
            if(String.isEmpty(userTimeZoneName)){
                userTimeZoneName = getUserTZ();
            }
        }
        else{
            userTimeZoneName = getUserTZ();
        }

        Case_Comment__c objCaseComment = new Case_Comment__c();  
        objCaseComment.Case__c = objCase.Id;
        objCaseComment.Status__c = 'Submitted';
        objCaseComment.Sub_Type__c = 'General Response';
        objCaseComment.Comment_Category__c = 'General Comments';
        objCaseComment.Visibility__c = 'External';

        if(String.isNotEmpty(strActionType) && strActionType == 'Reschedule'){
            //Create a Case Comment when user reschedule's session
            objCaseComment.Inbound__c = isExternalUser() ? true : false; 
            objCaseComment.Comment__c = '<b>Rescheduled Activity Window Details</b><br>Date: '+slotSelected[0].format('MMMMM dd, yyyy',userTimeZoneName)+'<br>Time: '+slotSelected[0].format('hh:mm a z',userTimeZoneName);  
        }
        else if(String.isNotEmpty(strActionType) && strActionType == 'Create'){
            objCaseComment.Inbound__c = false;
            objCaseComment.Comment__c = '<b>Activity Window Details</b><br>Date: '+slotSelected[0].format('MMMMM dd, yyyy',userTimeZoneName)+'<br>Time: '+slotSelected[0].format('hh:mm a z',userTimeZoneName);  
        }
        insert objCaseComment;
    }

    /*
     Method Name : getRescheduleSlots
     Description : This method returns the list of available slots.
     Parameters  : (String) called from getRescheduleSlots.
     Return Type : Map of available slots.
     */
    @AuraEnabled
    public static Map<String, List<OperationsSchedulerWrapper>> getRescheduleSlots(String caseId){

        caseId = (caseId != null) ? String.escapeSingleQuotes(caseId) : caseId;

        Map<String, List<OperationsSchedulerWrapper>> availableSlots = new Map<String, List<OperationsSchedulerWrapper>>();
        Case c = [Select Id,Priority,Environment__c from Case where Id =: caseId];

        if(String.isNotEmpty(c?.Priority) && String.isNotEmpty(c?.Environment__c)){
            availableSlots = getAvailableSlots(c.Priority, c.Environment__c);
        }
        return availableSlots;
    }

    /*
     Method Name : cancelSession
     Description : This method deletes the Service Appointment and the associated event from Case.
     Parameters  : (String, String) called from rescheduleSession.
     Return Type : String.
     */
    public static String cancelSession(String strCaseId, String cancelReason){ //<T02>

        strCaseId = (strCaseId != null) ? String.escapeSingleQuotes(strCaseId) : strCaseId;
        List<SObject> lstSobjectRecords = new List<SObject>();

        if(String.isNotEmpty(strCaseId)){
            for(Case objCase : [SELECT Id,Service_Appointment__c FROM Case WHERE Id = :strCaseId AND Service_Appointment__c != null LIMIT 1]){
                for(Event objEvent : (List<Event>) CaseControllerWithoutSharing.getSObjectRecords('SELECT Id FROM Event WHERE WhatId = \''+objCase.Id+'\' AND Service_Appointment_AAE__c = \''+objCase.Service_Appointment__c+'\' LIMIT 1')){
                    lstSobjectRecords.add(objEvent);
                }
                lstSobjectRecords.add(new Service_Appointment__c(Id = objCase.Service_Appointment__c));
                CaseControllerWithoutSharing.deleteSobjects(lstSobjectRecords);
            }
        }
        return 'Success';
    }

    /*
     Method Name : rescheduleSession
     Description : This method deletes Service Appointment and event associated to the case. Then creates a new Service Appointment and an event.
     Parameters  : (String, String) called from rescheduleSession.
     Return Type : String.
     */
    @AuraEnabled
    public static String rescheduleSession(String caseId, List<DateTime> slotSelected, String mode){
        caseId = (caseId != null) ? String.escapeSingleQuotes(caseId) : caseId;
        mode = (mode != null) ? String.escapeSingleQuotes(mode) : mode;

        String cancelSessionMsg = cancelSession(caseId, '');
        
        if(cancelSessionMsg == 'Success'){
            Case c = [Select Id,Support_Account__c,Subject,Description,Environment__c,Priority,RecordType.Name,ContactId from Case where Id =: caseId];
            if(String.isNotEmpty(c?.Environment__c) && String.isNotEmpty(c?.Priority) && c.RecordType.Name == 'Operations' && slotSelected != null && slotSelected.size() > 0){
                if(String.isNotEmpty(mode)){
                    createServiceAppointment(c, slotSelected, mode);
                }
                else{
                    createServiceAppointment(c, slotSelected, 'Reschedule');
                }
            }
        }

        return 'Success';
    }

    //Wrapper classes
    public class OperationsSchedulerWrapper {
        @AuraEnabled
	    public Boolean boolIsAvailable {get; set;}
        @AuraEnabled
        public DateTime startDT {get; set;}
        @AuraEnabled
        public DateTime endDT {get; set;}
        @AuraEnabled
        public Integer numberOfCommonSlots {get; set;}
        @AuraEnabled
        public Integer numberOfReservedSlots {get; set;}
    }

    public class TimeSlotWrapper{
        @AuraEnabled
        public String dayOfWeek {get; set;}
        @AuraEnabled
        public Time startTime {get; set;}
        @AuraEnabled
        public Time endTime {get; set;}
    }
}