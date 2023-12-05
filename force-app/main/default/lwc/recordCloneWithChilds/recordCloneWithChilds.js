import {
    LightningElement,
    api
} from 'lwc';
import cloneRecords from '@salesforce/apex/RecordCloneWithChildController.cloneObjectSingle';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
    CloseActionScreenEvent
} from 'lightning/actions';

export default class RecordCloneWithChilds extends LightningElement {

    showSpinner = true;
    response;
    _recordId;

    @api set recordId(value) {
        this._recordId = value;
        this.handleClone();
    }

    get recordId() {
        return this._recordId;
    }

    //closing lightning quick action
    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    //show toast message notification.
    showToastNotification(variant, title, message) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    //call cloneRecords Apex method to trigger cloning process asynchronously
    handleClone() {
        cloneRecords({
                clonedQuoteId: this.recordId
            })
            .then((result) => {
                this.response = result.Message
                this.showSpinner = false;
                this.error = undefined;
                setTimeout(() => {
                    this.closeAction();
                }, 3000);
            })
            .catch((error) => {
                this.showSpinner = false;
                this.response = 'Error Occured : ' + JSON.stringify(error.body.message);
            });
    }

}