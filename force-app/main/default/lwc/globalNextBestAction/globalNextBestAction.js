/*
 * Name			:	GlobalNextBestAction
 * Author		:	Monserrat Pedroza
 * Created Date	: 	9/14/2021
 * Description	:	Next Best Action Controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		9/14/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import getRecommendations from "@salesforce/apex/GlobalNextBestActionController.getRecommendations";
import getSelectionSaved from "@salesforce/apex/GlobalNextBestActionController.getSelectionSaved";
import getRecordUpserted from "@salesforce/apex/GlobalNextBestActionController.getRecordUpserted";
import getRecordDeleted from "@salesforce/apex/GlobalNextBestActionController.getRecordDeleted";

//Custom Labels.
import No_Recommendations_Found from '@salesforce/label/c.No_Recommendations_Found';
import Next_Best_Action_Title from '@salesforce/label/c.Next_Best_Action_Title';
import Accept_Recommendation from '@salesforce/label/c.Accept_Recommendation';
import Reject_Recommendation from '@salesforce/label/c.Reject_Recommendation';
import Operation_Executed_Successfully from '@salesforce/label/c.Operation_Executed_Successfully';
import CSM_NBA_Refresh_Frequency from '@salesforce/label/c.CSM_NBA_Refresh_Frequency';

//Class body.
export default class GlobalNextBestAction extends NavigationMixin(LightningElement) {

	//API variables.
	@api recordId;
	@api intRecordsPerPage;

	//Track variables.
	@track objCurrentRecommendation;
	@track lstRecommendations;
	@track lstOriginalRecords;
	@track boolDisplaySpinner;
	@track boolDisplayPaginator;
	@track boolHasRecommendations;
	@track objPaginatorParameters = {
		intPaginatorType: 2,
		intPageSize: 5
	};

	timeout;

	//Private variables.
	strSerializedResponse;

	//Labels.
	label = {
		No_Recommendations_Found,
		Next_Best_Action_Title,
		Accept_Recommendation,
		Reject_Recommendation,
		Operation_Executed_Successfully
	}

	/*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
		let objParent = this;

		//We set the default values.
		objParent.boolHasRecommendations = false;
		objParent.boolDisplaySpinner = true;
		objParent.boolDisplayPaginator = false;
		objParent.lstRecommendations = new Array();
		objParent.lstOriginalRecords = new Array();

		//Now we load the records.
		objParent.loadRecords();
	}

	disconnectedCallback(){
		clearTimeout(this.timeout);
	}

	/*
	 Method Name : loadRecords
	 Description : This method loads the recommendations.
	 Parameters	 : None
	 Return Type : None
	 */
	loadRecords() {
		let boolContinueExecution;
		let strNewSerializedResponse;
		let objParent = this;

		//Now, we load the recomendations.
		this.timeout=setTimeout(function() {
			getRecommendations({
				objRequest: {
					idRecord: objParent.recordId
				}
			}).then((lstResults) => {

				//Now we check if we have received a different response.
				boolContinueExecution = false;
				strNewSerializedResponse = JSON.stringify(lstResults);
				if(strNewSerializedResponse !== objParent.strSerializedResponse) {
					objParent.strSerializedResponse = strNewSerializedResponse;
					boolContinueExecution = true;
				}

				//If we can continue.
				if(boolContinueExecution) {

					//We set the default values.
					objParent.boolHasRecommendations = false;
					objParent.boolDisplaySpinner = true;
					objParent.boolDisplayPaginator = false;
					objParent.lstRecommendations = new Array();
					objParent.lstOriginalRecords = new Array();
		
					//Now we check if we received data.
					if(objUtilities.isNotNull(lstResults) && lstResults.length > 0) {
		
						//We received data.
						objParent.boolHasRecommendations = true;
						objParent.lstRecommendations = [... lstResults];
						objParent.lstOriginalRecords = [... lstResults];
		
						//Now we check if we need a paginator.
						if(objUtilities.isNotNull(objParent.intRecordsPerPage)) {
							objParent.boolDisplayPaginator = true;
							objParent.objPaginatorParameters.intPageSize = objParent.intRecordsPerPage;
		
							//We make sure we have a valid value.
							if(isNaN(objParent.objPaginatorParameters.intPageSize) || objParent.objPaginatorParameters.intPageSize < 1) {
								objParent.objPaginatorParameters.intPageSize = 5;
							}

							//Now we reset paginator.
							if(objUtilities.isNotNull(objParent.template.querySelector("c-global-paginator"))) {
								objParent.template.querySelector("c-global-paginator").resetTheData(objParent.lstOriginalRecords);
							}
						}
					}
	
					//Finally, we hide the spinner.
					objParent.boolDisplaySpinner = false;
				}
			}).catch((objError) => {
				objUtilities.processException(objError, objParent);
			}).finally(() => {

				//Now we load the records.
				objParent.loadRecords();
			});
		}, CSM_NBA_Refresh_Frequency);
	}

	/*
	 Method Name : setCurrentRecommendation
	 Description : This method sets the current recommendation, based on the record id provided.
	 Parameters	 : String, called from setCurrentRecommendation, strRecordId Record Id.
	 Return Type : None
	 */
	setCurrentRecommendation(strRecordId) {
		let objParent = this;
		if(objUtilities.isNotBlank(strRecordId) && objUtilities.isNotNull(objParent.lstOriginalRecords)) {
			objParent.lstOriginalRecords.forEach(objRecommendation => {
				if(objRecommendation.idRecord === strRecordId) {
					objParent.objCurrentRecommendation = {... objRecommendation};
				}
			});
		}
	}

	/*
	 Method Name : acceptRecommendation
	 Description : This method executes the corresponding action of the actual recommendation, and saves the selection.
	 Parameters	 : Object, called from acceptRecommendation, objEvent Event.
	 Return Type : None
	 */
	acceptRecommendation(objEvent) {
		this.executeActionSelected(true, objEvent.currentTarget.dataset.id);
	}

	/*
	 Method Name : rejectRecommendation
	 Description : This method executes the corresponding action of the actual recommendation, and saves the selection.
	 Parameters	 : Object, called from acceptRecommendation, objEvent Event.
	 Return Type : None
	 */
	rejectRecommendation(objEvent) {
		this.executeActionSelected(false, objEvent.currentTarget.dataset.id);
	}

	/*
	 Method Name : executeActionSelected
	 Description : This method executes the corresponding action of the actual recommendation;
	 Parameters	 : Boolean, called from executeActionSelected, boolSelection If the recommendation was accepted or rejected.
	 			   String, called from executeActionSelected, strRecommendationId Recommendation Id.
	 Return Type : None
	 */
	executeActionSelected(boolSelection, strRecommendationId) {
		let objData;
		let objAction;
		let objParent = this;

		//We start the spinner.
		objParent.boolDisplaySpinner = true;

		//Now we set the current recommendation.
		objParent.setCurrentRecommendation(strRecommendationId);

		//Now we check which operation we need to execute.
		if(objUtilities.isNotNull(objParent.objCurrentRecommendation)) {

			//Now, depending on the user selection, we use the corresponding action.
			if(boolSelection) {
				if(objUtilities.isNotNull(objParent.objCurrentRecommendation.objAcceptedAction)) {
					objAction = objParent.objCurrentRecommendation.objAcceptedAction;
				} else if(objUtilities.isNotBlank(objParent.objCurrentRecommendation.strActionData) || objUtilities.isNotBlank(objParent.objCurrentRecommendation.strActionTarget)) {
					objAction = new Object();
					objAction.strActionData = objParent.objCurrentRecommendation.strActionData;
					objAction.strActionType = objParent.objCurrentRecommendation.strActionType;
					objAction.strActionTarget = objParent.objCurrentRecommendation.strActionTarget;
				}
			} else if(objUtilities.isNotNull(objParent.objCurrentRecommendation.objRejectedAction)) {
				objAction = objParent.objCurrentRecommendation.objRejectedAction;
			}

			//If we have an action to execute.
			if(objUtilities.isNotNull(objAction)) {

				//Now we transform the data into object, if possible.
				try {
					objData = JSON.parse(objAction.strActionData);
				} catch(objException) {
					objData = new Object();
				}

				//Now we decide the operation.
				switch(objAction.strActionType) {
					case "Launch Component":
					case "Launch Component In Modal":
						objParent.dispatchEvent(
							new CustomEvent("executeaction", {
								detail: {
									strActionTarget: objAction.strActionTarget,
									strActionData: objAction.strActionData,
									strActionType: objAction.strActionType
								},
								bubbles: true,
								composed: true
							})
						);

						//Now, we save the selection.
						objParent.saveSelection(boolSelection);
					break;
					case "Upsert record":
						getRecordUpserted({
							objRequest: {
								strActionTarget: objAction.strActionTarget,
								strActionData: objAction.strActionData
							}
						}).then(() => {
				
							//Now, we remove the current recommendation from the list, and fetch the next one.
							objUtilities.showToast("Success", objParent.label.Operation_Executed_Successfully, "success", objParent);
						}).catch((objError) => {
							objUtilities.processException(objError, objParent);
						}).finally(() => {

							//Now, we save the selection.
							objParent.saveSelection(boolSelection);
						});
					break;
					case "Delete record":
						getRecordDeleted({
							objRequest: {
								strActionTarget: objAction.strActionTarget,
								strActionData: objAction.strActionData
							}
						}).then(() => {
				
							//Now, we remove the current recommendation from the list, and fetch the next one.
							objUtilities.showToast("Success", objParent.label.Operation_Executed_Successfully, "success", objParent);
						}).catch((objError) => {
							objUtilities.processException(objError, objParent);
						}).finally(() => {

							//Now, we save the selection.
							objParent.saveSelection(boolSelection);
						});
					break;
					case "Navigate":

						//Now we check if we received default parameters.
						if(objUtilities.isNotNull(objData.state) && objUtilities.isNotNull(objData.state.defaultFieldValues)) {
							objData.state.defaultFieldValues = encodeDefaultFieldValues(objData.state.defaultFieldValues);
						}

						//Now we navigate to the target.
						objParent[NavigationMixin.Navigate](objData);

						//Now, we save the selection.
						objParent.saveSelection(boolSelection);
					break;
					case "No Action":
					break;
				}
			} else {

				//Otherwise we only save the selection.
				objParent.saveSelection(boolSelection);
			}
		}
	}

	/*
	 Method Name : saveSelection
	 Description : This method saves the selection.
	 Parameters	 : Boolean, called from saveSelection, boolAccepted Recommendation accepted or rejected.
	 Return Type : None
	 */
	saveSelection(boolAccepted) {
		let objParent = this;
		
		//If there's a current selection.
		if(objUtilities.isNotNull(objParent.objCurrentRecommendation) && objUtilities.isNotNull(boolAccepted)) {
			getSelectionSaved({
				objRequest: {
					idParentRecord: objParent.recordId,
					idRecord: objParent.objCurrentRecommendation.idRecord,
					boolAccepted: boolAccepted
				}
			}).catch((objError) => {
				objUtilities.processException(objError, objParent);
			});
		}
	}

	/*
	 Method Name : reload
	 Description : This method reloads the component.
	 Parameters	 : None
	 Return Type : None
	 */
	reload() {
		this.loadRecords();
	}

	/*
	 Method Name : changeTablePage
	 Description : This method changes the page on the Table.
	 Parameters	 : Object, called from changeTablePage, objEvent Event.
	 Return Type : None
	 */
	changeTablePage(objEvent) {
		this.lstRecommendations = objEvent.detail;
	}
}