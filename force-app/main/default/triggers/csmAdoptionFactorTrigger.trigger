trigger csmAdoptionFactorTrigger on Adoption_Factor__c(before insert, before update, after insert, before delete, after delete, after update, after undelete) {
    if(Global_Config__c.getInstance().Mute_Triggers__c != null && Global_Config__c.getInstance().Mute_Triggers__c != true){
        new CSMAdoptionFactorTriggerHandler().process();
    }
}