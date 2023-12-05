/*
 * Name			:	GlobalMultiSelectLookup
 * Author		:	Monserrat Pedroza
 * Created Date	: 	3/4/2022
 * Description	:	This LWC exposes the generic Multi Select Lookup component.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description							Tag
 **********************************************************************************************************
 Monserrat Pedroza		3/4/2022		N/A				Initial version.					N/A
 */

//Core imports.
import { LightningElement, api, track } from 'lwc';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Custom Labels.
import Multi_Select_Lookup_Cancel from '@salesforce/label/c.Multi_Select_Lookup_Cancel';
import Multi_Select_Lookup_Done from '@salesforce/label/c.Multi_Select_Lookup_Done';
import Multi_Select_Lookup_No_Records_Found from '@salesforce/label/c.Multi_Select_Lookup_No_Records_Found';
import Multi_Select_Lookup_Search from '@salesforce/label/c.Multi_Select_Lookup_Search';
import Multi_Select_Lookup_Records_Limit from '@salesforce/label/c.Multi_Select_Lookup_Records_Limit';

//Apex Controllers.
import loadRecords from '@salesforce/apex/GlobalMultiSelectLookupController.loadRecords';

//Class body.
export default class GlobalMultiSelectLookup extends LightningElement {

	//API variables.
	@api objRequest;

	//Track variables.
    @track lstCurrentCheckboxes = new Array();
	@track lstCurrentCheckboxesSelectedIds = new Array();
	@track lstPills = new Array();

	//Private variables.
	boolAllowCallBackend = true;
	boolIsSearchFieldDisabled = false;
    boolDisplayResultsSection = false;
    boolDisplayNoRecordsFound = false;
	strKeyword = '';
	
	//Labels.
	label = {   
        Multi_Select_Lookup_Cancel,
        Multi_Select_Lookup_Done,
        Multi_Select_Lookup_No_Records_Found,
		Multi_Select_Lookup_Search,
		Multi_Select_Lookup_Records_Limit
    }

    /*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
    connectedCallback() {
		if(objUtilities.isNotNull(this.objRequest) && objUtilities.isNotNull(this.objRequest.lstPreloadedPills)) {
			this.lstPills = [... this.objRequest.lstPreloadedPills];
		}
	}

	/*
	 Method Name : searchRecords
	 Description : This method returns the results found.
	 Parameters	 : Object, called from searchRecords, objEvent Event.
	 Return Type : None
	 */
    searchRecords(objEvent) {
		let boolAlreadyAPill;
		let objParent = this;
		let mapFilterFieldAPINames = new Object();

		//First we capture the keyword and make sure it contains something.
        if(objUtilities.isNotBlank(objEvent.target.value) && objParent.boolAllowCallBackend) {
			objParent.boolAllowCallBackend = false;

			//We set the initial global values.
			objParent.boolDisplayResultsSection = true;
			objParent.boolDisplayNoRecordsFound = true;
			objParent.strKeyword = objEvent.target.value.trim();
			objParent.lstCurrentCheckboxes = new Array();
			objParent.lstCurrentCheckboxesSelectedIds = new Array();

			//If we received a list of filters, we use it.
			if(objUtilities.isNotNull(objParent.objRequest.lstFilterFieldAPINames)) {
				objParent.objRequest.lstFilterFieldAPINames.forEach(strFilterFieldAPIName => {
					mapFilterFieldAPINames[strFilterFieldAPIName] = objParent.strKeyword;
				});
			}

            //Now we look for the matching records.
            loadRecords({
				objRequest: {
					intLimitResults: objParent.objRequest.intLimitResults,
					strObjectName: objParent.objRequest.strObjectApiName,
					strFilterFieldAPIName: objParent.objRequest.strFilterFieldAPIName,
					strKeyword: objParent.strKeyword,
					strAdditionalFilters: objParent.objRequest.strAdditionalFilters,
					strValueFormat: objParent.objRequest.strValueFormat,
					mapFilterFieldAPINames: mapFilterFieldAPINames
				}
            }).then(lstResults => { 
                
				//If we received records.
				lstResults.forEach(objRecord => {
					boolAlreadyAPill = false;

					//Now we check if the current record is already a pill, so we don't include it in the new list.
					objParent.lstPills.forEach(objPill => {
						if(objPill.value === objRecord.strKey) {
							boolAlreadyAPill = true;
						}
					});

					//Now we add the value to the list.
					if(!boolAlreadyAPill) {
						objParent.lstCurrentCheckboxes.push({
							value: objRecord.strKey, 
							label: objRecord.strValue
						});
					}
				});
            }).catch(objError => {
                objUtilities.processException(objError, objParent);
            }).finally(() => {
				if(objParent.lstCurrentCheckboxes.length > 0) {
					objParent.boolDisplayNoRecordsFound = false;
				}
				objParent.boolAllowCallBackend = true;
			});
        } else if(objUtilities.isBlank(objEvent.target.value) && objParent.boolAllowCallBackend) {
			objParent.boolDisplayResultsSection = false;
		}       
    }

