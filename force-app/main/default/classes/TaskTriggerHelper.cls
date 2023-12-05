/*
Class:          ActivityTriggerHandler
@Author:        VENKATESH BALLA
@Created Date:  5/22/2022
@Description:   TaskTrigger related help class. Add the trigger contex logic here and call from Handler class.
    Change History
*****************************************************************************************************************************
    ModifiedBy          Date        Requested By        Description                                             Tag   
    VENKATESH BALLA    5/22/2022      SALESRT-13807     To Include notification subscription method call.
******************************************************************************************************************************
*/
public with sharing class TaskTriggerHelper {
    public static void afterUpdate(List<Task> newList, Map<Id, Task> oldMap){
        notify(newList, oldMap);
    }
    
   /*Method Name : notify
   Description : This method gets executed from TaskAfterInsert method in After Insert Context
   Parameters   : List, newList New records.
   Return Type : None
   Use Story   : SALESRT-13807
   */
  public static void notify(List<Task> newList, Map<Id, Task> oldMap){
    List<Task> altifySourceTasks = new List<Task>();
    for(Task task : newList){
        if(task.Source__c == 'Altify' && (oldMap == NULL || oldMap.get(task.Id).Source__c == NULL)){
            altifySourceTasks.add(task);
        }
    }
    if(altifySourceTasks.size() > 0){
        NotificationService.notify(altifySourceTasks, NULL);
    }
  }
}