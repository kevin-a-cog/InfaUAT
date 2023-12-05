/*
* Name         : HelpIdeasLandingWrapper
* Author       : Deeksha Shetty
* Created Date : January 11 2022
* Description  : This Component displays Idea List Page. Parent Component of helpIdeasLanding

Change History
**********************************************************************************************************************************
Modified By         Date                Jira No.     Description                             Tag
Deeksha Shetty      22 Feb,2020         I2RT-5541    Incorrect list of Ideas are displayed when Ideas are filtered based on 'Status' and 'Product'

*********************************************************************************************************************************
10/02/2022 I2RT- Initial version. N/A
Utkarsh Jain     20-SEPT-2022  I2RT-7026     Bringing quick links in the blue banner for 
                                             all the product community detail page            2

Prashanth Bhat      25 OCT 2023         I2RT-9228    Pagination                               3             
*/

import { LightningElement, wire, track } from 'lwc';
import communityId from '@salesforce/community/Id';
import CommunityURL from '@salesforce/label/c.IN_CommunityName';
import userId from '@salesforce/user/Id';
import fetchFilterValues from '@salesforce/apex/helpInternalIdeaDetails.fetchFilterValues';
import fetchFilterAfterTabSwitch from '@salesforce/apex/helpInternalIdeaDetails.fetchFilterAfterTabSwitch';
import recommendedIdeasDisplay from '@salesforce/apex/helpIdeasController.recommendedIdeasDisplay';
import IdeasLandingDisplay from '@salesforce/apex/helpIdeasController.IdeasLandingDisplay';
import sortbyFilterIdeas from '@salesforce/apex/helpIdeasController.sortbyFilterIdeas';
import getUserType from '@salesforce/apex/helpIdeasController.getUserType';
import { CurrentPageReference } from 'lightning/navigation';

export default class HelpIdeasLandingWrapper extends LightningElement {

    firstFilterlist;
    @track selectedFiltersParent = [];
    @track selectedFiltersChild = [];
    @track filteredRecordsChild = [];
    @track filteredRecords = [];
    @track product = [];
    @track currentPage;
    @track recordPerPage;
    @track totalPages;
    @track showViewMore = false;
    @track selectedFilters = false;
    // Tag 2 start
    @track productName = '';
    // Tag 2 end
    searchval = '';
    searchRecords;
    searchedList = [];
    sortByList = [];

    selectedSortFilter = 'Latest';
    manipulatedArr;
    @track allideasList = [];  //Original
    searchInput;
    @track selectedTab = 2;
    @track noSearchResult = false;
    showIdeaModal;
    sortlandingvalue; //main ideas filter on landing
    sortIdeasOnOrder;  //idea filter based on latest/old
    currentUserType;
    isGuestUser = false;
    categoriesFilter;
    finalFilter;
    firstFilterNoDraft;
    finalManipulatedArray;
    sessionStorageOptionToken;

    @track selectedIdeaFilters = {};
    @track originalArray = [];
    @track showFilters = true;

    @track showPagination = false;
    @track syncToChild = false;

    get options() {
        return [
            { label: 'Latest', value: 'Latest' },
            { label: 'Oldest', value: 'Oldest' },
        ];
    }


    currentPageReference = null;
    urlStateParameters = null;
    /* Params from Url */
    urlactivetab = null;

    connectedCallback() {
        if (userId == undefined) {
            this.sessionStorageOptionToken = sessionStorage.getItem('coveoTokenAnonymous');
        }
        else {
            this.sessionStorageOptionToken = sessionStorage.getItem('coveoTokenAuthenticated');
        }
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        // Tag 2 start
        this.urlactivetab = this.urlStateParameters.active || null;
        if (this.urlactivetab) {
            this.selectedTab = this.urlactivetab;
        }
        this.productName = this.urlStateParameters.productname || '';
        if (this.productName) {
            this.productName = this.productName;
        }
        // Tag 2 end
    }


    //wire that fetches First Filters and second filters
    @wire(fetchFilterValues)
    IdeaWiring(result) {
        if (result.data) {

            this.firstFilterlist = result.data.statusFilter.map(item => {
                let idea = {};
                idea.label = item;
                idea.value = item;
                return idea;
            });

            this.firstFilterNoDraft = result.data.statusWithNoDraft.map(item => {
                let idea = {};
                idea.label = item;
                idea.value = item;
                return idea;
            });


            this.categoriesFilter = result.data.categoriesFilter.map(item => {
                let idea = {};
                idea.label = item;
                idea.value = item;
                return idea;
            });

            this.getUserType();

        }
        else if (result.error) {
            console.log(JSON.stringify(result.error));
        }
    }


