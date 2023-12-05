/*
        Trigger:        payTermTrigger
        @Author:        RamEsh M S
        @Created Date:  17 July 2020
        @Description:   SALESRT-12173
*/
/*
Change History
********************************************************************************************************************************************************************************************************************
ModifiedBy                Date                  JIRA                Requested By                 Description                                                 Tag
********************************************************************************************************************************************************************************************************************
*/

trigger payTermTrigger on Payment_Term__c (before insert, before update) {

    
        if(trigger.isBefore && trigger.isInsert)
        {    
            if(globalApexManager.avoidRecursion('payTermTriggerBeforeInsert')) {
            return;
            }
            
            payTermTriggerHandler.payTermTriggerBeforeInsert(Trigger.new);
            
        }
        
        
        if(trigger.isBefore && trigger.isUpdate)
        {
            if(globalApexManager.avoidRecursion('payTermTriggerBeforeUpdate')) {
            return;
            }
            
            payTermTriggerHandler.payTermTriggerBeforeUpdate(Trigger.newMap,Trigger.OldMap);
    
            
        }
}