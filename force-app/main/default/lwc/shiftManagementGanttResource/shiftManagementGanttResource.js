/*

Change History
****************************************************************************************************
ModifiedBy      Date        Jira No.    Tag     Description
****************************************************************************************************
balajip         11/22/2021  I2RT-4425   T01     to show the list of applied/approved allocations
*/
import { LightningElement, api, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import SHIFT_ALLOCATION_OBJECT from '@salesforce/schema/Shift_Allocation__c';
import LOCATION_FIELD from '@salesforce/schema/Shift_Allocation__c.Location__c';
import SHIFT_TYPE_FIELD from '@salesforce/schema/Shift_Allocation__c.Shift_Type__c';
import Shift_Allocation_Type_Holiday_Support from '@salesforce/label/c.Shift_Allocation_Type_Holiday_Support';

import createShiftAllocation from "@salesforce/apex/ShiftManagementController.createShiftAllocation";
import getOOODates from "@salesforce/apex/ShiftManagementController.getOOODates";

import USER_FIELD_MOBILE from '@salesforce/schema/User.MobilePhone';

const SHIFT_TYPE_HOLIDAY_SUPPORT_INDIA = 'Holiday Support (India)';//T01

export default class ShiftManagementGanttResource extends LightningElement {
    @api
    get resource() {
        return this._resource;
    }
    set resource(_resource) {
        this._resource = _resource;
        this.setAttribute('resource', _resource);
        this.setProjects();
    }

    @api label;
    @api isAvailable;
    @api startDate;
    @api endDate;
    @api dateIncrement;
    
    @api userId;

    @track userPhone;
    @track userLocation = 'WFO';
    @track userShiftType = '';

    @wire(getRecord, {
        recordId: '$userId',
        fields: [USER_FIELD_MOBILE]
    }) wireuser ({
        error,
        data
    }) {
        if (error) {
            console.log('error fetching user phone >>', JSON.stringify(error));
        } else if (data) {
            this.userPhone = getFieldValue(data, USER_FIELD_MOBILE);
            console.log('this.userPhone >>', this.userPhone);
        }
    }

    @track projects = [];
    @track _resource;
    @track request;
    @track requests = [];
    @track addAllocationData = {};
    @track editAllocationData = {};
    @track menuData = {
        open: false,
        show: false,
        style: ""
    };
    @track times = [];

    dragInfo = {};
    showSpinner = false;

    picklistValueProvider = {
        locationPicklistValues: [],
        shiftType: []
    }

    oooDateList = [];
    
    @track shiftUsersApproved = '';
    @track shiftUsersPending = '';
    showAllocationDetails = false;

    @wire(getOOODates, { userId: '$userId' })
    getOOODates({ error, data }) {
        if (error) {
            console.log('getOOODates error..', JSON.parse(JSON.stringify(error)));
        } else if (data) {
            let daysSet = new Set();
            data.forEach(evt => {
                const startDate = new Date(evt.StartDateTime);
                const endDate = new Date(evt.EndDateTime);

                while (startDate <= endDate) {
                    daysSet.add(moment(startDate).format('YYYY-MM-DD'));
                    startDate.setDate(startDate.getDate() + 1);
                }

            });
            this.oooDateList = Array.from(daysSet);
            this.setProjects();
        }
    }

    @wire(getObjectInfo, { objectApiName: SHIFT_ALLOCATION_OBJECT })
    shiftAllocationObjInfo;

    @wire(getPicklistValues, { recordTypeId: '$shiftAllocationObjInfo.data.defaultRecordTypeId', fieldApiName: LOCATION_FIELD })
    getLocationValues({ error, data }) {
        if (error) {
            console.log('error>>>', { ...error });
        } else if (data) {
            //console.log('getLocationValues, data >> ', JSON.stringify(data));
            this.picklistValueProvider.locationPicklistValues = [...this.picklistValueProvider.locationPicklistValues, ...data.values];
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$shiftAllocationObjInfo.data.defaultRecordTypeId', fieldApiName: SHIFT_TYPE_FIELD })
    getShiftTypeValues({ error, data }) {
        if (error) {
            console.log('error>>>', { ...error });
        } else if (data) {
            //console.log('getShiftTypeValues, data >> ', JSON.stringify(data));
            this.picklistValueProvider.shiftType = [...this.picklistValueProvider.shiftType, ...data.values];
        }
    }

    get isLocationRequired() {
        return this.selectedReq && this.selectedReq.Allocation_Type__c.includes(Shift_Allocation_Type_Holiday_Support);
    }

    get isHourView() {
        return this.dateIncrement == 2;
    }

    get isShiftTypeApplicable(){
        return this.selectedReq && this.selectedReq.Allocation_Type__c.includes(SHIFT_TYPE_HOLIDAY_SUPPORT_INDIA); //T01
    }

    connectedCallback() {
        let globalStyle = document.createElement('style');
        globalStyle.innerHTML = `
        .rejected-allocation .slds-button {
        background: #ff6666 !important;
        color: white !important;
        }

        .reject-allocation .slds-button {
        background: red !important;
        color: white !important;
        }

        .reject-allocation .slds-button:hover {
        background: #cc0000 !important;
        color: white !important;
        }
        
        .approved-allocation .slds-button {
        background: #00b300 !important;
        color: white !important;
        }
        
        .applied-allocation .slds-button {
        background: #ffae1a !important;
        color: white !important;
        }`;
        document.head.appendChild(globalStyle);

        this.refreshDates(this.startDate, this.endDate, this.dateIncrement);
    }

    captureEngineerDetail = false;
    selectedReq;

    handleApplyClick(event){
        console.log('handleApplyClick, title >>>>', event.currentTarget.title);
        console.log('handleApplyClick, id >>', event.currentTarget.dataset.id);
        console.log('handleApplyClick, startdate >>', event.currentTarget.dataset.startdate);
        console.log('handleApplyClick, enddate >>', event.currentTarget.dataset.enddate);
        if (this.validateData(event.currentTarget.dataset)) {
            console.log('handleApplyClick, validation success!');
            this.selectedReq = this.requests.filter(req => req.Id == event.currentTarget.dataset.id)[0];
            this.userShiftType = '';
            if(this.selectedReq.allocation){
                this.userPhone = this.selectedReq.allocation.Contact_Number__c;
                this.userLocation = this.selectedReq.allocation.Location__c;
                this.userShiftType = this.selectedReq.allocation.Shift_Type__c;
            }

            this.captureEngineerDetail = true;
        }
    }

    handleClick(event) {
        switch (event.target.name) {
            case 'applySave':
                console.log('apply save clicked!');
                const phoneField = this.template.querySelector("[data-name='engineerContact']");
                const locationField = this.template.querySelector("[data-name='engineerLocation']");
                const shiftTypeField = this.template.querySelector("[data-name='engineerShiftType']");
                let isValid = true;

                isValid = phoneField.reportValidity();
                if (isValid) {
                    isValid = locationField.reportValidity();
                } else {
                    locationField.reportValidity();
                }
                if(shiftTypeField){
                    if (isValid) {
                        isValid = shiftTypeField.reportValidity();
                    } else {
                        shiftTypeField.reportValidity();
                    }    
                }

                if (!isValid) {
                    console.log('isValid >>', isValid);
                    this.dispatchEvent(new ShowToastEvent({
                        message: "Please review the error(s)",
                        variant: "error"
                    }));
                    return;
                }
                this.showSpinner = true;

                /*
                let appliedStartDate;
                let appliedEndDate;                
                this.template.querySelectorAll(`[data-name="${event.target.dataset.id}"]`).forEach(slot => {
                    //if (slot.classList.value.includes(' is-selected')) {
                        if (!appliedStartDate) {
                            appliedStartDate = new Date(slot.dataset.startdate)
                            //appliedStartDate = new Date(Number(slot.dataset.start));
                        }
                        appliedEndDate = new Date(slot.dataset.enddate)
                        //appliedEndDate = new Date(Number(slot.dataset.end));
                    //}
                });
                console.log('appliedStartDate >> ', appliedStartDate);
                console.log('appliedEndDate >> ', appliedEndDate);
                */

                this.captureEngineerDetail = false;
                this.selectedReq = null;

                this.userPhone = phoneField.value;
                this.userLocation = locationField.value;
                this.userShiftType = '';
                if(shiftTypeField){
                    this.userShiftType = shiftTypeField.value;
                }
                createShiftAllocation({
                    //startDate: this.formatDate(appliedStartDate),
                    //endDate: this.formatDate(appliedEndDate),
                    userId: this.userId,
                    reqId: event.target.dataset.id,
                    phone: this.userPhone,
                    location: this.userLocation,
                    shiftType: this.userShiftType
                }).then(() => {
                    this.dispatchEvent(new CustomEvent('refresh'));
                }).catch(err => {
                    console.log('ERR>>', JSON.stringify(err));
                }).finally(() => {
                    this.showSpinner = false;
                })
                break;
            case 'applyCancel':
                this.captureEngineerDetail = false;
                this.selectedReq = null;
                break;
            default:
                break;
        }

        switch (event.currentTarget.dataset.name) {
            case 'accordion':
                let reqId = event.currentTarget.dataset.control;
                let controlledDiv = this.template.querySelector("[data-controlled=" + reqId + "]");
                let controlledIcon = this.template.querySelector("[data-controlledicon=" + reqId + "]");
                if (controlledDiv.classList.value.includes('slds-hide')) {
                    controlledDiv.classList.remove('slds-hide');
                    controlledIcon.iconName = 'utility:chevrondown';
                } else {
                    controlledDiv.classList.add('slds-hide');
                    controlledIcon.iconName = 'utility:chevronright';
                }
                break;

            default:
                break;
        }
    }

    showAllocations(event){
        let selectedReq = this.requests.filter(req => req.Id == event.currentTarget.dataset.id)[0];

        this.shiftUsersPending = ['None'];
        if(selectedReq.appliedResourceList && selectedReq.appliedResourceList.length){
            console.log('selectedReq.appliedResourceList >>', JSON.stringify(selectedReq.appliedResourceList));
            this.shiftUsersPending = selectedReq.appliedResourceList;    
        }

        this.shiftUsersApproved = ['None'];
        if(selectedReq.approvedResourceList && selectedReq.approvedResourceList.length){
            console.log('selectedReq.approvedResourceList >>', JSON.stringify(selectedReq.approvedResourceList));
            this.shiftUsersApproved = selectedReq.approvedResourceList;    
        }
        
        this.showAllocationDetails = true;
    }

    hideAllocations(event){
        this.showAllocationDetails = false;
    }

    formatDate(date) {
        var d = new Date(date),
            month = '' + (d.getMonth() + 1),
            day = '' + d.getDate(),
            year = d.getFullYear();

        if (month.length < 2)
            month = '0' + month;
        if (day.length < 2)
            day = '0' + day;

        return [year, month, day].join('-');
    }

    validateData(dataset) {
        console.log('validateData dataset >>', JSON.stringify(dataset));
        console.log('validateData dataset.shiftplanid >>', dataset.shiftplanid);
        
        let appliedStartDate = new Date(dataset.startdate) //new Date(slot.start / 1000);
        appliedStartDate.setHours(0, 0, 0, 0);
        console.log('validateData, appliedStartDate >>', appliedStartDate);
        
        let appliedEndDate = new Date(dataset.enddate) //new Date(slot.end / 1000);
        appliedEndDate.setHours(0, 0, 0, 0);
        console.log('validateData, appliedEndDate >>', appliedEndDate);

        let isValid = true;
        this.requests.forEach(req => {
            //console.log('validateData req >>', JSON.stringify(req));
            console.log('validateData req.Shift_Plan__c >>', req.Shift_Plan__c);
            
            if (req.Shift_Plan__c != dataset.shiftplanid && req.Shift_Allocations__r) {
                console.log('validateData.. condition satisfied');
                req.Shift_Allocations__r.forEach(allocation => {    
                    //if (allocation.Status__c == 'Approved' && appliedStartDate >= _tmpStDt && appliedEndDate <= _tmpEndDt) {
                    if (allocation.Status__c == 'Approved' && allocation.Service_Resource__r.RelatedRecordId == this.userId) {
                        let _tmpStDt = new Date(allocation.Start_Date__c);
                        let _tmpEndDt = new Date(allocation.End_Date__c);
                        console.log('validateData, _tmpStDt >>', _tmpStDt);
                        console.log('validateData, _tmpEndDt >>', _tmpEndDt);

                        _tmpStDt.setHours(0, 0, 0, 0);
                        _tmpEndDt.setHours(0, 0, 0, 0);
                        if(appliedStartDate > _tmpEndDt || appliedEndDate < _tmpStDt){
                        }else{
                            isValid = false;
                        }
                    }
                });
            }
        });

        if (!isValid) {
            this.dispatchEvent(new ShowToastEvent({
                message: "Already allocated to another Shift Plan!",
                variant: "error"
            }));
        }
        return isValid;
    }

    setProjects() {
        let self = this;
        let allocArr = [];
        self.requests = [...self._resource];

        if (self.requests) {
            self.requests.forEach(req => {
                let tmpReq = Object.assign({}, req);
                tmpReq.class = "slds-is-absolute lwc-allocation unavailable";
                tmpReq.style = self.calcStyle(tmpReq, false);
                tmpReq.labelStyle = self.calcLabelStyle(tmpReq);
                tmpReq.timeSlots = this.fetchTimeSlots(tmpReq);

                console.log('this.isAvailable >> ', this.isAvailable);
                console.log('tmpReq.unassignedProduct >> ', tmpReq.unassignedProduct);

                tmpReq.showRequest =  false;
                if(this.isAvailable){
                    tmpReq.showRequest = !tmpReq.unassignedProduct;
                }else{
                    tmpReq.showRequest = tmpReq.unassignedProduct;
                }
                if(tmpReq.showRequest){
                    if(!tmpReq.canApply && !tmpReq.isApplied){
                        tmpReq.showRequest = false;
                    }
                }

                allocArr.push(tmpReq);
            });
            
            self.requests = allocArr;
            self.requests.sort(function(a, b) {
                if(a.skillName == b.skillName){
                    return (a.startDateTime < b.startDateTime) ? -1 : (a.startDateTime > b.startDateTime) ? 1 : 0;
                }else{
                    return (a.skillName < b.skillName) ? -1 : (a.skillName > b.skillName) ? 1 : 0;
                }
            });

        }
    }

    calcClass(allocation) {
        let classes = ["slds-is-absolute", "lwc-allocation", "unavailable"];
        return classes.join(" ");
    }

    calcStyle(allocation, isRequest) {
        if (!this.times) {
            return;
        }

        const totalSlots = this.dateIncrement == 2 ? 12 : this.times.length;
        let styles = [
            "left: " + (allocation.left / totalSlots) * 100 + "%",
            "right: " +
            ((totalSlots - (allocation.right + (this.dateIncrement == 2 ? 0 : 1))) / totalSlots) * 100 +
            "%"
        ];

        //if ("Rejected" !== allocation.Status__c) {
            const backgroundColor = allocation.color;
            const colorMap = {
                Blue: "#1589EE",
                Green: "#4AAD59",
                Red: "#E52D34",
                Turqoise: "#0DBCB9",
                Navy: "#052F5F",
                Orange: "#E56532",
                Purple: "#62548E",
                Pink: "#CA7CCE",
                Brown: "#823E17",
                Lime: "#7CCC47",
                Gold: "#FCAF32",
                Yellow: '#e6e600'
            };

            let bgColor = colorMap.Blue;
            if(allocation.isApproved){
                bgColor = colorMap.Green;
            }else if(allocation.isPending){
                bgColor = colorMap.Yellow;
            }else if(allocation.isRejected){
                bgColor = colorMap.Red;
            }

            /*let bgColor = allocation.isApplied ?
                colorMap.Red
                : colorMap.Blue;*/

            //styles.push("background-color:" + (this.isAvailable ? bgColor : 'gray'));
            styles.push("background-color:" + bgColor);
        //}

        if (!isNaN(this.dragInfo.startIndex)) {
            styles.push("pointer-events: none");
            styles.push("transition: left ease 250ms, right ease 250ms");
        } else {
            styles.push("pointer-events: auto");
            styles.push("transition: none");
        }

        return styles.join("; ");
    }

    calcLabelStyle(allocation) {
        if (!this.times) {
            return;
        }

        const totalSlots = this.dateIncrement == 2 ? 12 : this.times.length;
        let left =
            allocation.left / totalSlots < 0 ? 0 : allocation.left / totalSlots;
        let right =
            (totalSlots - (allocation.right + 1)) / totalSlots < 0
                ? 0
                : (totalSlots - (allocation.right + 1)) / totalSlots;
        let styles = [
            "left: calc(" + left * 100 + "% + 15px)",
            "right: calc(" + right * 100 + "% + 30px)"
        ];

        if (!isNaN(this.dragInfo.startIndex)) {
            styles.push("transition: left ease 250ms, right ease 250ms");
        } else {
            styles.push("transition: none");
        }

        return styles.join("; ");
    }

    handleAddAllocationDataChange(event) {
        this.addAllocationData[event.target.dataset.field] = event.target.value;

        if (!this.addAllocationData.projectId) {
            this.addAllocationData.disabled = true;
        } else {
            this.addAllocationData.disabled = false;
        }
    }

    @api
    refreshDates(startDate, endDate, dateIncrement) {
        if (startDate && endDate && dateIncrement) {
            let times = [];
            let today = new Date();
            today.setHours(0, 0, 0, 0);
            today = today.getTime();

            for (
                let date = new Date(startDate);
                date <= endDate;
                date.setDate(date.getDate() + dateIncrement)
            ) {
                let time = {
                    class: "slds-col lwc-timeslot",
                    start: date.getTime()
                };

                if (dateIncrement > 1) {
                    let end = new Date(date);
                    end.setDate(end.getDate() + dateIncrement - 1);
                    time.end = end.getTime();
                } else {
                    time.end = date.getTime();

                    if (times.length % 7 === 6) {
                        time.class += " lwc-is-week-end";
                    }
                }

                if (today >= time.start && today <= time.end) {
                    time.class += " lwc-is-today";
                }
                time.key = this.generateKey();

                times.push(time);
            }

            this.times = times;
            this.startDate = startDate;
            this.endDate = endDate;
            this.dateIncrement = dateIncrement;
            this.setProjects();
        }
    }

    fetchTimeSlots(req) {
        let startDate = this.startDate,
            endDate = this.endDate,
            dateIncrement = this.dateIncrement;

        if (startDate && endDate && dateIncrement) {
            let times = [];
            let today = new Date();
            today.setHours(0, 0, 0, 0);
            today = today.getTime();

            for (
                let date = new Date(startDate);
                date <= endDate;
                date.setDate(date.getDate() + dateIncrement)
            ) {
                let time = {
                    class: "slds-col lwc-timeslot",
                    start: date.getTime()
                };

                if (dateIncrement > 1) {
                    let end = new Date(date);
                    end.setDate(end.getDate() + dateIncrement - 1);
                    time.end = end.getTime();
                } else {
                    time.end = date.getTime();

                    if (times.length % 7 === 6) {
                        time.class += " lwc-is-week-end";
                    }
                }

                if (today >= time.start && today <= time.end) {
                    time.class += " lwc-is-today";
                }

                let timeStart = new Date(time.start),
                    timeEnd = new Date(time.end);
                timeStart.setHours(0, 0, 0, 0);
                timeEnd.setHours(0, 0, 0, 0);
                if (this.oooDateList && this.oooDateList.includes(moment(time.start).format('YYYY-MM-DD'))) {
                    console.log('HERE');
                    time.class += " ooo";
                }

                if (req.Shift_Allocations__r) {
                    req.Shift_Allocations__r.forEach(alloc => {
                        let allocStart = new Date(alloc.Start_Date__c),
                            allocEnd = new Date(alloc.End_Date__c);
                        allocStart.setHours(0, 0, 0, 0);
                        allocEnd.setHours(0, 0, 0, 0);
                        if (timeStart <= allocEnd && timeEnd >= allocStart) {
                            time.class += alloc.Status__c == 'Pending' ? " pending" : alloc.Status__c == 'Approved' ? ' approved' : alloc.Status__c == 'Rejected' ? ' rejected' : '';
                        }
                    });
                }
                time.key = this.generateKey();
                times.push(time);
            }

            return times;
        }
    }

    @api
    closeAllocationMenu() {
        if (this.menuData.open) {
            this.menuData.show = true;
            this.menuData.open = false;
        } else {
            this.menuData = {
                show: false,
                open: false
            };
        }
    }

    openAllocationMenu(event) {
        let container = this.template.querySelector(
            "." + event.currentTarget.dataset.id + " .lwc-allocation"
        );
        let allocation = this.projects[container.dataset.project].allocations[
            container.dataset.allocation
        ];

        if (
            this.menuData.allocation &&
            this.menuData.allocation.Id === allocation.Id
        ) {
            this.closeAllocationMenu();
        } else {
            this.menuData.open = true;

            let projectHeight = this.template
                .querySelector(".project-container")
                .getBoundingClientRect().height;
            let allocationHeight = this.template
                .querySelector(".lwc-allocation")
                .getBoundingClientRect().height;
            let totalSlots = this.times.length;
            let rightEdge =
                ((totalSlots - (allocation.right + 1)) / totalSlots) * 100 + "%";

            let topEdge =
                projectHeight * container.dataset.project + allocationHeight;

            this.menuData.allocation = Object.assign({}, allocation);
            this.menuData.style =
                "top: " + topEdge + "px; right: " + rightEdge + "; left: unset";
        }
    }

    handleModalEditClick(event) {
        this.editAllocationData = {
            resourceName: this.resource.Name,
            projectName: this.menuData.allocation.projectName,
            id: this.menuData.allocation.Id,
            startDate: this.menuData.allocation.Start_Date__c,
            endDate: this.menuData.allocation.End_Date__c,
            effort: this.menuData.allocation.Effort__c,
            status: this.menuData.allocation.Status__c,
            isFullEdit: this.menuData.allocation.Status__c !== "Unavailable",
            disabled: false
        };
        this.template.querySelector(".edit-allocation-modal").show();

        this.closeAllocationMenu();
    }

    handleEditAllocationDataChange(event) {
        this.editAllocationData[event.target.dataset.field] = event.target.value;

        if (
            !this.editAllocationData.startDate ||
            !this.editAllocationData.endDate
        ) {
            this.editAllocationData.disabled = true;
        } else {
            this.editAllocationData.disabled = false;
        }

        this.editAllocationData.isFullEdit =
            this.editAllocationData.Status__c !== "Unavailable";
    }

    handleMenuDeleteClick(event) {
        this.editAllocationData = {
            id: this.menuData.allocation.Id
        };
        this.template.querySelector(".delete-modal").show();
        this.closeAllocationMenu();
    }

    fetchSelectedTimeSlots() {
        let selectedSlotsArr = [];

        this.requests.forEach(req => {
            req.timeSlots.forEach(slot => {
                if (slot.class.includes('approved')) {
                    selectedSlotsArr.push(slot.start);
                }
            });
        });
        return selectedSlotsArr;
    }

    generateKey(length = 8) {
        const chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
        var result = '';
        for (var i = length; i > 0; --i) result += chars[Math.floor(Math.random() * chars.length)];
        return result;
    }
}