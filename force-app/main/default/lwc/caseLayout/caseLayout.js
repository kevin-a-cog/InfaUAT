/*
 * Name         :   caseLayout
 * Author       :   Vignesh
 * Created Date :   06-Jun-2021
 * Description  :   

 Change History
 **************************************************************************************************************************
 Modified By    Date        Jira No.    Description                                                     Tag
 **************************************************************************************************************************
 Vignesh D      06-Jun-2021 UTOPIA      Initial version.                                                NA
 Vignesh D      19-Nov-2021 I2RT-4417   Update Environment Details section display criteria             T01
 Vignesh D      03-Mar-2022 I2RT-5536   Show Org(lookup) and Org(Text) fields on edit layout            T02
 balajip        27-Jun-2022 I2RT-6222   To consider the overridden delivery method value as well 
                                            for showing the Environment Details section                 T03
 Vignesh D      22-Jul-2022 I2RT-6593   Show Business Impact and Estimated date for Milestone fields    T04
 balajip        22-Aug-2022 I2RT-6867   Case Lite changes                                               T05
 balajip        22-Aug-2022 I2RT-7261   added field POD Location                                        T06
 */

import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { log } from 'c/globalUtilities';

import CASE_OBJ from '@salesforce/schema/Case';
import CASE_TYPE from '@salesforce/schema/Case.RecordType.DeveloperName';
import CASE_STATUS from '@salesforce/schema/Case.Status';
import CASE_DESCRIPTION from '@salesforce/schema/Case.Description';
import CASE_PRODUCT from '@salesforce/schema/Case.Forecast_Product__c';
import CASE_DELIVERY_METHOD from '@salesforce/schema/Case.Delivery_Method__c';
import CASE_EP_DELIVERY_MEHTOD from '@salesforce/schema/Case.Entitled_Product__r.Delivery_Method__c';
import CASE_CONTACT_TIMEZONE_NAME from '@salesforce/schema/Case.Contact.TimeZone_Lookup__r.TimeZoneSidKey__c';
import PROBLEMAREA from '@salesforce/schema/Case.Problem_Area__c';
import CASE_ENVIRONMENT from '@salesforce/schema/Case.Environment__c';
import CASE_ACTIVITY_TYPE from '@salesforce/schema/Case.Activity_Type__c';
import CASE_ORG_ID from '@salesforce/schema/Case.Org_Formula_Id__c';
import ISSUE_SUMMARY from '@salesforce/schema/Case.Issue_Summary__c'; 

import UpdateCaseRecord from '@salesforce/apex/CaseController.UpdateCaseRecord';

const fields = [CASE_TYPE,ISSUE_SUMMARY,CASE_STATUS,CASE_DESCRIPTION,CASE_PRODUCT,CASE_DELIVERY_METHOD,CASE_EP_DELIVERY_MEHTOD,CASE_CONTACT_TIMEZONE_NAME,PROBLEMAREA,CASE_ENVIRONMENT,CASE_ACTIVITY_TYPE,CASE_ORG_ID];
const CASE_TECHNICAL = 'Technical';
const CASE_OPERATIONS = 'Operations';
const CASE_ADMIN = 'Administrative';
const CASE_SHIPPING = 'Fulfillment';
const CASE_LITE = 'Case_Lite'; //T05

export default class CaseLayout extends LightningElement {

    @api recordId;
    @api recordTypeId;
    @track isEditable = false;
    @track saveMessageTitle = 'Success';
    @track saveMessage = 'Case has been updated successfully';

    @track sObjectName = 'Case';

