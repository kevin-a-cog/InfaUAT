/*
@created by       : RANJAN KISHORE
@created on       : 02/12/2021
@Purpose          : Trigger to customize.

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
*/
trigger PSA_AdoptionEventTrigger on Adoption_Event__c (before insert, before update,before delete, after insert, after update,after delete) {
    
   Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId());
    System.debug('by'+bts);
    if(bts == null || bts.PSA_Adoption_Event_Trigger__c){
        System.debug('inside');
        new PSA_AdoptionEventTriggerHandler().process();
    }
    if(Global_Config__c.getInstance().Mute_Triggers__c != null && Global_Config__c.getInstance().Mute_Triggers__c != true){
        new CSMAdoptionEventTriggerHandler().process();
    }
    
    
}