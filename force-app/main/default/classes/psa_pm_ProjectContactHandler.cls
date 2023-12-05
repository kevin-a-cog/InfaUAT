public with sharing class psa_pm_ProjectContactHandler extends TriggerHandler {
    private psa_pm_ProjectContactHelper helper = new psa_pm_ProjectContactHelper();
    
    public override void beforeInsert() {         
        helper.checkPrimaryContactOnBeforeInsert((List<psa_pm_Project_Contact__c>) newList);
    }
    
    public override void beforeUpdate() { 
        helper.checkPrimaryContactOnBeforeUpdate((List<psa_pm_Project_Contact__c>) newList,(Map<Id, psa_pm_Project_Contact__c>) oldMap);
    }
}