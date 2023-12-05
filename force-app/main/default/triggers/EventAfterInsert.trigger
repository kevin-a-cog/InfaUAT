/*
        Trigger:        EventAfterInsert 
        @Author:        Ambica Pyati
        @Created Date:  05 June 2017
        @Description:   handles all logic on the after insert of Event
*/

trigger EventAfterInsert on Event(after Insert   ) {


    if(globalApexManager.avoidRecursion('TaskAfterInsert ')) {
                return;
    }

    ActivityTriggerHandler.EventAfterInsert(Trigger.new);

}