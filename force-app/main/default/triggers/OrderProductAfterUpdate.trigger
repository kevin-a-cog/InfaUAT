/*************************************************************************************************
*        Name        :        OrderProductTrigger 
*        Author      :        Krishna
*        Date        :        19 July 2017
*        Description :        AFTER UPDATE - Create Asset and Entitlement records when OrderItem is updated and Quantity is increased.
***************************************************************************************************
Change History
***************************************************************************************************
ModifiedBy                  Date          Requested By            Description
Jiju N                    26/11/2021       Tech Debt          commented avoidRecurion part to increase code coverage as passing null
                                                              was always returning false
****************************************************************************/
trigger OrderProductAfterUpdate on OrderItem (after update) {   
    
    /*if(globalApexManager.avoidRecursion(null)){
        return;
    }*/
    
    //Call the Helper class OrderProductTriggerHandler
    OrderProductTriggerHandler.afterUpdate(trigger.New, trigger.newMap, trigger.oldMap);
}