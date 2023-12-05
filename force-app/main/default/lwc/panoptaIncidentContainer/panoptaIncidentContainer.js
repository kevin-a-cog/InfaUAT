import { LightningElement,api } from 'lwc';
import Panopta from '@salesforce/resourceUrl/Panopta';

export default class PanoptaIncidentContainer extends LightningElement {
    @api recordId;
    isPopout = false;
    backgroundimage = Panopta;
    handlepopin(event){
        this.isPopout = false;
        this.template.querySelector("c-panotpa-incidents").handlepopin();
    }

    setpop(event){
        console.log('setpop function');
        this.isPopout = true;
    }
}