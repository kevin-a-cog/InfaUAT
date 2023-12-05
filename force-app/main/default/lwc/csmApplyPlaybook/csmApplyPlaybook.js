/*
 * Name			:	CsmApplyPlaybook
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/17/2021
 * Description	:	Apply Playbook controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/17/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import getRecords from "@salesforce/apex/CSMApplyPlaybookController.getRecords";
import getFilterFields from "@salesforce/apex/CSMApplyPlaybookController.getFilterFields";
import getSelectedRecordsCloned from "@salesforce/apex/CSMApplyPlaybookController.getSelectedRecordsCloned";

//Custom Labels.
import Make_Plan_As_PlayBook_Step from '@salesforce/label/c.Make_Plan_As_PlayBook_Step';
import Search_Plans_Placeholder from '@salesforce/label/c.Search_Plans_Placeholder';
import Next_Button from '@salesforce/label/c.Next_Button';
import Select_Records from '@salesforce/label/c.Select_Records';
import Back_Button from '@salesforce/label/c.Back_Button';
import Make_Playbook from '@salesforce/label/c.Make_Playbook';
import Save_Button from '@salesforce/label/c.Save_Button';
import Select_One_Record from '@salesforce/label/c.Select_One_Record';
import Warning from '@salesforce/label/c.Warning';
import Select_Plan from '@salesforce/label/c.Select_Plan';
import Apply_Playbook from '@salesforce/label/c.Apply_Playbook';

//Class body.
export default class CsmApplyPlaybook extends NavigationMixin(LightningElement)  {

	//API variables.
	@api recordId;
	@api strPreSelectedObjective;
	@api strPreSelectedMilestone;

	//Private variables.
	boolRenderSearchField = false;
	boolDisplaySpinner;
	boolIsPlanStep;
	boolIsOMMStep;
	boolIsConfirmation;
	boolAreObjectivesDisabled = false;
	boolAreMilestonesDisabled = false;
	strRecordId;
	objPlanUpdates;
	objInitialParameters;
	objInitialParametersConfirm;
	lstUpdateFields;
	lstSelectedRecords;

	//Labels.
	label = {
		Make_Plan_As_PlayBook_Step,
		Search_Plans_Placeholder,
		Next_Button,
		Select_Records,
		Back_Button,
		Make_Playbook,
		Save_Button,
		Select_One_Record,
		Warning,
		Select_Plan,
		Apply_Playbook
	}

	/*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
		let strLabel;
		let strAlternateAPIName;
		let objParent = this;
		this.boolIsPlanStep = true;
		this.boolDisplaySpinner = true;

		//First we get the current record id.
		if(objUtilities.isNull(this.recordId)) {
			window.location.href.match(/(Plan__c[A-Z//])\w+/g).forEach((objElement => {
				objParent.strRecordId = objElement.split("/")[1];
			}));
		} else {
			objParent.strRecordId = objParent.recordId;
		}

		//Now we disable the checkboxes, if we received preselected values.
		if(objUtilities.isNotBlank(this.strPreSelectedObjective)) {
			this.boolAreObjectivesDisabled = true;
		}
		if(objUtilities.isNotBlank(this.strPreSelectedMilestone)) {
			this.boolAreMilestonesDisabled = true;
		}

		//Now we get the filter fields.
		getFilterFields().then((lstResult) => {
			objParent.lstFilterFields = new Array();

			//We assign the list of fields.
			Object.entries(lstResult).map(objField => {
				switch(objField[0]) {
					case "Template_Name__c":
						strAlternateAPIName = "Template_Name__c";
						strLabel = "Template Name"
					break;
					case "Template_Creator__c":
						strAlternateAPIName = "Template_Creator__r.Name";
						strLabel = "Template Creator"
					break;
					case "Journey__c":
						strAlternateAPIName = "Journey__c";
						strLabel = "Journey"
					break;
				}
				objParent.lstFilterFields.push({
					strAPIName: objField[0],
					strLabel: strLabel,
					strAlternateAPIName: strAlternateAPIName
				});
			});

			//Now we get the plan records.
			return getRecords();
		}).then((objResult) => {

			//We build the Plan table.
			objParent.objPlanTable = new Object();
			objParent.objPlanTable.boolEnablePopOver = false;
			objParent.objPlanTable.boolDisplayActions = false;
			objParent.objPlanTable.boolDisplayPaginator = false;
			objParent.objPlanTable.intMaximumRowSelection = 1;
			objParent.objPlanTable.lstRecords = objResult.lstRecords;
			objParent.objPlanTable.lstColumns = objResult.lstColumns;
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
	 Method Name : movetoOMMSelection
	 Description : This method moves the user to the OMM selection step.
	 Parameters	 : None
	 Return Type : None
	 */
	movetoOMMSelection() {

		//First we check that we have selected a record.
		if(objUtilities.isNotNull(this.lstSelectedRecords) && this.lstSelectedRecords.length > 0) {
			this.boolIsPlanStep = false;
			this.boolIsOMMStep = true;

			//Now we prepare the Nested Viewer data.
			this.objInitialParameters = {
				boolIsOpen: true,
				boolDisplayCheckbox: true,
				boolIsCheckboxDisabled: this.boolAreObjectivesDisabled,
				intType: 1,
				strRecordId: this.lstSelectedRecords[0].Id,
				strObjectAPIName: "Objective__c",
				strFieldAPIName: "Plan__c",
				strLabelAPIName: "Name",
				strHeaderLabel: "Objective",
				lstChildSections: [
					{
						boolIsOpen: true,
						boolDisplayCheckbox: true,
						boolIsCheckboxDisabled: this.boolAreMilestonesDisabled,
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
								strHeaderLabel: "Engagement",
								lstAdditionalFilters: [
									"Is_Template__c = TRUE"
								]
							},
							{
								boolIsOpen: true,
								boolDisplayCheckbox: true,
								intType: 1,
								strObjectAPIName: "Task",
								strFieldAPIName: "WhatId",
								strLabelAPIName: "Subject",
								strHeaderLabel: "Task",
								lstAdditionalFilters: [
									"Is_Template__c = TRUE"
								]
							}
						],
						lstAdditionalFilters: [
							"Is_Template__c = TRUE"
						]
					}
				],
				lstAdditionalFilters: [
					"Is_Template__c = TRUE"
				]
			}
			this.objInitialParametersConfirm = {
				boolIsOpen: true,
				boolDisplayCheckbox: false,
				intType: 1,
				strRecordId: this.lstSelectedRecords[0].Id,
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
								strHeaderLabel: "Engagement",
								lstAdditionalFilters: [
									"Is_Template__c = TRUE"
								]
							},
							{
								boolIsOpen: true,
								boolDisplayCheckbox: false,
								intType: 1,
								strObjectAPIName: "Task",
								strFieldAPIName: "WhatId",
								strLabelAPIName: "Subject",
								strHeaderLabel: "Task",
								lstAdditionalFilters: [
									"Is_Template__c = TRUE"
								]
							}
						],
						lstAdditionalFilters: [
							"Is_Template__c = TRUE"
						]
					}
				],
				lstAdditionalFilters: [
					"Is_Template__c = TRUE"
				]
			}
		} else {
			objUtilities.showToast(this.label.Warning, this.label.Select_One_Record, "warning", this);
		}
	}

	/*
	 Method Name : moveToPlanConfirmation
	 Description : This method moves the user to the Plan confirmation step.
	 Parameters	 : None
	 Return Type : None
	 */
	moveToPlanConfirmation() {
		let strCSS = "";
		let strComponentName = "c-csm-apply-playbook";
		let objParent = this;

		//Now we get the data from the Selector Nested Viewer.
		this.objInitialParametersConfirm.lstResults = this.template.querySelector(".nestedViewerOMM").getSelectedComponents();

		//Only if we have at least one selection, we move to the next stage.
		if(this.objInitialParametersConfirm.lstResults.length > 0) {
			this.boolIsOMMStep = false;
			this.boolIsConfirmation = true;
		}

		//Now we hide the unnecessary objectives.
		this.template.querySelectorAll('.customGeneralCSS').forEach(objElement => {
			if(objUtilities.isNotNull(this.objInitialParametersConfirm.lstResults)) {
				this.objInitialParametersConfirm.lstResults.forEach(objResult => {
					if(objUtilities.isNotNull(objResult.objRequest) && objUtilities.isNotNull(objResult.objRequest.strMainFilterFieldAPIName)) {

						//If we need to hide objectives.
						if((objResult.objRequest.strMainFilterFieldAPIName === "Objective__c" && objUtilities.isNotBlank(objParent.strPreSelectedObjective)) || 
								(objResult.objRequest.strMainFilterFieldAPIName === "Milestone__c" && objUtilities.isNotBlank(objParent.strPreSelectedMilestone))) {
							strCSS += strComponentName + " [data-accordion-id='" + objResult.objRequest.strRecordId + "'] > section > div.slds-accordion__summary:first-child {" + 
							"	display: none;" + 
							"}";
							strCSS += strComponentName + " [data-accordion-id='" + objResult.objRequest.strRecordId + "'] > section:first-child {" + 
							"	padding-top: 0px;" + 
							"}";
						}
					}
				});
			}

			//Now we add the style.
			objElement.innerHTML = "<style> " + strCSS + " </style>";
		});
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
		this.template.querySelectorAll('.customGeneralCSS').forEach(objElement => {
			objElement.innerHTML = "<style></style>";
		});
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
		let lstBuckets = new Array();
		let mapBuckets = this.template.querySelector(".nestedViewerConfirmation").getBuckets();
		this.boolDisplaySpinner = true;

		//First we capture the selected Ids.
		if(objUtilities.isNotNull(mapBuckets)) {

			//Now we convert the map into a readable object.
			for(let [strObjectName, lstRecordIds] of mapBuckets) {
				lstBuckets.push({
					intOrder: objParent.getOrder(null, strObjectName, objParent.objInitialParametersConfirm),
					strObjectName: strObjectName,
					strPreSelectedObjectiveId: objParent.strPreSelectedObjective,
					strPreSelectedMilestoneId: objParent.strPreSelectedMilestone,
					lstRecordIds: lstRecordIds
				});
			}

			//Now we clone the records.
			getSelectedRecordsCloned({
				strParentRecordId: objParent.strRecordId,
				lstBuckets: lstBuckets
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

				//We also send a message to the container (if any), indicating it should close itself.
				objParent.dispatchEvent(new CustomEvent('close', {
					composed: true,
					bubbles: false,
					cancelable: true,
					detail: null
				}));
			}).catch((objError) => {
				objUtilities.processException(objError, objParent);
				objParent.boolDisplaySpinner = false;
			});
		} else {
			objUtilities.showToast(this.label.Warning, this.label.No_Records_To_Save, "warning", this);
		}
	}

	/*
	 Method Name : getOrder
	 Description : This method returns the hierarchy order of a nested object.
	 Parameters	 : Integer, called from getOrder, intOrder Order.
	 			   String, called from getOrder, strObjectName Object Name.
				   Object, called from getOrder, objInitialParametersConfirm Hierarchy parameters.
	 Return Type : Integer
	 */
	getOrder(intOrder, strObjectName, objInitialParametersConfirm) {
		if(objUtilities.isNull(intOrder)) {
			intOrder = 0;
		}
		intOrder++;
		if(objInitialParametersConfirm.strObjectAPIName !== strObjectName) {
			if(objUtilities.isNotNull(objInitialParametersConfirm.objChild)) {
				intOrder = this.getOrder(intOrder, strObjectName, objInitialParametersConfirm.objChild);
			} else {
				intOrder = 0;
			}
		}
		return intOrder;
	}

	/*
	 Method Name : applyFilter
	 Description : This method applies filters to the Plan's table.
	 Parameters	 : None
	 Return Type : None
	 */
	applyFilter() {
		let objFilter;
		let lstFilters = new Array();
		
		//First we collect all the values.
		this.template.querySelectorAll(".filterField").forEach((objField) => {
			objFilter = new Object();
			objFilter.strFieldName = objField.dataset.name;
			objFilter.strValue = objField.value;
			objFilter.boolIsExactMatch = false;
			lstFilters.push(objFilter);
		});

		//Now we send the filters to the table.
		this.template.querySelector('.plansTable').filterFields(lstFilters);
	}	

	/*
	 Method Name : searchRecord
	 Description : This method searches for Plan Partner records based on a given keyword.
	 Parameters	 : Object, called from sortBy, objEvent Change event.
	 Return Type : None
	 */
	searchRecord(objEvent) {
		this.template.querySelector('.plansTable').searchRecord(objEvent);
	}
}