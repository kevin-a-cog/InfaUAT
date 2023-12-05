/*
Trigger:  EstimatorCollaboratorAfterInsert
@Author: Chandana Gowda
@Created Date: 14 Feb 2022
@Description: After insert trigger on Estimator_Collaborator__c
@Jira: IPUE-156
*/
/*
Change History
************************************************************************************************************************************************************
ModifiedBy          Date            Jira No.          Description
*************************************************************************************************************************************************************
*/
trigger EstimatorCollaboratorAfterInsert on Estimator_Collaborator__c  (after insert) {

    if (Global_config__c.getInstance() != null && Global_config__c.getInstance().Mute_Triggers__c != null && Global_config__c.getInstance().Mute_Triggers__c == true ){
        return;
    }

    EstimatorCollaboratorTriggerHandler.handleAfterInsert(Trigger.newMap);
}