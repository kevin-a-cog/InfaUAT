/*
 * Name			:	globalRecordTagging
 * Author		:	Monserrat Pedroza
 * Created Date	: 	2/16/2023
 * Description	:	This LWC displays the related tags based on the Record Tagging rule engine.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		2/16/2023		N/A				Initial version.						 N/A
 */

//Core imports.
import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import getRecords from "@salesforce/apex/RecordTaggingController.getRecords";

//Class body.
export default class GlobalRecordTagging extends NavigationMixin(LightningElement) {

	//API variables.
	@api recordId;
	@api boolBlink;
	@api strChildRelationship;
	@api strStyle;
	@api strComponentStyle;

	//Private variables.
	boolTagsFound = false;
	boolInitialLoad = true;
	intId = Date.now();
	lstRecords;

	/*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
		let objParent = this;

		//We query the records.
		objParent.lstRecords = new Array();
		getRecords({
			idRecord: objParent.recordId,
			strChildRelationship: objParent.strChildRelationship
		}).then(lstRecords => {

			//First we create a new object with everything as lower case.
			if(objUtilities.isNotNull(lstRecords) && lstRecords.length > 0) {
				objParent.boolTagsFound = true;
				objParent.lstRecords = lstRecords;
			}
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		});
	}

	/*
	 Method Name : renderedCallback
	 Description : This method gets executed on rendered callback.
	 Parameters	 : None
	 Return Type : None
	 */
	renderedCallback() {
		let objParent = this;
		if(objParent.boolInitialLoad) {
			objParent.boolInitialLoad = false;

			//Now we insert the CSS code.
			if(objUtilities.isNotBlank(objParent.strStyle)) {
				objParent.template.querySelectorAll('.customGeneralCSS').forEach(objElement => {
					objElement.innerHTML = "<style> c-global-record-tagging .container[data-id='" + objParent.intId + "'] {" + objParent.strStyle + 
					"} c-global-record-tagging lightning-card[data-id='" + objParent.intId + "'] article {" + objParent.strComponentStyle + 
					"} c-global-record-tagging .slds-card__header.slds-grid {display: none;} </style>";
				});
			}
		}
	}

	/*
	 Method Name : openRecord
	 Description : This method opens the given record.
	 Parameters	 : Object, called from openRecord, objEvent Event.
	 Return Type : None
	 */
	openRecord(objEvent) {
		this[NavigationMixin.Navigate]({
			type:'standard__recordPage',
			attributes:{
				"recordId": objEvent.currentTarget.getAttribute("data-id"),
				"actionName": "view"
			}
		});
	}
}