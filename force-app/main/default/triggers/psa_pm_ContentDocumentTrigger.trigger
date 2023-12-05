/*
Change History
***************************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                                     Jira No.        Tag
***************************************************************************************************************************************
Vivek Warrier   7-Mar-2022      Jeff Christensen    Throwing error on update of file name on a Submitted Resume     PSA-2301        T01
*/
trigger psa_pm_ContentDocumentTrigger on ContentDocument (before delete, before update) {
    if(trigger.isDelete){
        system.debug('In delete');
        psa_pm_ContentDocumentTriggerHandler.onBeforeDelete(trigger.old);
    }
    //<T01>
    if(trigger.isUpdate && trigger.isBefore){
        system.debug('In update');
        psa_pm_ContentDocumentTriggerHandler.onBeforeUpdate(trigger.oldMap,trigger.new);
    }
    //</T01>
}