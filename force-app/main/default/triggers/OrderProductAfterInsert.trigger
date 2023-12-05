/***************************************************************************
*        Name        :        OrderProductTrigger 
*        Author      :        Krishna
*        Date        :        19 July 2017
*        Description :        AFTER INSERT - Create Asset and Entitlement records when OrderItem is inserted
****************************************************************************
Change History
******************************************************************
ModifiedBy                Date          Requested By             Tag       Description
RamEsh M S                12/05/2019    Prasanth Sagar                     Removed recursion logic for SALESRT-11351.

****************************************************************************/
trigger OrderProductAfterInsert on OrderItem (after insert) {
   
   if(globalApexManager.avoidRecursion(null) ) {
     return;
    }
    
    if(Trigger.isAfter && Trigger.isInsert){
        //Call the Helper class OrderProductTriggerHandler
        OrderProductTriggerHandler.afterInsert(trigger.newMap);
        //OrderProductTriggerHandler.updateOppLineItem(trigger.New);
    }
    

}