/*
 * Name         :   InFooter
 * Author       :   Utkarsh Jain
 * Created Date :   15-JAN-2022
 * Description  :   Footer component.

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Utkarsh Jain           15-JAN-2021     Utopia-ph-3         Initial version.                                          NA
 Utkarsh Jain           26-OCT-2022     I2RT-6996           Introducing the contact support field in the footer       1
 */
import { LightningElement, track, wire } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import IN_StaticResource from "@salesforce/resourceUrl/informaticaNetwork";
import analytics_script from '@salesforce/label/c.adobe_analytics'; 
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import FEDERATION_FIELD from '@salesforce/schema/User.FederationIdentifier';
import isguest from '@salesforce/user/isGuest';


export default class InFooter extends LightningElement {
  appLogo = IN_StaticResource + "/footerLogo.png";

  @track fedId;
  @wire(getRecord, {
      recordId: USER_ID,
      fields: [FEDERATION_FIELD]
  }) wireuser({
      error,
      data
  }) {
      if (error) {
         this.error = error ; 
      } else if (data) {
          this.fedId = data.fields.FederationIdentifier.value;
          window.liveUser = this.fedId;
      }
  }

  connectedCallback() {
    if (analytics_script != "") {
      Promise.all([
        loadScript(this, analytics_script)
      ])
        .then(() => {
          Promise.all([
            loadScript(this, IN_StaticResource + '/js/analytics/custom.js')
          ])
            .then(() => {
             /** START-- adobe analytics */
             try {
                util.setOktaUserID(this.fedId);
              }
              catch(ex) {
                  console.log(ex.message);
              }
              /** END-- adobe analytics*/
              util.trackPageView();
              if(isguest && document.title.includes('Home')){
                     /** START-- adobe analytics */
                     try {
                        util.trackAnonymousHomePage();                            
                    }
                    catch (ex) {
                        console.log(ex.message);
                    }
                    /** END-- adobe analytics*/
                }

            });

        })
        .catch(() => {
          console.log(JSON.stringify(error));
        });
    }
    if (window.location.href.includes("network.informatica.com")) {
      Promise.all([loadScript(this, IN_StaticResource + "/js/walkme.js")])
        .then(() => {
        })
        .catch(() => {
          console.log(JSON.stringify(error));
        });
    } else {
      Promise.all([loadScript(this, IN_StaticResource + "/js/walkme-test.js")])
        .then(() => {
        })
        .catch(() => {
          console.log(JSON.stringify(error));
        });
    }
  }

  get getCurrentYear() {
    return new Date().getFullYear();
  }
}