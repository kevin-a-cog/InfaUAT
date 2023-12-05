import { LightningElement,wire,api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


import insertRecord from '@salesforce/apex/RiskAssessmentController.saveRecords';
import getprimaryEst from '@salesforce/apex/RiskAssessmentController.getEngagementId';

const FIELDS = ['Engagement__c.Engagement_Journey__c','Engagement__c.Primary_IPU_Estimator_ID__c','Engagement__c.Status__c'];

export default class RiskAssessmentContainer extends LightningElement {

    currentEng;
    currectJourneyValue;
    currentStatus;
    DGlineExist;
    viewMode = false;
    displayChildComp = true;
    loadchildComp = false;
    primaryEstimator;
   

    @api recordId;

    connectedCallback() {

        getprimaryEst({ engagementId: this.recordId })
        .then((result) => {
            console.log('result output dealclosure',JSON.stringify(result));
            this.DGlineExist = result;

        }).catch((error) => {
            console.log('error', 'Method : getprimaryEst :' + error.message + " : " + error.stack);
        })
    }
    
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading contact',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            //this.loadchildComp = !this.loadchildComp;
            this.currentEng = data;
            this.currectJourneyValue = this.currentEng.fields.Engagement_Journey__c.value;
            this.primaryEstimator = this.currentEng.fields.Primary_IPU_Estimator_ID__c.value;
            this.currentStatus = this.currentEng.fields.Status__c.value;
            
            if(this.currentStatus !== 'Information Gathering') {
                this.viewMode = true;
            } else {
                this.viewMode = false;
            }
        }
    }


    /*
	 Method Name : pafInsert
	 Description : This method gets executed in the success method to insert/Update Risk Assess Record.
	 Parameters	 : jsonstring, parid, isnew.
	 Return Type : None <T01>
	 */
     pafInsert(jsonstring, parid, isnew) {
        insertRecord({
            JSONString: jsonstring,
            parentId: parid,
            isNewRec: isnew
            }).then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Readiness Assessment Record is saved',
                        variant: 'success'
                    })
                );
                this.loadchildComp = !this.loadchildComp;
                this.dispatchEvent(new CloseActionScreenEvent()); 
            }) .catch((error) => {
                console.log('Error'+error.message + " : " + error.stack);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating or refreshing records',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
    
    onPafSubmitEvent(event) {
        if(event.detail.payloadData){
            this.pafInsert(event.detail.payloadData,this.recordId,false);
        }
    }

    displayComp(event) {
        if(!event.detail && !this.DGlineExist) {
            this.displayChildComp = false;
        } else {
            this.displayChildComp = true;
        }
    }
}