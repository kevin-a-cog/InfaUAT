/*
 * Name			:	IpuHierarchyContainer
 * Author		:	Monserrat Pedroza
 * Created Date	: 	1/24/2023
 * Description	:	This component allows users to see the IPU Hierarchy related to a Fulfillment record.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		1/24/2023		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api } from 'lwc';

//Class body.
export default class IpuHierarchyContainer extends LightningElement {

	//API variables.
    @api recordId;

	//Private variables.
    isPoppedOut = false;

	/*
	 Method Name : popOut
	 Description : This method pops out or pops in the component.
	 Parameters	 : Event, called from popOut, objEvent dispatched event.
	 Return Type : None
	 */
    popOut(objEvent) {
        this.isPoppedOut = objEvent.detail.boolIsPopingOut;
    }
}