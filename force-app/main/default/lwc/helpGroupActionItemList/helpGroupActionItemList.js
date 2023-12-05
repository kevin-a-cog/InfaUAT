/*
 * Name         :   HelpGroupActionItemList
 * Author       :   Utkarsh Jain
 * Created Date :   17-FEB-2022
 * Description  :   Component used to show Action on Groups details page.

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                                 Tag
 **************************************************************************************************************************
 Utkarsh Jain          16-JUN-2022      I2RT-6422           Bringing Announcements on Community Page                     NA
 Saumya Gaikwad        27-Jul-2022      I2RT-6758           Displaying chapter leaders name in the Group details widget  T1
 Deeksha Shetty        02 Dec,2022      I2RT-7545			Spammed words are getting posted in product community	     T2
 Deeksha Shetty        08 May 2023     I2RT-8345           Ask a Question - Email Notification - Issue observed          T3
                                                            in New and Update Notification email template
 */

import { api, LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import userId from '@salesforce/user/Id';
import communityId from '@salesforce/community/Id';
import isinternaluser from '@salesforce/customPermission/User_Group_Admin';
import CommunityURL from '@salesforce/label/c.IN_CommunityName';
import IN_account_login from '@salesforce/label/c.IN_account_login';
import joinGroup from "@salesforce/apex/helpGroupsController.joinGroup";
import unfollowgroup from "@salesforce/apex/helpGroupsController.unfollowgroup";
import getgroupType from "@salesforce/apex/helpGroupsController.getgroupType";
import createAnnouncement from "@salesforce/apex/helpGroupsController.createAnnouncement";
import saveAnnouncement from "@salesforce/apex/helpGroupsController.updateAnnouncement";
import IN_StaticResource from "@salesforce/resourceUrl/informaticaNetwork";
import IN_StaticResource2 from "@salesforce/resourceUrl/InformaticaNetwork2";
import getUserType from '@salesforce/apex/helpGroupsController.getUserType';
import getgroupAdmin from '@salesforce/apex/helpGroupsController.getgroupAdmin';
import getgroupmember from '@salesforce/apex/helpGroupsController.getgroupmember';
import saveQuestionPost from "@salesforce/apex/helpGroupsController.saveQuestionPost";
import leadUserGroup from "@salesforce/apex/helpGroupsController.leadUserGroup";
import sendMail from "@salesforce/apex/helpGroupsController.sendMail";
import { publish, MessageContext } from 'lightning/messageService'
import ANNOUNCMENTS_MC from "@salesforce/messageChannel/AnnouncementsMessageChannel__c";
import getAnnouncementTileList from "@salesforce/apex/InAnnouncementBanner.getAnnouncementTileList";


export default class HelpGroupActionItemList extends NavigationMixin(LightningElement) {

    @api recordId;
    @api showCreateAnGroup;
    @api showAskAQuestion;
    @api showFollow;
    @track isFollowing = false;
    @track heading = 'Ask A Question';
    showGroupModal;
    showpollModal;
    showAnnouncementModal;
    showAnnouncementsModal;
    announcements = [];
    isGuestUser = false;
    isGroupAdmin = false;
    ispublicGroup = false;
    isprivateGroup = false;
    isLoading;
    objEvent;
    linkList;
    isSpinnerLoading = false; //T2


    @track isAskQuestionModal = false;
    questionLogo = IN_StaticResource + "/question.png";
    followgroupLogo = IN_StaticResource2 + "/joingroupicon.svg";
    createpolllogo = IN_StaticResource2 + "/pollicon.svg";
    createeventLogo = IN_StaticResource2 + "/eventicon.png";
    startausergrouplogo = IN_StaticResource2 + "/startagroupicon.svg";
    leadausergrouplogo = IN_StaticResource2 + "/leadagroupicon.svg";
    announcementLogo = IN_StaticResource2 + "/announcementicon.png";
    leaveGroupLogo = IN_StaticResource2 + "/leaveGroupIcon.svg"


    @wire(MessageContext)
    messageContext;

    @wire(getgroupType, { grpId: '$recordId' })
    wiredGroupType({ data, error }) {
        if (data) {
            if (data == 'Public') {
                this.getgroupmember();
                this.getGroupAdmin();
                this.ispublicGroup = true;
            }
            if (data == 'Private') {
                this.getgroupmember();
                this.getGroupAdmin();
                this.isprivateGroup = true;
            }
            this.getUserType();

        } else if (error) {
            console.error("error", error);
        }
    }

    connectedCallback() {
        leadUserGroup().then(
            result => {
                this.linkList = result;
            }
        ).catch(error => {
            console.error('This is the error ::: ' + error);
        });
    }

    openLink() {
        /** START-- adobe analytics */
        try {
            util.trackButtonClick('IUG - Lead A User Group');
        }
        catch (ex) {
            console.error(ex.message);
        }
        /** END-- adobe analytics*/
        let startgroupurl = this.linkList.Lead_User_Group_Link__c;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: startgroupurl
            }
        });
    }

    handleasktojoinagroup() {
        /** START-- adobe analytics */
        try {
            util.trackButtonClick('IUG - Ask Join a Group - ' + document.title);
        }
        catch (ex) {
            console.error(ex.message);
        }
        /** END-- adobe analytics*/
        sendMail({ grpId: this.recordId, userId: userId })
            .then(result1 => {
                if (result1) {
                    let res = JSON.stringify(result1);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success ',
                            message: 'Request Email Sent to Admin of the Group',
                            variant: 'success'
                        }),
                    );
                }
            })
            .catch(error => {
                console.log(error.body.message);
            })
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success : ',
                message: statusmsg,
                variant: 'success',
            }),
        );
    }


    getUserType() {
        if (userId === 'undefined' || userId === 'undefined' || !userId) {
            this.currentUserType = 'Guest';
            this.isGuestUser = true;
        }
        else {
            getUserType({ userId: userId })
                .then((result) => {
                    if (result) {
                        this.currentUserType = result;
                        if (this.currentUserType == 'Guest') this.isGuestUser = true;
                    }
                })
                .catch((error) => {
                    console.log(error.body);
                });
        }

    }

    getGroupAdmin() {
        getgroupAdmin({ userId: userId, grpId: this.recordId })
            .then((result) => {
                if (result) {
                    this.isGroupAdmin = true;
                }
            })
            .catch((error) => {
                console.log(error.body);
            });

    }

    getgroupmember() {
        getgroupmember({ userId: userId, grpId: this.recordId })
            .then((result) => {
                if (result) {
                    this.isFollowing = true;
                    console.log(this.isFollowing);
                }
            })
            .catch((error) => {
                console.log(error.body);
            });

    }


    handlejoinGroup() {
        /** START-- adobe analytics */
        try {
            util.trackButtonClick('IUG - Join User group - ' + document.title);
        }
        catch (ex) {
            console.error(ex.message);
        }
        /** END-- adobe analytics*/
        if (userId == undefined) {
            window.location.assign(IN_account_login);
        } else {
            joinGroup({ grpId: this.recordId, user: userId })
                .then((data) => {
                    this.isFollowing = true;
                })
                .catch((error) => {
                    console.log(error);
                })
        }
    }

    handleunfollowgroup() {
        /** START-- adobe analytics */
        try {
            util.trackButtonClick('IUG - Unfollow User group - ' + document.title);
        }
        catch (ex) {
            console.error(ex.message);
        }
        /** END-- adobe analytics*/
        unfollowgroup({ grpId: this.recordId, user: userId, networId: communityId })
            .then((data) => {
                this.isFollowing = false;
            })
            .catch((error) => {
                console.log(error);
            })
    }

    createEvent(objEvent) {
        let objParent = this;

        var isValidValue = [...this.template.querySelectorAll('lightning-input,lightning-textarea')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);

        if (isValidValue) {
            objParent.isLoading = true;
            createEvent({ strEvent: JSON.stringify(objParent.objEvent), grpId: this.recordId })
                .then(result => {
                    if (result) {
                        objUtilities.showToast("Success", 'Event has been created successfully', "success", objParent);
                        objParent.isLoading = false;
                        objParent.closeModal();
                    }
                })
                .catch(objError => {
                    objUtilities.processException(objError, objParent);
                    objParent.isLoading = false;
                })
        }
    }

    createAnnouncement(event) {
        let title = event.detail.title;
        let desc = event.detail.desc;
        let startDate = event.detail.startDate;
        let endDate = event.detail.endDate;
        createAnnouncement({ title: title, description: desc, startDate: startDate, endDate: endDate, groupId: this.recordId }).then((result) => {
            this.showAnnouncementModal = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success ',
                    message: 'Announcement created Successfully!!',
                    variant: 'success',
                    mode: 'dismissable',
                }),
            );
            const payload = { recordId: this.recordId };
            publish(this.messageContext, ANNOUNCMENTS_MC, payload);
        }).catch((error) => {
            this.showAnnouncementModal = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Failed ',
                    message: 'Error while creating Announcemnet',
                    variant: 'error',
                    mode: 'dismissable',
                }),
            );
        })
    }

    saveAnnouncement(event) {
        let Id = event.detail.Id;
        let title = event.detail.title;
        let desc = event.detail.desc;
        let startDate = event.detail.startDate;
        let endDate = event.detail.endDate;
        saveAnnouncement({ Id: Id, title: title, description: desc, startDate: startDate, endDate: endDate, groupId: this.recordId }).then((result) => {
            this.showAnnouncementsModal = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success ',
                    message: 'Announcement updated Successfully!!',
                    variant: 'success',
                    mode: 'dismissable',
                }),
            );
            const payload = { recordId: this.recordId };
            publish(this.messageContext, ANNOUNCMENTS_MC, payload);
            location.reload();
            eval("$A.get('e.force:refreshView').fire();");
        }).catch((error) => {
            console.log('Error while saving Announcemnet : ' + JSON.stringify(error));
            this.showAnnouncementsModal = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Failed ',
                    message: 'Error while saving Announcemnet',
                    variant: 'error',
                    mode: 'dismissable',
                }),
            );
        })
    }

    saveData(event) {
        this.isSpinnerLoading = true; //T2
        let fileData = event.detail.file;
        saveQuestionPost({ title: event.detail.title, body: event.detail.desc, parentId: this.recordId, fileList: JSON.stringify(fileData) })
            .then((data) => {
                let questionId = data;
                /** T3 starts */
                if (questionId != '') {
                    this.closeAskQuestionModal();
                    window.location.assign(CommunityURL + 'question/' + questionId);

                    // uploadFile({ fileList: JSON.stringify(fileData), recordId: questionId })
                    //     .then((data) => {

                    //     })
                    //     .catch((error) => {
                    //         console.log('file attachment error > ', error);
                    //     })
                }
                /** T3 ends */
            })
            .catch((error) => {
                console.log("error", error);
                this.isSpinnerLoading = false; //T2 starts
                if (error.body.message.includes('FIELD_MODERATION_RULE_BLOCK')) {
                    let bmOne = error.body.message.split('FIELD_MODERATION_RULE_BLOCK,')[1];
                    bmOne = bmOne.split('[RawBody]')[0];
                    bmOne = bmOne.split('[Title, RawBody]')[0];
                    bmOne = bmOne.split(':')[0];
                    this.template.querySelector('c-help-group-ask-a-question').showErrorMessage(bmOne);
                } else {
                    this.template.querySelector('c-help-group-ask-a-question').showErrorMessage('Error in Saving this Discussion.');
                }
                //T2 ends
            })
    }


    handleAskQuestion() {
        /** START-- adobe analytics */
        try {
            util.trackButtonClick('IUG - Ask A Question - ' + document.title);
        }
        catch (ex) {
            console.error(ex.message);
        }
        /** END-- adobe analytics*/
        if (userId == undefined) {
            window.location.assign(IN_account_login);
        } else {
            this.isAskQuestionModal = true;
            document.body.classList += ' modal-open';
        }
    }

    closeAskQuestionModal() {
        this.isAskQuestionModal = false;
        document.body.classList -= ' modal-open';
    }

    closeAnnouncementModal() {
        this.showAnnouncementModal = false;
        document.body.classList -= ' modal-open';
    }
    closeAnnouncementsModal() {
        this.showAnnouncementsModal = false;
        document.body.classList -= ' modal-open';
    }

    handleCreateEvent() {
        /** START-- adobe analytics */
        try {
            util.trackButtonClick('IUG - Create Event - ' + document.title);
        }
        catch (ex) {
            console.error(ex.message);
        }
        /** END-- adobe analytics*/
        this.showGroupModal = true;
    }
    closeEventModal() {
        this.showGroupModal = false;

    }
    handleCreatePoll() {
        /** START-- adobe analytics */
        try {
            util.trackButtonClick('IUG - Create a Poll - ' + document.title);
        }
        catch (ex) {
            console.error(ex.message);
        }
        /** END-- adobe analytics*/
        this.showpollModal = true;
        //console.log('Inside Event');
    }
    handleCreateAnnouncement() {
        /** START-- adobe analytics */
        try {
            util.trackButtonClick('IUG - Create a Announcement - ' + document.title);
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
            util.trackButtonClick('IUG - Edit a Announcement - ' + document.title);
        }
        catch (ex) {
            console.error(ex.message);
        }
        /** END-- adobe analytics*/
        getAnnouncementTileList({ type: 'Groups', id: this.recordId }).then(result => {
            this.announcements = JSON.parse(JSON.stringify(result));
            this.showAnnouncementsModal = true;
        }).catch(error => {
            console.error(JSON.stringify(error));
        });
    }
    closePollModal(event) {
        if (event.detail) this.showpollModal = false;

    }

    handleEditAnnouncement(event) {
        event.preventDefault();
    }

    get isInternaluser() {
        return isinternaluser;
    }
}