/*
        Class:          IPUServices
        @Author:        Nishant Bansal
        @Created Date:  March 03 20213
        @Description:   To upsert the Opportunity IPU services record
*/
/*
    Change History
    ********************************************************************************************************************************************
    ModifiedBy        Date          JIRA No.      Requested By      Description                                                 Tag
    ********************************************************************************************************************************************
	* Nishant Bansal       04-06-2023      SALESRT-15406
*/
public without sharing class IPUServices {
    
     //<SALESRT-14945> Starts here
    /**
     * @description : Added the method to insert the Opportunity IPU Services records.
     * 
     * @param : list - estSummaryIdSet
     * @param : set - oppIdSet
     * 
     * @return : void
     */
    @future
    public static void insertOppIPUServices(Set<Id> estSummaryIdSet, Set<Id> oppIdSet) {
        
        List<Opportunity_IPU_Services__c> oppIPUServicesList = new List<Opportunity_IPU_Services__c>();
        
        if(oppIdSet.size() > 0 ) {
            delete [SELECT ID FROM Opportunity_IPU_Services__c WHERE Opportunity__c IN : oppIdSet];
        }
        
        for(Estimation_Summary_Line__c  estSummaryLine : [SELECT Id, Forecast_Product__c, Product__c, Product_Family__c, Required_IPUs__c, Service_Name__c, Estimation_Summary__r.Opportunity__c, Estimation_Summary__r.Primary__c FROM Estimation_Summary_Line__c WHERE Estimation_Summary__c IN : estSummaryIdSet]) {
            
            Opportunity_IPU_Services__c oppIPUServices = new Opportunity_IPU_Services__c();
            oppIPUServices.Estimation_Summary_Line_Id__c = estSummaryLine.Id;
            oppIPUServices.Forecast_Product__c = estSummaryLine.Forecast_Product__c;
            oppIPUServices.Opportunity__c = estSummaryLine.Estimation_Summary__r.Opportunity__c;
            oppIPUServices.Product__c = estSummaryLine.Product__c;
            oppIPUServices.Product_Family__c = estSummaryLine.Product_Family__c;
            oppIPUServices.Required_IPUs__c = estSummaryLine.Required_IPUs__c;
            oppIPUServices.Service_Name__c = estSummaryLine.Service_Name__c;
            oppIPUServicesList.add(oppIPUServices);
        }

        if(!oppIPUServicesList.isEmpty() && oppIPUServicesList.size() > 0 ) {
            insert oppIPUServicesList;
        }
        
    }
    
    //<SALESRT-14945> Starts here
    /**
     * @description : Added the method to upsert the Opportunity IPU Services records.
     * 
     * @param : list - estSummaryLineIdSet
     * 
     * @return : void
     */
    public static void upsertOppIPUServices(Set<Id> estSummaryIdSet) {  
        
        List<Opportunity_IPU_Services__c> oppIPUServicesList = new List<Opportunity_IPU_Services__c>();
        
        for(Estimation_Summary_Line__c  estSummaryLine : [SELECT Id, Forecast_Product__c, Product__c, Product_Family__c, Required_IPUs__c, Service_Name__c, Estimation_Summary__r.Opportunity__c, Estimation_Summary__r.Primary__c FROM Estimation_Summary_Line__c WHERE Estimation_Summary__c IN : estSummaryIdSet]) {
            
            if(estSummaryLine.Estimation_Summary__r.Primary__c) {
                
                Opportunity_IPU_Services__c oppIPUServices = new Opportunity_IPU_Services__c();
                oppIPUServices.Estimation_Summary_Line_Id__c = estSummaryLine.Id;
                oppIPUServices.Forecast_Product__c = estSummaryLine.Forecast_Product__c;
                oppIPUServices.Opportunity__c = estSummaryLine.Estimation_Summary__r.Opportunity__c;
                oppIPUServices.Product__c = estSummaryLine.Product__c;
                oppIPUServices.Product_Family__c = estSummaryLine.Product_Family__c;
                oppIPUServices.Required_IPUs__c = estSummaryLine.Required_IPUs__c;
                oppIPUServices.Service_Name__c = estSummaryLine.Service_Name__c;
                oppIPUServicesList.add(oppIPUServices); 
                
            }
        }

        if(!oppIPUServicesList.isEmpty() && oppIPUServicesList.size() > 0 ) {
            upsert oppIPUServicesList Estimation_Summary_Line_Id__c; 
        }
        
    }
    
    /**
     * @description : Added the method to delete the Opportunity IPU Services records.
     * 
     * @param : list - estSummaryLineIdSet, set - oppIdSet
     * 
     * @return : void
     */
    public static void deleteOppIPUServices(Set<Id> estSummaryIdSet, Set<Id> oppIdSet) {
        if(oppIdSet.size() > 0 ) {
            delete [SELECT ID FROM Opportunity_IPU_Services__c WHERE Opportunity__c IN : oppIdSet];
        }
    }
    
}