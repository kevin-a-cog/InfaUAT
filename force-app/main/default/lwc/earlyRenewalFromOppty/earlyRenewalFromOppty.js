import { LightningElement,api, wire } from 'lwc';
import earlyRenew from '@salesforce/apex/CreateAmendQuote.earlyRenew';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Opportunity.Name';
import RENEWAL_CONTRACTID from '@salesforce/schema/Opportunity.SBQQ__RenewedContract__c';
import ACCOUNT_ID_FIELD from '@salesforce/schema/Opportunity.AccountId';
import {CurrentPageReference} from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ELEVATESTATUSMESSAGE from '@salesforce/label/c.ElevateStatusMessage';
import { CloseActionScreenEvent } from "lightning/actions";

const FIELDS = [NAME_FIELD, RENEWAL_CONTRACTID, ACCOUNT_ID_FIELD];
export default class EarlyRenewalFromOppty extends NavigationMixin(LightningElement) {
    @api recordId;
    showSpinner = true;
    //Id of the contract to be amended
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    opportunity;
    label = {
        ELEVATESTATUSMESSAGE
    };

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }
    connectedCallback() {
        console.log(this.recordId);        
        this.showSpinner = true;
        earlyRenew({oppId: this.recordId})
        .then((result) => {
            if(result != undefined){
                if(result[0] == 'Success'){
                    setTimeout(() => {
                    this.redirectToQuote(result[1]);
                    this.showSpinner = false;
                  }, 4000);
                }
                else{
                    this.showSpinner = false;
                    this.closeAction();
                    this.showToast('Error', result[1], 'error');
                }
            }
        })

        .catch((error) => {
            console.log(error);
            this.showSpinner = false;
            console.log('error message', error.body.message);
            this.showToast('Error', error.body.message, 'error');
        });
    }
    redirectToQuote(quoteId){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: quoteId,
                actionName: 'view'
            }
        });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    //closes the modal 
    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}