    //T05 - included Case Lite Type
    @track generalSectionFields = [
        {label: "Error Message", name: "Error_Message__c", editable: false, updateable: true, showEditPencil: true, layoutSizeTwo: false, showCaseTypes: [CASE_TECHNICAL, CASE_LITE, CASE_OPERATIONS, CASE_ADMIN, CASE_SHIPPING], show: false, hide:false},
        {label: "Problem Statement", name: "Problem_Statement__c", editable: false, updateable: true, showEditPencil: true, layoutSizeTwo: false, showCaseTypes: [CASE_TECHNICAL, CASE_LITE, CASE_OPERATIONS, CASE_ADMIN, CASE_SHIPPING], show: false, hide:false},
        {label: "RCA Pending flag", name: "RCA_Pending_flag__c", editable: false, updateable: true, showEditPencil: true, layoutSizeTwo: true, showCaseTypes: [CASE_TECHNICAL, CASE_LITE, CASE_OPERATIONS, CASE_ADMIN, CASE_SHIPPING], show: false, hide:false},    
        {label: "Case Record Type", name: "Record_Type_Name__c", editable: false, updateable: false, showEditPencil: false, layoutSizeTwo: true, showCaseTypes: [CASE_TECHNICAL, CASE_LITE, CASE_OPERATIONS, CASE_ADMIN, CASE_SHIPPING], show: false, hide:false},    
        {label: "Case Origin", name: "Origin", editable: false, updateable: true, showEditPencil: true, layoutSizeTwo: true, showCaseTypes: [CASE_TECHNICAL, CASE_LITE, CASE_OPERATIONS, CASE_ADMIN, CASE_SHIPPING], show: false, hide:false},    
        {label: "Delay Close Date", name: 'Automatic_closure_Date__c', editable: false, updateable: false, showEditPencil: false, layoutSizeTwo: true, showCaseTypes: [CASE_TECHNICAL, CASE_LITE, CASE_OPERATIONS, CASE_ADMIN, CASE_SHIPPING], show: false, hide:false},
        {label: "Cause of Delay", name: 'Cause_of_Delay__c', editable: false, updateable: true, showEditPencil: true, layoutSizeTwo: true, showCaseTypes: [CASE_TECHNICAL, CASE_LITE, CASE_OPERATIONS, CASE_SHIPPING], show: false, hide:false},
        {label: "Resolution Type", name: 'Root_cause__c', editable: false, updateable: true, showEditPencil: true, layoutSizeTwo: true, showCaseTypes: [CASE_TECHNICAL, CASE_LITE, CASE_OPERATIONS], show: false, hide:false},
        {label: "Resolution Code", name: 'Resolution_Code__c', editable: false, updateable: true, showEditPencil: true, layoutSizeTwo: true, showCaseTypes: [CASE_TECHNICAL, CASE_LITE, CASE_OPERATIONS], show: false, hide:false},
        {label: "Problem Area", name: 'Problem_Area__c', editable: false, updateable: true, showEditPencil: true, layoutSizeTwo: true, showCaseTypes: [CASE_ADMIN], show: false, hide:false},
        {label: "Case Conversion Summary", name: 'Issue_Summary__c', editable: false, updateable: false, showEditPencil: false, layoutSizeTwo: true, showCaseTypes: [CASE_TECHNICAL, CASE_LITE, CASE_OPERATIONS, CASE_ADMIN, CASE_SHIPPING], show: false, hide:false},
        {label: "Case Type", name: "Is_Internal_Or_External_Case__c", editable: false, updateable: false, showEditPencil: false, layoutSizeTwo: true, showCaseTypes: [CASE_TECHNICAL, CASE_LITE, CASE_OPERATIONS, CASE_ADMIN, CASE_SHIPPING], show: false, hide:false},
        {label: "Business Impact", name: "Business_Impact__c", editable: false, updateable: false, showEditPencil: false, layoutSizeTwo: true, showCaseTypes: [CASE_TECHNICAL, CASE_LITE, CASE_OPERATIONS], show: false, hide:false}, //<T04>
        {label: "Estimated Date for Milestone", name: "Estimated_Date_for_Milestone__c", editable: false, updateable: false, showEditPencil: false, layoutSizeTwo: true, showCaseTypes: [CASE_TECHNICAL, CASE_OPERATIONS], show: false, hide:false} //<T04>
    ];
    // <T02>
    hostedSectionFieldsOnRead = [
        {label: "Environment", name: 'Environment__c',editable: false, updateable: true, showEditPencil: true},
        {label: "Activity Type", name: 'Activity_Type__c', editable: false, updateable: true, showEditPencil: true},
        {label: "Org ID", name: 'Org_Formula_Id__c', editable: false, updateable: true, showEditPencil: true},
        {label: "Secure Agent", name: 'Secure_Agent__c', editable: false, updateable: true, showEditPencil: true},
        {label: "POD Location", name: 'Org_POD_Location__c', editable: false, updateable: false, showEditPencil: false}, //T06
    ];
    hostedSectionFieldsOnEdit = [
        {label: "Environment", name: 'Environment__c',editable: false, updateable: true, showEditPencil: true},
        {label: "Activity Type", name: 'Activity_Type__c', editable: false, updateable: true, showEditPencil: true},
        {label: "Org", name: 'Org__c', editable: false, updateable: true, showEditPencil: true},
        {label: "Secure Agent", name: 'Secure_Agent__c', editable: false, updateable: true, showEditPencil: true},
        {label: "Org ID", name: 'Org_ID__c', editable: false, updateable: true, showEditPencil: true},
    ];
    // </T02>
    @track hostedSectionFields = this.hostedSectionFieldsOnRead;
    @track pcSectionFields = [
        {label: "Contact Salutation", name: 'Contact_Salutation__c', editable: false, updateable: true, showEditPencil: true, showValue: false, value: ''},
        {label: "Contact", name: 'ContactId', editable: false, updateable: true, showEditPencil: true, showValue: false, value: ''},
        {label: "Contact Email", name: 'ContactEmail', editable: false, updateable: false, showEditPencil: false, showValue: false, value: ''},
        {label: "Contact Phone", name: 'ContactPhone', editable: false, updateable: false, showEditPencil: false, showValue: false, value: ''},
        {label: "Contact Region", name: 'Contact_Region__c', editable: false, updateable: false, showEditPencil: false, showValue: false, value: ''},
        {label: "Contact Timezone", name: 'Contact_Timezone__c', editable: false, updateable: false, showEditPencil: false, showValue: false, value: ''},
        {label: "Current Time", name: 'Current_Time__c', editable: false, updateable: false, showEditPencil: false, showValue: true, value: ''},
        {label: "Preferred Language", name: 'Preferred_Language__c', editable: false, updateable: false, showEditPencil: false,showValue: false, value: ''}
    ];
    @track caseData;
    @track caseType;
    @track caseStatus;
    @track showHostedSection = false;

