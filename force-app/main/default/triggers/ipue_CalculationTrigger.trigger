trigger ipue_CalculationTrigger on Calculation__c (before insert, after insert, before update, after update) {
    new IPUE_CalculationTriggerHandler().process();
}