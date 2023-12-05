/*
Class:          marketo
@Author:        Ben Griffith
@Created Date:  08/11/2017
@Description:   test class for marketo
*/
/*
Change History
******************************************************************
ModifiedBy          Date        Requested By        Description                 Tag
Sumitkumar Mittal   04/25/2018  Nirvikar Singh      Updated the test class with minor changes.

******************************************************************
*/
/*
------------------------------------------------------------------------------< T01>
//Changes done
------------------------------------------------------------------------------</T01>
*/

@isTest
global class MarketoTest implements HttpCalloutMock {
    
    /**
* this method creates data for unit testing
* @param 
* @return return-void
* @throws exception-NA
*/
    @testSetup static void setup() {
        AppExchange_Config__c settings = new AppExchange_Config__c(
            name = 'appexchange test settings',
            Marketo_REST_Endpoint__c = 'https://munckinId.mktorest.com/rest',
            Marketo_Identity_Endpoint__c = 'https://munckinId.mktorest.com/identity',
            Marketo_REST_Client_Id__c = 'string',
            Marketo_REST_Client_Secret__c = 'string',
            Marketo_AppExchange_Smart_Campaign_Id__c = '0'
        );
        insert settings;
    }
    
    /**
* this testmethod tests marketo.getLeadsByFilterType method
* @param 
* @return return-void
* @throws exception-NA
*/
    @isTest
    static void getLeadsByFilterTypeTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new marketoTest());
        marketo mktoClient = new marketo();
        marketo.ResponseOfMap marketoLeads = mktoClient.getLeadsByFilterType('email', new set<string> { 'testing-user@informatica.com', 'testing-user2@informatica.com' });
        system.assertEquals(true, marketoLeads.success);
        Test.stopTest();
    }
    
    /**
* this testmethod tests marketo.syncLeads method
* @param 
* @return return-void
* @throws exception-NA
*/
    @isTest
    static void syncLeadsTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new marketoTest());
        marketo mktoClient = new marketo();
        marketo.SyncLeadRequest syncLeadRequest = new marketo.SyncLeadRequest();
        syncLeadRequest.action = 'createOnly';
        syncLeadRequest.asyncProcessing = false;
        syncLeadRequest.input = new list<map<string,string>> { new map<string,string> { 'email' => 'testing-user@informatica.com' } };
        syncLeadRequest.lookupField = 'string';
        syncLeadRequest.partitionCode = 'string';
        syncLeadRequest.partitionName = 'string';
        marketo.ResponseOfLead syncResult = mktoClient.syncLeads(syncLeadRequest);
        system.assertEquals(true, syncResult.success);
        Test.stopTest();
    }
    
    /**
* this testmethod tests marketo.pushToMarketo method
* @param 
* @return return-void
* @throws exception-NA
*/
    @isTest
    static void pushToMarketoTest() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new marketoTest());
        marketo mktoClient = new marketo();
        marketo.PushLeadToMarketoRequest pushLeadRequest = new marketo.PushLeadToMarketoRequest();
        pushLeadRequest.input = new list<map<string,string>> { new map<string,string> { 'email' => 'testing-user@informatica.com' } };
        pushLeadRequest.lookupField = 'string';
        pushLeadRequest.partitionName = 'string';
        pushLeadRequest.programName = 'string';
        pushLeadRequest.reason = 'string';
        pushLeadRequest.source = 'string';
        marketo.ResponseOfLead pushResult = mktoClient.pushToMarketo(pushLeadRequest);
        system.assertEquals(true, pushResult.success);
        Test.stopTest();
    }
    
    /**
* this testmethod tests marketo.requestCampaign method
* @param 
* @return return-void
* @throws exception-NA
*/
    @isTest
    static void requestCampaignTest() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new marketoTest());
        marketo mktoClient = new marketo();
        marketo.TriggerCampaignRequest requestCampaignRequest = new marketo.TriggerCampaignRequest();
        requestCampaignRequest.input = new marketo.TriggerCampaignData();
        requestCampaignRequest.input.leads = new list<marketo.InputLead> { new marketo.InputLead() };
        requestCampaignRequest.input.leads.get(0).id = 0;
        requestCampaignRequest.input.tokens = new list<marketo.Token> { new marketo.Token() };
        requestCampaignRequest.input.tokens.get(0).name = 'string';
        requestCampaignRequest.input.tokens.get(0).value = 'string';
        marketo.ResponseOfCampaign requestCampaignResult = mktoClient.requestCampaign('0', requestCampaignRequest);
        system.assertEquals(true, requestCampaignResult.success);
        
        Test.stopTest();
    }
    
    
    /*
******************************************************************
*   marketo Mock HTTP Response Generation
******************************************************************
*/
    global HTTPResponse respond(HTTPRequest req) {
        
        url endpoint = new url(req.getEndpoint());
        string method = req.getMethod();
        system.debug('\nHTTP Request: ' + endpoint.getPath() + '\n');
        string path = endpoint.getPath();
        map<string,string> queryParams = new map<string,string>();
        
        if(endpoint.getQuery() != null) {
            string[] queryPairs = endpoint.getQuery().split('&');
            for(string qp : queryPairs) {
                string[] keyVal = qp.split('=');
                if(keyVal.size() == 2) {
                    queryParams.put(keyVal[0], EncodingUtil.urlDecode(keyVal[1], 'UTF-8'));
                }
            }
        }
        
        if(path == '/identity/oauth/token') return authMock();
        else if(path == '/rest/v1/leads.json' && method == 'GET' && queryParams.containsKey('filterType')) return getLeadsByFilterTypeMock(queryParams.get('filterType'), queryParams.get('filterValues'));
        else if(path == '/rest/v1/leads.json' && method == 'POST') return syncLeadsMock((marketo.SyncLeadRequest)JSON.deserialize(req.getBody(), marketo.SyncLeadRequest.class));
        else if(path == '/rest/v1/leads/push.json' && method == 'POST') return pushToMarketoMock();
        else if(path.startsWith('/rest/v1/campaigns/') && path.endsWith('/trigger.json')) return requestCampaignMock();
        
        return null;
    }
    
    private HTTPResponse authMock() {
        marketo.ResponseOfIdentity mockResponse = new marketo.ResponseOfIdentity();
        mockResponse.access_token = 'string';
        mockResponse.scope = 'string';
        mockResponse.expires_in = 0;
        mockResponse.token_type = 'bearer';
        
        httpResponse res = new httpResponse();
        res.setBody(json.serialize(mockResponse));
        return res;
    }
    
    private HTTPResponse getLeadsByFilterTypeMock(string filterType, string filterValues) {
        marketo.ResponseOfMap mockResponse = new marketo.ResponseOfMap();
        mockResponse.errors = new list<marketo.Error> { new marketo.Error() };
        mockResponse.errors.get(0).code = 0;
        mockResponse.errors.get(0).message = 'string';
        mockResponse.moreResult = false;
        mockResponse.nextPageToken = 'string';
        mockResponse.requestId = 'string';
        mockResponse.result = new list<map<string,string>>();
        string[] vals = filterValues.split(',');
        for(integer i=0; i<vals.size(); i++) {
            if(math.mod(i,2) == 0) {
                mockResponse.result.add(new map<string,string> { 'id' => (filterType == 'id' ? vals[i] : '0'), 'email' => (filterType == 'email' ? vals[i] : 'testing-user@informatica.com'), 'updatedAt' => 'string' } );
            }
        }
        mockResponse.success = true;
        mockResponse.warnings = new list<marketo.Warning> { new marketo.Warning() };
        mockResponse.warnings.get(0).code = 0;
        mockResponse.warnings.get(0).message = 'string';
        
        httpResponse res = new httpResponse();
        res.setBody(json.serialize(mockResponse));        
        return res;
    }
    
    private HTTPResponse syncLeadsMock(marketo.SyncLeadRequest request) {
        marketo.ResponseOfLead mockResponse = new marketo.ResponseOfLead();
        mockResponse.errors = new list<marketo.Error> { new marketo.Error() };
        mockResponse.errors.get(0).code = 0;
        mockResponse.errors.get(0).message = 'string';
        mockResponse.moreResult = false;
        mockResponse.nextPageToken = 'string';
        mockResponse.requestId = 'string';
        mockResponse.result = new list<marketo.Lead> { new marketo.Lead() };
        mockResponse.result.get(0).id = 0;
        mockResponse.result.get(0).membership = new marketo.ProgramMembership();
        mockResponse.result.get(0).membership.acquiredBy = false;
        mockResponse.result.get(0).membership.isExhausted = false;
        mockResponse.result.get(0).membership.membershipDate = 'string';
        mockResponse.result.get(0).membership.nurtureCadence = 'string';
        mockResponse.result.get(0).membership.progressionStatus = 'string';
        mockResponse.result.get(0).membership.reachedSuccess = false;
        mockResponse.result.get(0).membership.reachedSuccessDate = 'string';
        mockResponse.result.get(0).membership.stream = 'string';
        mockResponse.result.get(0).reason = new marketo.Reason();
        mockResponse.result.get(0).reason.code = 'string';
        mockResponse.result.get(0).reason.message = 'string';
       
        if(request.action == 'updateOnly') mockResponse.result.get(0).status = 'updated';
        else  mockResponse.result.get(0).status = 'created';
        
        mockResponse.success = true;
        mockResponse.warnings = new list<marketo.Warning> { new marketo.Warning() };
        mockResponse.warnings.get(0).code = 0;
        mockResponse.warnings.get(0).message = 'string';
        
        httpResponse res = new httpResponse();
        res.setBody(json.serialize(mockResponse));        
        return res;
    }
    
    private HTTPResponse pushToMarketoMock() {
        marketo.ResponseOfLead mockResponse = new marketo.ResponseOfLead();
        mockResponse.errors = new list<marketo.Error> { new marketo.Error() };
        mockResponse.errors.get(0).code = 0;
        mockResponse.errors.get(0).message = 'string';
        mockResponse.moreResult = false;
        mockResponse.nextPageToken = 'string';
        mockResponse.requestId = 'string';
        mockResponse.result = new list<marketo.Lead> { new marketo.Lead() };
        mockResponse.result.get(0).id = 0;
        mockResponse.result.get(0).membership = new marketo.ProgramMembership();
        mockResponse.result.get(0).membership.acquiredBy = false;
        mockResponse.result.get(0).membership.isExhausted = false;
        mockResponse.result.get(0).membership.membershipDate = 'string';
        mockResponse.result.get(0).membership.nurtureCadence = 'string';
        mockResponse.result.get(0).membership.progressionStatus = 'string';
        mockResponse.result.get(0).membership.reachedSuccess = false;
        mockResponse.result.get(0).membership.reachedSuccessDate = 'string';
        mockResponse.result.get(0).membership.stream = 'string';
        mockResponse.result.get(0).reason = new marketo.Reason();
        mockResponse.result.get(0).reason.code = 'string';
        mockResponse.result.get(0).reason.message = 'string';
        mockResponse.result.get(0).status = 'string';
        mockResponse.success = true;
        mockResponse.warnings = new list<marketo.Warning> { new marketo.Warning() };
        mockResponse.warnings.get(0).code = 0;
        mockResponse.warnings.get(0).message = 'string';
        
        httpResponse res = new httpResponse();
        res.setBody(json.serialize(mockResponse));        
        return res;
    }
    
    private HTTPResponse requestCampaignMock() {
        
        marketo.ResponseOfCampaign mockResponse = new marketo.ResponseOfCampaign();
        mockResponse.errors = new list<marketo.Error> { new marketo.Error() };
        mockResponse.errors.get(0).code = 0;
        mockResponse.errors.get(0).message = 'string';
        mockResponse.moreResult = false;
        mockResponse.nextPageToken = 'string';
        mockResponse.requestId = 'string';
        mockResponse.result = new list<marketo.Campaign> { new marketo.Campaign() };
        mockResponse.result.get(0).active = false;
        mockResponse.result.get(0).createdAt = 'string';
        mockResponse.result.get(0).description = 'string';
        mockResponse.result.get(0).id = 0;
        mockResponse.result.get(0).name = 'string';
        mockResponse.result.get(0).programId = 0;
        mockResponse.result.get(0).programName = 'string';
        mockResponse.result.get(0).type = 'batch';
        mockResponse.result.get(0).updatedAt = 'string';
        mockResponse.result.get(0).workspaceName = 'string';
        mockResponse.success = true;
        mockResponse.warnings = new list<marketo.Warning> { new marketo.Warning() };
        mockResponse.warnings.get(0).code = 0;
        mockResponse.warnings.get(0).message = 'string';
        
        httpResponse res = new httpResponse();
        res.setBody(json.serialize(mockResponse));        
        return res;
    }
}