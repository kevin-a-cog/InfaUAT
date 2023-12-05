import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendOutboundMessage from '@salesforce/apex/SendOutboundMessageController.sendOutboundMessage';
import emailStatus from '@salesforce/label/c.FulFillment_Sendmail_Action_Message';

export default class SendOutboundMessageManually extends LightningElement {
    isExecuting = false;
@api recordId; 
@track errorMessage;   
@api 
async invoke() {
    let params = {
        "recordId" : this.recordId
    }
    sendOutboundMessage(params).then(result => {
      this.showSuccessToast();
    }
    ).catch(error =>{
      this.errorMessage = error;
      this.showErrorToast();
    }
    );
}
showSuccessToast() {
        const evt = new ShowToastEvent({
            title: 'Email Status',
            message: emailStatus,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
}
showErrorToast() {
        const evt = new ShowToastEvent({
            title: 'Email Status',
            message: 'Some unexpected error occured '+JSON.stringify(this.errorMessage),
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
}
}