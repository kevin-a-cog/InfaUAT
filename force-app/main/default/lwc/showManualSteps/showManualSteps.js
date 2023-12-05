import {LightningElement,api, track, wire } from 'lwc';
import getManualStepRecs from '@salesforce/apex/UserProvisioningHandler.getManualSteps';

export default class ShowManualSteps extends LightningElement {
    @api recordId;
    
    @wire(getManualStepRecs,{UserProvisioningId : '$recordId'}) manualSteps;

}