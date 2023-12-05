import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import requestAttn from '@salesforce/apex/CaseController.requestAttn';

export default class CaseEscalate extends LightningElement {

    @track requestTypeOptions=[
        {label: 'Revise Priority', value: 'Revise Priority'}, 
        {label: 'Callback from Engineer', value: 'Callback'}
    ];

    @api recordId;
    requestType = 'Callback';

    @track saveInProgress=false;
    connectedCallback(){     

    
        console.log('recid='+this.recordId);
        //this.requestType = this.template.querySelector('[data-id="requestType"]').value;

        console.log("requestType selected - " + JSON.stringify(this.requestType));
        
        this.saveInProgress=true;
        requestAttn({
            caseId: this.recordId,         
            requestType: this.requestType
        })
        .then(result => {
            console.log("result - " + JSON.stringify(result));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Callback from Engineer request submitted successfully!',
                    variant: 'success',
                }),
            );
            this.saveInProgress=false;
            this.closeQuickAction();
        })
        .catch(error => {
            console.log("error - " + JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error escalating the case!',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
            this.saveInProgress=false;
            this.closeQuickAction();
        });
    }

    cancel(){
        this.closeQuickAction;
    }

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }
}