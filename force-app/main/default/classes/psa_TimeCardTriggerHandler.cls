/*
@created by       : MAHESH GANTI
@created on       : 10/30/2020
@Purpose          : Trigger Handler Class for TIMECARD Trigger.

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
public class psa_TimeCardTriggerHandler extends TriggerHandler{
    
    private psa_tm_TimeCardTriggerHelper helper = new psa_tm_TimeCardTriggerHelper();
    //Methods related to the module to be called in before insert context
    public override void beforeInsert() {         
        helper.runValidationsOnTCInsert((List<pse__Timecard_Header__c>) newList);
        helper.populateFieldsOnTimeCardInsert((List<pse__Timecard_Header__c>) newList);
        
    }

    //Methods related to the module to be called in before update context
    public override void beforeUpdate() {        
        helper.runValidationsOnTCUpdate((List<pse__Timecard_Header__c>) oldList,(List<pse__Timecard_Header__c>) newList,(Map<Id, pse__Timecard_Header__c>) oldMap, (Map<Id, pse__Timecard_Header__c>) newMap);
        helper.populateFieldsOnTimeCardUpdate((List<pse__Timecard_Header__c>) oldList,(List<pse__Timecard_Header__c>) newList,(Map<Id, pse__Timecard_Header__c>) oldMap, (Map<Id, pse__Timecard_Header__c>) newMap);
        
    }

    //Methods related to the module to be called in before delete context
    public override void beforeDelete() {   

    }

    //Methods related to the module to be called in after insert context
    public override void afterInsert() {
        helper.handleAfterTCInsertLogic((List<pse__Timecard_Header__c>) newList, (Map<Id,pse__Timecard_Header__c>) newMap);
    }
        
    
    //Methods related to the module to be called in after update context
    public override void afterUpdate() {  
        helper.handleAfterTCUpdateLogic((List<pse__Timecard_Header__c>) oldList,(List<pse__Timecard_Header__c>) newList,(Map<Id, pse__Timecard_Header__c>) oldMap, (Map<Id, pse__Timecard_Header__c>) newMap);
    }

    //Methods related to the module to be called in after delete context
    public override void afterDelete() {        
        helper.handleAfterTCDeleteLogic((List<pse__Timecard_Header__c>) oldList);
    }
}