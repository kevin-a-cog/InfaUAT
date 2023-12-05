trigger CSMPlanTrigger on Plan__C(before insert, before update, after insert, before delete, after delete, after update, after undelete) {
    zsfjira.ZTriggerFactory.createAndExecuteHandler(Plan__C.sObjectType);
   /* if(Global_Config__c.getInstance().Mute_Triggers__c != null && Global_Config__c.getInstance().Mute_Triggers__c != true){
        new CSMPlanTriggerHandler().process();
    }*/
    Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getValues(UserInfo.getUserId());
    if(bts == null || (bts!=null && !bts.Plan__C)){
        new CSMPlanTriggerHandler().process();
    }
}