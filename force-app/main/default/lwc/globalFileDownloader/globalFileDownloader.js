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

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import getRecords from "@salesforce/apex/GlobalFileDownloader.getRecords";

//Custom Labels.
import Download_Files_Modal_Title from '@salesforce/label/c.Download_Files_Modal_Title';
import Download_Files_Modal_Confirmation from '@salesforce/label/c.Download_Files_Modal_Confirmation';
import Download_Files_Modal_Cancel from '@salesforce/label/c.Download_Files_Modal_Cancel';
import Download_Files_Modal_Download from '@salesforce/label/c.Download_Files_Modal_Download';

//Class body.
export default class GlobalFileDownloader extends LightningElement {

	//API variables.
	@api recordId;

	//Private variables.
	boolIsModalOpen;
	boolInitialLoad = true;
	boolDisplaySpinner = true;
	objParameters = {
		strTableId: "1",
		lstActionButtons: [
			{
				strId: "1",
				strVariant: "Brand",
				strLabel: "Download",
				title: "Download",
				strStyleClasses: "slds-var-m-left_x-small"
			}
		]
	};
	lstSelectedRecords;

	//Labels.
	label = {
		Download_Files_Modal_Title,
		Download_Files_Modal_Confirmation,
		Download_Files_Modal_Cancel,
		Download_Files_Modal_Download
	}

	//Getters.
	get objCustomCellModalProperties() {
		return objUtilities.getPopOutCSSClosed();
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
		
			//First we obtain the related Files.
			getRecords({
				strRecordId: objParent.recordId
			}).then((objResult) => {
				objParent.objParameters.lstRecords = objResult.lstRecords;
				objParent.objParameters.lstColumns = objResult.lstColumns;
			}).catch((objError) => {
				objUtilities.processException(objError, objParent);
			}).finally(() => {
				objParent.boolDisplaySpinner = false;
			});
		}
	}

	/*
	 Method Name : executeAction
	 Description : This method executes the corresponding action requested by the Data Tables components.
	 Parameters	 : Object, called from executeAction, objEvent Select event.
	 Return Type : None
	 */
	executeAction(objEvent) {
        const { intAction, objPayload } = objEvent.detail;
		let objParent = this;

		//First, we check which event we need to execute.
		switch(intAction) {
			case 1:
				
				//The user has selected records.
				objParent.selectRecords(objPayload);
			break;
			case 2:

				//The user has pressed an Action button.
				switch(objPayload.currentTarget.dataset.id) {

					//User wants to download the provided records.
					case "1":
						if(objUtilities.isNotNull(objParent.lstSelectedRecords) && objParent.lstSelectedRecords.length > 0) {
							objParent.boolIsModalOpen = true;
						}
					break;
				}
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
	 Method Name : cancelOperation
	 Description : This method closes the confirmation modal.
	 Parameters	 : None
	 Return Type : None
	 */
	cancelOperation() {
		this.boolIsModalOpen = false;
    }

    /*
	 Method Name : confirmOperation
	 Description : This method starts the download process.
	 Parameters	 : None
	 Return Type : None
	 */
	confirmOperation() {
		this.lstSelectedRecords.forEach(objDocument => {
			window.open("/sfc/servlet.shepherd/document/download/" + objDocument.Id);
		});
		this.boolIsModalOpen = false;
    }
}