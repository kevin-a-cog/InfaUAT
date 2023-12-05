import { LightningElement, api, track } from 'lwc';
import { log } from 'c/globalUtilities'; //Vignesh

// import FIELD_CASE_NUMBER from '@salesforce/schema/Case.Case_Number__c';
// import FIELD_SUBJECT from '@salesforce/schema/Case.Subject';
// import FIELD_PRIORITY from '@salesforce/schema/Case.Priority';
// import FIELD_STATUS from '@salesforce/schema/Case.Status';
// import FIELD_FORECAST_PRODUCT from '@salesforce/schema/Case.Forecast_Product__c';
// import FIELD_VERSION from '@salesforce/schema/Case.Version__c';
// import FIELD_SUPPORT_ACCOUNT from '@salesforce/schema/Case.Support_Account__c';
// import FIELD_ACCOUNT from '@salesforce/schema/Case.AccountId';
// import FIELD_OWNER from '@salesforce/schema/Case.OwnerId';
// import FIELD_NEXT_ACTION from '@salesforce/schema/Case.Next_Action__c';


export default class CaseDatatableRecordName extends LightningElement {
    @api recId;
    @api recordNumber;
    @api isEscalated;
    @api showPreviewOption;
    
    @track casePreviewOn=false;

    //fields = [FIELD_CASE_NUMBER, FIELD_OWNER, FIELD_STATUS, FIELD_SUPPORT_ACCOUNT, FIELD_PRIORITY, FIELD_ACCOUNT, FIELD_FORECAST_PRODUCT, FIELD_VERSION, FIELD_NEXT_ACTION, FIELD_SUBJECT];

    get recordURL(){
        log('case id>>', this.recId);
        return '/lightning/r/' + this.recId + '/view';
    }

    togglePreview(event){
        log('togglePreview');
        this.casePreviewOn = !this.casePreviewOn;
    }

    hidePreview(event){
        log('hidePreview');
        this.casePreviewOn = false;
    }

    showPreview(event){
        log('showPreview');
        this.casePreviewOn = true;
    }
}