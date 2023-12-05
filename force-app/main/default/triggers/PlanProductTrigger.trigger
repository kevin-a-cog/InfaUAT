/*
 * Name         :   PlanProductTrigger
 * Author       :   Monserrat Pedroza
 * Created Date :   1/17/2022
 * Description  :   Trigger for Plan Product object.

 Change History
 **********************************************************************************************************
 Modified By            Date            Jira No.        Description                 Tag
 **********************************************************************************************************
 Monserrat Pedroza      1/17/2022        N/A             Initial version.            N/A
 */
trigger PlanProductTrigger on Related_Account_Plan__c(after insert, after update, after delete) {
    Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getValues(UserInfo.getUserId());
    if(bts == null || (bts!=null && !bts.Plan_Product__c)){ 
    //Now we decide the execution.
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            PlanProductTriggerHandler.afterInsert(Trigger.new);
        } else if(Trigger.isUpdate) {
            PlanProductTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        } else if(Trigger.isDelete) {
            PlanProductTriggerHandler.afterDelete(Trigger.old);
        }
    }
}}