/*
* Class :        RiskIssueBeforeUpdate
* Author:        Ambica P
* Created Date:  15 Aug 2020
* Description:   Before update Trigger on Risk
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
    ********************************************************************************************************************************************
   
*/

trigger RiskIssueBeforeUpdate on Risk_Issue__c (before update) {

    
   /* if(globalApexManager.avoidRecursion('RiskIssueBeforeUpdate') ) {
        return;
    }
      RiskIssueTriggerHandler.handleBeforeUpdate(Trigger.New, Trigger.OldMap);*/
        
}