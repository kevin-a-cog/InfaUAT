trigger CSMMilestoneTrigger on Milestone__c (before insert, before update, after insert, after update , after delete) {

    if(Global_Config__c.getInstance().Mute_Triggers__c != null && Global_Config__c.getInstance().Mute_Triggers__c != true){
        new CSMMilestoneTriggerHandler().process();
    }
}