/*
Trigger:        InvoiceScheduleBeforeDelete
@Author:        Wasim Akram
@Created Date:  20 July 2021
@Description:   

Change History
********************************************************************************************************************************************
ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag

********************************************************************************************************************************************
*/
trigger InvoiceScheduleBeforeDelete on Invoice_Schedule__c (before delete) {
   
    if(globalApexManager.avoidRecursion('InvoiceScheduleBeforeDelete')) { return; }
    
    InvoiceScheduleTriggerHandler.handleBeforeDelete(Trigger.old);
}