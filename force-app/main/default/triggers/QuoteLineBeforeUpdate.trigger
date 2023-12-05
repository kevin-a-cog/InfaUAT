/*
        Trigger:        QuoteLineBeforeUpdate
        @Author:        Kendra Claiborne
        @Created Date:  19 December 2017
        @Description: 
          
         Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag

    Ritika Gupta      10 July 2018  SALESRT-4141                    Updated recursion logic to allow code execution for Before update trigger one more time, 
                                                                    as Parent and child Quote lines are getting processed in 2 different batches.<T01>    
    Chandana Gowda    20 May 2021   SALESRT-12038   Val             Updated recursion logic to allow trigger logic execution multiple times, to update the
                                                                    right End date localised value on all child lines             <T02>                                                                           
    ********************************************************************************************************************************************

*/

trigger QuoteLineBeforeUpdate on SBQQ__QuoteLine__c (before update) {  
    //<T01>
    if(Global_Config__c.getInstance() != null && Global_Config__c.getInstance().Mute_Triggers__c != null 
                                && Global_Config__c.getInstance().Mute_Triggers__c == true){
                                
        return;
    }
    //</T01>

    if(globalApexManager.avoidRecursion('QuoteLineBeforeUpdate') && QuoteLineTriggerHandler.beforeUpdateCount > 4 ) {//<T01> //<T02> update to >4
        return;
    }
    
    QuoteLineTriggerHandler.beforeUpdateCount += 1;//<T01>
    
    QuoteLineTriggerHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
}