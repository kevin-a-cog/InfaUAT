trigger psa_ScheduleTrigger on pse__Schedule__c (before insert, before update,before delete, after insert, after update,after delete) {
    Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId());
    if(bts == null || bts.PSA_ScheduleTrigger__c){
        new psa_ScheduleTriggerHandler().process();
    }
}