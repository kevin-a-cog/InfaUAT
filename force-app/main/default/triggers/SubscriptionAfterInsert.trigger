/*
        Trigger:        SubscriptionAfterInsert
        @Author:        Thejaswini Sattenapalli
        @Created Date:  14 Septmber 2017
        @Description:   To update the 
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
    Ambica Pyati    5/21/19        SALESRT-4229    Prasanth Sagar    Added Mute Check                                           <T01>
    ********************************************************************************************************************************************
   
*/
trigger SubscriptionAfterInsert on SBQQ__Subscription__c (after Insert) {

   //------------------------------------------------------------<T01>
   //Do not execute triggger if Mute Trigger is enabled for user.
    if (Global_config__c.getInstance() != null && Global_config__c.getInstance().Mute_Triggers__c != null &&
        Global_config__c.getInstance().Mute_Triggers__c == true ){
        Return;
    }
   //-------------------------------------------------------------</T01>
    //call handler class
    SubscriptionTriggerHandler.handleAfterInsert(Trigger.new);
  
}