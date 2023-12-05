import { LightningElement, track, wire, api } from 'lwc';
import getMetadataRecord from '@salesforce/apex/helpUserRelatedList.getMetadataRecordFromCustomLabel'; 
import IN_RESOURCE from '@salesforce/resourceUrl/informaticaNetwork';
import { loadScript } from 'lightning/platformResourceLoader';
import getCommunityName from '@salesforce/apex/helpUserRelatedList.getCommunityName';
import CloudSupportCommunity from '@salesforce/label/c.CloudSupportCommunity';

export default class HelpOrgOutageBanner extends LightningElement {

    @track bannerOutage = {
        message: "Intelligent Cloud Services Status",
        isOutage: false,
        services: []
    };
    StatusPage;
    sp;
    podNames;
    @track showServices = true;
    @track service_pods = "content-justified content-pods es-hide";
    collapse = IN_RESOURCE + '/collapse.png';
    expand = IN_RESOURCE + '/expand.png';
    collapseAll = IN_RESOURCE + '/collapseAll.png';
    expandAll = IN_RESOURCE + '/expandAll.png';
    @track icon_name = this.expandAll;
    @track communityType;
    @track communityUrl;
    @track operationalStatus;
    @api recordId;
    @track isCloudCommunity = false;

    @wire(getCommunityName, {commId : '$recordId'})
    GetCommunity(result){
        if(result.data){
            let communityName = result.data;
            if(CloudSupportCommunity == communityName || CloudSupportCommunity.includes(communityName)){
                this.isCloudCommunity = true;
            }
        }
    }

    handleOutageDisplay() {
        if (this.icon_name == this.expandAll) {
            this.icon_name = this.collapseAll;
            this.service_pods = "content-justified content-pods es-block";
            this.showServices = false;
        }
        else {
            this.icon_name = this.expandAll;
            this.service_pods = "content-justified content-pods es-hide";
            this.showServices = true;
        }
    }

    connectedCallback() {
        getMetadataRecord({ metadataName: 'Cloud_Community_Status' }) 
            .then(result => {
                this.communityType = result.Communtiy_Type__c;
                this.operationalStatus = result.Operational_Status__c;
                getMetadataRecord({ metadataName: 'community_url' }) 
                .then(result => {
                    this.communityUrl = result.community_url__c;
                })
                .catch(error => {
                    console.log(' community_url Metadata error ==> '+ JSON.stringify(error));
                });
                Promise.all([
                    loadScript(this, IN_RESOURCE + '/js/infa-cloud-status.js')
                ])
                    .then(() => {
                        this.StatusPage = StatusPage;
                        this.checkStatus(this.bannerOutage,this.operationalStatus,this.communityType,this.communityUrl);
                    })
                    .catch(error => {
                        console.log(JSON.stringify(error));
                    });
            })
            .catch(error => {
                console.log('Cloud_Community_Status Metadata error ==> '+ JSON.stringify(error));
            });
        

        
    }

    checkStatus(bannerOutage,operationalStatus,communityType,communityUrl) {
        try {
            this.sp = new this.StatusPage.page({ page: 'qdkyv53bnw6d' });
            this.sp.components({
                success: function (data) {
                    let infaNetworkStatus = {
                        operational: "Operational",
                        degraded_performance: "Degraded Performance",
                        under_maintenance: "Under Maintenance",
                        partial_outage: "Partial Outage",
                        major_outage: "Major Outage"
                    };
                    let components = data.components;

                    let arr = components;
                    var tree = [],
                        mappedArr = {},
                        arrElem,
                        mappedElem;

                    // First map the nodes of the array to an object -> create a hash table.
                    for (var i = 0, len = arr.length; i < len; i++) {
                        arrElem = arr[i];
                        mappedArr[arrElem.id] = arrElem;
                        mappedArr[arrElem.id]['items'] = [];
                    }


                    for (var id in mappedArr) {
                        if (mappedArr.hasOwnProperty(id)) {
                            mappedElem = mappedArr[id];
                            // If the element is not at the root level, add it to its parent array of children.
                            // console.log('mappedElem["name"] :: ' + mappedElem['name']);
                            if (mappedElem.group_id) {
                                mappedElem['status'] = mappedElem['status'].toUpperCase();
                                mappedElem['statusClass'] = (mappedElem['status'] == 'OPERATIONAL') ? 'service-status-operational' : 'service-status-maintenance';
                                mappedArr[mappedElem['group_id']]['items'].push(mappedElem);
                            }
                            // If the element is at the root level, add it to first level elements array.
                            else {
                                tree.push(mappedElem);
                            }
                        }
                    }
                    let isCloudOutage = false;
                    for (var key in tree) {
                        var serviceData = {
                            id:"",
                            name: "",
                            status: "",
                            items:[],
                            expanded:false
                        };
                        
                        if (tree.hasOwnProperty(key)) {
                            var item = tree[key];
                            // console.log('group :: ' + item.group );
                            // console.log('status :: ' + item.status);
                            if (item.group == true && operationalStatus.includes(item.status) /* && item.status != 'operational' */  ) {
                                
                                bannerOutage.isOutage = true;
                                serviceData.id = item.id;
                                serviceData.label = item.name;
                                serviceData.name = item.name;
                                serviceData.status = infaNetworkStatus[item.status].toUpperCase();
                                serviceData.items = item.items;
                                serviceData.statusClass = (serviceData.status == 'OPERATIONAL') ? 'service-status-operational' : 'service-status-maintenance';
                               // console.log('item.name :: ' + item.name);
                                // if(item.name.includes(communityType))
                                bannerOutage.services.push(serviceData);
                               
                                isCloudOutage = (serviceData.status == 'OPERATIONAL' && !isCloudOutage) ? false : true;
                            }   
                        }
                    }
                    bannerOutage.message = !isCloudOutage ? 'Intelligent Cloud Services Status - All Systems Operational' : 'Intelligent Cloud Services Status - Service Under Maintainance';
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    console.log('##Error in get Components call');
                }
            });
        } catch (error) {
            console.log('error :: ' + JSON.stringify(error));
        }

    }

    handleExpandCollapse(event) {
        let serviceId = event.currentTarget.dataset.id;
        let services = [];
        for(let item in this.bannerOutage.services){
            let service = this.bannerOutage.services[item];
            if(service.id == serviceId){
                service.expanded = !service.expanded;
            }
            services.push(service);
        }
        this.bannerOutage.services = services;
    }
}