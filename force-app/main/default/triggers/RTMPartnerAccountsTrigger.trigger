/*
Class:          RTMPartnerAccountsTrigger
@Author:        Anusha Akella
@Created Date:  04/27/2022
@Description:  Trigger for RTM_Partner_Account__c.
*/
trigger RTMPartnerAccountsTrigger on RTM_Partner_Account__c (before insert, after insert, after delete) {
    
    
    if(Trigger.isInsert && Trigger.isBefore){
        if(globalApexManager.avoidRecursion('RTMPartnerAccountsTrigger')) {
            return;
        }
        RTMPartnerAccountsTriggerHandler.handleBeforeInsert(Trigger.new);
    }
    if(Trigger.isDelete && Trigger.isAfter){
        if(globalApexManager.avoidRecursion('RTMPartnerAccountsTrigger')) {
            //return;
        }
        RTMPartnerAccountsTriggerHandler.handleAfterDelete(Trigger.oldMap);
    }
    
    if(trigger.isAfter && trigger.isInsert) {
        RTMPartnerAccountsTriggerHandler.handleAfterInsert(trigger.new); 
    }
}