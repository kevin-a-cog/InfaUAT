/*
        Trigger:        API Field Mapping
        @Author:        Stephanie Viereckl
        @Created Date:  November 8, 2021
        @Description:   This trigger will run after delete to delete any related Lightning Service Member records.
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag

    Stephanie Viereckl  November 8, 2021  IPUE-105                  Initial Create                     
    ********************************************************************************************************************************************
   
*/
trigger ApiFieldMappingTrigger on API_Field_Mapping__c (before delete) {

    //Do not execute triggger if Mute Trigger is enabled for user.
    if (Global_config__c.getInstance() != null && Global_config__c.getInstance().Mute_Triggers__c != null &&
        Global_config__c.getInstance().Mute_Triggers__c == true 
    ){
        return;
    }

    if (Trigger.isBefore && Trigger.isDelete) {
        ApiFieldMappingTriggerHandler.beforeDelete(Trigger.old);
    }

}