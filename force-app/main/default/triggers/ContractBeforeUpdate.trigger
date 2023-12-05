/*before
        Trigger:        ContractBeforeUpdate
        @Author:        Wasim Akram
        @Created Date:  4th Feb 2020
        @Description:   To be invoked in before insert context of the Contract
*/
/*
Change History
********************************************************************************************************************************************
ModifiedBy        Date          JIRA No.            Requested By      Description                                                         Tag 
Chandana Gowda    09-Nov-2020   SALESRT 12290       Chitra            Allowing the run of contractBeforeUpate twice to handle   
                                                                      amend scenario
********************************************************************************************************************************************

   
*/
trigger ContractBeforeUpdate on Contract (before Update){
    public static Integer count = 0;
    
    if(count < 2){
        globalApexManager.allowRun('ContractBeforeUpdate');
    } else if(globalApexManager.avoidRecursion('ContractBeforeUpdate') ) {
        return;
    }
    
    if(Global_Config__c.getInstance().Mute_Triggers__c != null && Global_Config__c.getInstance().Mute_Triggers__c != true){
        ContractTriggerHandler.handleBeforeUpdate(Trigger.New,Trigger.NewMap,Trigger.OldMap);
        count += 1;
    }
    
}