/*
* Class :        PlanProductAfterUpdate
* Author:        Ambica P
* Created Date:  15 July 2020
* Description:   After Update Trigger on Plan Product 
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
    ********************************************************************************************************************************************
   
*/
trigger PlanProductAfterUpdate on Related_Account_Plan__c (After update) {
    
    /*if(globalApexManager.avoidRecursion('PlanProductAfterUpdate') ) {
        return;
    }*/
    Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getValues(UserInfo.getUserId());
    if(bts == null || (bts!=null && !bts.Plan_Product__c)){ 
        PlanProductTriggerHandler.handlerAfterUpdate(Trigger.New, Trigger.Oldmap);
    }
}