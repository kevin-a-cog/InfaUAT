/*
    @created by       : balajip
    @created on       : 02/18/2021
    @Purpose          : ICareReferral Trigger.
    @Testclass        : 
    @JIRA             : 
     
 Change History
 ****************************************************************************************************
    ModifiedBy      Date        Requested By        Description               Jira No.       Tag
 ****************************************************************************************************
 
*/
trigger ICareReferralTrigger on iCare_Referral__c(before insert, after insert, before update, after update) {

    /**
    if (trigger.isBefore &&  trigger.isInsert){
        //check for recursion
        if(globalApexManager.avoidRecursion('ICareReferralTrigger', 'before', 'insert') ) {
            return;
        }

        ICareReferralTriggerHandler.setDefaultValues(trigger.ne,w); 
    }**/
    
    if(Global_Config__c.getInstance().Mute_Triggers__c != null && Global_Config__c.getInstance().Mute_Triggers__c != true){
        new ReferralManagementTriggerHandler().process();
    }
}