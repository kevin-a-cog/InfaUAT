trigger ProjectRegistrationAfterUpdate on Project_Registration__c (after update) {
    
if(!Test.isRunningTest() && globalApexManager.avoidRecursion('ProjectRegistrationAfterUpdate ')) 
    {
        return;
    }
    
    ProjectRegistrationTriggerHandler.ProjectRegistrationAfterUpdate(Trigger.New, trigger.oldMap);

}