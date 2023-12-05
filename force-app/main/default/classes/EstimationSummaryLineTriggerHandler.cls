/*
        Trigger:        Estimation_Sumamry_Line__c
        @Author:        Colton Kloppel
        @Created Date:  October 19 2021
        @Description:   To recalculate the total values of an Estimation Summary when updates are made to an Estimation Summary Line.
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag

    Colton Kloppel    Oct 19 2021  IPUE-52                        Initial Create  
    nibansal          07/03/2023  SALESRT-14945                   upsertOppIPUServices method to upsert the Opp IPU Services Record
	nibansal          04/07/2023  SALESRT-15406                   commented upsertOppIPUServices
    ********************************************************************************************************************************************
*/ 

public with sharing class EstimationSummaryLineTriggerHandler {
    //This ID is the org specific ID related to the 
    public static final String NON_PRODUCTION_ORG_PRODUCTCODE = 'Non-production Org';

    public EstimationSummaryLineTriggerHandler() {

    }

    public static void afterInsert(List<Estimation_Summary_line__c> newList){
        rollUpIpuValues(newList);
        //upsertOppIPUServices(newList, null);
    }

    public static void afterUpdate(List<Estimation_Summary_line__c> newList, Map<Id,EstimatioN_Summary_Line__c> oldMap){
        rollUpIpuValues(newList);
        upsertOppIPUServices(newList, oldMap);
    }

    public static void rollUpIpuValues(List<Estimation_Summary_Line__c> newList){
        Set<Id> summaryIdSet = new Set<Id>();
        for(EstimatioN_Summary_Line__c line : newList){
            if(line.Estimation_Summary__c != null){
                summaryIdSet.add(line.Estimation_Summary__c);
            }
        }

        List<Estimation_Summary__c> summariesToUpdateList = new List<Estimation_Summary__c>();
        if(!summaryIdSet.isEmpty()){
            Map<Id, Estimation_Summary__c> summaryWithLinesMap = new Map<Id, Estimation_Summary__c>([SELECT Id, Final_IPU_Estimate__c, Room_for_Growth__c,
                                                                                                            Total_Production_IPUs__c, Total_Required_IPUs__c, Additional_Non_Production_IPUs__c, RecordTypeId,
                                                                                                            (
                                                                                                                SELECT Id, Name, Estimated_Quantity__c, Estimation_Summary__c,
                                                                                                                    Product__r.ProductCode, Required_IPUs__c, Service_ID__c, Service_Name__c,
                                                                                                                    Unit_of_Measure__c
                                                                                                                FROM Estimation_Summary_Lines__r
                                                                                                            )
                                                                                                    FROM Estimation_Summary__c
                                                                                                    WHERE Id IN: summaryIdSet]);
        
            if(!summaryWithLinesMap.isEmpty()){
                for(Estimation_Summary__c summary : summaryWithLinesMap.Values()){
                    if(summary.RecordTypeId == Schema.SObjectType.Estimation_Summary__c.getRecordTypeInfosByName().get('Form Based').getRecordTypeId()){
                        if(summary.Estimation_Summary_Lines__r != null){
                            Decimal productionIPUs = 0;
                            Decimal nonProdIPUs = 0;
                            for(Estimation_Summary_Line__c line : summary.Estimation_Summary_Lines__r){
                                if(line.Required_IPUs__c != null){
                                    if(line.Product__r.ProductCode != NON_PRODUCTION_ORG_PRODUCTCODE){
                                        productionIPUs += line.Required_IPUs__c;
                                    } else if(line.Product__r.ProductCode == NON_PRODUCTION_ORG_PRODUCTCODE){
                                        nonProdIPUs += line.Required_IPUs__c;
                                    }
                                }
                            }
                            summary.Total_Production_IPUs__c = productionIPUs;
                            summary.Additional_Non_Production_IPUs__c = nonProdIPUs;
                            summary.Total_Required_IPUs__c = productionIPUs + nonProdIPUs;
                            summariesToUpdateList.add(summary);
                        }
                    }
                }
            }                                                                                            
        }
        if(!summariesToUpdateList.isEmpty()){
            try{
                update summariesToUpdateList;
            } catch (Exception ex) {
                System.debug('Exception: ' + ex);
                System.debug('Exception message: ' + ex.getMessage());
                System.debug('Exception stack trace: ' + ex.getStackTraceString());
                System.debug('Exception cause: ' + ex.getCause());
            }
        }
    }
    
    //<SALESRT-14945> Starts here
    /**
     * @description : Added the method to insert the Opportunity IPU Services records.
     * 
     * @param : newList - List of Estimation Summaries line
     * @param : oldMap - map of Estimation Summary line
     * 
     * @return : void
     */
    private static void upsertOppIPUServices(List<Estimation_Summary_line__c> newList, map<Id, Estimation_Summary_line__c> oldMap) {
        
        Set<Id> estSummaryIdSet = new Set<Id>();

        for (Estimation_Summary_line__c estSummaryLine : newList) {
            if((oldMap == null || oldMap.get(estSummaryLine.Id).Required_IPUs__c != estSummaryLine.Required_IPUs__c) && estSummaryLine.Estimation_Summary__c != null) {
                estSummaryIdSet.add(estSummaryLine.Estimation_Summary__c);
            }
        }
        
        if(!estSummaryIdSet.isEmpty() && estSummaryIdSet.size() > 0) {
            IPUServices.upsertOppIPUServices(estSummaryIdSet);
        }
        
    }
    
}