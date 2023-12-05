/*
Trigger:        AccountBeforeUpdate
@Author:        Chandana Gowda
@Created Date:  3/6/2021
@Description:   handler logic on before update of account, added for Tax 19 to create ERP Company 
*/
trigger AccountBeforeUpdate on Account(Before Update) {
    
    
    if(globalApexManager.avoidRecursion('AccountBeforeUpdate')) {
        return;
    }
    if(Global_Config__c.getInstance() != null && Global_Config__c.getInstance().Mute_Triggers__c != null && Global_Config__c.getInstance().Mute_Triggers__c == true){
        return;
    }         
    
    AccountTriggerHandler.AccountBeforeUpdate (Trigger.newMap,Trigger.oldMap);
    
}