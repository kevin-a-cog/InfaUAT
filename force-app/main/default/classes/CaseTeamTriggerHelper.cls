/*
Class:          CaseTeamTriggerHelper
@Author:        Deva
@Created Date:  30-Jun-21
@Description:   Helper class for case team triggers
*/
public class CaseTeamTriggerHelper { 
	//This method will call on case team object 
    public static void trackOnCaseTeamRoleChange(Map<Id,Case_Team__c> caseTeamMap){
        TrackerUtility.track(caseTeamMap);
    } 
}