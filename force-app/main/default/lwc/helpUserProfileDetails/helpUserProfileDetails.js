/*
* Name : HelpUserProfileDetails
* Author : Deeksha Shetty
* Created Date : March 5, 2022
* Description : This Component displays User Details in user profile page
Change History
***********************************************************************************************************************
Modified By          Date          Jira No.         Description                                              Tag
Deeksha Shetty       14/6/2022      -               Nickname custom Message                                   T1
Utkarsh Jain         28-04-2023    I2RT-6143        Changing Nickname in IN community                        In HTML
Deeksha Shetty       14/08/2023    I2RT-8833        Anonymous user Access to User Profile visibility          T2
Deeksha Shetty       28/08/2023    I2RT-9006        SIT - IN Community - Anonymous - User Profile -           T3
                                                    Follow - After login, external user is not getting 
                                                    navigate to the user profile screen automatically
*************************************************************************************************************************

*/

import { LightningElement, api, wire } from 'lwc';
import userId from '@salesforce/user/Id';
import getUserdetails from "@salesforce/apex/helpUserProfileController.getUserdetails";
import getFollowingUser from "@salesforce/apex/helpUserProfileController.getFollowingUser";
import handleFollow from "@salesforce/apex/helpUserProfileController.handleFollow";
import communityId from '@salesforce/community/Id';
import getmetadatarecords from "@salesforce/apex/helpUserProfileController.getmetadatarecords";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import handlePostUploadSave from "@salesforce/apex/helpUserProfileController.handlePostUploadSave";
const OUTER_MODAL_CLASS = 'outerModalContent';
import handleNickName from "@salesforce/apex/helpUserProfileController.handleNickName";
import AccountURL from '@salesforce/label/c.IN_account_login';
import Accounts_Saml_Url from '@salesforce/label/c.Accounts_Saml_Url';//T3

export default class HelpUserProfileDetails extends LightningElement {
    @api recordId;
    userdetail;
    name;
    email;
    title;
    phone;
    company;
    photourl;
    address;
    firstName;
    lastName;
    userpoints;
    followLabel = 'FOLLOW';
    followClicked = false;
    followVisible;
    showVisible = false; //T2
    editURL;
    usrId = userId;
    showImgUploadModal = false;
    imageName;
    mimeType;
    base64content;
    showSpinner = false;
    showNickSpinner = false;
    file;
    nicknameshow = false;
    originalNickName;
    showData = false;
    nicknameMsg; //T1




    //For adding onclick event to close modal window on click
    constructor() {
        super();
        this.template.addEventListener("click", (event) => {
            if (event.target) {
                const classList = [...event.target.classList];
                if (classList.includes(OUTER_MODAL_CLASS)) {
                    this.handleModalClose();
                }
            }
        });
    }


    connectedCallback() {
        if (this.recordId && userId) {
            if ((this.recordId == userId) || (userId.includes(this.recordId))) {
                this.followVisible = false;
                this.showEdit = true;
            }
            else {
                this.followVisible = true;
                this.showVisible = true; //T2
            }
        }
        if (userId == undefined) {
            this.followVisible = true; //T2
        }
    }

    @wire(getmetadatarecords)
    wiredMetadata({ data, error }) {
        if (data) {
            this.editURL = data.EditProfileURL__c;
            this.nicknameMsg = data.Nickname_Validation__c; //T1
        } else if (error) {
            console.log("error", error);
        }
    }


    @wire(getFollowingUser, { recordId: '$recordId', user: userId, networId: communityId })
    wiredFollowingCommunity({ data, error }) {
        if (data) {
            if (data == 0) {
                this.followLabel = 'FOLLOW';
                this.followClicked = false;
            }
            else {
                this.followLabel = 'FOLLOWING';
                this.followClicked = true;
            }
        } else if (error) {
            console.log("error", error);
        }
    }


