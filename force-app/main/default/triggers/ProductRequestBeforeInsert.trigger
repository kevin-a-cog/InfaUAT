/************************************************************************************
 *  @Trigger Name: ProductRequestBeforeInsert
 *  @Author: Ashok Kumar Nayak
 *  @Date: 2017-12-20 
 *  @Description:This is a before Insert Trigger on Product Request Object.
 ************************************************************************************
 ChangeHistory      
 Puneet             31/07/2023 			  SALESRT-15141					  <SALESRT-15141>
 ************************************************************************************/
trigger ProductRequestBeforeInsert on Product_Request__c (before insert,before update, after insert, after update) 
{
    // SALESRT-15141 update start here
    if(Trigger.isBefore){

        if(Trigger.isUpdate){
            ProductRequestTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
        if(Trigger.isInsert){
            ProductRequestTriggerHandler.ProductRequestBeforeInsert(Trigger.New);
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            ProductRequestTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
        if(Trigger.isInsert){
            
        }
    }
    //SALESRT-15141 end here
}