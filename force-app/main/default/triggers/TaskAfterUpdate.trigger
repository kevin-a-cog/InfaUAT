/*
Trigger:        TaskAfterUpdate
@Author:        Venkatesh Balla
@Created Date:  20 May 2022
@Description:   handles all logic on the after update of Task
@UserStory      SALESRT#13807
*/
trigger TaskAfterUpdate on Task (after update) {
    if(globalApexManager.avoidRecursion('TaskAfterUpdate')) {
            return;
        }
    ActivityTriggerHandler.taskAfterUpdate(Trigger.New, Trigger.oldMap);
}