trigger SurveyResponseTrigger on Survey_Response__c (before insert, before update, after insert, before delete, after delete, after update, after undelete) {
    if(Global_Config__c.getInstance().Mute_Triggers__c != null && Global_Config__c.getInstance().Mute_Triggers__c != true){
        new SurveyResponseTriggerHandler().process();
    }
}