/*
        Trigger:        QuoteLineBeforeDelete
        @Author:        Chandan Gowda
        @Created Date:  05 Nov 2020
        @Description:   Before delete trigger used to create the junctipn Object Unrenewed
*/
trigger QuoteLineBeforeDelete on SBQQ__QuoteLine__c (before delete) {
    QuoteLineTriggerHandler.handleBeforeDelete(Trigger.oldMap);
}