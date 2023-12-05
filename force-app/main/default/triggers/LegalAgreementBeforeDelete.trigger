/*
        @Author: Conga Services
        @Created Date:  9/21/2018
        @Description:   BeforeDelete Trigger on LegalAgreement.
*/

//Conga Contracts Phase 2 Project: Conga Services - 9/29/2020 - Commented out code becuase the logic was no longer needed.  Left method stubs for code coverage.

trigger LegalAgreementBeforeDelete on Legal_Agreement__c (before delete) {
    if(globalApexManager.avoidRecursion('LegalAgreementBeforeDelete')) {
                    //return;
        }
    // LegalAgreementTriggerHandler handler = new LegalAgreementTriggerHandler(Schema.SObjectType.Legal_Agreement__c.getName());
    // handler.onTrigger(Trigger.newMap, Trigger.oldMap);
}