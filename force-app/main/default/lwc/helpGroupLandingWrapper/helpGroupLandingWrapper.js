/*
 * Name			:	HelpGroupLandingWrapper
 * Author		:	
 * Created Date	: 	
 * Description	:	
 
 Change History
 **********************************************************************************************************
 Modified By		                  Date			     Jira No.		       Description							Tag
 **********************************************************************************************************
 Prashanth Bhat/Chetan Shetty		  19/10/2023		 I2RT-9228		     Pagination                01
 */
import { LightningElement, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import IN_StaticResource2 from "@salesforce/resourceUrl/InformaticaNetwork2";
import communityId from "@salesforce/community/Id";
import userId from "@salesforce/user/Id";
import isGuest from "@salesforce/user/isGuest";
import fetchFilterValues from "@salesforce/apex/helpGroupsController.fetchFilterValues";
import getGroupLandingDisplay from "@salesforce/apex/helpGroupsController.getGroupLandingDisplay";
import getsortbygroup from "@salesforce/apex/helpGroupsController.getsortbygroup";
import getUserType from "@salesforce/apex/helpIdeasController.getUserType";
import startausergroup from "@salesforce/apex/helpGroupsController.startausergroup";
import isinternaluser from "@salesforce/customPermission/User_Group_Admin";
import CommunityURL from "@salesforce/label/c.IN_CommunityName";
import { CurrentPageReference } from 'lightning/navigation';

export default class HelpGroupLandingWrapper extends NavigationMixin(
  LightningElement
) {
  @track firstFilterlist; 
  @track secondFilterList;
  grouplist;
  firstFiltersApplied;
  secondFiltersApplied;
  @track communityLogo = IN_StaticResource2 + "/collaborateicon.png";
  @track selectedFiltersParent = [];
  @track selectedFiltersChild = [];
  @track filteredRecordsChild = [];
  @track filteredRecords = [];
  @track currentPage;
  @track recordPerPage;
  @track totalPages;
  
  @track selectedFilters = false;
  @track noSearchResult = false;
  skipClearOnLoad = true;
  searchval = "";
  searchRecords;
  searchedList = [];
  sortByList = [];
  @track activeTab = 3;

  @track manipulatedArr;
  selectedSortFilter = "Ascending";
  @track allgroupList = []; //Original
  searchInput;
  sortgroupOnOrder;
  showGroupModal;
  isGuestUser = false;

  finalManipulatedArray;
  @track selectedIdeaFilters = {};
  @track originalArray = [];
  @track showFilters = true;
  @track showPagination = false;
  @track syncToChild = false;

  get options() {
    return [
      { label: "Ascending", value: "Ascending" },
      { label: "Descending", value: "Descending" },
    ];
  }

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
     if (currentPageReference) {
        this.urlStateParameters = currentPageReference.state;
        this.activeTab = this.urlStateParameters.active || 3;
     }
  }

  @wire(fetchFilterValues)
  GroupWiring(result) {
    if (result.data) {
      //adding below logic to hide Private Group filter for anonymous user.
      let firstFilter = result.data.typeFilter;
      let firstFilterlist = [];
      for (let item in firstFilter) {
        let group = {};
        if (isGuest && firstFilter[item] != 'Private') {
          group.label = firstFilter[item];
          group.value = firstFilter[item];
          group.disable = true;
          firstFilterlist.push(group);
          this.selectedFilters = [
            firstFilter[item]
          ];
        } else if (!isGuest) {
          group.label = firstFilter[item];
          group.value = firstFilter[item];
          firstFilterlist.push(group);
          this.skipClearOnLoad = false;
        }
      }
      this.firstFilterlist = firstFilterlist;
      this.getUserType();
    }
    else if (result.error) {
      console.log(JSON.stringify(result.error));
    }
  }



  connectedCallback() {
    startausergroup()
      .then((result) => {
        this.linkList = result;
      })
      .catch((error) => {
        console.error("This is the error ::: " + error);
      });
  }

  openLink() {
    /** START-- adobe analytics */
    try {
      util.trackButtonClick("Start a Group");
    } catch (ex) {
      console.error(ex.message);
    }
    /** END-- adobe analytics*/
    let startgroupurl = this.linkList.Lead_User_Group_Link__c;
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: startgroupurl,
      },
    });
  }

  getUserType() {
    if (userId == undefined || userId === "undefined" || !userId) {
      this.currentUserType = "Guest";
      this.isGuestUser = true;
    } else {
      getUserType({ userId: userId })
        .then((result) => {
          if (result) {
            this.currentUserType = result;
            if (this.currentUserType == "Guest") this.isGuestUser = true;
          }
        })
        .catch((error) => {
          console.log(error.body);
        });
    }
  }

  handleActive(event) {
    this.selectedSortFilter = "Ascending";
    this.selectedTab = event.target.value;
    if (this.selectedTab == 2) {
      if(!this.skipClearOnLoad) this.handleClearAll();
      this.sortlandingvalue = "mygroup";
      this.showGrouplLandingDetails();
    } else if (this.selectedTab == 3) {
      if(!this.skipClearOnLoad) this.handleClearAll();
      this.sortlandingvalue = "allgroup";
      this.showGrouplLandingDetails();
    }
    this.template.querySelector('c-help-groups-landing').clearAll();
    this.getFilters();
  }

  getFilters(){
    this.firstFilterlist = [];
    fetchFilterValues()
    .then((data) => {
      let firstFilterlist = [];
      let firstFilter = data.typeFilter;
      for (let item in firstFilter) {
        let group = {};
        if (isGuest && firstFilter[item] != 'Private') {
          group.label = firstFilter[item];
          group.value = firstFilter[item];
          group.disable = true;
          firstFilterlist.push(group);
          this.selectedFilters = [
            firstFilter[item]
          ];
        } else if (!isGuest) {
          group.label = firstFilter[item];
          group.value = firstFilter[item];
          firstFilterlist.push(group);
          this.skipClearOnLoad = false;
        }
      }
      this.firstFilterlist = firstFilterlist;
    })
    .catch((error) => {
      console.log(JSON.stringify(error));
    })
  }

  showGrouplLandingDetails() {
    getGroupLandingDisplay({
      networkId: communityId,
      userId: userId,
      sortvalue: this.sortlandingvalue,
    })
      .then((data) => {
        this.allgroupList = data;
        this.originalArray = JSON.parse(JSON.stringify(this.allgroupList));
        this.firstPage(this.originalArray);

      })
      .catch((error) => {
        console.log("Group Error => " + JSON.stringify(error));
      });
  }

  firstPage(result) {
    this.currentPage = 1;
    this.recordPerPage = 9;
    this.totalPages = 1;
    this.totalPages = Math.ceil(result.length / this.recordPerPage);  
    this.showPagination = false;
    this.finalManipulatedArray = result;
    this.manipulatedArr = result.slice(0, this.recordPerPage);
    //Tag 01 Start
    if (this.totalPages > 1) {
        this.showPagination = true;
        if(this.syncToChild == true){
          this.template.querySelector('c-help-pagination').syncTotalPageOnChange(this.totalPages); 
        }
        this.syncToChild = true;
    }
    this.paginateRecords(); 
     //Tag 01 End  
  }
  
  //Tag 01 Start
  onPageRequest(event) {
    this.currentPage = event.detail;
    this.paginateRecords();
  }

  paginateRecords(){
    const start = (this.currentPage - 1) * this.recordPerPage;
    const end = start + this.recordPerPage;
    this.manipulatedArr = this.finalManipulatedArray.slice(start,end);
  }
  //Tag 01 End

  //sorting based on SORT BY filter
  handlesortfilter(event) {
    this.selectedSortFilter = event.detail.value;
    let finalFilterArray = this.getFilteredGroup(this.selectedIdeaFilters, this.originalArray);
    let finalArrayAfterSearch = this.globalsearchGroups(this.searchInput, finalFilterArray);
    let finalsortideas = this.globalSortGroups(finalArrayAfterSearch, this.selectedSortFilter);
    this.firstPage(finalsortideas);
  }

  globalSortGroups(ArrayToSort, SortOrder) {
    if (SortOrder == 'Ascending') {
      ArrayToSort.sort();
    }
    else if (SortOrder == 'Descending') {
      ArrayToSort.reverse();
    }
    return ArrayToSort;
  }


  getFilteredGroup(filterList, groupsToFilter) {
    let groupsAfterfilter = [];
    if (filterList.parentFilter) {
      groupsToFilter.forEach(element => {

        if (element.CollaborationType && filterList.parentFilter) {
          if (filterList.parentFilter.includes(element.CollaborationType)) {
            groupsAfterfilter.push(element);
          }
        }
      });

    }
    else {
      groupsAfterfilter = JSON.parse(JSON.stringify(groupsToFilter));
    }

    return groupsAfterfilter;
  }

  handleFirstFilter(event) {
    this.selectedIdeaFilters = {};

    if (event.detail.length > 0) {
      this.selectedIdeaFilters.parentFilter = event.detail;
      this.selectedFilters = this.selectedIdeaFilters.parentFilter;
    }
    else {
      this.selectedIdeaFilters.parentFilter = null;
      this.selectedFilters = false;
    }
    let finalsortideas = this.globalSortGroups(this.originalArray, this.selectedSortFilter);
    let finalArrayAfterSearch = this.globalsearchGroups(this.searchInput, finalsortideas);
    let finalFilterArray = this.getFilteredGroup(this.selectedIdeaFilters, finalArrayAfterSearch);
    this.firstPage(finalFilterArray);
    
  }



  searchGroup(event) {
    this.searchInput = event.target.value;
    let finalsortideas = this.globalSortGroups(this.originalArray, this.selectedSortFilter);
    let finalFilterArray = this.getFilteredGroup(this.selectedIdeaFilters, finalsortideas);
    let finalArrayAfterSearch = this.globalsearchGroups(this.searchInput, finalFilterArray);
    this.firstPage(finalArrayAfterSearch);
    if (this.searchInput == '') this.noSearchResult = false;
  }

  globalsearchGroups(searchKey, arrayToSearch) {
    let arrayAfterSearch = [];
    if (searchKey) {
      arrayAfterSearch = arrayToSearch.filter(word => { return (word.Name.toLowerCase()).includes(searchKey.toLowerCase()) })
      if (arrayAfterSearch.length == 0) this.noSearchResult = true;
      else this.noSearchResult = false;
    }
    else {
      arrayAfterSearch = JSON.parse(JSON.stringify(arrayToSearch));

    }
    return arrayAfterSearch;
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
  }


  handleClearAll() {
    this.selectedSortFilter = "Ascending";
    let finalArrayAfterSearch = this.globalsearchGroups(this.searchInput, this.originalArray);
    this.selectedIdeaFilters = {};
    this.selectedFilters = [];
    this.selectedFilters = false;
    this.firstPage(finalArrayAfterSearch);
  }

  handleSortedGroup() {
    getsortbygroup({
      networkId: communityId,
      userId: userId,
      sortFilter: this.selectedSortFilter,
      sortIdeasVal: this.sortgroupOnOrder,
    })
      .then((data) => {
        this.allgroupList = data.map((item) => {
          let group = {};
          let string = item.Name;
          let length = 40;
          let trimmedString = string.substring(0, length);
          group.Name = trimmedString;
          group.Id = item.Id;
          group.Description = item.Description;
          group.CollaborationType = item.CollaborationType;
          return group;
        });
        this.manipulatedArr = JSON.parse(JSON.stringify(this.allgroupList));
        this.firstPage(this.manipulatedArr);
      })
      .catch((error) => {
        console.log("getallgroup Error => " + JSON.stringify(error));
      });
  }


  handleCreateGroup() {
    /** START-- adobe analytics */
    try {
      util.trackButtonClick("Create a Group");
    } catch (ex) {
      console.error(ex.message);
    }
    /** END-- adobe analytics*/
    if (this.currentUserType != "Guest") this.showGroupModal = true;
  }

  closeIdeaModal(event) {
    if (event.detail) this.showGroupModal = false;
  }

  get isInternaluser() {
    return isinternaluser;
  }

  handleShowFilters(){
    this.showFilters = !this.showFilters;
  } 
}