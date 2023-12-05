trigger psa_pm_ProjectContactTrigger on psa_pm_Project_Contact__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId());

    if(bts == null || bts.PSA_Project_Contact__c){
        new psa_pm_ProjectContactHandler().process();
    }
}