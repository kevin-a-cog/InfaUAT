/*
 * Name			:	globalManageTeamsContainer
 * Author		:	Monserrat Pedroza
 * Created Date	: 	8/20/2021
 * Description	:	Global Manage Teams Container HTML.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		8/20/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api } from 'lwc';

//Class body.
export default class ManageTeamsContainer extends LightningElement  {

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