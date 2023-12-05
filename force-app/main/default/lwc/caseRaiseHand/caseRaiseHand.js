/*
   
 Change History
 *********************************************************************************************************************************************
 ModifiedBy         Date        Jira No.     Description										                                       Tag
 Tejasvi Royal      08/07/2021  
 Isha Bansal        01/03/2023   I2RT-7258   Join a customer meeting-PS  Have a join a customer meeting option for Product specialists T01
 Vignesh Divakaran  27/04/2023   I2RT-7859   Updated existing and added new values on environment types                                T02
 *********************************************************************************************************************************************
 */

import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getRecordNotifyChange} from 'lightning/uiRecordApi';
import createRaiseHand from '@salesforce/apex/RaiseHandController.createRaiseHand';
import getSkills from '@salesforce/apex/RaiseHandController.getSkills';

import CASE_FIELD_ID from '@salesforce/schema/Case.Id';
import CASE_FIELD_FORECAST_PRODUCT from '@salesforce/schema/Case.Forecast_Product__c';

import RAISEHAND_FIELD_ID from '@salesforce/schema/Raise_Hand__c.Id';
import RAISEHAND_FIELD_CASE from '@salesforce/schema/Raise_Hand__c.Case__c';
import RAISEHAND_FIELD_TYPE from '@salesforce/schema/Raise_Hand__c.Type__c';
import RAISEHAND_FIELD_TITLE from '@salesforce/schema/Raise_Hand__c.Title__c';
import RAISEHAND_FIELD_PRODUCT from '@salesforce/schema/Raise_Hand__c.Product__c';
import RAISEHAND_FIELD_QUESTION from '@salesforce/schema/Raise_Hand__c.Question__c';
import RAISEHAND_FIELD_CASE_PRODUCT from '@salesforce/schema/Raise_Hand__c.Case__r.Forecast_Product__c';

// Tejasvi Royal -> I2RT-2682: Weekend/Holiday Support & case Monitoring/Hand-off
// Tejasvi Royal -> I2RT-2634: Weekend/Holiday Support Notifications
// Tejasvi Royal -> I2RT-3072: Raise hand record creation w/ Handoff (Bug Fix)
import updateCase from '@salesforce/apex/RaiseHandController.updateCase';
import CASE_FIELD_RECORD_TYPE_ID from '@salesforce/schema/Case.RecordTypeId';

const CASE_FIELDS = [
    CASE_FIELD_ID,
    CASE_FIELD_RECORD_TYPE_ID,
    CASE_FIELD_FORECAST_PRODUCT
];

const RAISE_HAND_FIELDS = [
    RAISEHAND_FIELD_ID,
    RAISEHAND_FIELD_TYPE,
    RAISEHAND_FIELD_TITLE,
    RAISEHAND_FIELD_PRODUCT,
    RAISEHAND_FIELD_QUESTION,
    RAISEHAND_FIELD_CASE,
    RAISEHAND_FIELD_CASE_PRODUCT
];

export default class CaseRaiseHand extends LightningElement {

    @api recordId;
    caseId;
    raiseHandId;

    isConvert = false;

