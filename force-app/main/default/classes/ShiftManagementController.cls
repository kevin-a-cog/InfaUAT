/*******************************************************************************************
* @Name         ShiftManagementController 
* @Date         02/20/2021
* @Description  This class is a controller class for Shift Management

Change History
****************************************************************************************************
ModifiedBy      Date        Jira No.    Tag     Description
****************************************************************************************************
balajip         11/22/2021  I2RT-4425   T01     added deleteShiftPlan method, 
                                                included the list of applied/approved allocations in the resource data
                                                set reminder on the Events
balajip         12/15/2021  I2RT-5117   T02     updated the logic for Reminder
balajip         03/01/2022  NA          T03     updated searchShiftPlan method to mitigate SOQL injection 
balajip         09/19/2022  I2RT-7102   T04     updated searchResource method to return only the users with GCS Engineer custom permission
****************************************************************************************************
*/
public without sharing class ShiftManagementController {

    public static Map<String, Id> mapBusinessHoursNameToId = new Map<String, Id>();
    public static List<Id> lstGCSEngineerPermissionSetId = new List<Id>(); //T04

    static{
        Set<String> setBusinessHoursName = new Set<String>();
        for (GCS_Shift__mdt gcsShift : GCS_Shift__mdt.getAll().values()){
            setBusinessHoursName.add(gcsShift.Business_Hours_Name__c);
        }

        List<BusinessHours> lstBusinessHours = [Select Id, Name From BusinessHours Where Name in :setBusinessHoursName];
        for (BusinessHours businessHours : lstBusinessHours){
            mapBusinessHoursNameToId.put(businessHours.Name, businessHours.Id);
        }
        
        //T04 - get the list of Permission Set Ids that has the GCS_Engineer Custom Permission
        List<SetupEntityAccess> lstSetupEntityAccess = [ SELECT ParentId FROM SetupEntityAccess   
                                    WHERE SetupEntityId IN ( SELECT Id FROM CustomPermission   
                                        WHERE DeveloperName = 'GCS_Engineer')
                                    ];
                                    
        for (SetupEntityAccess access : lstSetupEntityAccess){ 
            lstGCSEngineerPermissionSetId.add(access.ParentId); 
        } 
    }

    /**************************************************************************************
    * @Description  This method checks iff the user for which Id is passed is has the custom 
    *               permission assigned specifying them as shift manager
    * @Param		Id - User Id
    * @Return       Boolean - if the user is Shift Manmager o 
    **************************************************************************************/
    @AuraEnabled
    public static Boolean isShiftManager(Id userId) {
        Boolean accessBool;  
        Set < Id > permissionSetIds = new Set < Id >();  
        List < User > userList = new List < User >();  
        for ( SetupEntityAccess access : [ SELECT ParentId FROM SetupEntityAccess   
                                            WHERE SetupEntityId IN ( SELECT Id   
                                                                    FROM CustomPermission   
                                                                    WHERE DeveloperName = :Label.Shift_Management_Manager_Custom_Permission )  
        ] )  { 
            permissionSetIds.add(access.ParentId); 
        } 
            
        userList = [SELECT Username, Phone FROM User WHERE Id IN (
                SELECT AssigneeId FROM PermissionSetAssignment  
                WHERE PermissionSetId IN :permissionSetIds AND AssigneeId = :userId ) ];  
        accessBool = userList.isEmpty() ? false : true;  

        return accessBool;
    }

    /**************************************************************************************
    * @Description  This method fetches the data to be rendered on the shift management view 
    *               for requests and allocations appropriately based on the type of the user 
    *               if its shift manager or not
    * @Param		String - User Id
    * @Param		String - Start time of the shift management view
    * @Param		String - End Time of the shift management view
    * @Param		String - Slot size of the shift management view
    * @Return       List - List containing the shift management data
    **************************************************************************************/
    @AuraEnabled
    public static ChartData getChartData(Boolean asManager, String userId, String startTime, String endTime, Integer slotSize) {
        ChartData chartData = new ChartData();
        if(asManager) {
            chartData = getManagerData(userId, startTime, endTime, slotSize);
        } else {
            chartData = getResourceData(userId, startTime, endTime, slotSize);
        }

        User usr = [Select Id, Phone, Email, TimeZoneSidKey,
                        (Select Id, Name From ManagedUsers) 
                      From User Where Id = :userId];
        UserWrapper userWrapper = new UserWrapper();
        userWrapper.usr = usr;

        chartData.userWrapper = userWrapper;
        return chartData;
    }

    /**************************************************************************************
    * @Description  This method fetches the data to be rendered on the shift management view 
    *               having requests and allocations for shift mamagers
    * @Param		String - User Id
    * @Param		String - Start time of the shift management view
    * @Param		String - End Time of the shift management view
    * @Param		String - Slot size of the shift management view
    * @Return       List - List containing the shift management data
    **************************************************************************************/
    public static ChartData getManagerData(String userId, String startTime, String endTime, Integer slotSize) {
        List<RequestWrapper> wrapperList = new List<RequestWrapper>();
        
        for(Shift_Request__c req : [SELECT Id, format(Shift_Plan__r.Start_Date__c), format(Shift_Plan__r.End_Date__c), Skill__c, Skill__r.Name, Total_Approved_Allocation__c, 
                                        Resource_Count__c, Allocation_Type__c, Shift_Plan__c, Business_Hours__c, Business_Hours__r.Name,
                                        Business_Hours__r.SundayStartTime, Business_Hours__r.MondayStartTime, Business_Hours__r.SundayEndTime, 
                                        Business_Hours__r.MondayEndTime, Business_Hours__r.TuesdayStartTime, Business_Hours__r.TuesdayEndTime, 
                                        Business_Hours__r.WednesdayStartTime, Business_Hours__r.WednesdayEndTime, Business_Hours__r.ThursdayStartTime, 
                                        Business_Hours__r.FridayStartTime, Business_Hours__r.FridayEndTime, Business_Hours__r.SaturdayStartTime, 
                                        Business_Hours__r.SaturdayEndTime, Business_Hours__r.TimeZoneSidKey, Business_Hours__r.ThursdayEndTime,
                                        (SELECT Id, Status__c, Service_Resource__c, Service_Resource__r.RelatedRecord.Name, Service_Resource__r.RelatedRecord.FullPhotoUrl, 
                                            Service_Resource__r.RelatedRecordId,Service_Resource__r.RelatedRecord.ManagerId,
                                            format(Start_Date__c), format(End_Date__c)
                                            FROM Shift_Allocations__r 
                                            WHERE Status__c != 'Rejected'
                                            //AND Start_Date__c <= :Date.valueOf(endTime) 
                                            //AND End_Date__c >= :Date.valueOf(startTime)
                                            ORDER BY CreatedDate ASC, Status__c ASC) 
                                    FROM Shift_Request__c 
                                    WHERE Shift_Plan__r.Start_Date__c <= :Date.valueOf(endTime) 
                                        AND Shift_Plan__r.End_Date__c >= :Date.valueOf(startTime)
                                        AND Shift_Plan__c != null
                                    ORDER BY Skill__r.Name, Shift_Plan__r.Start_Date__c]) {
            List<RequestAllocationWrapper> allocationList = new List<RequestAllocationWrapper>();
            for(Shift_Allocation__c all : req.Shift_Allocations__r) {
                RequestAllocationWrapper raw = new RequestAllocationWrapper();
                raw.allocation = all;
                allocationList.add(raw);
            }
            RequestWrapper reqWrap = new RequestWrapper();
            reqWrap.request = req;
            reqWrap.allocationList = allocationList;
            wrapperList.add(reqWrap);
        }
        
        ChartData chartData = new ChartData();
        chartData.availableRequestList = wrapperList;
        return chartData;
    }

    /**************************************************************************************
    * @Description  This method fetches the data to be rendered on the shift management view 
    *               having requests and allocations for engineers
    * @Param		String - User Id
    * @Param		String - Start time of the shift management view
    * @Param		String - End Time of the shift management view
    * @Param		String - Slot size of the shift management view
    * @Return       List - List containing the shift management data
    **************************************************************************************/
    public static ChartData getResourceData(String userId, String startTime, String endTime, Integer slotSize) {
        List<RequestWrapper> availableRequestList = new List<RequestWrapper>();
        List<RequestWrapper> unavailableRequestList = new List<RequestWrapper>();

        List<ServiceResource> srList = new List<ServiceResource>();
        srList = [SELECT Id FROM ServiceResource WHERE RelatedRecordId = :userId];

        if(srList.isEmpty()) {
            return null;
        }

        Set<Id> skillIdSet = new Set<Id>();
        for(ProfileSkillUser srs : [SELECT ProfileSkillId FROM ProfileSkillUser WHERE UserId = :userId]) {
            skillIdSet.add(srs.ProfileSkillId);
        }
        
        for(Shift_Request__c req : [SELECT Id, format(Shift_Plan__r.Start_Date__c), format(Shift_Plan__r.End_Date__c), Skill__c, Skill__r.Name,  
                                        Resource_Count__c, Allocation_Type__c, Shift_Plan__c, Business_Hours__c, Business_Hours__r.Name, Total_Approved_Allocation__c, 
                                        Business_Hours__r.SundayStartTime, Business_Hours__r.MondayStartTime, Business_Hours__r.SundayEndTime, 
                                        Business_Hours__r.MondayEndTime, Business_Hours__r.TuesdayStartTime, Business_Hours__r.TuesdayEndTime, 
                                        Business_Hours__r.WednesdayStartTime, Business_Hours__r.WednesdayEndTime, Business_Hours__r.ThursdayStartTime, 
                                        Business_Hours__r.FridayStartTime, Business_Hours__r.FridayEndTime, Business_Hours__r.SaturdayStartTime, 
                                        Business_Hours__r.SaturdayEndTime, Business_Hours__r.TimeZoneSidKey, Business_Hours__r.ThursdayEndTime,
                                        (SELECT Id, Status__c, Service_Resource__c, Service_Resource__r.RelatedRecordId,
                                        Service_Resource__r.RelatedRecord.Name, Service_Resource__r.RelatedRecord.FullPhotoUrl, 
                                            format(Start_Date__c), format(End_Date__c), Contact_Number__c, Location__c, Shift_Type__c
                                        FROM Shift_Allocations__r 
                                        WHERE Status__c != 'Rejected'
                                            //AND Service_Resource__c = :srList[0].Id
                                            //AND Start_Date__c <= :Date.valueOf(endTime) 
                                            //AND End_Date__c >= :Date.valueOf(startTime)
                                        ORDER BY Status__c ASC) 
                                    FROM Shift_Request__c 
                                    WHERE Shift_Plan__r.Start_Date__c <= :Date.valueOf(endTime) 
                                        AND Shift_Plan__r.End_Date__c >= :Date.valueOf(startTime)
                                        AND Shift_Plan__c != null
                                        ORDER BY Skill__r.Name, Shift_Plan__r.Start_Date__c]) {
            List<RequestAllocationWrapper> allocationList = new List<RequestAllocationWrapper>();

            List<String> appliedResourceList = new List<String>();//T01
            List<String> approvedResourceList = new List<String>();//T01
            for(Shift_Allocation__c all : req.Shift_Allocations__r) {
                if(all.Service_Resource__c == srList[0].Id){
                    RequestAllocationWrapper raw = new RequestAllocationWrapper();
                    raw.allocation = all;
                    allocationList.add(raw);
                }
                //T01
                if(all.Status__c == 'Pending'){
                    appliedResourceList.add(all.Service_Resource__r.RelatedRecord.Name);
                }else if(all.Status__c == 'Approved'){
                    approvedResourceList.add(all.Service_Resource__r.RelatedRecord.Name);
                }
            }
            RequestWrapper reqWrap = new RequestWrapper();
            reqWrap.request = req;
            reqWrap.allocationList = allocationList;
            reqWrap.appliedResourceList = appliedResourceList;//T01
            reqWrap.approvedResourceList = approvedResourceList;//T01
            reqWrap.unassignedProduct = true;
            if(skillIdSet.contains(req.Skill__c)) {
                reqWrap.unassignedProduct = false;
            }
        
            /*if(Label.Shift_Type_Not_Requiring_Skill.split(';').contains(req.Allocation_Type__c)) {
                if(Label.Shift_Type_Escalation_Manager != req.Allocation_Type__c || 
                    (Label.Shift_Type_Escalation_Manager == req.Allocation_Type__c && (isShiftManager(UserInfo.getUserId()) || !req.Shift_Allocations__r.isEmpty()))) {
                    availableRequestList.add(reqWrap);
                }
            } else {
                if(skillIdSet.contains(req.Skill__c)) {
                    availableRequestList.add(reqWrap);
                } else {
                    unavailableRequestList.add(reqWrap);
                }
            }*/
            availableRequestList.add(reqWrap);
        }
        
        ChartData chartData = new ChartData();
        chartData.availableRequestList = availableRequestList;
        chartData.unavailableRequestList = unavailableRequestList;
        return chartData;
    }

    private static Shift_Date__c getShiftDateRecord(Shift_Plan__c shiftPlan, Date shiftDate){
        Shift_Date__c shiftDateRecord;

        System.debug('getShiftDateRecord.. shiftDate >> ' + shiftDate);

        System.debug('getShiftDateRecord.. TimeZoneSidKey >> ' + shiftPlan.Business_Hours__r.TimeZoneSidKey);
        Timezone tz = Timezone.getTimeZone(shiftPlan.Business_Hours__r.TimeZoneSidKey);

        Datetime shiftDateTime = datetime.newInstanceGMT(shiftDate.year(), shiftDate.month(),shiftDate.day());
        System.debug('getShiftDateRecord.. before offset shiftDateTime >> ' + shiftDateTime);

        shiftDateTime = shiftDateTime.addSeconds(-(tz.getOffset(shiftDateTime))/1000);
        System.debug('getShiftDateRecord.. after offset shiftDateTime >> ' + shiftDateTime);
        
        DateTime startDateTime = BusinessHours.nextStartDate(shiftPlan.Business_Hours__c, shiftDateTime);
        System.debug('getShiftDateRecord.. startDateTime >> ' + startDateTime);
        if((startDateTime.getTime() - shiftDateTime.getTime()) < 24*60*60*1000){
            Long totalMilliSecs = BusinessHours.diff(shiftPlan.Business_Hours__c, shiftDateTime, shiftDateTime.addDays(1));
            System.debug('getShiftDateRecord.. totalMilliSecs >> ' + totalMilliSecs);
            
            DateTime endDateTime = startDateTime.addSeconds(Integer.valueOf(totalMilliSecs/1000));
            System.debug('getShiftDateRecord.. endDateTime >> ' + endDateTime);
    
            shiftDateRecord = new Shift_Date__c();
            shiftDateRecord.Shift_Plan__c = shiftPlan.Id;
            shiftDateRecord.Start_Date_Time__c = startDateTime;
            shiftDateRecord.End_Date_Time__c = endDateTime;    
        }
        return shiftDateRecord;
    }

    //identifies the business hours based on the Type
    private static Id getBusinessHoursId(Shift_Plan__c shiftPlan){
        Id businessHoursId;

        Date dstStartDate = date.newinstance(shiftPlan.Start_Date__c.year(), 3, (2*7+1)).toStartofWeek();
        Date dstEndDate = date.newinstance(shiftPlan.Start_Date__c.year(), 11, (1*7+1)).toStartofWeek();
        Boolean isDSTOn = false;
        if(shiftPlan.Start_Date__c >= dstStartDate && shiftPlan.Start_Date__c <= dstEndDate){
            isDSTOn = true;
        }
        for (GCS_Shift__mdt gcsShift : GCS_Shift__mdt.getAll().values()){
            if(shiftPlan.Type__c == gcsShift.Shift_Type__c && !gcsShift.During_DST__c){
                businessHoursId = mapBusinessHoursNameToId.get(gcsShift.Business_Hours_Name__c);
            }
        }
        if(isDSTOn){
            for (GCS_Shift__mdt gcsShift : GCS_Shift__mdt.getAll().values()){
                if(shiftPlan.Type__c == gcsShift.Shift_Type__c && gcsShift.During_DST__c){
                    businessHoursId = mapBusinessHoursNameToId.get(gcsShift.Business_Hours_Name__c);
                }
            }    
        }

        return businessHoursId;
    }

    //T02
    //creates a Calendar Event for the given Shift Request
    public static Event createCalendarEvent(Event evnt, Shift_Request__c shiftRequest){
        List<Calendar> lstCalendar = [SELECT Id FROM Calendar WHERE Name = :Label.Shift_Calendar_Name]; 

        if (evnt == null){
            evnt = new Event();
        }
        evnt.OwnerId = lstCalendar[0].Id;
        evnt.WhatId = shiftRequest.Id;
        evnt.Subject = shiftRequest.Skill__r.Name + ': ' + shiftRequest.Allocation_Type__c;
        evnt.ShowAs = 'Free';

        Date startDate = shiftRequest.Shift_Plan__r.Start_Date__c;
        Datetime dt = datetime.newInstance(startDate.year(), startDate.month(),startDate.day());
        Datetime startDateTime = BusinessHours.nextStartDate(shiftRequest.Business_Hours__c, dt);
        System.debug('createShiftPlanAndRequest, startDateTime - ' + startDateTime);

        Long duration = BusinessHours.diff(shiftRequest.Business_Hours__c, dt, dt.addDays(1));
        Datetime endDateTime = startDateTime.addSeconds(Integer.valueOf(duration/1000));//StartDateTime.addHours(8);
        System.debug('createShiftPlanAndRequest, endDateTime - ' + endDateTime);

        evnt.StartDateTime = startDateTime;
        evnt.EndDateTime = endDateTime;
        evnt.ActivityDateTime = startDateTime;
        //T01
        evnt.ReminderDateTime = startDateTime.addDays(-1).addMinutes(1);
        evnt.IsReminderSet = true;

        if(shiftRequest.Shift_Plan__r.End_Date__c > shiftRequest.Shift_Plan__r.Start_Date__c){
            if(evnt.Id == null){
                evnt.IsRecurrence = true;
            }
            evnt.RecurrenceStartDateTime = startDateTime;
            evnt.RecurrenceEndDateOnly = shiftRequest.Shift_Plan__r.End_Date__c;
            evnt.RecurrenceType = 'RecursDaily';
            evnt.RecurrenceInterval = 1; // This means that the event will wait 1 day before recurring again    
        }

        return evnt;
    }

    /**************************************************************************************
    * @Description  This method creates a list of Shift Request records
    * @Param		List - having Shift Request record to be inserted
    **************************************************************************************/
    @AuraEnabled
    public static void createShiftPlanAndRequest(List<Shift_Request__c> lstShiftRequestToUpsert, List<String> lstShiftRequestToDeleteId) {
        List<Shift_Date__c> lstShiftDatesToDelete = new List<Shift_Date__c>();
        List<Shift_Date__c> lstShiftDateToInsert = new List<Shift_Date__c>();

        if(lstShiftRequestToUpsert.get(0).Shift_Plan__c != null){
            Shift_Plan__c shiftPlan = [Select Id, Type__c, Start_Date__c, End_Date__c, 
                                            Business_Hours__c, Business_Hours__r.TimeZoneSidKey 
                                        From Shift_Plan__c 
                                        Where Id = :lstShiftRequestToUpsert.get(0).Shift_Plan__c];

            System.debug('shiftPlan = ' + shiftPlan);

            //T01
            if(shiftPlan.Business_Hours__c == null){
                Id businessHoursId = getBusinessHoursId(shiftPlan);
                shiftPlan.Business_Hours__c = businessHoursId;
                update shiftPlan;    

                for(Shift_Request__c shiftRequest : lstShiftRequestToUpsert){
                    shiftRequest.Business_Hours__c = businessHoursId;
                }
            }
            shiftPlan = [Select Id, Business_Hours__c, Business_Hours__r.TimeZoneSidKey, Start_Date__c, End_Date__c From Shift_Plan__c Where Id = :shiftPlan.Id];

            lstShiftDatesToDelete = [Select Id From Shift_Date__c Where Shift_Plan__c = :shiftPlan.Id];
            for(Date shiftDate = shiftPlan.Start_Date__c; shiftDate <= shiftPlan.End_Date__c; shiftDate = shiftDate.addDays(1)){
                Shift_Date__c shiftDateRecord = getShiftDateRecord(shiftPlan, shiftDate);
                if(shiftDateRecord != null){
                    lstShiftDateToInsert.add(shiftDateRecord);
                }
            }
        }
        
        upsert lstShiftRequestToUpsert;

        if(!lstShiftRequestToDeleteId.isEmpty()) {
            List<Shift_Request__c> lstShiftRequestToDelete = new List<Shift_Request__c>();
            for(String srId : lstShiftRequestToDeleteId) {
                lstShiftRequestToDelete.add(new Shift_Request__c(Id = srId));
            }
            delete lstShiftRequestToDelete;
        }

        if(!lstShiftDateToInsert.isEmpty()){
            insert lstShiftDateToInsert;

            if(!lstShiftDatesToDelete.isEmpty()){
                delete lstShiftDatesToDelete;
            }
        }

        Set<Id> setShiftRequestId = new set<Id>();
        for(Shift_Request__c shiftRequest : lstShiftRequestToUpsert){
            setShiftRequestId.add(shiftRequest.Id);
        }

        List<Event> lstEvent = [Select Id, WhatId, OwnerId, Subject, ActivityDateTime, StartDateTime, EndDateTime, IsRecurrence 
                                    From Event 
                                    Where WhatId in :setShiftRequestId And IsChild = false];
        Map<Id, Event> mapShiftRequestIdToEvent = new Map<Id, Event>();
        for(Event evnt : lstEvent){
            if(mapShiftRequestIdToEvent.containsKey(evnt.WhatId)){
                if(evnt.IsRecurrence){
                    mapShiftRequestIdToEvent.put(evnt.WhatId, evnt);
                }
            }else{
                mapShiftRequestIdToEvent.put(evnt.WhatId, evnt);
            }
        }

        List<Shift_Request__c> lstShiftRequest = [Select Id, Allocation_Type__c, Skill__c, Shift_Plan__c, Business_Hours__c,
                                                    Skill__r.Name, Shift_Plan__r.Start_Date__c, Shift_Plan__r.End_Date__c,
                                                    Business_Hours__r.SundayStartTime, Business_Hours__r.MondayStartTime, Business_Hours__r.SundayEndTime, 
                                                    Business_Hours__r.MondayEndTime, Business_Hours__r.TuesdayStartTime, Business_Hours__r.TuesdayEndTime, 
                                                    Business_Hours__r.WednesdayStartTime, Business_Hours__r.WednesdayEndTime, Business_Hours__r.ThursdayStartTime, 
                                                    Business_Hours__r.FridayStartTime, Business_Hours__r.FridayEndTime, Business_Hours__r.SaturdayStartTime, 
                                                    Business_Hours__r.SaturdayEndTime, Business_Hours__r.TimeZoneSidKey, Business_Hours__r.ThursdayEndTime
                                                From Shift_Request__c Where Id in :setShiftRequestId];
        
        List<Event> lstEventToUpsert = new List<Event>();
        for(Shift_Request__c shiftRequest : lstShiftRequest){
            Event evnt = new Event();
            if(mapShiftRequestIdToEvent.containsKey(shiftRequest.Id)){
                evnt = mapShiftRequestIdToEvent.get(shiftRequest.Id);
            }

            System.debug('createShiftPlanAndRequest, shift start date - ' + shiftRequest.Shift_Plan__r.Start_Date__c);
            System.debug('createShiftPlanAndRequest, shift end date - ' + shiftRequest.Shift_Plan__r.End_Date__c);

            //T02
            evnt = createCalendarEvent(evnt, shiftRequest);
            
            lstEventToUpsert.add(evnt);
        }
        if(!lstEventToUpsert.isEmpty()){
            //upsert lstEventToUpsert;
            for(Event evnt : lstEventToUpsert){
                String eventData = JSON.serialize(evnt);
                ShiftManagementController.updateEvent(eventData);
            }
        }
    }

    @future
    public static void updateEvent(String eventData){
        Event evnt = (Event) JSON.deserialize(eventData, Event.class);
        upsert evnt;
    }

    /**************************************************************************************
    * @Description  This method returns the Shift Request records attached to Shift Plan
    * @Param		String - Id of the Shift Plan
    * @Return       List - List having the Shift Request records for passed in shift plan
    **************************************************************************************/
    @AuraEnabled
    public static List<Shift_Request__c> getShiftRequestForShiftPlan(String shiftPlanId) {
        return [SELECT Id, Skill__c, Skill__r.Name, Allocation_Type__c, Shift_Plan__c, Resource_Count__c, Business_Hours__c, Business_Hours__r.Name 
                FROM Shift_Request__c 
                WHERE Shift_Plan__c = :shiftPlanId];
    }

    @AuraEnabled(cacheable=true)
    public static User getUserDetails(String userId) {
        return  [Select Id, Name, Email, Phone from User where Id =:userId];
    }

    /**************************************************************************************
    * @Description  This method return users reporting to current user
    * @Return       List - List of the users reporting to current user
    **************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<User> getMyTeam() {
        return [SELECT Id, Name, Email, Phone 
                    FROM User 
                    WHERE (ManagerId = :UserInfo.getUserId() OR Id = :UserInfo.getUserId()) 
                        AND IsActive = true];
    }

    /**************************************************************************************
    * @Description  This method creates Shift Allocation record using passed in data
    * @Param		String - Start date of the shift management view
    * @Param		String - End date of the shift management view
    * @Param		String - Id of the user for which Shift Allocation to be created
    * @Return       String - Id of the Shift Request for which Shift Allocation to be created
    **************************************************************************************/
    @AuraEnabled
    public static void createShiftAllocation(String startDate, String endDate, String userId, String reqId, String phone, String location, String shiftType) {
        if(String.isEmpty(userId)) {
            return;
        }

        List<Shift_Request__c> lstShiftRequest = new List<Shift_Request__c>();
        lstShiftRequest = [Select Allocation_Type__c, Shift_Plan__c, Shift_Plan__r.Start_Date__c, Shift_Plan__r.End_Date__c,
                                (Select Id, Status__c From Shift_Allocations__r Where Service_Resource__r.RelatedRecordId = :userId) 
                            From Shift_Request__c Where Id = :reqId];

        if(!lstShiftRequest.isEmpty()) {
            Shift_Request__c shiftRequest = lstShiftRequest.get(0);

            Shift_Allocation__c shiftAllocation = new Shift_Allocation__c();
            if(!shiftRequest.Shift_Allocations__r.isEmpty()){
                shiftAllocation = shiftRequest.Shift_Allocations__r.get(0);
                //I2RT-4697
                if('Rejected'.equals(shiftAllocation.Status__c)){
                    shiftAllocation.Status__c = 'Pending';
                }
            }else{
                List<ServiceResource> lstServiceResource = new List<ServiceResource>();
                lstServiceResource = [SELECT Id FROM ServiceResource WHERE RelatedRecordId = :userId];
                
                if(lstServiceResource.isEmpty()) {
                    return;
                }
                shiftAllocation = new Shift_Allocation__c(
                    Start_Date__c = shiftRequest.Shift_Plan__r.Start_Date__c, //Date.valueOf(startDate),
                    End_Date__c = shiftRequest.Shift_Plan__r.End_Date__c, //Date.valueOf(endDate),
                    Shift_Request__c = reqId,
                    Status__c = 'Pending',
                    Service_Resource__c = lstServiceResource[0].Id
                );
            }
            shiftAllocation.Contact_Number__c = phone;
            shiftAllocation.Location__c = location;
            shiftAllocation.Shift_Type__c = shiftType;
            upsert shiftAllocation;
    
            if(shiftAllocation.Status__c == 'Pending' && isShiftManager(UserInfo.getUserId())) {
                processShiftAllocation(shiftAllocation.Id, 'Approve');
            }
        }
    }

    /**
    * This method will Approve/Reject the Shift Allocation
    **/
    public static Approval.ProcessWorkitemRequest getProcessWorkitemRequest(Id workItemId, String approvalStatus) {
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Processing allocation approval/rejection via Apex');
        req.setAction(approvalStatus);

        if(workItemId == null) {
            throw new AuraHandledException('Error occurred while Approving/Rejecting the allocation');
        } else {
            req.setWorkitemId(workItemId);
            return req;
        }
    }

    public static void approveOrRejectRecord(Id recordId, String approvalStatus){
        List<Id> lstWorkItemId = getWorkItemId(new List<Id> {recordId});

        if(!lstWorkItemId.isEmpty()){
            Id workItemId = lstWorkItemId.get(0);
            Approval.ProcessWorkitemRequest req = getProcessWorkitemRequest(workItemId, approvalStatus);
            Approval.ProcessResult result = Approval.process(req);    
        }
    }

    public static void approveOrRejectRecords(Set<Id> setRecordId, String approvalStatus) {
        List<Id> lstWorkItemId = getWorkItemId(new List<Id>(setRecordId)); 

        List<Approval.ProcessWorkitemRequest> allReq = new List<Approval.ProcessWorkitemRequest>();                                    
        for(Id workItemId : lstWorkItemId) {
            Approval.ProcessWorkitemRequest req = getProcessWorkitemRequest(workItemId, approvalStatus);
            allReq.add(req);
        } 
        if(!allReq.isEmpty()) {
            Approval.ProcessResult[] result2 =  Approval.process(allReq);
        }
    }

    /**************************************************************************************
    * @Description  This method is used to reject shift allocation colliding with the time of
    *               the Shift Allocation for the passed in Id if its approving, approve/rejects
    *               the Shift Allocation for which Id is passed in and if Shift allocation is 
    *               approved then creates a Calender event in public Shift Management Calendar 
    *               as well as user's calendar
    * @Param		String - Id of the approved Shift Allocation to be approved/rejectes
    * @Param		String - End date of the shift management view
    **************************************************************************************/
    @AuraEnabled
    public static void processShiftAllocation(String shiftAllocationId, String status) {
        List<Shift_Allocation__c> lstShiftAllocation = new List<Shift_Allocation__c>();
        lstShiftAllocation = [SELECT Id, Start_Date__c, End_Date__c, Service_Resource__c, Service_Resource__r.RelatedRecordId,
                                    Shift_Request__c, Shift_Request__r.Skill__c, Shift_Request__r.Allocation_Type__c, 
                                    Shift_Request__r.Skill__r.Name, Shift_Request__r.Total_Approved_Allocation__c, 
                                    Shift_Request__r.Resource_Count__c, Shift_Request__r.Business_Hours__c,
                                    Shift_Request__r.Shift_Plan__c,
                                    Shift_Request__r.Shift_Plan__r.Start_Date__c, Shift_Request__r.Shift_Plan__r.End_Date__c
                                FROM Shift_Allocation__c 
                                WHERE Id = :shiftAllocationId];

        if(lstShiftAllocation.isEmpty()) {
            return;
        }
        Shift_Allocation__c shiftAllocation = lstShiftAllocation[0];
        Id shiftPlanId = shiftAllocation.Shift_Request__r.Shift_Plan__c;
        
        approveOrRejectRecord(Id.valueOf(shiftAllocationId), status);

        //T02
        List<Event> lstEvent = [Select Id, IsRecurrence From Event 
                                      Where WhatId = :shiftAllocation.Shift_Request__c
                                        And IsChild = false];
        Event evnt;
        if(!lstEvent.isEmpty()){
            for(Event eventIter : lstEvent){
                evnt = eventIter;
                if(evnt.IsRecurrence){
                    break;
                }
            }
        }
        
        if(status == 'Approve') {
            if(evnt == null){
                //T02
                evnt = createCalendarEvent(evnt, shiftAllocation.Shift_Request__r);
                insert evnt;
            }

            EventRelation eventRelation = new EventRelation();
            eventRelation.EventId = evnt.Id;
            eventRelation.RelationId = shiftAllocation.Service_Resource__r.RelatedRecordId;
            eventRelation.Status = 'Accepted';
            try{
                insert eventRelation;
            }catch(exception ex){
                System.debug('expection occurred while trying to create an event - ' + ex.getMessage());
            }
        
            Set<Id> setShiftAllocationIdToReject = new Set<Id>();
            for(Shift_Allocation__c sa : [SELECT Id  
                                                FROM Shift_Allocation__c 
                                                WHERE Shift_Request__r.Shift_Plan__c != :shiftPlanId
                                                AND Service_Resource__c = :shiftAllocation.Service_Resource__c
                                                AND Start_Date__c <= :Date.valueOf(shiftAllocation.End_Date__c) 
                                                AND End_Date__c >= :Date.valueOf(shiftAllocation.Start_Date__c)
                                                AND Status__c NOT IN :new List<String>{'Rejected', 'Approved'}]) 
            {
                setShiftAllocationIdToReject.add(sa.Id);
            }

            Shift_Request__c shiftRequest = [Select Id, Shift_Plan__c, Total_Approved_Allocation__c, Resource_Count__c,
                                                  (Select Id, Service_Resource__c, Status__c From Shift_Allocations__r) 
                                                From Shift_Request__c 
                                                Where Id =:shiftAllocation.Shift_Request__c];

            if(shiftRequest.Total_Approved_Allocation__c >= shiftRequest.Resource_Count__c){
                Set<Id> setAllocatedResourceId = new Set<Id>();
                for(Shift_Allocation__c sa : shiftRequest.Shift_Allocations__r){
                    if(sa.Status__c == 'Approved'){
                        setAllocatedResourceId.add(sa.Service_Resource__c);
                    }
                }
                for(Shift_Allocation__c sa : shiftRequest.Shift_Allocations__r){
                    if(sa.Status__c != 'Approved' && sa.Status__c != 'Rejected'  && !setAllocatedResourceId.contains(sa.Service_Resource__c)){
                        setShiftAllocationIdToReject.add(sa.Id);
                    }
                }
            }

            approveOrRejectRecords(setShiftAllocationIdToReject, 'Reject');
        }else if(status == 'Reject') { //T02
            //remove the User from the Calendar Event
            if(evnt != null){
                List<EventRelation> lstEventRelationToDelete = [Select Id From EventRelation 
                                                        Where EventId = :evnt.Id And RelationId = :shiftAllocation.Service_Resource__r.RelatedRecordId];
                
                if(!lstEventRelationToDelete.isEmpty()){
                    delete lstEventRelationToDelete;
                }
            }
        }
    }

    public class RequestAllocationWrapper {
        @AuraEnabled public Shift_Allocation__c allocation{get;set;}
    }

    public class RequestWrapper {
        @AuraEnabled public Shift_Request__c request {get;set;}
        @AuraEnabled public List<RequestAllocationWrapper> allocationList {get;set;}
        @AuraEnabled public Boolean unassignedProduct {get;set;}
        @AuraEnabled public List<String> appliedResourceList {get;set;}//T01
        @AuraEnabled public List<String> approvedResourceList {get;set;}//T01
    }

    public class UserWrapper{
        @AuraEnabled public User usr{get;set;}
        @AuraEnabled public Boolean isManager{get;set;}
    }

    public class ChartData {
        @AuraEnabled public List<RequestWrapper> availableRequestList{get;set;}
        @AuraEnabled public List<RequestWrapper> unavailableRequestList{get;set;}
        @AuraEnabled public UserWrapper userWrapper{get;set;}
    }
    
    /**************************************************************************************
    * @Description  This method is used to search existing Shift Plan while creating new 
    *               shift request 
    *               as well as user's calendar
    * @Param		String - search key to be used to search Shift Plan records
    **************************************************************************************/
    @AuraEnabled
    public static List<Shift_Plan__c> searchShiftPlan(String searchText){
        String search = '\'%' + String.escapeSingleQuotes(searchText)  + '%\''; //T03
        String query = 'SELECT Id, Name, Start_Date__c, End_Date__c FROM Shift_Plan__c WHERE Name LIKE ' + search + ' LIMIT 10';
        return Database.query(query);
    }
    
    /**************************************************************************************
    * @Description  This method is used to fetch OOO dates for the user
    *               as well as user's calendar
    * @Param		String - user Id 
    **************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Event> getOOODates(String userId) {
        return [SELECT StartDateTime, EndDateTime FROM Event WHERE OwnerId = :userId AND ShowAs = 'OutOfOffice'];
    }

    /**************************************************************************************
    * @Description  This method is used to search users either reporting to logged in user or all
    *               as well as user's calendar
    * @Param		String - search key to be used to search Shift Plan records
    * @Param        Boolean - denotes if the searc his limited to the users reporting to current user or all
    **************************************************************************************/
    @AuraEnabled
    public static List<User> searchResource(String searchText, Boolean isMyTeam) {
        String search = '\'%' + String.escapeSingleQuotes(searchText)  + '%\'';
        String currentUserId = UserInfo.getUserId();

        //T04 - added condition to filter out the users not having GCS Engineer Custom Permission
        String query = 'SELECT Id, Name, Email, Phone FROM User';
        query += ' WHERE IsActive = true AND Name LIKE ' + search;
        if(isMyTeam){
            query += ' AND ManagerId = :currentUserId';
        }
        query += ' AND Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId IN :lstGCSEngineerPermissionSetId)';
        query += ' LIMIT 5';

        return Database.query(query);
    }

    /**
	* Get ProcessInstanceWorkItemId using SOQL
	**/
    @AuraEnabled
    public static List<Id> getWorkItemId(List<Id> targetObjectIdSet) {
        List<Id> piwIdList = new List<Id>();

        for(ProcessInstanceWorkitem workItem : [SELECT Id 
                                                FROM ProcessInstanceWorkitem 
                                                WHERE ProcessInstance.TargetObjectId = :targetObjectIdSet
                                                AND ProcessInstance.Status = 'Pending']) {
                                                    piwIdList.add(workItem.Id);
        }

        return piwIdList;
    }

    /**************************************************************************************
    * @Description  This method is used to check if shift plan can be edited. Check is done '
                    by looking at the number of allocations for each request
    * @Param		String - Id of the Shift Plan
    **************************************************************************************/
    @AuraEnabled
    public static Boolean canEditShiftPlan(String shiftPlanId) {
        Boolean isShiftPlanEditable = true;
        for(Shift_Request__c sr : [SELECT Id, Shift_Plan__c, 
                                   (SELECT Id FROM Shift_Allocations__r WHERE Status__c != 'Rejected') 
                                   FROM Shift_Request__c 
                                   WHERE Shift_Plan__c = :shiftPlanId]) {
            if(sr.Shift_Allocations__r.size() != 0) {
                isShiftPlanEditable = false;
                break;
            }
        }
        return isShiftPlanEditable;
    }

    /**************************************************************************************
    * @Description  This method is used to get Shift Plan with Requests data
    * @Param		String - Id of the Shift Plan
    **************************************************************************************/
    @AuraEnabled()
    public static Shift_Plan__c getShiftPlanWithRequests(String shiftPlanId){
        if(String.isNotBlank(shiftPlanId)) {
            return [SELECT Id, Name, Start_Date__c, End_Date__c, Type__c, Business_Hours__c,
                    (SELECT Id FROM Shift_Requests__r) 
                    FROM Shift_Plan__c 
                    WHERE Id = :shiftPlanId][0];
        } else {
            return null;
        }
    }

    //T01
    @AuraEnabled
    public static void deleteShiftPlan(String shiftPlanId){
        try {
            List<Shift_Plan__c> lstShiftPlan = [Select Id From Shift_Plan__c Where Id = :shiftPlanId];
            List<Shift_Request__c> lstShiftRequest = [Select Id From Shift_Request__c Where Shift_Plan__c = :shiftPlanId];
            List<Shift_Allocation__c> lstShiftAllocation = [Select Id From Shift_Allocation__c Where Shift_Request__r.Shift_Plan__c = :shiftPlanId];
        
            if(!lstShiftAllocation.isEmpty()){
                delete lstShiftAllocation;
            }
            if(!lstShiftRequest.isEmpty()){
                delete lstShiftRequest;
            }
            if(!lstShiftPlan.isEmpty()){
                delete lstShiftPlan;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}