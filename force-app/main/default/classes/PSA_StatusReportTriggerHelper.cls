/*
@created by       : RANJAN KISHORE
@created on       : 02/17/2021
@Purpose          : Helper class for PSA_StatusReportTriggerHandler.

Change History
****************************************************************************************************************************
ModifiedBy      Date            Requested By        Description                                           Jira No.       Tag
****************************************************************************************************************************
Pavithra V	 14-10-2021								Sync the Status report to  IPS Jumpstart Engagement   AR-1584      T01
*/

public class PSA_StatusReportTriggerHelper {

    
    public void delStatusReportTimeCardDetailRecords(Map<Id,Status_Report__c> newMap, Map<Id,Status_Report__c> oldMap){
        
        Set<Id> statsReportIds = new Set<Id>();
        for(Status_Report__c newStatsRec : newMap.values()){
            Status_Report__c oldStatsRec = oldMap.get(newStatsRec.Id);
            if(newStatsRec.PSA_PM_Status_Report_Week__c!=null && oldStatsRec.PSA_PM_Status_Report_Week__c!=newStatsRec.PSA_PM_Status_Report_Week__c){
                statsReportIds.add(newStatsRec.Id);
            }
        }
        if(!statsReportIds.isEmpty()){
            List<Status_Report_Detail__c> statsReportDetailList = new List<Status_Report_Detail__c>();
            statsReportDetailList = [Select Id from Status_Report_Detail__c where PSA_Status_Report__c=:statsReportIds and PSA_Timecard__c!=null];
            if(!statsReportDetailList.isEmpty()){
                delete statsReportDetailList;
            }
        
        }
        
    }
    /** Sync the Status report to  IPS Jumpstart Engagement T01 **/
    public void addEngagementToStatusReport(List<Status_Report__c> newList){
        Set<Id> projectSet = new Set<Id>();
        for(Status_Report__c sReport : newList){
            if(sReport.PSA_PM_Project__c <> null){
                projectSet.add(sReport.PSA_PM_Project__c);
            }
        }
        
        Map<Id,pse__Proj__c> projMap = new Map<Id,pse__Proj__c>([Select Id,psa_pm_Engagement__c from pse__Proj__c where Id in:projectSet]);
        for(Status_Report__c sReport : newList){
            if(projMap.get(sReport.PSA_PM_Project__c).psa_pm_Engagement__c <> null){
                sReport.PSA_PM_Engagement_Name__c = projMap.get(sReport.PSA_PM_Project__c).psa_pm_Engagement__c;
            }
        }
        
    }
    
}