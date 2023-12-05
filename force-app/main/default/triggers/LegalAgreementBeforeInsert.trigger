/*
        @Author: Nishit Sardessai
        @Created Date:  09/22/2021
        @Description:   BeforeInsert Trigger on LegalAgreement.
*/

trigger LegalAgreementBeforeInsert on Legal_Agreement__c (before insert) {
    if(globalApexManager.avoidRecursion('LegalAgreementBeforeInsert')) {
        return;
    }
    if(Global_Config__c.getInstance().Mute_Triggers__c != null && Global_Config__c.getInstance().Mute_Triggers__c != true) {
        LegalAgreementTriggerHandler.LegalAgreementBeforeInsert(Trigger.new);
    }
}