/**
 * @description       : 
 * @author            : Tejasvi Royal
 * @group             : 
 * @last modified on  : 09-09-2021
 * @last modified by  : Tejasvi Royal
 
 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************
 balajip        07/28/2022  I2RT-6740   T01     to capture the list of users added/removed
 balajip        07/28/2022  I2RT-7099   T02     to remove only the Shift Users from the Weekend Support Teams Channel
**/
public with sharing class WeekendHoliday_Support_Start {
    
    //T01 - get the Shift Date Id as the parameter instead of Shift Plan
    @InvocableMethod(label='Weekend/Holiday Support Start' description='Start actions for Weekend/Holiday Support.')
    public static void requestWeekendHolidaySupport(List<Id> lstShiftDateId) {
        //T01 - get the Shift Plan Id from the Shift Date record.
        Id shiftDateId = lstShiftDateId.get(0);
        Shift_Date__c shiftDate = [Select Id, Shift_Plan__c, Status__c, Users_Added__c, Users_Removed__c From Shift_Date__c Where Id = :shiftDateId];
               
        Id shiftPlanId = shiftDate.Shift_Plan__c;
        // Pull all approved (status__c = approved) Shift Allocation (SA) records associated to the Shift Plan
        List<Shift_Allocation__c> saMainList = [SELECT Id, Name, Shift_Request__r.Skill__r.Name, Service_Resource__r.RelatedRecordId, Service_Resource__r.RelatedRecord.Name //T01
                                                FROM Shift_Allocation__c 
                                                WHERE Shift_Request__r.Shift_Plan__c = :shiftPlanId
                                                AND Status__c = 'Approved'
                                                AND (Shift_Request__r.Allocation_Type__c like 'Weekend%'
                                                OR Shift_Request__r.Allocation_Type__c like 'Holiday%')];
        
        //Enhancement -> Handling Shift Requests for SEs, EMs & PSs in the Shift Plan
        List<Shift_Allocation__c> saSEList = new List<Shift_Allocation__c>();
        List<Shift_Allocation__c> saEMList = new List<Shift_Allocation__c>();
        List<Shift_Allocation__c> saPSList = new List<Shift_Allocation__c>();
        
        for(Shift_Allocation__c sa : saMainList) {
            if(String.valueOf(sa.Shift_Request__r.Skill__r.Name).endsWith(' - PS')) {
                saPSList.add(sa);
            }
            else if(String.valueOf(sa.Shift_Request__r.Skill__r.Name).equals('Escalation Manager')) {
                saEMList.add(sa);
            }
            else {
                saSEList.add(sa);
            }
        }
        
        System.debug('saSEList ' + saSEList);
        System.debug('saEMList ' + saEMList);
        System.debug('saPSList ' + saPSList);
        
        if(!saSEList.isEmpty()) {
            handleRequestWeekendHolidaySupport(saSEList, 'W/H Support Notifications Support Engineers');
        }
        if(!saEMList.isEmpty()) {
            handleRequestWeekendHolidaySupport(saEMList, 'W/H Support Notifications Escalation Managers');
        }
        if(!saPSList.isEmpty()) {
            handleRequestWeekendHolidaySupport(saPSList, 'W/H Support Notifications Product Specialists');
        }
        
        //Enhancement -> Doing Callout through a class, for Managing MSTeams Members
        String response = buildPayload(shiftPlanId, false);
        MSTeamsServiceController.doCallout_Channel(response, 'Add Channel Members'); 

        //T02
        triggerNotification(shiftDateId, saMainList, false);
    }

    //T02 - update the Shift Date record with Status and Users added/removed
    public static void triggerNotification(Id shiftDateId, List<Shift_Allocation__c> saMainList, Boolean endshift){
        Set<String> setUserName = new Set<String>();
        
        for(Shift_Allocation__c sa : saMainList) {
            setUserName.add(sa.Service_Resource__r.RelatedRecord.name);
        }
    
        System.debug('users added/removed : ' + setUserName);
        Shift_Date__c shiftDate = new Shift_Date__c();
        shiftDate.Id = shiftDateId;
        if(!endshift){
            shiftDate.Status__c = 'Started';
            shiftDate.Users_Added__c = String.join(new List<String>(setUserName), ', ');
            shiftDate.Users_Removed__c = '';    
        }else{
            shiftDate.Status__c = 'Ended';
            shiftDate.Users_Added__c = '';
            shiftDate.Users_Removed__c = String.join(new List<String>(setUserName), ', ');    
        }
        update shiftDate;
    }
    
    //Enhancement -> Handling Shift Requests for SEs, EMs & PSs in the Shift Plan
    private static void handleRequestWeekendHolidaySupport(List<Shift_Allocation__c> saList, String notificationSubscription) {
        
        notificationSubscription = notificationSubscription + '%';
        
        // Query all Notification Users (NU) associated to Notification Criteria WHERE Name LIKE W/H Support   
        Map<Id, List<Notification_User__c>> notifUsersByCriteriaMap = new Map<Id, List<Notification_User__c>>();
        for(Notification_User__c nu : [SELECT Id, Name, User__c, User__r.Name, Active__c, Notification_Criteria__r.Id
                                       FROM Notification_User__c
                                       WHERE Notification_Criteria__r.Name LIKE :notificationSubscription
                                       AND Notification_Criteria__r.Active__c = true]) 
        { 
            List<Notification_User__c> tempList = notifUsersByCriteriaMap.get(nu.Notification_Criteria__r.Id);
            if(tempList == null) {
                tempList = new List<Notification_User__c>();
            }
            tempList.add(nu);
            notifUsersByCriteriaMap.put(nu.Notification_Criteria__r.Id, tempList);
        }

        List<Notification_User__c> nuList2Create = new List<Notification_User__c>();
        List<Notification_User__c> nuList2Update = new List<Notification_User__c>();
       
        //Enhancement -> HANDLING MULTIPLE NOTIFICATION CRITERIA
        for(Id i : notifUsersByCriteriaMap.keyset()) {

            List<Notification_User__c> nuList = new List<Notification_User__c>(notifUsersByCriteriaMap.get(i));
        
            // Create Notif. User, if NOT exists compared to SA,
            // => If exists from SA, set (Active = true)
            // => All records in NU which are not in SA, set (Active = false)
            Map<Id, Notification_User__c> nuUserIdMap = new Map<Id, Notification_User__c>();
            for(Notification_User__c nu : nuList) { 
                nuUserIdMap.put(nu?.User__c, nu); 
            }
            
            Map<Id, Shift_Allocation__c> saUserIdMap = new Map<Id, Shift_Allocation__c>();
            for(Shift_Allocation__c sa : saList) { 
                saUserIdMap.put(sa?.Service_Resource__r?.RelatedRecordId, sa); 
            }
            
            for(Shift_Allocation__c sa : saList) {
                if(!nuUserIdMap.containsKey((Id)sa?.Service_Resource__r?.RelatedRecordId)) {
                    Notification_User__c newNU = new Notification_User__c();
                    newNU.User__c = sa.Service_Resource__r.RelatedRecordId;
                    newNU.Active__c = true;
                    newNU.Notification_Criteria__c = (Id)i; //nuUserIdMap.get((Id)sa.Service_Resource__r.RelatedRecordId).Notification_Criteria__r.Id;
                    nuList2Create.add(newNU);
                }
            }
            
            for(Notification_User__c nu : nuList) {
                if(saUserIdMap.containsKey((Id)nu?.User__c)) {
                    nu.Active__c = true;
                    nuList2Update.add(nu);
                }
                if(!saUserIdMap.containsKey((Id)nu?.User__c) && nu.Active__c) {
                    nu.Active__c = false;
                    nuList2Update.add(nu);
                }
            }  
        }

        if(!nuList2Create.isEmpty()) {
            INSERT nuList2Create;
        }
        if(!nuList2Update.isEmpty()) {
            UPDATE nuList2Update; 
        }
        
    }
    
    public static String buildPayload(Id shiftPlanId, Boolean endshift) {
        
        list<MSTeamsServiceController.memberInputPayload> lstShiftPlanChannelInputPayload = new list<MSTeamsServiceController.memberInputPayload>();
        MSTeamsServiceController.memberInputPayload oShiftPlanChannelInputPayload;
        
        //if(!endshift){
            for(Shift_Allocation__c sa : [SELECT Id,Name,Status__c,Shift_Request__r.Skill__r.Name,Shift_Request__r.Allocation_Type__c,Shift_Request__r.Shift_Plan__c,
                                          Service_Resource__r.RelatedRecord.Name,Service_Resource__r.RelatedRecord.PrincipalNmae__c,Service_Resource__r.RelatedRecord.Email,Service_Resource__r.RelatedRecord.Phone
                                          FROM Shift_Allocation__c 
                                          WHERE Shift_Request__r.Shift_Plan__c = :shiftPlanId
                                          AND Status__c = 'Approved'
                                          AND (Shift_Request__r.Allocation_Type__c like 'Weekend%'
                                          OR Shift_Request__r.Allocation_Type__c like 'Holiday%')])
            {
                
                oShiftPlanChannelInputPayload = new MSTeamsServiceController.memberInputPayload();
                oShiftPlanChannelInputPayload.name = sa.Service_Resource__r.RelatedRecord.name;
                //oShiftPlanChannelInputPayload.email = (!String.isblank(sa.Service_Resource__r.RelatedRecord.PrincipalNmae__c)) ? sa.Service_Resource__r.RelatedRecord.PrincipalNmae__c : (String.isblank(sa.Service_Resource__r.RelatedRecord.Email))? ' ': sa.Service_Resource__r.RelatedRecord.email;
                oShiftPlanChannelInputPayload.email = (String.isblank(sa.Service_Resource__r.RelatedRecord.Email))? ' ': sa.Service_Resource__r.RelatedRecord.email;
                oShiftPlanChannelInputPayload.phone = (sa.Service_Resource__r.RelatedRecord.phone == null) ? '' : sa.Service_Resource__r.RelatedRecord.phone;
                oShiftPlanChannelInputPayload.team = (sa.Shift_Request__r.Skill__r.Name == null) ? '' : sa.Shift_Request__r.Skill__r.Name;
                oShiftPlanChannelInputPayload.region = (sa.Shift_Request__r.Allocation_Type__c == null) ? '' : sa.Shift_Request__r.Allocation_Type__c;
                
                lstShiftPlanChannelInputPayload.add(oShiftPlanChannelInputPayload);
            }
        //} 
        
        
        System.debug('@Developer --> lstShiftPlanChannelInputPayload :' + lstShiftPlanChannelInputPayload);
        
        
        MSTeamsServiceController.ChannelInputPayLoad oChannelInputPayLoad;
        oChannelInputPayLoad = new MSTeamsServiceController.ChannelInputPayLoad();
        //if(!endshift){ 
            oChannelInputPayLoad.payloaddata = lstShiftPlanChannelInputPayload;
        //}

        MS_Teams__mdt msTeamsPayloadData = [SELECT ChannelID__c, TeamsID__c FROM MS_Teams__mdt WHERE QualifiedApiName = 'AddChannelMembers' LIMIT 1];
        
        oChannelInputPayLoad.channelid = msTeamsPayloadData.ChannelID__c;
        oChannelInputPayLoad.teamsid = msTeamsPayloadData.TeamsID__c;
        oChannelInputPayLoad.addMembers = true;
        if(endshift){
            oChannelInputPayLoad.addMembers = false;
        } 
        String payload = JSON.serialize(oChannelInputPayLoad);
        system.debug('@Developer --> jsonpayload :'+payload);
        return payload;
    }
}