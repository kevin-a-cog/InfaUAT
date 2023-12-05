/*
 * Name			:	csmIPUConsumptionGoals
 * Author		:	Monserrat Pedroza
 * Created Date	: 	3/15/2023
 * Description	:	This LWC displays the IPU Consumption Goals component.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		3/15/2023		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api } from 'lwc';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import getRecords from "@salesforce/apex/IPUConsumptionGoalsController.getRecords";
import saveRecords from "@salesforce/apex/IPUConsumptionGoalsController.saveRecords";
import getServicePicklistValues from "@salesforce/apex/IPUConsumptionGoalsController.getServicePicklistValues";
import getObjectives from "@salesforce/apex/IPUConsumptionGoalsController.getObjectives";
import getAccountId from "@salesforce/apex/IPUConsumptionGoalsController.getAccountNumber";

//Custom Labels.
import TitlePUConsumptionGoals from '@salesforce/label/c.TitlePUConsumptionGoals';
import CancelIPUConsumptionGoals from '@salesforce/label/c.CancelIPUConsumptionGoals';
import ActionsIPUConsumptionGoals from '@salesforce/label/c.ActionsIPUConsumptionGoals';
import SaveIPUConsumptionGoals from '@salesforce/label/c.SaveIPUConsumptionGoals';
import SaveAndForecastChurn from '@salesforce/label/c.SaveAndForecastChurn';
import Unique_ICGs from '@salesforce/label/c.Unique_ICGs';
import Remove_Service from '@salesforce/label/c.Remove_Service';
import Active_Tab from '@salesforce/label/c.Active_Tab';
import Inactive_Tab from '@salesforce/label/c.Inactive_Tab';
import Save_And_Update_Risk from '@salesforce/label/c.Save_And_Update_Risk';
import Comments_Required from '@salesforce/label/c.Comments_Required';
import Invalid_Objective from '@salesforce/label/c.Invalid_Objective';
import Cassini_Usage_Information from '@salesforce/label/c.Cassini_Usage_Information';
import Cassini_URL from '@salesforce/label/c.Cassini_URL';

//Class body.
export default class CsmIPUConsumptionGoals extends LightningElement {

	//API variables.
	@api recordId;
	@api boolIsReadOnly;
	@api showForecast;
	@api objectApiName;

	//Private variables.
	boolIsPoppedOut = false;
	boolDisplaySaveAndUpdateRiskButton = false;
	boolLocalIsReadOnly = false;
	boolDisplaySpinner;
	boolDisplayOverlaySpinner = false;
	boolDisplayCassiniURL = false;
	strCassiniURL = Cassini_URL;
	strCassiniStyle = "width: 100%; height: 500px;";
	strSaveLabel = SaveIPUConsumptionGoals;
	objNewRecord;
	objParametersActive = {
		boolEnableTreeView: true,
		boolIsTreeView: false,
		boolDisplayActions: false,
		boolDisplayPaginator: false,
		boolEnablePopOver: false,
		boolHideCheckboxColumn: true,
		strTableId: "1",
		lstCustomCSS: [{
			strSelector: ".datatable-height",
			strCSS: "padding: 15px;"
		}, {
			strSelector: "lightning-button-menu lightning-primitive-icon:last-of-type, lightning-combobox .slds-form-element__label",
			strCSS: "display: none;"
		}, {
			strSelector: "lightning-button-menu button.slds-button",
			strCSS: "border-width: 0px; background-color: transparent;"
		}, {
			strSelector: ".table-responsive",
			strCSS: "overflow-x: auto;"
		}, {
			strSelector: "c-global-custom-cell lightning-icon",
			strCSS: "padding-right: var(--lwc-spacingSmall,0.75rem);"
		}, {
			strSelector: "lightning-calendar div, lightning-base-combobox div.slds-listbox",
			strCSS: "z-index: 99999999999999999999 !important;"
		}, {
			strSelector: "lightning-combobox, lightning-record-edit-form",
			strCSS: "width: 100% !important;"
		}, {
			strSelector: "div.textarea-container",
			strCSS: "top: 3px;"
		}, {
			strSelector: "div.textarea-container textarea",
			strCSS: "height: 32px; padding-top: 5px;"
		}, {
			strSelector: "lightning-base-combobox span.slds-truncate, c-global-custom-cell div.slds-truncate",
			strCSS: "white-space: normal;"
		}, {
			strSelector: "c-global-custom-cell div.slds-truncate",
			strCSS: "white-space: normal; padding-right: 20px;"
		}]
	};
	objParametersInactive = {... this.objParametersActive };
	lstGoalAndActualValues = new Array();

	//Labels.
	label = {
		TitlePUConsumptionGoals: TitlePUConsumptionGoals,
		CancelIPUConsumptionGoals: CancelIPUConsumptionGoals,
		SaveIPUConsumptionGoals: SaveIPUConsumptionGoals,
		Active_Tab: Active_Tab,
		Inactive_Tab: Inactive_Tab,
		Save_And_Update_Risk: Save_And_Update_Risk,
		Cassini_Usage_Information: Cassini_Usage_Information
	};

	/*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
		let objParent = this;

		//We define the "Save" button label.
		if(objUtilities.isNotNull(objParent.showForecast) && objParent.showForecast) {
			objParent.strSaveLabel = SaveAndForecastChurn;
		}

		//We check the mode.
		if((objUtilities.isNotBlank(objParent.boolIsReadOnly) && objParent.boolIsReadOnly === "true") || (objUtilities.isNotNull(objParent.boolIsReadOnly) && objParent.boolIsReadOnly === true)) {
			objParent.boolLocalIsReadOnly = true;
		} else {
			objParent.objParametersActive.lstCustomCSS.push({
				strSelector: ".slds-table th",
				strCSS: "position: sticky !important; top: -16px !important; z-index: 999999999;"
			});
			objParent.objParametersActive.lstCustomCSS.push({
				strSelector: ".slds-table",
				strCSS: "position: absolute !important;"
			});
		}

		//We load Cassini URL.
		getAccountId({
			idRecord: objParent.recordId
		}).then(idAccount => {
			
			//We prepare the data table.
			objParent.strCassiniURL += idAccount;
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		}).finally(() => {
			objParent.boolDisplayCassiniURL = this.objectApiName ==='Plan__c';
		});

		//Now we load the list of records.
		objParent.loadRecords();
	}

	/*
	 Method Name : loadRecords
	 Description : This method loads the records on the corresponding table.
	 Parameters	 : None
	 Return Type : None
	 */
	@api
	loadRecords(refreshsummary) {
		let objTable;
		let objParent = this;
		let lstPromises = new Array();

		//We set the initial values.
		objParent.boolDisplaySpinner = true;

		//Now we fetch the data - Active records.
		lstPromises.push(new Promise((resolve) => {
			getRecords({
				boolIsReadOnly: objParent.boolIsReadOnly,
				boolGetActiveIPUConsumptionGoals: true,
				idRecord: objParent.recordId
			}).then(objResult => {
				
				//We prepare the data table.
				objParent.objParametersActive.lstColumns = new Array();
				objParent.objParametersActive.lstRecords = objResult.lstRecordsCustomStructure;
				objParent.objParametersActive.mapParentChildRelationship = objResult.mapParentChildRelationship;

				//We update the columns.
				if(objUtilities.isNotNull(objResult.lstColumns)) {
					objResult.lstColumns.forEach(objColumn => {
						if(objColumn.fieldName !== 'Comments__c') {
							objColumn = {
								... objColumn,
								objAdditionalAttributes: {
									boolPreventEnter: true
								}
							}
						}
						objParent.objParametersActive.lstColumns.push(objColumn);
					});
				}

				//We add the actions column.
				if(!objParent.boolLocalIsReadOnly) {
						objParent.objParametersActive.lstColumns.push({
						initialWidth: 70,
						label: ActionsIPUConsumptionGoals,
						fieldName: "lstActions",
						strFieldName: "lstActions",
						type: "custom",
						typeAttributes: {
							subtype: "icons"
						}
					});
				}
			}).catch((objError) => {
				objUtilities.processException(objError, objParent);
			}).finally(() => {
				resolve();
			});
		}));

		//Now we fetch the data - Inactive records.
		lstPromises.push(new Promise((resolve) => {
			getRecords({
				boolIsReadOnly: true,
				boolGetActiveIPUConsumptionGoals: false,
				idRecord: objParent.recordId
			}).then(objResult => {
				
				//We prepare the data table.
				objParent.objParametersInactive.lstColumns = objResult.lstColumns;
				objParent.objParametersInactive.lstRecords = objResult.lstRecordsCustomStructure;
				objParent.objParametersInactive.mapParentChildRelationship = objResult.mapParentChildRelationship;
			}).catch((objError) => {
				objUtilities.processException(objError, objParent);
			}).finally(() => {
				resolve();
			});
		}));
		
		//We wait for all the promises to inish.
		Promise.allSettled(lstPromises).finally(() => {
	
			//Finally, we hide the spinner.
			objParent.boolDisplaySpinner = false;
	
			//We expand all the rows.
			setTimeout(() => {
				objTable = objParent.template.querySelector("c-global-data-table[data-id='active']");
				if(objUtilities.isNotNull(objTable)) {
					objTable.toggleRows(true);
				}
				objTable = objParent.template.querySelector("c-global-data-table[data-id='inactive']");
				if(objUtilities.isNotNull(objTable)) {
					objTable.toggleRows(true);
				}
			}, 100);
		});

		if(refreshsummary){
			objTable = objParent.template.querySelector("c-csm-accountipu-summary");
				if(objUtilities.isNotNull(objTable)) {
					objTable.refresh();
				}
		}
	}

	/*
	 Method Name : executeAction
	 Description : This method executes the corresponding action requested by the Data Tables components.
	 Parameters	 : Object, called from executeAction, objEvent Select event.
	 Return Type : None
	 */
	executeAction(objEvent) {
		let { intAction, objAdditionalAttributes } = objEvent.detail.detail;
		let objParent = this;
		let objTable = objParent.template.querySelector("c-global-data-table[data-id='active']");
		let lstRecords;
		let lstExcludedPicklistValues = new Array();
		let lstPicklistValues = new Array();

		//First, we check which event we need to execute.
		switch(parseInt(intAction)) {
			case 1:

				//Add new row.
				objParent.boolDisplayOverlaySpinner = true;
				getServicePicklistValues({
					idRecord: objParent.recordId
				}).then(lstResults => {

					//We get the selections of the other new rows under the same Org.
					lstRecords = objTable.getNewRecords();
					if(objUtilities.isNotNull(lstRecords) && lstRecords.length > 0) {
						lstRecords.forEach(objInnerRecord => {
							if(objUtilities.isNotBlank(objInnerRecord.Service__c)) {
								lstExcludedPicklistValues.push(objInnerRecord.Service__c);
							}
						});
					}

					//We iterate over the rows.
					lstResults.forEach(objValue => {
						if(!lstExcludedPicklistValues.includes(objValue.value)) {
							lstPicklistValues.push(objValue);
						}
					});

					//Now we add the row.
					return getObjectives({
						idRecord: objParent.recordId,
					});
				}).then(lstResults => {
						objTable.addRow({
							boolHasItsOwnStructure: false,
							boolIsVisible: true,
							intRecordLayoutType: 1,
							objColumn: {
								objAdditionalAttributes: {
									boolBehaveAsNewRecord: true,
									boolIsRequired: true
								}
							},
							lstActions: [{
								boolHasSubactions: false,
								intAction: 2,
								strIcon: "action:delete",
								strHelpText: Remove_Service
							}],
							lstOverridenValues: [{
								strRecordObjectAPIName: "IPU_Consumption_Goal__c",
								strRecordFieldAPIName: "Name",
								strNewRecordFieldAPIName: "Service__c",
								objAdditionalAttributes: {
									boolIsRequired: false,
									intFieldType: 1,
									lstPicklistOptions: lstPicklistValues
								}
							}, {
								strRecordObjectAPIName: "IPU_Consumption_Goal__c",
							strRecordFieldAPIName: "Objective_Name__c",
							objAdditionalAttributes: {
								boolIsRequired: false,
								intFieldType: 1,
								lstPicklistOptions: lstResults
							}
						}, {
							strRecordObjectAPIName: "IPU_Consumption_Goal__c",
							strRecordFieldAPIName: "Expected_Goal__c",
								objAdditionalAttributes: {
									boolPreventEnter: true,
									boolIsRequired: false
								}
							}, {
								strRecordObjectAPIName: "IPU_Consumption_Goal__c",
							strRecordFieldAPIName: "Expected_Date__c",
								objAdditionalAttributes: {
									boolPreventEnter: true,
									boolIsRequired: false
								}
							}, {
								strRecordObjectAPIName: "IPU_Consumption_Goal__c",
							strRecordFieldAPIName: "Comments__c",
								objAdditionalAttributes: {
									boolIsRequired: false
								}
							}]
						});
				}).catch((objError) => {
					objUtilities.processException(objError, objParent);
				}).finally(() => {
					objParent.boolDisplayOverlaySpinner = false;
				});
			break;
			case 2:

				//Delete new row.
				objTable.removeRow(objAdditionalAttributes.intPosition);
			break;
		}
    }

	/*
	 Method Name : createRecord
	 Description : This method creates the new ICF record.
	 Parameters  : Object, called from createRecord, objEvent Event.
	 Return Type : None
	 */
	createRecord(objEvent) {
		let boolCheckPastDate;
		let dblActualUsage;
		let dblExpectedGoal;
		let strField;
		let strButtonType = objEvent.target.getAttribute("data-type");
		let objCustomError;
		let objProcessedRecord;
		let objParent = this;
		let objTable = objParent.template.querySelector("c-global-data-table[data-id='active']");
		let lstRecords = new Array();
		let lstModifiedIdentifiers = new Array();
		let lstProcessingRecords;
		let lstCellsValues;

		//We validate the fields.
		if(objTable.validateAllRowsAllFields()) {

			//We remove any errors.
			objTable.clearAllErrors();

			//We get the values.
			lstProcessingRecords = [
				... objTable.getNewRecords(),
				... objTable.getUpdatedRecords()
			];

			//We adjust the fields.
			lstProcessingRecords.forEach(objRecord => {
				if(objUtilities.isNotBlank(objRecord.Id)) {
					lstModifiedIdentifiers.push(objRecord.Id);
				}
				if(objUtilities.isNotNull(objRecord.intRowNumber)) {
					lstModifiedIdentifiers.push(objRecord.intRowNumber);
				}
				objProcessedRecord = new Object();
				Object.entries(objRecord).forEach(objInnerRecord => {
					if(objUtilities.isNotNull(objInnerRecord[1])) {
						if(objInnerRecord[0] === "Objective_Name__c") {
							if(objUtilities.isObject(objInnerRecord[1])) {
								objProcessedRecord["Objective_Id__c"] = objInnerRecord[1].value;
							} else {
								objProcessedRecord["Objective_Id__c"] = objInnerRecord[1];
							}
							if(objUtilities.isBlank(objProcessedRecord["Objective_Id__c"])) {
								delete objProcessedRecord["Objective_Id__c"];
							}
						} else if(objInnerRecord[0] === "Service__c") {
							if(objUtilities.isObject(objInnerRecord[1])) {
								objProcessedRecord["Service__c"] = objInnerRecord[1].value;
							} else {
								objProcessedRecord["Service__c"] = objInnerRecord[1];
							}
						} else if(!objInnerRecord[0].includes(" ") && !objUtilities.isObject(objInnerRecord[1])) {
							objProcessedRecord[objInnerRecord[0]] = objInnerRecord[1];
						}
					}
					if(objUtilities.isNotNull(objRecord["Estimated IPUs"])) {
						objProcessedRecord.Estimated_IPUs__c = objRecord["Estimated IPUs"];
					}
					if(objUtilities.isNotNull(objRecord["Last Billing Cycle Usage"]) && objUtilities.isNotNull(objRecord["Last Billing Cycle Usage"][0])) {
						if(objUtilities.isNotBlank(objRecord["Last Billing Cycle Usage"][0].strLabel)) {
							objProcessedRecord.Actual_Usage__c = parseFloat(objRecord["Last Billing Cycle Usage"][0].strLabel);
						}
						if(objUtilities.isNotBlank(objRecord["Last Billing Cycle Usage"][0].strHelpText)) {
							objProcessedRecord.Actual_Usage_Trend__c = parseFloat(objRecord["Last Billing Cycle Usage"][0].strHelpText);
						}
					}
				});
				lstRecords.push(objProcessedRecord);
			});

			//If we have records to save.
			if(objUtilities.isNotNull(lstRecords) && lstRecords.length > 0) {
				objParent.boolDisplayOverlaySpinner = true;

				//We insert the records.
				saveRecords({
					idRecord: objParent.recordId,
					lstRecords: lstRecords
				}).then(() => {

					//We indicate the parent we need to refresh the read-only table.
					objParent.dispatchEvent(new CustomEvent('refresh', {
						composed: true,
						bubbles: true,
						cancelable: true
					}));

					//We update the Generate Risk Component.
					if(strButtonType === "saveandrisk") {

						//We open the Generate Risk component.
						objParent.closeModal(true);
					} else {
						objParent.closeModal(false);
					
					}
				}).catch((objError) => {
					objCustomError = {
						body: {
							pageErrors: [
								{
									statusCode: "Error"
								}
							]
						}
					};

					//We check the type of error.
					if(objUtilities.isNotNull(objError) && objUtilities.isNotNull(objError.body) && objUtilities.isNotNull(objError.body.pageErrors) && 
							objUtilities.isNotNull(objError.body.pageErrors[0]) && objUtilities.isNotBlank(objError.body.pageErrors[0].statusCode)) {
						switch(objError.body.pageErrors[0].statusCode) {
							case "DUPLICATE_VALUE":
								objCustomError.body.pageErrors[0].message = Unique_ICGs;
							break;
							case "FIELD_CUSTOM_VALIDATION_EXCEPTION":
								boolCheckPastDate = false;
								objCustomError.body.pageErrors[0].message = objError.body.pageErrors[0].message;

								//We obtain all the cell values.
								lstCellsValues = objTable.getAllCellsValues();

								//Now we look for the related fields.
								switch(objError.body.pageErrors[0].message) {
									case "Expected Date field is required.":
										strField = "Expected_Date__c";
									break;
									case "You need to provide an Expected Goal.":
										strField = "Expected_Goal__c";
									break;
									case "You need to provide an Service Name.":
										strField = "Service__c";
									break;
									case "Expected Date must be a today or a future date.":
										strField = "Expected_Date__c";
										boolCheckPastDate = true;
									break;
								}

								//Now we set the errors.
								lstCellsValues.forEach(objCell => {
									if((lstModifiedIdentifiers.includes(parseInt(objCell.intRowNumber)) || lstModifiedIdentifiers.includes(objCell.intRowNumber) || 
											lstModifiedIdentifiers.includes(objCell.strRowId)) && objCell.strFieldAPIName === strField) {
										if((boolCheckPastDate && new Date(objCell.objValue) < new Date()) || objUtilities.isBlank(objCell.objValue)) {
											objTable.setFieldError(objCell.intRowNumber, objCell.strRowId, objCell.strFieldAPIName, true);
										}
									}
								});
							break;
							default:
								objCustomError.body.pageErrors[0].message = objError.body.pageErrors[0].message;
							break;
						}
						objUtilities.processException(objCustomError, objParent);
					} else {
						objCustomError.body.message = objError.body.message;

						//We highlight the fields.
						if(objUtilities.isNotNull(objError) && objUtilities.isNotNull(objError.body) && objUtilities.isNotBlank(objError.body.message)) {

							//We obtain all the cell values.
							lstCellsValues = objTable.getAllCellsValues();

							//Now we look for the related fields.
							switch(objError.body.message) {
								case Comments_Required:

									//Now we set the errors.
									lstCellsValues.forEach(objCell => {
										if(objCell.strFieldAPIName === "Comments__c" && objUtilities.isBlank(objCell.objValue)) {
											dblActualUsage = objTable.getFieldValue(objCell.intRowNumber, objCell.strRowId, "Last Billing Cycle Usage");
											if(objUtilities.isNotNull(dblActualUsage) && objUtilities.isNotNull(dblActualUsage[0]) && objUtilities.isNotNull(dblActualUsage[0].strLabel)) {
												dblActualUsage = parseFloat(dblActualUsage[0].strLabel);
											} else {
												dblActualUsage = null;
											}
											dblExpectedGoal = objTable.getFieldValue(objCell.intRowNumber, objCell.strRowId, "Expected_Goal__c");
											if(objUtilities.isNotBlank(dblExpectedGoal)) {
												dblExpectedGoal = parseFloat(dblExpectedGoal);
											} else {
												dblExpectedGoal = null;
											}
											if(dblActualUsage !== null && dblExpectedGoal !== null && dblActualUsage > dblExpectedGoal) {
												objTable.setFieldError(objCell.intRowNumber, objCell.strRowId, objCell.strFieldAPIName, true);
											}
										}
									});
								break;
								default:
								case Invalid_Objective:

									//Invalid Objective.
									if(objError.body.message.startsWith(Invalid_Objective)) {
										objTable.setFieldError(null, objError.body.message.split("|||")[1], "Objective_Name__c", true);
										objCustomError.body.message = Invalid_Objective;
									}
								break;
							}
						}

						//Now we show the error toast.
						objUtilities.processException(objCustomError, objParent);
					}
				}).finally(() => {
					objParent.boolDisplayOverlaySpinner = false;
				});
			} else {

				//We close the modal.
				objParent.closeModal(false);
			}
		}
	}

	/*
	 Method Name : closeModal
	 Description : This method sends the request to the parent to close the modal.
	 Parameters  : Object, called from closeModal, objEvent Event.
	 Return Type : None
	 */
	closeModal(objEvent) {
		this.dispatchEvent(new CustomEvent('close', {
			composed: true,
			bubbles: true,
			cancelable: true,
			detail: objEvent
		}));
	}

	/*
	 Method Name : moveToNextField
	 Description : This method focuses the next field, if a Enter key was pressed.
	 Parameters  : Object, called from moveToNextField, objEvent Event.
	 Return Type : None
	 */
	moveToNextField(objEvent) {
		let {intKeyCode, intPosition, strFieldAPIName, strRowId} = objEvent.detail.detail;
		let strNewFieldAPIName;
		if(intKeyCode === 13) {
			this.template.querySelectorAll("c-global-data-table[data-id='active']").forEach(objTable => {
				switch(strFieldAPIName) {
					case "Name":
						strNewFieldAPIName = "Expected_Goal__c";
					break;
					case "Expected_Goal__c":
						strNewFieldAPIName = "Expected_Date__c";
					break;
					case "Expected_Date__c":
						strNewFieldAPIName = "Comments__c";
					break;
				}
				if(objUtilities.isNotBlank(strNewFieldAPIName)) {
					objTable.focusRecordField(intPosition, strRowId, strNewFieldAPIName);
				}
			});
		}
	}

	/*
	 Method Name : cellChanged
	 Description : This method recieves a changed cell.
	 Parameters  : Object, called from cellChanged, objEvent Event.
	 Return Type : None
	 */
	cellChanged(objEvent) {
		let boolRecordFound = false;
		let { intPosition, strRowId } = objEvent.detail.detail;
		let objParent = this;

		//We execute the field-specific validations.
		objParent.template.querySelectorAll("c-global-data-table[data-id='active']").forEach(objTable => {

			//Now we check the logic to display the "Save & Update Risk" button.
			objParent.boolDisplaySaveAndUpdateRiskButton = false;
			objParent.lstGoalAndActualValues.forEach(objRecord => {
				if(objRecord.Id === strRowId) {
					boolRecordFound = true;
					objRecord.Expected_Goal__c = objTable.getFieldValue(intPosition, strRowId, "Expected_Goal__c");
				}
			});
			if(!boolRecordFound && objUtilities.isNotBlank(strRowId)) {
				objParent.lstGoalAndActualValues.push({
					Id: strRowId,
					Expected_Goal__c: objTable.getFieldValue(intPosition, strRowId, "Expected_Goal__c")
				});
			}
			objParent.lstGoalAndActualValues.forEach(objRecord => {
				objParent.objParametersActive.lstRecords.forEach(objInnerRecord => {
					if(objRecord.Id === objInnerRecord.Id && objUtilities.isNotBlank(objRecord.Expected_Goal__c) && objUtilities.isNotNull(objInnerRecord["Last Billing Cycle Usage"]) && 
							objUtilities.isNotNull(objInnerRecord["Last Billing Cycle Usage"][0]) && objUtilities.isNotBlank(objInnerRecord["Last Billing Cycle Usage"][0].strLabel)) {
						if(parseFloat(objRecord.Expected_Goal__c) < parseFloat(objInnerRecord["Last Billing Cycle Usage"][0].strLabel)) {
							objParent.boolDisplaySaveAndUpdateRiskButton = true;
						}
					}
				});
			});
		});
	}

	/*
	 Method Name : setActiveTab
	 Description : This method receives the current active tab.
	 Parameters  : Object, called from setActiveTab, objEvent Event.
	 Return Type : None
	 */
	setActiveTab(objEvent) {
		let strDataTable = objEvent.target.value;
		let objTable;
		let objParent = this;
		setTimeout(() => {
			objTable = objParent.template.querySelector("c-global-data-table[data-id='" + strDataTable + "']");
			if(objUtilities.isNotNull(objTable)) {
				objTable.toggleRows(true);
				objTable.startInlineEditingAllCells();
			}
		}, 100);
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
	 Method Name : newRecord
	 Description : This method adds a new record.
	 Parameters  : None
	 Return Type : None
	 */
	newRecord() {
		this.executeAction({
			detail: {
				detail: {
					intAction: 1
				}
			}
		});
	}
}