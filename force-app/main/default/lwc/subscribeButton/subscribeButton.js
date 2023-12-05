/*
 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 NA                     NA              UTOPIA              Initial version.                                          NA
 Vignesh Divakaran      09-May-2022     I2RT-6196           Comment CDC channel subscription                          T01            
 */
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getSubscriptionStatus from '@salesforce/apex/SubscriptionController.getSubscriptionStatus';
import toggleSubscription from '@salesforce/apex/SubscriptionController.toggleSubscription';
//Deva I2RT-2390 - Importing emp Api
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled }  from 'lightning/empApi';
//Deva Generic Utilities.
import { objUtilities } from 'c/informaticaUtilities';
import UserId from '@salesforce/user/Id'

export default class SubscribeButton extends LightningElement {

    @api objectname;
    @api recordid;

    userId = UserId;
    isSelected = false;
    @track showInProgress=false;
    //Deva I2RT-2390
    caseSub;
    connectedCallback(){
        console.log('record id >>', this.recordid);
        console.log('objectname >>', this.objectname);
        //I2RT-2390 - Commented the code and moved to method to call the logic on platform event of case record change
        // this.subscribeToCaseDataChange(); Commented as part of <T01>
        this.handleSubscriptionStatus();
    /*Deva Commented the below code and moved to method to call it multiple times in the same componennt
        getSubscriptionStatus({
            recordId : this.recordid,
            userId : this.userId
        })
        .then(result => {
            console.log('result >>', result);
            if(result){
                this.isSelected = result;
            }
            console.log('isSelected >>', this.isSelected);
        })
        .catch(error => {
            console.log('error >>', JSON.stringify(error));
        })*/
    }
    //Deva Start- I2RT-2390 - Commented the code and moved to method to call the logic on platform event of case record change
    handleSubscriptionStatus(){
        let objParent = this;
        getSubscriptionStatus({
            recordId : this.recordid,
            userId : this.userId
        })
        .then(result => {
            console.log('result >>', result);
            if(result){
                this.isSelected = result;
            }
            console.log('isSelected >>', this.isSelected);
        })
        .catch(error => {
            objUtilities.processException(error, objParent);
        })
    }
    /* Commented as part of <T01>
    subscribeToCaseDataChange() {
        if (this.caseSub) {
            return;
        }
        // Callback invoked whenever a new event message is received
        var thisReference = this;
        const messageCallback = function(response) {
            console.log('Case record  created/updated: ', JSON.stringify(response));
            thisReference.handleSubscriptionStatus();
        };
        // Invoke subscribe method of empApi. Pass reference to messageCallback
        var channelName = '/data/CaseChangeEvent';
        this.caseSub = subscribe(channelName, -1, messageCallback);
    }*/
    //Deva End- I2RT-2390
    get buttonVariant() {
        var buttonVariant;
        if(this.isSelected){
            buttonVariant='success';
        }else{
            buttonVariant='neutral';
        }
        return buttonVariant;
    }

    handleClick() {
        console.log('record id >>', this.recordid);
        console.log('objectname >>', this.objectname);

        this.showInProgress=true;
        toggleSubscription({
            recordId : this.recordid,
            userId : this.userId,
            subscribe : !this.isSelected
        })
        .then(result => {
            console.log('result >>', result);
            this.isSelected = !this.isSelected;
            console.log('isSelected >>', this.isSelected);
            this.showInProgress=false;
        })
        .catch(error => {
            console.log('error >>', JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error occurred!',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
            this.showInProgress=false;
        })
        
        console.log('isSelected >>', this.isSelected);
    }
}