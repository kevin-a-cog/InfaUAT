public class psa_pm_ProjectLocationTriggerHandler extends TriggerHandler{

     private psa_pm_ProjectLocationTriggerHelper helper = new psa_pm_ProjectLocationTriggerHelper();
     
    //Methods related to the module to be called in before insert context
    public override void beforeInsert() {         
        helper.populateMSAFieldValuesOnInsert((List<pse__Project_Location__c>) newList);
    }

    //Methods related to the module to be called in before update context
    public override void beforeUpdate() {        
     helper.populateMSAFieldValuesOnUpdate((Map<Id,pse__Project_Location__c>) newMap,(Map<Id,pse__Project_Location__c>) oldMap);   
    }

    //Methods related to the module to be called in before delete context
    public override void beforeDelete() {   

    }

    //Methods related to the module to be called in after insert context
    public override void afterInsert() {
        helper.runValidationsOnInsertUpdate((List<pse__Project_Location__c>) newList, (Map<Id,pse__Project_Location__c>) newMap);
    }
        
    
    //Methods related to the module to be called in after update context
    public override void afterUpdate() {  
        helper.runValidationsOnInsertUpdate((List<pse__Project_Location__c>) newList,(Map<Id, pse__Project_Location__c>) newMap);
    }

    //Methods related to the module to be called in after delete context
    public override void afterDelete() {        
        helper.runValidationsOnDelete((List<pse__Project_Location__c>) oldList,(Map<Id, pse__Project_Location__c>) oldMap);
    }
}