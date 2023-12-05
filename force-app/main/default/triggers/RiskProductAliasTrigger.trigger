trigger RiskProductAliasTrigger on Risk_Product_Alias__c (before insert, before update, after insert, before delete, after delete, after update, after undelete) {
    Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getValues(UserInfo.getUserId());
    if(bts == null || (bts!=null && !bts.Risk_Product_Alias__c)){ 
        new RiskProductAliasTriggerHandler().process();
    }
}