    @track caseProductName;
    @track caseRecordTypeId;
    @track saveInProgress = false;
    @track classname;
    @track classnamesteps;
    //@track selectedUserId;            // Tejasvi Royal -> I2RT-2682: Weekend/Holiday Support & case Monitoring/Hand-off
    @track selectedQueueId;             // Tejasvi Royal -> I2RT-2682: Weekend/Holiday Support & case Monitoring/Hand-off
    @track handoffType;                 // Tejasvi Royal -> I2RT-2682: Weekend/Holiday Support & case Monitoring/Hand-off
    //@track handoffQueue;              // Tejasvi Royal -> I2RT-2682: Weekend/Holiday Support & case Monitoring/Hand-off
    @track handoffComments;             // Tejasvi Royal -> I2RT-2682: Weekend/Holiday Support & case Monitoring/Hand-off
    @track handoffSteps;                // Tejasvi Royal -> I2RT-2682: Weekend/Holiday Support & case Monitoring/Hand-off
    //@track holidayStartValue;         // Tejasvi Royal -> I2RT-2634: Weekend/Holiday Support Notifications
    //@track holidayEndValue;           // Tejasvi Royal -> I2RT-2634: Weekend/Holiday Support Notifications
    //@track weekendStartValue;         // Tejasvi Royal -> I2RT-2634: Weekend/Holiday Support Notifications
    //@track weekendEndValue;           // Tejasvi Royal -> I2RT-2634: Weekend/Holiday Support Notifications
    @track selectedOwnerId;             // Tejasvi Royal -> Weekend/Holiday Support -> Feedback/Enhancement through Demo
    @track supportStartValue;           // Tejasvi Royal -> Weekend/Holiday Support -> Feedback/Enhancement through Demo
    @track supportEndValue;             // Tejasvi Royal -> Weekend/Holiday Support -> Feedback/Enhancement through Demo

    @track typeOptions = [
        { label: 'Get Help', value: 'Get Help' },
        { label: 'Co-own', value: 'Co-own' },
        { label: 'Handoff/Monitoring', value: 'Handoff' },
        { label: 'Join a Customer Meeting', value: 'Join a Customer Meeting' },
        { label: 'Repro Environment Setup', value: 'Repro Environment Setup' }
    ];

    @track subtypeOptions = [
        { label: 'Multi Product', value: 'Multi Product' },
        { label: 'Operations', value: 'Operations' },
        { label: 'Product Specialist (Review/ Handoff)', value: 'PS Review' }
    ];

    @track envtypes = [
        { label: 'Development', value: 'Development' },
        { label: 'QA', value: 'QA' },
        { label: 'SIT', value: 'SIT' },
        { label: 'UAT', value: 'UAT' },
        { label: 'SUP', value: 'SUP' },
        { label: 'Production', value: 'Production' },
        { label: 'Sandbox', value: 'Sandbox' },
        { label: 'Prerelease', value: 'Prerelease' }

    ]; //<T02>

    
    @track activitytypes = [
        { label: 'Report a service outage', value: 'Report a service outage' },
        { label: 'Report an issue or for any queries', value: 'Report an issue or for any queries' },
        { label: 'Request an activity/change request', value: 'Request an activity/change request' }       

    ];

    

    @track meetingTimeOptions = [
        { label: 'Join Ongoing Meeting', value: 'Join Ongoing Meeting' },
        { label: 'Yet To Schedule', value: 'Yet To Schedule' },
        { label: 'Customer Requested Time', value: 'Customer Requested Time' }
    ];

    @track productOptions = [];

    @track raiseHandObj = {
        apiName: "Raise_Hand__c",
        fields: {
            Id: null
        }
    };


    @track additionalSelectionOption=[
        { label: 'Product Specialists', value: 'PS Review' }, 
        { label: 'Support Engineers', value: 'Support Engineer' }
    ]; // T01 -> I2RT-7258



    @wire(getRecord, { recordId: '$caseId', fields: CASE_FIELDS })
    getCaseDetails({ error, data }) {
        if (error) {
            console.log("error - " + JSON.stringify(error));
        } else if (data) {
            this.caseProductName = data.fields.Forecast_Product__c.value;
            this.caseRecordTypeId = data.fields.RecordTypeId.value;
            console.log("caseProductName - " + this.caseProductName);
            console.log("caseRecordTypeId - " + this.caseRecordTypeId);
            this.raiseHandObj.fields.Case__c = this.caseId;
        }
    }

