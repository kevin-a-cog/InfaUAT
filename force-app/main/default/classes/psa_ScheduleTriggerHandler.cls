/*
@created by       : MAHESH GANTI
@created on       : 10/19/2020
@Purpose          : PSE_Schedule Object Trigger Handler Class
@Testclass        : 
@JIRA             : 

Change History
******************************************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                                             Jira No.    Tag
Wasim Akram     20-Mar-2023     Neha Kumari         Sync changes on Scheduled hours (Assignment) to Requested hour (RR)     PSA-2924    <T1>   
******************************************************************************************************************************************************
*/
public class psa_ScheduleTriggerHandler extends TriggerHandler{
    
    private psa_us_ScheduleTriggerHelper helper = new psa_us_ScheduleTriggerHelper();
    //Methods related to the module to be called in before insert context
    public override void beforeInsert() {         

    }

    //Methods related to the module to be called in after update context
    public override void beforeUpdate() {        
        helper.beforeUpdateSchedule((List<pse__Schedule__c>) newList);
    }

    //Methods related to the module to be called in after update context
    public override void beforeDelete() {   

    }

    //Methods related to the module to be called in after insert context
    public override void afterInsert() {
        
    }
        
    
    //Methods related to the module to be called in before insert context
    public override void afterUpdate() {  
        helper.afterScheduleUpdate((List<pse__Schedule__c>) newList,(Map<Id, pse__Schedule__c>) newMap, (Map<Id, pse__Schedule__c>) oldMap);
        helper.updateRRHours((List<pse__Schedule__c>) newList,(Map<Id, pse__Schedule__c>) newMap, (Map<Id, pse__Schedule__c>) oldMap); //<T1>
    }

    //Methods related to the module to be called in after update context
    public override void afterDelete() {        
        
    }
    
}