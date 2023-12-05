trigger CSMObjectiveTrigger on Objective__c (before insert,after Insert,before update,after update,before delete,after delete) {
	zsfjira.ZTriggerFactory.createAndExecuteHandler(Plan__C.sObjectType);    
    /*if(Global_Config__c.getInstance().Mute_Triggers__c != null && Global_Config__c.getInstance().Mute_Triggers__c != true){
        new CSMObjectiveTriggerHandler().process();
    }*/
    Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getValues(UserInfo.getUserId());
    if(bts == null || (bts!=null && !bts.Objective__c)){
        new CSMObjectiveTriggerHandler().process();
    }
}