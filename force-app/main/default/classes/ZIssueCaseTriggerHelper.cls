/*
Trigger:        ZIssueCaseTriggerHelper
@Author:        balajip
@Created Date:  06 July 2021
@Description:   Handles the trigger logic for the object ZIssue_Case

Change History
****************************************************************************************************
ModifiedBy  Date        Jira No.    Tag     Description
****************************************************************************************************
balajip     07/05/2022  I2RT-6655   T01     To prevent SOQL from the nested method getCaseSubscribers inside the loop
balajip     07/13/2022  I2RT-6153   T02     To replace GCS_Segment__c field with Segment__c field in the notifications
*/

public without sharing class ZIssueCaseTriggerHelper {
    
    /**
    * Notifies the Case Team members on create/update
    * 
    * @param parameter- mapOld - map of old zIssue
    * @param parameter- mapNew - map of new zIssue
    * @return return-void
    * @throws exception - NA
    */
    public void notifyCaseTeam(Map<Id, zsfjira__ZIssue_Case__c> mapNew, Map<Id, zsfjira__ZIssue_Case__c> mapOld){               
        Set<Id> setCaseId = new Set<Id>();
        for(zsfjira__ZIssue_Case__c issueCase : mapNew.values()){
            setCaseId.add(issueCase.zsfjira__CaseId__c);
        }
        Map<Id, Case> mapCaseIdToCase = new Map<Id, Case>(
            [Select Id, OwnerId, CaseNumber, Priority, Forecast_Product__c, Support_Level__c,
                    Version__c, Segment__c, Acc__c, //T02
                    Support_Account__r.Name, Support_Account__r.New_Org_Account_Number__c,
                    Account.Name, Account.New_Org_Account_Number__c,
                    Is_case_claimed_weekend_holiday__c, Case_claimed_by_user_weekend_holiday__c //T01 
                From Case Where Id = :setCaseId]);
                
        Map<Id, Set<Case>> mapIssueIdToCases = new Map<Id, Set<Case>>();
        for(zsfjira__ZIssue_Case__c issueCase : mapNew.values()){
            mapIssueIdToCases.put(issueCase.zsfjira__ZIssueId__c, new Set<Case>{mapCaseIdToCase.get(issueCase.zsfjira__CaseId__c)});
        }

        List<zsfjira__ZIssue__c> lstIssue = [Select Id, Name, zsfjira__IssueKey__c, zsfjira__Summary__c, zsfjira__Project__c 
                                                From zsfjira__ZIssue__c 
                                                Where Id = :mapIssueIdToCases.keyset()];
        Map<Id, zsfjira__ZIssue__c> mapIssueIdToIssue = new Map<Id, zsfjira__ZIssue__c>(lstIssue);

        ZIssueTriggerHelper.createNotifications(mapIssueIdToCases, mapIssueIdToIssue);
    }

}