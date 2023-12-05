/*
 * Name         :   HelpUserRelatedList
 * Author       :   Utkarsh Jain
 * Created Date :   15-JAN-2022
 * Description  :   This component can be used to display various list based on object selected from builder. 

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                                                 Tag
 **************************************************************************************************************************
 Utkarsh Jain           15-JAN-2021     UTOPIA              Initial version.                                                            NA
 Deeksha Shetty         July 1,2022     I2RT-6759            Users not able to see the components in the Product community              T1

 */
import { LightningElement, track, api, wire } from "lwc";

import USER_ID from "@salesforce/user/Id";
import { CurrentPageReference } from 'lightning/navigation';
import communityId from "@salesforce/community/Id";

import CommunityURL from "@salesforce/label/c.IN_CommunityName";
import getUserGroupList from "@salesforce/apex/helpUserRelatedList.getGroupList";
import getSubCommunityList from "@salesforce/apex/helpUserRelatedList.getSubCommunityList";
import getEventList from "@salesforce/apex/helpUserRelatedList.getEventList";
import displayBlogs from "@salesforce/apex/helpBlogPostsController.displayBlogs";
import getCommunityName from '@salesforce/apex/helpUserRelatedList.getCommunityName';
import getHighlights from '@salesforce/apex/helpUserRelatedList.getHighlights';
import {
    publish,subscribe,
    unsubscribe,
    MessageContext
} from "lightning/messageService";
import SESSIONID_CHANNEL from "@salesforce/messageChannel/sessionstorage__c";


export default class HelpUserRelatedList extends LightningElement {
    @api recordId;
    @api recordTypeId;
    @api title;
    @api headingClass;
    @api objectType;
    @track isHighlights = false;
    @track showComp = false;
    @track target = "_self";
    @track userResult = [];
    @track viewmore;

    @wire(MessageContext)
    messageContext;

    receivedMessage;
    subscription = null;

    connectedCallback() {
        if (this.objectType == "Groups") {
            getUserGroupList({ userId: USER_ID })
                .then((result) => {
                    result.forEach((res) => {
                        var item = {
                            title: "",
                            url: "",
                        };
                        item.title = res.CollaborationGroup.Name;
                        item.url = CommunityURL + "group/" + res.CollaborationGroup.Id;
                        this.userResult.push(item);
                    });
                    if (this.userResult.length > 0) {
                        this.showComp = true;
                    }
                })
                .catch((error) => {
                    console.error(JSON.stringify(error));
                });
        } else if (this.objectType == "Communities") {
            getCommunityName({ commId: this.recordId })
                .then((result) => {
                    let communityName = result;
                    getSubCommunityList({ ntwrkId: communityId, productName: communityName })
                        .then((result) => {
                            this.userResult = result;
                            if (this.userResult.length > 0) {
                                this.showComp = true;
                            }
                        })
                        .catch((error) => {
                            console.error(JSON.stringify(error));
                        });
                })
                .catch((error) => {
                    console.error(JSON.stringify(error));
                });

            this.viewmore = CommunityURL + 'topiccatalog';

        } else if (this.objectType == "Events") {
            getEventList({ userId: USER_ID })
                .then((result) => {
                    result.forEach((res) => {
                        var item = {
                            title: "",
                            url: "",
                        };
                        item.title = res.Subject;
                        item.url = CommunityURL + "event/" + res.Id;
                        this.userResult.push(item);
                        if (this.userResult.length > 0) {
                            this.showComp = true;
                        }
                    });
                })
                .catch((error) => {
                    console.error(JSON.stringify(error));
                });
        } else if (this.objectType == "Highlights") {
            this.target = "_blank";
            this.isHighlights = true;
            this.target = "_blank";
            getHighlights({ recordId: this.recordId })
                .then((result) => {
                    this.userResult = result;
                    if (this.userResult.length > 0) {
                        this.showComp = true;
                    }
                })
                .catch((error) => {
                    console.error(JSON.stringify(error));
                });
        }

        //T1 starts

        this.handleSubscribe();
        const isChild = {
            isBlogLoaded: true,
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
        if (this.receivedMessage.sessiontoken && this.recordId) this.BlogsDisplay();
    }



    handleUnsubscribe() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    BlogsDisplay() {
        if (this.objectType == "Blogs") {
            this.target = "_blank";
            displayBlogs({ topicId: this.recordId, token: this.receivedMessage.sessiontoken })
                .then((result) => {
                    this.userResult = result;
                    if (this.userResult.length > 0) {
                        this.showComp = true;
                        this.viewmore = result[0].LearnMoreUrl;
                    }
                })
                .catch((error) => {
                    console.error(JSON.stringify(error));
                });
        }

    }


}