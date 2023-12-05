/*
 Change History
 ***************************************************************************************************************
 Modified By         Date            Jira No.            Description                                    Tag
 ***************************************************************************************************************
 Jiju N            07-Feb-2023      PRMRT-1238           Initial version.                                NA
 Jiju N            22-Feb-2023      PRMRT-1240           Fixed bug Jira                                  NA
 Puneet            31-07-2023       SALESRT-15141        Product Flow revamp                            <SALESRT-15141>
 */


import { LightningElement, track, wire } from 'lwc';
import PRM_CommunityUrl from '@salesforce/label/c.PRM_CommunityUrl';
 
export default class CustomNewProductRequest extends LightningElement {
 
     label = {
        PRM_CommunityUrl
     };
 
     handleClick() {
         let labelUrl = this.label.PRM_CommunityUrl;
         let finalUrl = labelUrl + 'newproductrequest';
         window.open(finalUrl,'_self');
     }
 
 }