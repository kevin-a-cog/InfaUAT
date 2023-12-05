import { LightningElement,api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import ES_STATUS_FIELD from '@salesforce/schema/Estimation_Summary__c.Status__c';
import ID_FIELD from '@salesforce/schema/Estimation_Summary__c.Id';
const fields = [ID_FIELD,ES_STATUS_FIELD];

export default class IpueRevertEstimation extends LightningElement {
    @api recordId;

    status;
    showSpinner;
    
    @wire(getRecord, { recordId: '$recordId', fields: [ID_FIELD,ES_STATUS_FIELD] } )
    estimationSummary;
   

    @api invoke() {
        this.showSpinner = true;
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[ES_STATUS_FIELD.fieldApiName] = "Draft";
        const recordInput = { fields };
        updateRecord(recordInput)
        .then(()=> {
            
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Success',
                    message : 'Estimated Summary updated',
                    variant : 'success',
                    mode : 'dismissable'
                })
            ); 
            this.showSpinner = false;
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Something is wrong',
                    message: error.body.message,
                    variant: 'error'
                })
             ); 
        })
    }
}