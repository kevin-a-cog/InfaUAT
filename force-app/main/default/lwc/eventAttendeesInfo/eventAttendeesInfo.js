/*
 * Name			:	EventAttendeesInfo
 * Author		:	Vignesh Divakaran
 * Created Date	: 	10/02/2022
 * Description	:	This LWC is used to display to informartion about event attendees.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description							Tag
 **********************************************************************************************************
 Vignesh Divakaran		10/02/2022		I2RT-5251		Initial version.					N/A
 */

//Core imports.
import { LightningElement, api, track } from 'lwc';
import getEventAttendeeStatus from "@salesforce/apex/EventDetailController.getEventAttendeeStatus";
import { objUtilities } from 'c/globalUtilities';
import userId from '@salesforce/user/Id';

export default class EventAttendeesInfo extends LightningElement {

	//API Variables
	@api recordId;
	recId;

	//Private Variables
	isLoading;
	@track objEventAttendees = {
		ACCEPTED: { status: 'Accepted', count: 0 },
		DECLINED: { status: 'Declined', count: 0 },
		TENTATIVE: { status: 'Tentative', count: 0 },
		NORESPONSE: { status: 'No Response', count: 0 },
	};



	/*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {

		//We initialize the components.
		this.initializeComponent();
	}

	/*
	 Method Name : initializeComponent
	 Description : This method gets executed after load.
	 Parameters	 : None
	 Return Type : None
	 */
	initializeComponent() {
		let objParent = this;
		objParent.isLoading = true;

		if (objParent.recordId) {
            this.recId = objParent.recordId;
            
        }
        else {
            this.recId = window.location.href.toString().split('?id=')[1];
           
        }

		getEventAttendeeStatus({ recordId: this.recId })
			.then(response => {
				if (Array.isArray(response) && response.length > 0) {
					response.forEach(obj => {
						let intCount = obj.intCount;
						switch (obj.strStatus) {
							case 'Accepted':
								objParent.objEventAttendees.ACCEPTED.count = intCount ; // Don't Increment by 1 to count the organizer.
								break;
							case 'Declined':
								objParent.objEventAttendees.DECLINED.count = intCount;
								break;
							case 'New':
								objParent.objEventAttendees.NORESPONSE.count = intCount;
								break;
							case 'Tentative':
								objParent.objEventAttendees.TENTATIVE.count = intCount;
								break;
							default:
								//Do nothing
								break;
						}
					})
				}
				else {
					//Call Logic
				}
			})
			.catch(objError => {
				objUtilities.processException(objError, objParent);
			})
			.finally(() => {
				objParent.isLoading = false;
			});
	}

}