    // Track changes to main properties
    @track isLoading = true;
    @track isEditing = false;
    @track hasChanged = false;
    @track isSaving = false;
    @track showFooter = false;
    @track showEdit = true;

    @track environmentSection = 'Environment Details';
    @track contactSection = 'Case Contact';
    caseSubscription;
    setTimer;

    @wire(getRecord, { recordId: '$recordId', fields })
    fieldsData({data, error}){
        if(data){
            this.caseData = data;
            log('CaseLayout::DATA @wire getRecord->'+JSON.stringify(data));
            if(data.fields.RecordType != undefined && data.fields.RecordType.displayValue != null){
                this.caseType = getFieldValue(this.caseData, CASE_TYPE);
                //T05 - to show the hosted section for Lite cases
                if(this.caseType == CASE_LITE){
                    this.showHostedSection = true;
                }
                var conversionsummary = data.fields.Issue_Summary__c.value;
                this.recordTypeId = data.fields.RecordType.value.id;
                log('CaseLayout::@wire recordTypeId-->'+this.recordTypeId);
                console.log('conversion:'+conversionsummary);

                this.generalSectionFields.forEach(field => {
                    if(field.showCaseTypes.includes(this.caseType)){
                        if(!field.hide){
                            field.show = true;
                            log('label value:'+field.label);
                        }
                        if((conversionsummary == ' ' || conversionsummary == undefined  || conversionsummary == null) && field.name == 'Issue_Summary__c'){
                            field.show = false;
                        } 
                    }
                });
            }
            if(data.fields.Status != undefined && data.fields.Status.value != null){
                this.caseStatus = data.fields.Status.value;
                
                if(this.caseStatus !== 'Closed' && this.caseStatus !== 'Cancelled' && this.caseStatus !== 'Delivered'){
                    this.isEditable = true;
                }
                else if(this.caseStatus === 'Closed' || this.caseStatus === 'Cancelled' || this.caseStatus === 'Delivered'){
                    this.isEditable = false;
                }
                
            }
            //T03 - to also check the overridden delivery method value
            if(data.fields.Delivery_Method__c && data.fields.Delivery_Method__c.value && data.fields.Delivery_Method__c.value != null){
                let deliveryMethod = data.fields.Delivery_Method__c.value;
                if( deliveryMethod === 'Hosted Multi Tenant' || deliveryMethod === 'Hosted Single Tenant'){
                    this.showHostedSection = true;
                }
            }

            this.calcContactCurrentTime();
        }
        else if(error){
            log('CaseLayout::ERROR @wire getRecord->'+JSON.stringify(error));
        }
        this.isLoading = false;
    };

