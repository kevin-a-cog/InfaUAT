/*
Trigger:        InvoiceTrigger
@Author:        Nishit Sardessai
@Created Date:  August 25, 2021
@Description:   handles all logic on all trigger events on InvoiceTriggerHandler

********************************************************************************************************************************************
ModifiedBy          Date            JIRA NO      Requested By       Description                                                         Tag
********************************************************************************************************************************************  
*/
trigger InvoiceTrigger on blng__Invoice__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) { 
    
    if(trigger.isBefore && trigger.isInsert)
    {    
        if(globalApexManager.avoidRecursion('InvoiceBeforeInsert')) {
            return;
        }
        InvoiceTriggerHandler.InvoiceBeforeInsert(Trigger.newMap,Trigger.OldMap);
    }
    
    if(trigger.isAfter && trigger.isInsert)
    {    
        if(globalApexManager.avoidRecursion('InvoiceAfterInsert')) {
            return;
        }
        InvoiceTriggerHandler.InvoiceAfterInsert(Trigger.newMap,Trigger.OldMap);
        
    }
    
    if(trigger.isBefore && trigger.isUpdate)
    {    
        if(globalApexManager.avoidRecursion('InvoiceBeforeUpdate')) {
            return;
        }
        InvoiceTriggerHandler.InvoiceBeforeUpdate(Trigger.newMap,Trigger.OldMap);
    }
    if(trigger.isAfter && trigger.isUpdate)
    {
        if(globalApexManager.avoidRecursion('InvoiceAfterUpdate')) {
            return;
        }
        InvoiceTriggerHandler.InvoiceAfterUpdate(Trigger.newMap,Trigger.OldMap);
    }
}