/*
        Trigger:        QuoteBeforeDelete
        @Author:        cgowda
        @Created Date:  03 Jul 2023
        @Description:   SALESRT-16911 : Enabled delete access to Quote for all CPQ Users
        
         Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag              
    ********************************************************************************************************************************************
*/

trigger QuoteBeforeDelete on SBQQ__Quote__c (before delete) {
    
    if(Global_Config__c.getInstance() != null && Global_Config__c.getInstance().Mute_Triggers__c != null && Global_Config__c.getInstance().Mute_Triggers__c == true){
        return;
    }
    
    QuoteTriggerHandler.handleBeforeDelete(Trigger.oldMap);
}