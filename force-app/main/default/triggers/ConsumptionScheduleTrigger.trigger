/*
        Trigger:        ConsumptionSchedule
        @Author:        Stephanie Viereckl
        @Created Date:  October 14 2021
        @Description:   To default fields on ConsumptionSchedule when record type is "Estimation Schedule" and to create a dummy ConsumptionRate
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag

    Stephanie Viereckl  Oct 14 2021  IPUE-53                        Initial Create                     
    ********************************************************************************************************************************************

   
*/

trigger ConsumptionScheduleTrigger on ConsumptionSchedule (before insert, after insert) {

    //Do not execute triggger if Mute Trigger is enabled for user.
    if (Global_config__c.getInstance() != null && Global_config__c.getInstance().Mute_Triggers__c != null &&
        Global_config__c.getInstance().Mute_Triggers__c == true 
    ){
        return;
    }
    if(Trigger.isBefore && Trigger.isInsert){
        ConsumptionScheduleTriggerHandler.beforeInsert(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isInsert) {
        ConsumptionScheduleTriggerHandler.afterInsert(Trigger.new);
    }

}