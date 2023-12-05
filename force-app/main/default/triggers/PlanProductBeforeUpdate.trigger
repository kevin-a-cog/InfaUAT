/*
* Class :        PlanProductBeforeUpdate
* Author:        Ambica P
* Created Date:  15 July 2020
* Description:   Before Update Trigger on Plan Product 
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
    ********************************************************************************************************************************************
   
*/
trigger PlanProductBeforeUpdate on Related_Account_Plan__c (Before update) {
    
    if(globalApexManager.avoidRecursion('PlanProductBeforeUpdate') ) {
        return;
    }
    
    PlanProductTriggerHandler.handlerBeforeUpdate(Trigger.New, Trigger.Oldmap);
}