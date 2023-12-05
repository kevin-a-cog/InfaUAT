/*
* Class :        RiskIssueBeforeInsert
* Author:        Ambica P
* Created Date:  15 Aug 2020
* Description:   Before Insert Trigger on Risk
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
    ********************************************************************************************************************************************
   
*/

trigger RiskIssueBeforeInsert on Risk_Issue__c (before insert) {
/*
    
    if(globalApexManager.avoidRecursion('RiskIssueBeforeInsert') ) {
        return;
    }
      RiskIssueTriggerHandler.handleBeforeInsert(Trigger.New);*/
        
}