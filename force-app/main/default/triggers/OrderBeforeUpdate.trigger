/*
Trigger:        OrderBeforeUpdate
@Author:        Vivek Warrier
@Created Date:  March 1, 2018
@Description:   handles all logic on the before update on OrderTriggerHandler

********************************************************************************************************************************************
ModifiedBy          Date            JIRA NO      Requested By       Description                                                         Tag
********************************************************************************************************************************************  
Vivek Warrier       3/1/2018        TKT-001087   Shobhit Sharma     To sync the Order Start Date and the Billing Day of Month - March   <T1>
*/
trigger OrderBeforeUpdate on Order (before update) {
    //<T1> To copy the Day of the Order Start Date to the Billing Day of Month
    
    if(globalApexManager.avoidRecursion('OrderBeforeUpdate') ) {
        return;
    }
    
    if(Global_Config__c.getInstance().Mute_Triggers__c != null && Global_Config__c.getInstance().Mute_Triggers__c != true){
        if(Trigger.isBefore && Trigger.isUpdate){
            OrderTriggerHandler.handleBeforeUpdate(Trigger.newMap,Trigger.oldMap);
        }
    }
    //</T1>
}