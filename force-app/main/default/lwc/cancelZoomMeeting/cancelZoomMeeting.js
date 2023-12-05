/*
 * Name			:	CancelZoomMeeting
 * Author		:	Monserrat Pedroza
 * Created Date	: 	11/2/2021
 * Description	:	This LWC cancels a Zoom invite.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		11/2/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api } from 'lwc';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import getMeetingCanceled from "@salesforce/apex/GCSCancelZoomMeetingController.getMeetingCanceled";

//Custom Labels.
import Zoom_Cancel_Meeting_Message from '@salesforce/label/c.Zoom_Cancel_Meeting_Message';
import Zoom_Cancel_Meeting_Button from '@salesforce/label/c.Zoom_Cancel_Meeting_Button';
import Zoom_Cancel_Meeting_Success from '@salesforce/label/c.Zoom_Cancel_Meeting_Success';
import Zoom_Cancel_Meeting_Error from '@salesforce/label/c.Zoom_Cancel_Meeting_Error';

//Class body.
export default class CancelZoomMeeting extends LightningElement {

	//API variables.
	@api recordId;

	//Private variables.
	boolInitialLoad = true;
	boolDisplaySpinner = false;
	lstCustomCSS = new Array();

	//Labels.
	label = {
		Zoom_Cancel_Meeting_Message,
		Zoom_Cancel_Meeting_Button,
		Zoom_Cancel_Meeting_Success,
		Zoom_Cancel_Meeting_Error
	}

	/*
	 Method Name : renderedCallback
	 Description : This method gets executed on UI rerendering.
	 Parameters	 : None
	 Return Type : None
	 */
	renderedCallback() {
		let strFullCustomCSS = "";
		let objParent = this;
		if(objParent.boolInitialLoad && objUtilities.isNotBlank(objParent.recordId)) {
			objParent.boolInitialLoad = false;
		
			//Now we load the css.
			objParent.lstCustomCSS.push(".modal-footer.slds-modal__footer { display: none !important; }");
			objParent.lstCustomCSS.push(".modal-body.scrollable.slds-modal__content.slds-p-around--medium { height: 150px !important; max-height: 150px !important; " + 
					"border-bottom-right-radius: var(--sds-c-modal-radius-border, var(--lwc-borderRadiusMedium,0.25rem)); " + 
					"border-bottom-left-radius: var(--sds-c-modal-radius-border, var(--lwc-borderRadiusMedium,0.25rem)); }");
			objParent.template.querySelectorAll('.customGeneralCSS').forEach(objElement => {
				objParent.lstCustomCSS.forEach(strCustomCSS => {
					strFullCustomCSS += " " + strCustomCSS + " ";
				});
				objElement.innerHTML = "<style> " + strFullCustomCSS + " </style>";
			});
		}
	}

    /*
	 Method Name : confirmOperation
	 Description : This method starts the download process.
	 Parameters	 : None
	 Return Type : None
	 */
	confirmOperation() {
		let strMessageType;
		let strMessageTitle;
		let strMessage;
		let objParent = this;

		//Now we send the request.
		objParent.boolDisplaySpinner = true;
		getMeetingCanceled({
			strRecordId: objParent.recordId
		}).then((boolResult) => {

			//We check the result.
			if(boolResult) {
				strMessageType = "success";
				strMessageTitle = "Success";
				strMessage = objParent.label.Zoom_Cancel_Meeting_Success;
				objParent.closeQuickAction();
			} else {
				strMessageType = "error";
				strMessageTitle = "Error";
				strMessage = objParent.label.Zoom_Cancel_Meeting_Error;
			}

			//Now we display the message.
			objUtilities.showToast(strMessageTitle, strMessage, strMessageType, objParent);
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		}).finally(() => {
			objParent.boolDisplaySpinner = false;
		});
    }

	/*
	 Method Name : closeQuickAction
	 Description : This method closes the modal.
	 Parameters	 : None
	 Return Type : None
	 */
	closeQuickAction() {
		this.dispatchEvent(
			new CustomEvent("executeaction", {
				bubbles: true,
				composed: true
			})
		);
	}
}