trigger psa_ShadowLeadRequestTrigger on psa_Shadow_Lead_Request__c (before insert, after insert, before update, after update) {
Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId());
    if(bts == null || bts.psa_Shadow_Lead_Request_Trigger__c){
    new psa_ShadowLeadRequestHandler().process();
    }
}