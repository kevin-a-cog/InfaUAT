trigger ProjectRegistrationAfterInsert on Project_Registration__c (after insert) {

if(!Test.isRunningTest() && globalApexManager.avoidRecursion('ProjectRegistrationAfterInsert ')) 
    {
        return;
    }
     
    ProjectRegistrationTriggerHandler.ProjectRegistrationAfterInsert(Trigger.New);

}