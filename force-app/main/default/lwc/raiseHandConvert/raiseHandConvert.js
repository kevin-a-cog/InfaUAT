import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import getSkills from '@salesforce/apex/RaiseHandController.getSkills';
import raiseHandRequest from '@salesforce/apex/RaiseHandController.raiseHandRequest';
import closeRequest from '@salesforce/apex/RaiseHandController.closeRequest';

import ID_FIELD from '@salesforce/schema/Raise_Hand__c.Id';
import TYPE_FIELD from '@salesforce/schema/Raise_Hand__c.Type__c';
import SKILL_FIELD from '@salesforce/schema/Raise_Hand__c.Skill__c';
import QUESTION_FIELD from '@salesforce/schema/Raise_Hand__c.Question__c';
import CASE_FIELD from '@salesforce/schema/Raise_Hand__c.Case__c';
import CASE_PRODUCT_FIELD from '@salesforce/schema/Raise_Hand__c.Case__r.Forecast_Product__c';

const RAISE_HAND_FIELDS = [
    ID_FIELD,
    TYPE_FIELD,
    SKILL_FIELD,
    QUESTION_FIELD,
    CASE_FIELD,
    CASE_PRODUCT_FIELD
];

export default class RaiseHandConvert extends LightningElement {
        
    @track subtypeOptions=[
        {label: 'Multi Product', value: 'Multi Product'}, 
        {label: 'Product Specialist Review', value: 'PS Review'},
        {label: 'Operations', value: 'Operations'}
    ];

    @track productOptions=[];

    @track urgencyOptions=[
        {label: 'Normal', value: 'Normal'},
        {label: 'High', value: 'High'},
        {label: 'Critical', value: 'Critical'}
    ];

    @track typeOfIssueOptions=[
        {label: 'Type 1', value: 'Type 1'},
        {label: 'Type 2', value: 'Type 2'},
        {label: 'Type 3', value: 'Type 3'}
    ];

    originalSkill;
    type;
    question;

    requestType = 'Co-own';
    productName;
    urgency;
    typeOfIssue;
    description;

    caseId;
    caseProduct;

    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: RAISE_HAND_FIELDS })
    cse({ error, data }) {
        if (error) {
            console.log("error - " + JSON.stringify(error));
        } else if (data) {
            this.type = data.fields.Type__c.value;
            this.question = data.fields.Question__c.value;
            this.description = this.question;
            this.originalSkill = data.fields.Skill__c.value;
            this.caseId = data.fields.Case__c.value;

            console.log("data.fields - " + JSON.stringify(data.fields));

            this.caseProduct = data.fields.Case__r.value.fields.Forecast_Product__c.value;
            console.log("caseProduct - " + this.caseProduct);
        }
    }

    @track saveInProgress=false;

    connectedCallback(){
        //console.log("typeOptions - " + JSON.stringify(this.typeOptions));
    }

    loadSkills(){
        if(this.template.querySelector('[data-id="requestSubtype"]')){
            this.requestSubtype = this.template.querySelector('[data-id="requestSubtype"]').value;
        }else{
            this.requestSubtype = '';
        }

        var productOptions = [];

        getSkills({
            type: this.requestType,
            subtype: this.requestSubtype,
            productName: this.caseProduct
        })
        .then(result => {
            console.log("result - " + JSON.stringify(result));
            result.forEach(element => {
                productOptions.push({label: element, value: element});
            });
            this.productOptions = productOptions;
            if(this.requestSubtype== 'PS Review' && productOptions[0]){
                this.productName = productOptions[0].value;
            }else if(this.requestType== 'Repro Environment Setup'){
                this.productName = this.caseProduct;
            }else{
                this.productName = '';
            }
        })
        .catch(error => {
            console.log("error - " + JSON.stringify(error));
        })
    }

    submit() {
        console.log('recid='+this.recordId);
        this.productName = this.template.querySelector('[data-id="productName"]').value;
                
        if(this.template.querySelector('[data-id="requestSubtype"]')){
            this.requestSubtype = this.template.querySelector('[data-id="requestSubtype"]').value;
        }else{
            this.requestSubtype = '';
        }

        if(this.template.querySelector('[data-id="urgency"]')){
            this.urgency = this.template.querySelector('[data-id="urgency"]').value;
        }else{
            this.urgency = '';
        }

        if(this.template.querySelector('[data-id="typeOfIssue"]')){
            this.typeOfIssue = this.template.querySelector('[data-id="typeOfIssue"]').value;
        }else{
            this.typeOfIssue = '';
        }

        if(this.template.querySelector('[data-id="description"]')){
            this.description = this.template.querySelector('[data-id="description"]').value;
        }else{
            this.description = '';
        }
        
        console.log("requestType selected - " + JSON.stringify(this.requestType));
        
        this.saveInProgress=true;
        raiseHandRequest({
            caseId: this.caseId,         
            type: this.requestType,
            subtype: this.requestSubtype,
            productName: this.productName,
            question: '',
            urgency: this.urgency,
            typeOfIssue: this.typeOfIssue,
            description: this.description,
            reproExpectation: ''
        })
        .then(result => {
            console.log("result - " + JSON.stringify(result));
            closeRequest({
                raiseHandId: this.recordId
            })
            .then(result => {
                console.log("result - " + JSON.stringify(result));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Request raised successfully!',
                        variant: 'success',
                    }),
                );
                this.saveInProgress=false;
                this.closeQuickAction();
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
                this.saveInProgress=false;
                this.closeQuickAction();
            });
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
            this.saveInProgress=false;
            this.closeQuickAction();
        });
    }

    cancel(){
        this.closeQuickAction;
    }

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }
}