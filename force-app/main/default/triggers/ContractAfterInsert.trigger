/*
        Trigger:        ContractAfterInsert
        @Author:        Wasim Akram
        @Created Date:  6th Feb 2020
        @Description:   To be invoked in after insert context of the Contract
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag              
    ********************************************************************************************************************************************

   
*/
trigger ContractAfterInsert on Contract (after Insert){

    
    if(globalApexManager.avoidRecursion('ContractAfterInsert') ) {
        return;
    }
    
    if(Global_Config__c.getInstance().Mute_Triggers__c != null && Global_Config__c.getInstance().Mute_Triggers__c != true){
        ContractTriggerHandler.handleAfterInsert(Trigger.New);
    }
    
}