/*
 * Name         :   HelpLanding
 * Author       :   Utkarsh Jain
 * Created Date :   15-JAN-2022
 * Description  :   This component is a child component for product community landing pages.

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Utkarsh Jain           15-JAN-2021     I2RT-5237           Initial version.                                          NA
 Utkarsh Jain           30-JAN-2023     I2RT-5889           Product community: Community Landing 
                                                            page - message to the user                                1
 Prashanth Bhat         22-JUN-2023     I2RT-8529           Introduce New sorting option in the 
                                                            Product community 
 Prashanth/Chetan       25-JUL-2023     I2RT-8649           Hiding filters in the landing page                        2   
 Prashanth Bhat         31-OCT-2023     I2RT-9228           Pagination  - Removed unused code                         3                                                                                                                                                            
 */
 import { api, LightningElement, track } from "lwc";
 import IN_StaticResource from "@salesforce/resourceUrl/informaticaNetwork";
 import communityId from "@salesforce/community/Id";
 import userId from '@salesforce/user/Id';
 import IN_account_login from '@salesforce/label/c.IN_account_login';   
 import Accounts_Saml_Url from '@salesforce/label/c.Accounts_Saml_Url';
 import IN_CommunityName from "@salesforce/label/c.IN_CommunityName";
 import getCommunityId from "@salesforce/apex/helpCommunityController.getCommunityId";
 
 export default class HelpLanding extends LightningElement {
     @track isFollowing = false;
     @track isTileView = true;
     @api communityLogo;
     @track hasRendered = false;
     addLogo = IN_StaticResource + "/add.png";
     minusLogo = IN_StaticResource + "/minus.png";
     tile = IN_StaticResource + "/tile-grey-v1.svg";
     color_tile = IN_StaticResource + "/tile-color-v1.svg";
     list = IN_StaticResource + "/list-grey-v1.svg";
     color_list = IN_StaticResource + "/list-color-v1.svg";
     @api resultSet = [];
     @api firstFilter;
     @api secondFilter;
     @api thirdFilter;
     @api firstplaceholder;
     @api secondplaceholder;
     @api thirdplaceholder;
     @api selectedfilters;
     @api showviewmore = false;
     @api nosearchresult = false;
     @api selectedsortBy;
     @api showFilters;
 
     get sortByOption() {
         return [
             {
                 label: "Most Followed",
                 value: "FLW",
             },
             {
                 label: "Most Popular",
                 value: "POP",
             },
             {
                 label: "Ascending",
                 value: "ASC",
             },
             {
                 label: "Descending",
                 value: "DESC",
             },
         ];
     }
 
     renderedCallback(){
         if(!this.hasRendered){
             this.hasRendered = true;
         }
     }
 
     @api
     clearAll(){
         this.hasRendered = false;
         this.handleClearAll();
     }
     
     handlefirstChange(event) {
         this.dispatchEvent(
             new CustomEvent("firstfilterchange", {
                 detail: event.detail,
             })
         );
     }
 
     handlesecondChange(event) {
         this.dispatchEvent(
             new CustomEvent("secondfilterchange", {
                 detail: event.detail,
             })
         );
     }
 
     handlethirdChange(event) {
         this.dispatchEvent(
             new CustomEvent("thirdfilterchange", {
                 detail: event.detail,
             })
         );
     }
     
     handleUnfollow(event) {
          /** START-- adobe analytics */
          try {
             util.trackButtonClick('unfollow this community - product communities page - '+event.currentTarget.dataset.name);
         }
         catch (ex) {
             console.error(ex.message);
         }
         /** END-- adobe analytics*/
         // Tag 1 - Start
         this.dispatchEvent(
             new CustomEvent("unfollow", {
                 detail: {"id" : event.currentTarget.dataset.value,
                         "name": event.currentTarget.dataset.name,
                     }
             })
         );
         // Tag 1 - End
     }
     
     handleFollow(event) {
          /** START-- adobe analytics */
          try {
             util.trackButtonClick('follow this community - product communities page - '+event.currentTarget.dataset.name);
         }
         catch (ex) {
             console.error(ex.message);
         }
         /** END-- adobe analytics*/
         if(userId == undefined){
             window.location.assign(IN_account_login+"/login.html?fromURI="+Accounts_Saml_Url+"?RelayState="+encodeURIComponent(window.location.href));
         }else{
             // Tag 1 - Start
             this.dispatchEvent(
                 new CustomEvent("follow", {
                     detail: {"id" : event.currentTarget.dataset.value,
                     "name": event.currentTarget.dataset.name,
                 }
                 })
             );
             // Tag 1 - End
         }
     }
 
     handleClearAll() {
         let multiSelectPicklist = [
             ...this.template.querySelectorAll("c-help-multi-pick-list"),
         ];
         if (multiSelectPicklist) {
             for (let item in multiSelectPicklist) {
                 multiSelectPicklist[item].clearSelection();
                 multiSelectPicklist[item].clear();
             }
         }
         this.dispatchEvent(
             new CustomEvent("clearall", {
                 detail: true,
             })
         );
     }
 
     handleFilterOption(event) {
         this.dispatchEvent(
             new CustomEvent("clearselectfilter", {
                 detail: event.currentTarget.dataset.id,
             })
         );
         let multiSelectPicklist = this.template.querySelector(
             '[data-id="in-first-filter"]'
         );
         if (multiSelectPicklist) {
             multiSelectPicklist.clearfilter(event.currentTarget.dataset.id);
         }
         let multiSelectPicklist2 = this.template.querySelector(
             '[data-id="in-second-filter"]'
         );
         if (multiSelectPicklist2) {
             multiSelectPicklist2.clearfilter(event.currentTarget.dataset.id);
         }
     }
 
     toggleTileView() {
         this.isTileView = true;
     }
 
     toggleListView() {
         this.isTileView = false;
     }
 
     handleSortBy(event) {
         this.dispatchEvent(
             new CustomEvent("sortby", {
                 detail: event.detail.value,
             })
         );
     }
 
     handleParentCommName(event){
         let name = event.currentTarget.dataset.value;
         getCommunityId({ commName: name, networkId: communityId })
         .then((data) => {
           let redirectURI = IN_CommunityName + 'topic/' + data;
           window.location.assign(redirectURI);
         })
         .catch((error) => {
         });
     }
 
     handleOnClick(event){
         let name = event.currentTarget.dataset.value;
         /** START-- adobe analytics */
         try {
            util.trackButtonClick('product name - '+name);
        }
        catch (ex) {
            console.error(ex.message);
        }
        /** END-- adobe analytics*/
     }
 }