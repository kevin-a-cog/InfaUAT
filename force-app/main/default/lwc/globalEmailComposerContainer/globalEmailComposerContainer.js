/*
 * Name			:	GlobalEmailComposerContainer
 * Author		:	Monserrat Pedroza
 * Created Date	: 	10/05/2021
 * Description	:	This LWC servers as a container for the Email Composer LWC.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		10/05/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api } from 'lwc';

//Class body.
export default class GlobalEmailComposerContainer extends LightningElement {

	//API variables.
    @api recordId;
	@api boolIsReply;
	@api boolIsReplyAll;
	@api boolIsForward;

	//Private variables.
    boolIsPoppedOut = false;

	/*
	 Method Name : popOut
	 Description : This method pops out or pops in the component.
	 Parameters	 : Event, called from popOut, objEvent dispatched event.
	 Return Type : None
	 */
    popOut(objEvent) {
        this.boolIsPoppedOut = objEvent.detail.boolIsPopingOut;
    }
}