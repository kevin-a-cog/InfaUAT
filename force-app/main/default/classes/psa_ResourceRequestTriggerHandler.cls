/*
@created by       : MAHESH GANTI
@created on       : 11/05/2020
@Purpose          : Resource Request Trigger Handler.

Change History
*****************************************************************************************************************************************************
ModifiedBy              Date            Requested By        Description                                                         Jira No.        Tag
Wasim Akram             25-Jul-2022     Neha Kumari         Alert while creating Billable Hours RR when Budget is used          PSA-2048        <T01>
Rohit Niranjanamath     09-Sep-2023     PSA Sept Build '23  Resource Manager field addition to RR and PSA Contact Page layouts  PSA-3079        <T02>
*****************************************************************************************************************************************************
*/
public class psa_ResourceRequestTriggerHandler extends TriggerHandler{
    
    private psa_rm_ResourceRequestTriggerHelper helper = new psa_rm_ResourceRequestTriggerHelper();
    
    //Methods related to the module to be called in before insert context
    public override void beforeInsert() {         
        helper.defaultResReqFieldValOnInsert((List<pse__Resource_Request__c>) newList);
        helper.updateRMOContactFieldOnRR(null,(List<pse__Resource_Request__c>) newList);//<T02>
    } 

    //Methods related to the module to be called in Before update context
    public override void beforeUpdate() {     
        helper.defaultResReqFieldValOnUpdate((List<pse__Resource_Request__c>) oldList,(List<pse__Resource_Request__c>) newList,(Map<Id, pse__Resource_Request__c>) oldMap, (Map<Id, pse__Resource_Request__c>) newMap);
        helper.validateRRExceededBudget((List<pse__Resource_Request__c>) oldList,(List<pse__Resource_Request__c>) newList,(Map<Id, pse__Resource_Request__c>) oldMap, (Map<Id, pse__Resource_Request__c>) newMap); //<T01>
        helper.updateRMOContactFieldOnRR((Map<Id,pse__Resource_Request__c>) oldMap,(List<pse__Resource_Request__c>) newList);//<T02>
    }

    //Methods related to the module to be called in Before Delete context
    public override void beforeDelete() {   
        
    }

    //Methods related to the module to be called in after insert context
    public override void afterInsert() {
        helper.processAfterInsertActions((List<pse__Resource_Request__c>) newList,(Map<Id,pse__Resource_Request__c>) newMap);
    }
        
    
    //Methods related to the module to be called in After Update context
    public override void afterUpdate() {  
        system.debug('oldList'+oldList);
        system.debug('newList'+newList);
        
        helper.processAfterUpdateActions((List<pse__Resource_Request__c>) oldList,(List<pse__Resource_Request__c>) newList,(Map<Id, pse__Resource_Request__c>) oldMap, (Map<Id, pse__Resource_Request__c>) newMap);
    }

    //Methods related to the module to be called in After Delete context
    public override void afterDelete() {        
        
    }
}