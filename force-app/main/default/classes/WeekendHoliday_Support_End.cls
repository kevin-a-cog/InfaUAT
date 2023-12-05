/**
 * @description       : 
 * @author            : Tejasvi Royal
 * @group             : 
 * @last modified on  : 09-09-2021
 * @last modified by  : Tejasvi Royal
 * 

 Change History
 ****************************************************************************************************
 ModifiedBy     Date        Jira No.    Tag     Description
 ****************************************************************************************************
 balajip        07/28/2022  I2RT-6740   T01     to capture the list of users added/removed
 balajip        07/28/2022  I2RT-7099   T02     to remove only the Shift Users from the Weekend Support Teams Channel
**/
public with sharing class WeekendHoliday_Support_End {

    //T01 - get the Shift Date Id as the parameter instead of Shift Plan
    @InvocableMethod(label='Weekend/Holiday Support End' description='End actions for Weekend/Holiday Support.')
    public static void revokeWeekendHolidaySupport(List<Id> lstShiftDateId) {
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
            handleRevokeWeekendHolidaySupport(saSEList, 'W/H Support Notifications Support Engineers');
        }
        if(!saEMList.isEmpty()) {
            handleRevokeWeekendHolidaySupport(saEMList, 'W/H Support Notifications Escalation Managers');
        }
        if(!saPSList.isEmpty()) {
            handleRevokeWeekendHolidaySupport(saPSList, 'W/H Support Notifications Product Specialists');
        }

        //Enhancement -> Doing Callout through a class, for Managing MSTeams Members
        String response = WeekendHoliday_Support_Start.buildPayload(shiftPlanId, true);
        MSTeamsServiceController.doCallout_Channel(response, 'Add Channel Members');

        //T02 - call the method to update the Shift Date record with status and the users removed
        WeekendHoliday_Support_Start.triggerNotification(shiftDateId, saMainList, true);
    }

    //Enhancement -> Handling Shift Requests for SEs, EMs & PSs in the Shift Plan
    private static void handleRevokeWeekendHolidaySupport(List<Shift_Allocation__c> saList, String notificationSubscription) {

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

        List<Notification_User__c> nuList2Update = new List<Notification_User__c>();
        
        //Enhancement -> HANDLING MULTIPLE NOTIFICATION CRITERIA
        for(Id i : notifUsersByCriteriaMap.keyset()) {

            List<Notification_User__c> nuList = new List<Notification_User__c>(notifUsersByCriteriaMap.get(i));
        
            // NU that match with SA set (Active = false)            
            Map<Id, Shift_Allocation__c> saUserIdMap = new Map<Id, Shift_Allocation__c>();
            for(Shift_Allocation__c sa : saList) { 
                saUserIdMap.put(sa?.Service_Resource__r?.RelatedRecordId, sa); 
            }
          
            for(Notification_User__c nu : nuList) {
                if(saUserIdMap.containsKey((Id)nu?.User__c) && nu.Active__c) {
                    nu.Active__c = false;
                    nuList2Update.add(nu);
                }
            }            
        }

        if(!nuList2Update.isEmpty()) {
           UPDATE nuList2Update; 
        }
    }
}