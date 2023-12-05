/*
 * Name			:	csmIPUConsumptionGoalsLauncher
 * Author		:	Monserrat Pedroza
 * Created Date	: 	3/15/2023
 * Description	:	This LWC launches the IPU Consumption Goals component.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		3/15/2023		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

//Utilities.
import { objUtilities } from "c/globalUtilities";

//Apex Controllers.
import getAccountId from "@salesforce/apex/IPUConsumptionGoalsController.getAccountId";
import saveButtonType from "@salesforce/apex/IPUConsumptionGoalsController.saveButtonType";

//Custom Labels.
import EditIPUConsumptionGoals from "@salesforce/label/c.EditIPUConsumptionGoals";
import Consumption_Goals_History from "@salesforce/label/c.Consumption_Goals_History";

//Class body.
export default class CsmIPUConsumptionGoalsLauncher extends NavigationMixin(LightningElement) {

	//API variables.
	@api recordId;
	@api objectApiName;

	//Private variables.
	boolIsPoppedOut = false;
	boolHasRecords = false;
	boolDisplayIPUConsumptionGoalsModal = false;
	boolDisplayChurnForecastModal = false;
	boolDisplayGenerateRiskModal = false;

	//Labels.
	label = {
		EditIPUConsumptionGoals: EditIPUConsumptionGoals,
		Consumption_Goals_History: Consumption_Goals_History
	};


	get displayICGOptions(){
		return this.objectApiName ==='Plan__c';
	}

	connectedCallback(){
		saveButtonType({
			idRecord: this.recordId
		}).then(intResult => {
			this.boolHasRecords = intResult==1;
		});
	}

	/*
	 Method Name : displayIPUConsumptionGoalsModal
	 Description : This method displays the IPU Consumption Goals modal.
	 Parameters  : None
	 Return Type : None
	 */
	displayIPUConsumptionGoalsModal() {
		this.boolIsPoppedOut = false;
		this.boolDisplayIPUConsumptionGoalsModal = true;
	}

	/*
	 Method Name : hideIPUConsumptionGoalsModal
	 Description : This method hides the IPU Consumption Goals modal.
	 Parameters  : Object, called from hideIPUConsumptionGoalsModal, objEvent Event.
	 Return Type : None
	 */
	hideIPUConsumptionGoalsModal(objEvent) {
		this.boolDisplayIPUConsumptionGoalsModal = false;

		//We update the Generate Risk component visibility.
		this.boolDisplayGenerateRiskModal = false;
	/*	if(objUtilities.isNotNull(objEvent) && objUtilities.isNotNull(objEvent.detail) && typeof objEvent.detail === "boolean") {
			this.boolDisplayGenerateRiskModal = objEvent.detail;
		} */
	}

	/*
	 Method Name : hideGenerateRiskModal
	 Description : This method hides the Generate Risk modal.
	 Parameters  : None
	 Return Type : None
	 */
	hideGenerateRiskModal() {
		this.boolDisplayGenerateRiskModal = false;
	}

	/*
	 Method Name : refreshTable
	 Description : This method refreshes the IPU Consumption Goals table.
	 Parameters  : None
	 Return Type : None
	 */
	refreshTable() {
		this.template.querySelector("c-csm-i-p-u-consumption-goals.readonly").loadRecords(true);
	}

	/*
	 Method Name : popInPopOut
	 Description : This method pops out or in the table.
	 Parameters  : None
	 Return Type : None
	 */
	popInPopOut() {
		this.boolIsPoppedOut = !this.boolIsPoppedOut;
	}

	/*
	 Method Name : displayConsumptionGoalsHistory
	 Description : This method opens the IPU Consumption Goals related list.
	 Parameters  : None
	 Return Type : None
	 */
	displayConsumptionGoalsHistory() {
		let objParent = this;

		//We get the account id.
		getAccountId({
			idRecord: objParent.recordId
		}).then(idAccount => {

			//Now we open the tab.
			objParent[NavigationMixin.Navigate]({
				type: "standard__recordRelationshipPage",
				attributes: {
					recordId: idAccount,
					objectApiName: "Account",
					relationshipApiName: "IPU_Consumption_Goals__r",
					actionName: "view"
				}
			});
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		});
	}
}