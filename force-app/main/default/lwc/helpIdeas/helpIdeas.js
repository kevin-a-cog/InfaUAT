/*
* Name : helpIdeas
* Author : Deeksha Shetty
* Created Date : January 11 2022
* Description : This Component displays Idea/CRT Detail Page
Change History
**********************************************************************************************************
Modified By Date Jira No. Description Tag
**********************************************************************************************************
10/02/2022 I2RT- Initial version. N/A
*/

import { LightningElement, wire, api, track } from 'lwc';
import communityId from '@salesforce/community/Id';
import ideasDisplay from '@salesforce/apex/helpIdeasController.ideasDisplay';
import addComments from '@salesforce/apex/helpIdeasController.addComments';
import deleteComment from '@salesforce/apex/helpIdeasController.deleteComment';
import showRelatedIdeas from '@salesforce/apex/helpIdeasController.showRelatedIdeas';
import likeCountUpdate from '@salesforce/apex/helpIdeasController.likeCountUpdate';
import returnUser from '@salesforce/apex/helpIdeasController.returnUser';
import likeCountUpdateforComment from '@salesforce/apex/helpIdeasController.likeCountUpdateforComment';
import handleUpvoteCount from '@salesforce/apex/helpIdeasController.handleUpvoteCount';
import handleDownvoteCount from '@salesforce/apex/helpIdeasController.handleDownvoteCount';
import { refreshApex } from '@salesforce/apex';
import userId from '@salesforce/user/Id';
import SaveEditedComment from '@salesforce/apex/helpIdeasController.SaveEditedComment';
import handleFollow from '@salesforce/apex/helpIdeasController.handleFollow';
// import returnUserforComment from '@salesforce/apex/helpIdeasController.returnUserforComment';
import IN_StaticResource from "@salesforce/resourceUrl/InformaticaNetwork2";
import { getRecord } from 'lightning/uiRecordApi';
import getUserType from '@salesforce/apex/helpIdeasController.getUserType';
import CommunityURL from '@salesforce/label/c.IN_CommunityName';
import getmetadatarecords from '@salesforce/apex/helpIdeasController.getmetadatarecords';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

export default class HelpIdeas extends LightningElement {
    mainData;
    commentBody;
    showButtons = false;
    successMsg;
    wiredResults;
    currentCommunityNetworkId;
    showReplyComment = false;
    replyBody;
    commentReply;
    replyIdeaid;
    editCommentId;
    deleteCommentId;
    relatedIdeas = [];
    showEditModal = false;
    showaddcomment = true;
    chevronup = IN_StaticResource + "/chevronup.jpg";
    chevrondown = IN_StaticResource + "/chevrondown.jpg";
    chevronupmini = IN_StaticResource + "/chevronupmini.jpg";
    chevrondownmini = IN_StaticResource + "/chevrondownmini.jpg";
    disableup = IN_StaticResource + "/disableup.png";
    disabledown = IN_StaticResource + "/disabledown.png";
    avatar = IN_StaticResource + "/avatar.png";

    //metadata records
    learnMore;
    takeMeThere;
    relatedIdeaslabel;
    editIdeaComment;


    //Like variables
    isLiked;
    likedIdea;
    likeType;
    buttonClicked = false;
    likeUItext = 'Like';
    IdeaIdOnLoad;
    userresult;
    togglecls = 'togglegrey';


    //Like Comment
    iscomLiked;
    togglecomment = 'togglegrey';
    ideaCommentUserData;

    //Edited Comment
    editedComment;
    inputcomment;
    editDeleteDisableData;

    //upvote/downvote
    disableUpvote = false;
    disableDownvote = false;

    //follow button
    followClicked = false;
    followUItext = 'Follow';
    followType;
    toggleFollow = 'togglegrey';
    followedIdea;
    hideUpvoteAction = false;

    changeRequestIdea = false;

    accountsite;
    currentUserType;
    currentIdeaStatus;
    totalupvotecount; //displays total comm interaction record for a aprticluar idea






    constructor() {
        super();
        let url = window.location.href;
        this.IdeaIdOnLoad = window.location.href.toString().split('?id=')[1];
        if (this.IdeaIdOnLoad) {
            this.helpIdeaDisplay();
        }
    }



