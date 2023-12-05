//Core imports
import { wire,api, LightningElement } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

//Plan object fields
import PLAN_ACCOUNT from '@salesforce/schema/Plan__c.Account__c';
//Custom Labels
import Loading from '@salesforce/label/c.Loading';
export default class CsmAltifyPeoplePage extends LightningElement {

    //Labels.
	label = {
		Loading
	}
    siteURL;
    @api recordId;
    planAccountId;
    boolDisplaySpinner;
    @api isPoppedOut;

    get className(){
      //if changeStle is true, getter will return popout_frame else popIn_frame
        return this.isPoppedOut ? 'popout_frame': 'popIn_frame';
    }

    @wire(getRecord, { recordId: '$recordId', fields: [PLAN_ACCOUNT] })
    planRecord({ error, data }) {
        this.boolDisplaySpinner=true;
        if (error) {
            this.boolDisplaySpinner=false;
        } else if (data) {
            this.planAccountId = data.fields.Account__c.value            
            if(this.planAccountId){
                this.siteURL = '/apex/altf__altify_people_problems#!/'+this.planAccountId+'/all/none/map?fullscreen=true';
                this.boolDisplaySpinner=false;
            }
        }
    }
    connectedCallback(){
        this.boolDisplaySpinner=true;
    }
 
    	/*
	 Method Name : popOut
	 Description : This method gets executed when the user tries to pop out or pop in the component.
	 Parameters	 : Event, called from popOut, objEvent click event.
	 Return Type : None
	 */
	popOut(objEvent) {
		let boolIsPopingOut;

        //First we define the operation.
        switch (objEvent.target.dataset.name) {
            case 'popOut':
                boolIsPopingOut = true;
            break;
            case 'popIn':
                boolIsPopingOut = false;
            break;
        }

		//Now we send the event.
        this.dispatchEvent(new CustomEvent('popout', {
			detail: {
				boolIsPopingOut: boolIsPopingOut
			}
		}));
    }

}