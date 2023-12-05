/*
* Name			:	HelpEventsLanding
* Author		:	Deeksha Shetty
* Created Date	: 	10/02/2022
* Description	:	This LWC is used to show all events and my events.

Change History
**********************************************************************************************************
Modified By			Date			    Jira No.		 Description							                           Tag
**********************************************************************************************************
Deeksha Shetty		10/02/2022		I2RT-5251		 Initial version.					                         N/A
Saumya Gaikwad   29/08/2022    I2RT-6601    Years shown in the Filter should be dynamic         1
Utkarsh Jain     20-SEPT-2022  I2RT-7026     Bringing quick links in the blue banner for 
                                             all the product community detail page              2
Utkarsh Jain      25-Jan-2023  I2RT-7306     Event: Join button in the Event landing page 
Prashanth Bhat    25-JUL-2023  I2RT-8649     Hiding filters on all the landing pages            3                                              
Prashanth Bhat    04-NOV-2023  I2RT-9228     Pagination                                         4
Deeksha Shetty    04-NOV-2023  I2RT-9229     PROD - IN Community - Events - Last filter is not  5
                                             getting removed
*/

import { LightningElement, track, wire } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import IN_StaticResource from "@salesforce/resourceUrl/informaticaNetwork";
import userId from "@salesforce/user/Id";
import communityId from "@salesforce/community/Id";
import getUserGroups from "@salesforce/apex/helpEventsController.getUserGroups";
import getAllEvents from "@salesforce/apex/helpEventsController.getAllEvents";
import getMyEvents from "@salesforce/apex/helpEventsController.getMyEvents";
import addUserToEvent from "@salesforce/apex/helpEventsController.addUserToEvent";
import getEventTypePicklistValues from "@salesforce/apex/helpEventsController.getEventTypePicklistValues";
import fetchFilterAfterTabSwitch from "@salesforce/apex/helpEventsController.fetchFilterAfterTabSwitch";
import sendMail from "@salesforce/apex/helpEventsController.sendMail";
import returnUsersWhoJoinedEvents from "@salesforce/apex/helpEventsController.returnUsersWhoJoinedEvents";
import accountUrl from '@salesforce/label/c.IN_account_login';
import { CurrentPageReference } from 'lightning/navigation';

