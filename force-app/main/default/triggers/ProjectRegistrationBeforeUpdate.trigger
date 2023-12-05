/************************************************************************************
 *  @Trigger Name: ProjectRegistrationBeforeUpdate
 *  @Author: Ashok Kumar Nayak
 *  @Date: 2017-12-13 
 *  @Description:This is a before Insert Trigger on Project Registration Object.
 ************************************************************************************
 ChangeHistory      
 ************************************************************************************/
trigger ProjectRegistrationBeforeUpdate on Project_Registration__c (before update) 
{
    if(!Test.isRunningTest() && globalApexManager.avoidRecursion('ProjectRegistrationBeforeUpdate')) 
    {
                    return;
    }
     
    If(Trigger.isBefore && Trigger.isUpdate)
    ProjectRegistrationTriggerHandler.ProjectRegistrationBeforeUpdate(Trigger.New,Trigger.OldMap);

}