/*

 *********************************************************************************************************************************************
   ModifiedBy                  Date          JIRA No.                         Description                                Tag
 *********************************************************************************************************************************************

 */

public with sharing class CoveoKBSearch {

	public CoveoKBSearch(ApexPages.StandardSetController stdController) {
		// blank constructor
	}

	/*******************************************************************************************************
	 * @description Returns the search token from coveo
	 * @param strSessionToken salesforce current user session id
	 * @param strUserEmail current user email
	 * @param strUserID current user id
	 * @return Returns the search token from coveo as json string
	 */


	@AuraEnabled
	public static string getSearchToken(){
		APISearchTokenResponse apiSearchTokenResponse = new APISearchTokenResponse();
		apiSearchTokenResponse.APISearchToken = '';
		apiSearchTokenResponse.ErrorMessage = '';
		apiSearchTokenResponse.APIResponseStatus = '';
		apiSearchTokenResponse.groupByResults = null;
		apiSearchTokenResponse.RecordCount = '';
		apiSearchTokenResponse.APIResponseData = '';

		AthenaSearch__c searchSettings = AthenaSearch__c.getOrgDefaults();
		String searchTokenGeneratorAPIKey = searchSettings.CoveoSearchTokenGenAPIKey__c;
		String coveoEndpoint = searchSettings.CoveoEndPoint__c;
		String searchTokenGenEndpoint = coveoEndpoint + '/rest/search/token';


		String filter = searchSettings.InternalFilterExpression__c;
		String searchToken = '';
		String searchhub = searchSettings.CoveoSearchHubKBSearchInternal__c;
		String orgname = searchSettings.CoveoOrgName__c;
		String pipeline = searchSettings.CoveoPipelineKBSearchInternal__c;

		String username = 'anonymous';
		string type = 'User';
		string provider = 'Email Security Provider';

		HttpRequest req = new HttpRequest();
		req.setEndpoint(searchTokenGenEndpoint);
		req.setMethod('POST');
		String authorizationHeader = 'Bearer ' + searchTokenGeneratorAPIKey;
		req.setHeader('Authorization', authorizationHeader);
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');

		SearchTokenMessage objSearchTokenMessage = new SearchTokenMessage();
		List<UserIdentity> objListuserIds = new List<UserIdentity>();
		UserIdentity objUserIdentity = new UserIdentity(username,provider,type);

		objListuserIds.add(objUserIdentity);

		// objSearchTokenMessage.filter = filter;
		objSearchTokenMessage.userIds = objListuserIds;
		//objSearchTokenMessage.searchHub = searchHub;
		//objSearchTokenMessage.organization = orgname;
		// objSearchTokenMessage.roles = new string[] { 'queryExecutor' };
		// objSearchTokenMessage.pipeline = pipeline;
		// objSearchTokenMessage.enableQuerySyntax = 'false';


		string body = JSON.serialize(objSearchTokenMessage,true);
		req.setHeader('Content-Length', String.valueOf(body.length()));
		req.setBody(body);

		//System.debug(req.getEndpoint());
		Http http = new Http();
		HTTPResponse res = http.send(req);
		try {
			SearchTokenResponse tokenapiresponse  = (SearchTokenResponse) JSON.deserialize(res.getBody(), SearchTokenResponse.class);
			searchToken = tokenapiresponse.token;
			System.debug(searchToken);

			apiSearchTokenResponse.APIResponseStatus = 'OK';
			apiSearchTokenResponse.APISearchToken = tokenapiresponse.token;
			apiSearchTokenResponse.SearchTokenActualResponse = '';
			apiSearchTokenResponse.SearchOrgName = orgname;

		} catch(Exception e) {

			apiSearchTokenResponse.APIResponseStatus = 'ERROR';
			apiSearchTokenResponse.ErrorMessage = e.getMessage();
			apiSearchTokenResponse.APISearchToken = '';

		}

		system.debug('Search token'+JSON.serialize(apiSearchTokenResponse));
		return JSON.serialize(apiSearchTokenResponse);
	}

	/*******************************************************************************************************
	 * @description Returns the similar articles from coveo based on the keywords
	 * @param strSessionToken salesforce current user session id
	 * @param strUserEmail current user email
	 * @param strUserID current user id
	 * @return Returns the recent content from coveo as json string
	 */
	@auraenabled
	public static string getSimilararticles(string strSessionToken, Id recid, String numOfArticles,String viewFilter){
		String seacrchKeywords='';
		String knwldgeKeywords='';
		String athenaproduct='';
		String searchhub;
		String pipeline;
		String filter;
		APISearchDataResponse apiSearchDataResponse = new APISearchDataResponse();
		apiSearchDataResponse.ErrorMessage = '';
		apiSearchDataResponse.APIResponseStatus = '';
		apiSearchDataResponse.SearchDataAPIURL = '';
		apiSearchDataResponse.searchDataList = null;
		apiSearchDataResponse.RecordCount = '';

		string SearchDataAPIFlowStatus ='';

		try {
			if(recid != null) {
				knowledge__kav kbarticle = [SELECT Id, Solution__c,Title,urlName,Additional_Information__c,Keywords__c,Primary_Product__c,Also_Applies_To__c,Description__c from knowledge__kav where Id = :recid];
				system.debug('Article values:'+kbarticle);
				if(!String.isBlank(kbarticle.Title)) {
					seacrchKeywords+=kbarticle.Title+' ';
				}
				if(!String.isBlank(kbarticle.Solution__c)) {
					String solution = kbarticle.solution__c.stripHtmlTags();
					seacrchKeywords+=solution+' ';
				}

				if(!String.isBlank(kbarticle.Additional_Information__c)) {
					String additionalInfo = kbarticle.Additional_Information__c.stripHtmlTags();
					seacrchKeywords+=additionalInfo;
				}

				/*string eVal = seacrchKeywords;
				   eVal = eVal.replaceAll('~', ' ');
				   eVal = eVal.replaceAll('!', ' ');
				   eVal = eVal.replaceAll('@', ' ');
				   eVal = eVal.replaceAll('#', ' ');
				   eVal = eVal.replaceAll('$', ' ');
				   eVal = eVal.replaceAll('&', ' ');
				   eVal = eVal.replaceAll('\\*', ' ');
				   eVal = eVal.replaceAll('\\(', ' ');
				   eVal = eVal.replaceAll('\\)', ' ');
				   eVal = eVal.replaceAll('=', ' ');
				   eVal = eVal.replaceAll('\\+', ' ');
				   eVal = eVal.replaceAll(';', ' ');
				   eVal = eVal.replaceAll(':', ' ');
				   eVal = eVal.replaceAll('\'', ' ');
				   eVal = eVal.replaceAll(',', ' ');
				   eVal = eVal.replaceAll('"', ' ');
				   eVal = eVal.replaceAll('/', ' ');
				   eVal = eVal.replaceAll('\\?', ' ');
				   eVal = eVal.replaceAll('`', ' ');
				   eVal = eVal.replaceAll('>', ' ');
				   eVal = eVal.replaceAll('<', ' ');
				   eVal = eVal.replaceAll('\r\n', ' ');
				   eVal = eVal.replaceAll('\n', ' ');
				   eVal = eVal.replaceAll('\r', ' ');
				   eVal = eVal.replaceAll('”', ' ');
				   eVal = eVal.replaceALl('“', ' ');*/

				seacrchKeywords = processString(seacrchKeywords);

				if(!String.isBlank(kbarticle.Primary_Product__c)) {
					athenaproduct = kbarticle.Primary_Product__c;
				}

				if(!String.isBlank(kbarticle.Keywords__c)) {
					knwldgeKeywords=kbarticle.Keywords__c;
				}
				knwldgeKeywords= processString(knwldgeKeywords);
				List<SearchResultData> searchResultDatas = new List<SearchResultData>();
				List<Case> lstcaseDetails=new List<Case>();

				AthenaSearch__c searchSettings = AthenaSearch__c.getOrgDefaults();
				String coveoEndpoint = searchSettings.CoveoEndPoint__c;

				String orgname = searchSettings.CoveoOrgName__c;

				if(viewFilter=='External') {
					searchhub = searchSettings.CoveoSearchHubKBSearchPublic__c;
					pipeline = searchSettings.CoveoPipelineKBSearchPublic__c;
					//filter = '@infaviewpermissions=public';
					filter = searchSettings.PublicFilterExpression__c;
				}else if(viewFilter=='Internal') {
					searchhub = searchSettings.CoveoSearchHubKBSearchInternal__c;
					pipeline = searchSettings.CoveoPipelineKBSearchInternal__c;
					//filter = '@infaviewpermissions=(internal,public)';
					filter = searchSettings.InternalFilterExpression__c;
				}

				String searchEndpoint = coveoEndpoint + '/rest/search';

				String searchToken = strSessionToken;

				String dOCID=kbarticle.urlName;

				knwldgeKeywords = knwldgeKeywords.stripHtmlTags();
				seacrchKeywords = seacrchKeywords.stripHtmlTags();

				string COVEO_SEARCH_API_PRODUCTSFILTER = '(@athenaproduct==(PRODUCTS)) ';
				string COVEO_SEARCH_API_KEYWORDSFILTER = '($qre(expression: @INFAKeywords=\'KEYWORDS\', modifier: 150)) ';
				string COVEO_SEARCH_API_SEARCHKEYWORDSFILTER = '($some(keywords: \'SEARCHKEYWORDS\', best: 10, match: 3, removestopwords: true, maximum: 500))';
				string COVEO_SEARCH_API_ADVANCEDFILTER = 'SEARCHKEYWORDSFILTER PRODUCTSKEYWORDSFILTER ';
				string COVEO_SEARCH_API_CONSTANTFILTER = '(FILTER @sourcetype=Salesforce (@infadocumenttype==KB OR IPSKB OR ExpertAssistant) (NOT @infadocid==DOCID) (NOT @infadocumentstatus==(archived))($sort(criteria: relevancy)))';

				string strAdvQry = '';
				string strConstQry = '';
				string strSearchKeywordsFilters = '';
				string strProductKeywordsFilters = '';

				if (athenaproduct.Trim() != '')
				{
					strProductKeywordsFilters += COVEO_SEARCH_API_PRODUCTSFILTER.replace('PRODUCTS', '\'' + athenaproduct + '\'');
				}

				if (athenaproduct.Trim() != '')
				{
					strProductKeywordsFilters += COVEO_SEARCH_API_PRODUCTSFILTER.replace('PRODUCTS', '\'' + athenaproduct + '\'');
				}

				if (knwldgeKeywords.Trim() != '')
				{
					strProductKeywordsFilters += COVEO_SEARCH_API_KEYWORDSFILTER.replace('KEYWORDS', knwldgeKeywords);
				}

				if (seacrchKeywords.Trim() != '')
				{
					strSearchKeywordsFilters = COVEO_SEARCH_API_SEARCHKEYWORDSFILTER.replace('SEARCHKEYWORDS', seacrchKeywords);
				}

				strAdvQry = COVEO_SEARCH_API_ADVANCEDFILTER.replace('PRODUCTSKEYWORDSFILTER', strProductKeywordsFilters).replace('SEARCHKEYWORDSFILTER', strSearchKeywordsFilters);

				strConstQry = COVEO_SEARCH_API_CONSTANTFILTER.replace('DOCID', dOCID).replace('FILTER',filter);

				HttpRequest req = new HttpRequest();
				req.setEndpoint(searchEndpoint);
				req.setMethod('POST');
				String authorizationHeader = 'Bearer ' + searchToken;
				req.setHeader('Authorization', authorizationHeader);
				req.setHeader('Content-Type', 'application/json');
				req.setHeader('Accept', 'application/json');

				SearchResultMessage objSearchResultMessage = new SearchResultMessage();

				objSearchResultMessage.aq = strAdvQry;
				objSearchResultMessage.cq = strConstQry;
				objSearchResultMessage.numberOfResults=numOfArticles;
				objSearchResultMessage.organization = orgname;
				objSearchResultMessage.searchHub = searchHub;
				objSearchResultMessage.pipeline = pipeline;

				apiSearchDataResponse.SearchDataAPIURL = strAdvQry + '$$$$$$$$' + strConstQry;

				string body = JSON.serialize(objSearchResultMessage,true);
				req.setHeader('Content-Length', String.valueOf(body.length()));
				req.setBody(body);
				Http http = new Http();
				HTTPResponse res = http.send(req);

				//SearchDataAPIFlowStatus += res.getBody();

				Map<String, Object> resultObj = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());

				List<Object> lstResults = (List<Object>)resultObj.get('results');

				for(Object result : lstResults ) {
					SearchResultData searchResultData = new SearchResultData();
					Map<String,Object> mapResult = (Map<String,Object>)result;

					if( mapResult.get('raw') != null)
					{
						Object objRaw = mapResult.get('raw');
						Map<String,Object> mapRaw = (Map<String,Object>)objRaw;
						searchResultData.infadocid = mapRaw.get('infadocid') != null ?  mapRaw.get('infadocid').toString()  : '';
						searchResultData.title = mapResult.get('title') != null ?  mapResult.get('title').toString()  : '';
						searchResultData.clickUri = mapResult.get('clickUri') != null ?  mapResult.get('clickUri').toString()  : '';
						searchResultData.sysfiletype = mapRaw.get('sysfiletype') != null ?  mapRaw.get('sysfiletype').toString()  : '';
						searchResultDatas.add(searchResultData);
					}
				}

				apiSearchDataResponse.APIResponseStatus = 'SUCCESS';
				apiSearchDataResponse.searchDataList = searchResultDatas;
				apiSearchDataResponse.SearchDataAPIFlowStatus = SearchDataAPIFlowStatus;

			}else {
				return getSearchResultRecenttData(strSessionToken, numOfArticles);
			}
		} catch(Exception e) {

			apiSearchDataResponse.APIResponseStatus = 'ERROR';
			apiSearchDataResponse.ErrorMessage = e.getMessage();
			apiSearchDataResponse.SearchDataAPIFlowStatus = SearchDataAPIFlowStatus;


		}
		return JSON.serialize(apiSearchDataResponse);
	}

	@auraenabled
	public static string getArticleDetails(string strSessionToken, Id recid, String numOfArticles,String viewFilter){
		String seacrchKeywords='';
		String knwldgeKeywords='';
		String athenaproduct='';
		String searchhub;
		String pipeline;
		String filter;
		APISearchDataResponse apiSearchDataResponse = new APISearchDataResponse();
		apiSearchDataResponse.ErrorMessage = '';
		apiSearchDataResponse.APIResponseStatus = '';
		apiSearchDataResponse.SearchDataAPIURL = '';
		apiSearchDataResponse.searchDataList = null;
		apiSearchDataResponse.RecordCount = '';

		string SearchDataAPIFlowStatus ='';

		try {
			if(recid != null) {

				List<SearchResultData> searchResultDatas = new List<SearchResultData>();

				AthenaSearch__c searchSettings = AthenaSearch__c.getOrgDefaults();
				String coveoEndpoint = searchSettings.CoveoEndPoint__c;

				String orgname = searchSettings.CoveoOrgName__c;

				if(viewFilter=='External') {
					searchhub = searchSettings.CoveoSearchHubKBSearchPublic__c;
					pipeline = searchSettings.CoveoPipelineKBSearchPublic__c;
					//filter = '@infaviewpermissions=public';
					filter = searchSettings.PublicFilterExpression__c;
				}else if(viewFilter=='Internal') {
					searchhub = searchSettings.CoveoSearchHubKBSearchInternal__c;
					pipeline = searchSettings.CoveoPipelineKBSearchInternal__c;
					//filter = '@infaviewpermissions=(internal,public)';
					filter = searchSettings.InternalFilterExpression__c;
				}

				String searchEndpoint = coveoEndpoint + '/rest/search';

				String searchToken = strSessionToken;

				string strRecordFilter = '(@sfid==' + recid + ')';
        
                HttpRequest req = new HttpRequest();
                req.setEndpoint(searchEndpoint);
                req.setMethod('POST');
                String authorizationHeader = 'Bearer ' + searchToken;
                req.setHeader('Authorization', authorizationHeader);
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Accept', 'application/json');
    
                SearchResultMessage objSearchResultMessage = new SearchResultMessage();
    
                objSearchResultMessage.cq = strRecordFilter;
                objSearchResultMessage.numberOfResults=numOfArticles;
                objSearchResultMessage.organization = orgname;
                objSearchResultMessage.searchHub = searchHub;
                objSearchResultMessage.pipeline = pipeline;
    
                string body = JSON.serialize(objSearchResultMessage,true);
                req.setHeader('Content-Length', String.valueOf(body.length()));
                req.setBody(body);
                Http http = new Http();
                HTTPResponse res = http.send(req);
    
                //SearchDataAPIFlowStatus += res.getBody();
    
                Map<String, Object> resultObj = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
    
                List<Object> lstResults = (List<Object>)resultObj.get('results');
    
                for(Object result : lstResults ) {
                    SearchResultData searchResultData = new SearchResultData();
                    Map<String,Object> mapResult = (Map<String,Object>)result;
    
                    if( mapResult.get('raw') != null)
                    {
                        Object objRaw = mapResult.get('raw');
                        Map<String,Object> mapRaw = (Map<String,Object>)objRaw;
                        searchResultData.infadocid = mapRaw.get('infadocid') != null ?  mapRaw.get('infadocid').toString()  : '';
                        searchResultData.title = mapResult.get('title') != null ?  mapResult.get('title').toString()  : '';
                        searchResultData.clickUri = mapResult.get('clickUri') != null ?  mapResult.get('clickUri').toString()  : '';
                        searchResultData.sysfiletype = mapRaw.get('sysfiletype') != null ?  mapRaw.get('sysfiletype').toString()  : '';
                        searchResultData.infakblikes = mapRaw.get('infakblikes') != null ?  mapRaw.get('infakblikes').toString()  : '';
                        searchResultData.infakbcasedeflected = mapRaw.get('infakbcasedeflected') != null ?  mapRaw.get('infakbcasedeflected').toString()  : '';
                        searchResultData.infakblifetimeviews = mapRaw.get('infakblifetimeviews') != null ?  mapRaw.get('infakblifetimeviews').toString()  : '';
                        searchResultDatas.add(searchResultData);
                    }
                }
    
                apiSearchDataResponse.APIResponseStatus = 'SUCCESS';
                apiSearchDataResponse.searchDataList = searchResultDatas;
                apiSearchDataResponse.SearchDataAPIFlowStatus = SearchDataAPIFlowStatus;
    
            }
        } catch(Exception e) {
    
            apiSearchDataResponse.APIResponseStatus = 'ERROR';
            apiSearchDataResponse.ErrorMessage = e.getMessage();
            apiSearchDataResponse.SearchDataAPIFlowStatus = SearchDataAPIFlowStatus;
    
    
        }
        return JSON.serialize(apiSearchDataResponse);
    }
    
    /*******************************************************************************************************
     * @description Returns the String after replacing the characters in the provided input
     * @param input a String before replacing special characters
     * @return Returns a String after replacing special characters
     */
    private static string processString(String input){
    
        string eVal = input;
        eVal = eVal.replaceAll('~', ' ');
        eVal = eVal.replaceAll('!', ' ');
        eVal = eVal.replaceAll('@', ' ');
        eVal = eVal.replaceAll('#', ' ');
        eVal = eVal.replaceAll('$', ' ');
        eVal = eVal.replaceAll('&', ' ');
        eVal = eVal.replaceAll('\\*', ' ');
        eVal = eVal.replaceAll('\\(', ' ');
        eVal = eVal.replaceAll('\\)', ' ');
        eVal = eVal.replaceAll('=', ' ');
        eVal = eVal.replaceAll('\\+', ' ');
        eVal = eVal.replaceAll(';', ' ');
        eVal = eVal.replaceAll(':', ' ');
        eVal = eVal.replaceAll('\'', ' ');
        eVal = eVal.replaceAll(',', ' ');
        eVal = eVal.replaceAll('"', ' ');
        eVal = eVal.replaceAll('/', ' ');
        eVal = eVal.replaceAll('\\?', ' ');
        eVal = eVal.replaceAll('`', ' ');
        eVal = eVal.replaceAll('>', ' ');
        eVal = eVal.replaceAll('<', ' ');
        eVal = eVal.replaceAll('\r\n', ' ');
        eVal = eVal.replaceAll('\n', ' ');
        eVal = eVal.replaceAll('\r', ' ');
        eVal = eVal.replaceAll('”', ' ');
        eVal = eVal.replaceALl('“', ' ');
    
    
        return eVal;
    }
    
    /*******************************************************************************************************
     * @description Returns the recent content from coveo
     * @param strSessionToken salesforce current user session id
     * @param strUserEmail current user email
     * @param strUserID current user id
     * @return Returns the recent content from coveo as json string
     */
    @AuraEnabled
    public static string getSearchResultRecenttData(string strSessionToken,String numOfArticles){
        APISearchTokenResponse apiSearchTokenResponse = new APISearchTokenResponse();
        apiSearchTokenResponse.APISearchToken = '';
        apiSearchTokenResponse.ErrorMessage = '';
        apiSearchTokenResponse.APIResponseStatus = '';
        apiSearchTokenResponse.groupByResults = null;
        apiSearchTokenResponse.RecordCount = '';
        apiSearchTokenResponse.APIResponseData = '';
        List<SearchResultData> searchResultDatas = new List<SearchResultData>();
        List<Case> lstcaseDetails=new List<Case>();
        String SearchTokenAPIFlowStatus = '';
    
        AthenaSearch__c searchSettings = AthenaSearch__c.getOrgDefaults();
        String searchAPIKey = searchSettings.CoveoSearchAPIKey__c;
        String coveoEndpoint = searchSettings.CoveoEndPoint__c;
        String searchEndpoint = coveoEndpoint + '/rest/search';
    
    
        String filter = searchSettings.CoveoRecentSearchFilter__c;
        String searchToken = '';
        String searchhub = searchSettings.CoveoSearchHubKBSearchInternal__c;
        String orgname = searchSettings.CoveoOrgName__c;
        String pipeline = searchSettings.CoveoPipelineKBSearchInternal__c;
    
        String username = 'anonymous';
        string type = 'User';
        string provider = 'Email Security Provider';
    
        HttpRequest req = new HttpRequest();
        req.setEndpoint(searchEndpoint);
        req.setMethod('POST');
        String authorizationHeader = 'Bearer ' + searchAPIKey;
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
    
        SearchResultMessage objSearchResultMessage = new SearchResultMessage();
        List<UserIdentity> objListuserIds = new List<UserIdentity>();
    
        objSearchResultMessage.aq = filter;
        objSearchResultMessage.numberOfResults=numOfArticles;
        objSearchResultMessage.searchHub = searchHub;
        objSearchResultMessage.organization = orgname;
    
        SearchTokenAPIFlowStatus += '418';
    
        string body = JSON.serialize(objSearchResultMessage,true);
        req.setHeader('Content-Length', String.valueOf(body.length()));
        req.setBody(body);
        system.debug(body);
    
        //System.debug(req.getEndpoint());
        Http http = new Http();
        HTTPResponse res = http.send(req);
        try {
    
            Map<String, Object> resultObj = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> lstResults = (List<Object>)resultObj.get('results');
    
    
            for(Object result : lstResults ) {
                SearchResultData searchResultData = new SearchResultData();
                Map<String,Object> mapResult = (Map<String,Object>)result;
    
                if( mapResult.get('raw') != null)
                {
                    Object objRaw = mapResult.get('raw');
                    Map<String,Object> mapRaw = (Map<String,Object>)objRaw;
                    searchResultData.infadocid = mapRaw.get('infadocid') != null ?  mapRaw.get('infadocid').toString()  : '';
                    searchResultData.title = mapResult.get('title') != null ?  mapResult.get('title').toString()  : '';
                    searchResultData.clickUri = mapResult.get('clickUri') != null ?  mapResult.get('clickUri').toString()  : '';
                    searchResultData.sysfiletype = mapRaw.get('sysfiletype') != null ?  mapRaw.get('sysfiletype').toString()  : '';
                    searchResultDatas.add(searchResultData);
                }
            }
    
            apiSearchTokenResponse.APIResponseStatus = 'OK';
            apiSearchTokenResponse.searchDataList = searchResultDatas;
            apiSearchTokenResponse.SearchTokenActualResponse = SearchTokenAPIFlowStatus;
            apiSearchTokenResponse.SearchOrgName = orgname;
    
    
        } catch(Exception e) {
    
            apiSearchTokenResponse.APIResponseStatus = 'ERROR';
            apiSearchTokenResponse.ErrorMessage = e.getMessage();
            apiSearchTokenResponse.APISearchToken = '';
            apiSearchTokenResponse.SearchTokenActualResponse = SearchTokenAPIFlowStatus;
    
        }
    
    
        return JSON.serialize(apiSearchTokenResponse);
    }
    
    
    
    /**
     * @description Class used to return the search token its respective error information if its there,
     */
    
    public class APISearchTokenResponse {
    public List<SearchResultData> searchDataList;
    public string APISearchToken { get; set; }
    public string ErrorMessage { get; set; }
    public string APIResponseStatus { get; set; }
    public string SearchTokenAPIFlowStatus { get; set; }
    public string SearchTokenActualResponse { get; set; }
    public string SearchOrgName { get; set; }
    public string APIResponseData { get; set; }
    public string RecordCount { get; set; }
    public List<SearchFacettData> groupByResults;
    }
    
    
    public class APISearchDataResponse
    {
    public List<SearchResultData> searchDataList;
    public string ErrorMessage { get; set; }
    public string APIResponseStatus { get; set; }
    public string SearchDataAPIFlowStatus { get; set; }
    public string SearchDataAPIURL { get; set; }
    public string RecordCount { get; set; }
    }
    
    
    /**
     * @description Class used to send the user details for token generation
     */
    public class UserIdentity {
    
    public string name { get; set; }
    public string provider { get; set; }
    public string type { get; set; }
    
    public UserIdentity(string name, string provider, string type)
    {
        this.name = name;
        this.provider = provider;
        this.type = type;
    }
    }
    
    
    /**
     * @description Class used to send the Coveo env details for token generation
     */
    
    public class SearchTokenMessage
    {
    public string filter { get; set; }
    public List<UserIdentity> userIds { get; set; }
    public string searchHub { get; set; }
    public string organization { get; set; }
    //public int validFor { get; set; }
    //public string[] userGroups { get; set; }
    public string[] roles { get; set; }
    public string pipeline { get; set; }
    public string enableQuerySyntax { get; set; }
    
    }
    
    public class SearchResultMessage {
    public string organization { get; set; }
    public string aq { get; set; }
    public string cq { get; set; }
    public string q { get; set; }
    public string numberOfResults {get; set;}
    public string searchHub { get; set; }
    public string pipeline {get; set;}
    }
    
    public class SearchResultData {
    public string infadocid { get; set; }
    public string title { get; set; }
    public string clickUri { get; set; }
    public string sysfiletype { get; set; }
    public string infakblikes { get; set; }
    public string infakbcasedeflected { get; set; }
    public string infakblifetimeviews { get; set; }
    }
    
    public class SearchTokenResponse {
    public string token { get; set; }
    }
    
    public class SearchFacettData {
    public string field { get; set; }
    public string[] values { get; set; }
    }
    
    
    }