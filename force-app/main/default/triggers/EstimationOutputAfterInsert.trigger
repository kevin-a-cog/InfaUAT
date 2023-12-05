/*
Trigger:  EstimationOutputAfterInsert
@Author: Chandana Gowda
@Created Date: 15 Feb 2022
@Description: After insert trigger on Estimation_Output__c
@Jira: IPUE-219
*/
/*
Change History
************************************************************************************************************************************************************
ModifiedBy          Date            Jira No.          Description
*************************************************************************************************************************************************************
*/
trigger EstimationOutputAfterInsert on Estimation_Output__c (after insert) {

    if (Global_config__c.getInstance() != null && Global_config__c.getInstance().Mute_Triggers__c != null && Global_config__c.getInstance().Mute_Triggers__c == true ){
        return;
    }

    EstimationOutputTriggerHandler.handleAfterInsert(Trigger.newMap);
}