/*
        Trigger:        Estimation_Sumamry__c
        @Author:        Colton Kloppel
        @Created Date:  December 13 2021
        @Description:   To handle Primary logic on the Estimation Summary
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.            Description                                                 Tag

    Colton Kloppel    Dec 13 2021  IPUE-139             Initial Create
    Chandana Gowda    25 Apr 2022  SALESRT-13820        Added after Insert context                                  <T01>
    ********************************************************************************************************************************************
*/ 
trigger EstimationSummaryTrigger on Estimation_Summary__c (before update, before insert, after update, after insert) {

    //Do not execute triggger if Mute Trigger is enabled for user.
    if (Global_config__c.getInstance() != null && Global_config__c.getInstance().Mute_Triggers__c != null &&
        Global_config__c.getInstance().Mute_Triggers__c == true ){
        return;
    }

    if(Trigger.isBefore && Trigger.isInsert){
        EstimationSummaryTriggerHandler.beforeInsert(Trigger.new);
    }
	
    //<T01> - Adding after Insert context
    if(Trigger.isAfter && Trigger.isInsert){
        EstimationSummaryTriggerHandler.afterInsert(Trigger.newMap);
    }    

    if(Trigger.isBefore && Trigger.isUpdate){
        EstimationSummaryTriggerHandler.beforeUpdate(Trigger.oldMap, Trigger.newMap);
    }

    if(Trigger.isAfter && Trigger.isUpdate) {
        EstimationSummaryTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
}