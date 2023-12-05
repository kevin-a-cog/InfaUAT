import { LightningElement,api,wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ES_STATUS_FIELD from '@salesforce/schema/Estimation_Summary__c.Status__c';
import PRIMARY_FIELD from '@salesforce/schema/Estimation_Summary__c.Primary__c';
import OPP_NAME_FIELD from '@salesforce/schema/Estimation_Summary__c.Opportunity__r.Name';
import USER_ID from '@salesforce/user/Id';
import USER_TYPE_FIELD from '@salesforce/schema/User.UserType';
import FORM_NAME_FIELD from '@salesforce/schema/Estimation_Summary__c.Form__r.Name';
import level1Label from '@salesforce/label/c.EstimationSummaryLevel1Warning';
import level2Label from '@salesforce/label/c.EstimationSummaryLevel2Warning';
//import checkboxUncheckWarning from '@salesforce/label/c.checkboxUncheckWarning';
import EndOfLifeForms from '@salesforce/label/c.EndOfLifeForms';
import EndOfLifeError from '@salesforce/label/c.EndOfLifeError';

export default class IpueEstimationSummaryBanner extends LightningElement {

    OptyName;
    label = {
        level1Label,
        level2Label,
        //checkboxUncheckWarning,
        EndOfLifeForms,
        EndOfLifeError
    };

    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: [PRIMARY_FIELD,OPP_NAME_FIELD,FORM_NAME_FIELD] }) 
    estimatorRec;

    @wire(getRecord, { recordId: '$recordId', fields: [ES_STATUS_FIELD] }) 
    estimatorStatus;

    @wire(getRecord, { recordId: USER_ID , fields: [USER_TYPE_FIELD] }) 
    userRec;

    //Check if the current user is Internal/External
    get isExternalUser(){
        if(getFieldValue(this.userRec.data, USER_TYPE_FIELD) == 'Standard'){
            return false;
        }
        return true;
    }
    

    get submitEstimateBanner() {
        this.status = getFieldValue(this.estimatorStatus.data, ES_STATUS_FIELD);
        return this.status === 'Initialized Agreement';
    }

    get closeEstimateBanner() {
        return this.status === 'Finalized Agreement';
    }

    get primaryEstimateBanner() {
        this.primary = getFieldValue(this.estimatorRec.data, PRIMARY_FIELD);
        if(this.primary) {
            this.OptyName = getFieldValue(this.estimatorRec.data, OPP_NAME_FIELD);
            return this.primary;
        }
    }

    get isLevel1(){

        let formName = getFieldValue(this.estimatorRec.data, FORM_NAME_FIELD);
        if(formName && formName.indexOf('Level 1') > -1) {
            return true;
        }
    }

    get isLevel2(){

        let formName = getFieldValue(this.estimatorRec.data, FORM_NAME_FIELD);
        if(formName && formName.indexOf('Level 2') > -1) {
            return true;
        }
    }

    get showEndOfLife(){

        let formName = getFieldValue(this.estimatorRec.data,FORM_NAME_FIELD);
        let formNamesForEOL = this.label.EndOfLifeForms.split(',');
        
        return formNamesForEOL.includes(formName);
    }

}