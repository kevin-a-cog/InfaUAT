/*
        Trigger:        ContractBeforeInsert
        @Author:        Sumitkumar Mittal
        @Created Date:  25th June 2019
        @Description:   To be invoked in before insert context of the Contract
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag              
    ********************************************************************************************************************************************

   
*/
trigger ContractBeforeInsert on Contract (before Insert){

    
    if(globalApexManager.avoidRecursion('ContractBeforeInsert') ) {
        return;
    }
    
    if(Global_Config__c.getInstance().Mute_Triggers__c != null && Global_Config__c.getInstance().Mute_Triggers__c != true){
        ContractTriggerHandler.handleBeforeInsert(Trigger.New);
    }
    
}