    @wire(getRecord, { recordId: '$raiseHandId', fields: RAISE_HAND_FIELDS })
    getRaiseHandDetails({ error, data }) {
        if (error) {
            console.log("error - " + JSON.stringify(error));
        } else if (data) {
            console.log("data.fields - " + JSON.stringify(data.fields));

            this.raiseHandObj.fields.Id = data.fields.Id.value;
            this.raiseHandObj.fields.Case__c = data.fields.Case__c.value;
            this.raiseHandObj.fields.Type__c = 'Co-own';
            this.raiseHandObj.fields.Product__c = data.fields.Product__c.value;
            this.raiseHandObj.fields.Title__c = data.fields.Title__c.value;
            this.raiseHandObj.fields.Description__c = data.fields.Question__c.value;
            this.caseProductName = data.fields.Case__r.value.fields.Forecast_Product__c.value;

            //this.caseId = data.fields.Case__c.value;
        }
    }

    get showType(){
        return !this.isConvert;
    }

    get showSubtype(){
        var requestType = this.raiseHandObj.fields.Type__c;
        return (requestType && requestType == 'Co-own');
    }

    get showProduct(){
        var requestType = this.raiseHandObj.fields.Type__c;
        var requestSubtype = this.raiseHandObj.fields.Subtype__c;
        return (requestType && (!requestSubtype || requestSubtype != 'Operations'));
        
    }

    get showQuestion(){
        var requestType = this.raiseHandObj.fields.Type__c;
        return (requestType && requestType == 'Get Help');
    }

    get showTitle(){
        var requestType = this.raiseHandObj.fields.Type__c;
        return (requestType);
    }

    get showDescription(){
        var requestType = this.raiseHandObj.fields.Type__c;
        return (requestType && requestType != 'Get Help');
    }

    get showMeetingTime(){
        var requestType = this.raiseHandObj.fields.Type__c;
        return (requestType && requestType == 'Join a Customer Meeting');
    }

    get showCaseHandoff(){
        var requestType = this.raiseHandObj.fields.Type__c;
        return (requestType && requestType == 'Handoff');
    }

    get showoperations(){
        var requestsubType = this.raiseHandObj.fields.Subtype__c;
        return (requestsubType && requestsubType == 'Operations');
    }


    get descPlaceholderText(){
        var requestType = this.raiseHandObj.fields.Type__c;
        if(requestType === 'Co-own'){
            return 'Steps taken, Expectation, log details and system traces from log';
        }else if(requestType === 'Join a Customer Meeting'){
            return '1. Specify what is needed on the meeting\n2. Specific customer requested time if applicable\n3. Zoom link if applicable';
        }else if(requestType === 'Repro Environment Setup'){
            return 'EBF DB, OS, Customer data and use case';
        }
    }

    get showAdditionalChoice(){ //I2RT-7258
        var requestType = this.raiseHandObj.fields.Type__c;
        return (requestType && requestType ==='Join a Customer Meeting');
    }
    
    connectedCallback() {
        console.log("raiseHandObj - " + JSON.stringify(this.raiseHandObj));
        this.selectedAddtionalChoice='Support Engineer';// T01 default value = Engineer 
        console.log("recordId >> ", this.recordId);
        if(String(this.recordId).startsWith('500')){
            this.caseId = this.recordId;
        }else{
            this.raiseHandId = this.recordId;
            this.isConvert = true;
        }
    }

    handleFieldChange(event) {
        console.log({ event });
        console.log("event.target.value - " + event.target.value);
        console.log("event.currentTarget.dataset.id - " + JSON.stringify(event.currentTarget.dataset.id));
        console.log("event.currentTarget.dataset.field - " + JSON.stringify(event.currentTarget.dataset.field));

        this.raiseHandObj.fields[event.currentTarget.dataset.field] = event.target.value;
        //console.log("raiseHandObj - " + JSON.stringify(this.raiseHandObj));

        if (event.currentTarget.dataset.id == 'requestType' ) {
            this.loadSection();
        } else if (event.currentTarget.dataset.id == 'requestSubtype' ||event.currentTarget.dataset.id == 'addonChoice'  ) { //added addonchoice as per T01 I2RT-7258

            
            if(event.currentTarget.dataset.id == 'addonChoice' ){ //T01 if block
                if(event.target.value=='PS Review'){ //T01
                    this.selectedAddtionalChoice='PS Review'; //T01
            } else{//T01
                this.selectedAddtionalChoice='Support Engineer'; //T01
            }               
            }

            this.loadProducts();
        }

        
    }

