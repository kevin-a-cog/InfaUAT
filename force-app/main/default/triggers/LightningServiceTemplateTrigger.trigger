/*
        Trigger:        Lightning Service Template
        @Author:        Stephanie Viereckl
        @Created Date:  November 3, 2021
        @Description:   This trigger will run after insert and after update in order to determine if any related
        Lightning Service Member records should be created, updated, or deleted
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag

    Stephanie Viereckl  November 3, 2021  IPUE-105                  Initial Create                     
    ********************************************************************************************************************************************
   
*/
trigger LightningServiceTemplateTrigger on Lightning_Service_Template__c (after insert, after update, before delete) {

    //Do not execute triggger if Mute Trigger is enabled for user.
    if (Global_config__c.getInstance() != null && Global_config__c.getInstance().Mute_Triggers__c != null &&
        Global_config__c.getInstance().Mute_Triggers__c == true 
    ){
        return;
    }

    if (Trigger.isAfter && Trigger.isInsert) {
        LightningServiceTemplateTriggerHandler.afterInsert(Trigger.new);
    } else if (Trigger.isAfter && Trigger.isUpdate) {
        LightningServiceTemplateTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    } else if (Trigger.isBefore && Trigger.isDelete) {
        LightningServiceTemplateTriggerHandler.beforeDelete(Trigger.old);
    }

}