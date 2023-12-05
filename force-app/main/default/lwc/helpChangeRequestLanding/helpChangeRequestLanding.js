/*
* Name : HelpChangeRequestLanding
* Author : Deeksha Shetty
* Created Date : Jan 31,2022
* Description : This Component displays all CRS and My CRS
Change History
**************************************************************************************************************************
Modified By            Date            Jira No.            Description                                               Tag
**************************************************************************************************************************
Deeksha Shetty         10-FEB-2021     NA                   Initial version.                                          NA
Utkarsh Jain           21-JUN-2022     I2RT-6504            CRT Landing Page                                          NA
Utkarsh Jain           26-OCT-2022     I2RT-6953            CR Request landing on Invalid page                        1
Utkarsh Jain           27-JAN-2023     I2RT-7343            CR: Change request tracking from the header menu 
                                                            should take the user to All CRs not My CRs                2
Prashanth Bhat         25-JUL-2023     I2RT-8649            Hiding filters on all the landing pages                   3
Deeksha Shetty         11-SEP-2023     I2RT-9054            Change request - enhancement                              4
Prashanth Bhat         26-OCT-2023     I2RT-9228            Pagination                                                5
*/


import { LightningElement, track, wire } from 'lwc';
import informaticaNetwork2 from "@salesforce/resourceUrl/InformaticaNetwork2";
import CRTsLandingDisplay from '@salesforce/apex/helpChangeRequestController.CRTsLandingDisplay';
import communityId from '@salesforce/community/Id';
import userId from '@salesforce/user/Id';
import getStatusPicklistValuesForCRs from '@salesforce/apex/helpInternalIdeaDetails.getStatusPicklistValuesForCRs';
import sortbyFilterCRTs from '@salesforce/apex/helpChangeRequestController.sortbyFilterCRTs';
import getSearchedCRs from '@salesforce/apex/helpChangeRequestController.getSearchedCRs';
import getSupportAccNamesCoveo from '@salesforce/apex/helpChangeRequestController.getSupportAccNamesCoveo';

import {
    publish, subscribe,
    unsubscribe,
    MessageContext
} from "lightning/messageService";
import SESSIONID_CHANNEL from "@salesforce/messageChannel/sessionstorage__c";
// Tag 2 - Start
import { CurrentPageReference } from 'lightning/navigation';
// Tag 2 - End

export default class HelpChangeRequestLanding extends LightningElement {
    crtLogo = informaticaNetwork2 + "/crIcon.jpg";
    helptext = informaticaNetwork2 + "/helptext.png";

    firstFilterlist;
    secondFilterList;
    usrId = userId;

    @track selectedFiltersParent = [];
    @track selectedFiltersChild = [];
    @track filteredRecordsChild = [];
    @track filteredRecords = [];
    @track product = [];
    @track currentPage;
    @track recordPerPage;
    @track totalPages;
    @track selectedFilters = false;

    searchval = '';
    searchRecords;
    searchedList = [];
    sortByList = [];

    selectedSortFilter = 'Latest';
    @track manipulatedArr;
    @track allIdeasList = [];
    searchInput;
    // Tag 2 - Start
    @track selectedTab = 2;
    // Tag 2 - End
    @track noSearchResult = false;
    showIdeaModal;
    crtpopup;
    @track searchResultUrl;
    searchedResult;

    sortlandingvalue;
    sortIdeasOnOrder;

    @track subscription = null;
    @track token = null;

    //Tag - 4 start
    finalFilter;
    finalManipulatedArray;
    @track selectedIdeaFilters = {};
    @track originalArray = [];
    @track showFilters = true;
    supportAccIdNameMap;
    showSupportAccFilter = false;
    hideSupportAccFilter = false;
    @track hasRendered = false;
    //Tag - 4 End
    //Tag - 5 start
    @track showPagination = false;
    @track syncToChild = false;
    //Tag - 5 End


    connectedCallback() {
        this.handleSubscribe();
        const isChild = {
            CRTLoaded: true,
            sessiontoken: null
        };
        publish(this.messageContext, SESSIONID_CHANNEL, isChild);
        this.getFilters();
    }

    //Tag - 4 - for rendering My support accountCRS based on filters

    renderedCallback() {
        if (this.hasRendered && this.showSupportAccFilter) {
            return;
        }
        this.hasRendered = true;
        if (this.token) this.getSupportAccFilters();
    }


