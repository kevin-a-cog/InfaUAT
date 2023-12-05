/*
@created by       : Aishwarya B
@created on       : 01/08/2021
@Purpose          : Case comment Trigger.
@Testclass        : 
@JIRA             : 
@Tag              : T01


Change History
****************************************************************************************************
ModifiedBy      Date        Requested By        Description               Jira No.       Tag
****************************************************************************************************

*/
trigger CaseCommentTrigger on Case_Comment__c (after delete, after insert, after update, before delete, before insert, before update) {
    public static Integer count = 0;
    
    if(count < 2){
        globalApexManager.allowRun('caseTiggerProcess');
    } else if(globalApexManager.avoidRecursion('caseTiggerProcess') ) {
        return;
    }
    new CaseCommentTriggerHandler().process();
    count += 1;
}