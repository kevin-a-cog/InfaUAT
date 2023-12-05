/*
Trigger:  EstimatorCollaboratorAfterUpdate
@Author: Chandana Gowda
@Created Date: 14 Feb 2022
@Description: After update trigger on Estimator_Collaborator__c
@Jira: IPUE-156
*/
/*
Change History
************************************************************************************************************************************************************
ModifiedBy          Date            Jira No.          Description
*************************************************************************************************************************************************************
*/
trigger EstimatorCollaboratorAfterUpdate on Estimator_Collaborator__c (after update) {
    
    if (Global_config__c.getInstance() != null && Global_config__c.getInstance().Mute_Triggers__c != null && Global_config__c.getInstance().Mute_Triggers__c == true ){
        return;
    }
    
    if(globalApexManager.avoidRecursion('EstimatorCollaboratorAfterUpdate')) {
        return;
    }

    EstimatorCollaboratorTriggerHandler.handleAfterUpdate(Trigger.oldMap,Trigger.newMap);
}