/*
 * Name			:	GlobalCardColumn
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/22/2021
 * Description	:	This LWC exposes the generica Card Data controller created for Global.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/22/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Class body.
export default class GlobalCardColumn extends NavigationMixin(LightningElement) {

	//API variables.
	@api objRecord;
	@api lstColumns;

	//Private variables.
	lstLocalColumns;

	/*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
		let objParent = this;

		//If we received the minimum data.
		if(objUtilities.isNotNull(this.lstColumns) && objUtilities.isNotNull(this.objRecord)) {

			//First we clone the recieved columns, so we can update them.
			this.lstLocalColumns = JSON.parse(JSON.stringify(this.lstColumns));

			//Now we set the size of each column.
			this.lstLocalColumns.forEach((objColumn) => {
				objColumn.strStyleClasses = "slds-size_" + objColumn.intSize + "-of-12";

				//Now we set the value.
				this.objRecord.lstValues.forEach((objValue) => {
					if(objColumn.strId === objValue.strPlaceId) {
						objColumn.strValue = objValue.strValue;

						//Now we set the cell type.
						switch(objValue.intType) {
							case 1:

								//Text.
								objColumn.boolIsText = true;
							break;
							case 2:

								//Icon.
								objColumn.boolIsIcon = true;
							break;
							case 3:

								//Record Link.
								objColumn.boolIsRecordLink = true;
							break;
							case 4:

								//URL Link.
								objColumn.boolIsLink = true;
							break;
							default:

								//Text.
								objColumn.boolIsText = true;
							break;
						}

						//If we received parameters, we set them.
						if(objUtilities.isNotNull(objValue.mapAttributes)) {
							for(let [strAttribute, strValue] of Object.entries(objValue.mapAttributes)) {
								objColumn[strAttribute] = strValue;
							}
						}
					}
				});
			});
		}
	}

    /*
	 Method Name : openRecord
	 Description : This method opens a record
	 Parameters	 : Object, called from openRecord, objEvent On click event.
	 Return Type : None
	 */
	openRecord(objEvent) {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				recordId: objEvent.currentTarget.dataset.recordId,
				actionName: 'view'
			}
		});
    }
}