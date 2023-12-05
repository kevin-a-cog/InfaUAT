/*
 * Name			:	GlobalNestedDataViewer
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/16/2021
 * Description	:	Nested Data Viewer controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/16/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import strCustomStylesheet from '@salesforce/resourceUrl/globalNestedDataViewerStyles';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import getRecords from "@salesforce/apex/GlobalNestedDataViewerController.getRecords";

//Custom Labels.
import Loading from '@salesforce/label/c.Loading';

//Class body.
export default class GlobalNestedDataViewer extends LightningElement {

	//API variables.
	@api objInitialParameters;
	@api objParameters;
	@api strRecordId;

	//Private variables.
	boolCustomCSSLoaded = false;
	boolInitialLoad;
	boolIsTopParent;
	boolIsCheckboxDisabled;
	boolHasActionButtons;
	boolHasMultipleChilds;
	boolDisplaySpinner;
	boolDisplayCheckbox;
	boolDisplayTable = true;
	intHeaderPadding = 25;
	intNumberOfIteratios;
	objResult;
	objPanel;
	objTable;
	objParametersLocal;
	lstResults;
	lstActiveSections;
	lstSelectedRecords;
	lstObjects;
	lstCustomCSS = new Array();
	mapBuckets;

	//Label.
	label = {
		Loading
	}

	/*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
		let objParent = this;
		let objRequest;
		let objResult;
		this.boolInitialLoad = true;
		this.lstResults = new Array();
		this.mapBuckets = new Map();

		//If this is the first recursive iteration, we clone the data and load the style.
		if(objUtilities.isNotNull(this.objInitialParameters)) {
			loadStyle(this, strCustomStylesheet);
			this.boolIsTopParent = true;
			this.intNumberOfIteratios = 0;
			this.objParameters = {... this.objInitialParameters};
			if(objUtilities.isNotNull(this.objParameters)) {
				this.boolDisplaySpinner = true;
			}
		} else if(objUtilities.isNotNull(this.objParameters)) {

			//We start the active sections.
			this.lstActiveSections = new Array();

			//We indicate to the parent that we added an iteration.
			this.addIterationToParent();

			//If it is the second iteration, this is where we actually start the recursive checks.
			this.objParametersLocal = JSON.parse(JSON.stringify(this.objParameters));

			//If this is the first level, we set it in the data.
			if(objUtilities.isNull(this.objParametersLocal.intLevel)) {
				this.objParametersLocal.intLevel = 1;
			}

			//If the current UI element type is according, we apply the tab.
			if(this.objParametersLocal.intType === 1) {
				this.lstCustomCSS.push(".globalNestedDataViewer [data-level='" + this.objParametersLocal.intLevel + "'] h3.slds-accordion__summary-heading { padding-left: " + 
						(this.intHeaderPadding * this.objParametersLocal.intLevel) + "px; }");
			}

			//Now we check if we received one or multiple childs at the same time.
			if(objUtilities.isNull(this.objParametersLocal.lstChildSections)) {
				this.objParametersLocal.lstChildSections = new Array();
			}
			if(objUtilities.isNotNull(this.objParametersLocal.objChild)) {
				this.objParametersLocal.lstChildSections.push(this.objParametersLocal.objChild);
			}

			//Now we define if the panel contains action buttons.
			if(objUtilities.isNotNull(this.objParametersLocal.objButtons) && objUtilities.isNotNull(this.objParametersLocal.objButtons.lstButtons) && 
					this.objParametersLocal.objButtons.lstButtons.length > 0) {
				this.boolHasActionButtons = true;
			}

			//We include the default values to the list of fields to be queried.
			if(objUtilities.isNull(this.objParametersLocal.lstFields)) {
				this.objParametersLocal.lstFields = new Array();
			}
			this.objParametersLocal.lstFields.push(this.objParametersLocal.strLabelAPIName);

			//We include the Id field for Panels only.
			if(this.objParametersLocal.intType === 1) {
				this.objParametersLocal.lstFields.push("Id");
			}

			//Now we define if we need to display checkbox at the collapsible panel level.
			this.boolDisplayCheckbox = this.objParametersLocal.boolDisplayCheckbox;

			//Now we define if the checkbox needs to be disabled.
			this.boolIsCheckboxDisabled = this.objParametersLocal.boolIsCheckboxDisabled;

			//We set the custom record id, if present.
			if(objUtilities.isNotBlank(this.strRecordId)){
				this.objParametersLocal.strRecordId = this.strRecordId;
			}

			//Now we get the records of the current iteration.
			objRequest = {
				strRecordId: this.objParametersLocal.strRecordId,
				strObjectName: this.objParametersLocal.strObjectAPIName,
				strMainFilterFieldAPIName: this.objParametersLocal.strFieldAPIName,
				lstFieldNames: this.objParametersLocal.lstFields,
				lstAdditionalFilters: this.objParametersLocal.lstAdditionalFilters
			};
			if(typeof objRequest.lstAdditionalFilters === "undefined") {
				delete objRequest.lstAdditionalFilters;
			}

			//Now we set the results.
			if(objUtilities.isNotNull(this.objParametersLocal) && objUtilities.isNotNull(this.objParametersLocal.lstResults) && 
					this.objParametersLocal.lstResults.length > 0) {

				//Now we iterate over the provided results.
				this.objParametersLocal.lstResults.forEach(objResultStored => {

					//If the current iteration has a similar request in the provided results, we assign it.
					if(objParent.deepEqual(objResultStored.objRequest, objRequest)) {
						objParent.objResult = objResultStored.objResult;
					}
				});
			}

			//Now we iterate over the childs.
			this.objParametersLocal.lstChildSections.forEach(objChildItem => {

				//If the current iteration has child iterations, we set the level of the child.
				objChildItem.intLevel = this.objParametersLocal.intLevel + 1;

				//Now we set the results.
				if(objUtilities.isNotNull(this.objParametersLocal) && objUtilities.isNotNull(this.objParametersLocal.lstResults) && 
						this.objParametersLocal.lstResults.length > 0) {
					
					//If we have a child, we set the results to that child.
					if(objUtilities.isNotNull(objChildItem)) {
						objChildItem.lstResults = this.objParametersLocal.lstResults;

						//If we have multiple objects as childs, we set them the results too.
						if(objUtilities.isNotNull(objChildItem.lstChildSections)) {
							objChildItem.lstChildSections.forEach(objChildObject => {
								objChildObject.lstResults = objParent.objParametersLocal.lstResults;
							});
						}
					}
				}
			});

			//In case results were already provided by the invoker, we check those.
			if(objUtilities.isNotNull(this.objResult)) {

				//We save the results to send them later to parent.
				objParent.lstResults.push({
					objRequest: objRequest,
					objResult: objResult
				});

				//Now we process the data.
				objParent.processData(objRequest, this.objResult, objParent.objParametersLocal.lstChildSections);
				objParent.removeIterationFromParent();
			} else if(objUtilities.isNotNull(this.objParametersLocal) && objUtilities.isNotNull(objRequest) && objUtilities.isNotBlank(objRequest.strRecordId) && 
					(objUtilities.isNull(this.objParametersLocal.lstResults) || this.objParametersLocal.lstResults.length <= 0)) {

				//Now we send the request.
				getRecords({
					objRequest: objRequest
				}).then((objResult) => {
					objParent.processData(objRequest, objResult, objParent.objParametersLocal.lstChildSections);
				}).catch((objError) => {
					objUtilities.processException(objError, objParent);
				}).finally(() => {

					//Finally, we hide the spinner.
					objParent.removeIterationFromParent();
				});
			}
		}
	}

	/*
	 Method Name : renderedCallback
	 Description : This method gets executed on rendered callback.
	 Parameters	 : None
	 Return Type : None
	 */
	renderedCallback() {
		let strFullCustomCSS = "";
		let objParent = this;
		if(!this.boolCustomCSSLoaded) {
			this.updateCustomCSS();
			this.boolCustomCSSLoaded = true;
		}
	}

	/*
	 Method Name : updateCustomCSS
	 Description : This method updates the custom css of the component.
	 Parameters	 : None
	 Return Type : None
	 */
	updateCustomCSS() {
		let strFullCustomCSS = "";
		let objParent = this;
		this.template.querySelectorAll('.customGeneralCSS').forEach(objElement => {
			objParent.lstCustomCSS.forEach(strCustomCSS => {
				strFullCustomCSS += " c-global-nested-data-viewer " + strCustomCSS + " ";
			});
			objElement.innerHTML = "<style> " + strFullCustomCSS + " </style>";
		});
	}
	
	/*
	 Method Name : deepEqual
	 Description : This method determines if two objects have the same properties and values.
	 Parameters	 : Object, called from deepEqual, objItemOne Item to be analyzed.
	 			   Object, called from deepEqual, objItemTwo Item to be analyzed.
	 Return Type : Boolean
	 */
	deepEqual(objItemOne, objItemTwo) {
		const lstKeysOne = Object.keys(objItemOne);
		const lstKeysTwo = Object.keys(objItemTwo);
		let boolResult = true;

		//First we check if both have the same amount of properties.
		if(lstKeysOne.length !== lstKeysTwo.length) {
			boolResult = false;
		} else {

			//Now we check property by property.
			for(const strKey of lstKeysOne) {
				const objValueOne = objItemOne[strKey];
				const objValueTwo = objItemTwo[strKey];
				const boolAreObject = objUtilities.isObject(objValueOne) && objUtilities.isObject(objValueTwo);
				if(boolAreObject && !this.deepEqual(objValueOne, objValueTwo) || !boolAreObject && objValueOne !== objValueTwo) {
					boolResult = false;
					break;
				}
			}
		}
		return boolResult;
	}
	
	/*
	 Method Name : removeIterationFromParent
	 Description : This method remove an iteration from the counter.
	 Parameters	 : None
	 Return Type : None
	 */
	removeIterationFromParent() {
		if(objUtilities.isNotNull(this.intNumberOfIteratios)) {
			this.intNumberOfIteratios--;

			//If no more pending iterations, we remove the spinner.
			if(this.intNumberOfIteratios <= 0) {
				this.boolDisplaySpinner = false;
			}
		} else {
			this.dispatchEvent(new CustomEvent("removeiteration"));
		}
	}
	
	/*
	 Method Name : addIterationToParent
	 Description : This method adds an iteration to the counter.
	 Parameters	 : None
	 Return Type : None
	 */
	addIterationToParent() {
		if(objUtilities.isNotNull(this.intNumberOfIteratios)) {
			this.intNumberOfIteratios++;
		} else {
			this.dispatchEvent(new CustomEvent("additeration"));
		}
	}
	
	/*
	 Method Name : processData
	 Description : This method processes the data from results or backend.
	 Parameters	 : Object, called from processData, objRequest Request.
	 			   Object, called from processData, objResult Results.
				   Object, called from processData, lstChildSections Child references.
	 Return Type : None
	 */
	processData(objRequest, objResult, lstChildSections) {
		let objNewRecord;
		let objParent = this;
		let lstRecordIds = new Array();
		
		//We save the results to send them later to parent.
		objParent.lstResults.push({
			objRequest: objRequest,
			objResult: objResult
		});

		//Depending the UI element type, we prepare the data.
		switch(this.objParametersLocal.intType) {

			//Collapsible Panel.
			default:
			case 1:
				objParent.objPanel = {
					lstRecords: new Array()
				}

				//Now we assign the records to the UI, and get them ready for the next iteration.
				objResult.lstRecords.forEach((objRecord) => {

					//We set the hierarchy.
					lstRecordIds.push(objRecord.Id);

					//Now we define if the panel should be open by default.
					if(objUtilities.isNotNull(objParent.objParametersLocal.boolIsOpen)) {
						objParent.lstActiveSections.push(objRecord[objParent.objParametersLocal.strLabelAPIName]);
					}

					//We set the child record id as the new Parent Record Id.
					objNewRecord = {
						boolDisplayCheckbox: objParent.boolDisplayCheckbox,
						boolIsCheckboxDisabled: objParent.boolIsCheckboxDisabled,
						boolHasActionButtons: objParent.boolHasActionButtons,
						strRecordId: objRecord.Id,
						strLabel: objRecord[objParent.objParametersLocal.strLabelAPIName],
						intLevel: objParent.objParametersLocal.intLevel,
						objButtons: objParent.objParametersLocal.objButtons,
						objRecordDetail: objRecord
					};
					if(objUtilities.isNotNull(lstChildSections) && lstChildSections.length > 0) {
						objNewRecord.lstChildSections = lstChildSections;
					} else {
						objParent.lstCustomCSS.push("lightning-accordion-section[data-accordion-id='" + objRecord.Id + "'] lightning-primitive-icon { visibility: hidden; padding-left: 10px; }");
						objParent.updateCustomCSS();
					}
					objParent.objPanel.lstRecords.push(objNewRecord);
				});
			break;

			//Data Table.
			case 2:
				objParent.objTable = objParent.objParametersLocal.objTable;
				objParent.objTable.lstRecords = objResult.lstRecords;
				objParent.objTable.lstColumns = objResult.lstColumns;

				//We hide the table, if no records are retrieved.
				if(objResult.lstRecords.length === 0) {
					objParent.boolDisplayTable = false;
				}

				//We set the hierarchy.
				objResult.lstRecords.forEach((objRecord) => {
					lstRecordIds.push(objRecord.Id);
				});
			break;
		}
		objParent.mapBuckets.set(objRequest.strObjectName, lstRecordIds);
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
	 Method Name : getRecursiveStructure
	 Description : This method returns the data structure of all the nodes.
	 Parameters	 : None
	 Return Type : Data structure.
	 */
	@api
	getRecursiveStructure() {
		 let lstResults = this.lstResults;
 
		//We add the current selection.
		if(objUtilities.isNotNull(this.lstResults) && objUtilities.isNotNull(this.lstResults[0])) {
			lstResults[0].lstSelectedIds = new Array();
			this.template.querySelectorAll(".collapsibleCheckbox").forEach(objCheckbox => {
				if(objCheckbox.checked) {
					lstResults[0].lstSelectedIds.push(objCheckbox.dataset.id);
				}
			});
			this.template.querySelectorAll(".customDataTable").forEach(objDataTable => {
				objDataTable.getSelectedRows().forEach(strRecordId => {
					lstResults[0].lstSelectedIds.push(strRecordId);
				});
			});
		}

		//Now we call the nested child records.
		this.template.querySelectorAll(".collapsiblePanel").forEach(objChildViewer => {
			lstResults.push(... objChildViewer.getRecursiveStructure());
		});
		return lstResults;
	}

    /*
	 Method Name : getSelectedComponents
	 Description : This method returns the data structure of all the selected nodes.
	 Parameters	 : None
	 Return Type : Data structure.
	 */
	@api
    getSelectedComponents() {
		let lstFilteredRecords;
		let lstResults = this.lstResults;
		let lstResultsFiltered = new Array();

		//We add the current selection.
		if(objUtilities.isNotNull(this.lstResults) && objUtilities.isNotNull(this.lstResults[0])) {
			lstResults[0].lstSelectedIds = new Array();

			//First we get the unique records.
			this.template.querySelectorAll(".collapsibleCheckbox").forEach(objCheckbox => {
				if(objCheckbox.checked) {
					lstResults[0].lstSelectedIds.push(objCheckbox.dataset.id);
				}
			});
			this.template.querySelectorAll(".customDataTable").forEach(objDataTable => {
				objDataTable.getSelectedRows().forEach(strRecordId => {
					lstResults[0].lstSelectedIds.push(strRecordId);
				});
			});

			//Now we remove the records that where not selected.
			lstResults.forEach(objResult => {
				lstFilteredRecords = new Array();
				if(objUtilities.isNull(objResult.objResult)) {
					objResult.objResult = new Object();
				}
				if(objUtilities.isNotNull(objResult.lstSelectedIds) && objResult.lstSelectedIds.length > 0 && objUtilities.isNotNull(objResult.objResult.lstRecords)) {
					objResult.objResult.lstRecords.forEach(objRecord => {
						if(objResult.lstSelectedIds.includes(objRecord.Id)) {
							lstFilteredRecords.push(objRecord);
						}
					});
				}
				objResult.objResult.lstRecords = lstFilteredRecords;

				//Only if we have selected options.
				if(objUtilities.isNotNull(objResult.lstSelectedIds) && objResult.lstSelectedIds.length) {
					lstResultsFiltered.push(objResult);
				}
			});
		}
		lstResults = lstResultsFiltered;

		//Now we call the nested child records.
		this.template.querySelectorAll(".collapsiblePanel").forEach(objChildViewer => {
			lstResults.push(... objChildViewer.getSelectedComponents());
		});
		return lstResults;
	}
	
	/*
	 Method Name : getSelectedImmediateChildRecords
	 Description : This method returns the selected immediate child records.
	 Parameters	 : None
	 Return Type : List of strings.
	 */
	@api
	getSelectedImmediateChildRecords() {
		let lstResults = new Array();

		//We add the current selection.
		if(this.boolDisplayCheckbox) {
			this.template.querySelectorAll(".collapsibleCheckbox").forEach(objCheckbox => {
				if(objCheckbox.checked) {
					lstResults.push(objCheckbox.dataset.id);
				}
			});
		}
		if(this.objTable && this.objTable.boolDisplayCheckbox) {
			this.template.querySelectorAll(".customDataTable").forEach(objDataTable => {
				objDataTable.getSelectedRows().forEach(strRecordId => {
					lstResults.push(strRecordId);
				});
			});
		}
		return lstResults;
	}
	
	/*
	 Method Name : getSelectedRecords
	 Description : This method returns the selected records recursively.
	 Parameters	 : None
	 Return Type : List of strings.
	 */
	@api
	getSelectedRecords() {
		let lstResults = new Array();

		//We add the current selection.
		if(this.boolDisplayCheckbox) {
			this.template.querySelectorAll(".collapsibleCheckbox").forEach(objCheckbox => {
				if(objCheckbox.checked) {
					lstResults.push(objCheckbox.dataset.id);
				}
			});
		}
		if(this.objTable && this.objTable.boolDisplayCheckbox) {
			this.template.querySelectorAll(".customDataTable").forEach(objDataTable => {
				objDataTable.getSelectedRows().forEach(strRecordId => {
					lstResults.push(strRecordId);
				});
			});
		}
		if(objUtilities.isNotNull(this.lstResults)) {
			this.lstResults.forEach(objResult => {
				if(objUtilities.isNotNull(objResult) && objUtilities.isNotNull(objResult.objResult) && objUtilities.isNotNull(objResult.objResult.lstRecords)) {
					objResult.objResult.lstRecords.forEach(objRecord => {
						lstResults.push(objRecord.Id);
					});
				}
			});
		}

		//Now we call the nested child records.
		this.template.querySelectorAll(".collapsiblePanel").forEach(objChildViewer => {
			lstResults.push(... objChildViewer.getSelectedRecords());
		});

		//Finally, if it is the last iteration, we return unique values.
		if(this.boolIsTopParent && lstResults.length > 0) {
			lstResults = JSON.parse(JSON.stringify(lstResults.filter(function (strValue, intIndex, objSelf) {
				return objSelf.indexOf(strValue) === intIndex;
			})));
		}
		return lstResults;
	}
	
	/*
	 Method Name : getBuckets
	 Description : This method returns the selected records recursively, in buckets.
	 Parameters	 : None
	 Return Type : Map.
	 */
	@api
	getBuckets() {
		let lstRecordIds;
		let mapChildBuckets;
		let mapBuckets = new Map(this.mapBuckets);

		//Now we call the nested child records.
		this.template.querySelectorAll(".collapsiblePanel").forEach(objChildViewer => {
			mapChildBuckets = objChildViewer.getBuckets();
			if(objUtilities.isNotNull(mapChildBuckets)) {
				mapChildBuckets.forEach((lstChildRecordIds, strObjectName) => {
					if(objUtilities.isNull(mapBuckets.get(strObjectName))) {
						mapBuckets.set(strObjectName, new Array());
					}
					lstRecordIds = mapBuckets.get(strObjectName);
					lstRecordIds.push(... lstChildRecordIds);
					lstRecordIds = JSON.parse(JSON.stringify(lstRecordIds.filter(function (strValue, intIndex, objSelf) {
						return objSelf.indexOf(strValue) === intIndex;
					})));
					mapBuckets.set(strObjectName, lstRecordIds);
				});
			}
		});
		return mapBuckets;
	}

    /*
	 Method Name : getSelectedTableRows
	 Description : This method returns the selected rows of the table currently render in the component.
	 Parameters	 : None
	 Return Type : List.
	 */
	@api
	getSelectedTableRows() {
		let lstRecords = new Array();
		this.template.querySelectorAll(".customDataTable").forEach(objTable => {
			lstRecords = objTable.getSelectedRows();
		});
		return lstRecords;
	}

    /*
	 Method Name : getAllSelectedTableRowsUnselected
	 Description : This method unchecks all the checkboxes on the table rendered on the current component.
	 Parameters	 : None
	 Return Type : None
	 */
	@api
	getAllSelectedTableRowsUnselected() {
		let lstRecords = new Array();
		this.template.querySelectorAll(".customDataTable").forEach(objTable => {
			lstRecords = objTable.getAllRecordsUnselected();
		});
		return lstRecords;
	}

    /*
	 Method Name : getAllSelectedChildCheckboxesUnselected
	 Description : This method changes the child checkboxes of the current iteration to FALSE.
	 Parameters	 : None
	 Return Type : None
	 */
	@api
	getAllSelectedChildCheckboxesUnselected() {
		let objParent = this.template;

		//First we get the components with the multiple tables, if any.
		this.getAllSelectedTableRowsUnselected();

		//Now we uncheck the checkboxes.
		objParent.querySelectorAll(".collapsibleCheckbox").forEach(objCheckbox => {
			objCheckbox.checked = false;
		});

		//Now we get the child panels unchecked.
		objParent.querySelectorAll(".collapsiblePanel").forEach(objComponent => {
			objComponent.getAllSelectedChildCheckboxesUnselected();
		});
    }

    /*
	 Method Name : selectRecords
	 Description : This method selects records from the table.
	 Parameters	 : Object, called from selectRecords, objEvent Select event.
	 Return Type : None
	 */
    selectRecords(objEvent) {
		let boolShouldCheckParent = false;
		let objParent = this;

		//If the table has been initialized.
		if(objUtilities.isNotNull(objEvent) && objUtilities.isNotNull(objEvent.detail) && objUtilities.isNotNull(objEvent.detail.selectedRows)) {
			this.lstSelectedRecords = objEvent.detail.selectedRows;

			//We only execute the code after the initial load.
			if(!this.boolInitialLoad) {
	
				//First we determine the parent checkbox future status.
				if(objUtilities.isNotNull(this.lstSelectedRecords) && this.lstSelectedRecords.length > 0) {
					boolShouldCheckParent = true;
				}
	
				//Now we update the parent checkbox.
				this.dispatchEvent(new CustomEvent("childcheboxchanged", {
					detail: {
						boolIsChecked: boolShouldCheckParent,
						strParentRecordId: objParent.objParametersLocal.strRecordId
					}
				}));
			}
		}

		//Now we set the flag so the next iteration gets executed.
		this.boolInitialLoad = false;
    }

    /*
	 Method Name : checkUncheckOtherCheckboxes
	 Description : This method requests to the other checkboxes to change their status, depending on the user request..
	 Parameters	 : Event, called from checkUncheckOtherCheckboxes, objEvent Child event.
	 Return Type : None
	 */
	checkUncheckOtherCheckboxes(objEvent) {
		let intTotalCheckboxes;
		let intTotalUnchecked = 0;
		let objParent = this;
		let lstCheckboxes = this.template.querySelectorAll(".collapsibleCheckbox");
		intTotalCheckboxes = lstCheckboxes.length;

		//Now we check how many checkboxes are checked.
		lstCheckboxes.forEach(objCheckbox => {
			if(!objCheckbox.checked) {
				intTotalUnchecked++;
			}
		});

		//If all the checkboxes are unchecked, we uncheck the parent.
		this.dispatchEvent(new CustomEvent("childcheboxchanged", {
			detail: {
				boolIsChecked: intTotalCheckboxes !== intTotalUnchecked,
				strParentRecordId: objParent.objParametersLocal.strRecordId
			}
		}));

		//Finally, we uncheck child checkboxes, if the current panel is unchecked.
		if(objUtilities.isNotNull(objEvent) && objUtilities.isNotNull(objEvent.target) && objUtilities.isNotNull(objEvent.target.checked) && !objEvent.target.checked) {
			this.template.querySelectorAll(".collapsiblePanel[data-link-id='" + objEvent.currentTarget.dataset.linkId + "']").forEach(objComponent => {
				objComponent.getAllSelectedChildCheckboxesUnselected();
			});
		}
    }

    /*
	 Method Name : updateCheckbox
	 Description : This method changes the checkbox of the current iteration and send the message to the parent to do the same.
	 Parameters	 : Event, called from updateCheckbox, objEvent Child event.
	 Return Type : None
	 */
	updateCheckbox(objEvent) {
		let boolIsChecked = objEvent.detail.boolIsChecked;
		let objParent = this;
		let objCheckbox = this.template.querySelector(".collapsibleCheckbox[data-id='" + objEvent.detail.strParentRecordId + "']");
		if(objUtilities.isNotNull(objCheckbox)) {

			//Now we confirm all the immediate child records are unchecked.
			if(!boolIsChecked) {
				this.template.querySelectorAll("c-global-nested-data-viewer[data-link-id='" + objEvent.detail.strParentRecordId + "']").forEach(objPanel => {
					if(objPanel.getSelectedImmediateChildRecords().length > 0) {
						boolIsChecked = true;
					}
				});
			}

			//Now we set the checkbox status.
			objCheckbox.checked = boolIsChecked;

			//Now we check all the siblings.
			objParent.checkUncheckOtherCheckboxes();
		}
    }
}