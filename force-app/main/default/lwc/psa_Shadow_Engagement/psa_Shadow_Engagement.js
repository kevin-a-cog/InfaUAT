import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import createShadowEngagement from '@salesforce/apex/psaCreateShadowEngagementController.createShadowEngagement';

export default class Psa_Shadow_Engagement extends NavigationMixin(LightningElement) {
    loaded = true;
    @api recordId;
    shadowObjVal;
    focusAreaVal;
    schUrgVal;
    commentVal;
    trainingVal;
    displayError = false;
    errorMessage;
    handleShadowObjChange(event){
        this.displayError = false;
        this.shadowObjVal = event.target.value;
    }
    handleFocusAreaChange(event){
        this.displayError = false;
        this.focusAreaVal = event.target.value;
    }
    handleShadowSchUrgencyChange(event){
        this.displayError = false;
        this.schUrgVal = event.target.value;
    }
    handletrainingChange(event){
        this.displayError = false;
        this.trainingVal = event.target.value;
    }
    handleCommentChange(event){
        this.displayError = false;
        this.commentVal = event.target.value;
    }
    handleSave(event){
        if(!(this.focusAreaVal && this.trainingVal && this.schUrgVal)){
            this.displayError = true;
            this.errorMessage = "Please fill all the mandatory fields";
        }
        else{
            this.loaded = false;
            createShadowEngagement({conId : this.recordId, shadowObj : this.shadowObjVal, focusArea : this.focusAreaVal, schUrgency : this.schUrgVal,
                training: this.trainingVal, comment : this.commentVal })
            .then((result) => {
            if(result){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Shadow Assignment created',
                    variant: 'success'
                })
            );                
            this.dispatchEvent(new CloseActionScreenEvent());
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: result,
                    objectApiName: 'psa_Shadow_Engagement_Request__c',
                    actionName: 'view'
                }
            });
            }
            })
            .catch((error) => {
            console.log('In handleSave error....');
            this.error = error;
            // This way you are not to going to see [object Object]
            this.dispatchEvent(
            new ShowToastEvent({
                title: 'Failed',
                message: error.body.message,
                variant: 'error'
            })
            );
            this.loaded = true;
            this.dispatchEvent(new CloseActionScreenEvent());
            }); 
            }
        }        
    }