/*
        @Author: Conga Services
        @Created Date:  9/18/2018
        @Description:   AfterUpdate Trigger on LegalAgreement.
*/

//Conga Contracts Phase 2 Project: Conga Services - 9/29/2020 - Commented out code becuase the logic was no longer needed.  Left method stubs for code coverage.

trigger LegalAgreementAfterUpdate on Legal_Agreement__c (after update) {
    if(globalApexManager.avoidRecursion('LegalAgreementAfterUpdate')) {
                    return;
        }
        APXT_Redlining.PlatformDataService.sendData(Trigger.old, Trigger.new);
        // LegalAgreementTriggerHandler handler = new LegalAgreementTriggerHandler(Schema.SObjectType.Legal_Agreement__c.getName());
        // handler.onTrigger(Trigger.newMap, Trigger.oldMap);
}