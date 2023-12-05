/*
 * Name			:	CsmPlanActivityContainer
 * Author		:	Deva M
 * Created Date	: 	05-April-2022
 * Description	:	Manage activity container 

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M         		05-April-2022		N/A				Initial version.			N/A
 */
import { api, LightningElement } from 'lwc';

export default class CsmPlanActivityContainer extends LightningElement {
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