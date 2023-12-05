/*
 * Name			:	CsmCreateEntitledProducts
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/24/2022
 * Description	:	This LWC servers as a container for the Create Entitled Products feature.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/24/2022		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import createRecords from "@salesforce/apex/CSMCreateEntitledProductsController.createRecords";

//Labels.
import Success from '@salesforce/label/c.Success';

//Class body.
export default class CsmCreateEntitledProducts extends LightningElement {

	//API variables.
    @api recordId;

	//Public variables.
	boolInitialLoad = true;

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

			//Now we create the records.
			createRecords({
				idRecord: objParent.recordId
			}).then(() => {
				objUtilities.showToast(Success, Success, 'success', objParent);
				objParent.dispatchEvent(new CloseActionScreenEvent());
			}).catch((objError) => {
				objUtilities.processException(objError, objParent);
			});
		}
	}
}