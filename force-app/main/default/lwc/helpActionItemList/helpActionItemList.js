/*
 * Name         :   HelpActionItemList
 * Author       :   Utkarsh Jain
 * Created Date :   15-JAN-2022
 * Description  :   This component is used for providing multiple actions for user to perform.

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Utkarsh Jain           15-JAN-2021     I2RT-5249            Initial version.                                          NA
 Utkarsh Jain           16-JUN-2022     I2RT-6422            Bringing Announcements on Community Page                  NA
 Deeksha Shetty         25-AUG-2022     I2RT-6885            PayGo-Ability of the users who has subscribed/ on trial   3
                                                             period of Data Loader product.
Deeksha Shetty          02 Dec,2022     I2RT-7545            Spammed words are getting posted in product community     4
Deeksha Shetty          08 May 2023     I2RT-8345            Ask a Question - Email Notification - Issue observed      5
                                                             in New and Update Notification email template
Deeksha Shetty          13/06/2023      I2RT-8423            Provision to create poll in product community             6                                                                                                                        
 */

import { api, LightningElement, track, wire } from 'lwc';
import userId from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import communityId from '@salesforce/community/Id';
import CommunityURL from '@salesforce/label/c.IN_CommunityName';
import IN_account_login from '@salesforce/label/c.IN_account_login';
import Accounts_Saml_Url from '@salesforce/label/c.Accounts_Saml_Url';
import followCommunity from "@salesforce/apex/helpCommunityController.followCommunity";
import unfollowCommunity from "@salesforce/apex/helpCommunityController.unfollowCommunity";
import getFollowingCommunity from "@salesforce/apex/helpCommunityController.getFollowingCommunity";
import saveQuestionPost from "@salesforce/apex/helpQuestions.saveQuestionPost";
import IN_StaticResource from "@salesforce/resourceUrl/informaticaNetwork";
import IN_StaticResource2 from "@salesforce/resourceUrl/InformaticaNetwork2";
import IN_StaticResource3 from "@salesforce/resourceUrl/InformaticaNetwork3";
import getCommunityName from '@salesforce/apex/helpUserRelatedList.getCommunityName';
import getAnnouncementTileList from "@salesforce/apex/InAnnouncementBanner.getAnnouncementTileList";
import createAnnouncementFromCommunity from "@salesforce/apex/InAnnouncementBanner.createAnnouncementFromCommunity";
import updateAnnouncementFromCommunity from "@salesforce/apex/InAnnouncementBanner.updateAnnouncementFromCommunity";
import isinternaluser from "@salesforce/customPermission/User_Group_Admin";
import CheckPaygoSubscribedUser from '@salesforce/apex/helpPaygoCaseController.CheckPaygoSubscribedUser';
import getmetadatarecords from '@salesforce/apex/helpPaygoCaseController.getmetadatarecords';
import handleCaseAction from '@salesforce/apex/helpPaygoCaseController.handleCaseAction';
import hasAdminAccess from '@salesforce/customPermission/User_Group_Admin';


export default class HelpActionItemList extends LightningElement {

    @api recordId;
    @api objectApiName;
    @api showAskAQuestion;
    @api showCreateAnIdea;
    @api showFollow;
    @track heading = 'Ask A Question';
    @track communityName;
    @track showAnnouncementModal = false;
    @track showEditAnnouncementModal = false;
    @track groupId = false;
    @track isFollowing = false;
    @track isAskQuestionModal = false;
    followCommunityLogo = IN_StaticResource + "/follow.png";
    questionLogo = IN_StaticResource + "/question.png";
    ideaLogo = IN_StaticResource + "/idea.png";
    announcementLogo = IN_StaticResource2 + "/announcementicon.png";
    createCaseLogo = IN_StaticResource3 + "/createCase.png";
    manageCaseLogo = IN_StaticResource3 + "/manageCase.png";
    createpolllogo = IN_StaticResource2 + "/pollicon.svg"; //Tag 6
    showCreateCaseButton = false;
    showManageCaseButton = false;
    showIdeaModal;
    email;
    payGoProducts;
    showSpinner = false;
    createCaseURL;
    manageCaseURL;
    isSpinnerLoading = false; //Tag 4
    showpollModal; //Tag 6
    topicId; //Tag 6
    showPollActionItem = false; //Tag 6

