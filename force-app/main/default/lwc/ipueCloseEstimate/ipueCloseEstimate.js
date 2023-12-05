import { LightningElement,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import ES_STATUS_FIELD from '@salesforce/schema/Estimation_Summary__c.Status__c';
import PRIMARY_FIELD from '@salesforce/schema/Estimation_Summary__c.Primary__c';
import ID_FIELD from '@salesforce/schema/Estimation_Summary__c.Id';

const fields = [ID_FIELD,ES_STATUS_FIELD, PRIMARY_FIELD];
export default class IpueCloseEstimate extends LightningElement {

    @api recordId;
    showSpinner = false;
    
    @api invoke() {
        this.showSpinner = true;
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[ES_STATUS_FIELD.fieldApiName] = "Finalized Agreement";
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
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Something is wrong',
                    message: error.body.message,
                    variant: 'error'
                })
             ); 
        });
    }
}