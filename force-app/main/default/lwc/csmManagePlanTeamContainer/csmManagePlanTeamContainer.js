/*
 * Name			:	csmManagePlanTeamContainer
 * Author		:	Deva M
 * Created Date	: 	07/02/2021
 * Description	:	Manage Plan Team Container controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M         		07/02/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api } from 'lwc';

//Class body.
export default class CsmManagePlanTeamContainer extends LightningElement {

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