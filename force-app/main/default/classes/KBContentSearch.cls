/*
   @created by       : SathishR
   @created on       : 08/02/2020
   @Purpose          : KB Search related activities done using this class.
   @Testclass        :
   @JIRA             :


   Change History
 ****************************************************************************************************
 |    Tag     |  Date             |  Modified by              |  Jira reference   |   ChangesMade
 |     1      |  15-Apr-2021      |   Sathish R               |                   |   Initial Version
 |     2      |  25-Oct-2022      |   Sathish R               |    I2RT-7308      |   Add Article Validation status and Article language columns in the KB list under KB action on case console
 |     3      |  23-Nov-2022      |   Sathish R               |    I2RT-7302      |   Display only assigned cases to engineers when attaching articles to Cases on article view page and Authoring home related tab.
 |     4      |  05-May-2023      |   Ankit S                 |    AR-3147        |   Engagement Catalog for CSM with Actions and IPX search
 |     5      |  10-Jul-2022      |   Sathish R               |    I2RT-8605      |   Tech_Debt : Assign Search hub to Global Search Box in IN and KB..
 |     6      |  24-Sep-2023      |   Sathish R               |    I2RT-9075      |   eSupport Change Request section- Remove the table of content and redirect to IN Change Request page
 |     7      |  24-Oct-2023      |   Sathish R               |    I2RT-9212      |   New column - 'Article Record Type' in attached KBs and search results KB table in case layout.
 |     8      |  10-Nov-2023      |   Sathish R               |    I2RT-9499      |   Customer facing "Something went wrong" issue every few hours in search
 ****************************************************************************************************
 */

