import { LightningElement,api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import ES_STATUS_FIELD from '@salesforce/schema/Estimation_Summary__c.Status__c';
import ID_FIELD from '@salesforce/schema/Estimation_Summary__c.Id';
import userRecordAccess from '@salesforce/apex/SubmitEstimateController.commUserAccess';
const fields = [ID_FIELD,ES_STATUS_FIELD];
export default class IpueInitializeAgreementES extends NavigationMixin(LightningElement) {

    clickedButtonLabel = 'Submit Estimate'; 
    isSelected;
    @api recordId;
    record = '';
    error;
    errorUA;
    status;
    showSpinner;
    userAccess;

    @wire(getRecord, {recordId: '$recordId',fields})
    estimationSummary;

    @wire(userRecordAccess, {recordId: '$recordId'})
    userAccessSubmit ({error, data}) { 
        if (data) { 
            this.userAccess = data;
        } else if (error) { 
            this.errorUA = error;
        }
    }

    
//scenaraio's considered external users  cannot change status field
    handleClick(event) {  
        //const label = document.getElementById('subEst').innerHTML;
        const label = event.target.label;  

        if (label === 'Submit Estimate' ) {  
            this.isSelected = true;   
        } else {  
            this.isSelected = false;  
        }  
    }
    
    handleSuccess(event){
        this.showSpinner = true;
        const rec_Id = this.recordId;
        const fields = {};
        fields[ID_FIELD.fieldApiName] = rec_Id;
        fields[ES_STATUS_FIELD.fieldApiName] = "Initialized Agreement";

        const recordInput = {
            fields
        };
        updateRecord(recordInput)
            .then(() => {
                this.showSpinner = false;
                this.isSelected = false;
                this.showToastMessage('Success', 'Estimated Summary status updated', 'success', 'dismissable');
                this.refreshEstimationSummary(); //refresh page once submitted to make the estimator read only
            })
            .catch(error => {
                this.showSpinner = false;
                console.log('Error occured', JSON.stringify(error));
            });
    }

    get isSelectDraft() {  
        this.status = getFieldValue(this.estimationSummary.data, ES_STATUS_FIELD);
        return this.status === 'Draft';
    }

    showToastMessage(title, message, variant, mode) {
        this.dispatchEvent(
            new ShowToastEvent({
                title : title,
                message : message,
                variant : variant,
                mode : mode
            })
        ); 
    }

    refreshEstimationSummary(){

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Estimation_Summary__c',
                actionName: 'view'
            }
        });        
    }    

    closeAction(){
        this.isSelected = false;
    }
}