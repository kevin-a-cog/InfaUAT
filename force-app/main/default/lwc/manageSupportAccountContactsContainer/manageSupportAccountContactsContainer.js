import { LightningElement,api,track,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import CASE_SUPPORT_ACCOUNT from '@salesforce/schema/Case.Support_Account__c';

const fields = [CASE_SUPPORT_ACCOUNT];

export default class ManageSupportAccountContactsContainer extends LightningElement {
    @api recordId;

    @track supportAccId;

    @wire(getRecord, { recordId: '$recordId', fields: fields })
    fieldsData({data, error}){
        if(data){
            console.log('CaseLayout::DATA @wire getRecord->'+JSON.stringify(data));
            if(data.fields.Support_Account__c != undefined && data.fields.Support_Account__c.value != null){
                this.supportAccId = data.fields.Support_Account__c.value;
            }
        }
        else if(error){
            console.log('CaseLayout::ERROR @wire getRecord->'+JSON.stringify(error));
        }
    };
}