global with sharing class KBContentSearch {
	public KBContentSearch() {

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
		apiSearchTokenResponse.RefreshCount = '0';//T08




		AthenaSearch__c searchSettings = AthenaSearch__c.getOrgDefaults();
		String searchTokenGeneratorAPIKey = searchSettings.CoveoSearchTokenGenAPIKey__c;
		String coveoEndpoint = searchSettings.CoveoEndPoint__c;
		apiSearchTokenResponse.EndPointURI = searchSettings.CoveoEndPoint__c;
		String searchTokenGenEndpoint = coveoEndpoint + '/rest/search/token';
		String kbsearchProfilesGCSfilesCase = searchSettings.KBSearchProfilesGCSfilesCase__c;
		kbsearchProfilesGCSfilesCase = kbsearchProfilesGCSfilesCase != null ? (kbsearchProfilesGCSfilesCase).trim().toLowerCase() : '';
		String kbsearchUserLicenceGCSfilesCase = searchSettings.KBSearchUserLicenceGCSfilesCase__c;
		kbsearchUserLicenceGCSfilesCase = kbsearchUserLicenceGCSfilesCase != null ? (kbsearchUserLicenceGCSfilesCase).trim().toLowerCase() : '';
		String kbsearchRemoveGCSfilesCase =  searchSettings.KBSearchFilterRemoveGCSfilesCase__c;
		String kbsearchRemoveSFDCCase =  searchSettings.KBSearchFilterRemoveSFDCCase__c;


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
		String CONTENTSEARCH = 'contentsearch';
		String ESUPPORTSEARCH = 'esupportsearch';
		String ESUPPORTCRSEARCH = 'esupportcrsearch';
		String CASECONSOLEIPXSEARCH = 'caseconsoleipxsearch';
		String KBSEARCH = 'kbsearch';
		String KBSEARCHOLD = 'kbsearchold';
		String INFANETWORKSEARCH = 'infanetworksearch';
		String INFANETWORKSEARCHBAR = 'infanetworksearchbar'; //4
		String ESUPPORTCASEDEFLECTIONTECHNICAL = 'esupportcasedeflectiontechnical';
		String ESUPPORTCASEDEFLECTIONGENERALINQUIRY = 'esupportcasedeflectiongeneralinquiry';
		String ESUPPORTCASEDEFLECTIONSHIPPING = 'esupportcasedeflectionshipping';
		String CASETOKBASSOCIATION = 'casetokbassociation';
		String KBTOCASEASSOCIATION = 'kbtocaseassociation';
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


		if(strCalledFrom == CONTENTSEARCH)
		{
			if(userType == 'Guest')
			{
				filter = searchSettings.PublicFilterExpression__c;
				searchhub = searchSettings.CoveoSearchHubKBSearchPublic__c;
				apiSearchTokenResponse.APISearchHub = searchhub;
				pipeline = searchSettings.CoveoPipelineKBSearchPublic__c;

			}
			else if(userType == 'Standard')
			{
				filter = searchSettings.InternalFilterExpression__c;
				searchhub = searchSettings.CoveoSearchHubKBSearchInternal__c;
				apiSearchTokenResponse.APISearchHub = searchhub;
				pipeline = searchSettings.CoveoPipelineKBSearchInternal__c;
				viewallcontent = '1';
				try {
					Boolean isDataFromGCSfiles = false;
					List<User> users  = [SELECT Id, Name, Profile.UserLicense.Name, Profile.Name FROM User WHERE Id=:strUserId LIMIT 1];
					if(!users.isEmpty())
					{
						String myuserlicense = users[0].Profile.UserLicense.Name;
						myuserlicense = myuserlicense.trim().toLowerCase();
						myuserlicense = '|' + myuserlicense + '|';

						String myprofilename = users[0].Profile.Name;
						myprofilename = myprofilename.trim().toLowerCase();
						myprofilename = '|' + myprofilename + '|';

						if(kbsearchUserLicenceGCSfilesCase.indexOf(myuserlicense) > -1)
						{
							isDataFromGCSfiles = true;
						}
						else if(kbsearchProfilesGCSfilesCase.indexOf(myprofilename) > -1)
						{
							isDataFromGCSfiles = true;
						}
					}

					if(isDataFromGCSfiles)
					{
						if(!String.isEmpty(kbsearchRemoveSFDCCase) && (kbsearchRemoveSFDCCase.trim().toLowerCase() != 'none'))
						{
							filter += ' ' + kbsearchRemoveSFDCCase;
						}
					}
					else
					{
						if(!String.isEmpty(kbsearchRemoveGCSfilesCase) && (kbsearchRemoveGCSfilesCase.trim().toLowerCase() != 'none'))
						{
							filter += ' ' + kbsearchRemoveGCSfilesCase;
						}
					}
				}
				catch(Exception e) {
					SearchTokenAPIFlowStatus += ' Error : ' + e.getMessage() + ' LineNumber : ' + e.getLineNumber();
				}
			}
			else if(userType == 'PowerPartner' || userType == 'PowerCustomerSuccess')
			{
				filter = searchSettings.AuthenticatedFilterExpression__c;
				searchhub = searchSettings.CoveoSearchHubKBSearchAuthenticated__c;
				apiSearchTokenResponse.APISearchHub = searchhub;
				pipeline = searchSettings.CoveoPipelineKBSearchPublic__c;
				//UserIdentity objUserIdentityAnonymous = new UserIdentity('anonymous','Email Security Provider','User');
				//objListuserIds.add(objUserIdentityAnonymous);

			}
			else
			{
				filter = searchSettings.PublicFilterExpression__c;
				searchhub = searchSettings.CoveoSearchHubKBSearchPublic__c;
				apiSearchTokenResponse.APISearchHub = searchhub;
				pipeline = searchSettings.CoveoPipelineKBSearchPublic__c;

			}
		}
		else if(strCalledFrom == ESUPPORTSEARCH)
		{
			String AccountFilter = getUserSupportAccount();
			if(AccountFilter != '' && AccountFilter.indexOf('Exception in getUserSupportAccount') == -1)
			{
				filter = searchSettings.CoveoESupportSearchFilter__c;
				filter += ' ((@sfsupport_account__c=(' + AccountFilter + ')) OR (@sfid=(' + AccountFilter + ')))';
			}
			else
			{
				SearchTokenAPIFlowStatus += ' ' + AccountFilter;
				filter = searchSettings.CoveoESupportSearchFilter__c + ' NOT(' + searchSettings.CoveoESupportSearchFilter__c + ')';
			}
			searchhub =  searchSettings.CoveoSearchHubESupportSearch__c;
			apiSearchTokenResponse.APISearchHub = searchhub;
			pipeline = searchSettings.CoveoPipelineESupport__c;

		}
		//<6 - Start - Used to only Idea data in Esupport>
		else if(strCalledFrom == ESUPPORTCRSEARCH)
		{
			filter = '(@infadocumenttype=(ChangeRequest)) (@infaviewpermissions=(authenticated))';
			searchhub =  'eSupportCRSearch';
			apiSearchTokenResponse.APISearchHub = searchhub;
			pipeline = searchSettings.CoveoPipelineESupport__c;

		}
		//<6 - End>
		else if(strCalledFrom == KBSEARCH)
		{
			if(userType == 'Guest')
			{
				filter = searchSettings.PublicFilterExpression__c;
				searchhub = searchSettings.CoveoSearchHubKBSearchPublic__c;
				apiSearchTokenResponse.APISearchHub = searchhub;
			}
			else {
				filter = searchSettings.AuthenticatedFilterExpression__c;
				searchhub = searchSettings.CoveoSearchHubKBSearchAuthenticated__c;
				apiSearchTokenResponse.APISearchHub = searchhub;
			}
			pipeline = searchSettings.CoveoPipelineKBSearchPublic__c;
		}
		else if(strCalledFrom == INFANETWORKSEARCH)
		{
			if(userType == 'Guest')
			{
				filter = searchSettings.PublicFilterExpression__c;
				searchhub = 'InfaNetworkGlobalSearch';
				apiSearchTokenResponse.APISearchHub = searchhub;
			}
			else {
				filter = searchSettings.AuthenticatedFilterExpression__c;
				searchhub = 'InfaNetworkGlobalSearchAuthenticated';
				apiSearchTokenResponse.APISearchHub = searchhub;
			}
			pipeline = searchSettings.CoveoPipelineKBSearchPublic__c;
			//pipeline = 'INFORMATICA NETWORK';
		}
		//<5>
		else if(strCalledFrom == INFANETWORKSEARCHBAR)
		{
			if(userType == 'Guest')
			{
				filter = searchSettings.PublicFilterExpression__c;
				searchhub = 'InfaNetworkGlobalSearchBar';
				apiSearchTokenResponse.APISearchHub = searchhub;
			}
			else {
				filter = searchSettings.AuthenticatedFilterExpression__c;
				searchhub = 'InfaNetworkGlobalSearchBarAuthenticated';
				apiSearchTokenResponse.APISearchHub = searchhub;
			}
			pipeline = searchSettings.CoveoPipelineKBSearchPublic__c;
			//pipeline = 'INFORMATICA NETWORK';
		}
		//</5>
		else if(strCalledFrom == CASECONSOLEIPXSEARCH)
		{
			searchhub = searchSettings.CoveoSearchHubIPXSearch__c;
			apiSearchTokenResponse.APISearchHub = searchhub;
			pipeline = searchSettings.CoveoSearchIPXPipeline__c;
		}
		else if(strCalledFrom == KBSEARCHOLD)
		{
			if(userType == 'Guest')
			{
				filter = searchSettings.PublicFilterExpression__c;
				searchhub = searchSettings.CoveoSearchHubKBSearchPublic__c;
				apiSearchTokenResponse.APISearchHub = searchhub;
			}
			else {
				filter = searchSettings.AuthenticatedFilterExpression__c;
				searchhub = searchSettings.CoveoSearchHubKBSearchAuthenticated__c;
				apiSearchTokenResponse.APISearchHub = searchhub;
			}
			pipeline = searchSettings.CoveoPipelineKBSearchPublic__c;

		}

		else if(strCalledFrom == ESUPPORTCASEDEFLECTIONTECHNICAL) {
			filter = searchSettings.CoveoCaseCreationSearchFilter__c;
			searchhub = 'CaseCreationTechnical';
			apiSearchTokenResponse.APISearchHub = searchhub;
			pipeline = searchSettings.CoveoPipelineESupport__c;

		}
		else if(strCalledFrom == ESUPPORTCASEDEFLECTIONGENERALINQUIRY) {
			filter = searchSettings.CoveoCaseCreationSearchFilter__c;
			searchhub = 'CaseCreationGeneralInquiry';
			apiSearchTokenResponse.APISearchHub = searchhub;
			pipeline = searchSettings.CoveoPipelineESupport__c;

		}
		else if(strCalledFrom == ESUPPORTCASEDEFLECTIONSHIPPING) {
			filter = searchSettings.CoveoCaseCreationSearchFilter__c;
			searchhub = 'CaseCreationShipping';
			apiSearchTokenResponse.APISearchHub = searchhub;
			pipeline = searchSettings.CoveoPipelineESupport__c;

		}
		else if(strCalledFrom == CASETOKBASSOCIATION) {
			filter = searchSettings.CoveoCaseToKBSearchFilter__c;
			searchhub = searchSettings.CoveoSearchHubKBSearchInternal__c;
			apiSearchTokenResponse.APISearchHub = searchhub;
			pipeline = searchSettings.CoveoPipelineKBSearchInternal__c;

		}
		else if(strCalledFrom == KBTOCASEASSOCIATION) {
			filter = searchSettings.CoveoKBToCaseSearchFilter__c;
			searchhub = searchSettings.CoveoSearchHubKBSearchInternal__c;
			apiSearchTokenResponse.APISearchHub = searchhub;
			pipeline = searchSettings.CoveoPipelineKBSearchInternal__c;
		}
		else {
			filter = searchSettings.PublicFilterExpression__c;
			searchhub = searchSettings.CoveoSearchHubKBSearchPublic__c;
			apiSearchTokenResponse.APISearchHub = searchhub;
			pipeline = searchSettings.CoveoPipelineKBSearchPublic__c;

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
		//objSearchTokenRequest.validFor = 900000;


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

	/*******************************************************************************************************
	 * @description Returns the recent result
	 */
	@AuraEnabled
	public static string getSearchResultRecenttData(string strSearchToken){

		String filter = '';
		String numOfArticles = '30';
		APISearchDataResponse apiSearchDataResponse = new APISearchDataResponse();
		apiSearchDataResponse.ErrorMessage = '';
		apiSearchDataResponse.APIResponseStatus = '';
		apiSearchDataResponse.SearchDataAPIURL = '';
		apiSearchDataResponse.searchDataList = null;
		apiSearchDataResponse.RecordCount = '';

		string SearchDataAPIFlowStatus ='296';

		try
		{
			List<SearchResultData> searchResultDatas = new List<SearchResultData>();

			AthenaSearch__c searchSettings = AthenaSearch__c.getOrgDefaults();
			String coveoEndpoint = searchSettings.CoveoEndPoint__c;
			filter = searchSettings.CoveoRecentSearchFilter__c;

			String orgname = searchSettings.CoveoOrgName__c;
			String searchEndpoint = coveoEndpoint + '/rest/search';
			String searchToken = strSearchToken;

			HttpRequest req = new HttpRequest();
			req.setEndpoint(searchEndpoint);
			req.setMethod('POST');
			String authorizationHeader = 'Bearer ' + searchToken;
			req.setHeader('Authorization', authorizationHeader);
			req.setHeader('Content-Type', 'application/json');
			req.setHeader('Accept', 'application/json');

			SearchDataAPIFlowStatus +='-426';

			SearchResultRequest objSearchResultRequest = new SearchResultRequest();

			objSearchResultRequest.aq = filter;


			string body = JSON.serialize(objSearchResultRequest,true);
			req.setHeader('Content-Length', String.valueOf(body.length()));
			req.setBody(body);
			Http http = new Http();
			HTTPResponse res = http.send(req);

			try {
				Map<String, Object> resultObj = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());

				List<Object> lstResults = (List<Object>)resultObj.get('results');

				for(Integer i = 0; i<lstResults.size(); i++) {

					Object result = lstResults[i];
					SearchResultData searchResultData = new SearchResultData();
					Map<String,Object> mapResult = (Map<String,Object>)result;

					if( mapResult.get('raw') != null)
					{
						Object objRaw = mapResult.get('raw');
						Map<String,Object> mapRaw = (Map<String,Object>)objRaw;
						//searchResultData.title = mapResult.get('title') != null ?  mapResult.get('title').toString()  : '';
						searchResultData.infadocid = mapRaw.get('infadocid') != null ?  mapRaw.get('infadocid').toString()  : '';
						searchResultDatas.add(searchResultData);
					}

				}
			} catch (Exception exSub) {
				apiSearchDataResponse.APIResponseStatus = 'ERROR';
				apiSearchDataResponse.ErrorMessage = exSub.getMessage();
				apiSearchDataResponse.SearchDataAPIFlowStatus = SearchDataAPIFlowStatus;
			}


			apiSearchDataResponse.APIResponseStatus = 'OK';
			apiSearchDataResponse.searchDataList = searchResultDatas;
			apiSearchDataResponse.SearchDataAPIFlowStatus = SearchDataAPIFlowStatus;


		}

		catch(Exception e) {

			apiSearchDataResponse.APIResponseStatus = 'ERROR';
			apiSearchDataResponse.ErrorMessage = e.getMessage();
			apiSearchDataResponse.SearchDataAPIFlowStatus = SearchDataAPIFlowStatus;


		}
		return JSON.serialize(apiSearchDataResponse);
	}

	/*******************************************************************************************************
	 * @description Returns the similar articles from coveo based on the keywords
	 * @param strSearchToken salesforce current user session id
	 * @param strUserEmail current user email
	 * @param strUserID current user id
	 * @return Returns the recent content from coveo as json string
	 */
	@AuraEnabled
	public static string getSimilarCases(string strSearchToken, string strSearchKeyword,string strCaseNumber,string strIsOnload){
		String searchKeywords='';
		String knwldgeKeywords='';
		String athenaproduct='';
		String searchhub;
		String pipeline;
		String filter = '';
		String numOfArticles = '10';
		String viewFilter = '';
		APISearchDataResponse apiSearchDataResponse = new APISearchDataResponse();
		apiSearchDataResponse.ErrorMessage = '';
		apiSearchDataResponse.APIResponseStatus = '';
		apiSearchDataResponse.SearchDataAPIURL = '';
		apiSearchDataResponse.searchDataList = null;
		apiSearchDataResponse.searchCaseDataList = null;
		apiSearchDataResponse.RecordCount = '';
		String strUserId = UserInfo.getUserId();//<3>

		string SearchDataAPIFlowStatus ='getSimilarCases 296';
		try
		{
			List<SearchCaseResultData> searchCaseResultDatas = new List<SearchCaseResultData>();

			AthenaSearch__c searchSettings = AthenaSearch__c.getOrgDefaults();
			String coveoEndpoint = searchSettings.CoveoEndPoint__c;

			String orgname = searchSettings.CoveoOrgName__c;

			String searchEndpoint = coveoEndpoint + '/rest/search';

			String searchToken = strSearchToken;



			HttpRequest req = new HttpRequest();
			req.setEndpoint(searchEndpoint);
			req.setMethod('POST');
			String authorizationHeader = 'Bearer ' + searchToken;
			req.setHeader('Authorization', authorizationHeader);
			req.setHeader('Content-Type', 'application/json');
			req.setHeader('Accept', 'application/json');

			SearchDataAPIFlowStatus +='-426';

			SearchResultRequest objSearchResultRequest = new SearchResultRequest();
			//<3>
			if(strUserId != '' && strIsOnload == '1')
			{
				filter += ' (@sfownerid=(' + strUserId + '))';
				objSearchResultRequest.sortCriteria = 'date descending';
			}

			if(strCaseNumber != '')
			{
				filter += ' NOT(@sfcasenumber=(' + strCaseNumber + '))';
			}

			if(filter.trim() != '')
			{
				objSearchResultRequest.aq = filter;
			}
			//</3>

			if(strSearchKeyword != '')
			{
				searchKeywords = strSearchKeyword;
				objSearchResultRequest.q = searchKeywords;
			}
			else
			{
				objSearchResultRequest.q = '';
			}

			objSearchResultRequest.numberOfResults=numOfArticles;


			string body = JSON.serialize(objSearchResultRequest,true);
			req.setHeader('Content-Length', String.valueOf(body.length()));
			req.setBody(body);
			Http http = new Http();
			HTTPResponse res = http.send(req);

			//SearchDataAPIFlowStatus += res.getBody();

			Map<String, Object> resultObj = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());

			List<Object> lstResults = (List<Object>)resultObj.get('results');

			for(Integer i = 0; i<lstResults.size(); i++) {

				Object result = lstResults[i];
				SearchCaseResultData searchCaseResultData = new SearchCaseResultData();
				Map<String,Object> mapResult = (Map<String,Object>)result;

				if( mapResult.get('raw') != null)
				{
					Object objRaw = mapResult.get('raw');
					Map<String,Object> mapRaw = (Map<String,Object>)objRaw;
					searchCaseResultData.sfid = mapRaw.get('sfid') != null ?  mapRaw.get('sfid').toString()  : '';
					searchCaseResultData.syssfid = mapRaw.get('syssfid') != null ?  mapRaw.get('syssfid').toString()  : '';
					searchCaseResultData.title = mapResult.get('title') != null ?  mapResult.get('title').toString()  : '';
					searchCaseResultData.clickUri = mapResult.get('clickUri') != null ?  mapResult.get('clickUri').toString()  : '';
					searchCaseResultData.sfcasestatus = mapRaw.get('sfcasestatus') != null ?  mapRaw.get('sfcasestatus').toString()  : '';
					// searchCaseResultData.sflastmodifieddate = mapRaw.get('sflastmodifieddate') != null ?  mapRaw.get('sflastmodifieddate').toString()  : '';
					searchCaseResultData.syssfdescription = mapRaw.get('syssfdescription') != null ?  mapRaw.get('syssfdescription').toString()  : '';
					searchCaseResultData.sfpriority = mapRaw.get('sfpriority') != null ?  mapRaw.get('sfpriority').toString()  : '';
					searchCaseResultData.sfcasenumber = mapRaw.get('sfcasenumber') != null ?  mapRaw.get('sfcasenumber').toString()  : '';
					searchCaseResultData.sfsupportaccountrname = mapRaw.get('sfsupport_account__rname') != null ?  mapRaw.get('sfsupport_account__rname').toString()  : '';
					searchCaseResultDatas.add(searchCaseResultData);
				}

			}

			apiSearchDataResponse.APIResponseStatus = 'OK';
			apiSearchDataResponse.searchCaseDataList = searchCaseResultDatas;
			apiSearchDataResponse.SearchDataAPIFlowStatus = SearchDataAPIFlowStatus;


		}

		catch(Exception e) {

			apiSearchDataResponse.APIResponseStatus = 'ERROR';
			apiSearchDataResponse.ErrorMessage = e.getMessage();
			apiSearchDataResponse.SearchDataAPIFlowStatus = SearchDataAPIFlowStatus;


		}
		return JSON.serialize(apiSearchDataResponse);
	}


	/*******************************************************************************************************
	 * @description Returns the similar articles from coveo based on the keywords
	 * @param strSearchToken salesforce current user session id
	 * @param strUserEmail current user email
	 * @param strUserID current user id
	 * @return Returns the recent content from coveo as json string
	 */
	@AuraEnabled
	public static string getSimilarArticle(string strSearchToken, string strSearchKeyword,string strArticleNumber){
		String searchKeywords='';
		String knwldgeKeywords='';
		String athenaproduct='';
		String searchhub;
		String pipeline;
		String filter = '';
		String numOfArticles = '5';
		String viewFilter = '';
		APISearchDataResponse apiSearchDataResponse = new APISearchDataResponse();
		apiSearchDataResponse.ErrorMessage = '';
		apiSearchDataResponse.APIResponseStatus = '';
		apiSearchDataResponse.SearchDataAPIURL = '';
		apiSearchDataResponse.searchDataList = null;
		apiSearchDataResponse.searchKBDataList = null;
		apiSearchDataResponse.RecordCount = '';

		string SearchDataAPIFlowStatus ='296';
		try
		{
			List<SearchKBResultData> searchKBResultDatas = new List<SearchKBResultData>();

			AthenaSearch__c searchSettings = AthenaSearch__c.getOrgDefaults();
			String coveoEndpoint = searchSettings.CoveoEndPoint__c;

			String orgname = searchSettings.CoveoOrgName__c;

			String searchEndpoint = coveoEndpoint + '/rest/search';

			String searchToken = strSearchToken;



			HttpRequest req = new HttpRequest();
			req.setEndpoint(searchEndpoint);
			req.setMethod('POST');
			String authorizationHeader = 'Bearer ' + searchToken;
			req.setHeader('Authorization', authorizationHeader);
			req.setHeader('Content-Type', 'application/json');
			req.setHeader('Accept', 'application/json');

			SearchDataAPIFlowStatus +='-426';

			SearchResultRequest objSearchResultRequest = new SearchResultRequest();

			if(strArticleNumber != '')
			{
				filter = ' NOT(@sfarticlenumber=(' + strArticleNumber + '))';
				objSearchResultRequest.aq = filter;
			}
			else
			{
				objSearchResultRequest.aq = '';
			}

			if(strSearchKeyword != '')
			{
				searchKeywords = strSearchKeyword;
				objSearchResultRequest.q = searchKeywords;
			}
			else
			{
				objSearchResultRequest.q = '';
			}

			objSearchResultRequest.numberOfResults=numOfArticles;


			string body = JSON.serialize(objSearchResultRequest,true);
			req.setHeader('Content-Length', String.valueOf(body.length()));
			req.setBody(body);
			Http http = new Http();
			HTTPResponse res = http.send(req);

			//SearchDataAPIFlowStatus += res.getBody();

			Map<String, Object> resultObj = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());

			List<Object> lstResults = (List<Object>)resultObj.get('results');

			for(Integer i = 0; i<lstResults.size(); i++) {

				Object result = lstResults[i];
				SearchKBResultData searchKBResultData = new SearchKBResultData();
				Map<String,Object> mapResult = (Map<String,Object>)result;

				if( mapResult.get('raw') != null)
				{
					Object objRaw = mapResult.get('raw');
					Map<String,Object> mapRaw = (Map<String,Object>)objRaw;
					searchKBResultData.infadocid = mapRaw.get('infadocid') != null ?  mapRaw.get('infadocid').toString()  : '';
					searchKBResultData.sfarticlenumber = mapRaw.get('sfarticlenumber') != null ?  mapRaw.get('sfarticlenumber').toString()  : '';
					searchKBResultData.sfid = mapRaw.get('sfid') != null ?  mapRaw.get('sfid').toString()  : '';
					searchKBResultData.title = mapResult.get('title') != null ?  mapResult.get('title').toString()  : '';
					searchKBResultData.infavalidationstatus = mapRaw.get('infavalidationstatus') != null ?  mapRaw.get('infavalidationstatus').toString()  : '';//<2>
					searchKBResultData.athenalanguage = mapRaw.get('athenalanguage') != null ?  mapRaw.get('athenalanguage').toString()  : '';//<2>
					searchKBResultData.infarecordtypename = mapRaw.get('infarecordtypename') != null ?  mapRaw.get('infarecordtypename').toString()  : '';//<T7>
					searchKBResultDatas.add(searchKBResultData);
				}

			}

			apiSearchDataResponse.APIResponseStatus = 'OK';
			apiSearchDataResponse.searchKBDataList = searchKBResultDatas;
			apiSearchDataResponse.SearchDataAPIFlowStatus = SearchDataAPIFlowStatus;


		}

		catch(Exception e) {

			apiSearchDataResponse.APIResponseStatus = 'ERROR';
			apiSearchDataResponse.ErrorMessage = e.getMessage();
			apiSearchDataResponse.SearchDataAPIFlowStatus = SearchDataAPIFlowStatus;


		}
		return JSON.serialize(apiSearchDataResponse);
	}

	// /*******************************************************************************************************
	//  * @description Returns the String after replacing the characters in the provided input
	//  * @param input a String before replacing special characters
	//  * @return Returns a String after replacing special characters
	//  */
	// private static string processString(String input){

	//   string eVal = input;
	//   eVal = eVal.replaceAll('~', ' ');
	//   eVal = eVal.replaceAll('!', ' ');
	//   eVal = eVal.replaceAll('@', ' ');
	//   eVal = eVal.replaceAll('#', ' ');
	//   eVal = eVal.replaceAll('$', ' ');
	//   eVal = eVal.replaceAll('&', ' ');
	//   eVal = eVal.replaceAll('\\*', ' ');
	//   eVal = eVal.replaceAll('\\(', ' ');
	//   eVal = eVal.replaceAll('\\)', ' ');
	//   eVal = eVal.replaceAll('=', ' ');
	//   eVal = eVal.replaceAll('\\+', ' ');
	//   eVal = eVal.replaceAll(';', ' ');
	//   eVal = eVal.replaceAll(':', ' ');
	//   eVal = eVal.replaceAll('\'', ' ');
	//   eVal = eVal.replaceAll(',', ' ');
	//   eVal = eVal.replaceAll('"', ' ');
	//   eVal = eVal.replaceAll('/', ' ');
	//   eVal = eVal.replaceAll('\\?', ' ');
	//   eVal = eVal.replaceAll('`', ' ');
	//   eVal = eVal.replaceAll('>', ' ');
	//   eVal = eVal.replaceAll('<', ' ');
	//   eVal = eVal.replaceAll('\r\n', ' ');
	//   eVal = eVal.replaceAll('\n', ' ');
	//   eVal = eVal.replaceAll('\r', ' ');
	//   eVal = eVal.replaceAll('”', ' ');
	//   eVal = eVal.replaceALl('“', ' ');


	//   return eVal;
	// }

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


	/*******************************************************************************************************
	 * @description Returns the user product filter based on the cases related to the current user
	 * @param strSessionToken salesforce current user session id
	 * @param strUserEmail current user email
	 * @param strUserID current user id
	 * @return Returns the user product filter based on the cases related to the current user as json string
	 */
	@AuraEnabled
	public static string getUserFilter(){
		APISearchTokenResponse apiSearchTokenResponse = new APISearchTokenResponse();
		apiSearchTokenResponse.APISearchToken = '';
		apiSearchTokenResponse.ErrorMessage = '';
		apiSearchTokenResponse.APIResponseStatus = '';
		apiSearchTokenResponse.groupByResults = null;
		apiSearchTokenResponse.RecordCount = '';
		apiSearchTokenResponse.APIResponseData = '';
		List<SearchFacettData> groupByResults = new List<SearchFacettData>();
		string SearchTokenAPIFlowStatus = '';
		try{

			String strCurrentUserID = userInfo.getUserId();
			AthenaSearch__c searchSettings = AthenaSearch__c.getOrgDefaults();

			string strFacetFieldName = '@athenaproduct';
			SearchFacettData groupByResult = new SearchFacettData();
			List<Case> lstCaseDetails = [SELECT Case.Forecast_Product__c FROM Case WHERE Case.OwnerId = :strCurrentUserID AND (Case.status != 'Closed' AND Case.status != 'Complete' AND Case.status != 'Resolved') AND (Case.Record_Type_Name__c = 'Technical' OR Case.Record_Type_Name__c = 'Collaboration: PS Review')];
			Set<Case> resultset = new Set<Case>();
			List<Case> result = new List<Case>();
			resultset.addAll(lstCaseDetails);
			result.addAll(resultset);

			List<String> allvalue = new List<String>();
			for(Case objCaseDetails : result ) {
				if(objCaseDetails.Forecast_Product__c != null) {
					allvalue.add(objCaseDetails.Forecast_Product__c);
				}
			}
			groupByResult.field = strFacetFieldName;
			groupByResult.values = allvalue;
			groupByResults.add(groupByResult);

			apiSearchTokenResponse.APIResponseStatus ='OK';
			apiSearchTokenResponse.ErrorMessage = '';
		}catch(Exception e) {
			apiSearchTokenResponse.APIResponseStatus = 'ERROR';
			apiSearchTokenResponse.ErrorMessage = e.getMessage();
			apiSearchTokenResponse.APISearchToken = '';

		}

		apiSearchTokenResponse.groupByResults = groupByResults;
		apiSearchTokenResponse.SearchTokenAPIFlowStatus = SearchTokenAPIFlowStatus;

		return JSON.serialize(apiSearchTokenResponse);
	}


	public static String getUserSupportAccount(){
		//Same Logic applied in the method getSupportAccWithRWAccess
		String strReturn = '';
		try
		{

			list<AccountContactRelation> lstACR=new list<AccountContactRelation>();
			Id SupportAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Support Account').getRecordTypeId();
			List<User> userContact = [SELECT Id, ContactId, Contact.AccountId FROM USER WHERE Id =: UserInfo.getUserId() and ContactId!=null];

			if(!userContact.isEmpty()) {

				for(AccountContactRelation account: [SELECT Id, Account.Name,favorite__c, Account.End_Date__c FROM AccountContactRelation
				                                     WHERE Account.RecordTypeId=: SupportAccountRecType AND Account.Active__c = true
				                                                                                                                AND ContactId =: userContact[0].ContactId WITH SECURITY_ENFORCED Order By favorite__c desc,Account.Name asc]) {
					if(account.Account.End_Date__c!=null) {
						if(system.today() <=  account.Account.End_Date__c.addDays(10)) {
							lstACR.add(account);
						}
					}

				}
			}

			for(AccountContactRelation account:lstACR) {
				if(strReturn == '')
				{
					strReturn = account.Account.Id;
				}
				else {
					strReturn += ',' + String.valueOf(account.Account.Id);
				}
			}
		}
		catch (Exception e) {
			system.debug('Exception in getUserSupportAccount : '+e.getmessage()+e.getlinenumber());
			strReturn += 'Exception in getUserSupportAccount : '+e.getmessage()+e.getlinenumber();
		}
		return strReturn;
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
	public string RefreshCount;//T08

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
	//public integer validFor { get; set; }
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
	public string sortCriteria {get; set;}//<3>
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
	public string infavalidationstatus   { get; set; }//<2>
	public string athenalanguage   { get; set; }//<2>
	public string infarecordtypename   { get; set; }//<T7>
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