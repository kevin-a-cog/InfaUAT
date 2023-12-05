/*
        Trigger:        FeedCommentTrigger
        @Author:       Informatica
        @Created Date: 1-Jun-21
        @Description: Trigger on feed comment as it's not support process builder or flow tigger
*/

trigger FeedCommentTrigger on FeedComment (after insert,after update,before insert,before update, before delete) {    
    /*if(globalApexManager.avoidRecursion('FeedCommentTrigger') ) {
        return;
    }*/
    
    //Adding the check to call even on after insert
    if(trigger.isafter && trigger.isinsert ){

        if(globalApexManager.avoidRecursion('FeedCommentTrigger', 'after', 'insert') ) {
            return;
        }

        FeedCommentTriggerHandler.handleAfterInsert(trigger.new);
    }

    if(trigger.isAfter && trigger.isUpdate ){

        if(globalApexManager.avoidRecursion('FeedCommentTrigger', 'after', 'update') ) {
            return;
        }

        FeedCommentTriggerHandler.handleAfterUpdate(trigger.new);
    }

    //Adding the check to call even on after insert
    if(trigger.isBefore && trigger.isDelete ){

        if(globalApexManager.avoidRecursion('FeedCommentTrigger', 'before', 'delete') ) {
            return;
        }

        FeedCommentTriggerHandler.handleBeforeDelete(trigger.old);
    }
}