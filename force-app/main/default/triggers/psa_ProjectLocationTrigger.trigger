trigger psa_ProjectLocationTrigger on pse__Project_Location__c (before insert, before update,before delete, after insert, after update,after delete) {
    
    Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId());
    if(bts == null || bts.PSA_Project_Location__c){
        new psa_pm_ProjectLocationTriggerHandler().process();
    }      
}