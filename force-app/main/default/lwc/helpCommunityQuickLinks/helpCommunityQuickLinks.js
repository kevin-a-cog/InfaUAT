/*
 * Name         :   HelpCommunityQuickLinks
 * Author       :   Utkarsh Jain
 * Created Date :   20-SEPT-2022
 * Description  :   LWC component to display the quick links on the product community details page.

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Utkarsh Jain           20-SEPT-2022    I2RT-7026           Bringing quick links in the blue banner for 
                                                            all the product community detail page                     NA
 */
import { LightningElement, track, wire } from 'lwc';
import IN_StaticResource from "@salesforce/resourceUrl/informaticaNetwork";
import getCommunityName from "@salesforce/apex/helpUserRelatedList.getCommunityName";
import getQuickLinksForCommunity from "@salesforce/apex/helpCommunityController.getQuickLinksForCommunity";
import CommunityURL from '@salesforce/label/c.IN_CommunityName';
import getQuickLinks from "@salesforce/apex/helpCommunityController.getQuickLinks";

export default class HelpCommunityQuickLinks extends LightningElement {

    @track communityId = undefined;
    @track communityName = '';
    @track quickLink;
    @track quickLinks;
    @track showQuickLinks = false;
    @track quickLinksList = [];

    constructor() {
        super();
        if (window.location.pathname.includes("/informaticaNetwork/s/")) {
          this.communityId = window.location.pathname.toString().split("/")[4];
        } else {
          this.communityId = window.location.pathname.toString().split("/")[3];
        }
    }

    @wire(getQuickLinks)
    GetQuickLinks(result) {
        if (result.data) {
            let quickLinksResult = result.data;
            getCommunityName({commId: this.communityId})
            .then((result) => {
                this.communityName = encodeURIComponent(result);
                this.quickLinks = quickLinksResult.map(this.mapData, this);
                getQuickLinksForCommunity({ communityId: this.communityId})
                .then((result) => {
                    this.quickLink = result.Quick_Links__c.split(';');
                    this.quickLink.forEach(element => {
                        for(var key in this.quickLinks){
                            if(element == this.quickLinks[key].name){
                                this.showQuickLinks = true;
                                this.quickLinksList.push(this.quickLinks[key]);
                            }
                        }
                    });
                })
                .catch((error) => {
                    console.error(error);
                });
            })
        }else if(result.error){
            console.error(result.error);
        }
    }

    mapData(quickLink){
        let link = '';
        let _class = 'in-help-quick-link-item-img mb-2';
        if(quickLink.quicklinkurl__c.includes('global-search')){
            link = CommunityURL + quickLink.quicklinkurl__c + this.communityName + ']';
        }else if (quickLink.quicklinkurl__c.includes('discussion')){
            link = CommunityURL + quickLink.quicklinkurl__c + this.communityName + ']';
            _class = 'in-help-quick-link-item-img-discussion mb-2';
        }else if (quickLink.quicklinkurl__c.includes('event')){
            link = CommunityURL + quickLink.quicklinkurl__c + '?cloudProduct=' + true;
        }else{
            link = CommunityURL + quickLink.quicklinkurl__c + '?productname=' + this.communityName;
        }
        let ql = {
            name: quickLink.Label,
            icon: IN_StaticResource + quickLink.helpQuickLinkIcon__c,
            link: link,
            class: _class
        }
        return ql;
    }

    openLink(event){
         /** START-- adobe analytics */
         try {
            util.trackButtonClick("Quick link in community : " + event.currentTarget.dataset.name);
        }
        catch(ex) {
            console.error(ex.message);
        }
        /** END-- adobe analytics*/
        window.open(event.currentTarget.dataset.link);
    }

}