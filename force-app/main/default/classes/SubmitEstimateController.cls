/*
Trigger:        SubmitEstimateController
@Author:        Anusha Akella
@Created Date:  March 30 2021
@Description:   Submit Estimate button should not be visible if the collaborator has Read Only access IPUE-249
*/
/*
Change History
********************************************************************************************************************************************
ModifiedBy        Date              JIRA No.      Requested By      Description                                                 Tag

********************************************************************************************************************************************
*/ 
public with sharing class SubmitEstimateController {
    @AuraEnabled (cacheable = true)
    public static boolean commUserAccess(String recordId) {
        UserRecordAccess recordAccess = [SELECT RecordId,HasEditAccess,HasReadAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :recordId];
        
        return recordAccess.HasEditAccess;
    }
}