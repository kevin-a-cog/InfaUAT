public with sharing class CSMAdoptionFactorTriggerHandler extends TriggerHandler {
    
    private CSMAdoptionFactorTriggerHelper helper = new CSMAdoptionFactorTriggerHelper();
    
    
    /*
    Method Name : beforeInsert
    Description : Methods related to the module to be called in before insert context
    */
    public override void beforeInsert() { 
        
    }
    
    /*
    Method Name : afterInsert
    Description : Methods related to the module to be called in After insert context
    */
    public override void afterInsert() {
        helper.processAfterInsert((List<Adoption_Factor__c>) newList,(Map<Id, Adoption_Factor__c>) oldMap);
    } 
    
    /*
    Method Name : afterDelete
    Description : Methods related to the module to be called in After delete context
    */
    public override void afterDelete() {     
    }    
    
    /*
    Method Name : beforeUpdate
    Description : Methods related to the module to be called in Before update context
    */
    public override void beforeUpdate() {   
        
    }  
    
    /*
    Method Name : afterUpdate
    Description : Methods related to the module to be called in after update context
    */
    public override void afterUpdate() {   
        helper.processAfterUpdate((List<Adoption_Factor__c>) newList,(Map<Id,Adoption_Factor__c>) oldMap);
    }
    
     /*
    Method Name : afterUndelete
    Description : Methods related to the module to be called in after undelete context
    */
    public override void afterUndelete() {
        
    } 

}