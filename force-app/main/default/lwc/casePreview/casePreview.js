import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

//LWC Utilties
import { log } from 'c/globalUtilities';

//Case Fields to import from schema
import CASE_STATUS from '@salesforce/schema/Case.Status';
import CASE_SUBJECT from '@salesforce/schema/Case.Subject';
import CASE_NUMBER from '@salesforce/schema/Case.CaseNumber';
import CASE_PRIORITY from '@salesforce/schema/Case.Priority';
import CASE_CONTACTID from '@salesforce/schema/Case.ContactId';
import CASE_CREATEDDATE from '@salesforce/schema/Case.CreatedDate';
import CASE_TIMEZONE from '@salesforce/schema/Case.Case_Timezone__c';
import CASE_ESCALATEDDATE from '@salesforce/schema/Case.Escalated_Date__c';
import CASE_SUPPORTACCOUNTID from '@salesforce/schema/Case.Support_Account__c';
import CASE_TARGET_CLOSEDATE from '@salesforce/schema/Case.Resolution_Target_DateTime__c';

//Apex methods
import buildTimeLine from '@salesforce/apex/CasePrioritizationViewLwcV4Ctrl.buildTimeLine';

const FIELDS = [CASE_STATUS,CASE_SUBJECT,CASE_NUMBER,CASE_PRIORITY,CASE_CONTACTID,CASE_CREATEDDATE,CASE_TIMEZONE,CASE_ESCALATEDDATE,CASE_SUPPORTACCOUNTID,CASE_TARGET_CLOSEDATE];

export default class CasePreview extends LightningElement {

    @api caseId;
    @api showBtn = false;
    @api disableNextCase = false;
    @api disablePreviousCase = false;
    @api showCasePreview;

    @track caseRecord;
    @track caseTimelines;
    @track isCaseLoading = true;

    connectedCallback(){
        log('caselist: '+JSON.stringify(this.caseList));
        log('disableNextCase: '+this.disableNextCase);
        log('disablePreviousCase: '+this.disablePreviousCase);
    }

    @wire(getRecord, { recordId: '$caseId', fields: FIELDS })
    wiredRecord({error, data}){
        if(data){
            this.caseRecord = data;
            if(this.caseRecord){
                this.isCaseLoading = true;
                this.buildTimeLineHelper(this.caseId);
            }
        }
        else if(error){
            log('@Error on getting case record: '+JSON.stringify(error));
        }
    }

    buildTimeLineHelper(caseId) {
        buildTimeLine({
            'caseId': caseId,
            'blflag': 'true'
        }).then(result => {
            log('casetimeline: '+JSON.stringify(result));

            try {           
                var prasedResult = JSON.parse(JSON.stringify(result));

                for(var i =0; i < prasedResult.data1.length; i++){
                    var timeLineItem = prasedResult.data1[i];
                    if(timeLineItem.feed != undefined){
                        if(timeLineItem.type == 'Feed Activity'){   
                            if(timeLineItem.feed.Body != undefined && timeLineItem.feed.Body != ''){
                                log('decodeURIComponent(encodeURIComponent(tl.feed.Body)) -- > ' + decodeURIComponent(encodeURIComponent(timeLineItem.feed.Body)));
                                timeLineItem.feed.Body = decodeURIComponent(encodeURIComponent(timeLineItem.feed.Body));
                            }
                        }                     
                    }
                }

                this.caseTimelines = prasedResult?.data1;
                log('casetimelines: '+JSON.stringify(this.caseTimelines));

            } catch (error) {
                log('@Error while parsing timeline data: '+JSON.stringify(error));
            }

        }).catch(error => {
            log('@Error on getting casetimeline: '+JSON.stringify(error));
        }).finally(() => {
            this.isCaseLoading = false;
        });
    }

    handleNextCase(){
        log('Show Next Case');
        //Dispatch event to show the next case on list
        const clickEvent = new CustomEvent('nextcase', { detail: {currentCaseId: this.caseId}, bubbles: true });
        this.dispatchEvent(clickEvent);
    }

    handlePreviousCase(){
        //Dispatch event to show the previous case on list
        const clickEvent = new CustomEvent('previouscase', { detail: {currentCaseId: this.caseId}, bubbles: true });
        this.dispatchEvent(clickEvent);
    }

    cancelPreview(){
        //Dispatch event to hide the preview
        const clickEvent = new CustomEvent('hidepreview', { detail: {hide: true}, bubbles: true });
        this.dispatchEvent(clickEvent);
    }

    get accountId(){
        return getFieldValue(this.caseRecord, CASE_SUPPORTACCOUNTID);
    }

    get contactId(){
        return getFieldValue(this.caseRecord, CASE_CONTACTID);
    }

    get timezoneId(){
        return getFieldValue(this.caseRecord, CASE_TIMEZONE);
    }

    get boolDisableNextCase(){
        return this.disableNextCase;
    }

    get boolDisablePreviousCase(){
        return this.disablePreviousCase;
    }

    get showNextPreviousBTNs(){
        return this.showBtn;
    }

}