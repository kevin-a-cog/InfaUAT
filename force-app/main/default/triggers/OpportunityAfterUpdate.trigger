/*
Trigger:        OpportunityAfterUpdate
@Author:        Gaurav Sadhwani
@Created Date:  14 November 2016
@Description:   handles all logic on the after update of an Opportunity
*/
/*
Change History

*********************************************************************************************************************************************
ModifiedBy          Date            JIRA NO     Requested By        Description                 
Ramya               01-Feb-2017                 Prasanth            Added recursion check T01
Prasanth            05-Apr-2017    SalesRT-48   Prasanth            Added recursion variable and emoved redudant static varibles SalesRT-48  
Chandana            25-apr-2022                                     Removing FlagOpportunityInsert, not being used anymore  T02  
*********************************************************************************************************************************************
------------------------------------------------------------------------------< T01>
*/

trigger OpportunityAfterUpdate on Opportunity (after update) {
    /*  if(globalApexManager.avoidRecursion('OpportunityAfterUpdate') && 
        (globalApexManager.avoidRecursion('OpportunityLineItemAfterUpdate') && 
        globalApexManager.avoidRecursion('OpportunityLineItemAfterInsert')) ) 
    */
    
    //<SalesRT-48>---------------------------------------------------------------- 
    if(/*----<T02>----!OpportunityTriggerHandler.FlagOpportunityInsert &&*/ globalApexManager.avoidRecursion('OpportunityAfterUpdate') &&
       (globalApexManager.avoidRecursion('OpportunityLineItemAfterUpdate') || 
        globalApexManager.avoidRecursion('OpportunityLineItemAfterInsert'))
      )
        //----------------------------------------------------------------</SalesRT-48>
    {
        return;
    }
    System.debug('..IN Opty Update..'+Trigger.New);
    
    OpportunityTriggerHandler.handleAfterUpdate(Trigger.old,Trigger.newMap);     
    
    System.debug('In opty update , before Line item insert');
    
    OpportunityTriggerHandler.handleAfterUpdate(Trigger.oldMap, Trigger.newMap); 
    
    System.debug('In opty update , afterLine item insert');

}