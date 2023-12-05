/**
* @author Conga Services, ahafez
* @date 20180914
* @version 1.00
* @description Trigger that fires After Insert of ContentDocumentLink
*/

trigger ContentDocumentLinkAfterInsert on ContentDocumentLink (after insert, before insert) {
    if(trigger.isbefore && trigger.isInsert){
        ContentDocumentLinkTriggerHandler.ContentDocumentLinkBeforeInsert(trigger.new);
    }
    if(trigger.isAfter && trigger.isInsert){
        ContentDocumentLinkTriggerHandler.ContentDocumentLinkAfterInsert(Trigger.new);
    }
}