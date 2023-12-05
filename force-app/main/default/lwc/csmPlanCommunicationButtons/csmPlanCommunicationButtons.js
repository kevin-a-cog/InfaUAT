/*
 * Name			    :	CsmPlanCommunicationButtons
 * Author		    :	Monserrat Pedroza
 * Created Date	    :   2/10/2021
 * Description	    :	CsmPlanCommunicationButtons controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			    Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza	    2/10/2021		    N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api } from 'lwc';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Custom labels.
import Insert_Meeting from '@salesforce/label/c.Insert_Meeting'; 
import Insert_Availability from '@salesforce/label/c.Insert_Availability';

//Class body.
export default class CsmPlanCommunicationButtons extends LightningElement {

	//API variables.
	@api recordId;

	//Private variables.
	boolOpenScheduler = false;
	boolIsSendSchedule = false;
	boolIsCreateInvite = false;
	lstButtons = [
		{
			keyValue: "1",
			label: Insert_Meeting,
			variant: '',
			title: Insert_Meeting,
			iconName: 'utility:event',
			iconPosition: 'left',
			styleClass: 'slds-m-horizontal_x-small',
			name: 'insert_meeting',
			showButton: true
		},
		{
			keyValue: "2",
			label: Insert_Availability,
			variant: '',
			title: Insert_Availability,
			iconName: 'utility:shift_scheduling_operation',
			iconPosition: 'left',
			styleClass: 'slds-m-horizontal_x-small',
			name: 'insert_availability',
			showButton: true
		}
	];

    /*
	 Method Name : handleClick
	 Description : This method gets executed on click.
	 Parameters	 : None
	 Return Type : None
	 */
    handleClick(objEvent){
        let objParent = this; 
        switch (objEvent.currentTarget.name) {
            case 'insert_meeting':
                objParent.getEventCreated();
            break;
            case 'insert_availability':
                objParent.getScheduleShared();
            break;
        }
    }

	/*
	 Method Name : getScheduleShared
	 Description : This method opens the Scheduler and gets it ready to return the shared schedule.
	 Parameters	 : Object, called from getScheduleShared, objComponent Component reference.
	 Return Type : None
	 */
	getScheduleShared() {
		this.boolOpenScheduler = true;
		this.boolIsSendSchedule = true;
		this.boolIsCreateInvite = false;
	}

	/*
	 Method Name : getEventCreated
	 Description : This method opens the Scheduler and gets it ready to return the created event.
	 Parameters	 : Object, called from getEventCreated, objComponent Component reference.
	 Return Type : None
	 */
	getEventCreated() {
		this.boolOpenScheduler = true;
		this.boolIsSendSchedule = false;
		this.boolIsCreateInvite = true;
	}

	/*
	 Method Name : closeModal
	 Description : This method closes the Scheduler modal.
	 Parameters	 : None
	 Return Type : None
	 */
	closeModal() {
		this.boolOpenScheduler = false;
	}

	/*
	 Method Name : shareLink
	 Description : This method shares the data received from the scheduler with the parent.
	 Parameters	 : Object, called from shareLink, objEvent Event reference.
	 Return Type : None
	 */
	shareLink(objEvent) {
		const { strHTMLBody } = objEvent.detail;
		this.boolOpenScheduler = false;
		if(objUtilities.isNotBlank(strHTMLBody)) {
			this.dispatchEvent(new CustomEvent('sharelink', {
				composed: true,
				bubbles: true,
				cancelable: true,
				detail: {
					strHTMLBody: strHTMLBody
				}
			}));
		}
	}

	/*
	 Method Name : popOut
	 Description : This method pops out or pops in the component.
	 Parameters	 : Event, called from popOut, objEvent dispatched event.
	 Return Type : None
	 */
    popOut(objEvent) {
		this.template.querySelectorAll(".schedulerModal").forEach(objElement => {
			if(objElement.classList.contains("slds-modal__container")) {
				if(objEvent.detail.boolIsPopingOut) {
					objElement.classList.add("fullyExpanded-container");
				} else {
					objElement.classList.remove("fullyExpanded-container");
				}
			} else if(objElement.classList.contains("slds-modal__content")) {
				if(objEvent.detail.boolIsPopingOut) {
					objElement.classList.add("fullyExpanded-content");
				} else {
					objElement.classList.remove("fullyExpanded-content");
				}
			}
		});
    }
}