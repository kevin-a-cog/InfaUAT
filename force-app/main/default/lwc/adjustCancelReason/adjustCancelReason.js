import { LightningElement, track, wire, api } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import UNRENEWED_OBJ from '@salesforce/schema/Unrenewed__c'
import CHURN_STATUS from '@salesforce/schema/Unrenewed__c.Churn_Status__c'
import getUnrenewedRecs from '@salesforce/apex/AdjustCancelReasonController.getUnrenewedRecs'
import updateUnrenewedRecs from '@salesforce/apex/AdjustCancelReasonController.updateUnrenewedRecs'
import updateUnrenewedRecsAndPush from '@salesforce/apex/AdjustCancelReasonController.updateUnrenewedRecsAndPush'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Fields to be displayed on the table
const unrenewedFields = [
    { label: 'Contract', fieldName: 'Subscription__r_SBQQ__ContractNumber__c', type: 'Text' },
    { label: 'Subscription Line', fieldName: 'Subscription__r_Name', type: 'Text' },
    { label: 'Product', fieldName: 'Product__r_Name', type: 'Text' }, ,
    { label: 'Quote', fieldName: 'Quote__r_Name', type: 'Text' },
    { label: 'Cancel Reason', fieldName: 'Churn_Status__c', type: 'Text' }
];

export default class AdjustCancelReason extends LightningElement {

    @track picklistValue;
    @api quoteId;
    unrenewedRecs;
    childUnrenewedRecs;
    unrenewedRecsToUpdate = [];
    showChild = false;
    orderBillAndContract = false;


    @wire(getObjectInfo, { objectApiName: UNRENEWED_OBJ })
    unrenewedObjInfo;

    @wire(getPicklistValues, { recordTypeId: '$unrenewedObjInfo.data.defaultRecordTypeId', fieldApiName: CHURN_STATUS })
    churnStatusPicklistValues;

    //Close the Modal, dispatch event to parent
    closeModal(event) {
        const closeEvent = new CustomEvent('closemodal', {});
        this.dispatchEvent(closeEvent);
    }

    closeChildView() {
        this.showChild = false;
    }

    showChildView(event) {
        var allRecs = this.unrenewedRecs;
        var childRecs = allRecs.filter(function (obj) { return obj.Parent_Product_Name__c === event.target.name });
        this.childUnrenewedRecs = childRecs;
        this.showChild = true;
    }

    //On change of the main Picklist value
    handleChangePicklist(event) {
        this.picklistValue = event.detail.value;
        this.updateSelectedLines();
    }
    //When the picklist value is updated at the line level
    handleChangePicklistLineLevel(event) {
        var recId = event.target.id;
        recId = recId.slice(0, 18);
        var objIndex = this.unrenewedRecsToUpdate.findIndex(obj => obj.Id === recId);
        if (objIndex < 0) {
            var unrenwed = { Id: recId, Churn_Status__c: event.detail.value };
            this.unrenewedRecsToUpdate.push(unrenwed);
        }
        else
            this.unrenewedRecsToUpdate[objIndex].Churn_Status__c = event.detail.value;

        var allRecs = this.unrenewedRecs;
        var childRecs = allRecs.filter(function (obj) { return obj.Parent_Product_Name__c === event.target.name });
        if (childRecs.length > 0)
            this.updateChildLineStatus(childRecs, event.detail.value);
        if (this.unrenewedRecsToUpdate.length > 0) {
            let button = this.template.querySelector('lightning-button');
            button.disabled = false;
        }
    }

    //Updating the child line statues from the Parent status
    updateChildLineStatus(childRecs, statusValue) {
        var self = this;
        childRecs.forEach(function (unrenewRec) { 
            var objIndex = self.unrenewedRecs.findIndex(obj => obj.Id === unrenewRec.Id);
            self.unrenewedRecs[objIndex].Churn_Status__c = statusValue;

            objIndex = self.unrenewedRecsToUpdate.findIndex(obj => obj.Id === unrenewRec.Id);
            if (objIndex < 0) {
                var unrenwed = { Id: unrenewRec.Id, Churn_Status__c: statusValue };
                self.unrenewedRecsToUpdate.push(unrenwed);
            }
            else
                self.unrenewedRecsToUpdate[objIndex].Churn_Status__c = statusValue;
        });
        //console.log('####: '+JSON.stringify(this.unrenewedRecs));
    }  