    @wire(getUserdetails, { recordId: '$recordId', networkId: communityId })
    wiredTopParticipants({ data, error }) {
        if (data) {
            this.showData = true;
            if (data.Userdetail[0].CommunityNickname) {
                this.name = data.Userdetail[0].CommunityNickname;
                this.originalNickName = data.Userdetail[0].CommunityNickname;
            }
            else {
                this.name = 'NA';
            }

            if (data.Userdetail[0].Email) {
                this.email = data.Userdetail[0].Email;
            }
            else {
                this.email = 'NA';
            }

            if (data.Userdetail[0].Title) {
                this.title = data.Userdetail[0].Title;
            }
            else {
                this.title = 'NA';
            }

            if (data.Userdetail[0].Phone) {
                this.phone = data.Userdetail[0].Phone;
            }
            else {
                this.phone = 'NA';
            }

            if (data.Userdetail[0].CompanyName) {
                this.company = data.Userdetail[0].CompanyName;
            }
            else {
                this.company = 'NA';
            }
            if (data.Userdetail[0].FirstName) {
                this.firstName = data.Userdetail[0].FirstName;
            }
            else {
                this.firstName = 'NA';
            }

            if (data.Userdetail[0].LastName) {
                this.lastName = data.Userdetail[0].LastName;
            }
            else {
                this.lastName = 'NA';
            }

            if (data.Userdetail[0].FullPhotoUrl) {
                this.photourl = data.Userdetail[0].FullPhotoUrl;
            }

            if (data.MemberPoints) {
                this.userpoints = data.MemberPoints;
            }

            if (data.Userdetail[0].Address) {
                this.address = data.Userdetail[0].Address.street + ',' + data.Userdetail[0].Address.city + ',' + data.Userdetail[0].Address.state + ',' + data.Userdetail[0].Address.postalCode + ',' + data.Userdetail[0].Address.country;
            }
            else {
                this.address = 'NA';
            }


        } else if (error) {
            console.log("error", JSON.stringify(error.body));
        }
    }


    handlefollowclick() {
        if (userId != undefined) {
            this.followClicked = !this.followClicked;
            if (this.followClicked) {
                this.followLabel = 'FOLLOWING';
                let followtype = 'Follow';
                handleFollow({ recordId: this.recordId, userId: userId, networkId: communityId, FollowType: followtype })
                    .then((result) => {
                        console.log('Message=' + JSON.stringify(result));
                    })
                    .catch((error) => {
                        console.log(error.body);
                    });

            }
            else {
                this.followLabel = 'FOLLOW';
                let followtype = 'Unfollow';
                handleFollow({ recordId: this.recordId, userId: userId, networkId: communityId, FollowType: followtype })
                    .then((result) => {
                        console.log('Message=' + JSON.stringify(result));
                    })
                    .catch((error) => {
                        console.log(error.body);
                    });
            }
        }
        /*  T3 starts */
        else {
            var varCurrentURL = document.location.href;
            window.location.assign(AccountURL + "/login.html?fromURI=" + Accounts_Saml_Url + "?RelayState=" + encodeURIComponent(varCurrentURL));
        }
        /*  T3 ends */

    }


    handleEdit() {
        window.open(this.editURL, "_blank");
    }

    handleNickName() {
        this.nicknameshow = true;
    }

    handleNickNameInput(event) {
        this.name = event.target.value;
    }

    handlepostName(event) {
        this.showNickSpinner = true;
        let nickname = event.target.name;

        if (nickname == 'save') {
            handleNickName({ nickname: this.name })
                .then((result) => {
                    if (result) {
                        this.showNickSpinner = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success : ',
                                message: 'Display Name Changed Successfully',
                                variant: 'success',
                            }),
                        );
                        this.nicknameshow = false;
                        location.reload();
                    }
                })
                .catch((error) => {
                    this.showNickSpinner = false;
                    let errormsg = error.body.message.includes('Nickname already exists') ? this.nicknameMsg : error.body.message; //T1                
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error : ',
                            message: errormsg,
                            variant: 'error',
                        }),
                    );
                });

        }

        else if (nickname == 'cancel') {
            this.name = this.originalNickName;
            this.showNickSpinner = false;
            this.nicknameshow = false;
        }

    }


    showUploadImage() {
        this.showImgUploadModal = true;
    }


    handleUploadFinished(event) {
        this.file = event.target.files[0];
        this.imageName = this.file.name;
        this.mimeType = this.file.type;
        var reader = new FileReader();
        reader.onload = () => {
            this.base64content = reader.result.split(',')[1];
        }
        reader.readAsDataURL(this.file);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Info : ',
                message: 'Image uploaded successfully.Please click on Save.',
                variant: 'info',
            }),
        );
    }



    handleFileSave() {
        this.showSpinner = true;
        handlePostUploadSave({ fileDetail: this.base64content, imgName: this.imageName, mimeType: this.mimeType, userId: this.recordId, communityId: communityId })
            .then((result) => {
                if (result) {
                    this.showSpinner = false;
                    this.handleModalClose();
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success: ',
                            message: 'Profile Picture Updated.',
                            variant: 'success',
                        }),
                    );
                    location.reload();

                }
            })
            .catch((error) => {
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error: ',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
    }

    handleModalClose() {
        this.file = [];
        this.imageName = '';
        this.mimeType = '';
        this.showImgUploadModal = false;
    }




}