    helpIdeaDisplay() {
        ideasDisplay({ IdeaUrlId: this.IdeaIdOnLoad, userId: userId })
            .then((result) => {
                if (result) {
                    this.mainData = result;
                    if (this.mainData) {
                        let res = JSON.parse(JSON.stringify(this.mainData));
                        res.forEach(item => {
                            item.Body.replace('informaticaNetwork/', '');

                        })
                        this.mainData = res;
                    }

                    this.currentIdeaStatus = this.mainData[0].Status;
                    if (this.currentIdeaStatus == 'Draft' || this.currentIdeaStatus == 'Archived') {
                        this.hideUpvoteAction = true;
                    }

                    this.showRelatedIdea();
                    this.handleUserEditDelete();
                    this.helpUserDisplay();
                    this.getUserType();
                    this.getmetadata();
                    if (this.mainData && this.ideaCommentUserData) {
                        this.handleLikedComment();
                    }

                }
            })
            .catch((error) => {
                console.log(error.body);
            });

    }

    getUserType() {

        if (userId === 'undefined' || userId === 'undefined' || !userId) {
            this.currentUserType = 'Guest';
        }
        else {
            getUserType({ userId: userId })
                .then((result) => {
                    if (result) {
                        this.currentUserType = result;
                    }
                })
                .catch((error) => {
                    console.log(error.body);
                });
        }

    }

    getmetadata() {
        getmetadatarecords()
            .then((result) => {
                if (result) {
                    this.editIdeaComment = result.Edit_Idea__c;
                    this.accountsite = result.Infa_Account_site__c;
                    this.learnMore = result.Learn_More__c;
                    this.takeMeThere = result.TakeMeThere__c;
                    if (this.mainData) {
                        this.mainData.forEach(item => {
                            if (item.ideaId == this.IdeaIdOnLoad) {
                                if (item.Category != 'Change Request') {
                                    this.relatedIdeaslabel = result.Related_Ideas__c;
                                }
                                else {
                                    this.relatedIdeaslabel = result.Related_CR__c;
                                }

                                if (item.Category == 'Change Request' || item.Category.includes('Change Request')) {
                                    this.changeRequestIdea = true;
                                }
                            }
                        })

                    }

                }
            })
            .catch((error) => {
                console.log(error.body);
            });

    }



    helpUserDisplay() {
        returnUser({ ideaId: this.IdeaIdOnLoad, userId: userId })
            .then((result) => {
                if (result) {
                    this.userData = result;
                    if (this.userData.LikeUser == 'UserExists') {
                        this.likeUItext = 'Liked';
                        this.togglecls = 'togglegreen';
                        this.buttonClicked = true;
                        this.likedIdea = this.IdeaIdOnLoad;   ////check thisss
                    }

                    if (this.userData.FollowUser == 'UserExists') {
                        this.followUItext = 'Following';
                        this.toggleFollow = 'toggleOrange';
                        this.followClicked = true;
                        this.followedIdea = this.IdeaIdOnLoad;
                    }

                    if (this.userData.ideaCommentLikeList) {
                        this.ideaCommentUserData = this.userData.ideaCommentLikeList;
                        if (this.mainData && this.ideaCommentUserData) {
                            this.handleLikedComment();
                        }

                    }
                    if (this.userData.upvoteTotalCount) {
                        this.totalupvotecount = this.userData.upvoteTotalCount;
                        this.displaytotalvoteCount();
                    }

                    if (this.userData.votedUser == 'UpvoteUserExists') {
                        this.disableUpvote = true;
                    }
                    else if (this.userData.votedUser == 'DownvoteUserExists') {
                        this.disableDownvote = true;
                    }
                    else {
                        console.log('something is wrong');
                    }

                }


            })
            .catch((error) => {
                console.log(error.body);
            });

    }



    showRelatedIdea() {
        //related ideas label
        showRelatedIdeas({ networkId: communityId, Ideaid: this.IdeaIdOnLoad })
            .then((result) => {
                this.relatedIdeas = result;

            })
            .catch((error) => {
                console.log(error.body);
            });
    }


    handleUserEditDelete() {
        let disableData = JSON.parse(JSON.stringify(this.mainData));
        disableData.forEach(element => {
            if (element.ideaCommentDetail) {
                element.ideaCommentDetail.forEach(item => {
                    if (item.commentedUserId == userId) {
                        item.disableEdit = false;
                        item.disableDelete = false;
                    }
                });
            }
            else {
                console.log('No comment');
            }

        });
        this.mainData = disableData;
    }

