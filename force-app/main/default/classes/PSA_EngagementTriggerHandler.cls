/*
@created by       : RANJAN KISHORE
@created on       : 06/14/2021
@Purpose          : Handler class for PSA_EngagementTrigger.

Change History
**************************************************************************************************************************
ModifiedBy  |    Date       |     Requested By  |   	Description                                 |  Jira No.      | Tag No:
Wasim Akram     22-Aug-2023     Neha Kumari         Approval process to be built for PSA Engagement     PSA-3111        <T1>
Wasim           27-Oct-2023     Neha Kumari	        PS Engagement SOW/Proposal documentation workflow   PSA-3173        T2

***************************************************************************************************************************
*/
public class PSA_EngagementTriggerHandler extends TriggerHandler{

    private PSA_EngagementTriggerHelper helper = new PSA_EngagementTriggerHelper();
    
    //Methods related to the module to be called in after update context
    public override void beforeUpdate() {   
    helper.onApprovalRejection((Map<Id,Engagement__c>) newMap,(Map<Id,Engagement__c>) oldMap); //<T1>
    helper.validationOnEngagement((List<Engagement__c>) newList, (Map<Id,Engagement__c>) newMap,(Map<Id,Engagement__c>) oldMap); //<T2>
    }    
}