/*
This trigger is just for testing purposes. Only to run inside a test context.
*/
trigger ManagedClauseCreationTestTrigger on Lead (after insert, after update, before delete) {
    if (!Test.isRunningTest()) return;
    ManagedClauseCreationTriggerHandler handler = new ManagedClauseCreationTriggerHandler(Schema.SObjectType.Lead.getName());
    handler.onTrigger(Trigger.newMap, Trigger.oldMap);
}