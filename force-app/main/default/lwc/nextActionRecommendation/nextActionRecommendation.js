import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecommendation from '@salesforce/apex/NextActionRecommendation.getRecommendation';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import RISK_ID from '@salesforce/schema/Risk_Issue__c.Id';
import RISK_TYPE from '@salesforce/schema/Risk_Issue__c.Type__c';
import RISK_REASON from '@salesforce/schema/Risk_Issue__c.Risk_Reason__c';
import REC_ACCEPTED from '@salesforce/schema/Risk_Issue__c.Recommendation_Accepted__c';
import REC_REJECTED from '@salesforce/schema/Risk_Issue__c.Recommendation_Rejected__c';


export default class NextActionRecommendation extends LightningElement {
    @api recordId;
    @track RiskID;
    @track Risk;
    @track RiskType;
    @track RiskReason;
    @track RecAccepted;
    @track RecRejected;
    @track hasRecommendation;
    @track taskarr = [];
    @track suggestionarr = [];
    @track engagementarr = [];
    nextActionRecommendationrecs;
    @track show = true;


    @wire(getRecord, { recordId: '$recordId', fields: [RISK_ID, RISK_TYPE, RISK_REASON, REC_ACCEPTED, REC_REJECTED] })
    getRiskRecord({ data, error }) {
        console.log('RiskRecord => ', data, error);
        if (data) {
            this.Risk = data;
            this.RiskID = this.recordId;
            this.RiskType = this.Risk.fields.Type__c.value;
            this.RiskReason = this.Risk.fields.Risk_Reason__c.value;
            this.RecAccepted = this.Risk.fields.Recommendation_Accepted__c.value;
            this.RecRejected = this.Risk.fields.Recommendation_Rejected__c.value;
            this.show =this.show;
            // this.RecAccepted= data.value.Recommendation_Accepted__c;
            //this.RecRejected = data.value.Recommendation_Rejected__c;
            //console.log('%%%' + JSON.stringify(this.nextActionRecommendations));
            this.reloadRecommendations();
        } else if (error) {
            console.error('ERROR => ', JSON.stringify(error)); // handle error properly
        }
    }


    reloadRecommendations() {
        console.log('entered  reloadRecommendations ');
        refreshApex(this.nextActionRecommendationrecs);
        console.log('%%% ' + this.RiskType);
        console.log('%%% ' + JSON.stringify(this.nextActionRecommendations));
        console.log('after refresh apex in reloadRecommendations ');

    }

    //@wire(getRecommendation, {riskId:'$recordId' }) nextActionRecommendations;

    @wire(getRecommendation, { riskId: '$recordId' }) nextActionRecommendations(result) {
        //console.log('inside wire');
        //console.log(JSON.stringify(result.data));
        this.nextActionRecommendationrecs = result;
        if (result.data) {
            this.taskarr = [];
            this.suggestionarr = [];
            this.engagementarr = [];
            //console.log('inside if');
            //console.log(JSON.stringify(result.data));
            for (let res in result.data) {
                //console.log('inside for');
                //console.log('res>>' + result.data[res]);
                //console.log('only res>>' + res);
                //console.log('res type>>'+result.data[res].Type__c); 
                //console.log(JSON.stringify(result.data));

                if (result.data[res].Type__c === 'Task')
                    //this.taskarr.push({ value: result.data[res], key: res });           
                    //this.taskarr[res] = result.data[res]; 
                    this.taskarr.push(result.data[res]);
                if (result.data[res].Type__c === 'Suggestion')
                    //this.suggestionarr.push({ value: result.data[res], key: res });             
                    //this.suggestionarr[res] = result.data[res];
                    this.suggestionarr.push(result.data[res]);
                if (result.data[res].Type__c === 'Engagement')
                    //this.engagementarr.push({ value: result.data[res], key: res });    
                    //this.engagementarr[res] = result.data[res];
                    this.engagementarr.push(result.data[res]);
            }
            //console.log('task');
            //console.log(JSON.stringify(this.taskarr));
            //console.log('suggestion');
            //console.log(JSON.stringify(this.suggestionarr));
            //console.log('engagement');
        }
    }


    updateRecommendationAccepted() {

        //console.log('entered updateRecommedationAccepted');

        const fields = {};
        fields[RISK_ID.fieldApiName] = this.RiskID;
        fields[REC_ACCEPTED.fieldApiName] = true;

        const inputRecord = { fields };

        //console.log('inputRecord', inputRecord);

        //console.log('bfore UpdateRecord call in updateRecommedationAccepted');

        updateRecord(inputRecord)
            // eslint-disable-next-line no-unused-vars
            .then(() => {
                //console.log('entered then after updaterecod in updateRecommedationAccepted');
                //console.log(' after reloadrecommendation in updateRecommedationAccepted');

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Recommendation Accepted ',
                        variant: 'sucess',
                    }),
                );
                //console.log(' after success event toast in updateRecommedationAccepted');
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error on data save',
                        message: error.message.body,
                        variant: 'error',
                    }),
                );
            });

    }

    updateRecommendationRejected() {
        let record = {
            fields: {
                Id: this.recordId,
                Recommendation_Rejected__c: true
            },
        };
        updateRecord(record)
            // eslint-disable-next-line no-unused-vars
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Recommendation Rejected',
                        variant: 'sucess',
                    }),
                );

                //   this.reloadRecommendations();

            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error on data save',
                        message: error.message.body,
                        variant: 'error',
                    }),
                );
            });
    }


    showRecommendation(){

        console.log('showRecommendation entered');
    this.show=true;
     console.log('show :'+this.show);
    }

    hideRecommendation(){
        console.log('hideRecommendation endtered');
    this.show=false;
    console.log('show:'+this.show);

    }

}