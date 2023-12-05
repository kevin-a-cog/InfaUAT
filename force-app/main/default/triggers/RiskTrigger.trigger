trigger RiskTrigger on Risk_Issue__c  (before insert, before update, after insert, before delete, after delete, after update, after undelete) {
    Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getValues(UserInfo.getUserId());
    if(bts == null || (bts!=null && !bts.Risk__c)){
        new RiskIssueTriggerHandler().process();
    }
}