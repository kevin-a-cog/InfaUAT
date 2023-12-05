import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import CheckTaxApplicableAndErrorMessage from '@salesforce/apex/taxICRTControllerExtension.CheckTaxApplicableAndErrorMessage';
import TaxBUShipCountryError from '@salesforce/label/c.TaxBUShipCountryError';
import TaxExemptOverrideError from '@salesforce/label/c.TaxExemptOverrideError';
import TaxNoQuoteLinesError from "@salesforce/label/c.TaxNoQuoteLinesError";
// import TaxOrderError from "@salesforce/label/c.TaxOrderError";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class UpdateTaxAction extends NavigationMixin(LightningElement) {
    
    @api recordId;    
    labels = {TaxBUShipCountryError,TaxExemptOverrideError,TaxNoQuoteLinesError};
    statusMsg;
     @api invoke() {
       CheckTaxApplicableAndErrorMessage({quoteId:this.recordId})
            .then(result => {
                if (result == "True") {
                    this.navigateToVFPage();
                }else if(result == "exemptError"){ 
                    this.statusMsg = this.labels.TaxExemptOverrideError;      
                    this.showErrorMessage();
                }else if(result == "generalError"){   
                    this.statusMsg = this.labels.TaxNoQuoteLinesError;      
                    this.showErrorMessage();
                    
                }
                // else if(result == "orderError"){      
                //     this.statusMsg = this.labels.TaxOrderError;      
                //     this.showErrorMessage();
                // }
                else if(result == "False"){      
                    this.statusMsg = this.labels.TaxBUShipCountryError;      
                    this.showErrorMessage();
                }
            })
            .catch(error => {
                console.log(error)
            });
    } 
    
    //Navigating the user to the visualforce page to generate the document
    navigateToVFPage() {
         this[NavigationMixin.GenerateUrl]({
             type: 'standard__webPage',
             attributes: {
                url: '/apex/UpdateTaxIcrt?id=' + this.recordId
            }
        }).then(generatedUrl => {
            window.open(generatedUrl,"_self");
        });
     }

     showErrorMessage() {
        const evt = new ShowToastEvent({
            title: 'Error in Updating Tax',
            message: this.statusMsg,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

}