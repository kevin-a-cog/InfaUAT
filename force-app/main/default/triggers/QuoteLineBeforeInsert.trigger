/*
        Trigger:        QuoteLineBeforeInsert
        @Author:        Kendra Claiborne
        @Created Date:  11 January 2018
        @Description:   
        
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag

    Ritika Gupta      26 June 2018  TKT-001433                      Removed the avoid recursion logic, since CPQ creates
                                                                    quotelines in multiple transactions, and we need the trigger
                                                                    to run for all the quote lines                               <T01>                   
    ********************************************************************************************************************************************

*/

trigger QuoteLineBeforeInsert on SBQQ__QuoteLine__c (before insert) {
    /*if(globalApexManager.avoidRecursion('QuoteLineBeforeInsert') ) {
        return;
    }<T01>*/
    
    QuoteLineTriggerHandler.handleBeforeInsert(Trigger.new);
}