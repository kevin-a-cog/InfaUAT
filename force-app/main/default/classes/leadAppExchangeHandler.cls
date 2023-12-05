/*
        Class:          leadAppExchangeHandler
        @Author:        Ben Griffith
        @Created Date:  08/11/2017
        @Description:   handler class for syncing Salesforce Leads that come from AppExchange to Marketo
                        
                        there are 2 entry points:
                        1. from process builder, uses @InvocalbleMethod: processAppExchangeLead()
                        2. from a visualforce button, uses @RemoteAction: remoteSyncAppExchangeLeads()
                        
                        salesforce leads are:
                        1. synced to Marketo through the REST API
                        2. added to a Marketo smart campaign for AppExchange Leads
                        3. deleted from Salesforce
*/
/*
    Change History
******************************************************************
    ModifiedBy          Date        Requested By        Description                 Tag
        
******************************************************************
*/
/*
    ------------------------------------------------------------------------------< T01>
    //Changes done
    ------------------------------------------------------------------------------</T01>
*/

public with sharing class leadAppExchangeHandler {
    
    //Lead Record Selection
    public string selectedJSON { get; private set; }
    public list<sobject> selected { private get; private set; }
    public integer numberSelected { get; private set; }
    
    /**
    * constructor, used for Visual Force Page: leadAppExchangeListButton
    *   populates lead record selection properties
    * @param parameter-controller- standard set controller, containing list of leads available to act on
    * @return return-NA
    * @throws exception-NA
    */
    public leadAppExchangeHandler(ApexPages.StandardSetController controller) {
        selected = controller.getSelected();
        numberSelected = selected.size();
        selectedJSON = JSON.serialize(selected);
    }
    
    /**
    * this RemoteAction method runs the syncAppExchangeLeads method
    *   allows syncAppExchangeLeads method to be called via JavaScript remoting
    * @param parameter-leads- list of lead ids
    * @return return-syncResult- the sync results, including success flag, error messages, and a list of sync result details for each lead
    * @throws exception-NA
    */
    @RemoteAction
    public static syncResult remoteSyncAppExchangeLeads(List<Id> leads) {
        return syncAppExchangeLeads(leads);
    }
    
    /**
    * this InvocableMethod checks if the running context is already in a future or batch method and then runs the syncAppExchangeLeads method
    *   allows syncAppExchangeLeads method to be called via Process Builder
    * @param parameter-leads- list of lead ids
    * @return return-void
    * @throws exception-NA
    */
    @InvocableMethod(label='Sync AppExchange Leads to Marketo' description='Syncs Salesforce Leads to Marketo, Adds Them to An AppExchange Smart Campaign and then Deletes them from Salesforce')
    public static void processAppExchangeLead(List<Id> leads) {
        if(system.isFuture() || system.isBatch()) syncAppExchangeLeads(leads);
        else futuresyncAppExchangeLeads(leads);
    }
    
    /**
    * this future method, supporting HTTP callouts, runs the syncAppExchangeLeads method
    * @param parameter-leads- list of lead ids
    * @return return-void
    * @throws exception-NA
    */
    @future (callout=true)
    private static void futuresyncAppExchangeLeads(List<Id> leads) {
        syncAppExchangeLeads(leads);
    }
    
    /**
    * this method syncs leads to marketo using the marketo class, add leads to a marketo smart campaign and then deletes the salesforce lead
    * @param parameter-leads- list of lead ids
    * @return return-syncResult- the sync results, including success flag, error messages, and a list of sync result details for each lead
    * @throws exception-NA
    */
    public static syncResult syncAppExchangeLeads(List<Id> leads) {
        
        string appExchangeSmartCampaignId;
        map<string, AppExchange_Config__c> settings = AppExchange_Config__c.getAll();
        
        if(settings.size() == 1) {
            AppExchange_Config__c s = settings.values().get(0);
            
            appExchangeSmartCampaignId = s.Marketo_AppExchange_Smart_Campaign_Id__c;
        }
        
        syncResult result = new syncResult();
        result.results = new map<id, map<string,string>>();
        
        string mappingsJSON = '[    {"sfdc": "Company", "marketo": "company"},  {"sfdc": "Country", "marketo": "country"},  {"sfdc": "Email", "marketo": "email"},  {"sfdc": "FirstName", "marketo": "firstName"},  {"sfdc": "LastName", "marketo": "lastName"},    {"sfdc": "LeadSource", "marketo": "leadSource"},    {"sfdc": "State", "marketo": "state"},  {"sfdc": "Title", "marketo": "title"}   ]';
        list<map<string,string>> mappings = (list<map<string,string>>)json.deserialize(mappingsJSON, list<map<string,string>>.class);
        
        marketo mktoClient = new marketo();
        
        
        string leadSOQL = 'select id';
        for(map<string,string> mapping : mappings) {
            leadSOQL += ', ' + mapping.get('sfdc');
        }
        leadSOQL += ' from lead where id in :leads';
        
        map<id,lead> appExchangeLeads;
        
        try {
            appExchangeLeads = new map<id,lead>((list<lead>)database.query(leadSOQL));
        } catch (Exception e) {
            return processException(e, result);
        }
        
        //Step 1: Query for Existing Leads by Email Address
        map<string,string> emailMarketoIdMap = new map<string,string>();
        map<string,string> emailSfdcIdMap = new map<string,string>();
        for(lead l : appExchangeLeads.values()) {
            emailMarketoIdMap.put(l.email, null);
            emailSfdcIdMap.put(l.email, l.id);
        }
        
        try {
            marketo.ResponseOfMap marketoLeads = mktoClient.getLeadsByFilterType('email',emailMarketoIdMap.keySet());
            map<string,string> emailMarketoLastUpdatedMap = new map<string,string>();

            for(map<string,string> l : marketoLeads.result) {
                if(emailMarketoLastUpdatedMap.containsKey(l.get('email'))) {
                    if(l.get('updatedAt') > emailMarketoLastUpdatedMap.get(l.get('email'))) {
                        emailMarketoIdMap.put(l.get('email'),l.get('id'));
                        emailMarketoLastUpdatedMap.put(l.get('email'),l.get('updatedAt'));
                    }
                } else {
                    emailMarketoIdMap.put(l.get('email'),l.get('id'));
                    emailMarketoLastUpdatedMap.put(l.get('email'),l.get('updatedAt'));
                }
            }
        } catch (Exception e) {
            return processException(e, result);
        }
                        
        //Step 2: Sync Leads to Marketo
        marketo.SyncLeadRequest existingLeadSync = new marketo.SyncLeadRequest();
        existingLeadSync.action = 'updateOnly';
        existingLeadSync.lookupField = 'id';
        existingLeadSync.input = new list<map<string,string>>();
        
        marketo.SyncLeadRequest newLeadSync = new marketo.SyncLeadRequest();
        newLeadSync.action = 'createOrUpdate';
        newLeadSync.lookupField = 'email';
        newLeadSync.input = new list<map<string,string>>();
        
        
        set<integer> successfulMarketoLeadSyncs = new set<integer>();
        map<string,string> emailMarketoSyncResult = new map<string,string>();
        set<id> leadsToDelete = new set<id>();
        
        for(string k : emailMarketoIdMap.keySet()) {
            
            lead l = appExchangeLeads.get(emailSfdcIdMap.get(k));
            
            map<string,string> fields = new map<string,string>();
            for(map<string,string> mapping : mappings) {
                object sfdcField = l.get(mapping.get('sfdc'));
                if(sfdcField != null) fields.put(mapping.get('marketo'), (string)sfdcField);
            }
            
            if(emailMarketoIdMap.get(k) == null) {
                newLeadSync.input.add(fields);
            } else {
                fields.put('id', emailMarketoIdMap.get(k));
                existingLeadSync.input.add(fields);
            }
        }
        
        
        if(existingLeadSync.input.size() > 0) {
            try {
                marketo.ResponseOfLead existingLeadResult = mktoClient.syncLeads(existingLeadSync);
                
                for(integer i=0; i<existingLeadResult.result.size(); i++) {
                    
                    marketo.Lead marketoResult = existingLeadResult.result.get(i);
                    
                    emailMarketoSyncResult.put(existingLeadSync.input.get(i).get('email'), marketoResult.status);
                    if(marketoResult.status == 'updated') successfulMarketoLeadSyncs.add(marketoResult.id);
                }
                
            } catch (Exception e) {
                return processException(e, result);
            }
        }
        
        if(newLeadSync.input.size() > 0) {
            try {
                marketo.ResponseOfLead newLeadResult = mktoClient.syncLeads(newLeadSync);
                
                for(integer i=0; i<newLeadResult.result.size(); i++) {
                    
                    marketo.Lead marketoResult = newLeadResult.result.get(i);
                    
                    emailMarketoSyncResult.put(newLeadSync.input.get(i).get('email'), marketoResult.status);
                    
                    if(marketoResult.status == 'created') {
                        
                        successfulMarketoLeadSyncs.add(marketoResult.id);
                        emailMarketoIdMap.put(newLeadSync.input.get(i).get('email'), String.valueOf(marketoResult.id));
                        
                    }
                }
                
            } catch (Exception e) {
                return processException(e, result);
            }
        }
        
        //update results with marketo sync statuses
        for(lead l : appExchangeLeads.values()) {
            
            map<string,string> resultMap = result.results.containsKey(l.id) ? result.results.get(l.id) : new map<string,string>();
            
            resultMap.put('email', l.email);
            resultMap.put('marketo sync', emailMarketoSyncResult.get(l.email));
            resultMap.put('marketo id', emailMarketoIdMap.get(l.email));
            
            result.results.put(l.id, resultMap);
        }
        
        
        //Step 3: Request Campaign
        marketo.TriggerCampaignRequest triggerCampaignRequest = new marketo.TriggerCampaignRequest();
        triggerCampaignRequest.input = new marketo.TriggerCampaignData();
        triggerCampaignRequest.input.leads = new list<marketo.InputLead>();
        
        for(integer id : successfulMarketoLeadSyncs) {
            marketo.InputLead l = new marketo.InputLead();
            l.id = id;
            
            triggerCampaignRequest.input.leads.add(l);
        }
        
        marketo.ResponseOfCampaign requestCampaignResult;
        try {
            requestCampaignResult = mktoClient.requestCampaign(appExchangeSmartCampaignId, triggerCampaignRequest);
            
            if(requestCampaignResult.success) {
                for(lead l : appExchangeLeads.values()) {
            
                    map<string,string> resultMap = result.results.containsKey(l.id) ? result.results.get(l.id) : new map<string,string>();
                    
                    resultMap.put('marketo smart campaign', appExchangeSmartCampaignId);
                    
                    if(successfulMarketoLeadSyncs.contains(Integer.valueOf(resultMap.get('marketo id')))) {
                        
                        resultMap.put('marketo smart campaign status', 'requested');
                        leadsToDelete.add(l.id);    
                    
                    } else {
                        
                        resultMap.put('marketo smart campaign status', 'error');    
                        
                    }
                    
                    result.results.put(l.id, resultMap);
                }
            }
        } catch(Exception e) {
            return processException(e, result);
        }
        
        //Step 4: Delete Leads in Salseforce
        try {
            if(requestCampaignResult.success) {
                
                database.deleteresult[] deleteResult = database.delete(new list<id>(leadsToDelete), false);
                
                for(database.deleteresult r : deleteResult) {
                    
                    map<string,string> resultMap = result.results.containsKey(r.getId()) ? result.results.get(r.getId()) : new map<string,string>();
                    resultMap.put('deleted', string.valueOf(r.isSuccess()));
                    resultMap.put('deleted errors', String.join(r.getErrors(), '; '));
                    
                }
            }
        } catch(Exception e) {
            return processException(e, result);
        }
        
        result.success = true;
        
        return result;
    }
    
    
    /*
    ******************************************************************
    *   private helper methods
    ******************************************************************
    */
    private static syncResult processException(Exception e, syncResult result) {
        result.success = false;
        result.errorMessage = e.getMessage();
        return result;
    }
    
    
    /*
    ******************************************************************
    *   Additional Classes for custom types
    ******************************************************************
    */
    public class syncResult {
        public boolean success { get; set; }
        public string errorMessage { get; set; }
        public map<id, map<string,string>> results { get; set; }
    }
}