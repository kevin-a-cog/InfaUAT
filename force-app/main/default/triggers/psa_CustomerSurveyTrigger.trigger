trigger psa_CustomerSurveyTrigger on psa_pm_IPS_Customer_Survey__c (before insert, before update,before delete, after insert, after update,after delete) {
	Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId());
    if(bts == null || bts.PSA_Customer_Survey_Trigger__c){
    new psa_CustomerSurveyTriggerHandler().process();
    }
}