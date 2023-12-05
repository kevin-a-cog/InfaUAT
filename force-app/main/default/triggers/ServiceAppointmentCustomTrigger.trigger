/*
 * Name         :   ServiceAppointmentCustomTrigger
 * Author       :   Vignesh Divakaran
 * Created Date :   9/19/2023
 * Description  :   Trigger for Service Appointment custom object.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                                 Tag
 **********************************************************************************************************
 Vignesh Divakaran      9/19/2023       I2RT-9063       Initial version.                            N/A
 */
trigger ServiceAppointmentCustomTrigger on Service_Appointment__c (before insert, after insert) {

    new ServiceAppointmentTriggerHandler().process();

}