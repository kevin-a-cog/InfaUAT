/*
        Trigger:        Opportunity_IPU_Services__c
        @Author:        
        @Created Date:  26th Feb 23
        @Description:   To rollup the Values on opportunity
*/
/*
    Change History
    ********************************************************************************************************************************************
    ********************************************************************************************************************************************
*/ 
trigger OpportunityIPUServicesTrigger on Opportunity_IPU_Services__c (after insert, after update) { 

    //Do not execute triggger if Mute Trigger is enabled for user.
    if (Global_config__c.getInstance() != null && Global_config__c.getInstance().Mute_Triggers__c != null &&
        Global_config__c.getInstance().Mute_Triggers__c == true 
    ){
        return;
    }
    
    if(Trigger.isAfter && Trigger.isInsert){
        OpportunityIPUServicesTriggerHandler.afterInsert(Trigger.new);
    } else if (Trigger.isAfter && Trigger.isUpdate){
        OpportunityIPUServicesTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }


}