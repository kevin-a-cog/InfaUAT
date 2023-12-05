import { LightningElement, api } from 'lwc';
import findIPUPicklistValues from '@salesforce/apex/IPUTypePicklistController.findIPUPicklistValues';
import updateIPUType from '@salesforce/apex/IPUTypePicklistController.updateIPUType';

export default class IPUTypePicklist extends LightningElement {

    @api recordId;
    picklistVal;
    selectedValue;
    selectedIPUValue;

    connectedCallback() {
        this.fetchRecords();
    }


    fetchRecords() {
        findIPUPicklistValues({ estimatorId: this.recordId })
            .then(result => {
                this.picklistVal = result;
            })
            .catch(error => {
                console.error(JSON.stringify(error));
            });
    }

    selectOptionChanveValue(event) {
        
        event.stopPropagation();
        this.selectedIPUValue = event.target.value;
        
        updateIPUType({
            estimatorId: this.recordId,
            selectedValue: this.selectedIPUValue
        }).then(result => {

        }).catch(error => {
            console.error(JSON.stringify(error));
        });;
    }
}