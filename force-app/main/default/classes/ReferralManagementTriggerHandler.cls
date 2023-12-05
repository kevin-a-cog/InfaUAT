public with sharing class ReferralManagementTriggerHandler extends TriggerHandler {
    private ReferralManagementTriggerHelper helper = new ReferralManagementTriggerHelper();

    public override void beforeInsert() {
        helper.processBeforeInsert((List<iCare_Referral__c>) newList);
    }

    public override void beforeUpdate() {
       helper.processBeforeUpdate((List<iCare_Referral__c>) newList,(Map<Id,iCare_Referral__c>) oldMap);
    }
    
    public override void afterInsert() {
        helper.processAfterInsert((List<iCare_Referral__c>) newList);
    }

    public override void afterUpdate() {
        helper.processAfterUpdate((List<iCare_Referral__c>) newList,(Map<Id,iCare_Referral__c>) oldMap);
    }
    
}