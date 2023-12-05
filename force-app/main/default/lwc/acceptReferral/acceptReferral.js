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
import { CloseActionScreenEvent } from 'lightning/actions';

import getReferralDetails from "@salesforce/apex/ReferralManagementController.getReferralDetails";

import STATUS_FIELD from '@salesforce/schema/iCare_Referral__c.Status__c';
import OWNERID_FIELD from '@salesforce/schema/iCare_Referral__c.OwnerId';
import ID_FIELD from '@salesforce/schema/iCare_Referral__c.Id';
import userId from '@salesforce/user/Id';

export default class AcceptReferral extends NavigationMixin(LightningElement){
    recId;
    referral;
    showMessage = false;

    @wire(getReferralDetails, { refId : '$recId'})
    referralDetails(result){
        this.referral = result;
    }

    connectedCallback(event){
        

    var currentURL = window.location.href;
    var objElement = currentURL.substring(currentURL.indexOf('/r/') + 1).split('/');    
    this.recId = objElement[2];

    

            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.recId;
            fields[OWNERID_FIELD.fieldApiName] = userId;
            fields[STATUS_FIELD.fieldApiName] = 'Accepted';

            const recordInput = { fields };

            updateRecord(recordInput)
                .then(() => {
                    //this.showMessage =true;

                    this.dispatchEvent(new CloseActionScreenEvent());

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Referral has been Accepted successfully!',
                            variant: 'success'
                        })
                    );
                    
                    return refreshApex(this.referral);
                })
                .catch(error => {
                    var errMsg = error.body.message;
                    var titleMsg = 'Error in updating record. Contact System Administrator.';
                    var closeModal = false;
                    //<T01> start
                    if(error!=null && error!=undefined && error.body!=null && error.body!=undefined && error.body.output!=null && error.body.output!=undefined && error.body.output.errors != null && error.body.output.errors != undefined && error.body.output.errors[0]?.message != null && error.body.output.errors[0]?.message !=undefined){
                        titleMsg = error.body.output.errors[0].message;
                        errMsg = '';
                        closeModal = true;
                    }//</T01> end
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: titleMsg,
                            message: errMsg,
                            variant: 'error'
                        })
                    );
                    if(closeModal === true){
                        this.dispatchEvent(new CloseActionScreenEvent());
                    }
                });
        
    }
}