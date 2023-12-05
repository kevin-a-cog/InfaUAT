/*
 * Name         :   HelpAnonymousVideos
 * Author       :   Utkarsh Jain
 * Created Date :   08-March-2022
 * Description  :   Component used to retrive videos from coveo on Anonymous Home Page

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                                               Tag
 **************************************************************************************************************************
 Utkarsh Jain           08-March-2022   NA                  UI - Update                                                                NA
 Deeksha Shetty         July 1,2022     I2RT-6759            Users not able to see the components in the Product community              T1
 */

import { LightningElement, api, wire, track } from 'lwc';
import displayVideos from '@salesforce/apex/helpCoveoVideoDisplayController.displayVideos';
const OUTER_MODAL_CLASS = 'outerModalContent';
import userId from "@salesforce/user/Id";
import informaticaNetwork2 from "@salesforce/resourceUrl/InformaticaNetwork2";
import CommunityURL from '@salesforce/label/c.IN_CommunityName';
import searchVideos from '@salesforce/label/c.help_searchVideos';
import {
    publish,subscribe,
    unsubscribe,
    MessageContext
} from "lightning/messageService";
import SESSIONID_CHANNEL from "@salesforce/messageChannel/sessionstorage__c";

export default class HelpAnonymousVideos extends LightningElement {
    urlarr;
    allVideosSource;
    displaymodal = false;
    titleModal;
    embeddedhtmlmodal;
    playrectangle = informaticaNetwork2 + "/authhomevideo.png";
    playicon = informaticaNetwork2 + "/playwhite.png";
    viewmore;
    @track carouselSlide = [];
    @track searchPage = CommunityURL + searchVideos;
    sessionStorageOptionToken;
    receivedMessage;
    subscription = null;


    @wire(MessageContext)
    messageContext;


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
        this.handleSubscribe();
        //T1 starts
        const isChild = {
          AnonyVideosLoaded: true,
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
        if (this.receivedMessage.sessiontoken) {
            displayVideos({ token: this.receivedMessage.sessiontoken, topicId: 'home' })
                .then((result) => {
                    this.carouselSlide = result;
                    setTimeout(() => {
                        this.setItemsForCarousel();
                    }, 3000);
                })
                .catch((error) => {
                    console.log(JSON.stringify(error));
                });
        }
    }



    handleUnsubscribe() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleOnClick(event) {
        let name = event.currentTarget.dataset.value;
        /** START-- adobe analytics */
        try {
            util.trackButtonClick('anonymous video - ' + name);
        }
        catch (ex) {
            console.log(ex.message);
        }
        /** END-- adobe analytics*/
    }




    displayVideo(event) {	
        let rowId = event.currentTarget.dataset.id;	
        if (rowId) {	
            const itemarr = this.carouselSlide.filter(item => item.rowId == rowId);	
            this.titleModal = itemarr[0].title;	
            this.embeddedhtmlmodal = itemarr[0].embeddedHtml;	
              /** START-- adobe analytics */	
              try {	
                util.trackButtonClick('Video - ' + this.titleModal);	
            }	
            catch (ex) {	
                console.error(ex.message);	
            }	
            /** END-- adobe analytics*/ 	
            if (this.embeddedhtmlmodal) this.displaymodal = true;	
        }	
    }

    closeModal() {
        this.displaymodal = false;
    }
}