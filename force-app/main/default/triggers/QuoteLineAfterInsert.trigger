/*
        Trigger:        QuoteLineAfterInsert
        @Author:        Kendra Claiborne
        @Created Date:  19 December 2017
        @Description:   
        17 JUL - 2019  Anil : Updated for 2d release. Moved logic from Process builder to QuotelineTriggerHandler Class.
*/

trigger QuoteLineAfterInsert on SBQQ__QuoteLine__c (after insert) {    



    
    QuoteLineTriggerHandler.handleAfterInsert(Trigger.newMap, Trigger.oldMap);
}