    // Tejasvi Royal -> I2RT-2682: Weekend/Holiday Support & case Monitoring/Hand-off
    // Tejasvi Royal -> I2RT-2634: Weekend/Holiday Support Notifications
    // Tejasvi Royal -> Weekend/Holiday Support -> Feedback/Enhancement through Demo
    //======== START: HANDOFF/MONITORING EVENT HANDLERS ========
    handleHandoffTypeChange(event) {
        this.handoffType = event.detail;
        console.log('[Parent] handoffType -> ' + this.handoffType);
    }
    /* handleUserLookupSelectionChange(event) {
        this.selectedUserId = event.detail;
        console.log('[Parent] selectedUserId -> ' + this.selectedUserId);
    } */
    handleQueueLookupSelectionChange(event) {
        this.selectedQueueId = event.detail;
        console.log('[Parent] selectedQueueId -> ' + this.selectedQueueId);
    }
    handleCombinedLookupSelectionChange(event) {
        this.selectedOwnerId = event.detail;
        console.log('[Parent] selectedOwnerId -> ' + this.selectedOwnerId);
    }
    /* DEPRECATED:
    handleHandoffQueueChange(event) {
        this.handoffQueue = event.detail.value;
        console.log('handoffQueue -> ' + this.handoffQueue)
    } */
/*     handleWeekendStartValue(event) {
        this.weekendStartValue = event.detail;
        console.log('[Parent] weekendStartValue -> ' + this.weekendStartValue);
    }
    handleWeekendEndValue(event) {
        this.weekendEndValue = event.detail;
        console.log('[Parent] weekendEndValue -> ' + this.weekendEndValue);
    }
    handleHolidayStartValue(event) {
        this.holidayStartValue = event.detail;
        console.log('[Parent] holidayStartValue -> ' + this.holidayStartValue);
    }
    handleHolidayEndValue(event) {
        this.holidayEndValue = event.detail;
        console.log('[Parent] holidayEndValue -> ' + this.holidayEndValue);
    } */
    handleSupportStartValue(event) {
        this.supportStartValue = event.detail;
        console.log('[Parent] supportStartValue -> ' + this.supportStartValue);
    }
    handleSupportEndValue(event) {
        this.supportEndValue = event.detail;
        console.log('[Parent] supportEndValue -> ' + this.supportEndValue);
    }
    handleHandoffCommentsChange(event) {
        this.handoffComments = event.detail;
        console.log('[Parent] handoffComments -> ' + this.handoffComments);
    }
    handleHandoffStepsChange(event) {
        this.handoffSteps = event.detail;
        console.log('[Parent] handoffSteps -> ' + this.handoffSteps);
    }
    //======== END: HANDOFF/MONITORING EVENT HANDLERS ========

    loadSection() {
        var requestType = this.raiseHandObj.fields.Type__c;
        console.log("requestType - " + requestType);

        this.raiseHandObj.fields.Subtype__c = '';
        this.raiseHandObj.fields.Product__c = '';
        this.raiseHandObj.fields.Question__c = '';
        this.raiseHandObj.fields.Title__c = '';
        this.raiseHandObj.fields.Description__c = '';
        this.raiseHandObj.fields.Meeting_Time__c = '';

        switch (requestType) {
            case 'Get Help':
                this.loadProducts();
                break;
            case 'Repro Environment Setup':
                this.loadProducts();
                break;
            case 'Join a Customer Meeting':
                this.raiseHandObj.fields.Subtype__c=this.selectedAddtionalChoice; //T01
                this.loadProducts();
                break;
            default:
                break;
        }
    }

