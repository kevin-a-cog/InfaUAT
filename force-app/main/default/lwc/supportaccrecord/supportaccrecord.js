import { api, LightningElement, wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";
import { getRecord } from 'lightning/uiRecordApi';
import CASE_STATUS from '@salesforce/schema/Case.Status';
import CASE_SUPPORT_ACCOUNT from '@salesforce/schema/Case.Support_Account__c';
import SUPPORT_ACCOUNT_NAME from '@salesforce/schema/Case.Support_Account__r.Name';
import DELAY_CLOSE from '@salesforce/schema/Case.Is_Delay_Close__c';
import CASE_PARENT_ACCOUNT from '@salesforce/schema/Case.Support_Account__r.ParentId';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import ACCOUNTNUMBER_FIELD from '@salesforce/schema/Account.AccountNumber';
import OFFERING_FIELD from '@salesforce/schema/Account.Success_Offering__c';
import SEGMENTATION_FIELD from '@salesforce/schema/Account.GCS_Segment__c';
import ACCNUMBER_FIELD from '@salesforce/schema/Account.AccountNumber';
import ACCOUNT_FIELD from '@salesforce/schema/Account.ParentId';
import HANDLING_FIELD from '@salesforce/schema/Account.Handling_Instructions__c';
import PARENTID_FIELD from '@salesforce/schema/Account.ParentId';
import ENTITLEMENT_FIELD from '@salesforce/schema/Account.Entitlement__c';
import ENTITLEMENTSTATUS_FIELD from '@salesforce/schema/Account.Support_Account_Status__c';
import getAccountTeamMembers from '@salesforce/apex/CaseController.getAccountTeamMembers';
import DEBUG from '@salesforce/label/c.Service_Cloud_LWC_Debug_Flag';

const fields = [CASE_STATUS,CASE_SUPPORT_ACCOUNT,CASE_PARENT_ACCOUNT,SUPPORT_ACCOUNT_NAME];
//const caseSupportAccNameFieldObj = {label: "Support Account Name", name: 'Name',overrideLabel: 'SupportAccountNameID', editable: false, updateable: false, showEditPencil: false, layoutSizeTwo: false, required: true};
const caseFieldsObj = [
    {label: "Support Account Number", name: 'New_Org_Account_Number__c',overridelabel: 'SupportAccountNumberID', editable: false, updateable: false, showEditPencil: false, layoutSizeTwo: true, required: false},
    {label: "Customer Account", name: 'ParentId',overridelabel: 'CustomerAccountID', editable: false, updateable: false, showEditPencil: false, layoutSizeTwo: true, required: false},
    //{label: "Segment", name: 'Segment__c', overrideLabel: 'SegmentID', editable: false, updateable: false, showEditPencil: false, layoutSizeTwo: true,required: false},
    // {label: "Entitlement", name: 'Entitlement__c', overridelabel: 'EntitlementID', editable: false, updateable: false, showEditPencil: false, layoutSizeTwo: true,required: false},
    {label: "Entitlement Status", name: 'Support_Account_Status__c', overridelabel: 'EntitlementStatusID', editable: false, updateable: false, showEditPencil: false, layoutSizeTwo: true,required: false},
    {label: "Handling Instructions", name: 'Handling_Instructions__c', overridelabel: 'HandlingInstructionsID', editable: false, updateable: true, showEditPencil: true, layoutSizeTwo: false,required: false}
];
const CSM = 'CSM';
const ACCOUNT_MANAGER = 'Account Manager';
const AccountTeamRoles = [CSM, ACCOUNT_MANAGER];

function log(message){
    if(DEBUG !== undefined && DEBUG !== null && DEBUG === 'true'){
        console.log(message);
    }
}

export default class Supportaccrecord extends NavigationMixin(LightningElement) {
    @api recordId;
    supportAccId; 
    recid;
    case; 

    @track supportAccName;
    @track caseStatus;
    @track accountTeamMembers = [];
    @track isEditable = false;
    @track saveMessageTitle = 'Success';
    @track saveMessage = 'Account has been updated successfully';
    @track sObjectName = 'Account';
    @track recordFields = caseFieldsObj;

    // Track changes to main properties
    @track isLoading = false;
    @track isEditing = false;
    @track hasChanged = false;
    @track isSaving = false;
    @track showFooter = false;
    @track showEdit = true;

    @wire(getRecord, { recordId: '$recordId', fields: fields})
    getRecordData({ error, data }) {
        if(data){
            this.case = data;
            log('Support Account -->'+JSON.stringify(data));
            this.supportAccId = this.case.fields.Support_Account__c.value;
            if(this.case.fields.Support_Account__r != undefined && this.case.fields.Support_Account__r.value != null && this.case.fields.Support_Account__r.value.fields.ParentId.value != null){
                this.recid = this.case.fields.Support_Account__r.value.fields.ParentId.value;
            }
            if(this.case.fields.Support_Account__r != undefined && this.case.fields.Support_Account__r.value != null && this.case.fields.Support_Account__r.value.fields.Name.value != null){
                this.supportAccName = this.case.fields.Support_Account__r.value.fields.Name.value;
            }
            log('AccountId= '+this.recid);
            if(data.fields.Status != undefined && data.fields.Status.value != null){
                this.caseStatus = data.fields.Status.value;
                
                if(this.caseStatus !== 'Closed'){
                    this.isEditable = true;
                }
                else if(this.caseStatus === 'Closed'){
                    this.isEditable = false;
                }
                
            }
           
            getAccountTeamMembers({accountId: this.recid})
                .then(result => {
                    this.accountTeamMembers = [];
                    log('Account Team Members: '+JSON.stringify(result));
                    let AccountManagers = [];
                    let CSMs = [];
                    result.forEach(accountTeamMember => {
                        if(AccountTeamRoles.includes(accountTeamMember.TeamMemberRole)){
                            if(CSM === accountTeamMember.TeamMemberRole){
                            //this.accountTeamMembers.push({role: accountTeamMember.TeamMemberRole, userName: accountTeamMember.User.Name, userId: accountTeamMember.User.Id});
                                CSMs.push({userName: accountTeamMember.User.Name, userId: accountTeamMember.User.Id});
                            }
                            else if(ACCOUNT_MANAGER === accountTeamMember.TeamMemberRole){
                                AccountManagers.push({userName: accountTeamMember.User.Name, userId: accountTeamMember.User.Id});
                            }
                        }
                    });
                    if(AccountManagers.length > 0){
                        this.accountTeamMembers.push({role: ACCOUNT_MANAGER, userRecords: AccountManagers});
                    }
                    if(CSMs.length > 0){
                        this.accountTeamMembers.push({role: CSM, userRecords: CSMs});
                    }
                    log('Account Team Members: '+JSON.stringify(this.accountTeamMembers));
                })
                .catch(error => {
                    log('Error: '+JSON.stringify(error));
                })
        }
    }

    // Show a UI Message
    showToastEvent(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }

    // Toggle editable state
    toggleEdit() {
        var borders = this.template.querySelectorAll('.custom-col-size-9');
        borders.forEach(element =>{
            element.classList.remove('slds-border_bottom');
        });
        if (this.canEdit){
            this.isEditing = !this.isEditing;
            this.showEdit = !this.showEdit;
            this.showFooter = true;
        }
        //this.recordFields.unshift(caseSupportAccNameFieldObj);

        this.recordFields.forEach((field) => {
            field.editable = field.updateable;
            field.showEditPencil = !field.updateable;
        });
    }

    toggleCancel(){
        var borders = this.template.querySelectorAll('.custom-col-size-9');
        borders.forEach(element =>{
            element.classList.add('slds-border_bottom');
        });
        if (this.canEdit){
            this.isEditing = !this.isEditing;
            this.showEdit = !this.showEdit;
            this.showFooter = false;
        }

        this.recordFields.forEach((field) => {
            field.editable = false;
            field.showEditPencil = field.updateable;
        });
        //this.recordFields.shift();
    }

    redirectToUser(event){
        log('redirect to user: '+JSON.stringify(event.currentTarget.dataset.id));
        let userId = event.currentTarget.dataset.id;
        if(userId !== undefined && userId !== null && userId != ''){
            this.handleNavigation(userId,"User");
        }
        
    }

    navigateToAccount(){
        this.handleNavigation(this.supportAccId,"Account");
    }

    handleNavigation(recId, objectName){
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
              recordId: recId,
              objectApiName: objectName,
              actionName: "view"
            }
          });
    }

    // Set the has changed to true
    setHasChanged() {
        this.hasChanged = true;
    }

    // Handle the form Submit callback
    handleFormSubmit() {
        // Show spinner
        this.isSaving = true;
    };

    // Handle the form Success callback
    handleFormSuccess() {
        this.isSaving = false;
        this.hasChanged = false;
        this.showToastEvent(this.saveMessageTitle, this.saveMessage, 'success');
        this.toggleCancel();
    };

    // Handle the form Error callback
    handleFormError(event) {
        // Hide spinner
        this.isSaving = false;
        //this.showToastEvent('Error', event.detail.message, 'error');
    };

    get showSupportAccName(){
        return true; //!this.isEditing;
    }

    // Show spinner error property
    get showSpinner() {
        return this.isLoading || this.isSaving;
    }

    // Show the record form
    get showForm() {
        return !this.isLoading && !!this.sObjectName;
    }

    // Check if we can edit
    get editLabel() {
        return 'Edit';
    }

    // Check if we can edit
    get canEdit() {
        return this.isEditable;
    }

    // Check if we can save, we need fields
    get canSave() {
        return this.canEdit && this.isEditing && this.hasChanged;
    }

    get showAccountTeamMembers(){
        return this.accountTeamMembers.length > 0 ? true : false;
    }

    /*get isCaseOpen(){
        return this.caseStatus !== undefined && this.caseStatus !== null && this.caseStatus !== 'Closed' ? true : false;
    }*/
}