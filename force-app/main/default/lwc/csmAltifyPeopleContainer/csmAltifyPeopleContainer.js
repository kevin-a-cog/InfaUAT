//Core imports
import { api, LightningElement } from 'lwc';
import hasPermission from '@salesforce/customPermission/Altify_Permission';
export default class CsmAltifyPeopleContainer extends LightningElement {
    
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
    /*
	 Method Name : 	 get isAltifyVisible()
	 Description : This method used to check Altify Access in the component.
	 Parameters	 : None
	 Return Type : Boolean
	 */
	 get isAltifyVisible() {
        return hasPermission;
    }

}