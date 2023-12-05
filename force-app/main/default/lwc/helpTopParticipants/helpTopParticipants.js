/*
 * Name         :   HelpTopParticipants
 * Author       :   Utkarsh Jain
 * Created Date :   15-JAN-2022
 * Description  :   This component is used to display Top participants.

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Utkarsh Jain           15-JAN-2021     I2RT-5270           Initial version.                                          NA
 Utkarsh Jain           22-FEB-2021     I2RT-5539           BUG fix.                                                  1
 Prashanth Bhat         21-SEP-2023     I2RT-9053           Hiding the points for Top contributors                    2
 */
 import { api, LightningElement, track, wire } from 'lwc';
 import communityId from '@salesforce/community/Id';
 import userId from '@salesforce/user/Id';
 import getTopParticipantsByCommunity from "@salesforce/apex/helpUserRelatedList.getTopParticipantsByCommunity";
 import getTopParticipantsByGroup from "@salesforce/apex/helpUserRelatedList.getTopParticipantsByGroup";
 
 export default class HelpTopParticipants extends LightningElement {
     @api recordId;
     @track topParticipants = [];
     @track viewmore = '#';
     @track showParticipants = false;
     @api grouprecord;
 
     @wire(getTopParticipantsByCommunity, { commId: '$recordId', networkId: communityId })
     wiredTopParticipants({ data, error }) {
         if (data) {
 
             if (this.grouprecord)
             {
                 this.getTopParticipantsByGroup();
                 
             }else{
             this.topParticipants = data;
             if(data.length > 0){
                 this.showParticipants = true;
             }
         }
             
         } else if (error) {
             console.log("error", error);
         }
     }
 
     getTopParticipantsByGroup() {
         getTopParticipantsByGroup({ grpId:this.recordId, networkId: communityId })
                 .then((data) => {
                     if (data) {
                         this.topParticipants = data;
                         if(data.length > 0){
                             this.showParticipants = true;
                         }
                         console.log(this.grouprecord);
                     }
                 })
                 .catch((error) => {
                     console.log(error.body);
                 });
         
     }
 
 }