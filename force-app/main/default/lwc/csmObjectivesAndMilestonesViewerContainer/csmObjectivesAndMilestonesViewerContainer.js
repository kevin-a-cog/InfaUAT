/*
 * Name			:	CsmObjectivesAndMilestonesViewerContainer
 * Author		:	Monserrat Pedroza
 * Created Date	: 	9/6/2021
 * Description	:	Objectives and Milestones Container Controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		9/6/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api } from 'lwc';

//Class body.
export default class CsmObjectivesAndMilestonesViewerContainer extends LightningElement {

	//API variables.
    @api recordId;
	@api boolHideActions;

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