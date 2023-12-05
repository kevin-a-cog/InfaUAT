trigger CSMPlanCommentTrigger on Plan_Comment__c (before insert, before update, after insert, before delete, after delete, after update, after undelete) {
    /*if(Global_Config__c.getInstance().Mute_Triggers__c != null && Global_Config__c.getInstance().Mute_Triggers__c != true){
        new CSMPlanCommentHandler().process();
    }*/
    Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getValues(UserInfo.getUserId());
    if(bts == null ||  (bts!=null && !bts.Plan_Comment__c)){
        new CSMPlanCommentHandler().process();
    }
}