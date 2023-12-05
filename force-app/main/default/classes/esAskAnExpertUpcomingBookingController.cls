/*
 Change History
 ***********************************************************************************************************************************
 Modified By            Date            Jira No.        Tag     Description                                
 ***********************************************************************************************************************************
 N/A                    N/A             UTOPIA          N/A     Initial version.
 Vignesh Divakaran      9/20/2023       I2RT-9063       T01     Replaced standard with custom object Service_Appointment__c
 */
public with sharing class esAskAnExpertUpcomingBookingController{

    @AuraEnabled
    public static List<Case> fetchSupportAccountAppoinmentBookings(string sParentRecordId){
        return [SELECT Id,
                    Status,
                    Subject,
                    CaseNumber,
                    Forecast_Product__c,
                    Service_Appointment__r.Name,
                    Service_Appointment__r.Time_Slot_AAE__r.Start_Time__c,
                    Service_Appointment__r.Time_Slot_AAE__r.End_Time__c 
                    FROM Case 
                    WHERE Support_Account__c =: sParentRecordId AND 
                    RecordType.DeveloperName = 'Ask_An_Expert' AND 
                    (Status = 'Booked' OR Status = 'Scheduled') 
                    ORDER BY Service_Appointment__r.Time_Slot_AAE__r.Start_Time__c ASC]; //<T01>
    }
}