import {LightningElement, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCurrentStatus from '@salesforce/apex/ApprovalRequestActioncls.getCurrentStatus';
import handleReassignment from '@salesforce/apex/ApprovalRequestActioncls.handleReassignment';
import handleRecallAssignment from '@salesforce/apex/ApprovalRequestActioncls.handleRecallAssignment';
import { createRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

export default class ApprovalRequestActions extends NavigationMixin(LightningElement) {
    
    
    
    buttonclicked = false;
    currentApprovalStatus = '';
    actionStatus = '';
    showError = false;
    userLookupValue;

    @api recordId;
    isLoading = false;
    approveRejectMetaData;
    sSelectedUserId;
    activateReassignButtion = true;
    selectedUser = {};
    ApproveRejectArrayObject = [{dataType:"text-area",fieldAPIName:"comment_approval_fieldname",fieldLabel:"Comments",isRequired:true,isTextAreaField:true,isPicklistField:false }];

    ApproveRejectArrayOtherObject = [{dataType:"text-area",fieldAPIName:"comment_approval_fieldname",fieldLabel:"Comments",isRequired:false,isTextAreaField:true,isPicklistField:false }];

    showApprovalUI = false;
    showRejectUI = false;
    showReassignUI = false;
    showRecallUI = false;

    connectedCallback(){
        console.log(this.recordId);
        getCurrentStatus({ recordId: this.recordId })
        .then((result) => {
            this.approveRejectMetaData  = result
            console.log(this.approveRejectMetaData);    
        })
        .catch((error) => {
            console.log(error);
        });
    }

    get showParentButton(){
        if(this.approveRejectMetaData){
            return this.approveRejectMetaData.showButtons;
        }
        return false;
    }

    get sobjectParentName(){
        if(this.approveRejectMetaData){
            return this.approveRejectMetaData.sObjectName;
        }
    }

    get parentObjectId(){
        if(this.approveRejectMetaData){
            return this.approveRejectMetaData.parentObjectId;
        }
    }

    get metadataDefination(){
        if(this.approveRejectMetaData){
            return this.approveRejectMetaData.metadataRecords;
        }
    }

    get returnApproveButtonConfiguration() {
        const approveFields = this.approveRejectMetaData.sObjectName == 'Lead' ? [...this.ApproveRejectArrayObject] :  [...this.ApproveRejectArrayOtherObject];
        if (this.approveRejectMetaData && this.approveRejectMetaData.metadataRecords.length > 0) {
            const approveMetadata = this.approveRejectMetaData.metadataRecords.find(
                (element) => element.actionName === 'Approve'
            );
            if (approveMetadata && approveMetadata.actionFields && approveMetadata.actionFields.length > 0) {
                return [...approveMetadata.actionFields, ...approveFields];
            }
        }
        return approveFields;
    }

    get returnRejectButtonConfiguration() {
        const rejectFields = this.approveRejectMetaData.sObjectName == 'Lead' ? [...this.ApproveRejectArrayObject] :  [...this.ApproveRejectArrayOtherObject];
        if (this.approveRejectMetaData && this.approveRejectMetaData.metadataRecords.length > 0) {
            const approveMetadata = this.approveRejectMetaData.metadataRecords.find(
                (element) => element.actionName === 'Reject'
            );
            
            if (approveMetadata && approveMetadata.actionFields && approveMetadata.actionFields.length > 0) {
                return [...approveMetadata.actionFields, ...rejectFields];
            }
        }
        return rejectFields;
    }

    get showApproveButton() {
        if(this.approveRejectMetaData &&
            this.approveRejectMetaData.metadataRecords.length == 0){
                return true;
        }else {
            return (
                this.approveRejectMetaData &&
                this.approveRejectMetaData.metadataRecords &&
                this.approveRejectMetaData.metadataRecords.some(
                  (record) => record.actionName === 'Approve'
                )
              );
        }
    }

    get showRejectButton() {
        if(this.approveRejectMetaData &&
            this.approveRejectMetaData.metadataRecords.length == 0){
                return true;
        }else{
            return (
                this.approveRejectMetaData &&
                this.approveRejectMetaData.metadataRecords &&
                this.approveRejectMetaData.metadataRecords.some(
                  (record) => record.actionName === 'Reject'
                )
              );
        }
    }

    get showReassignButton() {
        if(this.approveRejectMetaData &&
            this.approveRejectMetaData.metadataRecords.length == 0){
                return true;
        }else{
            return (
                this.approveRejectMetaData &&
                this.approveRejectMetaData.metadataRecords &&
                this.approveRejectMetaData.metadataRecords.some(
                  (record) => record.actionName === 'Reassign'
                )
              );
        }
    }

    get showRecallButton() {
        
        if(this.approveRejectMetaData && !this.approveRejectMetaData.showRecallButton){
            return false;
        }else if(this.approveRejectMetaData &&
            this.approveRejectMetaData.metadataRecords.length == 0){
                return true;
        }else{
            return (
                this.approveRejectMetaData &&
                this.approveRejectMetaData.metadataRecords &&
                this.approveRejectMetaData.metadataRecords.some(
                  (record) => record.actionName === 'Recall'
                )
              );
        }
    }
    
    navigateToRecordPage(recordId,ObjectName) {
        this[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: {
            recordId: recordId,
            objectApiName: ObjectName, 
            actionName: 'view' 
          }
        })
        .then(() => {
            refreshApex(recordId);
        });
    }

    handelLookupRecordUpdate(event){
        if(event.detail.selectedRecord != undefined){
            this.activateReassignButtion = false;
            this.sSelectedUserId = event.detail.selectedRecord.Id;
            
        }else{
            this.activateReassignButtion = true;
            this.sSelectedUserId= '';
        }
    }

    showButtonFields(event){
        if(event.target.label == 'Approve'){
            this.buttonVisibiltyProperty(true, false, false, false);
        }else if(event.target.label == 'Reject'){
            this.buttonVisibiltyProperty(false, true, false, false);
        }else if(event.target.label == 'Reassign'){
            this.buttonVisibiltyProperty(false, false, true, false);
        }else if(event.target.label == 'Recall'){
            this.buttonVisibiltyProperty(false, false, false, true);
        }
    }

    buttonVisibiltyProperty(approveUI, rejectUI, reassignUI, recallUI){
        this.showApprovalUI = approveUI;
        this.showRejectUI = rejectUI;
        this.showReassignUI = reassignUI;
        this.showRecallUI = recallUI;
    }

    handleReassign(event){
        this.isLoading = true;
        handleReassignment({recordId: this.recordId, newUserId: this.sSelectedUserId, targetObjectId:this.approveRejectMetaData.parentObjectId, sObjectName:this.approveRejectMetaData.sObjectName})
            .then((result) => {
                this.showToast('Success', result, 'success');
                this.isLoading = false;
                this.navigateToRecordPage(this.approveRejectMetaData.parentObjectId,this.approveRejectMetaData.sObjectName );
            })
            .catch((error) => {
                this.showToast('Error', error.body.message, 'error');
                this.isLoading = false;
                this.navigateToRecordPage(this.approveRejectMetaData.parentObjectId,this.approveRejectMetaData.sObjectName );
            });

    }

    handleRecall(event){
        this.isLoading = true;
        handleRecallAssignment({recordId: this.recordId})
            .then((result) => {
                this.showToast('Success', result, 'success');
                this.isLoading = false;
                this.navigateToRecordPage(this.approveRejectMetaData.parentObjectId,this.approveRejectMetaData.sObjectName );
            })
            .catch((error) => {
                this.showToast('Error', error.body.message, 'error');
                this.isLoading = false;
                this.navigateToRecordPage(this.approveRejectMetaData.parentObjectId,this.approveRejectMetaData.sObjectName );
            })
    }
    
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}