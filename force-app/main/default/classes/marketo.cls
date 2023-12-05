/*
        Class:          marketo
        @Author:        Ben Griffith
        @Created Date:  08/11/2017
        @Description:   class to use Marketo Rest API
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

public with sharing class marketo {
    
    //Marketo Rest credentials
    string RESTendpoint;
    string RESTidentity;
    string clientId;
    string clientSecret;
    
    //Marketo identity object, with oauth token required for all Rest calls
    private ResponseOfIdentity identity {
        get {
            if(identity == null) auth();
            return identity; 
        }
        set;
    }
    
    //HTTP Request settings
    static final integer HTTPtimeout = 120000; //HTTP Request timeout in milliseconds
    
    /**
    * constructor, pulls Rest API credentials from AppExchange Config custom settings
    * @param 
    * @return return-NA
    * @throws exception-NA
    */
    public marketo() {
        
        map<string, AppExchange_Config__c> settings = AppExchange_Config__c.getAll();
        
        if(settings.size() == 1) {
            AppExchange_Config__c s = settings.values().get(0);
            
            this.RESTendpoint = s.Marketo_REST_Endpoint__c;
            this.RESTidentity = s.Marketo_Identity_Endpoint__c;
            this.clientId = s.Marketo_REST_Client_Id__c;
            this.clientSecret = s.Marketo_REST_Client_Secret__c;
        }
    }
    
    /**
    * this method authenticates with Marketo's Rest API, storing authentication token and details in identity
    * @param 
    * @return return-void
    * @throws exception-NA
    */
    private void auth() {
        
        string endpoint = this.RESTidentity + '/oauth/token';
        endpoint += '?grant_type=client_credentials';
        endpoint += '&client_id=' + this.clientId;
        endpoint += '&client_secret=' + this.clientSecret;

        identity = (ResponseOfIdentity)restRequest(
            endpoint,
            'POST',
            null,
            false,
            ResponseOfIdentity.class
        );
    }
    
    /**
    * this method calls the Marketo Rest API method: Get Leads By Filter Type
    *   Get Leads by Filter Type: Returns a list of up to 300 leads based on a list of values in a particular field
    *   Required Marketo Permissions: Read-Only Lead, Read-Write Lead
    * @param parameter-filterType- The Marketo lead field to filter on
    * @param parameter-filterValues- A set of values to filter on in the specified field
    * @return return-ResponseOfMap- includes success/error/paging information as well as results as an array of map<string,string>
    *   representing leads and their fields 
    * @throws exception-NA
    */
    public ResponseOfMap getLeadsByFilterType(string filterType, set<string> filterValues) {
        
        string endpoint = this.RESTendpoint + '/v1/leads.json';
        endpoint += '?filterType=' + EncodingUtil.urlEncode(filterType, 'UTF-8');
        
        
        boolean firstValue = true;
        for(string val : filterValues) {
            if(firstValue) {
                endpoint += '&filterValues=' + EncodingUtil.urlEncode(val, 'UTF-8');
                firstValue = false;
            } else {
                endpoint += ',' + EncodingUtil.urlEncode(val, 'UTF-8');
            }
        }
        
        return (ResponseOfMap)restRequest(endpoint, ResponseOfMap.class);
    }
    
    /**
    * this method calls the Marketo Rest API method: Sync Leads
    *   Syncs a list of leads to the target instance
    *   Required Marketo Permissions: Read-Write Lead
    * @param parameter-leads- Sync Request includes sync action (createOnly, updateOnly, etc.), lookup Field, list of leads and their fields to sync
    * @return return-ResponseOfLead- includes success/error/paging information as well as results as a list of marketo.Lead
    *   including lead ids and the sync status (created, updated, etc.) 
    * @throws exception-NA
    */
    public ResponseOfLead syncLeads(SyncLeadRequest leads) {
        
        string endpoint = this.RESTendpoint + '/v1/leads.json';
        
        return (ResponseOfLead)restRequest(endpoint, 'POST', json.serialize(leads), ResponseOfLead.class);
    }
    
    /**
    * this method calls the Marketo Rest API method: Push to Marketo
    *   Upserts a lead, and generates a Pust to Marketo activity
    *   Required Marketo Permissions: Read-Write Lead
    * @param parameter-leads- Sync Request includes program name, source, reason, lookup Field, list of leads and their fields to sync
    * @return return-ResponseOfLead- includes success/error/paging information as well as results as a list of marketo.Lead
    *   including lead ids and the sync status (created, updated, etc.) 
    * @throws exception-NA
    */
    public ResponseOfLead pushToMarketo(PushLeadToMarketoRequest leads) {

        string endpoint = this.RESTendpoint + '/v1/leads/push.json';
        
        return (ResponseOfLead)restRequest(endpoint, 'POST', json.serialize(leads), ResponseOfLead.class);
    }
    
    /**
    * this method calls the Marketo Rest API method: Request Campaign
    *   Passes a set of leads to a trigger campaign to run through the campaign's flow. The designated campaign must have a Campaign
    *   is Requested: Web Service API trigger, and must be active. My tokens local to the campaign's parent program can be overridden
    *   for the run to customize content.
    *   Required Marketo Permissions: Execute Campaign
    * @param parameter-campaignId- The Marketo id of the campaign to trigger
    * @param parameter-leads- Trigger Campaign Request includes list of Marketo lead ids to run through the smart campaign as well as a
    *   list of tokens to override
    * @return return-ResponseOfCampaign- includes success/error/paging information as well as results as a list of marketo.Campaign
    *   including campaign id of the requested campaign 
    * @throws exception-NA
    */
    public ResponseOfCampaign requestCampaign(string campaignId, TriggerCampaignRequest leads) {
        
        string endpoint = this.RESTendpoint + string.format('/v1/campaigns/{0}/trigger.json', new string[]{campaignId});
        
        return (ResponseOfCampaign)restRequest(endpoint, 'POST', json.serialize(leads), ResponseOfCampaign.class);
    }
    
    
    /*
    ******************************************************************
    *   private REST request helper methods
    ******************************************************************
    */
    private object restRequest(string endpoint, System.Type responseType) {
        return restRequest(endpoint, null, null, true, responseType);
    }
    
    private object restRequest(string endpoint, string method, string body, System.Type responseType) {
        return restRequest(endpoint, method, body, true, responseType);
    }
    
    private object restRequest(
        string endpoint,
        string method,
        string body,
        boolean authHeader,
        System.Type responseType
    ) {
        object response;
        httpRequest req = new httpRequest();
        req.setTimeout(HTTPtimeout);
        
        if(authHeader) {
            req.setHeader('Authorization', 'Bearer ' + identity.access_token);
            req.setHeader('Content-Type', 'application/json');
        }
        
        req.setEndpoint(endpoint);
        
        if(method != null) req.setMethod(method);
        else req.setMethod('GET');
        
        if(body != null) req.setBody(body);
        system.debug('\nRequest Body: ' + body);
        
        http http = new http();
        
        try {
            httpResponse res = http.send(req);
            response = json.deserialize(res.getBody(), responseType);
            system.debug('\nRaw Response Data: ' + response);
        } catch (exception e) {
            system.debug(e);
        }
        
        return response;
    }
    
    
    /*
    ******************************************************************
    *   Additional Classes for Marketo REST objects
    ******************************************************************
    */
    public class ResponseOfIdentity {
        public string access_token { get; set; }
        public string scope { get; set; }
        public integer expires_in { get; set; }
        public string token_type { get; set; }
    }
    
    public class ResponseOfMap {
        public list<Error> errors { get; set; }
        public boolean moreResult { get; set; }
        public string nextPageToken { get; set; }
        public string requestId { get; set; }
        public list<map<string,string>> result { get; set; }
        public boolean success { get; set; }
        public list<Warning> warnings { get; set; }
    }
    
    public class ResponseOfLead {
        public list<Error> errors { get; set; }
        public boolean moreResult { get; set; }
        public string nextPageToken { get; set; }
        public string requestId { get; set; }
        public list<Lead> result { get; set; }
        public boolean success { get; set; }
        public list<Warning> warnings { get; set; }
    }
    
    public class ResponseOfCampaign {
        public list<Error> errors { get; set; }
        public boolean moreResult { get; set; }
        public string nextPageToken { get; set; }
        public string requestId { get; set; }
        public list<Campaign> result { get; set; }
        public boolean success { get; set; }
        public list<Warning> warnings { get; set; }
    }
    
    public class Error {
        public integer code { get; set; }
        public string message { get; set; }
    }
    
    public class Warning {
        public integer code { get; set; }
        public string message { get; set; }
    }
    
    public class SyncLeadRequest {
        public string action { get; set; }
        public boolean asyncProcessing { get; set; }
        public list<map<string,string>> input { get; set; }
        public string lookupField { get; set; }
        public string partitionCode { get; set; }
        public string partitionName { get; set; }
    }
    
    public class PushLeadToMarketoRequest {
        public list<map<string,string>> input { get; set; }
        public string lookupField { get; set; }
        public string partitionName { get; set; }
        public string programName { get; set; }
        public string reason { get; set; }
        public string source { get; set; } 
    }
    
    public class TriggerCampaignRequest {
        public TriggerCampaignData input { get; set; }
    }
    
    public class Lead {
        public integer id { get; set; }
        public ProgramMembership membership { get; set; }
        public Reason reason { get; set; }
        public string status { get; set; }
    }
    
    public class ProgramMembership {
        public boolean acquiredBy { get; set; }
        public boolean isExhausted { get; set; }
        public string membershipDate { get; set; }
        public string nurtureCadence { get; set; }
        public string progressionStatus { get; set; }
        public boolean reachedSuccess { get; set; }
        public string reachedSuccessDate { get; set; }
        public string stream { get; set; }
    }
    
    public class Reason {
        public string code { get; set; }
        public string message { get; set; }
    }
    
    public class Campaign {
        public boolean active { get; set; }
        public string createdAt { get; set; }
        public string description { get; set; }
        public integer id { get; set; }
        public string name { get; set; }
        public integer programId { get; set; }
        public string programName { get; set; }
        public string type { get; set; }
        public string updatedAt { get; set; }
        public string workspaceName { get; set; }
    }
    
    public class TriggerCampaignData {
        public list<InputLead> leads { get; set; }
        public list<Token> tokens { get; set; }
    }
    
    public class InputLead {
        public integer id { get; set; }
    }
    
    public class Token {
        public string name { get; set; }
        public string value { get; set; }
    }
}