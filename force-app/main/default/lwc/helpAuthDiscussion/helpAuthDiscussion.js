/*
 * Name         :   HelpAuthDiscussion
 * Author       :   Utkarsh Jain
 * Created Date :   15-JAN-2022
 * Description  :   This component is used for fetching discussions from coveo and ask a question.

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Deeksha Shetty          02 Dec,2022     I2RT-7545			 Spammed words are getting posted in product community	    1
 Deeksha Shetty        08 May 2023     I2RT-8345             Ask a Question - Email Notification - Issue observed       2
                                                            in New and Update Notification email template                                                          
 */

import { api, LightningElement, track, wire } from 'lwc';

import userId from "@salesforce/user/Id";
import communityId from "@salesforce/community/Id";
import CommunityURL from '@salesforce/label/c.IN_CommunityName';
import Accounts_Saml_Url from '@salesforce/label/c.Accounts_Saml_Url';
import helpDiscussionLanding from '@salesforce/label/c.helpDiscussionLanding';

import IN_StaticResource from "@salesforce/resourceUrl/informaticaNetwork";
import getDiscussion from "@salesforce/apex/helpQuestions.getDiscussion";
import IN_account_login from '@salesforce/label/c.IN_account_login';

import saveQuestionPost from "@salesforce/apex/helpQuestions.saveQuestionPost";


import {
    publish, subscribe,
    unsubscribe,
    MessageContext
} from "lightning/messageService";
import SESSIONID_CHANNEL from "@salesforce/messageChannel/sessionstorage__c";

export default class HelpAuthDiscussion extends LightningElement {
    questionLogo = IN_StaticResource + "/question.png";
    discussionLogo = IN_StaticResource + "/Icon_Social.png";
    @track discussions = [];
    @track isAskQuestionModal = false;
    @track heading = 'Ask A Question';
    @api recordId;
    @track searchPage = CommunityURL + helpDiscussionLanding;
    sessionStorageOptionToken;

    @wire(MessageContext)
    messageContext;

    receivedMessage;
    subscription = null;
    isSpinnerLoading = false; //Tag 1


    connectedCallback() {
        this.handleSubscribe();
        const isChild = {
            AuthDiscussionLoaded: true,
            sessiontoken: null
        };
        publish(this.messageContext, SESSIONID_CHANNEL, isChild);
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
            getDiscussion({ networkId: communityId, token: this.receivedMessage.sessiontoken })
                .then((result) => {
                    this.discussions = result;
                })
                .catch((error) => {
                    console.error("getDiscussion error => " + JSON.stringify(error));
                });
        }
    }



    handleUnsubscribe() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }


    handleAskQuestion() {
        /** START-- adobe analytics */
        try {
            util.trackButtonClick('ask - new discussion - home page - Form started');
        }
        catch (ex) {
            console.log(ex.message);
        }
        /** END-- adobe analytics*/
        if (userId == undefined) {
            window.location.assign(IN_account_login + "/login.html?fromURI=" + Accounts_Saml_Url + "?RelayState=" + encodeURIComponent(window.location.href));
        } else if (userId != undefined) {
            this.isAskQuestionModal = true;
            document.body.classList += ' modal-open';
        }
    }
    closeAskQuestionModal() {
        this.isAskQuestionModal = false;
        document.body.classList -= ' modal-open';
    }

    saveData(event) {
        this.isSpinnerLoading = true; //Tag 1
        /** START-- adobe analytics */
        let fileData = event.detail.file;
        try {
            util.trackButtonClick('ask - new discussion - home page - Form completed - ' + event.detail.label);
        }
        catch (ex) {
            console.log(ex.message);
        }
        /** END-- adobe analytics*/
        //let imageUrlList = this.handleRichTextImages(event.detail.desc);
        saveQuestionPost({ userId: userId, networkId: communityId, parentId: event.detail.comm, title: event.detail.title, body: event.detail.desc,fileList: JSON.stringify(fileData) })
            .then((data) => {
                let questionId = data;
                if (questionId != '') {
                    /** Tag 2 starts */
                    console.log('questionId>>>>>>', questionId);
                    this.closeAskQuestionModal();
                    window.location.assign(CommunityURL + 'question/' + questionId);
                    //                 window.location.assign(CommunityURL + 'question/' + questionId);
                    //creating attachment for post
                    // uploadFile({ fileList: JSON.stringify(fileData), recordId: questionId })
                    //     .then((data) => {
                    //         saveQuestionPostToTopic({ entityId: questionId, networkId: communityId, topicId: event.detail.comm })
                    //             .then((data) => {
                    //                 this.closeAskQuestionModal();
                    //                 window.location.assign(CommunityURL + 'question/' + questionId);
                    //             })
                    //             .catch((error) => {
                    //                 this.isSpinnerLoading = false; //Tag 4
                    //             })
                    //     })
                    //     .catch((error) => {
                    //         console.log('file attachment error > ', error);
                    //         this.isSpinnerLoading = false; //Tag 4
                    //     })
                }
                /** Tag 2 ends */
            })
            .catch((error) => {
                this.isSpinnerLoading = false;//Tag 1
                console.error("error", error);
                if (error.body.message.includes('INVALID_MARKUP')) {
                    this.template.querySelector('c-help-ask-a-question-modal').showErrorMessage('Please copy and paste plain text.');
                } else if (error.body.message.includes('STRING_TOO_LONG')) {
                    this.template.querySelector('c-help-ask-a-question-modal').showErrorMessage('Character limit is exceeded');
                }
                else if (error.body.message.includes('FIELD_MODERATION_RULE_BLOCK')) {
                    //Tag 1 starts
                    let bmOne = error.body.message.split('FIELD_MODERATION_RULE_BLOCK,')[1];
                    bmOne = bmOne.split('[RawBody]')[0];
                    bmOne = bmOne.split('[Title, RawBody]')[0];
                    bmOne = bmOne.split(':')[0];
                    this.template.querySelector('c-help-ask-a-question-modal').showErrorMessage(bmOne);
                } else {
                    this.template.querySelector('c-help-ask-a-question-modal').showErrorMessage('Error in Saving this Discussion.');
                } //Tag 1 ends
            })
    }

    handleRichTextImages(description) {
        let imageUrlList = [];
        if (description.includes("img")) {
            var parser = new DOMParser();
            var doc = parser.parseFromString(description, 'text/html');

            let allImages = doc.querySelectorAll("img");
            let imageURL;
            for (let i = 0; i < allImages.length; i++) {
                imageURL = allImages[i].getAttribute("src");
                if (imageURL.includes("refid")) {
                    imageUrlList.push(imageURL);
                }
            }
            //his.saveImages(imageUrlList);
            //this.saveRichText(imageUrlList, this.recordId, 'test-file-name.png');
        }
    }

    handleOnClick(event) {
        let name = event.currentTarget.dataset.value;
        let community = event.currentTarget.dataset.community;
        /** START-- adobe analytics */
        try {
            util.trackLinkClick('Discussion - ' + name + ' - ' + community);
        }
        catch (ex) {
            console.log(ex.message);
        }
        /** END-- adobe analytics*/
    }
}