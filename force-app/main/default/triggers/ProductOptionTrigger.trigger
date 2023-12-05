/*
Trigger:        ProductOptionTrigger
@Author:        Ramya Ravi 
@Created Date:  27/10/2020 
@Description:   handles all logic on the before insert, before update of SBQQ__ProductOption__c
*/

trigger ProductOptionTrigger on SBQQ__ProductOption__c (after insert, after update, after delete) {
    if(Trigger.isAfter && Trigger.isInsert )
    {
        ProductOptionTriggerHandler.handleAfterInsert(Trigger.new);
    }
    if(Trigger.isAfter && Trigger.isUpdate )
    {
        ProductOptionTriggerHandler.handleAfterUpdate(Trigger.new); 
    }
     if(Trigger.isAfter && Trigger.isDelete )
    {
        ProductOptionTriggerHandler.handleBeforeDelete(Trigger.old); 
    }
  
}