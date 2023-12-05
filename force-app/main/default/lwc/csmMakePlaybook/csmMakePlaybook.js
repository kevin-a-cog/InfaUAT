/*
 * Name			:	CsmMakePlaybook
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/17/2021
 * Description	:	Make Playbook controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/17/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import getFieldsToUpdate from "@salesforce/apex/CSMMakePlaybookController.getFieldsToUpdate";
import getRecordsUpdated from "@salesforce/apex/CSMMakePlaybookController.getRecordsUpdated";
import getPlanUpdated from "@salesforce/apex/CSMMakePlaybookController.getPlanUpdated";

//Custom Labels.
import Make_Plan_As_PlayBook_Step from '@salesforce/label/c.Make_Plan_As_PlayBook_Step';
import Next_Button from '@salesforce/label/c.Next_Button';
import Select_Records from '@salesforce/label/c.Select_Records';
import Back_Button from '@salesforce/label/c.Back_Button';
import Make_Playbook from '@salesforce/label/c.Make_Playbook';
import Save_Button from '@salesforce/label/c.Save_Button';
import No_Records_To_Save from '@salesforce/label/c.No_Records_To_Save';
import Warning from '@salesforce/label/c.Warning';

//Class body.
export default class CsmMakePlaybook extends NavigationMixin(LightningElement)  {

	//Private variables.
	boolDisplaySpinner;
	boolIsPlanStep;
	boolIsOMMStep;
	boolIsConfirmation;
	strRecordId;
	objPlanUpdates;
	objInitialParameters;
	objInitialParametersConfirm;
	lstUpdateFields;
	lstSelectedRecords;
	lstRequiredFields = [
		"Is_Template__c", 
		"Template_Name__c"
	];

	//Labels.
	label = {
		Make_Plan_As_PlayBook_Step,
		Next_Button,
		Select_Records,
		Back_Button,
		Make_Playbook,
		Save_Button,
		No_Records_To_Save,
		Warning
	}

	/*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
		let boolIsRequired;
		let strField;
		let objParent = this;
		this.boolIsPlanStep = true;
		this.boolDisplaySpinner = true;

		//First we get the current record id.
		window.location.href.match(/(Plan__c[A-Z//])\w+/g).forEach((objElement => {
			objParent.strRecordId = objElement.split("/")[1];
		}));

		//We prepare the plan object to be updated later.
		this.objPlanUpdates = new Object();
		this.objPlanUpdates.Id = this.strRecordId;

		//First we get the filter fields.
		getFieldsToUpdate({
			strRecordId: objParent.strRecordId
		}).then((lstResult) => {

			//We assign the list of fields.
			objParent.lstUpdateFields = new Array();
			Object.entries(lstResult).map(objField => {
				strField = objField[0];
				boolIsRequired = false;
				if(objParent.lstRequiredFields.includes(strField)) {
					boolIsRequired = true;
				}
				objParent.lstUpdateFields.push({
					strField: strField,
					boolIsRequired: boolIsRequired,
					value: objField[1]
				});
			});

			//Now we prepare the Nested Viewer data.
			objParent.objInitialParameters = {
				boolIsOpen: true,
				boolDisplayCheckbox: true,
				intType: 1,
				strRecordId: objParent.strRecordId,
				strObjectAPIName: "Objective__c",
				strFieldAPIName: "Plan__c",
				strLabelAPIName: "Name",
				strHeaderLabel: "Objective",
				lstChildSections: [
					{
						boolIsOpen: true,
						boolDisplayCheckbox: true,
						intType: 1,
						strObjectAPIName: "Milestone__c",
						strFieldAPIName: "Objective__c",
						strLabelAPIName: "Name",
						strHeaderLabel: "Milestone",
						lstChildSections: [
							{
								boolIsOpen: true,
								boolDisplayCheckbox: true,
								intType: 1,
								strObjectAPIName: "Engagement__c",
								strFieldAPIName: "Milestone__c",
								strLabelAPIName: "Name",
								strHeaderLabel: "Engagement"
							},
							{
								boolIsOpen: true,
								boolDisplayCheckbox: true,
								intType: 1,
								strObjectAPIName: "Task",
								strFieldAPIName: "WhatId",
								strLabelAPIName: "Subject",
								strHeaderLabel: "Task"
							}
						]
					}
				]
			}
			objParent.objInitialParametersConfirm = {
				boolIsOpen: true,
				boolDisplayCheckbox: false,
				intType: 1,
				strRecordId: objParent.strRecordId,
				strObjectAPIName: "Objective__c",
				strFieldAPIName: "Plan__c",
				strLabelAPIName: "Name",
				strHeaderLabel: "Objective",
				lstChildSections: [
					{
						boolIsOpen: true,
						boolDisplayCheckbox: false,
						intType: 1,
						strObjectAPIName: "Milestone__c",
						strFieldAPIName: "Objective__c",
						strLabelAPIName: "Name",
						strHeaderLabel: "Milestone",
						lstChildSections: [
							{
								boolIsOpen: true,
								boolDisplayCheckbox: false,
								intType: 1,
								strObjectAPIName: "Engagement__c",
								strFieldAPIName: "Milestone__c",
								strLabelAPIName: "Name",
								strHeaderLabel: "Engagement"
							},
							{
								boolIsOpen: true,
								boolDisplayCheckbox: false,
								intType: 1,
								strObjectAPIName: "Task",
								strFieldAPIName: "WhatId",
								strLabelAPIName: "Subject",
								strHeaderLabel: "Task"
							}
						]
					}
				]
			}
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		}).finally(() => {

			//Finally, we hide the spinner.
			objParent.boolDisplaySpinner = false;
		});
	}

	/*
	 Method Name : executeAction
	 Description : This method executes the corresponding action requested by the Data Tables components.
	 Parameters	 : Object, called from executeAction, objEvent Select event.
	 Return Type : None
	 */
	executeAction(objEvent) {
        const { intAction, objPayload } = objEvent.detail;

		//First, we check which event we need to execute.
		switch(intAction) {
			case 1:
				
				//The user has selected records.
				this.selectRecords(objPayload);
			break;
		}
    }

    /*
	 Method Name : selectRecords
	 Description : This method selects records from the table.
	 Parameters	 : Object, called from selectRecords, objEvent Select event.
	 Return Type : None
	 */
    selectRecords(objEvent) {
		this.lstSelectedRecords = objEvent.detail.selectedRows;
    }

	/*
	 Method Name : moveToOMMSelection
	 Description : This method moves the user to the OMM selection step.
	 Parameters	 : None
	 Return Type : None
	 */
	moveToOMMSelection() {
		let boolShouldContinue = true;

		//First we collect the field updates.
		this.collectPlanData();

		//Now we check required fields.
		this.template.querySelectorAll('lightning-input-field').forEach(objField => {
			if(boolShouldContinue) {
				boolShouldContinue = objField.reportValidity();
			}
        });

		//Now we change the UI.
		if(boolShouldContinue) {
			this.boolIsPlanStep = false;
			this.boolIsOMMStep = true;
		}
	}

	/*
	 Method Name : moveToPlanConfirmation
	 Description : This method moves the user to the Plan confirmation step.
	 Parameters	 : None
	 Return Type : None
	 */
	moveToPlanConfirmation() {

		//Now we get the data from the Selector Nested Viewer.
		this.objInitialParametersConfirm.lstResults = this.template.querySelector(".nestedViewerOMM").getSelectedComponents();

		//Only if we have at least one selection, we move to the next stage.
		if(this.objInitialParametersConfirm.lstResults.length > 0) {
			this.boolIsOMMStep = false;
			this.boolIsConfirmation = true;
		}
	}

	/*
	 Method Name : moveBackToOMMSelection
	 Description : This method moves the user to the OMM selection step.
	 Parameters	 : None
	 Return Type : None
	 */
	moveBackToOMMSelection() {
		this.boolIsOMMStep = true;
		this.boolIsConfirmation = false;
	}

	/*
	 Method Name : moveBackToPlanSelection
	 Description : This method moves the user back to the Plan selection step.
	 Parameters	 : None
	 Return Type : None
	 */
	moveBackToPlanSelection() {
		this.boolIsPlanStep = true;
		this.boolIsOMMStep = false;
	}

	/*
	 Method Name : saveAndCloseClickAction
	 Description : This method saves the user selection and closed the modal.
	 Parameters	 : None
	 Return Type : None
	 */
	saveAndCloseClickAction() {
		let objParent = this;
		let lstSelectedIds = this.template.querySelector(".nestedViewerConfirmation").getSelectedRecords();
		this.boolDisplaySpinner = true;

		//First we capture the selected Ids.
		if(objUtilities.isNotNull(lstSelectedIds)) {
			getPlanUpdated({
				objPlan: objParent.objPlanUpdates
			}).then(() => {
				return getRecordsUpdated({
					lstRecords: lstSelectedIds
				});
			}).then(() => {

				//Now we close the quick action.
				objParent[NavigationMixin.Navigate]({
					type:'standard__recordPage',
					attributes:{
						"recordId": objParent.strRecordId,
						"objectApiName":"Plan__c",
						"actionName": "view"
					}
				});
			}).catch((objError) => {
				objUtilities.processException(objError, objParent);
			});
		} else {
			objUtilities.showToast(this.label.Warning, this.label.No_Records_To_Save, "warning", this);
		}
	}

	/*
	 Method Name : collectPlanData
	 Description : This method collects the Plan updates.
	 Parameters	 : None
	 Return Type : None
	 */
	collectPlanData() {
		let objParent = this;
		
		//First we collect all the values.
		this.template.querySelectorAll(".filterField").forEach((objField) => {
			objParent.objPlanUpdates[objField.dataset.name] = objField.value;
		});
	}
	
}