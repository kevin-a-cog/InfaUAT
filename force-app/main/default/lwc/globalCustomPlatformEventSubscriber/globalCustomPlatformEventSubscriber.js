/*
 * Name			:	globalCustomPlatformEventSubscriber
 * Author		:	Monserrat Pedroza
 * Created Date	: 	7/8/2022
 * Description	:	This LWC contains Custom Platform Event Subscriber function.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		7/1/2022		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api } from 'lwc';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

//Utilities.
import { objUtilities } from 'c/globalUtilities';
import { objEvents } from 'c/globalCustomPlatformEvents';

//Class body.
export default class GlobalCustomPlatformEventSubscriber extends LightningElement {

	//API variables.
	@api recordId;
	@api boolSubscribeOnLoad;
	@api strRecordName;

	//Private variables.
	objSubscription;

	/*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
		if(objUtilities.isBlank(this.boolSubscribeOnLoad) || this.boolSubscribeOnLoad === "true") {
			this.subscribe();
		}
	}

	/*
	 Method Name : refreshData
	 Description : This method gets executed when a Custom Platform Event occurs.
	 Parameters	 : None
	 Return Type : None
	 */
	@api
	refreshData() {
		getRecordNotifyChange([{
			recordId: this.recordId
		}]);
	}

	/*
	 Method Name : disconnectedCallback
	 Description : This method gets executed once the component is removed from the DOM.
	 Parameters	 : None
	 Return Type : None
	 */
	disconnectedCallback() {
		this.unsubscribe();
	}

	/*
	 Method Name : subscribe
	 Description : This method starts the subscription.
	 Parameters	 : None
	 Return Type : None
	 */
	@api
	subscribe() {
		
		//We subscribe to the Custom Platform Events.
		if(objUtilities.isNotBlank(this.strRecordName)) {
			this.objSubscription = objEvents.subscribeToRecord({
				idRecord: this.recordId, 
				strRecordName: this.strRecordName,
				strMethodName: "refreshData",
				objParent: this
			});
		}
	}

	/*
	 Method Name : unsubscribe
	 Description : This method stops the subscription.
	 Parameters	 : None
	 Return Type : None
	 */
	@api
	unsubscribe() {

		//We remove the listener we opened.
		if(objUtilities.isNotNull(this.objSubscription)) {
			objEvents.unsubscribeFromRecord(this.objSubscription);
		}
	}
}