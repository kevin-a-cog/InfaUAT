/*
    Trigger: FeedItemTrigger
    @Author: Informatica
    @Created Date: 09-Nov-21
    @Description: Trigger on feed item
*/

trigger FeedItemTrigger on FeedItem (after insert, after delete, after update, before delete) {    
    
    //Calling the handler method to check for the context/recursive check of the trigger invocation.
    new FeedItemTriggerHandler().process();
}