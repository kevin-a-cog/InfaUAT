/*
        Trigger:        selfServiceQuoteSummaryTrigger
        @Author:        Nishit S
        @Created Date:  7/24/2023
        @Description:    SALESRT-15481
*/
/*
Change History
********************************************************************************************************************************************************************************************************************
ModifiedBy                Date                  JIRA                Requested By                 Description                                                 Tag
********************************************************************************************************************************************************************************************************************
*/
trigger selfServiceQuoteSummaryTrigger on Self_Service_Quote_Summary__c (before insert,after insert, before update, after update) {
    
    if (Global_config__c.getInstance() != null && Global_config__c.getInstance().Mute_Triggers__c != null && Global_config__c.getInstance().Mute_Triggers__c == true ){
        return;
    }
    if(trigger.isAfter && trigger.isUpdate)
    {
        if(globalApexManager.avoidRecursion('selfServiceQuoteSummaryAfterUpdate')) {
        return;
        }

        selfServiceQuoteSummaryTriggerHandler.selfServiceQuoteSummaryAfterUpdate(Trigger.newMap,Trigger.oldMap);
    }
        
    if(trigger.isBefore && trigger.isUpdate)
    {    
        if(globalApexManager.avoidRecursion('selfServiceQuoteSummaryBeforeUpdate')) {
        return;
        }
       
        selfServiceQuoteSummaryTriggerHandler.selfServiceQuoteSummaryBeforeUpdate(Trigger.newMap,Trigger.oldMap);
    }

}