    loadProducts() {
        var requestType = this.raiseHandObj.fields.Type__c;

        if(requestType==='Join a Customer Meeting'){ //I2RT-7258
            this.raiseHandObj.fields.Subtype__c=this.selectedAddtionalChoice; //T01
        }
        var requestSubtype = '';
        if (this.raiseHandObj.fields.Subtype__c) {
            requestSubtype = this.raiseHandObj.fields.Subtype__c;
        }
        if(requestType==='')
        console.log("requestType - " + requestType);
        console.log("requestSubtype - " + requestSubtype);
        console.log("this.caseProductName - " + this.caseProductName);

        var productOptions = [];

        this.saveInProgress = true;
        getSkills({
            type: requestType,
            subtype: requestSubtype,
            productName: this.caseProductName 
        })
        .then(result => {
            console.log("result - " + JSON.stringify(result));
            result.forEach(element => {
                productOptions.push({ label: element, value: element });
            });
            this.productOptions = productOptions;

            let productName = this.caseProductName;
            if ('Operations' == requestSubtype) {
                productName = 'GCS Operations CRE';
                this.productOptions = [];
                this.productOptions.push({label: 'GCS Operations CRE', value: 'GCS Operations CRE'})
            }
            this.raiseHandObj.fields.Product__c = productName;

            let productElement = this.template.querySelector('[data-id="productName"]');
            productElement.value = productName;

            this.saveInProgress = false;
            console.log("productName - " + productName);
            console.log("this.caseProductName - " + this.caseProductName);
        })
        .catch(error => {
            console.log("error - " + JSON.stringify(error));
            this.saveInProgress = false;
        })
    }

