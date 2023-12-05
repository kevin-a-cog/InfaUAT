import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import recalculateOARR from '@salesforce/apex/UpdateRenewalOpportunityOARRController.recalculateOARR';
import recalculate_OARR_Body_Text from '@salesforce/label/c.Recalculate_OARR_Body_Text';
import recalculate_OARR_Success_Text from '@salesforce/label/c.Recalculate_OARR_Success_Text';
import Recalculate_OARR_Title from '@salesforce/label/c.Recalculate_OARR_Title';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class UpdateRenewalOpportunityOARR extends LightningElement {

    error;
    isLoading = false;
    @api recordId;

    label = {
        recalculate_OARR_Body_Text,
        recalculate_OARR_Success_Text,
        Recalculate_OARR_Title
    };

    submitForRecalculation() {
        this.isLoading = true;
        recalculateOARR({ oppId:  this.recordId})
        .then(result => {

            this.showToast('Success! ', this.label.recalculate_OARR_Success_Text, 'success');
            this.closeAction();
            this.isLoading = false;
        })
        .catch(error => {
            this.error = error;
            this.showToast('Something went wrong', error.body.message, 'error');
            this.closeAction();
            this.isLoading = false;
            return;
        });

    }

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }



}