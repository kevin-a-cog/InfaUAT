import { LightningElement, wire, track } from 'lwc';
import ESUPPORT_RESOURCE from '@salesforce/resourceUrl/eSupportRrc';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';  
import getOrgList from '@salesforce/apex/orgOutageBanner_Controller.FetchOrgNames';
import checkSupportAccountType from '@salesforce/apex/orgOutageBanner_Controller.checkSupportAccountType';
import AskOurCommunityURL from '@salesforce/label/c.AskOurCommunityURL'; 

import getSupportContactDetails from '@salesforce/apex/CaseController.getSupportContactDetails';
import { registerListener } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';

export default class OrgOutageBanner extends LightningElement {
    caseCreation = ESUPPORT_RESOURCE + '/create_case.svg';
    askExpert = ESUPPORT_RESOURCE + '/ask_exp.svg';
    askCommunity = ESUPPORT_RESOURCE + '/ask_community.svg';
    dashboardBanner = ESUPPORT_RESOURCE + '/dashboard-banner3.png';
    @track askOurCommunity;
    @track hotfix = 'hotfix-downloads';
    StatusPage;
    sp;
    podNames;
    @track error;
    @track newCaseUrl;
    @track aaeUrl;
    @track bShowAAEOption = false;
    @track bShowAllCTA = false;

    @track bannerOutage = {
        message: "Intelligent Cloud Services Status - Some of the Services are non-functional.",
        isOutage: false,
        podsData: []
    };
    @track hasReadWriteAccess = false;

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        Promise.all([
            loadScript(this, ESUPPORT_RESOURCE + '/js/infa-cloud-status.js')
        ])
            .then(() => {
                console.log("All scripts and CSS are loaded.")
            })
            .catch(error => {
                console.log(JSON.stringify(error));
            });

        registerListener('getAccountDetails', this.handleResponse, this);
    }

    handleResponse(supportAccountId) {
        console.log('handleResponse= ' + supportAccountId);
        this.newCaseUrl = 'newcase?accountId=' + supportAccountId;
        this.aaeUrl = 'askanexpert?supportaccountid=' + supportAccountId ;
        getOrgList({accId :supportAccountId})
        .then(data => {
            console.log("getOrgList, data ===> ", JSON.stringify(data));
            this.podNames = data;
            this.error = undefined;
            console.log("PodsNames from SF ===> ", JSON.stringify(this.podNames));
            this.StatusPage = StatusPage;
            this.bannerOutage.isOutage = false;
            this.bannerOutage.podsData = [];
            this.checkStatus(this.bannerOutage);
            console.log('AccountInfo= '+JSON.stringify(data));             
        });

      
        getSupportContactDetails({ caseId: '', supportAccountId: supportAccountId })
        .then(result => {
            console.log('Contact details Error => '+JSON.stringify(result));
            if(result != undefined && result != null){
                this.hasReadWriteAccess = result.isReadWrite;
            }
        })
        .catch(error => {
            console.log('Contact details Error => '+JSON.stringify(error));
        });

        
          //adde by piyush for I2RT-3887
          checkSupportAccountType({accId: supportAccountId })
          .then(result => {              
            console.log('checkSupportAccountType result => '+result)
              if(result){
                this.bShowAAEOption = true;
                this.bShowAllCTA = true;
              }
              else{
                this.bShowAAEOption = false;
                this.bShowAllCTA = true;
              }
          })
          .catch(error => {
              console.log('checkSupportAccountType Error => '+JSON.stringify(error))
          });

        
    }

    checkStatus(bannerOutage) {
        let bannerEnv = window.location.origin;
        switch (bannerEnv) {
            case "https://servicedev-infa.cs1.force.com":
            case "https://servdev2-infa.cs17.force.com":
            case "https://sit-infa.cs8.force.com":
            case "https://uat-infa.cs198.force.com":
                this.sp = new this.StatusPage.page({ page: 'k731vwcnx0zz', accessKey: '?api_key=e1d144ea-4811-4a21-9627-685583867884' });
                break;
            default:
                this.sp = new this.StatusPage.page({ page: 'qdkyv53bnw6d' });
        }

        let podNames = this.podNames;

        this.sp.components({
            success: function (data) {
                let esBannerStatus = {
                    operational: "Operational",
                    degraded_performance: "Degraded Performance",
                    under_maintenance: "Under Maintenance",
                    partial_outage: "Partial Outage",
                    major_outage: "Major Outage"
                };
                let components = data.components;
                console.log("PodsNames from statusPage ===> ", components);
                for (var key in components) {
                    var podData = {
                        name: "",
                        status: ""
                    };

                    if (components.hasOwnProperty(key)) {
                        var item = components[key];
                        if (item.group == true && item.status != "operational" && podNames.indexOf(item.name) > -1) {
                            bannerOutage.isOutage = true;
                            podData.name = item.name;
                            podData.status = esBannerStatus[item.status];
                            bannerOutage.podsData.push(podData);
                        }   
                    }
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                console.log('##Error in get Components call');
            }
        });
    }

    openAskOurCommunity(event){
         /** START-- adobe analytics */
         try {
            util.trackButtonClick("Ask Our Community");
        }
        catch(ex) {
            console.log("Error =======>",ex.message);
        }
        /** END-- adobe analytics*/
        window.open(AskOurCommunityURL, "_blank");
    }

    checkUserAccessForCase(event){

        if(this.hasReadWriteAccess){
            /** START-- adobe analytics */
            try {
                util.trackButtonClick("Create New Case");
            }
            catch(ex) {
                console.log("Error =======>",ex.message);
            }
            /** END-- adobe analytics*/
            return true;
        }
        else{
            event.preventDefault();
            this.showToastEvent('Error', 'You do not have access to create case for this Support Account.', 'error', 'dismissable');
        }                  
    }
    
    checkUserAccessForExpert(event){

        if(this.hasReadWriteAccess){
            /** START-- adobe analytics */
            try {
                util.trackButtonClick("Ask An Expert");
            }
            catch(ex) {
                console.log("Error =======>",ex.message);
            }
            /** END-- adobe analytics*/
            return true;
        }
        else{
            event.preventDefault();
            this.showToastEvent('Error', 'You do not have access to create case for this Support Account.', 'error', 'dismissable');
        }                  
    }

    showToastEvent(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
            mode
        });
        this.dispatchEvent(event);
    }
}