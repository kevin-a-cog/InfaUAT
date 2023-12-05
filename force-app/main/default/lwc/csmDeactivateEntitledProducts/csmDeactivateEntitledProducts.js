/*
 * Name			:	CsmDeactivateEntitledProducts
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/23/2022
 * Description	:	This LWC servers as a container for the Deactivate Entitled Products feature.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/23/2022		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import deactivateRecords from "@salesforce/apex/CSMDeactivateEntitledProductsController.deactivateRecords";
import getForecastProduct from "@salesforce/apex/CSMDeactivateEntitledProductsController.getForecastProduct";
import getReportIds from "@salesforce/apex/CSMDeactivateEntitledProductsController.getReportIds";

//Labels.
import Success from '@salesforce/label/c.Success';
import Confirm from '@salesforce/label/c.Confirm';
import Please_Verify from '@salesforce/label/c.Please_Verify';

//Class body.
export default class CsmDeactivateEntitledProducts extends NavigationMixin(LightningElement) {

	//API variables.
    @api recordId;

	//Track variables.
	@track lstReports = new Array();

	//Public variables.
	boolInitialLoad = true;
	boolDisplaySpinner = true;
	strForecastProduct;

	//Labels.
	label = {
		Confirm,
		Please_Verify
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

			//We get the Forecast Product.
			getForecastProduct({
				idRecord: objParent.recordId
			}).then(strForecastProduct => {
				objParent.strForecastProduct = strForecastProduct;

				//Now we get the reports.
				return getReportIds();
			}).then(mapResults => {
				Object.entries(mapResults).map(objReport => {
					objParent.lstReports.push({
						Id: objReport[0],
						Name: objReport[1]
					});
				});
			}).catch((objError) => {
				objUtilities.processException(objError, objParent);
			}).finally(() => {
				objParent.boolDisplaySpinner = false;
			});
		}
	}

	/*
	 Method Name : openReport
	 Description : This method opens the selected report.
	 Parameters	 : Object, called from openReport, objEvent Event.
	 Return Type : None
	 */
	openReport(objEvent) {
		let objParent = this;
		objParent[NavigationMixin.Navigate]({
			type:'standard__recordPage',
			attributes:{
				"recordId": objEvent.currentTarget.dataset.id,
				"actionName": "view"
			},
			state: {
				fv0: objParent.strForecastProduct
			}
		});
	}

	/*
	 Method Name : deactivationConfirmed
	 Description : This method deactivates the records.
	 Parameters	 : None
	 Return Type : None
	 */
	deactivationConfirmed() {
		let objParent = this;

		//Now we deactivate the products
		objParent.boolDisplaySpinner = true;
			deactivateRecords({
				idRecord: objParent.recordId
			}).then(() => {
				objUtilities.showToast(Success, Success, 'success', objParent);
				objParent.dispatchEvent(new CloseActionScreenEvent());
			}).catch((objError) => {
				objUtilities.processException(objError, objParent);
		}).finally(() => {
			objParent.boolDisplaySpinner = false;
		});
	}
}