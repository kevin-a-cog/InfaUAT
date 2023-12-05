/*
Change History
*********************************************************************************************************************
ModifiedBy     Date             Jira No.        Description                                                 Tag
*********************************************************************************************************************
NA             NA               UTOPIA          Initial version.                                            NA
Vignesh D      23-Dec-2021      I2RT-5013       Entitled Product rollup to support account code issue       T01
Vignesh D      16-Jun-2023      I2RT-8398       Added filter to exclude Archived EPs                        T02
*/
global class EntitledProductRollupBatch implements Database.Batchable<sObject>{ 


    global static globalApexManager GAM = new globalApexManager();

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id,Support_Account__c from Entitled_Product__c WHERE Archived__c = false'; //<T02>
        return Database.getQueryLocator(query); 
    }

    global void execute(Database.BatchableContext BC, List<Entitled_Product__c> scope)
    {
        Set<id> setSupportAccountsToRecalculate = new Set<id>();
        Set<id> setEntitledProductRollup = new set<id>();

        for (Entitled_Product__c ep : scope){
            system.debug('Scope ep'+ep);
            setEntitledProductRollup.add(ep.Id);
            if(String.isNotBlank(ep?.Support_Account__c)){ //<T01>
                setSupportAccountsToRecalculate.add(ep.Support_Account__c);
            }
        }
         
        //Update Support Account and EP
        if(setEntitledProductRollup!= null && setEntitledProductRollup.size()>0)
            EntitledProductService.updateEntitledProducts(setEntitledProductRollup);
      
        //Calculate Support Level
        if(setSupportAccountsToRecalculate!= null&& setSupportAccountsToRecalculate.size()>0){
            SupportAccountService.updateSupportAccounts(setSupportAccountsToRecalculate);
        }
    }

    global void finish(Database.BatchableContext BC)
    {
        //Insert debug Logs
        GAM.CreateLogs('CreateSupportAccountBatch--> finish','timestamp:' + System.now());
        GAM.InsertDebugLogs();
    }
   
}