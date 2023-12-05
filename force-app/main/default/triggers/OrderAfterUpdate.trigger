/*
Trigger:        OrderAfterUpdate
@Author:        Kendra Claiborne
@Created Date:  August 28, 2017
@Description:   handles all logic on the after update on OrderTriggerHandler

Change History
******************************************************************
ModifiedBy          Date        Requested By        Description    
******************************************************************

******************************************************************
ModifiedBy          Date  JIRA NO      Requested By        Description   
******************************************************************    
*/

Trigger OrderAfterUpdate on Order (after update) {
    
    if(globalApexManager.avoidRecursion('OrderAfterUpdate') ) {
        return;
    }
    
    OrderTriggerHandler.handleAfterUpdate(Trigger.New, Trigger.oldMap);
}