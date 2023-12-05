/************************************************************************************
 *  @Trigger Name: ProjectRegistrationBeforeInsert
 *  @Author: Ashok Kumar Nayak
 *  @Date: 2017-12-13 
 *  @Description:This is a before Insert Trigger on Project Registration Object.
 ************************************************************************************
 ChangeHistory      
 ************************************************************************************/
trigger ProjectRegistrationBeforeInsert on Project_Registration__c (before insert) 
{
    if(!Test.isRunningTest() && globalApexManager.avoidRecursion('ProjectRegistrationBeforeInsert')) 
    {
                    return;
    }
     
    If(Trigger.isBefore && Trigger.isInsert)
    ProjectRegistrationTriggerHandler.ProjectRegistrationBeforeInsert(Trigger.New,Trigger.OldMap);

}