    getUserType() {
        if (userId === undefined || userId === 'undefined' || !userId) {
            this.currentUserType = 'Guest';
            this.isGuestUser = true;
        }
        else {
            getUserType({ userId: userId })
                .then((result) => {
                    if (result) {
                        this.currentUserType = result;
                        if (this.currentUserType == 'Guest') this.isGuestUser = true;
                    }
                })
                .catch((error) => {
                    console.log(error.body);
                });
        }

    }


    handleActive(event) {
        this.selectedSortFilter = 'Latest';
        this.selectedTab = event.target.value;

        if (this.selectedTab == 1) {
            this.handleClearAll();
            this.sortlandingvalue = 'myideas';
            this.showlandingIdeaDetails();

        } else if (this.selectedTab == 2) {
            this.handleClearAll();
            this.sortlandingvalue = 'allIdeas';
            this.showlandingIdeaDetails();
        }
        else if (this.selectedTab == 3) {
            this.handleClearAll();
            recommendedIdeasDisplay({ networkId: communityId, token: this.sessionStorageOptionToken })
                .then((data) => {
                    this.allideasList = data;
                    this.originalArray = JSON.parse(JSON.stringify(this.allideasList));
                    this.firstPage(this.originalArray);
                })
                .catch((error) => {
                    console.log("recommended Ideas Error => " + JSON.stringify(error));
                });
        }
        this.template.querySelector('c-help-ideas-landing').clearAll();
        this.getFilterData();
    }

    getFilterData() {
        this.firstFilterlist = [];
        this.firstFilterNoDraft = [];
        this.categoriesFilter = [];
        fetchFilterAfterTabSwitch()
            .then((data) => {
                if (data) {
                    this.firstFilterlist = data.statusFilter.map(item => {
                        let idea = {};
                        idea.label = item;
                        idea.value = item;
                        return idea;
                    });

                    this.firstFilterNoDraft = data.statusWithNoDraft.map(item => {
                        let idea = {};
                        idea.label = item;
                        idea.value = item;
                        return idea;
                    });

                    this.categoriesFilter = data.categoriesFilter.map(item => {
                        let idea = {};
                        idea.label = item;
                        idea.value = item;
                        return idea;
                    });

                    this.getUserType();
                }

            })
            .catch((error) => {
                console.log("Ideas Filter Error => " + JSON.stringify(error));
            });
    }

    showlandingIdeaDetails() {
        IdeasLandingDisplay({ networkId: communityId, userId: userId, sortvalue: this.sortlandingvalue })
            .then((data) => {
                this.allideasList = data;
                this.originalArray = JSON.parse(JSON.stringify(this.allideasList));
                // Tag 2 start
                let ev = {
                    detail : this.selectedFilters,
                  };
                  this.handleSecondFilterChange(ev);
                // this.firstPage(this.originalArray);
            })
            // Tag 2 end
            .catch((error) => {
                console.log("Ideas Error => " + JSON.stringify(error));
            });
    }



    firstPage(result) {
        this.currentPage = 1;
        this.recordPerPage = 9;
        this.totalPages = 1;
        this.totalPages = Math.ceil(result.length / this.recordPerPage);
        this.finalManipulatedArray = result;
        this.manipulatedArr = result.slice(0, this.recordPerPage);
        //Tag - 3 start
        this.showPagination = false;
        if (this.totalPages > 1) {
            this.showPagination = true;
               if(this.syncToChild == true){
                  this.template.querySelector('c-help-pagination').syncTotalPageOnChange(this.totalPages); 
               }
               this.syncToChild = true;
        }
        this.paginateRecords(); 
        //Tag - 3 end
    }

    //Tag 03 Start
    onPageRequest(event) {
        this.currentPage = event.detail;
        this.paginateRecords();
      }
  
    paginateRecords(){
        const start = (this.currentPage - 1) * this.recordPerPage;
        const end = start + this.recordPerPage;
        this.manipulatedArr = this.finalManipulatedArray.slice(start,end);
    }
      //Tag 03 End

    handleClearAll() {
        this.selectedSortFilter = 'Latest';
        let finalArrayAfterSearch = this.globalsearchIdeas(this.searchInput, this.originalArray);
        this.firstPage(finalArrayAfterSearch);
        this.selectedIdeaFilters = {};
        // Tag 2 start
        if(this.selectedFilters.length > 0){
            this.selectedFilters = [];
            this.selectedFilters = undefined;
        }else{
            if(this.selectedTab == 2){
                if(this.selectedFilters == undefined || !this.selectedFilters){
                    if(this.productName != ''){
                        this.selectedFilters = [...new Set([this.productName])];
                    }
                }
            }
        }
        // Tag 2 end
    }

