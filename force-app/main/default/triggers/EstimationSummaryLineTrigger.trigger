/*
        Trigger:        Estimation_Sumamry_Line__c
        @Author:        Colton Kloppel
        @Created Date:  October 19 2021
        @Description:   To recalculate the total values of an Estimation Summary when updates are made to an Estimation Summary Line.
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag

    Colton Kloppel    Oct 19 2021  IPUE-52                        Initial Create                     
    ********************************************************************************************************************************************
*/ 
trigger EstimationSummaryLineTrigger on Estimation_Summary_Line__c (after insert, after update) { 

    //Do not execute triggger if Mute Trigger is enabled for user.
    if (Global_config__c.getInstance() != null && Global_config__c.getInstance().Mute_Triggers__c != null &&
        Global_config__c.getInstance().Mute_Triggers__c == true 
    ){
        return;
    }
    
    if(Trigger.isAfter && Trigger.isInsert){
        EstimationSummaryLineTriggerHandler.afterInsert(Trigger.new);
    } else if (Trigger.isAfter && Trigger.isUpdate){
        EstimationSummaryLineTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }


}