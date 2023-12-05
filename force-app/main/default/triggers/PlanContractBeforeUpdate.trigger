/*
* Class :        PlanContractBeforeUpdate
* Author:        Ambica P
* Created Date:  15 July 2020
* Description:   Before Update Trigger on Plan Contract 
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
    ********************************************************************************************************************************************
   
*/

trigger PlanContractBeforeUpdate on Plan_Contract__c (before Update) {
    
      if(globalApexManager.avoidRecursion('PlanContractBeforeUpdate') ) {
        return;
    }
    
    PlanContractTriggerHandler.handlebeforeUpdate(trigger.new);

}