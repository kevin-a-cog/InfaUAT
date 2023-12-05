/*
Class : UpdateCampaignSeriesOnLeadBatch
@Author: Uday Kumar
@Created Date: 22nd March 2021
@Description: Batch class for updating the Campaign Series on Lead Object based on the MQL Program Name from Campaign.
              This batch class will handle both MQL program changed based on MQL Date and Campaign series is empty. SALESRT-12922
*/

global class UpdateCampaignSeriesOnLeadBatch implements Database.Batchable<sObject>
{
    public static globalApexManager GAM = new globalApexManager();
    
    // Below start method will be executed as part of the batch class execuation
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query;
        query =
            'SELECT Id,MQL_Program_Name__c,Campaign_Series__c,LastModifiedDate,Salesloft_Cadence__c FROM Lead WHERE ((MQL_Program_Name__c!=null and (Campaign_Series__c=null or Salesloft_Cadence__c = null) and LastModifiedDate=LAST_N_DAYS:1) OR MQL_Date__c=LAST_N_DAYS:1)';
        
        return Database.getQueryLocator(query);
    }
    
    // Below execute method is used to update the Campaign Series field on the lead records
    
    global void execute(Database.BatchableContext BC,List<Lead> scope)
    {
        List<Lead> LeadsToUpdate = new List<Lead>();
        Set<string> MQLProgramNameSet = new Set<String>();
        Map<string,Campaign> campaignMap = new Map<string,Campaign>();
        
        for(Lead ld:scope)
        {
            if(ld.MQL_Program_Name__c!=null){
                MQLProgramNameSet.add(ld.MQL_Program_Name__c);
            }
        }
        
        for(campaign cmp : [SELECT Id,Name,Campaign_Series__c,Salesloft_Cadence__c FROM campaign WHERE Name IN :MQLProgramNameSet]){

            campaignMap.put(cmp.Name,cmp);
        }
        
        for(Lead le : scope)
        {    
             if(campaignMap.containsKey(le.MQL_Program_Name__c)){

                Lead lead = new Lead();
                lead.Id = le.Id;
                Boolean check = false;

                if(le.Campaign_Series__c != campaignMap.get(le.MQL_Program_Name__c).Campaign_Series__c){
                    
                    lead.Campaign_Series__c = campaignMap.get(le.MQL_Program_Name__c).Campaign_Series__c;
                    check = true;
                }

                if(le.Salesloft_Cadence__c != campaignMap.get(le.MQL_Program_Name__c).Salesloft_Cadence__c){
                    
                    lead.Salesloft_Cadence__c = campaignMap.get(le.MQL_Program_Name__c).Salesloft_Cadence__c;
                    check = true;
                }

                if(check){
                    LeadsToUpdate.add(lead);
                }
            }
        }

        try{
           
            if(!LeadsToUpdate.isempty()){
                update LeadsToUpdate;
            }
        }catch(exception e){
            GAM.CreateExceptionRecords('UpdateCampaignSeriesOnLead','Exception in UpdateCampaignSeriesOnLead: ',e.getMessage());
        }
       
    }
    
    // Below Finish method is the final method called at the end of the batch class execution
    global void finish(Database.BatchableContext BC)
    {
        GAM.CreateLogs('LeadUpdated----> finish','timestamp:'+system.now());
 
        // Insert debug Logs
        GAM.InsertDebugLogs();
        GAM.CreateLogs('Calling UpdateCampaignSeriesOnContactBatch from UpdateCampaignSeriesOnLeadBatch ----> finish','timestamp:'+system.now());
        Id i=Database.ExecuteBatch(new UpdateCampaignSeriesOnContactBatch());
    }
    
}