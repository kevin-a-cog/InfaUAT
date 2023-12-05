/*
        @Author: Conga Services
        @Created Date:  9/10/2018
        @Description:   BeforeUpdate Trigger on LegalAgreement.
*/

trigger LegalAgreementBeforeUpdate on Legal_Agreement__c (before update) {
    if(globalApexManager.avoidRecursion('LegalAgreementBeforeUpdate')) {
        return;
    }
    if(Global_Config__c.getInstance().Mute_Triggers__c != null && Global_Config__c.getInstance().Mute_Triggers__c != true) {
        LegalAgreementTriggerHandler.LegalAgreementBeforeUpdate(Trigger.new);
    }
}