/*
        @Author: Conga Services
        @Created Date:  9/18/2018
        @Description:   AfterInsert Trigger on LegalAgreement.
*/

trigger LegalAgreementAfterInsert on Legal_Agreement__c (after insert) {
    if(globalApexManager.avoidRecursion('LegalAgreementAfterInsert')) {
                    return;
        }
        APXT_Redlining.PlatformDataService.sendData(Trigger.old, Trigger.new);
        LegalAgreementTriggerHandler handler = new LegalAgreementTriggerHandler(Schema.SObjectType.Legal_Agreement__c.getName());
        handler.onTrigger(Trigger.newMap, Trigger.oldMap);
        

    if(Global_Config__c.getInstance().Mute_Triggers__c != null && Global_Config__c.getInstance().Mute_Triggers__c != true) {
        LegalAgreementTriggerHandler.LegalAgreementAfterInsert(Trigger.new);
    }        
}