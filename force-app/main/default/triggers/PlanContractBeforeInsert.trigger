/*
* Class :        PlanContractBeforeInsert
* Author:        Ambica P
* Created Date:  15 July 2020
* Description:   Before Insert Trigger on Plan Contract 
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
    ********************************************************************************************************************************************
   
*/
trigger PlanContractBeforeInsert on Plan_Contract__c (before insert) {
    
    if(globalApexManager.avoidRecursion('PlanContractBeforeInsert') ) {
        return;
    }
    
    PlanContractTriggerHandler.handlebeforeInsert(Trigger.New);
}