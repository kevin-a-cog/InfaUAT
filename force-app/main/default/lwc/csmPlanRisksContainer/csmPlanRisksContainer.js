/*
 * Name			:	CsmPlanRisksContainer
 * Author		:	Monserrat Pedroza
 * Created Date	: 	6/14/2021
 * Description	:	Plan Risks Container Controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		6/14/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api } from 'lwc';

//Class body.
export default class CsmPlanRisksContainer extends LightningElement {

	//API variables.
    @api recordId;
	@api readOnly = false;

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