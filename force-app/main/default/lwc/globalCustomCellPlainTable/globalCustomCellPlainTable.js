/*
 * Name			:	GlobalCustomCellPlainTable
 * Author		:	Monserrat Pedroza
 * Created Date	: 	9/9/2021
 * Description	:	Generic Custom Cell component created for Plain tables in Data Table Global component.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		9/9/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api } from 'lwc';

//Class body
export default class GlobalCustomCellPlainTable extends LightningElement {

	//API variables.
	@api strRecordId;
	@api objCell;
	@api objRecord;

	/*
	 Method Name : executeAction
	 Description : This method sends a message to parent listeners with the action data.
	 Parameters	 : Object, called from executeAction, objEvent Event.
	 Return Type : None
	 */
	executeAction(objEvent) {
		this.dispatchEvent(new CustomEvent('action', {
			composed: true,
			bubbles: true,
			cancelable: true,
			detail: {
				objEvent: objEvent
			}
		}));
	}

	/*
	 Method Name : selectMenuItem
	 Description : This method sends a message to parent listeners with the action data.
	 Parameters	 : Object, called from executeAction, objEvent Event.
	 Return Type : None
	 */
	selectMenuItem(objEvent) {
		objEvent.currentTarget.dataset.action = objEvent.detail.value;
		this.dispatchEvent(new CustomEvent('action', {
			composed: true,
			bubbles: true,
			cancelable: true,
			detail: {
				objEvent: objEvent
			}
		}));
	}
}