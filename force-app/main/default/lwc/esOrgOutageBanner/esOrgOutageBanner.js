/*
 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					                Tag
 **********************************************************************************************************
 NA             		NA		        UTOPIA			Initial version.			                N/A
 Vignesh Divakaran		10/4/2022		I2RT-6865		Added boolIsCaseLite as public property     T01
                                                        and parameter to wire method
 */

import { LightningElement,api, wire, track } from 'lwc';
import ESUPPORT_RESOURCE from '@salesforce/resourceUrl/eSupportRrc';
import { loadScript } from 'lightning/platformResourceLoader';
import getOrgList from '@salesforce/apex/orgOutageBanner_Controller.FetchOrgInfo';
 
export default class EsOrgOutageBanner extends LightningElement {
    alertImage = ESUPPORT_RESOURCE + '/alert-notification.svg';
    caseCreation = ESUPPORT_RESOURCE + '/create_case.svg';
    askExpert = ESUPPORT_RESOURCE + '/ask_exp.svg';
    askCommunity = ESUPPORT_RESOURCE + '/ask_community.svg';
    StatusPage;
    sp;
    podNames;

    @track hasRendered = true;
    @api supportAccountId;
    @api isPopupMsg;
    @api message;
    @api ShowMultiMsg;
    @api showGenericMsg;
    @api boolIsCaseLite = false; //<T01>
    @track error;
    @track newCaseUrl;
    @track aaeUrl;
    @track bannerOutage = {
        message: "Intelligent Cloud Services Status - Some of the Services are non-functional.",
        isOutage: false,
        podsData: {
            name: "",
            status: ""
        }
    };

    @wire( getOrgList,{orgId :'$supportAccountId', boolIsCaseLite: '$boolIsCaseLite'}) //<T01>
    AllOrgInfo({ error, data }) {
        
        if (data) {
            this.podNames = data;
            this.error = undefined;
            this.StatusPage = StatusPage;
            this.bannerOutage.isOutage = false;
            this.bannerOutage.podsData=[];
            this.checkStatus(this.bannerOutage);
        }
    }

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
                            bannerOutage.podsData = podData;
                            console.log(JSON.stringify(bannerOutage)+'pod==> '+JSON.stringify(podData));
                        }   
                    }
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                console.log('##Error in get Components call');
            }
        });
    }
}