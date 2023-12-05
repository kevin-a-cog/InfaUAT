/*
* Name			:	HelpHotfixDownloads
* Author		:	Utkarsh Jain
* Created Date	: 	23/02/2023
* Description	:	This LWC is used to show all hotfix Downloads.

Change History
******************************************************************************************************************
Modified By			Date			    Jira No.		 Description				                        Tag
******************************************************************************************************************
Utkarsh Jain        23-Feb-2023        I2RT-7759        Hotfix download search is not consistent.          1
*/
import { LightningElement, wire, track } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { loadStyle } from 'lightning/platformResourceLoader';
import DOWNLOAD_OBJECT from '@salesforce/schema/Download__c';
import OPERATING_SYSTEM from '@salesforce/schema/Download__c.Operating_System__c';
import PROCESSOR from '@salesforce/schema/Download__c.Processor__c';
import PRODUCT from '@salesforce/schema/Download__c.Product__c';
import getDownloadsList from "@salesforce/apex/HelpHotfixController.getDownloads";
import informaticaNetwork from '@salesforce/resourceUrl/informaticaNetwork';
import getMetadataRecord from '@salesforce/apex/HelpHotfixController.getMetadataRecordFromCustomLabel';
import getSupportAccWithRWAccess from '@salesforce/apex/HelpMyCasesController.getSupportAccWithRWAccess';
import HotFixDownloadErrMsg from '@salesforce/label/c.HotFixDownloadErrMsg';


export default class HelpHotfixDownloads extends LightningElement {

    @track showSpinner = false;
    @track osLst = [];
    @track processorLst = [];
    @track productLst = [];
    @track currentReleases = [];
    @track previousReleases = [];
    @track releaseType = 'Current';
    @track selectedfilters = [];
    @track selectedFiltersMap = new Map();
    @track selectedProduct;
    @track selectedOS;
    @track selectedProcessor;
    @track showInformation = true;
    @track tabChanged = false;
    @track viewMoreBtnClicked = false;
    @track showViewMoreBtnCurrent = true;
    @track showViewMoreBtnPrevious = true;
    @track searchFilterApplied = false;
    @track clearAllFilters = false;
    @track dcUsername;
    @track dcPassword;
    @track searchTerm;
    @track sortList = [{ label: 'Latest', value: 'Latest' },
    { label: 'Oldest', value: 'Oldest' }];
    @track selectedSort = 'Latest';
    showHotfixDlds = true;
    strErrorMessage = HotFixDownloadErrMsg;

    get showClearAllFilters() {
        return (this.selectedFiltersMap.size > 0);
    }
    get getInformationIcon() {
        return this.showInformation ? "utility:dash" : "utility:add";
    }
    get appliedFilters() {
        let filters = [];
        this.selectedFiltersMap.forEach((value, key) => {
            filters.push({ key: key, value: value });
        });
        return filters;
    }

    get showViewMoreBtn() {
        if (this.releaseType == 'Current') {
            return this.showViewMoreBtnCurrent;
        } else {
            return this.showViewMoreBtnPrevious;
        }
    }

    get getReleases() {
        return this.releaseType == 'Current' ? this.currentReleases : this.previousReleases;
    }

