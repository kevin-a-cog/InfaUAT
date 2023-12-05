/*
        Trigger:        SubscriptionAfterUpdate
        @Author:        Thejaswini Sattenapalli
        @Created Date:  14 Septmber 2017
        @Description:    
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
	Wasim Akram		  12/23/2019	SALESRT-11149	Liz				Update the Product mix checkboxes based on conditions
																	which will determine the Renewal Type through Process 
																	Builder.
    ********************************************************************************************************************************************
   
*/
trigger SubscriptionAfterUpdate on SBQQ__Subscription__c (after Update) {

    if(globalApexManager.avoidRecursion('SubscriptionAfterUpdate') ) {
        return;
    }
    
    //call handler class
    //Commented and changed below line for JIRA SALESRT - 11149
    //SubscriptionTriggerHandler.handleAfterUpdate(Trigger.new);
    SubscriptionTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap, Trigger.newMap);
  
}