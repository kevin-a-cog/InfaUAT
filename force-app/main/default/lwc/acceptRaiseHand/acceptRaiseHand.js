import { LightningElement, track, wire,api } from 'lwc';
import acceptRaiseHand from '@salesforce/apex/CasePrioritizationViewLwcV4Ctrl.acceptRaiseHand';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Raise_Hand__c.Case__c',
    'Raise_Hand__c.Id',
    ];

export default class AcceptRaiseHand extends LightningElement {

    @track showspinner = false;
    userId = Id;
    raisehand;
    showspinner = true;
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            
        } else if (data) {
            this.raisehand = data;            
        }
    }

    connectedCallback(){       
        console.log('running accept');
        
        console.log(this.recordId);
            acceptRaiseHand({ lstRHId: this.recordId}).then(result => {                               
                this.showspinner = false;
                this.showToast('Success!' , 'You have accepted the Collaboration Request(s). Please traverse to the request(s) to view the details.' , 'success');
               
                    
                    var closeQA = new CustomEvent('close');                
            
                    this.dispatchEvent(closeQA);
                    console.log('close event fired!')
                
            }).catch(error => {
                this.showspinner = false;
                var stError=JSON.stringify( error);
                var closeQA = new CustomEvent('close'); 	
                this.dispatchEvent(closeQA);
                if(stError.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                    this.showToast('Error!' , 'This request has been accepted by another user.' , 'Error');
               
                }
               
                console.log('error==> ' + JSON.stringify( error));
            });
        }

        showToast(sTitle, sMsg, sVariant) {
            const event = new ShowToastEvent({
                title: sTitle,
                message: sMsg,
                variant : sVariant
            });
            this.dispatchEvent(event);
        }

}