import { LightningElement,api, wire } from 'lwc';
import fetchColumnDetails from '@salesforce/apex/psa_BEI_QLI_Controller.fetchColumnDetails';
import updateBillingEventItems from '@salesforce/apex/psa_BEI_QLI_Controller.updateBillingEventItems';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
const columns = [
    { label: 'Quote Line Name', fieldName: 'quoteLineName', type: 'string', initialWidth: 120, wrapText:true},
    { label: 'Product Name', fieldName: 'oppProductName', type: 'string', wrapText:true},
    { label: 'Budget Name', fieldName: 'budgetName', type: 'string', wrapText:true},
];

export default class Psa_BillingEventItem_QuoteLineItem extends LightningElement {
    @api recordId;
    hasRecords;
    wrapperDetails;
    error;
    loading = true;
    columns = columns;
    quoteLineItemId;
    noRecordMsg;
    
    //Fetch datatable details from Apex method - On load
    @wire(fetchColumnDetails, { recordId : '$recordId'})
    wiredQLDetails({ error, data }) {
        if (data) {
            if(data.length > 0){
                if(!data[0].errorMsg){                
                    this.wrapperDetails = data;
                    this.hasRecords = true;
                    this.error = undefined;
                }
                else{
                    this.hasRecords = false;
                    this.noRecordMsg = data[0].errorMsg;
                }
            }
        } 
        else if (error) {
            this.error = error;
            this.wrapperDetails = undefined;
        }
        this.loading = false;
    }

    getSelectedId(event) {
        const selectedRows = event.detail.selectedRows;
        // Display that fieldName of the selected rows
        for (let i = 0; i < selectedRows.length; i++) {
            this.quoteLineItemId = selectedRows[i].quoteLineId;
        }
    }
    //On clicking save
    handleSave(){
        this.loading = true;
        
        updateBillingEventItems( { recordId: this.recordId, quoteLineId: this.quoteLineItemId} )
        .then( result => {
            if(result == 'SUCCESS'){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Quote Line Item is mapped to the Billing Event Items successfully!',
                        variant: 'success'
                    })
                );
                this.dispatchEvent(new CloseActionScreenEvent());
            }
        })
        .catch((error) => {
            this.error = error;
            // This way you are not to going to see [object Object]
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Failed',
                    message: 'Please give the error to the Salesforce administrator:'+error.body.message,
                    variant: 'error'
                })
            );
            this.dispatchEvent(new CloseActionScreenEvent());
        }); 
    }
}