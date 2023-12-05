trigger apexScheduleTrigger on Apex_Schedules__c (before insert) {

apexSchedulerOne.apexScheduleTriggerHandler(trigger.new);

}