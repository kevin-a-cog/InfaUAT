/***************************************************************************
*        Name        :        OrderAfterInsert
*        Author      :        Kendra Claiborne
*        Date        :        11 October 2017
*        Description :        Handles all logic on the after insert of an Order
****************************************************************************
Change History
******************************************************************
ModifiedBy          Date        Requested By        Description                      
Kendra				
******************************************************************/

Trigger OrderAfterInsert on Order (after insert) {
    if(globalApexManager.avoidRecursion('OrderAfterInsert') ) {
        return;
    }
    
    OrderTriggerHandler.handleAfterInsert(Trigger.New);
}