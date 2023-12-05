/*
Trigger:        OpportunityLineItemAfterUpdate
@Author:        Gaurav Sadhwani
@Created Date:  11 December 2016
@Description:   handles all logic on the after update of an OpportunityLineItem


************************************************************************************************************************************
ModifiedBy        Date         JIRA NO     Requested By        Description                                  Tag
Prasanth       05-Apr-2017    SalesRT-48     Prasanth          Added recursion variable and removed         RecurssionAdded
                                                               redudant static varibles SalesRT-48      
************************************************************************************************************************************

*/

trigger OpportunityLineItemAfterUpdate on OpportunityLineItem (after update) {
    
    // #RecurssionAdded
   
    if(globalApexManager.avoidRecursion('OpportunityLineItemAfterUpdate') ) {
        return;
    } 
  
    OpportunityLineItemTriggerHandler.handleAfterUpdate(Trigger.oldMap, Trigger.newMap); 
  
}