    /* Tag 6 starts */
    connectedCallback() {
        if (window.location.pathname.includes('/s/topic/') && hasAdminAccess) {
            this.showPollActionItem = true;
        }
    }

    /* Tag 6 ends */


    @wire(getFollowingCommunity, { commId: '$recordId', user: userId, networId: communityId })
    wiredFollowingCommunity({ data, error }) {
        if (data) {
            if (data == 0) {
                this.isFollowing = false;
            }
            else {
                this.isFollowing = true;
            }
        } else if (error) {
            console.error(error);
        }
    }


    get isInternaluser() {
        return isinternaluser;
    }

    // //Tag 6 starts

    // get hasAdminAccess() {
    //     return hasAdminAccess;
    // }
    // //Tag 6 ends

    @wire(getCommunityName, { commId: '$recordId' })
    GetCommunity(result) {
        if (result.data) {
            this.communityName = result.data;
            if (this.communityName) this.getMetadataForPayGo();
            if (this.recordId) this.topicId = this.recordId;
        }
    }



    saveData(event) {
        this.isSpinnerLoading = true; //Tag 4
        let fileData = event.detail.file;
        getCommunityName({ commId: event.detail.comm })
            .then((res) => {
                this.communityName = res.data;

                /** START-- adobe analytics */
                try {
                    util.trackButtonClick('Ask - New discussion - Form Completed - ' + res);
                }
                catch (ex) {
                    console.error(ex.message);
                }
                /** END-- adobe analytics*/
            })
            .catch((error) => {
                console.error(error);
            })

        saveQuestionPost({ userId: userId, networId: communityId, parentId: event.detail.comm, title: event.detail.title, body: event.detail.desc, fileList: JSON.stringify(fileData) })
            .then((data) => {
                let questionId = data;
                if (questionId != '') {
                    /** Tag 5 starts */
                    console.log('questionId>>>>>>', questionId);
                    this.closeAskQuestionModal();
                    window.location.assign(CommunityURL + 'question/' + questionId);

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
                /** Tag 5 ends */
            })

            .catch((error) => {
                this.isSpinnerLoading = false;//Tag 4
                console.error('error>>>>>>', error)
                if (error.body.message.includes('INVALID_MARKUP')) {
                    this.template.querySelector('c-help-ask-a-question-modal').showErrorMessage('Please copy and paste plain text.');
                } else if (error.body.message.includes('STRING_TOO_LONG')) {
                    this.template.querySelector('c-help-ask-a-question-modal').showErrorMessage('Character limit is exceeded');
                }
                else if (error.body.message.includes('FIELD_MODERATION_RULE_BLOCK')) {
                    //Tag 4 starts
                    let bmOne = error.body.message.split('FIELD_MODERATION_RULE_BLOCK,')[1];
                    bmOne = bmOne.split('[RawBody]')[0];
                    bmOne = bmOne.split('[Title, RawBody]')[0];
                    bmOne = bmOne.split(':')[0];
                    this.template.querySelector('c-help-ask-a-question-modal').showErrorMessage(bmOne);
                } else {
                    this.template.querySelector('c-help-ask-a-question-modal').showErrorMessage('Error in Saving this Discussion.');
                } //Tag 4 ends
            })
    }

    handleCreateAnnouncement() {
        /** START-- adobe analytics */
        try {
            util.trackButtonClick('Community - Create a Announcement - ' + document.title);
        }
        catch (ex) {
            console.error(ex.message);
        }
        /** END-- adobe analytics*/
        this.showAnnouncementModal = true;
    }

    handleEditAnnouncements() {
        /** START-- adobe analytics */
        try {
            util.trackButtonClick('Community - Edit a Announcement - ' + document.title);
        }
        catch (ex) {
            console.error(ex.message);
        }
        /** END-- adobe analytics*/
        getAnnouncementTileList({ type: 'Communities', id: this.recordId }).then(result => {
            this.announcements = JSON.parse(JSON.stringify(result));
            this.showEditAnnouncementModal = true;
        }).catch(error => {
            console.error(JSON.stringify(error));
        });
    }

    closeEditAnnouncementModal() {
        this.showEditAnnouncementModal = false;
        document.body.classList -= ' modal-open';
    }

    closeAnnouncementModal() {
        this.showAnnouncementModal = false;
        document.body.classList -= ' modal-open';
    }

    createAnnouncement(event) {
        let title = event.detail.title;
        let desc = event.detail.desc;
        let startDate = event.detail.startDate;
        let endDate = event.detail.endDate;
        let commuities = event.detail.commuities;
        createAnnouncementFromCommunity({ title: title, description: desc, startDate: startDate, endDate: endDate, communitites: commuities }).then((result) => {
            this.showAnnouncementModal = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success ',
                    message: 'Announcement created Successfully!!',
                    variant: 'success'
                }),
            );
            location.reload();
        }).catch((error) => {
            console.log(JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Failed ',
                    message: 'Error while Creating Announcemnet',
                    variant: 'error',
                    mode: 'dismissable',
                }),
            );
            this.showAnnouncementModal = false;
        })
    }

    saveAnnouncement(event) {
        let Id = event.detail.Id;
        let title = event.detail.title;
        let desc = event.detail.desc;
        let startDate = event.detail.startDate;
        let endDate = event.detail.endDate;
        let communities = event.detail.communities;
        updateAnnouncementFromCommunity({ Id: Id, title: title, description: desc, startDate: startDate, endDate: endDate, communitites: communities }).then((result) => {
            this.showEditAnnouncementModal = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success ',
                    message: 'Announcement Updated Successfully!!',
                    variant: 'success'
                }),
            );
            location.reload();
        }).catch((error) => {
            console.log(JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Failed ',
                    message: 'Error while saving Announcemnet',
                    variant: 'error',
                    mode: 'dismissable',
                }),
            );
            this.showEditAnnouncementModal = false;
        })
    }

    handleAskQuestion() {
        /** START-- adobe analytics */
        try {
            util.trackButtonClick('Ask A Question - Product Details Page - From Started - ' + this.communityName);
        }
        catch (ex) {
            console.error(ex.message);
        }
        /** END-- adobe analytics*/
        if (userId == undefined) {
            window.location.assign(IN_account_login + "/login.html?fromURI=" + Accounts_Saml_Url + "?RelayState=" + encodeURIComponent(window.location.href));
        } else {
            this.isAskQuestionModal = true;
            document.body.classList += ' modal-open';
        }
    }

    closeAskQuestionModal() {
        this.isAskQuestionModal = false;
        document.body.classList -= ' modal-open';
    }

    handlefollowCommunity() {
        if (userId == undefined) {
            window.location.assign(IN_account_login + "/login.html?fromURI=" + Accounts_Saml_Url + "?RelayState=" + encodeURIComponent(window.location.href));
        } else {
            /** START-- adobe analytics */
            try {
                util.trackButtonClick('Follow this community - Product Details Page - ' + this.communityName);
            }
            catch (ex) {
                console.error(ex.message);
            }
            /** END-- adobe analytics*/
            followCommunity({ commId: this.recordId, user: userId, networId: communityId })
                .then((data) => {
                    this.isFollowing = true;
                })
                .catch((error) => {
                    console.error(error);
                })
        }
    }

    handleunfollowCommunity() {
        /** START-- adobe analytics */
        try {
            util.trackButtonClick('Unfollow this community - Product Details Page - ' + this.communityName);
        }
        catch (ex) {
            console.error(ex.message);
        }
        /** END-- adobe analytics*/
        unfollowCommunity({ commId: this.recordId, user: userId, networId: communityId })
            .then((data) => {
                this.isFollowing = false;
            })
            .catch((error) => {
                console.error(error);
            })
    }


    handleCreateIdea() {
        /** START-- adobe analytics */
        try {
            util.trackButtonClick('Create an Idea - Product Details Page - Form Started - ' + this.communityName);
        }
        catch (ex) {
            console.error(ex.message);
        }
        /** END-- adobe analytics*/
        if (userId == undefined) {
            window.location.assign(IN_account_login + "/login.html?fromURI=" + Accounts_Saml_Url + "?RelayState=" + encodeURIComponent(window.location.href));
        } else {
            this.showIdeaModal = true;
        }
    }
    closeIdeaModal(event) {
        if (event.detail) this.showIdeaModal = false;

    }

    //Tag 3 starts

    getMetadataForPayGo() {
        getmetadatarecords()
            .then((data) => {
                console.log('Metadata=' + data);
                this.email = data.CurrentUserEmail;
                this.payGoProducts = data.Metadata.PayGo_Subscription_Products__c;
                this.createCaseURL = data.Metadata.EsupportCreateCaseURL__c;
                this.manageCaseURL = data.Metadata.EsupportManageCaseURL__c;

                if (userId != undefined && this.payGoProducts && this.email) {
                    if (this.payGoProducts.toLowerCase() == this.communityName.toLowerCase()) {
                        this.checkCurrentUserIsPaygoUser();
                    }
                    else if (this.payGoProducts.includes(',') && this.payGoProducts.toLowerCase().split(',').includes(this.communityName.toLowerCase())) {
                        this.checkCurrentUserIsPaygoUser();
                    }
                    else this.showCaseButton = false;
                }

            })
            .catch((error) => {
                console.log("User Error => " + JSON.stringify(error));
            });

    }


    checkCurrentUserIsPaygoUser() {
        CheckPaygoSubscribedUser({ communityName: this.communityName, userMail: this.email })
            .then((result) => {
                this.showCreateCaseButton = (result.CreateCaseDisplay == 'showCreateCase') ? true : false;
                this.showManageCaseButton = (result.ManageCaseDisplay == 'showManageCase') ? true : false;
            })
            .catch((error) => {
                console.log("User Error => " + JSON.stringify(error));
            });
    }

    handleCreateCase() {
        this.showSpinner = true;
        handleCaseAction({ userId: userId })
            .then((result) => {
                if (result) {
                    this.showSpinner = false;
                    console.log('RESULT Create Case>>>>', result);
                    if (result == 'Success' || result == 'isCustomer') {
                        window.open(this.createCaseURL);
                    }
                    else {
                        let errormsg;
                        errormsg = result.error.message ? result.error.message : result.body.message;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error: ',
                                message: errormsg,
                                variant: 'error',
                                mode: 'dismissable',
                            }),
                        );
                    }
                }
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log("Case creation Error => " + JSON.stringify(error));
                if (error.body.message) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error: ',
                            message: error.body.message,
                            variant: 'error',
                            mode: 'dismissable',
                        }),
                    );
                }

            });
    }

    handleManageCase() {
        this.showSpinner = true;
        handleCaseAction({ userId: userId })
            .then((result) => {
                if (result) {
                    console.log('RESULT Manage case>>>>', result);
                    this.showSpinner = false;
                    if (result == 'Success' || result == 'isCustomer') {
                        window.open(this.manageCaseURL);
                    }
                    else {
                        let errormsg;
                        errormsg = result.error.message ? result.error.message : result.body.message;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error: ',
                                message: errormsg,
                                variant: 'error',
                                mode: 'dismissable',
                            }),
                        );
                    }
                }
            })
            .catch((error) => {
                this.showSpinner = false;
                console.log("Manage Case Error => " + JSON.stringify(error));
                if (error.body.message) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error: ',
                            message: error.body.message,
                            variant: 'error',
                            mode: 'dismissable',
                        }),
                    );
                }

            });

    }
    //Tag 3 ends

    getTopicId(event) {
        console.log('eventdetailValue=', event.detail.topicId)
        console.log('sobjname=', this.objectApiName)
        this.topicId = (event.detail.topicId) ? event.detail.topicId : this.recordId;
    }


    //Tag 6 starts
    handleCreatePoll() {
        /** START-- adobe analytics */
        try {
            console.log('doc title=', document.title);
            util.trackButtonClick('Community - Create a Poll - ' + document.title);
        }
        catch (ex) {
            console.error(ex.message);
        }
        /** END-- adobe analytics*/
        this.showpollModal = true;
        //console.log('Inside Event');
    }


    closePollModal(event) {
        console.log('CLOSE MODAL >', event.detail)
        if (event.detail) this.showpollModal = false;

    }

    //Tag 6 ends
}