global with sharing class CSMCoveoSearch {
	public CSMCoveoSearch() {

	}


	/*******************************************************************************************************
	 * @description Returns the search token from coveo
	 * @param strSessionToken salesforce current user session id
	 * @param strUserEmail current user email
	 * @param strUserID current user id
	 * @return Returns the search token from coveo as json string
	 */
	@AuraEnabled
	public static string getSearchToken(string strCalledFrom){
		APISearchTokenResponse apiSearchTokenResponse = new APISearchTokenResponse();
		apiSearchTokenResponse.APISearchToken = '';
		apiSearchTokenResponse.ErrorMessage = '';
		apiSearchTokenResponse.APIResponseStatus = '';
		apiSearchTokenResponse.groupByResults = null;
		apiSearchTokenResponse.RecordCount = '';
		apiSearchTokenResponse.APIResponseData = '';
		apiSearchTokenResponse.APISearchHub = '';
		apiSearchTokenResponse.UserType = UserInfo.getUserType();
		apiSearchTokenResponse.FirstName = UserInfo.getFirstName();
		apiSearchTokenResponse.UserId = UserInfo.getUserId();
		apiSearchTokenResponse.SessionId = UserInfo.getSessionId();
		apiSearchTokenResponse.EndPointURI = '';
		apiSearchTokenResponse.SearchOrgName = '';
		apiSearchTokenResponse.recentDataResponse = '';
		apiSearchTokenResponse.SearchTokenAPIFlowStatus = '';
		apiSearchTokenResponse.CalledFrom = strCalledFrom;




		AthenaSearch__c searchSettings = AthenaSearch__c.getOrgDefaults();
		String searchTokenGeneratorAPIKey = searchSettings.CoveoSearchTokenGenAPIKey__c;
		String coveoEndpoint = searchSettings.CoveoEndPoint__c;
		apiSearchTokenResponse.EndPointURI = searchSettings.CoveoEndPoint__c;
		String searchTokenGenEndpoint = coveoEndpoint + '/rest/search/v2/token';


		string SearchTokenAPIFlowStatus = '';
		String filter = '';
		String searchToken = '';
		String searchhub = '';
		String orgname = searchSettings.CoveoOrgName__c;
		apiSearchTokenResponse.SearchOrgName = searchSettings.CoveoOrgName__c;
		String pipeline = '';
		String userType = UserInfo.getUserType();
		String username = UserInfo.getUserName();
		String useremail = UserInfo.getUserEmail();
		String strOrgId = UserInfo.getOrganizationId();
		String strUserId = UserInfo.getUserId();
		string type = 'User';
		string provider = 'Email Security Provider';
		String CSMCONTENTSEARCH = 'csmcontentsearch';

		String INFORMATICASANDBOX = 'informaticasandbox';
		String UAT = 'UAT';
		String SIT = 'SIT';
		String DEV = 'DEV';
		string viewallcontent = '0';

		if(userType == 'Guest')
		{
			useremail = 'anonymous';
		}

		SearchTokenRequest objSearchTokenRequest = new SearchTokenRequest();
		List<UserIdentity> objListuserIds = new List<UserIdentity>();
		UserIdentity objUserIdentity = new UserIdentity(useremail,provider,type);
		objListuserIds.add(objUserIdentity);


		if(strCalledFrom == CSMCONTENTSEARCH)
		{
			searchhub = 'successplansearch';
			apiSearchTokenResponse.APISearchHub = searchhub;
			filter += ' (@infadocumenttype=(successplans))';
			filter += ' (@sfis_internal__c=false)'; 
			filter += ' (@cosmosplancontact="'+ useremail +'")'; // Filter Plans for Plan Contacts only
			pipeline = 'Cosmos';
		}
		//This is handle more than one environment in coveo cloud sandbox environment
		if(orgname == INFORMATICASANDBOX)
		{
			String strEnvName = searchSettings.SFDCEnvironmentName__c;
			if(strEnvName == UAT)
				filter += ' (NOT(@infaenvironmentid=(2,3)))';
			else if(strEnvName == SIT)
				filter += ' (NOT(@infaenvironmentid=(1,3)))';
			else if(strEnvName == DEV)
				filter += ' (NOT(@infaenvironmentid=(1,2)))';
			else
				filter += ' (NOT(@infaenvironmentid=(1,2)))';
		}

		SearchTokenAPIFlowStatus += ' ' + filter;

		HttpRequest req = new HttpRequest();
		req.setEndpoint(searchTokenGenEndpoint);
		
		req.setMethod('POST');
		String authorizationHeader = 'Bearer ' + searchTokenGeneratorAPIKey;
		req.setHeader('Authorization', authorizationHeader);
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');


		objSearchTokenRequest.filter = filter;
		objSearchTokenRequest.userIds = objListuserIds;
		objSearchTokenRequest.searchHub = searchHub;
		objSearchTokenRequest.salesforceOrganizationId = strOrgId;
		objSearchTokenRequest.salesforceUser = username;
		objSearchTokenRequest.usertype = userType;
		objSearchTokenRequest.organization = orgname;
		objSearchTokenRequest.roles = new string[] { 'queryExecutor' };
		objSearchTokenRequest.pipeline = pipeline;
		objSearchTokenRequest.enableQuerySyntax = 'false';
		objSearchTokenRequest.viewAllContent = viewallcontent;

		string body = JSON.serialize(objSearchTokenRequest,true);
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
			apiSearchTokenResponse.SearchTokenActualResponse = res.getBody();

		} catch(Exception e) {

			apiSearchTokenResponse.APIResponseStatus = 'ERROR';
			apiSearchTokenResponse.ErrorMessage = e.getMessage();
			apiSearchTokenResponse.APISearchToken = '';

		}
		apiSearchTokenResponse.SearchTokenAPIFlowStatus = SearchTokenAPIFlowStatus;


		return JSON.serialize(apiSearchTokenResponse);
	}

	/*******************************************************************************************************
	 * @description Returns the session id
	 */
	@AuraEnabled
	public static string getCurrentSessionId() {
		string strReturn = '';
		if(UserInfo.getSessionId() != null)
		{
			//strReturn =  (UserInfo.getUserId() + UserInfo.getOrganizationId());
			strReturn = UserInfo.getSessionId();
		}
		else {
			strReturn = (UserInfo.getUserType() + UserInfo.getUserId() + UserInfo.getOrganizationId());
		}
		return strReturn;
	}

	/**
	 *————————————————————————————————————————————————————
	 * @Description: To get logged in suer details.
	 * returns the UsersDetails
	 *————————————————————————————————————————————————————
	 * @param    None
	 * @return   String
	 *————————————————————————————————————————————————————
	 **/
	@AuraEnabled
	public static UserDetailsWrapper  getCurrentUsersDetails() {
		UserDetailsWrapper varUserDetailsWrapper = new UserDetailsWrapper();
		varUserDetailsWrapper.UserType = 'Guest';
		varUserDetailsWrapper.FirstName = '';
		varUserDetailsWrapper.UserName = '';
		varUserDetailsWrapper.UserId = '';
		varUserDetailsWrapper.Email='';
		varUserDetailsWrapper.SessionId='';
		try{
			varUserDetailsWrapper.UserType = UserInfo.getUserType();
			varUserDetailsWrapper.FirstName = UserInfo.getFirstName();
			varUserDetailsWrapper.UserName = UserInfo.getUserName();
			varUserDetailsWrapper.UserId = UserInfo.getUserId();
			varUserDetailsWrapper.Email = UserInfo.getUserEmail();
			varUserDetailsWrapper.SessionId = UserInfo.getSessionId();

		} catch (Exception e) {
			system.debug('Exception in getCurrentUsersDetails : '+e.getmessage()+e.getlinenumber());
		}
		return varUserDetailsWrapper;
	}


	




	/**
	 * @description Class used to return the search token its respective error information if its there,
	 */
	public class APISearchTokenResponse
	{
	public List<SearchResultData> searchDataList;
	public string APISearchToken { get; set; }
	public string APISearchHub { get; set; }
	public string ErrorMessage { get; set; }
	public string APIResponseStatus { get; set; }
	public string SearchTokenAPIFlowStatus { get; set; }
	public string SearchTokenActualResponse { get; set; }
	public string SearchOrgName { get; set; }
	public string APIResponseData { get; set; }
	public string RecordCount { get; set; }
	public string UserId { get; set; }
	public string UserType { get; set; }
	public string FirstName { get; set; }
	public string SessionId { get; set; }
	public string EndPointURI { get; set; }
	public List<SearchFacettData> groupByResults;
	public string recentDataResponse;
	public string CalledFrom;

	}



	public class APISearchDataResponse
	{
	public List<SearchResultData> searchDataList;
	public List<SearchKBResultData> searchKBDataList;
	public List<SearchCaseResultData> searchCaseDataList;
	public string ErrorMessage { get; set; }
	public string APIResponseStatus { get; set; }
	public string SearchDataAPIFlowStatus { get; set; }
	public string SearchDataAPIURL { get; set; }
	public string RecordCount { get; set; }
	}

	/**
	 * @description Class used to send the user details for token generation
	 */
	public class UserIdentity
	{
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
	public class SearchTokenRequest
	{
	public string filter { get; set; }
	public List<UserIdentity> userIds { get; set; }
	public string usertype { get; set; }
	public string salesforceUser { get; set; }
	public string searchHub { get; set; }
	public string salesforceOrganizationId { get; set; }
	public string organization { get; set; }
	//public long validFor { get; set; }
	//public string[] userGroups { get; set; }
	public string[] roles { get; set; }
	public string pipeline { get; set; }
	public string enableQuerySyntax { get; set; }
	public string viewAllContent { get; set; }

	}


	public class SearchResultRequest {
	public string aq { get; set; }
	public string q { get; set; }
	public string numberOfResults {get; set;}
	}

	public class SearchResultData
	{
	public string syssfid { get; set; }
	public string title { get; set; }
	public string clickUri { get; set; }
	public string sfcasestatus  { get; set; }
	public string sflastmodifieddate   { get; set; }
	public string syssfdescription  { get; set; }
	public string sfpriority   { get; set; }
	public string sfcasenumber   { get; set; }
	public string sfsupportaccountrname   { get; set; }
	public string infadocid   { get; set; }
	}

	public class SearchCaseResultData
	{
	public string sfid   { get; set; }
	public string syssfid { get; set; }
	public string title { get; set; }
	public string clickUri { get; set; }
	public string sfcasestatus  { get; set; }
	public string sflastmodifieddate   { get; set; }
	public string syssfdescription  { get; set; }
	public string sfpriority   { get; set; }
	public string sfcasenumber   { get; set; }
	public string sfsupportaccountrname   { get; set; }
	public string infadocid   { get; set; }
	}

	public class SearchKBResultData
	{
	public string infadocid   { get; set; }
	public string sfarticlenumber   { get; set; }
	public string title   { get; set; }
	public string sfid   { get; set; }
	}

	public class SearchTokenResponse
	{
	public string token { get; set; }
	}

	public class SearchFacettData
	{
	public string field { get; set; }
	public string[] values { get; set; }
	}


	public class UserDetailsWrapper {
	@AuraEnabled
	public String UserName;
	@AuraEnabled
	public String FirstName;
	@AuraEnabled
	public String UserType;
	@AuraEnabled
	public String UserId;
	@AuraEnabled
	public String Email;
	@AuraEnabled
	public String SessionId;
	}
}