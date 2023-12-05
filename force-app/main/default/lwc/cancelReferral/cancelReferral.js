/*

*******************************************************************************************************************
MODIFIED BY     MODIFIED Date   JIRA        DESCRIPTION                                                         TAG
*******************************************************************************************************************
ChaitanyaT      12-Sep-2023     AR-3383     Expansion Lead workflow added file upload for Source is Plan        T01
*/
import { LightningElement,api,wire } from 'lwc';

import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { CloseActionScreenEvent } from 'lightning/actions';

import getReferralDetails from "@salesforce/apex/ReferralManagementController.getReferralDetails";

import CANCELREASON_FIELD from '@salesforce/schema/iCare_Referral__c.Cancellation_Reason__c';
import OTHER_CANCELREASON_FIELD from '@salesforce/schema/iCare_Referral__c.Other_Cancellation_Reason__c';
import ID_FIELD from '@salesforce/schema/iCare_Referral__c.Id';
import STATUS_FIELD from '@salesforce/schema/iCare_Referral__c.Status__c';
import REF_DISPOSITIONING_INFO from '@salesforce/schema/iCare_Referral__c.Referral_Dispositioning_Information__c';
import SOURCE_FIELD from '@salesforce/schema/iCare_Referral__c.Source__c';
import isSMGGrpMember from "@salesforce/apex/ReferralManagementController.isSMGGrpMember";
import PlanReferralStatusErrorMsg from '@salesforce/label/c.PlanReferralStatusErrorMsg';
import PlanReferralStatusIllegalPathErrMsg from '@salesforce/label/c.PlanReferralStatusIllegalPathErrMsg';

const fields = [SOURCE_FIELD,STATUS_FIELD];

export default class CancelReferral extends NavigationMixin(LightningElement) {
    recId;
    referral;
    showMessage = false;
    showOtherReason = false;

    cancelReason;
    otherCancelReason;
    dispositioningInfo;
    source;
    displayDialog = false;
    label = {PlanReferralStatusErrorMsg,PlanReferralStatusIllegalPathErrMsg};
    intitalStatus;
    showSpinner = false;

    //<T01> start
    @api recordId;

    @wire(getRecord, { recordId: "$recordId", fields })
    wiredgetRecord({ error, data }) {
        if(data){
            this.source = getFieldValue(data, SOURCE_FIELD);
            this.intitalStatus = getFieldValue(data, STATUS_FIELD);
        }else if(error){
            console.log('referralRecord error ', error);
        }
        
        //this.referral = result;
    }

    get isFieldRequired() {
        if(this.source == 'Plan'){
            return true;
        }
        return false;
    }

    @wire(isSMGGrpMember, { source : '$source'})
    isSMGGrpMember({data,error}){
        if(data === true){
            if(this.intitalStatus == 'New' && this.source == 'Plan'){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.PlanReferralStatusIllegalPathErrMsg,
                        variant: 'error'
                    })
                );
                this.dispatchEvent(new CloseActionScreenEvent());
            }else{
                this.displayDialog = true;
            }
        }
        if(data === false){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.label.PlanReferralStatusErrorMsg,
                    variant: 'error'
                })
            );
            this.dispatchEvent(new CloseActionScreenEvent());
        }else if(error){
            console.log('unable to read whether user is a part of smg group ', error);
        }
    }

    closeModal(){    
        this.showSpinner = false;
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    //</T01> end

    @wire(getReferralDetails, { refId : '$recId'})
    referralDetails(result){
        this.referral = result;
    }

    connectedCallback(event){        

    var currentURL = window.location.href;
    var objElement = currentURL.substring(currentURL.indexOf('/r/') + 1).split('/');    
    this.recId = objElement[2];
    
    }

    handleFieldChange(event){  

        var fieldName = event.currentTarget.fieldName;
        var value = event.currentTarget.value;
        console.log(fieldName + ' ' + value );
        switch(fieldName){
            case 'Cancellation_Reason__c':
            this.cancelReason = value;
            if(value === 'Other'){
                this.showOtherReason = true;
            }else{
                this.showOtherReason = false;
            }
            break;

            case 'Other_Cancellation_Reason__c':
            this.otherCancelReason = value;
            break;

            case 'Referral_Dispositioning_Information__c':
            this.dispositioningInfo = value;
            break;
        }

    }

    handleSubmit(event){
        event.preventDefault();
        this.showSpinner = true;//<T01>
        const fields = {};
            fields[ID_FIELD.fieldApiName] = this.recId;
            fields[STATUS_FIELD.fieldApiName] = 'Cancelled';
            fields[CANCELREASON_FIELD.fieldApiName] = this.cancelReason;
            fields[OTHER_CANCELREASON_FIELD.fieldApiName] = this.otherCancelReason;
            fields[REF_DISPOSITIONING_INFO.fieldApiName] = this.dispositioningInfo;
            const recordInput = { fields };

            updateRecord(recordInput)
                .then(result => {
                    this.showSpinner = false;//<T01>
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success : ',
                            message: 'Referral has been Cancelled.',
                            variant: 'success',
                        }),
                    );
                   
                    //Navigate to new record
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.recId,
                            actionName: 'view'
                        }
                    });
                    return refreshApex(this.referral);
                    
                })
                .catch(error => {
                    this.showSpinner = false;//<T01>
                    console.log('error ' , error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error in updating record. Contact System Administrator.',
                            message: 'Error',
                            variant: 'error'
                        })
                    );
                });
    }

}