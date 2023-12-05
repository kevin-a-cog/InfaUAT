import { api,LightningElement,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import EST_SUMMARY_FIELD from '@salesforce/schema/Estimation_Output__c.Estimation_Summary__c';
import Id from '@salesforce/user/Id';
import USERTYPE from '@salesforce/schema/User.UserType';
const FIELDS = [EST_SUMMARY_FIELD];
const USERFIELDS = [USERTYPE];
export default class IpueRedirectToParent extends NavigationMixin(LightningElement) {
    @api recordId;
    userId = Id;
    estOutput;
    estSummary;
    user;
    usertype;
    userLoaded = false;
    estOutputLoaded = false;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            console.log('Error occured : '+message);
        } else if (data) {
            this.estOutput = data;
            this.estSummary = this.estOutput.fields.Estimation_Summary__c.value;
            this.estOutputLoaded = true;
            this.redirectToEstimationSummary();
        }
    }

    @wire(getRecord, { recordId: '$userId', fields: USERFIELDS })
    wiredUserRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            console.log('Error occured : '+message);
        } else if (data) {
            this.user = data;
            this.usertype = this.user.fields.UserType.value;
            this.userLoaded = this.usertype != 'Standard' ? true: false;
            this.redirectToEstimationSummary();
        }
    }

    redirectToEstimationSummary(){
        if(this.userLoaded && this.estOutputLoaded){
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.estSummary,
                    objectApiName: 'Estimation_Summary__c',
                    actionName: 'view'
                }
            });
        }
    }
}