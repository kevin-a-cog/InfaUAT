/*
 * Name         :   ServiceAppointmentTriggerHandler
 * Author       :   Vignesh Divakaran
 * Created Date :   9/19/2023
 * Description  :   This is an handler class.

 Change History
 *********************************************************************************************************************
 Modified By            Date            Jira No.        Description                                             Tag
 *********************************************************************************************************************
 Vignesh Divakaran      9/19/2023       I2RT-9063       Initial version.                                        N/A
 */

public class ServiceAppointmentTriggerHandler extends TriggerHandler{

    private ServiceAppointmentTriggerHelper helper = new ServiceAppointmentTriggerHelper();

    public override void beforeInsert() {          
        if(globalApexManager.avoidRecursion('ServiceAppointmentCustomTrigger',  'before', 'insert') ) {
            return;
        }
        helper.validateSlotLimit((List<Service_Appointment__c>) newList);
    }
    
    public override void afterInsert() {          
        if(globalApexManager.avoidRecursion('ServiceAppointmentCustomTrigger',  'after', 'insert') ) {
            return;
        }
        helper.createCase((List<Service_Appointment__c>) newList);
        helper.createEvent((Map<Id, Service_Appointment__c>) newMap);
    }
}