    connectedCallback() {
        //console.log('QuoteId: ', this.quoteId);
        this.loadUnrenewedRecs();
    }

    //Similar to init, used to load the unrenewed records on screen load
    loadUnrenewedRecs() {
        getUnrenewedRecs({ quoteId: this.quoteId }).then(result => {
            console.log('SUCCESS in fetching the Unrenewed records');
            var unreneweRec = result[0];
            this.orderBillAndContract = (unreneweRec.Quote__r.hasOwnProperty('Primary_Order__c') && (unreneweRec.Quote__r.Primary_Order__r.Status === 'Bill & Contract' || unreneweRec.Quote__r.Primary_Order__r.Status === 'Completed'));
            this.checkChildLines(result);
        }).catch(error => {
            this.error = 'Error in fetching the Unrenewed records';
            console.log('Error in fetching the Unrenewed records');
        });
    }

    //To check if the Lines have any associated child Lines
    checkChildLines(result) {
        result.forEach(function (unrenewed) {
            if (typeof unrenewed.Parent_Product_Name__c !== 'undefined') {
                var objIndex = result.findIndex(obj => obj.Name === unrenewed.Parent_Product_Name__c);
                result[objIndex].has_children__c = true;
            }
        });
        this.unrenewedRecs = result;
    }

    //Used to toggle the select and unselect on the table
    selectAllClicked() {
        var checkItAll = this.template.querySelector('input');
        var inputs = this.template.querySelectorAll('lightning-input');

        var currentValue = checkItAll.checked;
        inputs.forEach(function (input) {
            input.checked = currentValue;
        });
    }

    updateSelectedLines() {
        var inputs = this.template.querySelectorAll('lightning-input');
        var self = this;
        inputs.forEach(function (input) {
            var recId = input.id;
            recId = recId.slice(0, 18);
            if (input.checked) {
                var objIndex = self.unrenewedRecs.findIndex(obj => obj.Id === recId);
                self.unrenewedRecs[objIndex].Churn_Status__c = self.picklistValue;

                objIndex = self.unrenewedRecsToUpdate.findIndex(obj => obj.Id === recId);
                if (objIndex < 0) {
                    var unrenwed = { Id: recId, Churn_Status__c: self.picklistValue };
                    self.unrenewedRecsToUpdate.push(unrenwed);
                }
                else
                    self.unrenewedRecsToUpdate[objIndex].Churn_Status__c = self.picklistValue;
                
                var allRecs = self.unrenewedRecs;
                var childRecs = allRecs.filter(function (obj) { return obj.Parent_Product_Name__c === input.name});
                if (childRecs.length > 0)
                    self.updateChildLineStatus(childRecs, self.picklistValue);
            }
        });

        if (this.unrenewedRecsToUpdate.length > 0) {
            let button = this.template.querySelector('lightning-button');
            button.disabled = false;
        }        
    }

    //if contract is not created update only the unrenewed records
    handleSave() {
        //console.log('Unrenewed Recs to update: ' + JSON.stringify(this.unrenewedRecsToUpdate));
        updateUnrenewedRecs({ lstUnrenwedRecs: this.unrenewedRecsToUpdate }).then(result => {
            const evt = new ShowToastEvent({
                title: "Cancel Reason Updated!",
                message: "Cancel Reason has been successfully Updated!",
                variant: 'success',
            });
            this.dispatchEvent(evt);
            this.closeModal();
        }).catch(error => {});       
    }  

    //If the renewal contract is created then update both the unrenewed record and the timestamp on previous contract
    handleSaveAndPush() {
        //console.log('Unrenewed Recs to update: ' + JSON.stringify(this.unrenewedRecsToUpdate));
        updateUnrenewedRecsAndPush({ lstUnrenwedRecs: this.unrenewedRecsToUpdate }).then(result => {
            const evt = new ShowToastEvent({
                title: "Cancel Reason Updated!",
                message: "Cancel Reason has been successfully Updated!",
                variant: 'success',
            });
            this.dispatchEvent(evt);
            this.closeModal();
        }).catch(error => { });
    }     
}