/*
 * Name: engagementTimerController   
 * Author: Piyush Soni  
 * Date: 24 June 2021   
 * Description: Apex controller for engagementTimer Lightning web component
 

Change History
*********************************************************************************************************************************************
ModifiedBy                  Date          JIRA No.                         Description                                Tag
*********************************************************************************************************************************************
 
*/
public with sharing class engagementTimerController {
  
    @AuraEnabled
    public static Decimal fetchTimeDuration(string recId){
        Decimal totalDays;
        try {
            Engagement__c oEngagement = [Select Id,Dev_Active_Engaged_Start_Time__c,status__c From Engagement__c WHERE Id =: recId];
            DateTime startDate = oEngagement.Dev_Active_Engaged_Start_Time__c ;
            if(startDate == null || oEngagement.status__c != 'Active Engaged'){
                totalDays = 0;
                return totalDays;
            }
            DateTime endDate = system.now();
            Decimal days = Integer.valueOf((endDate.getTime() - startDate.getTime())/(1000*60*60*24));
            System.debug('Days : ' + days);
            totalDays =  days;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return totalDays;
    }


}