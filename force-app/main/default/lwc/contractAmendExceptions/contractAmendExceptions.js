import { LightningElement, api,wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import Amendment_Exception_Field from '@salesforce/schema/Contract.Amendment_Exception__c';

export default class ContractAmendExceptions extends LightningElement {
    @api recordId;
    @wire(getRecord, { recordId: '$recordId', fields: [Amendment_Exception_Field] }) contract;  

    get amendException() {
        return getFieldValue(this.contract.data, Amendment_Exception_Field);
    }
    
}