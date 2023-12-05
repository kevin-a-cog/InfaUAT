/*
Component Name:  IpueShareEstimatorWizard
@Author: Chandana Gowda
@Created Date: 24 Jan 2022
@Jira: IPUE-156
*/
import { LightningElement, track,api} from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class IpueShareEstimatorWizard extends LightningElement {
    @track currentStep = '1';
    @api recordId;
    selectedContactIds;
 
    get isStepOne() {
        return this.currentStep === "1";
    }
 
    get isStepTwo() {
        return this.currentStep === "2";
    }
 
    handleNext(event){
        this.selectedContactIds = event.detail;
        this.currentStep = "2";
    }

    handlePrevious(event){
        this.selectedContactIds = event.detail;
        this.currentStep = "1";
    }

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}