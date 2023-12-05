/*
 * Name         :   HelpCommunitiesLanding
 * Author       :   Utkarsh Jain
 * Created Date :   15-JAN-2022
 * Description  :   This component is used as wrapper for displaying all communities in landing page.

 Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Utkarsh Jain           15-JAN-2021     I2RT-5237           Initial version.                                          NA
 Utkarsh Jain           27-MAY-2021     I2RT-6263           Added 3rd Filter                                          NA
 Utkarsh Jain           30-JAN-2023     I2RT-5889           Product community: Community Landing 
                                                            page - message to the user  
 Prashanth Bhat         22-JUN-2023     I2RT-8529           Introduce New sorting option in the Product community     T1                                                                                     1
 Prashanth Bhat         25-JUL-2023     I2RT-8649           Hiding filters on all the landing pages                   T2
 Prashanth Bhat         31-OCT-2023     I2RT-9228           Pagination                                                T3
 */
 import { LightningElement, track, wire } from "lwc";
 import IN_StaticResource from "@salesforce/resourceUrl/informaticaNetwork";
 
 import userId from "@salesforce/user/Id";
 import communityId from "@salesforce/community/Id";
 import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 
 import getAllCommunity from "@salesforce/apex/helpCommunityController.getAllCommunity";
 import getAllCommunities from "@salesforce/apex/helpCommunityController.getAllCommunities";
 import getMyCommunities from "@salesforce/apex/helpCommunityController.getMyCommunities";
 import getRecommendedCommunity from "@salesforce/apex/helpCommunityController.getRecommendedCommunity";
 import getMostFollowedCommunity from "@salesforce/apex/helpCommunityController.getMostFollowedCommunity";
 import getMostPopularCommunity from "@salesforce/apex/helpCommunityController.getMostPopularCommunity";
 
 import followCommunity from "@salesforce/apex/helpCommunityController.followCommunity";
 import unfollowCommunity from "@salesforce/apex/helpCommunityController.unfollowCommunity";
 import { CurrentPageReference } from 'lightning/navigation';
 
 
 export default class HelpCommunitiesLanding extends LightningElement {
   @track allCommunityList;
   @track communityLogo = IN_StaticResource + "/community.png";
   @track parentCommunity;
   @track grandChildCommunity;
   @track subCommunities_grandChild;
   @track subCommunity = [];
   @track parentChildComm = [];
   @track selectedFiltersParent = [];
   @track selectedFiltersChild = [];
   @track selectedFiltersGrandChild = [];
   @track filteredRecordsChild = [];
   @track searchedList = [];
   @track noSearchResult = false;
 
   @track recordsToDisplay;
   @track filteredRecords = [];
   @track currentPage = 1;
   @track recordPerPage;
   @track totalPages;
   @track selectedFilters = false;
   @track firstplaceholder = "Select Product";
   @track secondplaceholder = "Select Sub Product";
   @track thirdplaceholder = "Select Sub-Sub Product";
   @track isloggedUser = false;
   @track tabValue = 2;
   @track ifFollow = false;
   @track sortByTerm = "FLW";
 
   @track searchVal = "";
 
   @track selectedTab = 2;
   // Tag 1 - Start
   @track showDialog = false;
 
   currentPageReference = null;
   urlStateParameters = null;
   /* Params from Url */
   urlactivetab = null;
 
   @track mostFollowerCommunity;
   @track mostPopularCommunity;
   @track isMostFollowerCalled = false;
   showSpinner = false;
   @track showFilters = true;

   finalManipulatedArray;
   @track showPagination = false;
   @track syncToChild = false;
 
   connectedCallback() {
       if (userId == undefined) {
           this.sessionStorageOptionToken = sessionStorage.getItem('coveoTokenAnonymous');
       }
       else {
           this.sessionStorageOptionToken = sessionStorage.getItem('coveoTokenAuthenticated');
           this.isloggedUser = true;
           this.tabValue = 2;
       }
   } 
 
   @wire (getMostPopularCommunity,{networkId: communityId})
   wiredPopularCommunity({data, error}){
     if(data) {
       
       let dataArray = Object.entries(data);
       dataArray.sort((a, b) => b[1] - a[1]);
       let sortedData = Object.fromEntries(dataArray);
       let sortedKeys = Object.keys(sortedData);
       this.mostPopularCommunity = sortedKeys;
       this.error = undefined;
       console.log('==>'+JSON.stringify(this.mostPopularCommunity));
 
     }else {
       this.mostPopularCommunity = undefined;
       this.error = error;
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
       this.urlactivetab = this.urlStateParameters.active || null;
       if (this.urlactivetab) {
           this.selectedTab = this.urlactivetab;
       }
   }
   
   // Tag 1 - End
 
   renderedCallback() {
     if (
       this.recordsToDisplay.length == 0 &&
       window.searchterm != undefined &&
       window.searchterm != ""
     ) {
       this.noSearchResult = true;
     } else if (this.recordsToDisplay.length == 0) {
       this.noSearchResult = true;
       this.filteredRecords = [];
       this.filteredRecordsChild = [];
     } else {
       this.noSearchResult = false;
     }
   }
 
   handleActive(event) {
     if(this.isMostFollowerCalled == false){
      this.showSpinner = true;
      this.isMostFollowerCalled = true;
      getMostFollowedCommunity({ networkId: communityId })
         .then(result => {
             this.mostFollowerCommunity = result;
             this.error = undefined;  
         })
         .catch(error => {
             this.error = error;
             this.mostFollowerCommunity = undefined;
         }); 
     }
     this.selectedTab = event.target.value;
     if (this.searchVal != "") {
       this.handleSearchProduct(this.searchVal);
     } else if (this.selectedTab == 1) {
       let curValue = this.currentPage;
       getMyCommunities({
         networId: communityId,
         user: userId,
         sortBy: (this.sortByTerm == "FLW" || this.sortByTerm == "POP")  ? 'ASC' : this.sortByTerm,
         searchTerm: "",
       })
         .then((data) => {
           this.currentPage = curValue;
           this.allCommunityList = data;
           
           if(this.sortByTerm == "FLW"){
              this.allCommunityList = this.handleFollowedSortOrder(this.allCommunityList,this.mostFollowerCommunity);
           }
           else if(this.sortByTerm == "POP"){
             this.allCommunityList = this.handlePopularSortOrder(this.allCommunityList,this.mostPopularCommunity);
           }
 
           this.ifFollow
             ? this.handleFilters()
             : this.firstPage(this.allCommunityList);
         })
         .catch((error) => {
           console.error(JSON.stringify(error));
         });
     } else if (this.selectedTab == 2) {
       let curValue = this.currentPage;
       getAllCommunity({
         networId: communityId,
         user: userId,
         sortBy: (this.sortByTerm == "FLW" || this.sortByTerm == "POP") ? 'ASC' : this.sortByTerm,
         searchTerm: "",
       })
         .then((data) => {
           this.currentPage = curValue;
           this.allCommunityList = data;
           this.showSpinner = false;
           if(this.sortByTerm == "FLW"){       
               this.allCommunityList = this.handleFollowedSortOrder(this.allCommunityList,this.mostFollowerCommunity);
           }
           else if(this.sortByTerm == "POP"){
               this.allCommunityList = this.handlePopularSortOrder(this.allCommunityList,this.mostPopularCommunity);
           }
           this.ifFollow
             ? this.handleFilters()
             : this.firstPage(this.allCommunityList);
         })
         .catch((error) => {
           console.error(JSON.stringify(error));
         });
     } else if (this.selectedTab == 3) {
       let curValue = this.currentPage;
       getRecommendedCommunity({
         networId: communityId,
         user: userId,
         sortBy: (this.sortByTerm == "FLW" || this.sortByTerm == "POP")  ? 'ASC' : this.sortByTerm,
         searchTerm: "",
       })
         .then((data) => {
           this.currentPage = curValue;
           this.allCommunityList = data;
           if(this.sortByTerm == "FLW"){        
             this.allCommunityList = this.handleFollowedSortOrder(this.allCommunityList,this.mostFollowerCommunity);
           }
           else if(this.sortByTerm == "POP"){
             this.allCommunityList = this.handlePopularSortOrder(this.allCommunityList,this.mostPopularCommunity);
           }
           this.ifFollow
             ? this.handleFilters()
             : this.firstPage(this.allCommunityList);
         })
         .catch((error) => {
           console.error(JSON.stringify(error));
         });
     }
     this.template.querySelector("c-help-landing").clearAll();
     this.getFilterData();
   }
 
   // Tag 1 - Start
   closeConfirmationModal(){
     this.showDialog = false;
   }
 
   handleUnfollow(event) {
     this.showDialog = true;
     this.unfollowEvent = event;
   }
 
   handleUnfollowCommunity(){
   this.showDialog = false;
   let event = this.unfollowEvent;
   let productCommName = event.detail.name;
   // Tag 1 - End
   unfollowCommunity({
       commId: event.detail.id,
       user: userId,
       networId: communityId,
     })
       .then((data) => {
         let event = { target: { value: this.selectedTab } };
         this.ifFollow = true;
         this.handleActive(event);
         // Tag 1 - Start
         this.dispatchEvent(
           new ShowToastEvent({
               title: 'Success ',
               message: 'You have unfollowed '+ productCommName,
               variant: 'success'
           }),
         );
         // Tag 1 - End
       })
       .catch((error) => {
         console.error(error);
       });
   }
 
   handleFollow(event) { 
     let productCommName = event.detail.name;
     followCommunity({
       commId: event.detail.id,
       user: userId,
       networId: communityId,
     })
       .then((data) => {
         let event = { target: { value: this.selectedTab } };
         this.ifFollow = true;
         this.handleActive(event);
         // Tag 1 - Start
         this.dispatchEvent(
           new ShowToastEvent({
               title: 'Success ',
               message: 'You are now following ' + productCommName,
               variant: 'success'
           }),
         // Tag 1 - End
         );
       })
       .catch((error) => {
         console.error(error);
       });
   }
 
   getFilterData() {
     this.parentCommunity = [];
     let subCom = [];
     getAllCommunities()
       .then((data) => {
         var filteredParentComm = data.filter((item) => {
           if (item.Parent_Level_1__c) {
             return item;
           }
         });
         this.subCommunities_grandChild = data.filter((item) => {
           if (!item.Parent_Level_1__c) {
             return item;
           }
         });
         this.parentCommunity = filteredParentComm.map((item) => {
           let community = {};
           community.label = item.ParentCommunity__c;
           community.value = item.ParentCommunity__c;
           return community;
         });
         data.map((item) => {
           let lstSubComm = item.SubCommunities__c.split(";");
           lstSubComm.sort();
           for (let subcomm in lstSubComm) {
             subCom.push(lstSubComm[subcomm]);
           }
         });
         subCom.sort();
         this.subCommunity = [];
         for (let subcomm in subCom) {
           let community = {};
           community.label = subCom[subcomm];
           community.value = subCom[subcomm];
           this.subCommunity.push(community);
         }
         this.parentChildComm = data;
       })
       .catch((error) => {
         console.error(JSON.stringify(error));
       });
   }
 
   @wire(getAllCommunities)
   CommunitiesList({ error, data }) {
     if (data) {
       this.parentCommunity = [];
       let subCom = [];
       var filteredParentComm = data.filter((item) => {
         if (item.Parent_Level_1__c) {
           return item;
         }
       });
       this.subCommunities_grandChild = data.filter((item) => {
         if (!item.Parent_Level_1__c) {
           return item;
         }
       });
       this.parentCommunity = filteredParentComm.map((item) => {
         let community = {};
         community.label = item.ParentCommunity__c;
         community.value = item.ParentCommunity__c;
         return community;
       });
       data.map((item) => {
         let lstSubComm = item.SubCommunities__c.split(";");
         lstSubComm.sort();
         for (let subcomm in lstSubComm) {
           subCom.push(lstSubComm[subcomm]);
         }
       });
       subCom.sort();
       this.subCommunity = [];
       for (let subcomm in subCom) {
         let community = {};
         community.label = subCom[subcomm];
         community.value = subCom[subcomm];
         this.subCommunity.push(community);
       }
       this.parentChildComm = data;
     } else if (error) {
       console.error(error);
     }
   }
 
   firstPage(result) {
     this.recordPerPage = 9;
     this.totalPages = 1;
     this.showPagination = false;
     this.totalPages = Math.ceil(result.length / this.recordPerPage);
     this.finalManipulatedArray = result;
     
    //Tag 03 Start
    if(!this.ifFollow){
      this.currentPage = 1;
      this.recordsToDisplay = this.finalManipulatedArray.slice(0, this.recordPerPage);
    }
    else if(this.ifFollow){
      this.preparePagination(this.finalManipulatedArray);
    }

    if (this.totalPages > 1) {
       this.showPagination = true;
    }
    if(this.syncToChild == true && !this.ifFollow){
      this.template.querySelector('c-help-pagination').syncTotalPageOnChange(this.totalPages);
    }
    this.syncToChild = true; 
   //Tag 03 End
   }
 
  //Tag 03 Start
  onPageRequest(event) {
    this.currentPage = event.detail; 
    this.paginateRecords();
  }

  preparePagination(result){
    this.showPagination = false;
    this.totalPages = Math.ceil(result.length / this.recordPerPage);
    if(!this.ifFollow){
      this.template.querySelector('c-help-pagination').syncTotalPageOnChange(this.totalPages);
    }
    if (this.totalPages > 1) {
      this.showPagination = true;
    }
    this.ifFollow = false;
    this.finalManipulatedArray = result;
    this.paginateRecords();
  }

  paginateRecords(){
    const start = (this.currentPage - 1) * this.recordPerPage;
    const end = start + this.recordPerPage;
    this.recordsToDisplay = this.finalManipulatedArray.slice(start,end);
  }
  //Tag 03 End

   handleFilters() {
     if (window.searchterm != undefined && window.searchterm != "") {
        this.preparePagination(this.searchedList);
     } else if (this.selectedFiltersGrandChild.length > 0) {
       let ev = {
         detail: [...this.selectedFiltersGrandChild],
       };
       this.handleThirdFilterChange(ev);
     } else if (this.selectedFiltersChild.length > 0) {
       let ev = {
         detail: [...this.selectedFiltersChild],
       };
       this.handleSecondFilterChange(ev);
     } else if (this.selectedFiltersParent.length > 0) {
       let ev = {
         detail: [...this.selectedFiltersParent],
       };
       this.handleFirstFilterChange(ev);
     } else if (this.filteredRecords.length == 0) {
       this.preparePagination(this.allCommunityList);
     } else {
       this.preparePagination(this.filteredRecords);
     }
   }
 
   handleClearAll() {
     if (window.searchterm != undefined && window.searchterm != "") {
       this.clearAllData();
       this.handleSearchProduct(window.searchterm);
     } else if (!this.ifFollow) {
       if (this.sortByTerm == "ASC") {
         this.allCommunityList.sort((a, b) => {
           let fa = a.Name.toLowerCase(),
             fb = b.Name.toLowerCase();
 
           if (fa < fb) {
             return -1;
           }
           if (fa > fb) {
             return 1;
           }
           return 1;
         });
       } else if (this.sortByTerm == "DESC") {
         this.allCommunityList.sort((a, b) => {
           let fa = a.Name.toLowerCase(),
             fb = b.Name.toLowerCase();
 
           if (fa > fb) {
             return -1;
           }
           if (fa < fb) {
             return 1;
           }
           return 1;
         });
       }
       this.clearAllData();
       this.firstPage(this.allCommunityList);
     }
   }
 
   clearAllData() {
     this.filteredRecords = [];
     this.subCommunity = [];
     this.selectedFiltersParent = [];
     this.selectedFiltersChild = [];
     this.selectedFilters = [];
     this.filteredRecordsChild = [];
     this.selectedFilters = false;
     this.isLoadMore = false;
     this.grandChildCommunity = false;
     this.getAllSubCommunity();
   }
 
   handleclearselectfilter(event) {
     let tempFilterRecords = this.filteredRecords;
     this.filteredRecords = [];
     for (let index in tempFilterRecords) {
       if (tempFilterRecords[index].ParentCommunityName == undefined) {
         if (
           tempFilterRecords[index].Name.toLowerCase() !=
           event.detail.toLowerCase()
         ) {
           this.filteredRecords.push(tempFilterRecords[index]);
         }
       } else if (
         tempFilterRecords[index].ParentCommunityName.toLowerCase() !=
         event.detail.toLowerCase()
       ) {
         this.filteredRecords.push(tempFilterRecords[index]);
       }
     }
 
     const elementIndex = this.selectedFiltersParent.indexOf(event.detail);
     if (elementIndex > -1) {
       this.selectedFiltersParent.splice(elementIndex, 1);
       let ev = {
         detail: [...this.selectedFiltersParent],
       };
       this.handleFirstFilterChange(ev);
     }
     const elementIndexchild = this.selectedFiltersChild.indexOf(event.detail);
     if (elementIndexchild > -1) {
       this.selectedFiltersChild.splice(elementIndexchild, 1);
 
       let ev = {
         detail: [...this.selectedFiltersChild],
       };
       this.handleSecondFilterChange(ev);
     }
     const elementIndexGrandchild = this.selectedFiltersGrandChild.indexOf(
       event.detail
     );
     if (elementIndexGrandchild > -1) {
       this.selectedFiltersGrandChild.splice(elementIndexGrandchild, 1);
       let ev = {
         detail: [...this.selectedFiltersGrandChild],
       };
       this.handleThirdFilterChange(ev);
     }
   }
 
   handleFirstFilterChange(event) {
     this.selectedFiltersParent = [];
     this.filteredRecords = [];
     for (let filterCommunity in event.detail) {
       for (let index in this.allCommunityList) {
         if (
           (this.allCommunityList[index].ParentCommunityName != undefined &&
             this.allCommunityList[index].ParentCommunityName.toLowerCase() ==
               event.detail[filterCommunity].toLowerCase()) ||
           this.allCommunityList[index].Name.toLowerCase() ==
             event.detail[filterCommunity].toLowerCase()
         ) {
           this.filteredRecords.push(this.allCommunityList[index]);
         }
       }
     }
     var tempGrandChildList = [];
     for (let filterCommunity in this.filteredRecords) {
       for (let index in this.allCommunityList) {
         if (
           this.filteredRecords[filterCommunity].Name.toLowerCase() ==
           (this.allCommunityList[index].ParentCommunityName != undefined &&
             this.allCommunityList[index].ParentCommunityName.toLowerCase())
         ) {
           tempGrandChildList.push(this.allCommunityList[index]);
         }
       }
     }
 
     this.filteredRecords = [
       ...new Set(this.filteredRecords.concat(tempGrandChildList)),
     ];
     let subFilter = [];
     this.parentChildComm.map((item) => {
       for (let filterCommunity in event.detail) {
         if (
           event.detail[filterCommunity].toLowerCase() ==
           item.ParentCommunity__c.toLowerCase()
         ) {
           let lstSubComm = item.SubCommunities__c.split(";");
           lstSubComm.sort();
           for (let subcomm in lstSubComm) {
             subFilter.push(lstSubComm[subcomm]);
           }
         }
       }
     });
     this.subCommunity = [];
     subFilter.sort();
     for (let subcomm in subFilter) {
       let community = {};
       community.label = subFilter[subcomm];
       community.value = subFilter[subcomm];
       this.subCommunity.push(community);
     }
     this.selectedFiltersParent = event.detail;
     this.selectedFilters = [
       ...new Set(this.selectedFiltersParent.concat(this.selectedFiltersChild)),
     ];
 
     if (window.searchterm != undefined && window.searchterm != "") {
       this.filteredRecords = [];
       for (let filterCommunity in event.detail) {
         for (let index in this.searchedList) {
           if (
             (this.searchedList[index].ParentCommunityName != undefined &&
               this.searchedList[index].ParentCommunityName.toLowerCase() ==
                 event.detail[filterCommunity].toLowerCase()) ||
             this.searchedList[index].Name.toLowerCase() ==
               event.detail[filterCommunity].toLowerCase()
           ) {
             this.filteredRecords.push(this.searchedList[index]);
           }
         }
       }
     }
 
     if (
       event.detail.length == 0 &&
       window.searchterm != undefined &&
       window.searchterm != ""
     ) {
       this.selectedFiltersParent = [];
       this.selectedFiltersChild = [];
       this.selectedFilters = false;
       this.handleSearchProduct(window.searchterm);
     } else if (event.detail.length == 0) {
       this.getAllSubCommunity();
       this.selectedFiltersParent = [];
       this.selectedFiltersChild = [];
       this.selectedFilters = false;
       this.firstPage(this.allCommunityList);
     } else if (this.selectedFiltersChild.length != 0) {
       this.firstPage(this.filteredRecordsChild);
     } else if (this.filteredRecords.length > 0 && this.isLoadMore) {
       this.isLoadMore = false;
       this.preparePagination(this.filteredRecords);
     } else {
       this.firstPage(this.filteredRecords);
     }
   }
 
   getAllSubCommunity() {
     this.subCommunity = [];
     getAllCommunities()
       .then((data) => {
         data.map((item) => {
           let lstSubComm = item.SubCommunities__c.split(";");
           for (let subcomm in lstSubComm) {
             let community = {};
             community.label = lstSubComm[subcomm];
             community.value = lstSubComm[subcomm];
             this.subCommunity.push(community);
           }
         });
       })
       .catch((error) => {});
   }
 
   handleSecondFilterChange(event) {
     this.showThirdFilter(event.detail);
     this.selectedFiltersChild = [];
     this.filteredRecordsChild = [];
     this.selectedFilters = [];
     for (let filterCommunity in event.detail) {
       for (let index in this.allCommunityList) {
         if (
           (this.allCommunityList[index].ParentCommunityName != undefined &&
             this.allCommunityList[index].ParentCommunityName.toLowerCase() ==
               event.detail[filterCommunity].toLowerCase()) ||
           this.allCommunityList[index].Name.toLowerCase() ==
             event.detail[filterCommunity].toLowerCase()
         ) {
           this.filteredRecordsChild.push(this.allCommunityList[index]);
         }
       }
     }
 
     this.selectedFiltersChild = event.detail;
     this.selectedFilters = [
       ...new Set(this.selectedFiltersParent.concat(this.selectedFiltersChild)),
     ];
 
     if (window.searchterm != undefined && window.searchterm != "") {
       this.filteredRecordsChild = [];
       for (let filterCommunity in event.detail) {
         for (let index in this.searchedList) {
           if (
             (this.searchedList[index].ParentCommunityName != undefined &&
               this.searchedList[index].ParentCommunityName.toLowerCase() ==
                 event.detail[filterCommunity].toLowerCase()) ||
             this.searchedList[index].Name.toLowerCase() ==
               event.detail[filterCommunity].toLowerCase()
           ) {
             this.filteredRecordsChild.push(this.searchedList[index]);
           }
         }
       }
     }
 
     if (this.selectedFilters.length == 0) {
       this.getAllSubCommunity();
       this.selectedFiltersParent = [];
       this.selectedFiltersChild = [];
       this.selectedFilters = false;
       this.firstPage(this.allCommunityList);
     } else if (event.detail.length == 0) {
       this.selectedFiltersChild = [];
       this.firstPage(this.filteredRecords);
     } else if (this.filteredRecordsChild.length > 0 && this.isLoadMore) {
       this.isLoadMore = false;
       this.preparePagination(this.filteredRecordsChild);
     } else {
       this.firstPage(this.filteredRecordsChild);
     }
   }
 
   showThirdFilter(subCommunities) {
     let subFilter = [];
     this.subCommunities_grandChild.map((item) => {
       for (let filterCommunity in subCommunities) {
         if (
           subCommunities[filterCommunity].toLowerCase() ==
           item.ParentCommunity__c.toLowerCase()
         ) {
           let lstSubComm = item.SubCommunities__c.split(";");
           lstSubComm.sort();
           for (let subcomm in lstSubComm) {
             subFilter.push(lstSubComm[subcomm]);
           }
         }
       }
     });
     this.grandChildCommunity = [];
     subFilter.sort();
     for (let subcomm in subFilter) {
       let community = {};
       community.label = subFilter[subcomm];
       community.value = subFilter[subcomm];
       this.grandChildCommunity.push(community);
     }
     if (this.grandChildCommunity.length == 0) {
       this.grandChildCommunity = false;
     }
   }
 
   handleThirdFilterChange(event) {
     this.selectedFiltersGrandChild = [];
     this.filteredRecordsGrandChild = [];
     this.selectedFilters = [];
     for (let filterCommunity in event.detail) {
       for (let index in this.allCommunityList) {
         if (
           this.allCommunityList[index].Name.toLowerCase() ==
           event.detail[filterCommunity].toLowerCase()
         ) {
           this.filteredRecordsGrandChild.push(this.allCommunityList[index]);
         }
       }
     }
     this.selectedFiltersGrandChild = event.detail;
     this.selectedFilters = [
       ...new Set(
         this.selectedFiltersParent
           .concat(this.selectedFiltersChild)
           .concat(this.selectedFiltersGrandChild)
       ),
     ];
     if (window.searchterm != undefined && window.searchterm != "") {
       this.filteredRecordsGrandChild = [];
       for (let filterCommunity in event.detail) {
         for (let index in this.searchedList) {
           if (
             (this.searchedList[index].ParentCommunityName != undefined &&
               this.searchedList[index].ParentCommunityName.toLowerCase() ==
                 event.detail[filterCommunity].toLowerCase()) ||
             this.searchedList[index].Name.toLowerCase() ==
               event.detail[filterCommunity].toLowerCase()
           ) {
             this.filteredRecordsGrandChild.push(this.searchedList[index]);
           }
         }
       }
     }
     if (this.selectedFilters.length == 0) {
       this.getAllSubCommunity();
       this.selectedFiltersParent = [];
       this.selectedFiltersGrandChild = [];
       this.selectedFilters = false;
       this.firstPage(this.allCommunityList);
     } else if (event.detail.length == 0) {
       this.selectedFiltersGrandChild = [];
       this.firstPage(this.filteredRecordsChild);
     } else if (this.filteredRecordsGrandChild.length > 0) {
       this.preparePagination(this.filteredRecordsGrandChild);
     } else {
       this.firstPage(this.filteredRecordsgrandChild);
     }
   }
 
   searchProduct(event) {
     let searchInput = event.target.value;
     window.searchterm = searchInput;
     this.searchVal = searchInput;
     if (this.filteredRecordsGrandChild != undefined && this.filteredRecordsGrandChild.length > 0) {
       if (window.searchterm.length > 0) {
        this.recordsToDisplay = this.filteredRecordsGrandChild.filter(
          this.filterSearchResults
        );
        this.preparePagination(this.recordsToDisplay);     
       } else {
         let ev = {
           detail: [...this.selectedFiltersGrandChild],
         };
         this.handleThirdFilterChange(ev);
       }
     } else if (this.filteredRecordsChild.length > 0 && this.filteredRecordsChild != undefined) {
       if (window.searchterm.length > 0) {
         this.recordsToDisplay = this.filteredRecordsChild.filter(
           this.filterSearchResults
         );
         this.preparePagination(this.recordsToDisplay);
       } else {
         let ev = {
           detail: [...this.selectedFiltersChild],
         };
         this.handleSecondFilterChange(ev);
       }
     } else if (this.filteredRecords.length > 0 && this.filteredRecords != undefined) {
       if (window.searchterm.length > 0) {
        this.recordsToDisplay = this.filteredRecords.filter(
          this.filterSearchResults
        );
         this.preparePagination(this.recordsToDisplay);
       } else {
         let ev = {
           detail: [...this.selectedFiltersParent],
         };
         this.handleFirstFilterChange(ev);
       }
     } else {
       this.handleSearchProduct(searchInput);
     }
   }
 
   filterSearchResults(community){
     return community.Name.toLowerCase().includes(
       window.searchterm.toLowerCase()
     );
   }
 
   handleSearchProduct(searchInput){
     if (this.selectedTab == 1) {
       getMyCommunities({
         networId: communityId,
         user: userId,
         sortBy: (this.sortByTerm == "FLW" || this.sortByTerm == "POP") ? 'ASC' : this.sortByTerm,
         searchTerm: searchInput,
       })
         .then((result) => {
           if (result) {
             this.searchedList = result;
             if (this.searchedList.length == 0) {
               this.noSearchResult = true;
             } else {
               this.noSearchResult = false;
             }
           }
           if(this.sortByTerm == "FLW"){
             this.searchedList =  this.handleFollowedSortOrder(this.searchedList,this.mostFollowerCommunity);
           }
           else if(this.sortByTerm == "POP"){
             this.searchedList = this.handlePopularSortOrder(this.searchedList,this.mostPopularCommunity);
           }
           this.firstPage(this.searchedList);
         })
         .catch((error) => {
           console.error(error.body);
         });
     } else if (this.selectedTab == 2) {
       getAllCommunity({
         networId: communityId,
         user: userId,
         sortBy: (this.sortByTerm == "FLW" || this.sortByTerm == "POP") ? 'ASC' : this.sortByTerm,
         searchTerm: searchInput,
       })
         .then((result) => {
           if (result) {
             this.searchedList = result;
             if (this.searchedList.length == 0) {
               this.noSearchResult = true;
             } else {
               this.noSearchResult = false;
             }
           }
           if(this.sortByTerm == "FLW"){
             this.searchedList = this.handleFollowedSortOrder(this.searchedList,this.mostFollowerCommunity);
           }
           else if(this.sortByTerm == "POP"){
             this.searchedList = this.handlePopularSortOrder(this.searchedList,this.mostPopularCommunity);
           }
           this.firstPage(this.searchedList);
         })
         .catch((error) => {
           console.error(error.body);
         });
     } else if (this.selectedTab == 3) {
       getRecommendedCommunity({
         networId: communityId,
         user: userId,
         sortBy: (this.sortByTerm == "FLW" || this.sortByTerm == "POP") ? 'ASC' : this.sortByTerm,
         searchTerm: searchInput,
       })
         .then((result) => {
           if (result) {
             this.searchedList = result;
             if (this.searchedList.length == 0) {
               this.noSearchResult = true;
             } else {
               this.noSearchResult = false;
             }
           }
           if(this.sortByTerm == "FLW"){
             this.searchedList = this.handleFollowedSortOrder(this.searchedList,this.mostFollowerCommunity);
           }
           else if(this.sortByTerm == "POP"){
             this.searchedList = this.handlePopularSortOrder(this.searchedList,this.mostPopularCommunity);
           }
           this.firstPage(this.searchedList);
         })
         .catch((error) => {
           console.error(error.body);
         });
     }
   }
 
   handleSortBy(event) {
     this.sortByTerm = event.detail;
     if (this.selectedFilters) {
     
       this.filterSortResult = this.filteredRecords;
       if (this.filteredRecordsGrandChild != undefined && this.filteredRecordsGrandChild.length > 0) {
         this.filterSortResult = this.filteredRecordsGrandChild;
       } else if (this.filteredRecordsChild != undefined && this.filteredRecordsChild.length > 0) {
         this.filterSortResult = this.filteredRecordsChild;
       }
       if (this.sortByTerm == "ASC") {
         this.filterSortResult.sort((a, b) => {
           let fa = a.Name.toLowerCase(),
             fb = b.Name.toLowerCase();
 
           if (fa < fb) {
             return -1;
           }
           if (fa > fb) {
             return 1;
           }
           return 1;
         });
       } 
       else if (this.sortByTerm == "DESC") {
         this.filterSortResult.sort((a, b) => {
           let fa = a.Name.toLowerCase(),
             fb = b.Name.toLowerCase();
 
           if (fa > fb) {
             return -1;
           }
           if (fa < fb) {
             return 1;
           }
           return 1;
         });
       } 
       else if(this.sortByTerm == "FLW"){
         this.filterSortResult = this.handleFollowedSortOrder(this.filterSortResult,this.mostFollowerCommunity);
       }
       else if(this.sortByTerm == "POP"){
         this.filterSortResult = this.handlePopularSortOrder(this.filterSortResult,this.mostPopularCommunity);
       }
       this.firstPage(this.filterSortResult);
     } 
     
     else if (this.searchVal != "") {
        this.handleSearchProduct(this.searchVal);
     }
     else if (this.selectedTab == 1) {
       getMyCommunities({
         networId: communityId,
         user: userId,
         sortBy: (this.sortByTerm == "FLW" || this.sortByTerm == "POP") ? 'ASC' : this.sortByTerm,
         searchTerm: "",
       })
         .then((result) => {
           if (result) {
             this.allCommunityList = result;
             if(this.sortByTerm == "FLW"){
                this.allCommunityList = this.handleFollowedSortOrder(this.allCommunityList,this.mostFollowerCommunity);
             }
             else if(this.sortByTerm == "POP"){
               this.allCommunityList  = this.handlePopularSortOrder(this.allCommunityList,this.mostPopularCommunity);
             }
             this.firstPage(this.allCommunityList);
           }
         })
         .catch((error) => {
           console.error(error.body);
         });
     } else if (this.selectedTab == 2) {
       getAllCommunity({
         networId: communityId,
         user: userId,
         sortBy: (this.sortByTerm == "FLW" || this.sortByTerm == "POP") ? 'ASC' : this.sortByTerm,
         searchTerm: "",
       })
         .then((result) => {
           if (result) {
             this.allCommunityList = result;
             if(this.sortByTerm == "FLW"){
               this.allCommunityList = this.handleFollowedSortOrder(this.allCommunityList,this.mostFollowerCommunity);
             }
             else if(this.sortByTerm == "POP"){
               this.allCommunityList = this.handlePopularSortOrder(this.allCommunityList,this.mostPopularCommunity);
             }
             this.firstPage(this.allCommunityList);
           }
         })
         .catch((error) => {
           console.error(error.body);
           console.error(error.message);
         });
     } else if (this.selectedTab == 3) {
       getRecommendedCommunity({
         networId: communityId,
         user: userId,
         sortBy: (this.sortByTerm == "FLW" || this.sortByTerm == "POP") ? 'ASC' : this.sortByTerm,
         searchTerm: "",
       })
         .then((result) => {
           if (result) {
             this.allCommunityList = result;
             if(this.sortByTerm == "FLW"){
               this.allCommunityList = this.handleFollowedSortOrder(this.allCommunityList,this.mostFollowerCommunity);
             }
             else if(this.sortByTerm == "POP"){
               this.allCommunityList = this.handlePopularSortOrder(this.allCommunityList,this.mostPopularCommunity);
             }
             this.firstPage(this.allCommunityList);
           }
         })
         .catch((error) => {
           console.error(error.body);
         });
     }
   }
 
   //<T1 Start>
   handlePopularSortOrder(arrayToSort,referenceArray){   
      arrayToSort.sort((a, b) => {
      const indexA = referenceArray.indexOf(a.Id);
      const indexB = referenceArray.indexOf(b.Id);
   
      if (indexA === -1) return 1; // a.Id not found, move it to the end
      if (indexB === -1) return -1; // b.Id not found, move it to the end
   
      return indexA - indexB;
     });  
    return arrayToSort;
   }
 
   handleFollowedSortOrder(arrayToSort,referenceArray){ 
     arrayToSort.sort((a, b) => {
       const indexA = referenceArray.indexOf(a.Name);
       const indexB = referenceArray.indexOf(b.Name);
    
       if (indexA === -1) return 1; // a.Name not found, move it to the end
       if (indexB === -1) return -1; // b.Name not found, move it to the end
    
       return indexA - indexB;
      });  
     return arrayToSort;
   }
   //<T1 Ends>
 
   //<T2>
   handleShowFilters(){
     this.showFilters = !this.showFilters;
   } 
 }