    handleLikedComment() {
        let likedCommentData = JSON.parse(JSON.stringify(this.mainData));
        likedCommentData.forEach(element => {
            if (element.ideaCommentDetail) {
                element.ideaCommentDetail.forEach(item => {
                    if (this.ideaCommentUserData.includes(item.ideaCommentId)) {
                        item.label = 'Liked';
                    }
                });
            }
            else {
                console.log('No comment');
            }
        });

        this.mainData = likedCommentData;
    }



    displaytotalvoteCount() {
        let upvote = JSON.parse(JSON.stringify(this.mainData));
        upvote.forEach(element => {
            if (element.ideaId == this.IdeaIdOnLoad) {
                element.upvoteCount = this.totalupvotecount;
            }
        });
        this.mainData = upvote;

    }


    handleCommentInput(event) {
        this.commentBody = event.target.value;
    }

    showButton() {
        if (this.currentIdeaStatus != 'Draft' && this.currentUserType != 'Guest') {
            this.showButtons = true;
            this.showaddcomment = false;
        }
    }

    handleCancel() {
        this.showButtons = false;
        this.commentBody = '';
        this.showaddcomment = true;
    }

    //handle after add
    handleComment() {
        if (this.commentBody && this.IdeaIdOnLoad) {
            addComments({ CommentBody: this.commentBody, IdeaId: this.IdeaIdOnLoad })
                .then((result) => {
                    if (result) {
                        this.helpIdeaDisplay();
                        this.showButtons = false;
                        this.commentBody = '';
                        this.showaddcomment = true;
                    }

                })
                .catch((error) => {
                    console.log(error.body);
                });

        }

    }

    handleEdit(event) {
        if (this.currentIdeaStatus != 'Draft' && this.currentUserType != 'Guest') {
            event.preventDefault();
            this.showEditModal = true;
            this.editCommentId = event.currentTarget.dataset.id;
            this.editedComment = event.currentTarget.dataset.name;
        }
    }

    handleInputedComment(event) {
        let commentinputed = event.target.value;
        this.inputcomment = commentinputed;
    }

    saveEditedComment() {
        if (this.inputcomment && this.editCommentId && this.IdeaIdOnLoad) {
            SaveEditedComment({ ideacommId: this.editCommentId, ideaId: this.IdeaIdOnLoad, commentBody: this.inputcomment })
                .then((result) => {
                    if (result) {
                        this.helpIdeaDisplay();
                        this.handleModalClose();
                    }
                })
                .catch((error) => {
                    console.log(error.body);
                });

        }
    }

    handleModalClose() {
        this.showEditModal = false;
    }


    handleDelete(event) {
        if (this.currentIdeaStatus != 'Draft' && this.currentUserType != 'Guest') {
            this.deleteCommentId = event.currentTarget.dataset.id;
            deleteComment({ ideacommId: this.deleteCommentId })
                .then((result) => {
                    if (result) {
                        this.helpIdeaDisplay();
                    }
                })
                .catch((error) => {
                    console.log(error.body);
                });
        }

    }

    handleLike(event) {
        if (this.currentUserType == 'Guest') {
            window.open(this.accountsite, "_blank");
        }
        if (this.currentIdeaStatus != 'Draft' && this.currentUserType != 'Guest') {
            this.likedIdea = event.currentTarget.dataset.id;
            this.likeType = event.currentTarget.name;
            this.buttonClicked = !this.buttonClicked; //set to true if false, false if true.
            if (this.buttonClicked) {
                this.togglecls = 'togglegreen';
                this.likeUItext = 'Liked';
                this.isLiked = 'Like';
                if (this.likedIdea && this.likeType) {
                    likeCountUpdate({ objId: this.likedIdea, likeType: this.likeType, isLike: this.isLiked, userId: userId })
                        .then((result) => {
                            let sucessmsg = result;


                        })
                        .catch((error) => {
                            console.log(error.body);
                        });
                }
            }
            else {
                this.togglecls = 'togglegrey';
                this.likeUItext = 'Like';
                this.isLiked = 'Dislike';
                likeCountUpdate({ objId: this.likedIdea, likeType: this.likeType, isLike: this.isLiked })
                    .then((result) => {
                        let sucessmsg = result;

                    })
                    .catch((error) => {
                        console.log(error.body);
                    });
            }
        }

    }

