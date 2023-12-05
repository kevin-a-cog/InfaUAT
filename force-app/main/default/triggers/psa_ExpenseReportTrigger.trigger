trigger psa_ExpenseReportTrigger on pse__Expense_Report__c(before insert, before update,before delete, after insert, after update,after delete) {
    Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId());
    if(bts == null || bts.PSA_ExpenseReportTrigger__c){
    new psa_ExpenseReportHandler().process();
    }
}