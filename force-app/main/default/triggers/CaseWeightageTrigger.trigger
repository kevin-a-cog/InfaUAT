/*
@created by       : Venky K
@created on       : 01/17/2022
@Purpose          : CaseWeightageTrigger.
@Testclass        : 
@JIRA             : 
@Tag              : 


Change History
****************************************************************************************************
ModifiedBy      Date        Requested By        Description               Jira No.       Tag
****************************************************************************************************

*/
trigger CaseWeightageTrigger on Case_Weightage__c (Before Insert, Before Update) {
    CaseWeightageTriggerHandler.updateWeightage(Trigger.New);
}