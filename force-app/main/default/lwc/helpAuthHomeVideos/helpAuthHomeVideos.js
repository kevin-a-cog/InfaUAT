/*
 * Name         :   HelpAuthHomeVideos
 * Author       :   Utkarsh Jain
 * Created Date :   17-FEB-2022
 * Description  :   Component used to retrive videos from coveo on Authenticated Home Page

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                                                Tag
 **************************************************************************************************************************
 Deeksha Shetty         17-FEB-2022     Utopia-ph-3         Initial version.                                                           NA
 Utkarsh Jain           25-FEB-2022     NA                  UI - Update                                                                NA
 Deeksha Shetty         July 1,2022     I2RT-6759           Users not able to see the components in the Product community             T1
 */

 import { LightningElement, api, wire, track } from 'lwc';
 import displayVideos from '@salesforce/apex/helpCoveoVideoDisplayController.displayVideos';
 import userId from "@salesforce/user/Id";
 const OUTER_MODAL_CLASS = 'outerModalContent';
 import informaticaNetwork2 from "@salesforce/resourceUrl/InformaticaNetwork2";
 import CommunityURL from '@salesforce/label/c.IN_CommunityName';
 import searchVideos from '@salesforce/label/c.help_searchVideos';
 import { loadStyle, loadScript } from "lightning/platformResourceLoader";
 import IN_StaticResource from '@salesforce/resourceUrl/informaticaNetwork';
 import {
     publish,subscribe,
     unsubscribe,
     MessageContext
 } from "lightning/messageService";
 import SESSIONID_CHANNEL from "@salesforce/messageChannel/sessionstorage__c";
 
 export default class HelpAuthHomeVideos extends LightningElement {
 
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
        //T1 starts
        this.handleSubscribe();
        const isChild = {
          AuthHomeVideosLoaded: true,
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
 
 
 
     setItemsForCarousel() {
         Promise.all([
             loadScript(this, "https://code.jquery.com/jquery-3.6.0.min.js"),
             loadStyle(this, IN_StaticResource + "/carousel/owl.carousel.min.css"),
             loadStyle(this, IN_StaticResource + "/carousel/owl.theme.default.min.css"),
             loadScript(this, IN_StaticResource + "/js/owl.carousel.min.js"),
         ])
             .then(() => {
                 const carousel = this.template.querySelector('div[class="owl-carousel owl-theme"]');
                 window.$(carousel).owlCarousel({
                     items: 1,
                     loop: true,
                     margin: 30,
                     nav: true,
                     dots: false,
                     responsiveClass: true,
                     navText: ['<div class="carousel-left-arrow"></div>', '<div class="carousel-right-arrow"></div>'],
                     responsive: {
                         0: {
                             items: 1,
                             nav: false,
                             dots: true
                         },
                         768: {
                             items: 2,
                             nav: true,
                             slideBy: 2
                         },
                         991: {
                             items: 3,
                             nav: true,
                             slideBy: 3
                         }
                     }
                 });
             })
             .catch((error) => {
                 console.log("Error Occured", error);
             });
     }
 
     displayVideo(event) {
         let rowId = event.currentTarget.dataset.id;
         if (rowId) {
             const itemarr = this.carouselSlide.filter(item => item.rowId == rowId);
             this.titleModal = itemarr[0].title;
              /** START-- adobe analytics */
             try {
                 util.trackButtonClick('Video - ' + this.titleModal);
             }
             catch (ex) {
                 console.error(ex.message);
             }
             /** END-- adobe analytics*/ 
             this.embeddedhtmlmodal = itemarr[0].embeddedHtml;
             if (this.embeddedhtmlmodal) this.displaymodal = true;
         }
 
     }
 
     closeModal() {
         this.displaymodal = false;
     }
 }