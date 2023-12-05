/*

Change History
****************************************************************************************************
ModifiedBy      Date        Jira No.    Tag     Description
****************************************************************************************************
balajip         11/22/2021  I2RT-4425   T01     added refresh button, changed the View to one week instead of two
*/
import { LightningElement, api, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { createRecord, updateRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';

import momentJS from "@salesforce/resourceUrl/momentJS";
import { loadScript } from "lightning/platformResourceLoader";
import Id from '@salesforce/user/Id';
import Shift_Type_Not_Requiring_Skill from '@salesforce/label/c.Shift_Type_Not_Requiring_Skill';
import TIME_ZONE from '@salesforce/i18n/timeZone';

import searchResource from "@salesforce/apex/ShiftManagementController.searchResource";
import getChartData from "@salesforce/apex/ShiftManagementController.getChartData";
import checkForShiftManager from "@salesforce/apex/ShiftManagementController.isShiftManager";
import getMyTeam from "@salesforce/apex/ShiftManagementController.getMyTeam";
import canEditShiftPlan from "@salesforce/apex/ShiftManagementController.canEditShiftPlan";

export default class ShiftManagementGantt extends LightningElement {
    @api recordId = "";
    @api objectApiName;
    @api defaultView = "View by Day";

    @track userData;

    @track startDateUTC;
    @track endDateUTC;
    @track formattedStartDate;
    @track formattedEndDate;
    @track dates = [];
    @track datePickerString;
    @track startDate;
    @track endDate;
    @track resources = [];
    @track view = {
        slotSize: 1,
        slots: 1,
        value: "1/7"
    };
    @track filters = [
        {
            label: 'Manager View',
            value: 'none',
            isSelected: true
        }, {
            label: 'My Team',
            value: 'myTeam',
            isSelected: false
        }, {
            label: 'My View',
            value: 'myView',
            isSelected: false
        }, {
            label: 'By Skill',
            value: 'bySkill',
            isSelected: false
        }
    ];
    @track filteredBy = {
        none: true,
        myTeam: false,
        myView: false,
        bySkill: false
    }

    allocFilterDefaultOptions = [
        {
            label: 'All',
            value: 'all',
            isSelected: true
        }, {
            label: 'My Team',
            value: 'myTeam',
            isSelected: false
        }
    ]

    @track allocFilterOptions = [];
    @track allocFilterValue = 'all';

    filteredByValue = '';
    userId = Id;
    @track isShiftManager = false;
    dateShift = 7;
    isAddSkillRequest = false;
    showSpinner = false;
    originalResources = [];
    shiftRequestId;
    shiftPlanId;

    @wire(getMyTeam)
    myTeamMembers

    get options() {
        let opts = [
            {
                label: "View by Hour",
                value: "2/12"
            },
            {
                label: "View by Day",
                value: "1/7" //T01
            }
        ];
        /*if (this.isShiftManager) {
            opts.push({
                label: "View by Week",
                value: "7/10"
            });
        }*/
        return opts;
    }

    get currentUserId() {
        return this.filteredByValue && (this.filteredBy.myTeam || this.filteredBy.none) ? this.filteredByValue : Id;
    }

    get teamMemberOptions() {
        let _myTeam = [{
            label: 'None',
            value: ''
        }];
        if (this.myTeamMembers && this.myTeamMembers.data) {
            this.myTeamMembers.data.forEach(mem => {
                _myTeam.push({
                    label: mem.Name,
                    value: mem.Id
                });
            });
        }
        return _myTeam;
    }

    get filterValue() {
        let selectedFilter;
        this.filters.forEach(fil => {
            if (fil.isSelected) {
                selectedFilter = fil.value;
            }
        });

        return selectedFilter;
    }

    get filterLabel() {
        let selectedFilterLabel = '';
        this.filters.forEach(fil => {
            if (fil.isSelected) {
                selectedFilterLabel = fil.label;
            }
        });
        return selectedFilterLabel;
    }

    get skillOptions() {
        let _skillOpt = [{
            label: 'All',
            value: ''
        }];

        let skillMap = new Map();

        if (this.originalResources && Array.isArray(this.originalResources)) {
            this.originalResources.forEach(res => {
                let key = res.Skill__c ? res.Skill__r.Name : res.Allocation_Type__c;
                let val = key + ':' + (res.Skill__c ? 'skill' : 'allocation');
                skillMap.set(key, val);
            });

            skillMap.forEach(function (val, key) {
                _skillOpt.push({
                    label: key,
                    value: val
                });
            });
        }
        return _skillOpt;
    }

    get showManagerView(){
        return this.isShiftManager && (!(this.filteredByValue) || this.filteredBy.bySkill);
    }

    get showResourceFilter() {
        return this.isShiftManager || this.filteredByValue;
    }

    get dateHeader() {
        return this.view.slotSize == 2 ? this.formattedStartDate : this.formattedStartDate + ' - ' + this.formattedEndDate;
    }

    get showShiftPlanModal() {
        return this.isAddSkillRequest || this.shiftPlanId;
    }

    constructor() {
        super();
        this.template.addEventListener("click", this.closeDropdowns.bind(this));
    }

    connectedCallback() {
        this.showSpinner = true;
        Promise.all([
            loadScript(this, momentJS)
        ]).then(() => {
            switch (this.defaultView) {
                case "View by Hour":
                    this.setView("2/12");
                    break;
                case "View by Day":
                    this.setView("1/7");//T01
                    break;
                default:
                    this.setView("7/10");
            }
            this.getUserType();
        });
    }

    getUserType() {
        this.showSpinner = true;
        checkForShiftManager({
            userId: this.filteredByValue ? this.filteredByValue : this.userId
        }).then(res => {
            this.isShiftManager = res;
            this.setStartDate(new Date());
            this.handleRefresh();
        }).catch(err => {
            console.log('ERR>>', JSON.parse(JSON.stringify(err)))
            this.showSpinner = false;
        });
    }

    handleClick(event) {
        switch (event.target.name) {
            case 'addSkillReq':
                this.isAddSkillRequest = true;
                //this.setStartDate(new Date());
                //this.showSpinner = true;
                //this.handleRefresh();
                break;
            default:
                break;
        }
    }

    handleSkillChange(event) {
        this.filteredByValue = event.target.value;
        console.log('handleSkillChange, this.filteredByValue = ' + this.filteredByValue);
        this.filterData();
    }

    handleTeamMemberChange(event) {
        this.filteredByValue = event.target.value;
        this.getUserType();
    }

    handleLookupUserChange(event) {
        if (event.detail[0]) {
            this.filteredByValue = event.detail[0];
        } else {
            this.filteredByValue = '';
        }
        this.getUserType();
    }
    
    handleAllocFilterChange(event) {
        this.allocFilterValue = event.detail.value;
        console.log('handleAllocFilterChange.. allocFitlerValue >>', this.allocFilterValue);
        
        this.resources = [];
        let _filteredData = [];
        this.originalResources.forEach(res => {
            //console.log('fitlerData, res >>', res);
            //console.log('fitlerData, res.Skill__c >>', res.Skill__c);
            //console.log('fitlerData, res.Skill__r.Name >>', res.Skill__r.Name);
            //console.log('fitlerData, res.Allocation_Type__c >>', res.Allocation_Type__c);
            if(res.Shift_Allocations__r){
                res.Shift_Allocations__r.forEach(alloc => {
                    console.log('handleAllocFilterChange.. alloc.managerId >>', alloc.managerId);
                    console.log('handleAllocFilterChange.. alloc.showAllocation >>', alloc.showAllocation);
                    alloc.showAllocation = false;
                    if (this.allocFilterValue == 'all') {
                        alloc.showAllocation = true;
                    }else if (this.allocFilterValue == 'myTeam') {
                        if(alloc.managerId == this.userId){
                            alloc.showAllocation = true;
                        }
                    }else if (this.allocFilterValue == alloc.userId) {
                        alloc.showAllocation = true;
                    }
                    console.log('handleAllocFilterChange.. alloc.showAllocation >>', alloc.showAllocation);
                });
            }
            _filteredData.push(res);
        });
        this.resources = _filteredData;
        this.template.querySelectorAll('c-shift-management-gantt-manager').forEach(childComp => {
            childComp.setProjects();
        });
        this.showSpinner = false;
            
    }

    handleFilterChange(event) {
        this.filters.forEach(fil => {
            fil.isSelected = fil.value == event.detail.value
            this.filteredBy[fil.value] = fil.value == event.detail.value;
        });
        this.filteredByValue = '';
        if(this.filteredBy.myView){
            this.filteredByValue =  this.userId;
        }
        //this.resources = this.originalResources;
        this.getUserType();
    }

    handleClose(event) {
        this.shiftRequestId = null;
        this.shiftPlanId = null;
        if (event.detail) {
            this.handleRefresh();
        }
        this.isAddSkillRequest = false;
    }

    closeDropdowns() {
        Array.from(
            this.template.querySelectorAll(".lwc-resource-component")
        ).forEach(row => {
            row.closeAllocationMenu();
        });
    }

    setStartDate(_startDate) {
        if (_startDate instanceof Date && !isNaN(_startDate)) {
            _startDate.setHours(0, 0, 0, 0);
            this.datePickerString = moment(_startDate).format('YYYY-MM-DD');
            this.startDate = this.view.slotSize == 2 ? moment(_startDate).toDate() : moment(_startDate)
                .day(1)
                .toDate();
            this.startDateUTC =
                moment(this.startDate)
                    .utc()
                    .valueOf() -
                moment(this.startDate).utcOffset() * 60 * 1000 +
                "";
            this.formattedStartDate = moment(this.startDate).format('ddd, MMM D, YYYY');

            this.setDateHeaders();
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    message: "Invalid Date",
                    variant: "error"
                })
            );
        }
    }

    setDateHeaders() {
        if (this.view.slotSize == 2) {
            this.endDate = moment(this.startDate)
                .toDate();
        } else {
            this.endDate = moment(this.startDate)
                .add(this.view.slots * this.view.slotSize - 1, "days")
                .toDate();
        }
        this.endDateUTC =
            moment(this.endDate)
                .utc()
                .valueOf() -
            moment(this.endDate).utcOffset() * 60 * 1000 +
            "";
        this.formattedEndDate = moment(this.endDate).format('ddd, MMM D, YYYY');//this.endDate;
        const dayNames = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        let today = new Date();
        today.setHours(0, 0, 0, 0);
        today = today.getTime();

        let dates = {};

        let _startDt = this.view.slotSize == 2 ? moment(this.startDate).add(0, "hours") : moment(this.startDate);
        let _endDt = this.view.slotSize == 2 ? moment(this.startDate).add(22, "hours") : moment(this.endDate);
        for (let date = _startDt; date <= _endDt; date.add(this.view.slotSize, this.view.slotSize == 2 ? "hours" : "days")) {
            let index = date.format("YYYYMM");
            if (!dates[index]) {
                dates[index] = {
                    dayName: '',
                    name: this.view.slotSize == 2 ? date.format('LL') : date.format("MMMM"),
                    days: []
                };
            }

            let day = {
                class: "slds-col slds-p-vertical_x-small slds-m-top_x-small lwc-timeline_day",
                label: this.view.slotSize == 2 ? date.format("HH:mm") : date.format("M/D"),
                start: date.toDate()
            };

            if(this.view.slotSize == 2){
                day.class = day.class + " slds-border_right";
            }else{
                day.class = day.class + " lwc-timeline_align_center";
            }

            if (this.view.slotSize > 1) {
                let end = moment(date).add(this.view.slotSize - 1, this.view.slotSize == 2 ? "hours" : "days");
                day.end = end.toDate();
            } else {
                day.end = date.toDate();
                day.dayName = date.format("ddd");
                if (date.day() === 0) {
                    day.class = day.class + " lwc-is-week-end";
                }
            }

            if (today >= day.start && today <= day.end) {
                day.class += " lwc-is-today";
            }

            dates[index].days.push(day);
            dates[index].style =
                "width: calc(" +
                dates[index].days.length +
                "/" +
                this.view.slots +
                "*100%)";
        }

        // reorder index
        this.dates = Object.values(dates);
        console.log('setDateHeaders, this.dates >> ', JSON.stringify(this.dates));

        Array.from(
            this.template.querySelectorAll("c-shift-management-gantt-resource")
        ).forEach(resource => {
            resource.refreshDates(this.startDate, this.endDate, this.view.slotSize);
        });
        Array.from(
            this.template.querySelectorAll("c-shift-management-gantt-manager")
        ).forEach(resource => {
            resource.refreshDates(this.startDate, this.endDate, this.view.slotSize);
        });
    }

    //T01
    refreshPlans(){
        this.handleRefresh();
    }
    
    navigateToToday() {
        this.setStartDate(new Date());
        this.handleRefresh();
    }

    navigateToPrevious() {
        let _startDate = new Date(this.startDate);
        _startDate.setHours(0, 0, 0, 0);
        _startDate.setDate(_startDate.getDate() - (this.view.value == '2/12' ? 1 : this.dateShift));
        this.setStartDate(_startDate);
        this.handleRefresh();
    }

    navigateToNext() {
        let _startDate = new Date(this.startDate);
        _startDate.setHours(0, 0, 0, 0);
        _startDate.setDate(_startDate.getDate() + (this.view.value == '2/12' ? 1 : this.dateShift));
        this.setStartDate(_startDate);
        this.handleRefresh();
    }

    navigateToDay(event) {
        this.setStartDate(new Date(event.target.value + "T00:00:00"));
        this.handleRefresh();
    }

    setView(value) {
        let values = value.split("/");
        this.view.value = value;
        this.view.slotSize = parseInt(value[0], 10);
        this.view.slots = parseInt(values[1], 10);
    }

    handleViewChange(event) {
        this.setView(event.target.value);
        this.setStartDate(new Date());
        this.setDateHeaders();
        this.handleRefresh();
    }

    /*** Filter Modal ***/
    stopProp(event) {
        event.stopPropagation();
    }

    clearFocus() {
        this.filterModalData.focus = null;
    }

    get shiftTypesNotRequiringSkill() {
        return Shift_Type_Not_Requiring_Skill ? Shift_Type_Not_Requiring_Skill.split(';') : [];
    }

    filterShifts(event) {
        var resources = [];
        this.originalResources.forEach(row => {
            var allRowValue = '';
            allRowValue += row.label + '---';
            allRowValue = allRowValue.toLowerCase();
            console.log('allRowValue = '+allRowValue);
            if(allRowValue.indexOf(event.target.value.toLowerCase()) >= 0){
                resources.push(row);
            }
        });
        this.resources = resources;
    }

    handleRefresh() {
        let self = this;
        this.showSpinner = true;

        this.template.querySelector('[data-name="shiftFilter"]').value = "";

        getChartData({
            asManager: this.showManagerView,
            userId: this.filteredByValue ? this.filteredByValue : Id,
            startTime: moment(self.startDate).format('YYYY-MM-DD'),
            endTime: moment(self.endDate).format('YYYY-MM-DD'),
            slotSize: self.view.slotSize
        }).then(data => {
            //console.log('data >>', JSON.stringify(data));
            console.log('usr data >>', JSON.stringify(data.userWrapper.usr));

            console.log('this.allocFilterOptions >>', JSON.stringify(this.allocFilterOptions));
            let allocFilterOptions = [];
            allocFilterOptions = allocFilterOptions.concat(this.allocFilterDefaultOptions);
            if(data.userWrapper.usr){
                this.userData = data.userWrapper.usr;
                if(this.userData.ManagedUsers){
                    this.userData.ManagedUsers.forEach(managedUser => {
                        allocFilterOptions.push({
                            label: managedUser.Name,
                            value: managedUser.Id,
                            isSelected: false
                        });
                    });
                }
            }
            this.allocFilterOptions = allocFilterOptions;
            console.log('this.allocFilterOptions >>', JSON.stringify(this.allocFilterOptions));

            if (this.showManagerView) {
                let tmpArr = [];
                if (data.availableRequestList) {
                    data.availableRequestList.forEach(item => {
                        if (item.request.Shift_Plan__r && item.request.Resource_Count__c > 0) {
                            let tmpReq = Object.assign({}, item.request);
                            tmpReq.label = item.request.Allocation_Type__c + ': ' + item.request.Skill__r.Name
                                + ' (' + (item.request.Total_Approved_Allocation__c ? item.request.Total_Approved_Allocation__c : 0) + '/' + item.request.Resource_Count__c + ')';
                            tmpReq.left = this.getSlotPosition(self.startDate, tmpReq.Shift_Plan__r.Start_Date__c, tmpReq.Business_Hours__r);
                            tmpReq.right = this.getSlotPosition(self.startDate, tmpReq.Shift_Plan__r.End_Date__c, tmpReq.Business_Hours__r, true, tmpReq.left);
                            tmpReq.timeLabel = this.getTimeLabel(self.startDate, tmpReq.Business_Hours__r);
                            tmpReq.skillName = item.request.Skill__r.Name;
                            tmpReq.startDateTime = this.userDatetime(tmpReq.Business_Hours__r, this.userData.TimeZoneSidKey, tmpReq.Shift_Plan__r.Start_Date__c, 'StartTime');
                            console.log('getChartDate.. managerview.. ' + tmpReq.skillName + '-' + tmpReq.startDateTime);
                            tmpReq.helpText = tmpReq.timeLabel; //tmpReq.Allocation_Type__c + ', ' + tmpReq.timeLabel;
                            if (item.allocationList) {
                                item.allocationList.forEach(alloc1 => {
                                    tmpReq.Shift_Allocations__r.forEach(alloc => {
                                        if (alloc.Id == alloc1.allocation.Id) {
                                            alloc.showAllocation = true;
                                            alloc.isPending = alloc.Status__c == 'Pending';
                                            alloc.isApproved = alloc.Status__c == 'Approved';
                                            alloc.isRejected = alloc.Status__c == 'Rejected';
                                            alloc.right = alloc1.right;
                                            alloc.left = alloc1.left;
                                            alloc.timeLabel = this.getTimeLabel(self.startDate, tmpReq.Business_Hours__r);
                                            alloc.left = this.getSlotPosition(self.startDate, alloc.Start_Date__c, tmpReq.Business_Hours__r);
                                            alloc.right = this.getSlotPosition(self.startDate, alloc.End_Date__c, tmpReq.Business_Hours__r, true, tmpReq.left);
                                            alloc.managerId = alloc.Service_Resource__r.RelatedRecord.ManagerId;
                                            alloc.userId = alloc.Service_Resource__r.RelatedRecordId;
                                        }
                                    });
                                });
                            }
                            console.log('handleRefresh.. tmpReq >> ', tmpReq);
                            tmpArr.push(tmpReq);
                        }
                    });
                }
                this.originalResources = tmpArr;
                this.filterData();
            } else {
                let tmpData = {
                    availableRequestList: [],
                    unavailableRequestList: []
                };

                if (data) {
                    if (data.availableRequestList) {
                        data.availableRequestList.forEach(req => {
                            tmpData.availableRequestList.push(this.requestData(req, self));
                        });
                    }

                    if (data.unavailableRequestList) {
                        data.unavailableRequestList.forEach(req => {
                            if (req.request.Shift_Plan__c) {
                                let tmpReq;
                                /*tmpReq = Object.assign({}, req.request);
                                tmpReq.label = this.shiftTypesNotRequiringSkill.includes(req.request.Allocation_Type__c)
                                    ? req.request.Allocation_Type__c
                                    : req.request.Skill__r.Name;
                                // tmpReq.right = req.right;
                                // tmpReq.left = req.left;
                                tmpReq.timeLabel = this.getTimeLabel(self.startDate, tmpReq.Business_Hours__r);
                                tmpReq.left = this.getSlotPosition(self.startDate, tmpReq.Shift_Plan__r.Start_Date__c, tmpReq.Business_Hours__r);
                                tmpReq.right = this.getSlotPosition(self.startDate, tmpReq.Shift_Plan__r.End_Date__c, tmpReq.Business_Hours__r, true);
                                */
                                tmpReq = this.requestData(req, self);
                                tmpData.unavailableRequestList.push(tmpReq);
                            }
                        });
                    }
                }
                
                this.originalResources = tmpData.availableRequestList;
                this.resources = tmpData.availableRequestList; 
            }
        }).catch(error => {
            this.showSpinner = false;
            console.log('error>>>', error);
        }).finally(() => {
            this.showSpinner = false;
        });
    }

    requestData(req, self){
        let tmpReq = Object.assign({}, req.request);
        tmpReq.label = req.request.Allocation_Type__c + ': ' + req.request.Skill__r.Name;
        // tmpReq.right = req.right;
        // tmpReq.left = req.left;
        tmpReq.timeLabel = this.getTimeLabel(self.startDate, tmpReq.Business_Hours__r);
        tmpReq.helpText = tmpReq.timeLabel;//req.request.Allocation_Type__c + ', ' + tmpReq.timeLabel;
        tmpReq.left = this.getSlotPosition(self.startDate, tmpReq.Shift_Plan__r.Start_Date__c, tmpReq.Business_Hours__r);
        tmpReq.right = this.getSlotPosition(self.startDate, tmpReq.Shift_Plan__r.End_Date__c, tmpReq.Business_Hours__r, true, tmpReq.left);
        tmpReq.startDateTime = this.userDatetime(tmpReq.Business_Hours__r, this.userData.TimeZoneSidKey, tmpReq.Shift_Plan__r.Start_Date__c, 'StartTime');
        tmpReq.skillName = req.request.Skill__r.Name;
        console.log('getChartDate.. managerview.. ' + tmpReq.skillName + '-' + tmpReq.startDateTime);

        /*let startDate = this.userDatetime(tmpReq.Business_Hours__r, this.userData.TimeZoneSidKey, tmpReq.Shift_Plan__r.Start_Date__c, 'StartTime');
        startDate.setHours(0,0,0,0);
        console.log('requestData.. shift start date = ' + startDate);

        let curDateTime = this.userDatetime(tmpReq.Business_Hours__r, this.userData.TimeZoneSidKey, (new Date()).setHours(0,0,0,0), 'StartTime');
        let curDate = curDateTime.setHours(0,0,0,0);
        console.log('requestData.. curDate = ' + curDate);
        */
        tmpReq.canApply = false;
        //if(startDate > curDate){
            tmpReq.canApply = tmpReq.Resource_Count__c > (tmpReq.Total_Approved_Allocation__c ? tmpReq.Total_Approved_Allocation__c : 0);
        //}
        
        tmpReq.isApplied = 0;
        tmpReq.isPending = 0;
        tmpReq.isApproved = 0;
        tmpReq.isRejected = 0;
        if(req.allocationList.length>0){
            tmpReq.isApplied = 1;
            tmpReq.isPending = tmpReq.isApplied && req.allocationList[0].allocation.Status__c == 'Pending';
            tmpReq.isApproved = tmpReq.isApplied && req.allocationList[0].allocation.Status__c == 'Approved';
            tmpReq.isRejected = tmpReq.isApplied && req.allocationList[0].allocation.Status__c == 'Rejected';
            tmpReq.allocation = req.allocationList[0].allocation;
        }
        console.log('getChartDate.. managerview.. tmpReq.isApplied - ' + tmpReq.isApplied);
        console.log('getChartDate.. managerview.. tmpReq.canApply - ' + tmpReq.canApply);
        // tmpReq.allocationStartDate = tmpReq.isApplied ? req.allocationList[0].allocation.Start_Date__c : null;
        // tmpReq.allocationEndDate = tmpReq.isApplied ? req.allocationList[0].allocation.End_Date__c : null;
        tmpReq.slotLabel = 'Apply';
        if(tmpReq.isPending){
            tmpReq.slotLabel = 'Applied';
        }else if(tmpReq.isApproved){
            tmpReq.slotLabel = 'Approved';
        }else if(tmpReq.isRejected){
            tmpReq.slotLabel = 'Rejected';
        }
        tmpReq.unassignedProduct = req.unassignedProduct;
        tmpReq.appliedResourceList = req.appliedResourceList;//T01
        tmpReq.approvedResourceList = req.approvedResourceList;//T01
        console.log('requestData.. tmpReq >> ', tmpReq);
        return tmpReq;
    }

    /*userDatetime(bhTimezone, userTimezone, dateValue, timeValue){
        var momentDate = moment(dateValue);
        const bhDate = this.dateWithTimeZone(bhTimezone, momentDate.year(), momentDate.month(), momentDate.date(), timeValue.hours(), timeValue.minutes(), 0);
        
        momentDate = moment(bhDate);
        const userDate = this.dateWithTimeZone(userTimezone, momentDate.year(), momentDate.month(), momentDate.date(), momentDate.hours(), momentDate.minutes(), 0);

        return userDate;
    }*/

    userDatetime(businessHour, userTimezone, dateValue, timeString){
        const day = moment(dateValue).format('dddd');
        const timeValue = moment.duration(businessHour[day + timeString]);

        var momentDate = moment(dateValue);
        const bhDate = this.dateWithTimeZone(businessHour.TimeZoneSidKey, momentDate.year(), momentDate.month(), momentDate.date(), timeValue.hours(), timeValue.minutes(), 0);
        
        momentDate = moment(bhDate);
        const userDate = this.dateWithTimeZone(userTimezone, momentDate.year(), momentDate.month(), momentDate.date(), momentDate.hours(), momentDate.minutes(), 0);

        return userDate;
    }

    getTimeLabel(startDate, businessHour) {
        //console.log('startDate >> ', startDate);

        const userStartDate = this.userDatetime(businessHour, this.userData.TimeZoneSidKey, startDate, 'StartTime');
        const userEndDate = this.userDatetime(businessHour, this.userData.TimeZoneSidKey, startDate, 'EndTime');

        return moment(userStartDate).format('h:mm a') + ' - ' + moment(userEndDate).format('h:mm a');
        //return returnValue;
    }

    getSlotPosition(startDate, endDate, businessHour, isRight, leftValue) {
        if (this.view.slotSize == 2) {
            const day = moment(startDate).format('dddd');
            //const stTime = moment.duration(businessHour[day + 'StartTime']);
            //const endTime = moment.duration(businessHour[day + 'EndTime']);

            //const stDt = this.dateWithTimeZone(businessHour.TimeZoneSidKey, moment(startDate).year(), moment(startDate).month(), moment(startDate).date(), stTime.hours(), stTime.minutes(), 0);
            const stDt = this.userDatetime(businessHour, this.userData.TimeZoneSidKey, startDate, 'StartTime');
            console.log('stDt >>', stDt);

            //const endDt = this.dateWithTimeZone(businessHour.TimeZoneSidKey, moment(startDate).year(), moment(startDate).month(), moment(startDate).date(), endTime.hours(), endTime.minutes(), 0);
            const endDt = this.userDatetime(businessHour, this.userData.TimeZoneSidKey, startDate, 'EndTime');
            console.log('endDt >>', endDt);

            if (!isRight) {
                if (businessHour[day + 'StartTime']) {
                    let rgt = (moment(stDt).minutes() / 60 + moment(stDt).hours()) / this.view.slotSize;
                    return rgt;
                } else {
                    return 0;
                }
            } else {
                if (businessHour[day + 'EndTime']) {
                    console.log('(moment(endDt)??', moment(endDt));
                    let left = (moment(endDt).minutes() / 60 + moment(endDt).hours()) / this.view.slotSize;
                    if(left <= leftValue){
                        left = 12;
                    }
                    return left;
                } else {
                    return 12;
                }
            }
        } else {
            var stDT = moment(moment(startDate).toDate(), 'DD-MM-YYYY');
            console.log('stDT >>', stDT);
            var endDT = moment(moment(endDate).toDate(), 'DD-MM-YYYY');
            console.log('endDT >>', endDT);
            let off = parseInt(endDT.diff(stDT, 'days') / this.view.slotSize);
            console.log('off >>', off);
            return off;
        }
    }

    dateWithTimeZone = (timeZone, year, month, day, hour, minute, second) => {
        let date = new Date(Date.UTC(year, month, day, hour, minute, second));
        let utcDate = new Date(date.toLocaleString('en-US', { timeZone: "UTC" }));
        let tzDate = new Date(date.toLocaleString('en-US', { timeZone: timeZone }));
        let offset = utcDate.getTime() - tzDate.getTime();

        date.setTime(date.getTime() + offset);

        return date;
    };

    filterData() {
        //console.log('fitlerData, this.filteredByValue >>', this.filteredByValue);
        //console.log('fitlerData, this.filteredBy >>', JSON.stringify(this.filteredBy));

        this.originalResources.sort(function(a, b) {
            if(a.skillName == b.skillName){
                return a.startDateTime - b.startDateTime;
            }else{
                return (a.skillName < b.skillName) ? -1 : (a.skillName > b.skillName) ? 1 : 0;
            }
        });

        try {
            if (this.isShiftManager) {
                let _filteredData = [];
                this.originalResources.forEach(res => {
                    //console.log('fitlerData, res >>', res);
                    //console.log('fitlerData, res.Skill__c >>', res.Skill__c);
                    //console.log('fitlerData, res.Skill__r.Name >>', res.Skill__r.Name);
                    //console.log('fitlerData, res.Allocation_Type__c >>', res.Allocation_Type__c);
                    if (!this.filteredByValue) {
                        _filteredData.push(res);
                    } else if (this.filteredBy.bySkill) {

                        let value = this.filteredByValue.split(':')[0];
                        let type = this.filteredByValue.split(':')[1];
                        //console.log('fitlerData, type >>', type);
                        //console.log('fitlerData, value >>', value);

                        if ((type == 'skill' && res.Skill__c && res.Skill__r.Name == value) || (type == 'allocation' && res.Allocation_Type__c == value)) {
                            _filteredData.push(res);
                        }
                    }
                });
                this.resources = _filteredData;
                this.showSpinner = false;
            }
        } catch (err) {
            console.log('ERROR>>>', JSON.stringify(err));
        }
    }

    handleSearch(event) {
        searchResource({
            searchText: event.detail.searchTerm,
            isMyTeam: this.filterValue == 'myTeam'
        }).then(result => {
            let userInfo = [];

            result.forEach(usr => {
                userInfo.push({
                    id: usr.Id,
                    sObjectType: 'User',
                    icon: 'standard:user',
                    title: usr.Name,
                    subtitle: usr.Email,
                    phone: usr.Phone
                });
            });
            this.template.querySelectorAll('c-lookup').forEach(cmp => {
                if (event.detail.key == cmp.customKey) {
                    cmp.setSearchResults(userInfo);
                }
            });
        }).catch(error => {
            console.log('Error in Search results ---> ' + JSON.stringify(error));
        });
    }

    handleEditRequest(event) {
        const evtParams = event.detail;
        canEditShiftPlan({
            shiftPlanId: evtParams.shiftPlanId
        }).then(result => {
            if (result) {
                getRecordNotifyChange([{recordId: evtParams.shiftPlanId}]);
                this.shiftPlanId = evtParams.shiftPlanId;
            } else {
                getRecordNotifyChange([{recordId: evtParams.requestId}]);
                this.shiftRequestId = evtParams.requestId;
            }
        }).catch(error => {
            console.log('ERROR>>>>', JSON.stringify(error));
        });
    }
}