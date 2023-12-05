import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import getCoOwners from '@salesforce/apex/CaseController.getCoOwners';
import switchOwner from '@salesforce/apex/CaseController.switchOwner';

import CASE_FIELD_ID from '@salesforce/schema/Case.Id';
import CASE_FIELD_OWNERID from '@salesforce/schema/Case.OwnerId';

const CASE_FIELDS = [
    CASE_FIELD_ID,
    CASE_FIELD_OWNERID,
    'Case.Owner.Name'
];

export default class CaseSwitchOwner extends LightningElement {

    @api recordId;
    @track coOwnerOptions=[];
    @track currentOwnerId;
    @track currentOwnerName;
    @track selectedCoOwnerId;

    @track progressCount = 1;

    get showSpinner(){
        return this.progressCount > 0;
    }

    @wire(getRecord, { recordId: '$recordId', fields: CASE_FIELDS })
    cse({ error, data }) {
        if (error) {
            console.log("error - " + JSON.stringify(error));
            this.progressCount--;
        } else if (data) {
            console.log("fields - " + JSON.stringify(data.fields));

            this.currentOwnerId = data.fields.OwnerId.value;
            console.log("currentOwnerId - " + this.currentOwnerId);

            this.currentOwnerName = data.fields.Owner.value.fields.Name.value;
            console.log("currentOwnerName - " + this.currentOwnerName);

            this.fetchUsers(data.fields.Id.value);
        }
    }

    fetchUsers(caseId){
        getCoOwners({
            caseId: caseId
        })
        .then(result => {
            console.log("result - " + JSON.stringify(result));

            var coOwnerOptions = [];
            for(let key in result) {
                if (result.hasOwnProperty(key) && key!=this.currentOwnerId) { 
                    coOwnerOptions.push({label: result[key], value: key});
                }
            }
            this.coOwnerOptions = coOwnerOptions;
            console.log("coOwnerOptions - " + JSON.stringify(this.coOwnerOptions));
            
            if (this.coOwnerOptions.length == 0) {
                this.cancel();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'There isn\'t any Co-owner to swap to!',
                        variant: 'error',
                    })
                );
            }
            this.progressCount--;
        })
        .catch(error => {
            console.log("error - " + JSON.stringify(error));
            this.progressCount--;
        })
    }

    handleChange(event) {
        this.selectedCoOwnerId = event.detail.value;
        console.log('Option selected with value: ' + this.selectedCoOwnerId);
    }

    submit() {
        console.log('recid='+this.recordId);
        console.log("selectedCoOwnerId - " + this.selectedCoOwnerId);
        
        if (!this.selectedCoOwnerId) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select the new Owner!',
                    variant: 'error',
                })
            );
        }else{
            this.progressCount++;
            switchOwner({
                caseId: this.recordId,         
                newOwnerId: this.selectedCoOwnerId
            })
            .then(result => {
                console.log("result - " + JSON.stringify(result));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Ownership swapped successfully!',
                        variant: 'success',
                    }),
                );
                this.progressCount--;
                this.closeQuickAction();
            })
            .catch(error => {
                console.log("error - " + JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error switching the owner!',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
                this.progressCount--;
                this.closeQuickAction();
            });    
        }
    }

    cancel(){
        this.closeQuickAction();
    }

    closeQuickAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}