    handleIdeaCommentLike(event) {
        if (this.currentUserType == 'Guest') {
            window.open(this.accountsite, "_blank");
        }
        if (this.currentIdeaStatus != 'Draft' && this.currentUserType != 'Guest') {
            let targetId = event.currentTarget.dataset.id;
            let likeUnlike = JSON.parse(JSON.stringify(this.mainData));

            likeUnlike.forEach(element => {
                element.ideaCommentDetail.forEach(item => {
                    if (item.ideaCommentId == targetId && item.label == 'Like') {
                        this.iscomLiked = 'Like';
                        item.label = 'Liked';
                        this.togglecomment = 'togglegreen';
                    }
                    else if (item.ideaCommentId == targetId && item.label == 'Liked') {
                        this.iscomLiked = 'Dislike';
                        item.label = 'Like';
                        this.togglecomment = 'togglegrey';
                    }
                });
            });
            this.mainData = likeUnlike;

            if (targetId) {

                likeCountUpdateforComment({ objId: targetId, isLike: this.iscomLiked })
                    .then((result) => {
                        let sucessmsg = result;
                        console.log('sucessmsg=' + sucessmsg);
                    })
                    .catch((error) => {
                        console.log(error.body);
                    });
            }
        }
    }

    handleUpvote() {
        if (this.currentUserType == 'Guest') {
            window.open(this.accountsite, "_blank");
        }
        if (this.currentIdeaStatus != 'Draft' && this.currentUserType != 'Guest') {
            this.disableDownvote = false;
            this.disableUpvote = true;

            handleUpvoteCount({ ideaId: this.IdeaIdOnLoad, UserId: userId })
                .then((result) => {
                    if (result) {
                        let upvote = JSON.parse(JSON.stringify(this.mainData));
                        upvote.forEach(element => {
                            if (element.ideaId == this.IdeaIdOnLoad) {
                                element.upvoteCount = result.Upvote_Count__c;
                                this.followUItext = 'Following';
                                this.toggleFollow = 'toggleOrange';
                            }
                        });
                        this.mainData = upvote;

                    }
                })
                .catch((error) => {
                    console.log(error.body);
                });
        }

    }

    handleDownvote() {
        if (this.currentUserType == 'Guest') {
            window.open(this.accountsite, "_blank");
        }
        if (this.currentIdeaStatus != 'Draft' && this.currentUserType != 'Guest') {
            this.disableUpvote = false;
            this.disableDownvote = true;
            handleDownvoteCount({ ideaId: this.IdeaIdOnLoad, UserId: userId })
                .then((result) => {
                    if (result) {
                        let downvote = JSON.parse(JSON.stringify(this.mainData));
                        downvote.forEach(element => {
                            if (element.ideaId == this.IdeaIdOnLoad) {
                                element.upvoteCount = result.Upvote_Count__c;
                                this.followUItext = 'Follow';
                                this.toggleFollow = 'togglegrey';
                            }
                        });
                        this.mainData = downvote;

                    }

                })
                .catch((error) => {
                    console.log(error.body);
                });
        }
    }

    handleFollow(event) {
        if (this.currentUserType == 'Guest') {
            window.open(this.accountsite, "_blank");
        }
        if (this.currentIdeaStatus != 'Draft' && this.currentUserType != 'Guest') {
            this.followClicked = !this.followClicked;
            this.followedIdea = event.currentTarget.dataset.id;
            let followtype = event.currentTarget.dataset.name;
            if (this.followClicked) {
                this.followUItext = 'Following';
                this.toggleFollow = 'toggleOrange';
                if (this.followedIdea && followtype) {
                    handleFollow({ ideaId: this.followedIdea, followType: followtype, UserId: userId })
                        .then((result) => {
                            console.log('Message=' + JSON.stringify(result));
                        })
                        .catch((error) => {
                            console.log(error.body);
                        });

                }
            }
            else {
                this.followUItext = 'Follow';
                followtype = 'Unfollow';
                this.toggleFollow = 'togglegrey';
                if (this.followedIdea && followtype) {
                    handleFollow({ ideaId: this.followedIdea, followType: followtype, UserId: userId })
                        .then((result) => {
                            console.log('Message=' + JSON.stringify(result));
                        })
                        .catch((error) => {
                            console.log(error.body);
                        });

                }
            }
        }
    }



}