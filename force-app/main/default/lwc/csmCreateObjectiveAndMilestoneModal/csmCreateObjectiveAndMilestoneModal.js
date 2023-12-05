/* Name			    :	CsmCreateObjectiveAndMilestoneModal
* Author		    :	Deva M
* Created Date	    :   14/09/2021
* Description	    :	CsmCreateObjectiveAndMilestoneModal controller.

Change History
**********************************************************************************************************
Modified By			Date			    Jira No.		Description					Tag
**********************************************************************************************************
Deva M		        10/08/2021		N/A				  Initial version.			N/A
*/
//Core imports
import { api, LightningElement, track,wire } from 'lwc';
import fetchPlanProducts from '@salesforce/apex/CSMObjectiveAndMilestoneViewController.fetchPlanProducts';
import createObjectiveProducts from '@salesforce/apex/CSMManageObjectiveProducts.getRecordsRelated';
//import createMilestoneWithProducts from '@salesforce/apex/CSMObjectiveAndMilestoneViewController.createMilestoneWithProducts';

//Apex Controllers.
import isCSMSuccessCommunity from "@salesforce/apex/CSMObjectivesAndMilestonesController.isCSMSuccessCommunity";

//Utilities.
import { objUtilities } from 'c/globalUtilities';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

import IS_INTERNAL from "@salesforce/schema/Plan__c.Is_Internal__c";

const fields = [IS_INTERNAL];

export default class CsmCreateObjectiveAndMilestoneModal extends LightningElement {
    @api planRecord;
   	//Private variables.    
		boolIsCSMCommunity = false;
    currentStep = 1;
    showSpinner = false;
    objectiveId;
    closeObjectiveModal;
    saveObectiveAndAddMilestone=false;
    
    planProducts;
    selectedObjectiveProducts = [];

    isPlanInternal = true;

    @wire(getRecord, { recordId: "$planRecord", fields })
	planRecordDetails({data,error}){
        if(data){
            this.isPlanInternal = data.fields.Is_Internal__c.value;
        }
    }

    get disableSaveAddMilestoneButton() {
        return this.showSpinner || !(this.selectedObjectiveProducts && this.selectedObjectiveProducts.length);
    }

    get header() {
        if (this.currentStep === 1) {
            return 'Add Objective';
        } else if (this.currentStep === 2) {
            return 'Add Objective Product(s)';
        } else if (this.currentStep === 3) {
            return 'Add Milestone(s)';
        }
    }

    get showSaveAndNext() {
        return this.currentStep == 1;
    }

    get showSaveAndClose() {
        return (this.selectedObjectiveProducts && this.selectedObjectiveProducts.length>0 && this.currentStep == 2) || this.currentStep == 3;
    }

    get showSaveAddMilestone() {
        return ((this.currentStep == 2 || this.currentStep == 3) && (this.selectedObjectiveProducts && this.selectedObjectiveProducts.length>0));
    }

    get showBack() {
        return this.currentStep !== 1;
    }

    get isStep1() {
        return this.currentStep == 1;
    }

    get isStep2() {
        return this.currentStep == 2;
    }

    get isStep3() {
        return this.currentStep == 3;
    }


