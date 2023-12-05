/*
Trigger:        OpportunityLineItemAfterInsert
@Author:        Gaurav Sadhwani
@Created Date:  11 December 2016
@Description:   handles all logic on the after insert of an OpportunityLineItem
*/

/*
Change History
************************************************************************************************************************************
ModifiedBy                  Date            Requested By        Description                                   Tag
************************************************************************************************************************************
Thejaswini Sattenapalli     13/7/2017                           Call updateOppotunityDealType                 DealTypeRequirement
                                                                for Deal Type Requirement

Vivek Warrier               06-Jun-2019     Liz Matthews        Commenting out the updateOppotunityDealType   <T01>
                                                                method call
************************************************************************************************************************************
*/

trigger OpportunityLineItemAfterInsert on OpportunityLineItem (after insert) {
    //Invoke the after insert method from the trigger handler
   /* 
    if(!OpportunityTriggerHandler.OpportunityUpdateFlag) {
        
        if(globalApexManager.avoidRecursion('OpportunityLineItemAfterInsert') ) {
            return;
        }
       */
       system.debug('OpportunityLineItemAfterInsert:'+Trigger.newMap);
       public static Integer count = 0;
       if(count < 2){
            globalApexManager.allowRun('OpportunityLineItemAfterInsert');
        } else if(globalApexManager.avoidRecursion('OpportunityLineItemAfterInsert') ) {return;}        
        /* #DealTypeRequirement 
         added by Thejaswini Sattenapalli on 13/7/2017 for DealTypeRequirement
         */
         
        //OpportunityLineItemTriggerHandler.updateOppotunityDealType(Trigger.New); //<T01>
        //change to update product family fields of opp
        OpportunityLineItemTriggerHandler.handleAfterInsert(Trigger.newMap);
        count += 1;
    //}
}