	/*
	 Method Name : selectUnselectCheckbox
	 Description : This method stores the selected result.
	 Parameters	 : Object, called from selectUnselectCheckbox, objEvent Event.
	 Return Type : None
	 */
    selectUnselectCheckbox(objEvent) {
		this.lstCurrentCheckboxesSelectedIds = objEvent.detail.value;
    }

	/*
	 Method Name : selectionCompleted
	 Description : This method finishes the record selection.
	 Parameters	 : None
	 Return Type : None
	 */
    selectionCompleted() {
		let inSelectedItemsSize = this.lstPills.length;
		let objParent = this;

		//First we get the corresponding sizes.
		if(objUtilities.isNotNull(objParent.lstCurrentCheckboxesSelectedIds)) {
			inSelectedItemsSize += objParent.lstCurrentCheckboxesSelectedIds.length;
		}

		//We make sure, if needed, that the user hasn't selected more than the allowed number of items.
		if(objUtilities.isNotNull(objParent.objRequest.intMaximumNumberOfSelectedResults) && inSelectedItemsSize > objParent.objRequest.intMaximumNumberOfSelectedResults) {
			objUtilities.showToast('Error', objParent.label.Multi_Select_Lookup_Records_Limit + ' ' + objParent.objRequest.intMaximumNumberOfSelectedResults, 'Error', objParent);
		} else {

			//We disable the search field, if needed.
			if(objUtilities.isNotNull(objParent.objRequest.intMaximumNumberOfSelectedResults) && inSelectedItemsSize === objParent.objRequest.intMaximumNumberOfSelectedResults) {
				objParent.boolIsSearchFieldDisabled = true;
			}

			//We create the new pills first, if we have any.
			if(inSelectedItemsSize > 0) {
				objParent.lstCurrentCheckboxesSelectedIds.forEach(strId => {
					objParent.lstCurrentCheckboxes.forEach(objCheckbox => {
						if(strId === objCheckbox.value) {
							objParent.lstPills.push(objCheckbox);
						}
					});
				});

				//We send the final list to the parent.
				objParent.dispatchEvent(new CustomEvent("update", { 
					detail: {
						lstSelectedItems: objParent.lstPills
					}
				}));
			}

			//We restart the component.
			objParent.initializeValues();
		}
    }

	/*
	 Method Name : removeRecord
	 Description : This method removes the selected result.
	 Parameters	 : Object, called from removeRecord, objEvent Event.
	 Return Type : None
	 */
    removeRecord(objEvent) {
		let objParent = this;
		let lstNewPills = new Array();

		//We look for the pill.
		objParent.lstPills.forEach(objPill => {
			if(objEvent.target.dataset.item !== objPill.value) {
				lstNewPills.push(objPill);
			}
		});

		//Now we set the new pills.
		objParent.lstPills = lstNewPills;
        
        //We send the final list to the parent.
        objParent.dispatchEvent(new CustomEvent("update", {   
            detail: {
				lstSelectedItems: objParent.lstPills
			}
		}));
		objParent.boolIsSearchFieldDisabled = false;
    }

	/*
	 Method Name : cancelSelection
	 Description : This method cancels the record selection.
	 Parameters	 : None
	 Return Type : None
	 */
    cancelSelection() {
        this.initializeValues();
    }

	/*
	 Method Name : initializeValues
	 Description : This method restores the values to their initial state.
	 Parameters	 : None
	 Return Type : None
	 */
    initializeValues() {
        this.strKeyword = '';        
        this.boolDisplayResultsSection = false;
    }
}