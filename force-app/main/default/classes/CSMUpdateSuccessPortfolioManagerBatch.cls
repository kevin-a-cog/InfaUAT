/*
    Class:          CSMUpdateSuccessPortfolioManagerBatch
    @Author:        Karthi Gurusamy
    @Created Date:  24/02/2023
    @Description:   Batch class to update Success Portfolio based on manager  changes
                        on custom metadata Success_Portfolio_Manager_Mappings__mdt 
    @Test Class :   CSMUpdateSuccessPortfolioBatchTest

Change History
*******************************************************************************************************************************************************
ModifiedBy            Date          Requested By             Description                                                           Tag
*******************************************************************************************************************************************************
Karthi G             01-Mar-2023    AR-3107             Batch class to update Success Portfolio based on manager  changes
                                                        on custom metadata Success_Portfolio_Manager_Mappings__mdt                Initial version                        
*******************************************************************************************************************************************************
*/
global class CSMUpdateSuccessPortfolioManagerBatch  implements Database.Batchable<sObject>, Database.Stateful{
    global static globalApexManager GAM = new globalApexManager();
    Set<String> portfolioSet = new Set<String>();

    public CSMUpdateSuccessPortfolioManagerBatch(Set<String> sPortfolioSet){
        this.portfolioSet=sPortfolioSet;
    }

    public Database.QueryLocator start(Database.BatchableContext bc){        

        CSM_Static_Value__mdt mc = [Select Id,Value_Long_text__c from CSM_Static_Value__mdt WHERE developerName ='CSMUpdateSuccessPortfolioManagerBatch_Qu' LIMIT 1];
        String query = mc?.Value_Long_text__c;
        system.debug(query);
        if(query==null || query ==''){
            query='SELECT Id,Success_Portfolio__c from Account where RecordType.Name =\'Customer Account\' AND Success_Portfolio__c IN :portfolioSet';
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Account> scope){
       Map<Id,Account> newMap = new Map<Id,Account>(scope);
       AccountTriggerHandler.handleSuccessPortfolioChange(newMap.keyset(), newMap);
    }
    
    public void finish(Database.BatchableContext bc){
        gam.CreateLogs('CSMUpdateSuccessPortfolioManagerBatch--> finish','timestamp:' + System.now());
        gam.InsertDebugLogs();
    }
}