    connectedCallback() {
		let objParent = this;
        this.showSpinner = true;

		//We check if the current user is a Community User.
		isCSMSuccessCommunity().then(boolIsCSMCommunity => {
			objParent.boolIsCSMCommunity = boolIsCSMCommunity;
			objParent.showSpinner = false;
		});
    }
    handleCancel(){
        this.dispatchEvent(new CustomEvent('close'));  
    }
    handleClick(event) {
        switch (event.target.dataset.name) {
            case 'cancel':
                this.dispatchEvent(new CustomEvent('close'));
                break;
            case 'closeModal':
                this.dispatchEvent(new CustomEvent('close'));
                break;
            case 'back':
                if (this.currentStep == 2) {
                    this.showSpinner = true;
                }
                this.currentStep--;
                break;

            case 'saveAndNext':
                if (this.currentStep == 1 && this.validate()) {
                    this.showSpinner = true;
                    this.closeObjectiveModal=false;
                    this.template.querySelector('[data-name="objectiveFormSubmitButton"]').click();
                }
                break;
            case 'saveObectiveAndClose':
                if(this.currentStep == 1 && this.validate()){
                    this.showSpinner = true;
                    this.closeObjectiveModal=true;
                    this.template.querySelector('[data-name="objectiveFormSubmitButton"]').click();
                }
                break;
            case 'saveObectiveAndAddMilestone':
                if(this.currentStep == 1 && this.validate()){
                    this.showSpinner = true;
                    this.saveObectiveAndAddMilestone=true;
                    this.template.querySelector('[data-name="objectiveFormSubmitButton"]').click();
                }
            break;
            case 'saveAndClose':
                if (this.currentStep === 2) {
                    if (this.selectedObjectiveProducts && this.selectedObjectiveProducts.length) {
                        this.saveObjectiveProduct();
                        this.dispatchEvent(new CustomEvent('close'));
                    } else {
                        this.dispatchEvent(new CustomEvent('close'));
                    }
                }

                if (this.currentStep === 3) {
                   /* let dataArr = [];
                    let isValid = true;
                    this.template.querySelectorAll('c-create-milestone-with-product').forEach(mp => {
                        const milestoneData = mp.getMilestoneData();
                        if (milestoneData) {
                            dataArr.push(milestoneData);
                        } else {
                            isValid = milestoneData;
                        }
                    });
                    if (!isValid) {
                        return;
                    }
                    this.showSpinner = true;

                    createMilestoneWithProducts({
                        dataStr: JSON.stringify(dataArr)
                    })
                        .then(() => {
                            this.dispatchEvent(new CustomEvent('close'));
                            this.dispatchEvent(new ShowToastEvent({
                                title: '',
                                message: 'Record(s) created successfully!',
                                variant: 'success'
                            }));
                        })
                        .catch(err => {
                            console.log('ERR>>>', JSON.stringify(err));
                            this.dispatchEvent(new ShowToastEvent({
                                title: '',
                                message: error.body.message,
                                variant: 'error'
                            }));
                        })
                        .finally(() => this.showSpinner = false);*/
                }

                break;

            case 'saveAndAddMilestone':
                if (this.currentStep == 2) {
                    this.saveObjectiveProduct();
                }
                break;

            default:
                break;
        }
    }

    validate() {
        let isValid = true;
        this.template.querySelectorAll('lightning-input-field').forEach(ip => {
            isValid = ip.reportValidity();
        });
        return isValid;
    }


    handleLoad() {
        this.showSpinner = false;
    }

    handleError() {
        this.showSpinner = false;
    }

    handleProductSelect(event) {
        
        if(objUtilities.isNotNull(event.detail.selectedRows)){
            let lstRecords = new Array();
            event.detail.selectedRows.forEach(objSelectedRecord => {
                lstRecords.push(
                    objUtilities.isNotNull(objSelectedRecord.Id) ? objSelectedRecord.Id :objSelectedRecord
                );
            });
            this.selectedObjectiveProducts = lstRecords;
        }
    }

    handleObjectiveSuccess(event) {
        let objParent = this;
        if(this.saveObectiveAndAddMilestone && this.saveObectiveAndAddMilestone==true){
            this.currentStep=3;
            this.showSpinner = false;
            this.objectiveId = event.detail.id;
        }else if(this.closeObjectiveModal && this.closeObjectiveModal==true){
            this.dispatchEvent(new CustomEvent('close'));
            objUtilities.showToast('Success','Record(s) Created successfully!!','success',objParent); 
            this.showSpinner = false;
        }else{
            this.objectiveId = event.detail.id;
            this.currentStep++;
            fetchPlanProducts({   planId: this.planId })
            .then(response => this.planProducts = response)
            .catch((objError) => {
                objUtilities.processException(objError, objParent);
            }).finally(() => {
                this.showSpinner = false;
            });        
        }
    }


    saveObjectiveProduct() {
        let objParent = this;
        this.showSpinner = true;
        createObjectiveProducts({
            strRecordId: this.objectiveId,
            lstRecords: this.selectedObjectiveProducts
        }).then(() => {
            this.currentStep++;
            objUtilities.showToast('Success','Objective with Product(s) created successfully!','success',objParent);  
        })
        .catch(objError => {
            objUtilities.processException(objError, objParent);
        })
        .finally(() => {
            this.showSpinner = false;
        });
    }


}