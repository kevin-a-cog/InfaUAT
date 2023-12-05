/*
* Name : HelpCoveoVideoDisplay
* Author : Deeksha Shetty
* Created Date :  January 3 2022
* Description : This Component displays Support Tv component in Product Detail Page
Change History
**********************************************************************************************************
Modified By              Date       Jira No.                 Description                                                              Tag
Deeksha Shetty         July 1,2022     I2RT-6759            Users not able to see the components in the Product community              T1
**********************************************************************************************************

*/

import { LightningElement, wire, api } from 'lwc';
import displayVideos from '@salesforce/apex/helpCoveoVideoDisplayController.displayVideos';
const OUTER_MODAL_CLASS = 'outerModalContent';
import informaticaNetwork2 from "@salesforce/resourceUrl/InformaticaNetwork2";
import userId from '@salesforce/user/Id';
import {
    publish,subscribe,
    unsubscribe,
    MessageContext
} from "lightning/messageService";
import SESSIONID_CHANNEL from "@salesforce/messageChannel/sessionstorage__c";




export default class HelpCoveoVideoDisplay extends LightningElement {
    @api recordId;
    urlarr;
    headerTitle;
    allVideosSource;
    displaymodal = false;
    titleModal;
    embeddedhtmlmodal;
    playrectangle = informaticaNetwork2 + "/playrectangle.png";
    playicon = informaticaNetwork2 + "/playwhite.png";
    viewmore;

    @wire(MessageContext)
    messageContext;

    receivedMessage;
    subscription = null;

    //For adding onclick event to close modal window on click
    constructor() {
        super();
        this.template.addEventListener("click", (event) => {
            if (event.target) {
                const classList = [...event.target.classList];
                if (classList.includes(OUTER_MODAL_CLASS)) {
                    this.closeModal();
                }
            }
        });
    }


    connectedCallback() {
        //T1 starts
        this.handleSubscribe();
        const isChild = {
            isVideoLoaded: true,
            sessiontoken: null

        };
        publish(this.messageContext, SESSIONID_CHANNEL, isChild);
        //T1 ends

    }

    disconnectedCallback() {
        this.handleUnsubscribe();
    }


    handleSubscribe() {
        if (this.subscription) {
            return;
        }

        //Subscribing to the message channel
        this.subscription = subscribe(
            this.messageContext,
            SESSIONID_CHANNEL,
            (message) => {
                this.handleMessage(message);
            }
        );
    }

    handleMessage(message) {
        this.receivedMessage = message ? message : "no message";
        if (this.receivedMessage.sessiontoken && this.recordId) this.handleVideosDisplay();
    }



    handleUnsubscribe() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }





    handleVideosDisplay() {
        displayVideos({ token: this.receivedMessage.sessiontoken, topicId: this.recordId })
            .then((result) => {
                if (result) {
                    let result1 = JSON.parse(JSON.stringify(result));
                    this.urlarr = result1.splice(0, 3);
                    this.headerTitle = 'Support TV';
                    this.viewmore = result[0].LearnMoreUrl;
                    console.log('url=' + JSON.stringify(this.urlarr));
                    console.log('record id=' + this.recordId);
                }

            })
            .catch((error) => {
                console.log(error.body);
            });
    }


    displayVideo(event) {
        console.log('Id captured=' + JSON.stringify(event.currentTarget.dataset.id));
        let rowId = event.currentTarget.dataset.id;
        if (rowId) {
            const itemarr = this.urlarr.filter(item => item.rowId == rowId);
            console.log('itemurl=' + JSON.stringify(itemarr));
            this.titleModal = itemarr[0].title;
            this.embeddedhtmlmodal = itemarr[0].embeddedHtml;
            if (this.embeddedhtmlmodal) this.displaymodal = true;

        }

    }

    closeModal() {
        this.displaymodal = false;
    }


}