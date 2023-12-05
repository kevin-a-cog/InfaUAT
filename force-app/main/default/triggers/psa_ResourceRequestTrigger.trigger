trigger psa_ResourceRequestTrigger on pse__Resource_Request__c (before insert, before update,before delete, after insert, after update,after delete) {
	 Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId());
    if(bts == null || bts.PSA_ResourceRequest_Trigger__c){
    new psa_ResourceRequestTriggerHandler().process();
    }
}