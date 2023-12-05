/*
 * Name			:	GlobalZoomController
 * Author		:	Monserrat Pedroza
 * Created Date	: 	7/9/2021
 * Description	:	Controller class for Zoom Integration.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		7/9/2021		N/A				Initial version.			N/A
 */
public with sharing class GlobalZoomController {

	/*
	 Method Name : processAuthorizationResponse
	 Description : This method processes the Authorization response from Zoom.
	 Parameters	 : None
	 Return Type : None
	 */
    public void processAuthorizationResponse() {
		Meeting_Account__c objMeetingAccount = new Meeting_Account__c();
		HttpResponse objResponse = new HttpResponse();
		GlobalZoomRequestWrapperClass objWrappedRequest = new GlobalZoomRequestWrapperClass();
		GlobalZoomResponseWrapperClass objWrappedResponse = new GlobalZoomResponseWrapperClass();
		GlobalZoomEndpointWrapperClass objEndpoint = GlobalZoomUtilitiesClass.getEndpoint('Token');
		Map<String, String> mapParameters = ApexPages.currentPage().getParameters();

		//First we define the HTTP request parameters.
        objWrappedRequest.strBody = 'grant_type=authorization_code&code=' + mapParameters.get('code') + '&redirect_uri=' + objEndpoint.strRedirectURI;
		objWrappedRequest.strEndpointLabel = 'Token';

		//Now we execute the callout.
        objResponse = GlobalZoomUtilitiesClass.executeZoomCallout(objWrappedRequest);
        
		//Now we analyze the response.
        if(objResponse.getStatusCode() == 200) {
            objWrappedResponse = (GlobalZoomResponseWrapperClass) JSON.deserialize(objResponse.getBody(), GlobalZoomResponseWrapperClass.class);

			//Now we update the Meeting Account record.
			objMeetingAccount.Id = mapParameters.get('state');
			objMeetingAccount.Access_Token__c = objWrappedResponse.access_token;
			objMeetingAccount.Expires_In__c = objWrappedResponse.expires_in;
			objMeetingAccount.Refresh_Token__c = objWrappedResponse.refresh_token;
			objMeetingAccount.Scope__c = objWrappedResponse.scope;
			objMeetingAccount.Token_Type__c = objWrappedResponse.token_type;
			update objMeetingAccount;
        }
    }

	/*
	 Method Name : getAuthorizationEndpoint
	 Description : This method returns the Authorization endpoint details.
	 Parameters	 : None
	 Return Type : Object
	 */
	@AuraEnabled
    public static GlobalZoomEndpointWrapperClass getAuthorizationEndpoint() {
		GlobalZoomEndpointWrapperClass objResult = GlobalZoomUtilitiesClass.getEndpoint('Authorize');
		objResult.strClientSecret = null;
		return objResult;
    }
}