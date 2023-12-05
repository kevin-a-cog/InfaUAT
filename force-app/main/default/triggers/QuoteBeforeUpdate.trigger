/*
        Trigger:        QuoteBeforeUpdate
        @Author:        Kendra Claiborne
        @Created Date:  19 December 2017
        @Description:   
        
         Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag

    Ritika Gupta      26 June 2018  TKT-001472                      Updated recursion logic to allow code execution for Before update trigger twice, 
                                                                    as in case of Discount Approval, we have 2 Quote updates in the transaction <T01>    
    Ritika Gupta      23 Oct 2018                 Prasanth          Added code to enable muting this trigger using Global config custom setting <T02>               
    ********************************************************************************************************************************************
*/

trigger QuoteBeforeUpdate on SBQQ__Quote__c (before update) {  
    
    //<T02>
    if(Global_Config__c.getInstance() != null && Global_Config__c.getInstance().Mute_Triggers__c != null 
                                && Global_Config__c.getInstance().Mute_Triggers__c == true){
                                
        return;
    }
    //</T02>
    
    system.debug('QuoteTriggerHandler.beforeUpdateCount:' + QuoteTriggerHandler.beforeUpdateCount);
    if(globalApexManager.avoidRecursion('QuoteBeforeUpdate') && QuoteTriggerHandler.beforeUpdateCount > 2) {//Added 'QuoteTriggerHandler.beforeUpdateCount > 2'<T01>
        return;
    }
    
    QuoteTriggerHandler.beforeUpdateCount += 1;
    
    
    QuoteTriggerHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
}