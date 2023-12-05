/*
Trigger:        fulfillmentLineTrigger
@Author:        Nishit S
@Created Date:  1/24/2022
@Description:    F2A-440
*/
/*
Change History
********************************************************************************************************************************************************************************************************************
ModifiedBy                Date                  JIRA                Requested By                 Description                                                 Tag
********************************************************************************************************************************************************************************************************************
*/

trigger fulfillmentLineTrigger on Fulfillment_Line__c (before insert, after insert, before update, after update) {
    
    
    if(trigger.isBefore && trigger.isInsert)
    {    
        if(globalApexManager.avoidRecursion('fulfillmentLineBeforeInsert')) {
            return;
        }
        fulfillmentLineTriggerHandler.fulfillmentLineBeforeInsert(Trigger.oldMap, Trigger.newMap);
    }
    
    if(trigger.isAfter && trigger.isInsert)
    {    
        if(globalApexManager.avoidRecursion('fulfillmentLineAfterInsert')) {
            return;
        }
        fulfillmentLineTriggerHandler.fulfillmentLineAfterInsert(Trigger.oldMap, Trigger.newMap);
    }
    
    if(trigger.isBefore && trigger.isUpdate)
    {    
        if(globalApexManager.avoidRecursion('fulfillmentLineBeforeUpdate')) {
            return;
        }
        fulfillmentLineTriggerHandler.fulfillmentLineBeforeUpdate(Trigger.oldMap, Trigger.newMap);
    }
    
    if(trigger.isAfter && trigger.isUpdate)
    {
        if(globalApexManager.avoidRecursion('fulfillmentLineAfterUpdate')) {
            return;
        }
        fulfillmentLineTriggerHandler.fulfillmentLineAfterUpdate(Trigger.oldMap, Trigger.newMap);
        
    }
}