/*
        @Author: Conga Services
        @Created Date:  9/18/2018
        @Description:   AfterInsert Trigger on LegalAgreement.
*/

trigger LegalAgreementAfterDelete on Legal_Agreement__c (after delete) {
	if(globalApexManager.avoidRecursion('LegalAgreementAfterDelete')) {
        return;
    }
    if(Global_Config__c.getInstance().Mute_Triggers__c != null && Global_Config__c.getInstance().Mute_Triggers__c != true) {
        APXT_Redlining.PlatformDataService.sendData(Trigger.old, Trigger.new);
    }
}