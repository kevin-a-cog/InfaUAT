/*
Class:          ALTF_ContactInfluenceTrigger
@Author:        Uday Gangula
@Created Date:  20-NOV-2021
@Description:   Trigger to call Contact Influence Trigger Handler. 
*/

Trigger ALTF_ContactInfluenceTrigger on ALTF__Contact_Influence__c(after insert,after update, after delete){
    if(Trigger.isAfter)
    ALTF_ContactInfluenceTriggerHandler.AltifyContactInfluenceUpdates(trigger.newMap,Trigger.oldMap);
}