trigger FeedMetaTrigger on Feed_Meta__c (before insert,after insert) {
    
    if(trigger.IsAfter && trigger.isInsert){
        FeedMetaTriggerHandler handler = new FeedMetaTriggerHandler();
        handler.OnAfterInsert(trigger.New);
    }

}