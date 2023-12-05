/*
 * Name			:	GlobalZoomAuthorization
 * Author		:	Monserrat Pedroza
 * Created Date	: 	7/9/2021
 * Description	:	This LWC starts the Authorization process with Zoom App.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		7/9/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import getAuthorizationEndpoint from "@salesforce/apex/GlobalZoomController.getAuthorizationEndpoint";

//Custom Labels.
import Close_Modal from '@salesforce/label/c.Close_Modal';

//Class body.
export default class GlobalZoomAuthorization extends NavigationMixin(LightningElement) {

	//API variables.
	@api recordId;

	//Public variables.
	boolInitialLoad = true;
	strRecordId;
	strIframeSource;

	//Labels.
	label = {
		Close_Modal
	}

	/*
	 Method Name : constructor
	 Description : Constructor.
	 Parameters	 : None
	 Return Type : None
	 */
	constructor() {
		super();
		let objParent = this;

		//We set the listener to close the quick action.
		window.addEventListener("message", function(objEvent) {

			//First we make sure the message is for us.
			if(objEvent.data && objEvent.data.strRecordId === objParent.strRecordId) {
				objParent.dispatchEvent(new CloseActionScreenEvent());
			}
		});
	}

	/*
	 Method Name : renderedCallback
	 Description : This method gets executed on UI rerendering.
	 Parameters	 : None
	 Return Type : None
	 */
	renderedCallback() {
		let objParent = this;
		if(objParent.boolInitialLoad && objUtilities.isNotBlank(objParent.recordId)) {
			objParent.boolInitialLoad = false;
		
			//First we obtain the record id.
			objParent.strRecordId = objParent.recordId;

			//Now we obtain the endpoint properties.
			getAuthorizationEndpoint().then((objEndpoint) => {
	
				//Now we open the authorization page.
				window.open(objEndpoint.strEndpoint + "?response_type=code&client_id=" + objEndpoint.strClientId + "&redirect_uri=" + objEndpoint.strRedirectURI + "&state=" + objParent.strRecordId, "_blank");
				window.postMessage({
					strRecordId: objParent.strRecordId
				}, "*");
			}).catch((objError) => {
				objUtilities.processException(objError, objParent);
			});
		}
	}
}