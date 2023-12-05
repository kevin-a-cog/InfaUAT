/*
Trigger:        InvoiceScheduleBeforeUpdate
@Author:        Wasim Akram
@Created Date:  20 July 2021
@Description:   

Change History
********************************************************************************************************************************************
ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag

********************************************************************************************************************************************
*/
trigger InvoiceScheduleBeforeUpdate on Invoice_Schedule__c (before update) {
   
    if(globalApexManager.avoidRecursion('InvoiceScheduleBeforeUpdate')) { return; }
    
    InvoiceScheduleTriggerHandler.handleBeforeUpdate(Trigger.NewMap, Trigger.OldMap);
}