/*
 * Name         :   InAnnouncementTile
 * Author       :   Utkarsh Jain
 * Created Date :   17-FEB-2022
 * Description  :   Component used to show Announcements.

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Utkarsh Jain          16-FEB-2022      I2RT-5421           Initial version.                                          NA
 Utkarsh Jain          16-JUN-2022      I2RT-6422           Bringing Announcements on Community Page                  NA
 Utkarsh Jain          01-DEC-2022      I2RT-7549           Private User group - announcements should not be
                                                            visible to public users.                                  1
 */

import { LightningElement, wire, track, api } from "lwc";
import getAnnouncementTileList from "@salesforce/apex/InAnnouncementBanner.getAnnouncementTileList";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import userId from '@salesforce/user/Id';
import getgroupType from "@salesforce/apex/helpGroupsController.getgroupType";
import getgroupmember from '@salesforce/apex/helpGroupsController.getgroupmember';
import IN_StaticResource from '@salesforce/resourceUrl/informaticaNetwork';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
  } from "lightning/messageService";
import ANNOUNCMENTS_MC from "@salesforce/messageChannel/AnnouncementsMessageChannel__c";
  

export default class InAnnouncementTile extends LightningElement {

    @api recordId;
    @api pagename;
    @track announcementTiles = [];
    @track isAnnouncementTile = false;
    @track groupId;
    @track wiredAnnouncementsResult;
    @track heading = 'Announcements';

    // < Tag 1 Start>
    @track isGroups = false;
    @track ispublicGroup = true;

    @wire(getgroupType, { grpId: '$recordId' })
    wiredGroupType({ data, error }) {
        if (data) {
            this.getgroupmember();
            if (data == 'Public') {
                this.ispublicGroup = true;
            }
            if (data == 'Private') {
                this.ispublicGroup = false;
            }
        } else if (error) {
            console.error("error", error);
        }
    }

    getgroupmember() {
        getgroupmember({ userId: userId, grpId: this.recordId })
            .then((result) => {
                if (result) {
                    this.isFollowing = true;
                }
            })
            .catch((error) => {
                console.log(error.body);
            });
    }

    // < Tag 1 End>

    @wire(getAnnouncementTileList, { type: '$pagename', id: '$recordId' })
    AnnouncementList({ error, data }) {
        if (data) {
            this.groupId = this.recordId;
            if(this.pagename == 'Home'){
                this.heading = 'Start Exploring';
            }
            // < Tag 1 Start>
            if(this.pagename == 'Groups'){
                this.isGroups = true;
            }
            // < Tag 1 End>
            this.announcementTiles = data;
            setTimeout(() => {
                this.isAnnouncementTile = this.announcementTiles.length > 0 ? true : false;
                this.setItemsForCarousel();
            }, 3000);
        } else if (error) {
            console.log("getAnnouncementTileList Error => " + JSON.stringify(error));
        } else if( this.pagename == undefined){

        }
    }

    @wire(MessageContext)
    messageContext;
    subscription = null;

    // Encapsulate logic for Lightning message service subscribe and unsubsubscribe
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                ANNOUNCMENTS_MC,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    // Handler for message received by component
    handleMessage(message) {
        this.groupId = message.recordId;
        location.reload();
        return;
    }

    // Standard lifecycle hooks used to subscribe and unsubsubscribe to the message channel
    connectedCallback() {
        this.subscribeToMessageChannel();
        if(this.pagename == 'Home'){
            getAnnouncementTileList({type: this.pagename, id: this.recordId })
            .then((data) => {
                this.heading = 'Start Exploring';
                this.announcementTiles = data;
                setTimeout(() => {
                    this.isAnnouncementTile = this.announcementTiles.length > 0 ? true : false;
                    this.setItemsForCarousel();
                }, 3000);
            }).catch((error) => {
                console.log("Error Occured", error);
            })
        }
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    setItemsForCarousel() {
        Promise.all([
            loadScript(this, "https://code.jquery.com/jquery-3.6.0.min.js"),
            loadStyle(this, IN_StaticResource + "/carousel/owl.carousel.min.css"),
            loadStyle(this, IN_StaticResource + "/carousel/owl.theme.default.min.css"),
            loadScript(this, IN_StaticResource + "/js/owl.carousel.min.js"),
            ])
            .then(() => {
                this.loadCarousel();
            })
            .catch((error) => {
                console.log("Error Occured", error);
            });
    }

    loadCarousel(){
        const carousel = this.template.querySelector('div[class="owl-carousel owl-theme"]');
        window.$(carousel).owlCarousel({
            items: 3,
            loop: false,
            margin: 30,
            dots: false,
            autoplayHoverPause: true,
            responsiveClass: true,
            navText: ['<div class="carousel-left-arrow"></div>', '<div class="carousel-right-arrow"></div>'],
            responsive: {
                0: {
                    items: 1,
                    nav: false,
                    dots: true
                },
                600: {
                    items: 3,
                    nav: true,
                    slideBy: 3
                },
                1000: {
                    items: 3,
                    nav: true,
                    slideBy: 3
                }
            }
        });
    }

    handleOnClick(event){
        let name = event.currentTarget.dataset.value;
         /** START-- adobe analytics */
         try {
            util.trackButtonClick('announcement - ' + name);
        }
        catch (ex) {
            console.log(ex.message);
        }
        /** END-- adobe analytics*/
    }
}