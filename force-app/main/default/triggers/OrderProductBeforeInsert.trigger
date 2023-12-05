/*
        Trigger:        OrderProductBeforeInsert
        @Author:        Rupanjana Mitra
        @Created Date:  14 Sept 2017
        @Description:   To align billing dates for amendments
******************************************************************
Change History
******************************************************************
ModifiedBy          Date            Requested By           Tag       Description
RamEsh M S          12/05/2019      Prasanth Sagar                   Removed recursion logic for SALESRT-11351.

*/

trigger OrderProductBeforeInsert on OrderItem(before Insert, before Update){
    
   /*if(globalApexManager.avoidRecursion(null) ) {
        return;
    }*/
    
    //Call the Helper class OrderProductTriggerHandler
    if(Trigger.isInsert)
        OrderProductTriggerHandler.beforeInsert(trigger.New, trigger.newMap, trigger.oldMap);
    if(Trigger.isUpdate)
        OrderProductTriggerHandler.beforeUpdate(trigger.New, trigger.newMap, trigger.oldMap);
}