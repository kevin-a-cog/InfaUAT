/*
 * Name         :   HelpUserInfo
 * Author       :   Utkarsh Jain
 * Created Date :   17-FEB-2022
 * Description  :   Component used to show user info on homepage.

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Utkarsh Jain          18-FEB-2022      I2RT-5421           Initial version.                                          NA
 */
import { LightningElement,track,wire } from 'lwc';
import Id from '@salesforce/user/Id';
import communityId from '@salesforce/community/Id';
import getCurrentUserDetails from "@salesforce/apex/helpUserRelatedList.getCurrentUserDetails";


export default class HelpUserInfo extends LightningElement {

    @track userData;
    @track isData = false;
    @wire(getCurrentUserDetails, { networkId: communityId, userId: Id}) 
    userDetails({error, data}) {
        if (data) {
            this.userData = data;
            this.isData = true;
        } else if (error) {
            this.error = error ;
        }
    }

}