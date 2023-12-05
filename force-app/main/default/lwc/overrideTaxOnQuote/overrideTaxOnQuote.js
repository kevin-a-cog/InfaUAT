import { LightningElement, api,wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import setExemptStatusToOverride from '@salesforce/apex/OverrideTaxOnQuoteController.setExemptStatusToOverride';
import checkIfTaxApplicable from '@salesforce/apex/OverrideTaxOnQuoteController.checkTaxApplicable';
import TaxBUShipCountryError from '@salesforce/label/c.TaxBUShipCountryError';

export default class OverrideTaxOnQuote extends LightningElement {
    @api recordId;
    loading = true;
    labels = {TaxBUShipCountryError};
    isTaxApplicable = false;
    statusMsg;
    //To check if the Tax is applicable for the Quotes Ship to Country
    @wire(checkIfTaxApplicable, { quoteId: '$recordId' }) setisTaxApplicable({ error, data }) {
        console.log('data:-'+data);
        if (data == true) {
            console.log('In true');
            this.isTaxApplicable = data;
            this.statusMsg = "Tax cannot be updated once Overriden. Please click on 'Confirm' to Override Tax.";
        }else if(data == false){            
            console.log('In false');
            this.isTaxApplicable = false;
            this.statusMsg = this.labels.TaxBUShipCountryError;
        } else if (error) {
            this.isTaxApplicable = false;
            this.statusMsg = this.labels.TaxBUShipCountryError;
        }
        this.loading = false;
    };

    overrideTax() {
        this.loading = true;
        setExemptStatusToOverride({ quoteId: this.recordId })
            .then((result) => {
                if (result == 'Success') {
                    console.log('In Success....');
                    let event = new ShowToastEvent({
                        title: 'Tax Override Successful',
                        message: 'Quote Tax Exempt Status set to "Override" Successfully',
                        variant: 'success'
                    });
                    this.dispatchEvent(event);
                    this.dispatchEvent(new CloseActionScreenEvent());
                } else {
                    console.log('In Failed...');
                    let event = new ShowToastEvent({
                        title: 'Tax Override Failed',
                        message: 'Quote Tax Exempt Status could not be set as "Override"',
                        variant: 'error'
                    });
                    this.dispatchEvent(event);
                    this.dispatchEvent(new CloseActionScreenEvent());
                }
            }).catch((error) => {
                let event = new ShowToastEvent({
                    title: 'Tax Override Failed',
                    message: 'Quote Tax Exempt Status could not be set as "Override"',
                    variant: 'error'
                });
                this.dispatchEvent(event);
                this.dispatchEvent(new CloseActionScreenEvent());
            });
    }
    closeWindow(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}