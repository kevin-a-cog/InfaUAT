import { LightningElement, api, track, wire } from 'lwc';
import IN_StaticResource from "@salesforce/resourceUrl/informaticaNetwork";
import communityId from "@salesforce/community/Id";
import getJoinGroupLanding from "@salesforce/apex/helpGroupsController.getJoinGroupLanding";
import getUserGroupId from "@salesforce/apex/helpGroupsController.getUserGroupId";
import IN_account_login from '@salesforce/label/c.IN_account_login';
import Accounts_Saml_Url from '@salesforce/label/c.Accounts_Saml_Url';
import IN_CommunityName from '@salesforce/label/c.IN_CommunityName';

export default class InJoinTheGroup extends LightningElement {
    @api groupCatalogRelative;
    @track groupCatalogUrl;
    @track allGroupsList = [
      {
        Id: "1",
        Name: "Japan User Group",
      },
      {
        Id: "2",
        Name: "Chicago User Group",
      },
      {
        Id: "3",
        Name: "Dallas / Fort Worth User Group",
      },
      {
        Id: "4",
        Name: "Wisconsin User Group",
      },
      {
        Id: "5",
        Name: "Raleigh User Group",
      },
      {
        Id: "6",
        Name: "Iowa User Group",
      },
      {
        Id: "7",
        Name: "Houston User Group",
      },
      {
        Id: "8",
        Name: "Florida User Group",
      },
      {
        Id: "9",
        Name: "New England User Group",
      },
    ];;
    @track communityLogo = IN_StaticResource + "/community.png";
    @track addLogo = IN_StaticResource + "/add.png";
    
    connectedCallback() {
        this.groupCatalogUrl = IN_CommunityName+this.groupCatalogRelative;
    }

    handleGroupRedirect(event) {
      let name = event.currentTarget.dataset.id;
      /** START-- adobe analytics */
      try {
         util.trackButtonClick('iug - '+name);
     }
     catch (ex) {
         console.log(ex.message);
     }
     /** END-- adobe analytics*/
        try {
          getUserGroupId({groupName: name, networkId: communityId})
          .then((data) => {
            var redirectURI = IN_account_login+"/login.html?fromURI="+encodeURIComponent(Accounts_Saml_Url+"?RelayState="+encodeURIComponent(window.location.href) + 'group/' + data);
            window.location.assign(redirectURI);
          })
          .catch((error) => {
            var redirectURI = IN_account_login+"/login.html?fromURI="+encodeURIComponent(Accounts_Saml_Url+"?RelayState="+encodeURIComponent(window.location.href));
            window.location.assign(redirectURI);
          })
           
        } catch (error) {
            console.log('error', 'handleGroupRedirect : ' + error.message + " : " + error.stack);
        }
      }

    // @wire(getJoinGroupLanding, {networkId: communityId, sortvalue: 'ASC'})
    // GroupsList({ error, data }) {
    //   if (data) {
    //       this.allGroupsList = data;
    //     console.log("allGroupsList Success : Results data : ", data);
    //   } else if (error) {
    //       console.log("allGroupsList Error : data : ", error);
    //   }
    // }
}