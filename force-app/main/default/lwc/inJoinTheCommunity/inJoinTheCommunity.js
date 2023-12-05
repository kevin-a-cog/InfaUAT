/*
* Name : InJoinTheCommunity
* Author : Utkarsh Jain
* Created Date : March 5, 2022
* Description : This Component displays Top communitites based on number of followers.
Change History
**********************************************************************************************************
Modified By          Date          Jira No.         Description                                      Tag
Utkarsh Jain         20-06-2023    I2RT-8368        Replace the community widget in the anonymous 
                                                    landing page with communities which has more 
                                                    followers.                                       In HTML AND TAG 1
**********************************************************************************************************

*/
import { LightningElement, api, track, wire } from "lwc";
import IN_StaticResource from "@salesforce/resourceUrl/informaticaNetwork";

import communityId from "@salesforce/community/Id";
import getCommunityId from "@salesforce/apex/helpCommunityController.getCommunityId";
import getCommunityFollowerCount from "@salesforce/apex/helpCommunityController.getMostFollowedCommunity";
import IN_account_login from "@salesforce/label/c.IN_account_login";
import Accounts_Saml_Url from "@salesforce/label/c.Accounts_Saml_Url";
import IN_CommunityName from "@salesforce/label/c.IN_CommunityName";

export default class InJoinTheCommunity extends LightningElement {
  @api topicCatalogRelative;
  @track topicCatalogUrl;
  @track allCommunityList = [];
  @track communityLogo = IN_StaticResource + "/community.png";
  @track addLogo = IN_StaticResource + "/add.png";

  connectedCallback() {
    this.topicCatalogUrl = IN_CommunityName + this.topicCatalogRelative;
  }

  initialRender = true;
  renderedCallback() {
    if (!this.initialRender) {
      return;
    }
    // Tag 1 Start
    getCommunityFollowerCount({ networkId: communityId })
    .then((data) => {
      this.allCommunityList = data.slice(0, 9);;
    })
    .catch((error) => {
      this.error = error;
      console.error(this.error);
    });
    this.initialRender = false;
  }
    // Tag 1 End

  handleRedirect(event) {
    let name = event.currentTarget.dataset.value;
    /** START-- adobe analytics */
    try {
      util.trackButtonClick("product name - " + name);
    } catch (ex) {
      console.log(ex.message);
    }
    /** END-- adobe analytics*/
    try {
      getCommunityId({ commName: name, networkId: communityId })
        .then((data) => {
          var redirectURI =
            IN_account_login +
            "/login.html?fromURI=" +
            Accounts_Saml_Url +
            "?RelayState=" +
            encodeURIComponent(window.location.href) +
            "topic/" +
            data;
          window.location.assign(redirectURI);
        })
        .catch((error) => {
          var redirectURI = IN_account_login+"/login.html?fromURI="+encodeURIComponent(Accounts_Saml_Url+"?RelayState="+encodeURIComponent(window.location.href));
          window.location.assign(redirectURI);
        });
    } catch (error) {
      console.log(
        "error",
        "handleRedirect : " + error.message + " : " + error.stack
      );
    }
  }
}