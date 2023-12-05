/*
        Trigger:        TaskAfterInsert 
        @Author:        Ambica Pyati
        @Created Date:  05 June 2017
        @Description:   handles all logic on the after insert of Task
*/

trigger TaskAfterInsert on Task (after Insert   ) {


    if(globalApexManager.avoidRecursion('TaskAfterInsert ')) {
                return;
    }

    ActivityTriggerHandler.TaskAfterInsert(Trigger.new);

}