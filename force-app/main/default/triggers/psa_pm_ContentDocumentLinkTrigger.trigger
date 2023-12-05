trigger psa_pm_ContentDocumentLinkTrigger on ContentDocumentLink (before insert, after insert, before delete) {
    
    if(trigger.isBefore && trigger.isInsert){
        psa_pm_ContentDocumentLinkTriggerHandler.onBeforeInsert(trigger.new);
    }

    if(trigger.isAfter && trigger.isInsert) {
        psa_pm_ContentDocumentLinkTriggerHandler.onAfterInsert(trigger.new);
    }
    
    if(trigger.isBefore && trigger.isDelete) {
        psa_pm_ContentDocumentLinkTriggerHandler.onBeforeDelete(trigger.old);
    }
}