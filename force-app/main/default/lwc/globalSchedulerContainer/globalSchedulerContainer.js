/*
 * Name			:	globalSchedulerContainer
 * Author		:	Monserrat Pedroza
 * Created Date	: 	7/28/2021
 * Description	:	This LWC servers as a container for the Scheduler LWC.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		7/28/2021		N/A				Initial version.			N/A
 Amit Garg				5/12/2022		I2RT-5967		Fix the exception happening T01
														due to the bubbling issue
 */

//Core imports.
import { LightningElement, api } from 'lwc';

//Class body.
export default class GlobalSchedulerContainer extends LightningElement {

	//API variables.
    @api recordId;
	@api boolSendBackResponse;
	@api boolIsSendSchedule;
	@api boolIsCreateInvite;

	//Private variables.
    boolIsPoppedOut = false;

	/*
	 Method Name : popOut
	 Description : This method pops out or pops in the component.
	 Parameters	 : Event, called from popOut, objEvent dispatched event.
	 Return Type : None
	 */
    popOut(objEvent) {
		let objParent = this;
        this.boolIsPoppedOut = objEvent.detail.boolIsPopingOut;

		//Now we send the event.
        this.dispatchEvent(new CustomEvent('popout', {
			detail: {
				boolIsPopingOut: objParent.boolIsPoppedOut
			}
		}));
    }
	//<T01>
	/*

     Method Name : populateCommentField

     Description : This method populates the Comment field, based on the data received from the Scheduler.

     Parameters  : Object, called from getEventCreated, objEvent Event reference.

     Return Type : None

     */

	 populateCommentField(objEvent) {

        //Do nothing

    }
}