/*
        Trigger:        Opportunity_IPU_Services__c
        @Author:        Nishant Bansal
        @Created Date:  Feb 26 2023
        @Description:   To rollup the Values on opportunity
*/
/*
    Change History
    ********************************************************************************************************************************************
    ********************************************************************************************************************************************
*/ 

public without sharing class OpportunityIPUServicesTriggerHandler {

    public OpportunityIPUServicesTriggerHandler() {

    }

    public static void afterInsert(List<Opportunity_IPU_Services__c> newList){
        rollUpIPUsOnOpportunity(newList, null);
    }

    public static void afterUpdate(List<Opportunity_IPU_Services__c> newList, Map<Id,Opportunity_IPU_Services__c> oldMap){
        rollUpIPUsOnOpportunity(newList, oldMap);
    }
    
    //<SALESRT-14945> Starts here
    /**
     * @description : Added the method to rollup the IPUs on Opporunity and trigger the notification
     * 
     * @param : newList - new list of Opportunity_IPU_Services__c
     * @param : oldMap - oldmap of Opportunity_IPU_Services__c
     * 
     * @return : void
     */
    public static void rollUpIPUsOnOpportunity(List<Opportunity_IPU_Services__c> newList, Map<Id,Opportunity_IPU_Services__c> oldMap){
        
        set<Id> oppIdSet = new set<Id>();
        
        for(Opportunity_IPU_Services__c oppIPUServices : newList) {
            
            if((oldMap == null || oldMap.get(oppIPUServices.Id).Required_IPUs__c != oppIPUServices.Required_IPUs__c) && oppIPUServices.Required_IPUs__c != null && oppIPUServices.Forecast_Product__c != null && oppIPUServices.Product_Family__c != null ) {
                oppIdSet.add(oppIPUServices.Opportunity__c	);
            }
        }
        
        if(!oppIdSet.isEmpty() && oppIdSet.size() > 0 ) {
            updateRollUpsOnOpportunity(oppIdSet, oldMap == null ? true : false);
        }
    }
    
	@future
    private static void updateRollUpsOnOpportunity(set<Id> oppIdSet, Boolean isInsert){
        
        set<Id> estimationSummaryIdSet = new set<Id>();
        map<Id, Opportunity> mapOfOppIdAndOpportunity = new map<Id, Opportunity>();
        map<Id,Estimation_Summary_Notification_Config__mdt> mapOfIdAndestimationConfig = new map<Id,Estimation_Summary_Notification_Config__mdt>();
        
        for(Opportunity_IPU_Services__c oppIPUServices : [SELECT Id, Opportunity__c, Product_Family__c, Forecast_Product__c, Required_IPUs__c
                                                          FROM Opportunity_IPU_Services__c WHERE Opportunity__c IN : oppIdSet]) {
                
            Opportunity opp = new Opportunity();
            
            if(mapOfOppIdAndOpportunity == null || mapOfOppIdAndOpportunity.containsKey(oppIPUServices.Opportunity__c)) {
                opp = mapOfOppIdAndOpportunity.get(oppIPUServices.Opportunity__c);
            } else {
                opp.put('Id', oppIPUServices.Opportunity__c);                
            }
            
            for (Estimation_Summary_Notification_Config__mdt estSummaryMetadata : Estimation_Summary_Notification_Config__mdt.getAll().values()) {
                mapOfIdAndestimationConfig.put(estSummaryMetadata.Id,estSummaryMetadata);
                if(estSummaryMetadata.Forecast_Product__c == oppIPUServices.Forecast_Product__c && estSummaryMetadata.Product_Family__c == oppIPUServices.Product_Family__c ) {
                    Integer requiredIPUs = opp.get(estSummaryMetadata.Field_API_Name__c) == null ? oppIPUServices.Required_IPUs__c == null ? 0 : Integer.valueOf(oppIPUServices.Required_IPUs__c) :  oppIPUServices.Required_IPUs__c == null ? Integer.valueOf(opp.get(estSummaryMetadata.Field_API_Name__c)) : Integer.valueOf(oppIPUServices.Required_IPUs__c) + Integer.valueOf(opp.get(estSummaryMetadata.Field_API_Name__c));
                    opp.put(estSummaryMetadata.Field_API_Name__c,requiredIPUs);   
                     
                    mapOfOppIdAndOpportunity.put(opp.Id, opp);
                }
            }
        }
        
        if(mapOfOppIdAndOpportunity != null && mapOfOppIdAndOpportunity.size() > 0 && !isInsert) {
            
            for(Opportunity opp : [SELECT Id, Cloud_Data_Integration_DI__c, Advanced_Data_Integration_DI__c, Mass_Ingestion_DI__c, Data_Marketplace_EDC__c, Cloud_Data_Governance_and_Catalog_EDC__c, Cloud_Data_Quality_DQ__c, Cloud_Data_Masking_DSG__c, Cloud_Application_Integration_DI__c, Cloud_B2B_DI__c, Cloud_Data_Governance_and_Catalog_DQ__c FROM Opportunity WHERE Id IN : oppIdSet]) {
                
                if(mapOfOppIdAndOpportunity.containsKey(opp.Id)) {
                    
                    for (Estimation_Summary_Notification_Config__mdt estSummaryMetadata : mapOfIdAndestimationConfig.values()) {
                        if(estSummaryMetadata.Active__c && (mapOfOppIdAndOpportunity.get(opp.Id).get(estSummaryMetadata.Field_API_Name__c) != null && opp.get(estSummaryMetadata.Field_API_Name__c) != null && opp.get(estSummaryMetadata.Field_API_Name__c) != mapOfOppIdAndOpportunity.get(opp.Id).get(estSummaryMetadata.Field_API_Name__c))) {
                            if(Integer.valueOf(opp.get(estSummaryMetadata.Field_API_Name__c)) == 0 || Integer.valueOf(mapOfOppIdAndOpportunity.get(opp.Id).get(estSummaryMetadata.Field_API_Name__c)) == 0 || 
                               ((Integer.valueOf(opp.get(estSummaryMetadata.Field_API_Name__c)) > 0 && Integer.valueOf(mapOfOppIdAndOpportunity.get(opp.Id).get(estSummaryMetadata.Field_API_Name__c)) > 0 )&& 
                                ((math.abs(Integer.valueOf(opp.get(estSummaryMetadata.Field_API_Name__c)) - Integer.valueOf(mapOfOppIdAndOpportunity.get(opp.Id).get(estSummaryMetadata.Field_API_Name__c)))*100)/ Integer.valueOf(opp.get(estSummaryMetadata.Field_API_Name__c)))>=  estSummaryMetadata.Percentage_Diff__c)) {
                                    Opportunity oppty = mapOfOppIdAndOpportunity.get(opp.Id);
                                    oppty.Trigger_IPU_Notification__c = true;
                                    mapOfOppIdAndOpportunity.put(oppty.Id,oppty);
                                    break;
                            }
                        }
                    }
                    
                }
                
            }
            
            if(mapOfOppIdAndOpportunity.size() > 0) {
                update mapOfOppIdAndOpportunity.values();
            }
        }

    }
    
                    
}