    @wire(getObjectInfo, {
        objectApiName: DOWNLOAD_OBJECT
    }) downloadObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$downloadObjectInfo.data.defaultRecordTypeId',
        fieldApiName: PRODUCT
    }) getProducts({ error, data }) {
        if (error) {
            console.log('error>>>', {
                ...error
            });
        } else if (data) {
            this.productLst = [...data.values];
            console.log('this.productLst' + ':' + JSON.stringify(this.productLst));
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$downloadObjectInfo.data.defaultRecordTypeId',
        fieldApiName: OPERATING_SYSTEM
    }) getOperatingSystem({ error, data }) {
        if (error) {
            console.log('error>>>', {
                ...error
            });
        } else if (data) {
            this.osLst = [...data.values];
            console.log('this.osLst' + ':' + JSON.stringify(this.osLst));
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$downloadObjectInfo.data.defaultRecordTypeId',
        fieldApiName: PROCESSOR
    }) getProcessor({ error, data }) {
        if (error) {
            console.log('error>>>', {
                ...error
            });
        } else if (data) {
            this.processorLst = [...data.values];
            console.log('this.processorLst' + ':' + JSON.stringify(this.processorLst));
        }
    }

    handleRemove(event) {
        this.showSpinner = true;
        let key = event.currentTarget.getAttribute('data-id');
        let filter = event.currentTarget.getAttribute('data-value');
        let removeEvent = event.currentTarget.getAttribute('data-name');
        console.log('removeEvent :: ' + removeEvent);
        switch (removeEvent) {
            case 'Remove':
                let selectedFilters = this.selectedFiltersMap.get(key);
                if (selectedFilters != undefined && selectedFilters.includes(filter)) {
                    selectedFilters.splice(selectedFilters.indexOf(filter), 1);
                }
                if (selectedFilters.length == 0) {
                    this.selectedFiltersMap.delete(key);
                } else {
                    this.selectedFiltersMap.set(key, selectedFilters);
                }
                let filterCmp = '[data-name="' + key + '"]';
                let multiSelectPicklist = this.template.querySelector(filterCmp);
                if (multiSelectPicklist) {
                    multiSelectPicklist.clearfilter(filter);
                }
                break;
            case 'RemoveAll':
                this.selectedFiltersMap.forEach((value, key) => {
                    let filterCmp = '[data-name="' + key + '"]';
                    let multiSelectPicklist = this.template.querySelector(filterCmp);
                    if (multiSelectPicklist) {
                        multiSelectPicklist.clear();
                    }
                });
                this.selectedFiltersMap.clear();
                this.selectedFiltersMap = new Map();
                this.searchFilterApplied = false;
                this.clearAllFilters = true;
                break;
            default:
                break;
        }
        this.getDownloads();

    }

    handleInformationChange(event) {
        this.showInformation = !this.showInformation;
    }


    handleChange(event) {
        console.log('handleChange ::  ' + JSON.stringify(event.detail));
        let value = event.detail;
        this.searchFilterApplied = true;
        let filterName = event.currentTarget.getAttribute('data-name');
        console.log('filterName ::  ' + JSON.stringify(filterName));
        this.selectedFiltersMap.set(filterName, value);
        if (value.length == 0) {
            this.selectedFiltersMap.delete(filterName);
        }
        this.getDownloads();
        /* switch (filterName) {
            case 'product':
                this.applyFilter(filterName, value);
                break;
            case 'operatingSystem':
                this.applyFilter(filterName, value);
                break;
            case 'processor':
                this.applyFilter(filterName, value);
                break;
            default:
                break;
            
        } */

    }

    applyFilter(filterName, value) {

        /* if (this.selectedFiltersMap.has(filterName)) {
            let osFilter = this.selectedFiltersMap.get(filterName);
            if (osFilter != undefined && !osFilter.includes(value)) {
                this.selectedfilters.push(value);
                this.selectedFiltersMap.set(filterName, this.selectedfilters);
            }
        } else {
            this.selectedfilters = [];
            this.selectedfilters.push(value);
            this.selectedFiltersMap.set(filterName, this.selectedfilters);
        } */
        // this.getDownloads();
    }

    connectedCallback() {
        this.showSpinner = true;
        loadStyle(this, informaticaNetwork + '/css/hotfix_downloads.css');
        getMetadataRecord({ metadataName: 'Download_Center' }) //Get Accept Solution Message from Service Cloud Custom Metadata
            .then(result => {
                this.dcUsername = result.Download_Center_Username__c;
                this.dcPassword = result.Download_Center_Password__c;
            })
            .catch(error => {
                console.log('Metadata error ==> ' + error);
            })
        // this.getProducts();
        this.showHotfixDownloads();

    }

    showHotfixDownloads() {
        getSupportAccWithRWAccess()
            .then(result => {
                if (result.length > 0) {
                    this.showHotfixDlds = true;
                    this.getDownloads();
                }
                else {
                    this.showSpinner = false;
                    this.showHotfixDlds = false;
                }
            })
            .catch(error => {
                console.log('Metadata error ==> ' + error);
            })

    }

    getDownloads() {
        if (!this.clearAllFilters && !this.searchFilterApplied && !this.viewMoreBtnClicked && !this.tabChanged) {
            this.showSpinner = false;
            return;
        }
        let sortBy = (this.selectedSort == 'Latest') ? 'desc' : 'asc';
        let filterMap = JSON.stringify(Object.fromEntries(this.selectedFiltersMap));
        // Tag 1 Start
        let limit = 9;
        if (this.releaseType == 'Current' && !this.tabChanged && this.viewMoreBtnClicked) {
            limit = 9 + this.currentReleases.length;
        }
        if (this.releaseType == 'Previous' && !this.tabChanged && this.viewMoreBtnClicked) {
            limit = 9 + this.previousReleases.length;
        }
        getDownloadsList({ filters: filterMap, searchKey: this.searchTerm, sortBy: sortBy, releaseType: this.releaseType, limitSize: limit }).then(result => {
            if (this.releaseType == 'Current') {
                this.currentReleases = JSON.parse(JSON.stringify(result));
                if (limit > this.currentReleases.length) {
                    this.showViewMoreBtnCurrent = false;
                }else{
                    this.showViewMoreBtnCurrent = true;
                }
            }
            if (this.releaseType == 'Previous') {
                this.previousReleases = JSON.parse(JSON.stringify(result));
                if (limit > this.previousReleases.length) {
                    this.showViewMoreBtnPrevious = false;
                }else{
                    this.showViewMoreBtnPrevious = true;
                }
            }
            // Tag 1 End
            limit = 0;
            this.showSpinner = false;
            this.tabChanged = false;
            this.viewMoreBtnClicked = false;
        }).catch(error => {
            console.log('error : ' + JSON.stringify(error));
            this.showSpinner = false;
        })
    }


    handleClick(event) {
        let url = event.currentTarget.value;
        let action = event.target.dataset.name;
        let productName = event.target.dataset.product;
        let name = event.target.dataset.title;
        if (action == 'download' || action == 'relnotes' || action == 'EBFDownload') {
            let actionDict = {
                download: 'Hotfix Downloads',
                relnotes: 'Release Notes',
                EBFDownload: 'EBF Downloads'
            }
            /** START-- adobe analytics */
            try {
                util.trackButtonClick(actionDict[action] + " || " + name + " || " + productName);
            }
            catch (ex) {
                console.log(ex.message);
            }
            /** END-- adobe analytics*/
            window.open(url);
        }

        if (action == 'viewmore') {
            this.viewMoreBtnClicked = true;
            this.getDownloads();
        }
    }

    handleSort(event) {
        this.selectedSort = event.currentTarget.value;
        this.getDownloads();
    }

    handleSearchChange(event) {
        this.searchTerm = event.currentTarget.value;
        this.searchFilterApplied = true;
        if (this.searchTerm == '' || (this.searchTerm != undefined && this.searchTerm.length > 3))
            this.getDownloads();
    }

    handleTabChange(event) {
        if (this.releaseType != event.currentTarget.value); {
            this.releaseType = event.currentTarget.value;
            this.tabChanged = true;
            this.getDownloads();
        }

    }

}