    globalSortIdeas(ArrayToSort, SortOrder) {
        if (SortOrder == 'Oldest') {
            ArrayToSort.sort((a, b) => new Date(a.stringdate) - new Date(b.stringdate));
        }
        else if (SortOrder == 'Latest') {
            ArrayToSort.sort((a, b) => new Date(b.stringdate) - new Date(a.stringdate));

        }
        return ArrayToSort;
        // sort and  return array
    }

    // Start 



    getFilteredIdea(filterList, ideasToFilter) {
        let ideasAfterfilter = [];
        if (filterList.parentFilter || filterList.childFilter) {
            ideasToFilter.forEach(element => {
                if (element.Status && filterList.parentFilter && filterList.childFilter) {
                    if (filterList.parentFilter.includes(element.Status)) {
                        if (element.Category.includes(';')) {
                            let commasval = element.Category.replaceAll(";", ",");
                            let catarr = commasval.split(',');
                            let boolval = filterList.childFilter.some(item => catarr.includes(item));
                            if (boolval == true) {
                                ideasAfterfilter.push(element);
                            }
                        }
                        else {

                            if (filterList.childFilter.includes(element.Category)) {
                                ideasAfterfilter.push(element);
                            }

                        }

                    }
                }

                else if (element.Status && filterList.parentFilter) {
                    if (filterList.parentFilter.includes(element.Status)) {
                        ideasAfterfilter.push(element);
                    }
                }
                else if (element.Category && filterList.childFilter) {
                    if (element.Category.includes(';')) {
                        let commasval = element.Category.replaceAll(";", ",");
                        let catarr = commasval.split(',');
                        let boolval = filterList.childFilter.some(item => catarr.includes(item));
                        if (boolval == true) {
                            ideasAfterfilter.push(element);
                        }
                    }
                    else {

                        if (filterList.childFilter.includes(element.Category)) {
                            ideasAfterfilter.push(element);
                        }

                    }
                }
            });

        }
        else {
            ideasAfterfilter = JSON.parse(JSON.stringify(ideasToFilter));
        }

        return ideasAfterfilter;
    }


    handleFirstFilter(event) {
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


    //handle selected filters on the second Filter Box 
    handleSecondFilterChange(event) {
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

    handleSortedIdeas() {
        sortbyFilterIdeas({
            networkId: communityId, userId: userId, sortFilter: this.selectedSortFilter,
            sortIdeasVal: this.sortIdeasOnOrder
        })
            .then((data) => {
                this.allideasList = data.map(item => {
                    let idea = {};
                    let string = item.title;
                    let length = 70;
                    let trimmedString = string.substring(0, length);
                    idea.Name = trimmedString;
                    idea.Id = item.ideaId;
                    idea.Status = item.Status;
                    idea.Category = item.Category;
                    idea.createddate = new Date(item.CreatedDate);
                    idea.upvoteCount = item.upvoteCount;
                    // string = item.Body;
                    // length = 150;
                    // trimmedString = string.substring(0, length) + '....';
                    idea.Description = item.Body;
                    idea.Link = CommunityURL + "ideadetail?id=" + item.ideaId;
                    return idea;
                });
                this.originalArray = JSON.parse(JSON.stringify(this.allideasList));
                this.firstPage(this.originalArray);
            })
            .catch((error) => {
                console.log("getAllIdeas Error => " + JSON.stringify(error));
            });
    }



    searchIdeas(event) {
        this.searchInput = event.target.value;
        let finalsortideas = this.globalSortIdeas(this.originalArray, this.selectedSortFilter);
        let finalFilterArray = this.getFilteredIdea(this.selectedIdeaFilters, finalsortideas);
        let finalArrayAfterSearch = this.globalsearchIdeas(this.searchInput, finalFilterArray);
        this.firstPage(finalArrayAfterSearch);
        if (this.searchInput == '') this.noSearchResult = false;
    }

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

    handleCreateIdea() {
        if (this.currentUserType != 'Guest'){
            this.showIdeaModal = true;
            /** START-- adobe analytics */
            try {
               util.trackButtonClick('Create - New Idea - Form Started');
           }
           catch (ex) {
               console.error(ex.message);
           }
           /** END-- adobe analytics*/
        }

    }

    closeIdeaModal(event) {
        if (event.detail) this.showIdeaModal = false;

    }
    handleShowFilters(){
        this.showFilters = !this.showFilters;
      } 
}