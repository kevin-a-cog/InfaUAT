import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LAR_OBJECT from '@salesforce/schema/Legal_Agreement__c';
import ACCOUNT_FIELD from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Account__c';
import OPPTY_FIELD from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Opportunity2__c';
import TERRITORY_FIELD from '@salesforce/schema/SBQQ__Quote__c.Territory__c';
import NAME_FIELD from '@salesforce/schema/SBQQ__Quote__c.Name';
import ORDERED_FIELD from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Ordered__c';
import EXHA_LAR_FIELD from '@salesforce/schema/SBQQ__Quote__c.Exhibit_A_Legal_Agreement_Reference__c';
import LAR_TYPE from '@salesforce/label/c.ExhA_LAR_Type';
import LAR_REC_TYPE from '@salesforce/label/c.Cloud_and_License_LAR_record_type';
import LEGAL_ENTITY from '@salesforce/schema/SBQQ__Quote__c.Legal_Entity_Name__c'

const FIELDS = [ACCOUNT_FIELD, OPPTY_FIELD, TERRITORY_FIELD, NAME_FIELD, ORDERED_FIELD, EXHA_LAR_FIELD, LEGAL_ENTITY];

export default class CreateLarFromQuote extends LightningElement {
    @api recordId;
    larCreateable = true;
    showSpinner = true;

    legalEntityMatchError = false;
    legalEntityMatchErrorClass = '';


    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    quoteRec;

    @wire(getObjectInfo, { objectApiName: LAR_OBJECT })
    wiredData({ data, error }) {
        this.showSpinner = false;
        if (data) {
            this.larCreateable = data.createable;
        }
        if (error) {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Error checking Object permission',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }

    get accountName() {
        return getFieldValue(this.quoteRec.data, ACCOUNT_FIELD);
    }

    get opptyName() {
        return getFieldValue(this.quoteRec.data, OPPTY_FIELD);
    }

    get quoteName() {
        return getFieldValue(this.quoteRec.data, NAME_FIELD);
    }

    get quoteOrdered() {
        return getFieldValue(this.quoteRec.data, ORDERED_FIELD);
    }

    get contractGroup() {
        var territoryName = String(getFieldValue(this.quoteRec.data, TERRITORY_FIELD));
        if (territoryName.startsWith('AP') || territoryName.startsWith('JP')) {
            return 'Sales - APJ';
        } else if (territoryName.startsWith('EA')) {
            return 'Sales - EMEA/LA';
        } else {
            return 'Sales - NA';
        }
    }
    get legalEntity() {
        let legalEntity = String(getFieldValue(this.quoteRec.data, LEGAL_ENTITY));
        return legalEntity;

    }

    get contractType() {
        return LAR_TYPE;
    }

    get agreementType() {
        return LAR_TYPE;
    }

    get quoteExhALar() {
        return getFieldValue(this.quoteRec.data, EXHA_LAR_FIELD);
    }

    get larRecType() {
        return LAR_REC_TYPE;
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSubmit() {
        this.showSpinner = true;
    }

    handleSuccess(event) {
        const evt = new ShowToastEvent({
            title: 'LAR Created',
            message: 'Legal Agreement ' + event.detail.fields.Name.value + ' was created.',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
        this.handleCancel();
    }

    handleError(event) {
        this.showSpinner = false;
    }
    handleLegalEntityChange(event) {
        if (this.legalEntity != event.target.value) {
            this.legalEntityMatchError = true;
        }
        else {
            this.legalEntityMatchError = false;
        }

    }

}