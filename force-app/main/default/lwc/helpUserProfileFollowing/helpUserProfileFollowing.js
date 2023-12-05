/*
* Name : HelpUserProfileFollowing
* Author : Deeksha Shetty
* Created Date : March 5, 2022
* Description : This Component displays User Following in user profile page
Change History
**********************************************************************************************************
Modified By Date Jira No. Description Tag
**********************************************************************************************************
10/02/2022 I2RT- Initial version. N/A
*/


import { LightningElement, wire, api } from 'lwc';
import getFollowingNumber from "@salesforce/apex/helpUserProfileController.getFollowingNumber";
import communityId from '@salesforce/community/Id';
import userId from '@salesforce/user/Id';

export default class HelpUserProfileFollowing extends LightningElement {
    @api recordId;
    topParticipants;
    showParticipants = false;

    @wire(getFollowingNumber, { networkId: communityId, userId: '$recordId' })
    wiredTopParticipants({ data, error }) {
        if (data) {
            this.topParticipants = data;
            if (data.length > 0) {
                this.showParticipants = true;
            }
            else {
                this.showParticipants = false;
            }
            this.userfollowers = false;
            console.log('Following NUMBER=' + JSON.stringify(this.topParticipants))
        } else if (error) {
            console.log("error", JSON.stringify(error.body));
        }
    }
}