trigger pse_BudgetTrigger on pse__Budget__c (before insert,before update,before delete, after insert, after update,after delete) {
    
    Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId());
    if(bts == null || bts.PSE_Budget__c){
		new pse_BudgetTriggerHandler().process();
    }
}