    handleSubscribe() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(
            this.messageContext,
            SESSIONID_CHANNEL,
            (message) => {
                this.handleMessage(message);
            }
        );
    }

    handleMessage(message) {
        this.receivedMessage = message ? message : "no message";
        if (this.receivedMessage.sessiontoken) {
            this.token = this.receivedMessage.sessiontoken;
        }
    }

    disconnectedCallback() {
        this.handleUnsubscribe();
    }

    handleUnsubscribe() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    @wire(MessageContext)
    messageContext;

    get options() {
        return [
            { label: 'Latest', value: 'Latest' },
            { label: 'Oldest', value: 'Oldest' },
        ];
    }

    // Tag 2 - Start
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }


    setParametersBasedOnUrl() {
        this.urlactivetab = this.urlStateParameters.active || null;
        if (this.urlactivetab) {
            if (this.urlactivetab == 1 || this.urlactivetab == 2 || this.urlactivetab == 3) {
                this.selectedTab = this.urlactivetab;
            } else {
                this.selectedTab = 2;
            }
        }
    }
    // Tag 2 - End

    getFilters() {
        getStatusPicklistValuesForCRs()
            .then((data) => {
                let firstFilter = data;
                this.firstFilterlist = firstFilter.map(item => {
                    let idea = {};
                    idea.label = item;
                    idea.value = item;
                    return idea;
                });
            })
            .catch((error) => {
                console.error(JSON.stringify(error.body));
            });
    }

    //
    // getSupportAccFilters() {
    //     getSupportAccountNames()
    //         .then((data) => {
    //             if (data) {
    //                 this.showSupportAccFilter = true;
    //                 this.secondFilterList = data.map(item => {
    //                     let idea = {};
    //                     idea.label = item.Name;
    //                     idea.value = item.Id;
    //                     return idea;
    //                 });
    //                 this.supportAccIdNameMap = data[0].SupportAccIdNameMap;
    //                 console.log('Support Account Map Values =>', this.supportAccIdNameMap)
    //             }
    //         })
    //         .catch((error) => {
    //             this.hideSupportAccFilter = true;
    //             console.error("Second Filters Error => " + JSON.stringify(error.body));
    //         });

    // }


    //Tag - 4 - start - Method to fetch all the support Names. Dynamic filters for support names that user is part of

    getSupportAccFilters() {
        getSupportAccNamesCoveo({ token: this.token })
            .then((data) => {
                if (data) {
                    console.log('DATA from coveo =>' + JSON.stringify(data))
                    if (data[0].NoData) this.hideSupportAccFilter = true;
                    else {
                        this.showSupportAccFilter = true;
                        this.hideSupportAccFilter = false;
                        this.secondFilterList = data.map(item => {
                            let idea = {};
                            idea.label = item.Name;
                            idea.value = item.Name;
                            return idea;
                        });

                    }


                }
            })
            .catch((error) => {
                this.showSupportAccFilter = false;
                console.error("Second Filters Error => " + JSON.stringify(error.body));
                this.hideSupportAccFilter = error.body.message.includes('Ending position out of bounds: -1') ? false : true;
            });

    }


    handleActive(event) {
        this.handleClearAll();
        this.selectedSortFilter = 'Latest';
        this.selectedTab = event.target.value;
        console.log('Tab Change>>' + JSON.stringify(this.selectedTab))

        if (this.selectedTab == 1) {
            this.handleClearAll();
            this.getFilters();
            this.getSupportAccFilters();
            this.sortlandingvalue = 'myideas';
            this.showlandingCRTDetails();

        } else if (this.selectedTab == 2) {
            this.handleClearAll();
            this.getFilters();
            this.getSupportAccFilters();
            this.sortlandingvalue = 'allIdeas';
            this.showlandingCRTDetails();
        }
        else if (this.selectedTab == 3) {
            this.handleClearAll();
            this.getFilters();
            this.getSupportAccFilters();
            this.sortlandingvalue = 'mySupportAccountideas';
            this.showlandingCRTDetails();
        }
        this.template.querySelector('c-help-ideas-landing').clearAll();
        this.getFilters();
        this.getSupportAccFilters();

    }


    showlandingCRTDetails() {
        console.log('token>>>>' + this.token)
        CRTsLandingDisplay({ networkId: communityId, userId: userId, sortvalue: this.sortlandingvalue, token: this.token })
            .then((data) => {
                if (data) {
                    console.log('DATA length>>>' + JSON.stringify(data.length))
                    console.log('DATA>>>' + JSON.stringify(data))
                    this.allideasList = data;
                    this.originalArray = JSON.parse(JSON.stringify(this.allideasList));
                    this.firstPage(this.originalArray);

                }
            })
            .catch((error) => {
                console.error("Ideas Error => " + JSON.stringify(error.body));
            });
    }

    firstPage(result) {
        this.currentPage = 1;
        this.recordPerPage = 9;
        this.totalPages = 1;
        this.totalPages = Math.ceil(result.length / this.recordPerPage);
        this.finalManipulatedArray = result;
        this.manipulatedArr = result.slice(0, this.recordPerPage);
        //Tag - 5 start
        this.showPagination = false;
        if (this.totalPages > 1) {
            this.showPagination = true;
               if(this.syncToChild == true){
                  this.template.querySelector('c-help-pagination').syncTotalPageOnChange(this.totalPages); 
               }
               this.syncToChild = true;
        }
        this.paginateRecords(); 
        //Tag - 5 end
    }

    //Tag 05 Start
    onPageRequest(event) {
      this.currentPage = event.detail;
      this.paginateRecords();
    }

    paginateRecords(){
      const start = (this.currentPage - 1) * this.recordPerPage;
      const end = start + this.recordPerPage;
      this.manipulatedArr = this.finalManipulatedArray.slice(start,end);
    }
    //Tag 05 End

    handleClearAll() {
        this.selectedSortFilter = 'Latest';
        let finalArrayAfterSearch = this.globalsearchIdeas(this.searchInput, this.originalArray);
        this.firstPage(finalArrayAfterSearch);
        this.selectedIdeaFilters = {};
        this.selectedFilters = [];
        this.selectedFilters = false;

    }

    //Tag - 4  - Method to sort Ideas 

    globalSortIdeas(ArrayToSort, SortOrder) {

        if (SortOrder == 'Oldest') {
            const compareDates = (a, b) => {
                const dateA = new Date(a.createddate);
                const dateB = new Date(b.createddate);
                return dateA - dateB;
            };
            ArrayToSort.sort(compareDates);
        }
        else if (SortOrder == 'Latest') {
            const compareDates = (a, b) => {
                const dateA = new Date(a.createddate);
                const dateB = new Date(b.createddate);
                return dateB - dateA;
            };
            ArrayToSort.sort(compareDates);
        }
        console.log('ArrayToSort>' + JSON.stringify(ArrayToSort));
        return ArrayToSort;
        // sort and  return array
    }

    //Tag - 4  - Method to Filter Ideas based on filter

    getFilteredIdea(filterList, ideasToFilter) {
        console.log('FilterList>>' + JSON.stringify(filterList))
        console.log('ideasToFilter>>' + JSON.stringify(filterList))
        let ideasAfterfilter = [];
        if (filterList.parentFilter || filterList.childFilter) {
            ideasToFilter.forEach(element => {
                if (element.Status && filterList.parentFilter && filterList.childFilter) {
                    if (filterList.parentFilter.includes(element.Status) && filterList.childFilter.includes(element.SupportAccountName)) {
                        ideasAfterfilter.push(element);
                    }
                }

                else if (element.Status && filterList.parentFilter) {
                    if (filterList.parentFilter.includes(element.Status)) {
                        ideasAfterfilter.push(element);
                    }
                }
                else if (element.SupportAccountName && filterList.childFilter) {
                    if (filterList.childFilter.includes(element.SupportAccountName)) {
                        ideasAfterfilter.push(element);
                    }
                }
            });

        }
        else {
            ideasAfterfilter = JSON.parse(JSON.stringify(ideasToFilter));
        }

        console.log('Idea Data post filter > ' + JSON.stringify(ideasAfterfilter))

        return ideasAfterfilter;
    }


    handleFirstFilter(event) {
        console.log('FIRST FILTERS>>>' + JSON.stringify(event.detail));
        if (event.detail.length > 0) {
            this.selectedIdeaFilters.parentFilter = event.detail;
            this.selectedFilters = this.selectedIdeaFilters.childFilter ? [...new Set(this.selectedIdeaFilters.parentFilter.concat(this.selectedIdeaFilters.childFilter)),] : this.selectedIdeaFilters.parentFilter;

        }
        else {
            this.selectedIdeaFilters.parentFilter = null;
            this.selectedFilters = this.selectedIdeaFilters.childFilter ? this.selectedIdeaFilters.childFilter : false;
        }
        let finalsortideas = this.globalSortIdeas(this.originalArray, this.selectedSortFilter);
        let finalArrayAfterSearch = this.globalsearchIdeas(this.searchInput, finalsortideas);
        let finalFilterArray = this.getFilteredIdea(this.selectedIdeaFilters, finalArrayAfterSearch);
        this.firstPage(finalFilterArray);
    }


    handleSecondFilterChange(event) {
        console.log('SECOND FILTERS>>>' + JSON.stringify(event.detail));
        if (event.detail.length > 0) {
            this.selectedIdeaFilters.childFilter = event.detail;
            this.selectedFilters = this.selectedIdeaFilters.parentFilter ? [...new Set(this.selectedIdeaFilters.childFilter.concat(this.selectedIdeaFilters.parentFilter)),] : this.selectedIdeaFilters.childFilter;
        }
        else {
            this.selectedIdeaFilters.childFilter = null;
            this.selectedFilters = this.selectedIdeaFilters.parentFilter ? this.selectedIdeaFilters.parentFilter : false;
        }
        let finalsortideas = this.globalSortIdeas(this.originalArray, this.selectedSortFilter);
        let finalArrayAfterSearch = this.globalsearchIdeas(this.searchInput, finalsortideas);
        let finalFilterArray = this.getFilteredIdea(this.selectedIdeaFilters, finalArrayAfterSearch);
        this.firstPage(finalFilterArray);

    }


    handleclearselectfilter(event) {
        if (this.selectedIdeaFilters.parentFilter) {
            const elementIndex = this.selectedIdeaFilters.parentFilter.indexOf(event.detail);
            if (elementIndex > -1) {
                this.selectedIdeaFilters.parentFilter.splice(elementIndex, 1);
                let ev = {
                    detail: [...this.selectedIdeaFilters.parentFilter],
                };
                this.handleFirstFilter(ev);
            }

        }

        if (this.selectedIdeaFilters.childFilter) {
            const elementIndexchild = this.selectedIdeaFilters.childFilter.indexOf(event.detail);
            if (elementIndexchild > -1) {
                this.selectedIdeaFilters.childFilter.splice(elementIndexchild, 1);
                let ev = {
                    detail: [...this.selectedIdeaFilters.childFilter],
                };
                this.handleSecondFilterChange(ev);
            }
        }

    }

    //sorting based on SORT BY filter
    handlesortfilter(event) {
        this.selectedSortFilter = event.detail.value;
        let finalFilterArray = this.getFilteredIdea(this.selectedIdeaFilters, this.originalArray);
        let finalArrayAfterSearch = this.globalsearchIdeas(this.searchInput, finalFilterArray);
        let finalsortideas = this.globalSortIdeas(finalArrayAfterSearch, this.selectedSortFilter);
        this.firstPage(finalsortideas);
    }

    searchCrs(event) {
        this.searchInput = event.target.value;
        console.log('length of selected filters=' + this.selectedFilters.length)
        console.log('this.searchInput=' + this.searchInput);
        console.log('this.selectedSortFilter=' + this.selectedSortFilter);

        if (this.selectedFilters.length == undefined && this.searchInput != '') {
            console.log('Search block 1');
            getSearchedCRs({ searchTerm: this.searchInput, networkId: communityId })
                .then((data) => {
                    if (data) {
                        this.searchedResult = data;
                        this.manipulatedArr = JSON.parse(JSON.stringify(this.searchedResult));
                        this.firstPage(this.manipulatedArr);
                    }
                })
                .catch((error) => {
                    console.error("Ideas post search Error => " + JSON.stringify(error.body));
                });

        }
        else {
            console.log('Search block 2');
            let finalsortideas = this.globalSortIdeas(this.originalArray, this.selectedSortFilter);
            let finalFilterArray = this.getFilteredIdea(this.selectedIdeaFilters, finalsortideas);
            let finalArrayAfterSearch = this.globalsearchIdeas(this.searchInput, finalFilterArray);
            this.firstPage(finalArrayAfterSearch);

        }

        if (this.searchInput == '') this.noSearchResult = false;

    }

    //Tag - 4  - Method to search Ideas 
    globalsearchIdeas(searchKey, arrayToSearch) {
        let arrayAfterSearch = [];
        if (searchKey) {
            arrayAfterSearch = arrayToSearch.filter(word => { return (word.Name.toLowerCase()).includes(searchKey.toLowerCase()) })
            if (arrayAfterSearch.length == 0) this.noSearchResult = true;
            else this.noSearchResult = false;
            //this.firstPage(this.manipulatedArr);
            //filter for filtered records
        }
        else {
            arrayAfterSearch = JSON.parse(JSON.stringify(arrayToSearch));

        }
        return arrayAfterSearch;
    }
    //Tag - 4 - end

    //tag 3
    handleShowFilters() {
        this.showFilters = !this.showFilters;
    }

}