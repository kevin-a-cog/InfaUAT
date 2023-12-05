/*
Class:          ALTF_ContactMapDetailsTrigger
@Author:        Uday Gangula
@Created Date:  20-NOV-2021
@Description:   Trigger to call Contact Map Details Trigger Handler. 
*/

trigger ALTF_ContactMapDetailsTrigger on ALTF__Contact_Map_Details__c (after update, after delete) 
{
   
    if(Trigger.isAfter)
    ALTF_ContactMapDetailsTriggerHandler.ContactMapDetailsHandling(Trigger.newmap,Trigger.oldmap);
    
}