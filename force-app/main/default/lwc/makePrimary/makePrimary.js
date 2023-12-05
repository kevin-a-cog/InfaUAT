import { LightningElement, api, wire } from 'lwc';
import PRIMARY_FIELD from '@salesforce/schema/Estimation_Summary__c.Primary__c';
import ID_FIELD from '@salesforce/schema/Estimation_Summary__c.Id';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';

export default class MakePrimary extends LightningElement {
    @api recordId;
    showSpinner;

    @api invoke() {
        this.showSpinner = true;
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[PRIMARY_FIELD.fieldApiName] = true;
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