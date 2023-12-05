/*
Trigger:        OpportunityLineItemBeforeUpdate
@Author:        Thejaswini Sattenapalli
@Created Date:  18 July 2017
@Description:   handles all logic on the before update of an OpportunityLineItem
*/

/*
Change History
******************************************************************
ModifiedBy          Date        Requested By        Description                 Tag

******************************************************************
*/
trigger OpportunityLineItemBeforeUpdate on OpportunityLineItem (before Update) {
    // In this Before Insert trigger we are set the Parent__c field Primary for Primary Opportunity
    // if the opportunity is secondry then set the 'secondary' in Parent__c on Opportunity Line items
    system.debug('Trigger.oldMap:'+Trigger.oldMap);
    system.debug('Trigger.newMap:'+Trigger.newMap);
    
    if(globalApexManager.avoidRecursion('OpportunityLineItemBeforeUpdate') ) {
        return;
    }
    //OpportunityLineItemTriggerHandler.updateOppotunityLineItemParentField(Trigger.new);
}