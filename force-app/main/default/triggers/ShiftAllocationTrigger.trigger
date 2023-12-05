trigger ShiftAllocationTrigger on Shift_Allocation__c (after insert, after update, after delete) {

    if(trigger.isAfter) {
        if(trigger.isInsert) {
            ShiftAllocationTriggerHandler.handleAfterInsert(trigger.new);
        }

        if(trigger.isUpdate) {
            ShiftAllocationTriggerHandler.handleAfterUpdate(trigger.new, trigger.oldMap);
        }

        if(trigger.isDelete) {
            ShiftAllocationTriggerHandler.handleAfterDelete(trigger.old);
        }
    } 
}