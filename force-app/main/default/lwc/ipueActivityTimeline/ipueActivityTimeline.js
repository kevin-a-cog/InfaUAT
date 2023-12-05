import { LightningElement,api,wire } from 'lwc';
import getActivities from '@salesforce/apex/IPUE_ActivityTimelineCntlr.getActivities';
import {subscribe,MessageContext,APPLICATION_SCOPE} from 'lightning/messageService';
import { refreshApex } from '@salesforce/apex';
import openChatter from '@salesforce/messageChannel/openChatter__c';
export default class IpueActivityTimeline extends LightningElement {

    @api recordId;
    activityIteration=[];
    loadData=false;
    // non-reactive variables
    refreshFeeds;

    //handle message content for the lms
    @wire(MessageContext)
    messageContext;
  
    
    // retrieving the data using wire service
    @wire(getActivities, { recordId: '$recordId' })
    relations(result) {
        this.refreshFeeds= result;
        if (result.data) {
            var res=JSON.parse(result.data);
            this.activityIteration=res;
            this.loadData=true;
        }
    }
    
    connectedCallback(){
        this.subsToMessageChannel();
    }
    
    //Encapsulate logic for LMS subscribe
    subsToMessageChannel(){
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                openChatter,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    // Handler for message received by component
    handleMessage(message) {
        if(message.description=='refreshActivity'){
            //refreshing activity list
            refreshApex(this.refreshFeeds);
        }
    }

}