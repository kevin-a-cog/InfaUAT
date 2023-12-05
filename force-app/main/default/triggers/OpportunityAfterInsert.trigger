/*
Trigger:        OpportunityAfterInsert
@Author:        Vishal Negandhi
@Created Date:  01 November 2016
@Description:   handles all logic on the after insert of an Opportunity

Change History
******************************************************************************************************************
ModifiedBy          Date        Requested By        Description                 
Gaurav Sadhwani     14/11/2016  Prasanth            OpportunityProductUpdate Method Added for updating the Price on the Opp fields.    
******************************************************************************************************************

******************************************************************************************************************
ModifiedBy          Date            JIRA NO      Requested By        Description                 
Ramya               01-Feb-2017                  Prasanth            Added recursion check T02  
Prasanth            05-Apr-2017    SalesRT-48    Kiran               Removed redudant static varibles SalesRT-48    
******************************************************************************************************************
------------------------------------------------------------------------------< T01>
*/

trigger OpportunityAfterInsert on Opportunity (after insert) {
    
    if(globalApexManager.avoidRecursion('OpportunityAfterInsert')) {
        return;
    }
    
    System.debug('..IN Opty Insert..'+Trigger.New);
    //<SalesRT-48>-----------------------------------------------------
    OpportunityTriggerHandler.handleAfterInsert(Trigger.new); 
    // This method will call the handler class to add sales team
    
    OpportunityTriggerHandler.handleAfterInsert(Trigger.newMap);
    // To add end user, opty products
   //z OpportunityTriggerHandler.FlagOpportunityInsert = true;
    //OpportunityTriggerHandler.OpportunityInsertFlag = true;
    //-----------------------------------------------------</SalesRT-48>
    //OpportunityTriggerHandler.sharingAfterInsertUpdate(Trigger.new,null);
}