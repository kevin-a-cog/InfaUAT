/*
        Trigger:        ContractAfterUpdate
        @Author:        Nishant Bansal
        @Created Date:  24th Apr 2023
        @Description:   To be invoked in after update context of the Contract
*/
/*
Change History
********************************************************************************************************************************************
ModifiedBy        Date          JIRA No.        Requested By      Description                                                         Tag 
Nishant    24th Apr 2023   SALESRT-13388                           Allowing the run of ContractAfterUpdate twice to handle   
                                                                   amend scenario
********************************************************************************************************************************************

   
*/
trigger ContractAfterUpdate on Contract (after Update){
    public static Integer count = 0;
    
    if(count < 2){
        globalApexManager.allowRun('ContractAfterUpdate');
    } else if(globalApexManager.avoidRecursion('ContractAfterUpdate') ) {
        return;
    }
    
    if(Global_Config__c.getInstance().Mute_Triggers__c != null && Global_Config__c.getInstance().Mute_Triggers__c != true){
        ContractTriggerHandler.handleAfterUpdate(Trigger.New,Trigger.NewMap,Trigger.OldMap);      
        count += 1;
    }
    
}