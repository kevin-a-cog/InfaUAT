/*
        Trigger:        revSchTrigger
        @Author:        RamEsh M S
        @Created Date:  09 July 2020
        @Description:    I2C-659
*/
/*
Change History
********************************************************************************************************************************************************************************************************************
ModifiedBy                Date                  JIRA                Requested By                 Description                                                 Tag
********************************************************************************************************************************************************************************************************************
*/

trigger revSchTrigger on blng__RevenueSchedule__c (before insert, after insert, before update, after update) {

        
        if(trigger.isBefore && trigger.isInsert)
        {    
            if(globalApexManager.avoidRecursion('RevSchBeforeInsert')) {
            return;
            }
            
            revSchTriggerHandler.revSchBeforeInsert(Trigger.new);
            
        }
        
        if(trigger.isAfter && trigger.isInsert)
        {    
            if(globalApexManager.avoidRecursion('RevSchAfterInsert')) {
            return;
            }
            
            revSchTriggerHandler.revSchAfterInsert(Trigger.newMap);
            
        }
        
        if(trigger.isBefore && trigger.isUpdate)
        {    
            if(globalApexManager.avoidRecursion('RevSchBeforeUpdate')) {
            return;
            }
            
            revSchTriggerHandler.revSchBeforeUpdate(Trigger.newMap,Trigger.OldMap);
            
        }
        
        if(trigger.isAfter && trigger.isUpdate)
        {
            if(globalApexManager.avoidRecursion('RevSchAfterUpdate')) {
            return;
            }
            
            revSchTriggerHandler.revSchAfterUpdate(Trigger.newMap,Trigger.OldMap);
    
            
        }
}