/*
        Trigger:        OpportunityLineItemBeforeInsert
        @Author:        Thejaswini Sattenapalli
        @Created Date:  18 July 2017
        @Description:   handles all logic on the before insert of an OpportunityLineItem
*/

/*
Change History
******************************************************************
ModifiedBy          Date        Requested By        Description                                     Tag
Puneet Lohia    25-Jun-2021     SALESRT-12507   IPS & GES - Opportunity field update             <T12507>        
******************************************************************
*/

trigger OpportunityLineItemBeforeInsert on OpportunityLineItem (before insert) {
    
        if(globalApexManager.avoidRecursion('OpportunityLineItemBeforeInsert') ) {
        return;
    }
        //Added as part of <T12507>
        OpportunityLineItemTriggerHandler.handleBeforeInsert(Trigger.new); 

        // In this Before Insert trigger we are set the Parent__c field Primary for Primary Opportunity
        // if the opportunity is secondry then set the 'secondary' in Parent__c on Opportunity Line items
        //OpportunityLineItemTriggerHandler.updateOppotunityLineItemParentField(Trigger.new);
}