    submit() {
        console.log("raiseHandObj - " + JSON.stringify(this.raiseHandObj));
        var requestType = this.raiseHandObj.fields.Type__c;
        var requestSubtype = this.raiseHandObj.fields.Subtype__c;

        let validationSuccessful = false;

        let requiredFieldsValidated = true;
        this.classname="";
        this.classnamesteps = "";
        // Validating Required Fields
        if (!requestType) {
            requiredFieldsValidated = false;
        } else {
            switch (requestType) {
                case 'Get Help':
                    if (!this.raiseHandObj.fields.Product__c
                        || !this.raiseHandObj.fields.Title__c
                        || !this.raiseHandObj.fields.Question__c) {
                        requiredFieldsValidated = false;
                        
                    }
                    break;
                case 'Co-own':
                    if (!this.raiseHandObj.fields.Subtype__c
                        || (!this.raiseHandObj.fields.Product__c && requestSubtype != 'Operations')
                        || !this.raiseHandObj.fields.Title__c
                        || !this.raiseHandObj.fields.Description__c) {
                        requiredFieldsValidated = false;
                    }
                    break;
                case 'Handoff':
                    console.log('this.handoffComments: '+this.handoffComments);
                    console.log('this.handoffComments valid: '+this.isValidInput(this.handoffComments));
                    console.log('this.handoffSteps: '+this.handoffSteps);
                    if (!this.handoffType
                        || (this.handoffType === 'Live/Queue Handoff' && !this.selectedOwnerId)
                        || (this.handoffType === 'Follow the Sun Monitoring' && !this.selectedQueueId)
                        || (this.handoffType === 'Weekend/Holiday Monitoring' && !this.supportStartValue && !this.supportEndValue)
                        || (!this.isValidInput(this.handoffComments))
                        || (!this.isValidInput(this.handoffSteps))) {
                        requiredFieldsValidated = false;
                        if(!this.isValidInput(this.handoffComments)){
                            this.classname="required";
                        }
                        if(!this.isValidInput(this.handoffSteps)){
                            this.classnamesteps = "required";
                        }
                        console.log('In Handoff Switch Case');
                    }
                    break;
                case 'Join a Customer Meeting':
                    if (!this.raiseHandObj.fields.Product__c
                        || !this.raiseHandObj.fields.Meeting_Time__c
                        || !this.raiseHandObj.fields.Title__c
                        || !this.raiseHandObj.fields.Description__c) {
                        requiredFieldsValidated = false;
                    }
                    break;
                case 'Repro Environment Setup':
                    if (!this.raiseHandObj.fields.Product__c
                        || !this.raiseHandObj.fields.Title__c
                        || !this.raiseHandObj.fields.Description__c) {
                        requiredFieldsValidated = false;
                    }
                    break;
                default:
                    break;
            }
        }
        console.log('in the console statement');
        if (!requiredFieldsValidated) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please enter all required values!',
                    variant: 'error',
                })
            );
        }else{
            if(this.raiseHandObj.fields.Title__c && this.raiseHandObj.fields.Title__c.length > 255){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Title must not exceed 255 characters!',
                        variant: 'error',
                    })
                );
            }else{
                validationSuccessful = true;
            }
        }

        if (validationSuccessful) {
            if(requestType != 'Handoff'){                
                this.saveInProgress = true;
                createRaiseHand({
                    raiseHand: Object.assign({ 'sobjectType': 'Raise_Hand__c' }, this.raiseHandObj.fields)
                })
                .then(result => {
                    console.log("result - " + JSON.stringify(result));
                    var raiseHandId = result;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Request raised successfully!',
                            variant: 'success',
                        }),
                    );
                    this.saveInProgress = false;
                    getRecordNotifyChange([
                        {recordId: raiseHandId},
                        {recordId: this.raiseHandId},
                        {recordId: this.caseId}
                    ]);
                    this.closeQuickAction(raiseHandId);
                })
                .catch(error => {
                    console.log("error - " + JSON.stringify(error));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error raising the request!',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                    this.saveInProgress = false;
                    this.closeQuickAction();
                });    
            }else{
                this.saveInProgress = true;
                // Tejasvi Royal -> I2RT-2682: Weekend/Holiday Support & case Monitoring/Hand-off
                // Tejasvi Royal -> I2RT-2634: Weekend/Holiday Support Notifications
                // Tejasvi Royal -> I2RT-3072: Raise hand record creation w/ Handoff (Bug Fix)
                // Tejasvi Royal -> Weekend/Holiday Support -> Feedback/Enhancement through Demo
                // Call specific Controller Method for Case Update
                updateCase({
                    recordId: this.recordId,
                    handoffType: this.handoffType,
                    selectedOwnerId: this.selectedOwnerId,
                    selectedQueueId: this.selectedQueueId,
                    handoffComments: this.handoffComments,
                    handoffSteps: this.handoffSteps,
                    supportStartDateTime: this.supportStartValue,
                    supportEndDateTime: this.supportEndValue})
                .then(result => {
                    console.log("result - " + JSON.stringify(result));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Handoff/Monitoring initiated!',
                            variant: 'success',
                        }),
                    );
                    this.saveInProgress = false;
                    this.closeQuickAction();
                })
                .catch(error => {
                    console.log("error - " + JSON.stringify(error));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Unable to initiate Handoff/Monitoring.',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                    this.saveInProgress = false;
                    this.closeQuickAction();
                });  
            }  
        }
    }

    isValidInput(input){
        return (input && input?.replace(/<[^>]+>/g, '')?.trim().length > 0) ? true : false;
    }

    cancel() {
        this.closeQuickAction();
    }
    
    closeQuickAction(recordId) {
        console.log('firing close event')
        
        var closeQA = new CustomEvent('close');

        if(recordId){
            const filters = [recordId];
        
            closeQA = new CustomEvent('close', {
                detail: {filters}
            });    
        }

        this.dispatchEvent(closeQA);
        console.log('close event fired!')
    }
}