export default class HelpEventsLanding extends LightningElement {
  @track allEvents;
  @track communityLogo = IN_StaticResource + "/community.png";
  @track userGroups = [];
  @track eventTypes = [];
  @track periodOptions = [{ label: 'Past', value: 'Past' }, { label: 'Future', value: 'Future' }];
  @track noSearchResult = false;
  @track currentPage;
  @track recordPerPage;
  @track totalPages;
  @track showAllEvents = false;
  @track showMyEvents = false;
  @track selectedFilters = [];
  @track selectedFilters = false;
  @track firstplaceholder = "Select User Group";
  @track secondplaceholder = "Select Event Type";
  @track thirdplaceholder = "Select Period";
  userId = userId;
  joinedeventusers; //for button disable
  @track selectedTab = 1;
  @track activeTab = 2;
  @track selectedEventFilters = {};
  @track originalArray = [];
  manipulatedArr;
  allEventsList; //Tag 1
  finalManipulatedArray;
  selectedSortFilter = 'ASC';
  searchInput;
  @track selectedMonthYear;
  @track selectedMonthYearFilterName;
  @track showFilters = true;
  @track showPagination = false;
  @track syncToChild = false;


  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.urlStateParameters = currentPageReference.state;
      this.activeTab = this.urlStateParameters.active || 2;
      // Tag 2 start
      this.fromQuickLink = this.urlStateParameters.cloudProduct || false;
      // Tag 2 end
    }
  }

  @wire(getEventTypePicklistValues)
  EventWiring(result) {
    if (result.data) {
      let categoryFilter = result.data;
      this.eventTypes = categoryFilter.map(item => {
        let event = {};
        event.label = item;
        event.value = item;
        return event;
      });
    }
    else if (result.error) {
      console.log(JSON.stringify(result.error));
    }
  }

  @wire(getUserGroups)
  UserGroupList({ data, error }) {
    if (data) {
      this.userGroups = [];
      for (var key in data) {
        let userGroup = { value: data[key], label: data[key] };
        this.userGroups.push(userGroup);
      }

    } else if (error) {
      console.log("getUserGroups Error => " + JSON.stringify(error));
    }
  }

  renderedCallback() {
    if (this.manipulatedArr.length == 0) {
      this.noSearchResult = true;
    } else {
      this.noSearchResult = false;
    }
  }

  fetchAllEvents(sortOrder, searchInput) {
    getAllEvents({
      sortOrder: sortOrder,
      searchTerm: searchInput
    })
      .then((result) => {
        if (result) {
          this.showAllEvents = false;

          // this.firstPage(this.originalArray);
          // this.selectedFilters = true;

          let ev = {
            detail: this.selectedFilters,
          };
          this.allEvents = result;
          this.originalArray = JSON.parse(JSON.stringify(this.allEvents));
          // Tag 2 start
          if (this.fromQuickLink) {
            this.handleSecondFilterChange(ev);
          }
          // Tag 2 end

          this.helpUsersEvent();
          if (searchInput && searchInput.length > 0) {
            if (this.allEvents.length == 0) {
              this.noSearchResult = true;
            } else {
              this.noSearchResult = false;
            }
          }
          this.showAllEvents = true;
          this.handleThirdFilterChange(ev);
        }
      })
      .catch((error) => {
        console.log("getAllEvents Error => " + JSON.stringify(error));
      });
  }

  fetchMyEvents(sortOrder, searchInput) {
    getMyEvents({
      userId: userId,
      sortOrder: sortOrder,
      searchTerm: searchInput
    })
      .then((data) => {
        this.showMyEvents = false;
        this.allEvents = data;
        this.originalArray = JSON.parse(JSON.stringify(this.allEvents));
        let ev = {
          detail: this.selectedFilters,
        };
        this.handleThirdFilterChange(ev);
        if (searchInput && searchInput.length > 0) {
          if (this.allEvents.length == 0) {
            this.noSearchResult = true;
          } else {
            this.noSearchResult = false;
          }
        }
        this.showMyEvents = true;
      })
      .catch((error) => {
        console.log("getMyEvents Error => " + JSON.stringify(error));
      });
  }

  handleActive(event) {
    this.selectedSortFilter = 'ASC';
    this.searchInput = '';
    this.selectedTab = event.target.value;
    let listBoxOptions = [...this.template.querySelectorAll('c-help-event-list')];
    if (listBoxOptions) {
      for (let item in listBoxOptions) {
        listBoxOptions[item].clearAll();
      }
    }
    this.handleClearAll(event);
    this.getFilterData();
  }

  getFilterData() {
    this.userGroups = [];
    this.eventTypes = [];
    this.periodOptions = [];
    fetchFilterAfterTabSwitch()
      .then((data) => {
        if (data.UserGroupFilter) {
          for (var key in data.UserGroupFilter) {
            let userGroup = { value: data.UserGroupFilter[key], label: data.UserGroupFilter[key] };
            this.userGroups.push(userGroup);
          }
        }

        if (data.TypeFilter) {
          this.eventTypes = data.TypeFilter.map(item => {
            let event = {};
            event.label = item;
            event.value = item;
            return event;
          });
        }
        this.periodOptions = [{ label: 'Past', value: 'Past' }, { label: 'Future', value: 'Future' }];
        // this.getUserType();   

      })
      .catch((error) => {
        console.log("Event Filter Error => " + JSON.stringify(error));
      });
  }

  helpUsersEvent() {
    returnUsersWhoJoinedEvents({ userId: userId })
      .then((result) => {
        if (result) {
          let disable = JSON.parse(JSON.stringify(this.allEvents));
          this.joinedeventusers = result;
          disable.forEach(item => {
            this.joinedeventusers.forEach(element => {
              if (element.EventId == item.Id) {
                item.disablebutton = true;
              }
            });
          });

          this.allEvents = disable;
        }
      })
      .catch((error) => {
        console.log(error.body);
      });
  }


  firstPage(result) {
    this.currentPage = 1;
    this.recordPerPage = 9;
    this.totalPages = 1;
    this.totalPages = Math.ceil(result.length / this.recordPerPage);
    this.finalManipulatedArray = result;
    this.manipulatedArr = result.slice(0, this.recordPerPage);
    this.showPagination = false;
    if (this.totalPages > 1) {
      this.showPagination = true;
    }
  }

  //Tag 04 Start
  onPageRequest(event) {
    this.currentPage = event.detail;
    this.paginateRecords();
  }

  onPaginationRequest(result) {
    this.currentPage = 1;
    this.totalPages = Math.ceil(result.length / this.recordPerPage);
    this.showPagination = false;
    this.finalManipulatedArray = result;
    this.paginateRecords();
    if (this.totalPages > 1) {
      this.showPagination = true;
      if (this.syncToChild) {
        this.template.querySelector('c-help-pagination').syncTotalPageOnChange(this.totalPages);
      }
    }
  }

  paginateRecords() {
    const start = (this.currentPage - 1) * this.recordPerPage;
    const end = start + this.recordPerPage;
    this.manipulatedArr = this.finalManipulatedArray.slice(start, end);
  }
  //Tag 04 End

  handleClearAll(event) {
    this.showPagination = false;
    this.selectedSortFilter = 'ASC';
    let finalArrayAfterSearch = this.globalsearchIdeas(this.searchInput, this.originalArray);
    this.selectedEventFilters = {};
    this.selectedFilters = undefined;

    if (event.target.value == 1) {
      // Tag 2 start
      if (this.selectedFilters == undefined || !this.selectedFilters) {
        if (this.fromQuickLink) {
          this.selectedFilters = [...new Set(['Future', 'Cloud Release'])];
        } else {
          this.selectedFilters = [...new Set(['Future'])];
        }
      }
      this.fetchMyEvents('ASC', '');
    } else if (event.target.value == 2) {
      if (this.selectedFilters == undefined || !this.selectedFilters) {
        if (this.fromQuickLink) {
          this.selectedFilters = [...new Set(['Future', 'Cloud Release'])];
        } else {
          this.selectedFilters = [...new Set(['Future'])];
        }
      }
      this.fetchAllEvents('ASC', '');
    }
    else {
      if (!this.syncToChild) {
        this.firstPage(finalArrayAfterSearch);
      }
      else {
        this.onPaginationRequest(finalArrayAfterSearch);
      }
    }
    // Tag 2 end
  }

  globalSortIdeas(ArrayToSort, SortOrder) {
    if (SortOrder == 'ASC') {
      ArrayToSort.sort((a, b) => new Date(a.FilterDate) - new Date(b.FilterDate));
    }
    else if (SortOrder == 'DESC') {
      ArrayToSort.sort((a, b) => new Date(b.FilterDate) - new Date(a.FilterDate));

    }
    return ArrayToSort;
    // sort and  return array
  }


  handleclearselectfilter(event) {
    if (this.selectedEventFilters.calendarFilter && this.selectedMonthYearFilterName == event.detail) {
      const elementIndex = this.selectedEventFilters.calendarFilter.indexOf(event.detail);
      if (elementIndex > -1) {
        this.selectedEventFilters.calendarFilter = undefined;
      }
    }

    if (this.selectedEventFilters.parentFilter) {
      const elementIndex = this.selectedEventFilters.parentFilter.indexOf(event.detail);
      if (elementIndex > -1) {
        this.selectedEventFilters.parentFilter.splice(elementIndex, 1);
        let ev = {
          detail: [...this.selectedEventFilters.parentFilter],
        };
        this.handleFirstFilterChange(ev);
      }

    }

    if (this.selectedEventFilters.childFilter) {

      const elementIndexchild = this.selectedEventFilters.childFilter.indexOf(event.detail);
      if (elementIndexchild > -1) {
        this.selectedEventFilters.childFilter.splice(elementIndexchild, 1);
        let ev = {
          detail: [...this.selectedEventFilters.childFilter],
        };
        this.handleSecondFilterChange(ev);
      }
    }


    if (this.selectedEventFilters.ThirdFilter) {
      const elementIndexchild = this.selectedEventFilters.ThirdFilter.indexOf(event.detail);
      if (elementIndexchild > -1) {
        this.selectedEventFilters.ThirdFilter.splice(elementIndexchild, 1);
        let ev = {
          detail: [...this.selectedEventFilters.ThirdFilter],
        };
        this.handleThirdFilterChange(ev);
      }
    }



  }

  getFilteredEvent(filterList, eventsToFilter) {
    /* Tag 1 Starts */
    let events = [];
    if (filterList.childFilter) {
      filterList.childFilter.forEach(filter => {
        eventsToFilter.forEach(element => {
          if (element.Type == filter) {
            events.push(element);
          }
        });
      });
    }
    this.allEventsList = events;
    /* Tag 1 Ends */
    let eventsAfterfilter = [];
    if (filterList.parentFilter || filterList.childFilter || filterList.ThirdFilter) {
      eventsToFilter.forEach(element => {
        let elementDate = new Date(element.FilterDate);
        let currentDate = new Date(element.TodayDate);

        if (filterList.parentFilter && filterList.childFilter && filterList.ThirdFilter) {
          if (filterList.ThirdFilter.includes('Past') && filterList.ThirdFilter.includes('Future') && (filterList.parentFilter.includes(element.UserGroupData)) && (filterList.childFilter.includes(element.Type)) && element.FilterDate) {
            if ((filterList.parentFilter.includes(element.UserGroupData)) && (filterList.childFilter.includes(element.Type))) {
              eventsAfterfilter.push(element);
            }
          }
          else if (filterList.ThirdFilter.includes('Past') && (filterList.parentFilter.includes(element.UserGroupData)) && (filterList.childFilter.includes(element.Type)) && element.FilterDate) {
            if ((elementDate < currentDate) && (filterList.parentFilter.includes(element.UserGroupData)) && (filterList.childFilter.includes(element.Type))) {
              eventsAfterfilter.push(element);
            }
          }
          else if (filterList.ThirdFilter.includes('Future') && (filterList.parentFilter.includes(element.UserGroupData)) && (filterList.childFilter.includes(element.Type)) && element.FilterDate) {
            if ((elementDate > currentDate) && (filterList.parentFilter.includes(element.UserGroupData)) && (filterList.childFilter.includes(element.Type))) {
              eventsAfterfilter.push(element);
            }
          }

        }

        else if (filterList.parentFilter && filterList.childFilter) {
          if (filterList.parentFilter.includes(element.UserGroupData) && filterList.childFilter.includes(element.Type)) {
            eventsAfterfilter.push(element);
          }
        }

        else if (filterList.parentFilter && filterList.ThirdFilter) {

          if (filterList.ThirdFilter.includes('Past') && filterList.ThirdFilter.includes('Future') && filterList.parentFilter.includes(element.UserGroupData) && element.FilterDate) {
            if (filterList.parentFilter.includes(element.UserGroupData)) {
              eventsAfterfilter.push(element);
            }
          }
          else if (filterList.ThirdFilter.includes('Past') && filterList.parentFilter.includes(element.UserGroupData) && element.FilterDate) {
            if ((elementDate < currentDate) && filterList.parentFilter.includes(element.UserGroupData)) {
              eventsAfterfilter.push(element);
            }
          }
          else if (filterList.ThirdFilter.includes('Future') && filterList.parentFilter.includes(element.UserGroupData) && element.FilterDate) {
            if ((elementDate > currentDate) && filterList.parentFilter.includes(element.UserGroupData)) {
              eventsAfterfilter.push(element);
            }
          }

        }

        else if (filterList.childFilter && filterList.ThirdFilter) {
          if (filterList.ThirdFilter.includes('Past') && filterList.ThirdFilter.includes('Future') && (filterList.childFilter.includes(element.Type))) {
            if ((filterList.childFilter.includes(element.Type))) {
              eventsAfterfilter.push(element);
            }
          }
          else if (filterList.ThirdFilter.includes('Past') && (filterList.childFilter.includes(element.Type))) {
            if ((elementDate < currentDate) && (filterList.childFilter.includes(element.Type))) {
              eventsAfterfilter.push(element);
            }
          }
          else if (filterList.ThirdFilter.includes('Future') && (filterList.childFilter.includes(element.Type))) {
            if ((elementDate > currentDate) && (filterList.childFilter.includes(element.Type))) {
              eventsAfterfilter.push(element);
            }

          }


        }
        else if (element.UserGroupData && filterList.parentFilter) {
          if (filterList.parentFilter.includes(element.UserGroupData)) {
            eventsAfterfilter.push(element);
          }
        }

        else if (element.Type && filterList.childFilter) {
          if (filterList.childFilter.includes(element.Type)) {
            eventsAfterfilter.push(element);
          }
        }

        else if (element.FilterDate && filterList.ThirdFilter) {
          if (filterList.ThirdFilter.includes('Past') && filterList.ThirdFilter.includes('Future')) {
            eventsAfterfilter.push(element);
          }
          else if (filterList.ThirdFilter.includes('Past')) {
            if (elementDate < currentDate) {
              eventsAfterfilter.push(element);
            }
          }
          else if (filterList.ThirdFilter.includes('Future')) {
            if (elementDate > currentDate) {
              eventsAfterfilter.push(element);
            }
          }

        }
      });
    } //main if ends

    else {
      eventsAfterfilter = JSON.parse(JSON.stringify(eventsToFilter));
    }
    let uniquearray = [...new Set(eventsAfterfilter)];

    if (filterList.calendarFilter) {
      let tempCalendarEvents = [];
      eventsAfterfilter.forEach(element => {
        if (element.MonthYear == this.selectedMonthYear) {
          tempCalendarEvents.push(element);
        }
        /* Tag 1 Starts */
        if (element.month == this.selectedMonthYear) {
          tempCalendarEvents.push(element);
        }
        if (element.year == this.selectedMonthYear) {
          tempCalendarEvents.push(element);
        }
        /* Tag 1 Ends */
      });
      uniquearray = [...new Set(tempCalendarEvents)];
    }
    return uniquearray;
  }


  handleFirstFilterChange(event) {
    if (event.detail.length > 0) {
      this.selectedEventFilters.parentFilter = event.detail;
      /** Tag 5- Adding condition to check selectedEventFilters.calendarFilter with First/child/third filter combination */

      if (this.selectedEventFilters.ThirdFilter && this.selectedEventFilters.childFilter && this.selectedEventFilters.calendarFilter == undefined) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.parentFilter.concat(this.selectedEventFilters.childFilter).concat(this.selectedEventFilters.ThirdFilter))];
      }
      else if (this.selectedEventFilters.childFilter && this.selectedEventFilters.calendarFilter == undefined) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.parentFilter.concat(this.selectedEventFilters.childFilter)),];
      }
      else if (this.selectedEventFilters.ThirdFilter && this.selectedEventFilters.calendarFilter == undefined) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.parentFilter.concat(this.selectedEventFilters.ThirdFilter)),];
      }
      else if (this.selectedEventFilters.calendarFilter != undefined && this.selectedEventFilters.childFilter && this.selectedEventFilters.ThirdFilter) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.parentFilter.concat(this.selectedEventFilters.childFilter).concat(this.selectedEventFilters.ThirdFilter).concat(this.selectedMonthYearFilterName))];
      }
      else if (this.selectedEventFilters.calendarFilter != undefined && this.selectedEventFilters.ThirdFilter) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.parentFilter.concat(this.selectedEventFilters.ThirdFilter).concat(this.selectedMonthYearFilterName))];
      }
      else if (this.selectedEventFilters.calendarFilter != undefined && this.selectedEventFilters.childFilter) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.parentFilter.concat(this.selectedEventFilters.childFilter).concat(this.selectedMonthYearFilterName))];
      }
      else if (this.selectedEventFilters.calendarFilter != undefined) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.parentFilter.concat(this.selectedMonthYearFilterName)),];
      }
      else {
        this.selectedFilters = this.selectedEventFilters.parentFilter;
      }

    }
    else {
      this.selectedEventFilters.parentFilter = null;
      if (this.selectedEventFilters.ThirdFilter && this.selectedEventFilters.childFilter && this.selectedEventFilters.calendarFilter == undefined) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.childFilter.concat(this.selectedEventFilters.ThirdFilter))];
      }
      else if (this.selectedEventFilters.childFilter && this.selectedEventFilters.calendarFilter == undefined) {
        this.selectedFilters = this.selectedEventFilters.childFilter;
      }
      else if (this.selectedEventFilters.ThirdFilter && this.selectedEventFilters.calendarFilter == undefined) {
        this.selectedFilters = this.selectedEventFilters.ThirdFilter;
      }
      else if (this.selectedEventFilters.ThirdFilter && this.selectedEventFilters.childFilter && this.selectedEventFilters.calendarFilter != undefined) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.childFilter.concat(this.selectedEventFilters.ThirdFilter).concat(this.selectedMonthYearFilterName))];
      }
      else if (this.selectedEventFilters.ThirdFilter && this.selectedEventFilters.calendarFilter != undefined) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.ThirdFilter.concat(this.selectedMonthYearFilterName))];
      }
      else if (this.selectedEventFilters.childFilter && this.selectedEventFilters.calendarFilter != undefined) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.childFilter.concat(this.selectedMonthYearFilterName))];
      }
      else if (this.selectedEventFilters.calendarFilter != undefined) {
        this.selectedFilters = this.selectedMonthYearFilterName;
      }
      /** Tag 5 ends here */

      else {
        this.selectedFilters = false;
      }
    }
    let finalsortideas = this.globalSortIdeas(this.originalArray, this.selectedSortFilter);
    let finalArrayAfterSearch = this.globalsearchIdeas(this.searchInput, finalsortideas);  //replace the sorted one with Original
    let finalFilterArray = this.getFilteredEvent(this.selectedEventFilters, finalArrayAfterSearch);
    this.onPaginationRequest(finalFilterArray);
  }


  //handle selected filters on the second Filter Box 
  handleSecondFilterChange(event) {
    if (event.detail.length > 0) {
      this.selectedEventFilters.childFilter = event.detail;

      /** Tag 5 - Adding condition to check selectedEventFilters.calendarFilter with First/child/third filter combination */

      if (this.selectedEventFilters.parentFilter && this.selectedEventFilters.ThirdFilter && this.selectedEventFilters.calendarFilter == undefined) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.parentFilter.concat(this.selectedEventFilters.childFilter).concat(this.selectedEventFilters.ThirdFilter))];
      }
      else if (this.selectedEventFilters.parentFilter && this.selectedEventFilters.calendarFilter == undefined) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.parentFilter.concat(this.selectedEventFilters.childFilter)),];
      }
      else if (this.selectedEventFilters.ThirdFilter && this.selectedEventFilters.calendarFilter == undefined) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.childFilter.concat(this.selectedEventFilters.ThirdFilter)),];
      }
      else if (this.selectedEventFilters.calendarFilter != undefined && this.selectedEventFilters.parentFilter && this.selectedEventFilters.ThirdFilter) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.parentFilter.concat(this.selectedEventFilters.childFilter).concat(this.selectedEventFilters.ThirdFilter).concat(this.selectedMonthYearFilterName))];
      }
      else if (this.selectedEventFilters.calendarFilter != undefined && this.selectedEventFilters.parentFilter) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.parentFilter.concat(this.selectedEventFilters.childFilter).concat(this.selectedMonthYearFilterName))];
      }
      else if (this.selectedEventFilters.calendarFilter != undefined && this.selectedEventFilters.ThirdFilter) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.childFilter.concat(this.selectedEventFilters.ThirdFilter).concat(this.selectedMonthYearFilterName))];
      }
      else if (this.selectedEventFilters.calendarFilter != undefined) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.childFilter.concat(this.selectedMonthYearFilterName)),];
      }
      else {
        this.selectedFilters = this.selectedEventFilters.childFilter;
      }

    }
    else {
      this.selectedEventFilters.childFilter = null;

      if (this.selectedEventFilters.ThirdFilter && this.selectedEventFilters.parentFilter && this.selectedEventFilters.calendarFilter == undefined) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.parentFilter.concat(this.selectedEventFilters.ThirdFilter))];
      }
      else if (this.selectedEventFilters.parentFilter && this.selectedEventFilters.calendarFilter == undefined) {
        this.selectedFilters = this.selectedEventFilters.parentFilter;
      }
      else if (this.selectedEventFilters.ThirdFilter && this.selectedEventFilters.calendarFilter == undefined) {
        this.selectedFilters = this.selectedEventFilters.ThirdFilter;
      }
      else if (this.selectedEventFilters.parentFilter && this.selectedEventFilters.ThirdFilter && this.selectedEventFilters.calendarFilter != undefined) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.parentFilter.concat(this.selectedEventFilters.ThirdFilter).concat(this.selectedMonthYearFilterName))];
      }
      else if (this.selectedEventFilters.parentFilter && this.selectedEventFilters.calendarFilter != undefined) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.parentFilter.concat(this.selectedMonthYearFilterName))];
      }
      else if (this.selectedEventFilters.ThirdFilter && this.selectedEventFilters.calendarFilter != undefined) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.ThirdFilter.concat(this.selectedMonthYearFilterName))];
      }
      else if (this.selectedEventFilters.calendarFilter != undefined) {
        this.selectedFilters = this.selectedMonthYearFilterName;
      }
      /** ends here */
      else {
        this.selectedFilters = false;
      }

    }
    let finalsortideas = this.globalSortIdeas(this.originalArray, this.selectedSortFilter);
    let finalArrayAfterSearch = this.globalsearchIdeas(this.searchInput, finalsortideas);
    let finalFilterArray = this.getFilteredEvent(this.selectedEventFilters, finalArrayAfterSearch);
    this.onPaginationRequest(finalFilterArray);

  }



  handleThirdFilterChange(event) {
    if (event.detail.length > 0) {
      this.selectedEventFilters.ThirdFilter = event.detail;

      /** Tag 5 - Adding condition to check selectedEventFilters.calendarFilter with First/Child/third filter combination */
      if (this.selectedEventFilters.parentFilter && this.selectedEventFilters.childFilter && this.selectedEventFilters.calendarFilter == undefined) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.parentFilter.concat(this.selectedEventFilters.childFilter).concat(this.selectedEventFilters.ThirdFilter))];
      }
      else if (this.selectedEventFilters.parentFilter && this.selectedEventFilters.calendarFilter == undefined) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.parentFilter.concat(this.selectedEventFilters.ThirdFilter)),];
      }
      else if (this.selectedEventFilters.childFilter && this.selectedEventFilters.calendarFilter == undefined) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.childFilter.concat(this.selectedEventFilters.ThirdFilter)),];
      }
      else if (this.selectedEventFilters.calendarFilter != undefined && this.selectedEventFilters.parentFilter && this.selectedEventFilters.childFilter) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.parentFilter.concat(this.selectedEventFilters.childFilter).concat(this.selectedMonthYearFilterName))];
      }
      else if (this.selectedEventFilters.calendarFilter != undefined && this.selectedEventFilters.parentFilter) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.parentFilter.concat(this.selectedEventFilters.ThirdFilter).concat(this.selectedMonthYearFilterName))];
      }
      else if (this.selectedEventFilters.calendarFilter != undefined && this.selectedEventFilters.childFilter) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.childFilter.concat(this.selectedEventFilters.ThirdFilter).concat(this.selectedMonthYearFilterName))];
      }
      else if (this.selectedEventFilters.calendarFilter != undefined) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.ThirdFilter.concat(this.selectedMonthYearFilterName)),];
      }
      else {
        this.selectedFilters = this.selectedEventFilters.ThirdFilter;
      }


    }
    else {
      this.selectedEventFilters.ThirdFilter = null;

      if (this.selectedEventFilters.parentFilter && this.selectedEventFilters.childFilter && this.selectedEventFilters.calendarFilter == undefined) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.parentFilter.concat(this.selectedEventFilters.childFilter))];
      }
      else if (this.selectedEventFilters.parentFilter && this.selectedEventFilters.calendarFilter == undefined) {
        this.selectedFilters = this.selectedEventFilters.parentFilter;
      }
      else if (this.selectedEventFilters.childFilter && this.selectedEventFilters.calendarFilter == undefined) {
        this.selectedFilters = this.selectedEventFilters.childFilter;
      }
      else if (this.selectedEventFilters.parentFilter && this.selectedEventFilters.childFilter && this.selectedEventFilters.calendarFilter != undefined) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.parentFilter.concat(this.selectedEventFilters.childFilter).concat(this.selectedMonthYearFilterName))];
      }
      else if (this.selectedEventFilters.parentFilter && this.selectedEventFilters.calendarFilter != undefined) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.parentFilter.concat(this.selectedMonthYearFilterName))];
      }
      else if (this.selectedEventFilters.childFilter && this.selectedEventFilters.calendarFilter != undefined) {
        this.selectedFilters = [...new Set(this.selectedEventFilters.childFilter.concat(this.selectedMonthYearFilterName))];
      }
      else if (this.selectedEventFilters.calendarFilter != undefined) {
        this.selectedFilters = this.selectedMonthYearFilterName;
      }
      /** ends here */
      else {
        this.selectedFilters = false;
      }
    }
    // if (this.selectedFilters && this.selectedFilters.length > 0 && this.selectedEventFilters.calendarFilter != undefined && this.selectedMonthYearFilterName != undefined) {
    //   const elementIndex = this.selectedFilters.indexOf(this.selectedMonthYearFilterName);
    //   if (elementIndex == -1) {
    //     this.selectedFilters.push(this.selectedMonthYearFilterName);
    //   }
    // }
    let finalsortideas = this.globalSortIdeas(this.originalArray, this.selectedSortFilter);
    let finalArrayAfterSearch = this.globalsearchIdeas(this.searchInput, finalsortideas);
    let finalFilterArray = this.getFilteredEvent(this.selectedEventFilters, finalArrayAfterSearch);
    if (!this.syncToChild) {
      this.firstPage(finalFilterArray);
    }
    else {
      this.onPaginationRequest(finalFilterArray);
    }
    this.syncToChild = true;
  }

  handleJoinEvent(event) {
    if (userId == undefined) {
      window.open(accountUrl, "_blank");
    }
    else {
      let eventId = event.detail;
      addUserToEvent({
        eventId: eventId,
        userId: userId
      })
        .then((result) => {
          if (result.returnMessage == 'User Added') {
            // Show toast message 
            this.dispatchEvent(
              new ShowToastEvent({
                title: 'Success : ',
                message: 'You have successfully joined the Event.You will receive an Email Invite Shortly!',
                variant: 'success',
              }),
            );

            sendMail({ userId: userId, eventId: eventId })
              .then(result1 => {
                if (result1) {
                  let disable = JSON.parse(JSON.stringify(this.allEvents));
                  disable.forEach(element => {
                    if (element.Id == eventId) {
                      element.disablebutton = true;
                    }
                  });
                  this.allEvents = disable;
                  // Start - Tag - 3 
                  location.reload();
                }
              })
              .catch(error => {
                console.log(error.body.message);
                location.reload();
                // End - Tag - 3 
              })

          }
          else if (result.returnMessage == 'Past Event') {
            this.dispatchEvent(
              new ShowToastEvent({
                title: 'Error : ',
                message: 'You Cannot Join a Past Event',
                variant: 'Error',
              }),
            );
          }


        })
        .catch((error) => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error : ',
              message: 'Error occurred, please contact system administrator. Error Message: ' + error.body.message,
              variant: 'error',
            }),
          );
        });

    }

  }

  handleSortBy(event) {
    this.selectedSortFilter = event.detail;
    let finalFilterArray = this.getFilteredEvent(this.selectedEventFilters, this.originalArray);
    let finalArrayAfterSearch = this.globalsearchIdeas(this.searchInput, finalFilterArray);
    let finalsortideas = this.globalSortIdeas(finalArrayAfterSearch, this.selectedSortFilter);
    this.onPaginationRequest(finalsortideas);
  }

  searchEvent(event) {
    this.searchInput = event.target.value;
    console.log('==>' + this.searchInput);
    let finalsortideas = this.globalSortIdeas(this.originalArray, this.selectedSortFilter);
    let finalFilterArray = this.getFilteredEvent(this.selectedEventFilters, finalsortideas);
    console.log('finalFilterArray :' + finalFilterArray);
    let finalArrayAfterSearch = this.globalsearchIdeas(this.searchInput, finalFilterArray);
    console.log('finalArrayAfterSearch :' + finalArrayAfterSearch);
    this.onPaginationRequest(finalArrayAfterSearch);
    if (this.searchInput == '') this.noSearchResult = false;
  }



  globalsearchIdeas(searchKey, arrayToSearch) {
    let arrayAfterSearch = [];
    if (searchKey) {
      arrayAfterSearch = arrayToSearch.filter(word => { return (word.Subject.toLowerCase()).includes(searchKey.toLowerCase()) })
      if (arrayAfterSearch.length == 0) this.noSearchResult = true;
      else this.noSearchResult = false;
    }
    else {
      arrayAfterSearch = JSON.parse(JSON.stringify(arrayToSearch));

    }
    return arrayAfterSearch;
  }

  handleMonthYearFilterChange(event) {
    if (event.detail.value == undefined) {
      this.selectedMonthYear = undefined;
      this.selectedEventFilters.calendarFilter = undefined;
      this.selectedMonthYearFilterName = undefined;
      let previousFilterName = event.detail.previousValue;
      let indexOf = this.selectedFilters.indexOf(previousFilterName);
 
      if (indexOf > -1) {
        this.selectedFilters.splice(indexOf, 1);
        if (this.selectedFilters.length == 0) {
          this.selectedFilters = false;
        } else {
          // let ev = {
          //   detail: this.selectedFilters,
          // };
          // this.handleThirdFilterChange(ev);

          //Tag 5 - Removes the index of selectedMonthYearFilterName from selectedFilters
          if (this.selectedFilters && this.selectedFilters.length > 0 && this.selectedEventFilters.calendarFilter != undefined && this.selectedMonthYearFilterName != undefined) {
            const elementIndex = this.selectedFilters.indexOf(this.selectedMonthYearFilterName);
            if (elementIndex == -1) {
              this.selectedFilters.push(this.selectedMonthYearFilterName);
            }
          }
          let finalsortideas = this.globalSortIdeas(this.originalArray, this.selectedSortFilter);
          let finalArrayAfterSearch = this.globalsearchIdeas(this.searchInput, finalsortideas);
          let finalFilterArray = this.getFilteredEvent(this.selectedEventFilters, finalArrayAfterSearch);
          this.onPaginationRequest(finalFilterArray);
           //Tag 5 ends
        }
      }
    } else if (event.detail.value != undefined) {
      this.selectedMonthYear = event.detail.value;
      //this.selectedEventFilters.calendarFilter = event.detail.value;
      if (this.selectedFilters) {
        let filterName = event.detail.filterName;
        this.selectedMonthYearFilterName = event.detail.filterName;
        this.selectedEventFilters.calendarFilter = event.detail.filterName; //Tag 5 - Assign the month and year value
        let previousFilterName = event.detail.previousValue;
        if (previousFilterName != undefined) {
          let indexOf = this.selectedFilters.indexOf(previousFilterName);
          this.selectedFilters[indexOf] = filterName;
        } else {
          this.selectedFilters.push(filterName);
        }
        let finalsortideas = this.globalSortIdeas(this.originalArray, this.selectedSortFilter);
        let finalArrayAfterSearch = this.globalsearchIdeas(this.searchInput, finalsortideas);
        let finalFilterArray = this.getFilteredEvent(this.selectedEventFilters, finalArrayAfterSearch);
        this.onPaginationRequest(finalFilterArray);
      }

    }
    console.log('Selected filters towards the end of handleMonthYearFilterChange=' + JSON.stringify(this.selectedFilters))
  }
  //tag 3
  handleShowFilters() {
    this.showFilters = !this.showFilters;
  }
}