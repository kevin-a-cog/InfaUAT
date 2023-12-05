import { LightningElement, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchExistingData from '@salesforce/apex/IPUE_CreateEstimationPageController.getExistingData';
import { CloseActionScreenEvent } from 'lightning/actions';
import createEstimationModel from '@salesforce/apex/IPUE_CreateEstimationPageController.createEstimationModel';
import checkForValidForm from '@salesforce/apex/IPUE_CreateEstimationPageController.checkForValidForm';
import { NavigationMixin } from 'lightning/navigation';
import inactiveIPUErrorMessage from '@salesforce/label/c.InactiveIPUErrorMessage';



export default class IpueCreateEstimation extends NavigationMixin(LightningElement) {
    @api recordId;

    estimationName = '';
    formId = '';
    isFormActive = true;
    accountId;
    oppId;
    quoteId;
    databaseProcessing = false;
    disableButtons = false;
    isClone = false;
    title;
    cloneCollaborator = true;
    labels = { inactiveIPUErrorMessage };

    @wire(fetchExistingData, { sObjectId: '$recordId' })
    returnedResults(existingData) {
        if (existingData.data) {

            this.title = 'Create IPU Estimation'

            if (existingData.data.sObjectType == 'Account') {
                this.accountId = this.recordId;
            } else if (existingData.data.sObjectType == 'Opportunity') {
                this.oppId = this.recordId;
                this.accountId = existingData.data.sourceObject.AccountId;
            } else if (existingData.data.sObjectType == 'SBQQ__Quote__c') {
                this.quoteId = this.recordId;
                this.accountId = existingData.data.sourceObject.SBQQ__Account__c;
                this.oppId = existingData.data.sourceObject.SBQQ__Opportunity2__c;
            } else if (existingData.data.sObjectType == 'Estimation_Summary__c') {
                this.title = 'Clone IPU Estimation';
                this.isClone = true;
                //this.quoteId = existingData.data.sourceObject.Quote__c;
                this.accountId = existingData.data.sourceObject.Account__c;
                this.oppId = existingData.data.sourceObject.Opportunity__c;
                this.formId = existingData.data.sourceObject.Form__c;
                this.isFormActive = existingData.data.sourceObject.Form__r.Active__c;
            }
        }
    }

    handleCheckboxChange(event) {
        this.cloneCollaborator = event.detail.checked;
    }

    handleNameChange(event) {
        this.estimationName = event.detail.value;
    }

    handleFormChange(event) {
        this.formId = event.detail.value[0];
    }


    get isNotVisible() {

        if (!this.isFormActive) {
            this.disableButtons = true;
        }

        return !this.isFormActive;


    }

    handleSave() {

        if (this.estimationName != '') {
            this.disableButtons = true;
            checkForValidForm({ 'formIdSignature': this.formId })
                .then((result) => {
                    if (result) {
                        this.template.querySelector('lightning-record-edit-form').submit();
                        this.databaseProcessing = true;
                    }
                }).catch(err => {
                    this.databaseProcessing = false;
                    this.disableButtons = false;

                    this.showToast(
                        'Required Fields Missing',
                        'Please fill out all required fields before submitting',
                        'error',
                    );
                });
        } else {
            this.databaseProcessing = false;

            this.showToast(
                'Required Fields Missing',
                'Please fill out all required fields before submitting',
                'error',
            );
        }
    }

    handleSuccess(event) {

        let previousEstimationId = this.isClone ? this.recordId : null;

        //Added an extra parameter to check for cloning estimator collaborators
        createEstimationModel({ estimationId: event.detail.id, previousEstimationId: previousEstimationId, cloneCollaborators: this.cloneCollaborator })
            .then((result) => {
                if (result) {
                    this.databaseProcessing = false;
                    this.getUrlAndShowToast(event.detail.id);
                    this.closeModal();
                }
            })
            .catch((err) => {

                console.error(err);

                this.databaseProcessing = false;
                let message = err.body.message ? err.body.message : 'Unknown Error';

                this.showToast(
                    'Error Creating IPU Estimator',
                    'Please contact your System Administrator for assistance. Error Message: ' + message,
                    'error',
                    'sticky'
                );

            })
    }

    handleError(event) {
        this.databaseProcessing = false;
        console.log(JSON.stringify(event.detail.detail));
        this.showToast(
            'Error Creating Estimation Summary',
            event.detail.detail,
            'error',
            'sticky'
        );
    }

    getUrlAndShowToast(resultId) {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: resultId,
                actionName: 'view',
            },
        }).then(url => {
            const event = new ShowToastEvent({
                title: "Success!",
                message: "Estimation Summary created! {0}!",
                messageData: [
                    {
                        url,
                        label: 'Click here to view the Record'
                    }
                ],
                variant: 'Success'
            });
            this.databaseProcessing = false;
            this.dispatchEvent(event);
        });
    }

    showToast(title, message, variant, modeOption) {

        let mode = modeOption ? modeOption : 'dismissible';

        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        }));
    }

    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}