    @track buttonClickedEnv = true;
    @track classNameEnv = 'slds-section slds-show';
    @track iconNameEnv = 'utility:chevrondown';
    handleToggleEnvDetails() {
        this.buttonClickedEnv = !this.buttonClickedEnv;
        if (this.buttonClickedEnv == false) {
            this.classNameEnv = 'slds-section slds-hide';
            this.iconNameEnv = 'utility:chevronright';
        }
        else {
            this.classNameEnv = 'slds-section slds-show';
            this.iconNameEnv = 'utility:chevrondown';
        }
    }
    @track buttonClickedCase = true;
    @track classNameCase = 'slds-section slds-show';
    @track iconNameCase = 'utility:chevrondown';
    handleToggleCaseContact() {
        this.buttonClickedCase = !this.buttonClickedCase;
        if (this.buttonClickedCase == false) {
            this.classNameCase = 'slds-section slds-hide';
            this.iconNameCase = 'utility:chevronright';
        }
        else {
            this.classNameCase = 'slds-section slds-show';
            this.iconNameCase = 'utility:chevrondown';
        }
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

        this.generalSectionFields.forEach((field) => {
            field.editable = field.updateable;
            field.showEditPencil = !field.updateable;
        });
        this.hostedSectionFields = this.hostedSectionFieldsOnEdit; // <T02>
        this.hostedSectionFields.forEach((field) => {
            field.editable = field.updateable;
            field.showEditPencil = !field.updateable;
        });
        this.pcSectionFields.forEach((field) => {
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

        this.generalSectionFields.forEach((field) => {
            field.editable = false;
            field.showEditPencil = field.updateable;
        });
        this.hostedSectionFields.forEach((field) => {
            field.editable = false;
            field.showEditPencil = field.updateable;
        });
        this.hostedSectionFields = this.hostedSectionFieldsOnRead; // <T02>
        this.pcSectionFields.forEach((field) => {
            field.editable = false;
            field.showEditPencil = field.updateable;
        });
    }

    // Set the has changed to true
    setHasChanged() {
        this.hasChanged = true;
    }

    // Handle the form Submit callback
    handleFormSubmit(event) {
        event.preventDefault();
        // Show spinner
        this.isSaving = true;
        log('fields-> '+JSON.stringify(event.detail.fields));
        var caseObj = event.detail.fields;
        caseObj.Id = this.recordId;
        UpdateCaseRecord({ caseObj: JSON.stringify(caseObj) })
            .then(result => {
                this.isSaving = false;
                this.hasChanged = false;
                this.showToastEvent(this.saveMessageTitle, this.saveMessage, 'success');
                this.toggleCancel();
            })
            .catch(error => {
                log('Error -> '+JSON.stringify(error));
                let errorMessage = error?.body.message;
                //T05
                /*if(errorMessage === 'CASE PRIMARY CONTACT IS NOT A SUPPORT ACCOUNT CONTACT'){
                    errorMessage = 'Please select a contact associated with the Support Account';
                }*/
                this.isSaving = false;
                this.showToastEvent('ERROR', errorMessage, 'error');
            })
    };

    // Handle the form Success callback
    handleFormSuccess() {
        // Hide spinner
        /*this.isSaving = false;
        this.hasChanged = false;
        this.showToastEvent(this.saveMessageTitle, this.saveMessage, 'success');
        this.toggleCancel();*/
    };

    // Handle the form Error callback
    handleFormError(event) {
        // Hide spinner
        //this.isSaving = false;
        //let errorMessage = `${event.detail.message}\n${event.detail.detail}`;
        //log(errorMessage);
        //this.showToastEvent('Error', event.detail.message, 'error');
        //log(JSON.stringify(event.detail));
    };

    calcContactCurrentTime(){
        this.pcSectionFields.forEach(element => {
            if(element.name === 'Current_Time__c'){
                element.value = '';
            }
        });
        this.calcTime();

        this.setTimer;
        clearInterval(this.setTimer);

        this.setTimer = setInterval(() => {
            this.calcTime();
        }, 1000);
    }

    calcTime(){
        let data = this?.caseData?.fields;
        if(data?.Contact?.value?.fields?.TimeZone_Lookup__r?.value?.fields?.TimeZoneSidKey__c?.value){
            //log('timeZone --> '+JSON.stringify(data.Contact.value.fields.TimeZone_Lookup__r.value.fields.TimeZoneSidKey__c.value));
            let tzName = data.Contact.value.fields.TimeZone_Lookup__r.value.fields.TimeZoneSidKey__c.value;
            let myDate = new Date();
            let currentTime = myDate.toLocaleTimeString('en-US', {timeZone: tzName});
            //log('time now --> '+this.recordId);
            this.pcSectionFields.forEach(element => {
                if(element.name === 'Current_Time__c'){
                    element.value = currentTime;
                }
            });
        }
    }

}