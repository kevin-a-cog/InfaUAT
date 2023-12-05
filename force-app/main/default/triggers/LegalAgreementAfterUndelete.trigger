/*
        @Author: Conga Services
        @Created Date:  9/18/2018
        @Description:   AfterInsert Trigger on LegalAgreement.
*/

trigger LegalAgreementAfterUndelete on Legal_Agreement__c (after undelete) {
    if(globalApexManager.avoidRecursion('LegalAgreementAfterUnDelete')) {
        return;
    }
    if(Global_Config__c.getInstance().Mute_Triggers__c != null && Global_Config__c.getInstance().Mute_Triggers__c != true) {
        APXT_Redlining.PlatformDataService.sendData(Trigger.old, Trigger.new);
    }
}