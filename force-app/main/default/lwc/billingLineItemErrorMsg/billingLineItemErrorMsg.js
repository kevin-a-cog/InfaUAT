import { LightningElement, api, wire } from 'lwc';
import areChildRecordsEqual from '@salesforce/apex/psa_BEI_QLI_Controller.areChildRecordsEqual';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class BillingLineItemErrorMsg extends LightningElement {
@api recordId;

@wire(areChildRecordsEqual, { parentId : '$recordId' })
    handleError(){
        areChildRecordsEqual({parentId: this.recordId})
        .then(result =>{
            if(!result){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Warning',
                        message: '"Multiple quote lines are identified for this Billing Event"',
                        variant: 'Warning'
                    })
                );
            }
        })
        .catch((error) => {
            console.log('In handleSave error....');
            this.error = error;
            console.log('Error is', this.error); 
        }); 
    }
}