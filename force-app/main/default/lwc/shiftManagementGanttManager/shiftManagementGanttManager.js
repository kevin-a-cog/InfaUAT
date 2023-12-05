import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { updateRecord } from 'lightning/uiRecordApi';

import processShiftAllocation from "@salesforce/apex/ShiftManagementController.processShiftAllocation";

import FIELD_SHIFT_ALLOCATION_ID from '@salesforce/schema/Shift_Allocation__c.Id';
import FIELD_SHIFT_ALLOCATION_STATUS from '@salesforce/schema/Shift_Allocation__c.Status__c';

export default class ShiftManagementGanttManager extends LightningElement {
    @api projectId; // used on project page for quick adding of allocations
    @api
    get resource() {
        return this._resource;
    }
    set resource(_resource) {
        this._resource = _resource;
        this.setProjects();
    }

    // dates
    @api startDate;
    @api endDate;
    @api dateIncrement;
    @track _resource;
    showSpinner = false;
    @track request;

    allocationIdToDelete;
    @track showConfirmationModal=false;

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

                times.push(time);
            }

            this.times = times;
            this.startDate = startDate;
            this.endDate = endDate;
            this.dateIncrement = dateIncrement;
            this.setProjects();

            console.log('refreshDates this.times >> ', this.times);
        }
    }

    // used by parent level window
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

    // modal data
    @track addAllocationData = {};
    @track editAllocationData = {};

    @track menuData = {
        open: false,
        show: false,
        style: ""
    };

    @track projects = [];

    get isHourView() {
        return this.dateIncrement == 2;
    }

    connectedCallback() {
        let globalStyle = document.createElement('style');
        globalStyle.innerHTML = `
        .rejected-allocation .slds-button {
        background: #ff6666 !important;
        color: white !important;
        border: 1px solid red;
        }

        .reject-allocation .slds-button {
        background: red !important;
        color: white !important;
        border: 1px solid red;
        }

        .reject-allocation .slds-button:hover {
        background: #cc0000 !important;
        color: white !important;
        border: 1px solid red;
        }
        
        
        .approved-allocation .slds-button {
        background: #00b300 !important;
        color: white !important;
        }`;
        document.head.appendChild(globalStyle);
        this.refreshDates(this.startDate, this.endDate, this.dateIncrement);
    }

    // calculate allocation classes
    calcClass(allocation) {
        let classes = ["slds-is-absolute", "lwc-allocation", "unavailable"];
        return classes.join(" ");
    }

    // calculate allocation positions/styles
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
        if ("Rejected" !== allocation.Status__c) {
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
            styles.push("background-color:" + (isRequest ? colorMap.Blue : (allocation.isApproved ? colorMap.Green : colorMap.Yellow)));
        }

        if (!isNaN(this.dragInfo.startIndex)) {
            styles.push("pointer-events: none");
            styles.push("transition: left ease 250ms, right ease 250ms");
        } else {
            styles.push("pointer-events: auto");
            styles.push("transition: none");
        }

        return styles.join("; ");
    }

    // calculate allocation label position
    calcLabelStyle(allocation) {
        if (!this.times) {
            return;
        }

        const totalSlots = this.dateIncrement == 2 ? 12 : this.times.length;
        let left =
            ((allocation.left / totalSlots) < 0) ? 0 : (allocation.left / totalSlots);
        let right =
            ((totalSlots - (allocation.right)) / totalSlots) < 0
                ? 0
                : ((totalSlots - (allocation.right)) / totalSlots);
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

    approveRejectShiftAllocation(shiftAllocationId, approveReject, successMessage, errorMessage){
        this.showSpinner = true;
        processShiftAllocation({
            shiftAllocationId: shiftAllocationId,
            status: approveReject
        }).then(() => {
            if(successMessage){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: successMessage,
                        variant: 'success'
                    })
                );    
            }

            this.dispatchEvent(new CustomEvent('refresh'));
        }).catch(error => {
            if(errorMessage){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: errorMessage,
                        variant: 'error'
                    })
                );    
            }

            console.log('update allocation error>>', JSON.stringify(error));
        }).finally(() => {
            this.showSpinner = false;
        });
    }

    handleClick(event) {
        switch (event.currentTarget.name) {
            case 'approveReject':
                this.approveRejectShiftAllocation(event.currentTarget.dataset.id, event.currentTarget.dataset.status);
                
            case 'edit':
                this.dispatchEvent(new CustomEvent('editrequest', {
                    detail: {
                        requestId: event.currentTarget.dataset.id,
                        shiftPlanId: event.currentTarget.dataset.shiftplan
                    }
                }));
                break;
            case 'deleteAllocation':
                this.allocationIdToDelete = event.currentTarget.dataset.id;
                this.showConfirmationModal = true;
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

    saveDeleteAllocation(event){
        this.deleteAllocation(event);
        this.showConfirmationModal = false;
    }
    
    cancelDeleteAllocation(event){
        this.showConfirmationModal = false;
    }

    deleteAllocation(event){
        this.showSpinner = true;

        const fields = {};
        fields[FIELD_SHIFT_ALLOCATION_ID.fieldApiName] = this.allocationIdToDelete;
        fields[FIELD_SHIFT_ALLOCATION_STATUS.fieldApiName] = 'Rejected';

        const recordInput = { fields };

        updateRecord(recordInput)
        .then(() => {
            this.showSpinner = false;

            //T02
            this.approveRejectShiftAllocation(this.allocationIdToDelete, 'Reject', 'The allocation deleted successfully!', 'Error deleting the allocation!');
        })
        .catch(error => {
            this.showSpinner = false;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting the allocation!',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }

    @api
    setProjects() {
        let self = this;
        self.projects = [];
        self.request = Object.assign({
            class: "slds-is-absolute lwc-allocation",
            style: self.calcStyle(self._resource, true),
            labelStyle: self.calcLabelStyle(self._resource)
        }, self._resource);
        let allocArr = [];
        if (self.request.Shift_Allocations__r) {
            self.request.Shift_Allocations__r.forEach(allocation => {
                let tmpAlloc = Object.assign({}, allocation);
                tmpAlloc.class = "slds-is-absolute lwc-allocation unavailable";
                tmpAlloc.style = self.calcStyle(tmpAlloc, false);
                tmpAlloc.labelStyle = self.calcLabelStyle(tmpAlloc);
                
                allocArr.push(tmpAlloc);
            });
            self.request.Shift_Allocations__r = allocArr;
        }
    }

    handleTimeslotClick(event) {
        const start = new Date(parseInt(event.currentTarget.dataset.start, 10));
        const end = new Date(parseInt(event.currentTarget.dataset.end, 10));
        const startUTC = start.getTime() + start.getTimezoneOffset() * 60 * 1000;
        const endUTC = end.getTime() + end.getTimezoneOffset() * 60 * 1000;

        if (this.projectId) {
            this._saveAllocation({
                startDate: startUTC + "",
                endDate: endUTC + ""
            });
        } else {
            let self = this;
            getProjects()
                .then(projects => {
                    projects = projects.map(project => {
                        return {
                            value: project.Id,
                            label: project.Name
                        };
                    });

                    projects.unshift({
                        value: "Unavailable",
                        label: "Unavailable"
                    });

                    self.addAllocationData = {
                        projects: projects,
                        startDate: startUTC + "",
                        endDate: endUTC + "",
                        disabled: true
                    };

                    self.template.querySelector(".add-allocation-modal").show();
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            message: error.body.message,
                            variant: "error"
                        })
                    );
                });
        }
    }

    handleAddAllocationDataChange(event) {
        this.addAllocationData[event.target.dataset.field] = event.target.value;

        if (!this.addAllocationData.projectId) {
            this.addAllocationData.disabled = true;
        } else {
            this.addAllocationData.disabled = false;
        }
    }

    addAllocationModalSuccess() {
        if ("Unavailable" === this.addAllocationData.projectId) {
            this.addAllocationData.projectId = null;
            this.addAllocationData.status = "Unavailable";
        }

        this._saveAllocation({
            projectId: this.addAllocationData.projectId,
            status: this.addAllocationData.status,
            startDate: this.addAllocationData.startDate,
            endDate: this.addAllocationData.endDate
        })
            .then(() => {
                this.addAllocationData = {};
                this.template.querySelector(".add-allocation-modal").hide();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: error.body.message,
                        variant: "error"
                    })
                );
            });
    }

    _saveAllocation(allocation) {
        if (
            null == allocation.projectId &&
            null != this.projectId &&
            !allocation.status
        ) {
            allocation.projectId = this.projectId;
        }

        if (null == allocation.resourceId) {
            allocation.resourceId = this.resource.Id;
        }

        return saveAllocation(allocation)
            .then(() => {
                // send refresh to top
                this.dispatchEvent(
                    new CustomEvent("refresh", {
                        bubbles: true,
                        composed: true
                    })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: error.body.message,
                        variant: "error"
                    })
                );
            });
    }

    /*** Drag/Drop ***/
    dragInfo = {};
    handleDragStart(event) {
        let container = this.template.querySelector('[data-allocation="' + event.currentTarget.dataset.id + '"]')
        this.dragInfo.allocationId = event.currentTarget.dataset.id;
        this.dragInfo.projectIndex = container.dataset.project;
        this.dragInfo.allocationIndex = container.dataset.allocation;
        this.dragInfo.newAllocation = this.request.Shift_Allocations__r.filter(all => all.Id == event.currentTarget.dataset.id)[0];

        // hide drag image
        container.style.opacity = 0;
        setTimeout(function () {
            container.style.pointerEvents = "none";
        }, 0);
    }

    handleLeftDragStart(event) {
        this.dragInfo.direction = "left";
        this.handleDragStart(event);
    }

    handleRightDragStart(event) {
        this.dragInfo.direction = "right";
        this.handleDragStart(event);
    }

    handleDragEnd(event) {
        event.preventDefault();

        const projectIndex = this.dragInfo.projectIndex;
        const allocationIndex = this.dragInfo.allocationIndex;
        const allocation = this.dragInfo.newAllocation;

        this.projects = JSON.parse(JSON.stringify(this.projects));

        this.request.Shift_Allocations__r.forEach(all => {
            if (all.Id == event.currentTarget.dataset.id) {
                all = JSON.parse(JSON.stringify(allocation));
            }
        });

        let startDate = new Date(allocation.Start_Date__c + "T00:00:00");
        let endDate = new Date(allocation.End_Date__c + "T00:00:00");

        this._saveAllocation({
            allocationId: allocation.Id,
            startDate:
                startDate.getTime() + startDate.getTimezoneOffset() * 60 * 1000 + "",
            endDate: endDate.getTime() + endDate.getTimezoneOffset() * 60 * 1000 + ""
        });

        this.dragInfo = {};
        this.template.querySelector('[data-allocation="' + event.currentTarget.dataset.id + '"]').style.pointerEvents = "auto";
    }

    handleDragEnter(event) {
        const projectIndex = this.dragInfo.projectIndex;
        const allocationIndex = this.dragInfo.allocationIndex;
        const direction = this.dragInfo.direction;
        const start = new Date(parseInt(event.currentTarget.dataset.start, 10));
        const end = new Date(parseInt(event.currentTarget.dataset.end, 10));
        const index = parseInt(event.currentTarget.dataset.index, 10);

        if (isNaN(this.dragInfo.startIndex)) {
            this.dragInfo.startIndex = index;
        }

        let allocation = JSON.parse(
            JSON.stringify(this.request.Shift_Allocations__r.filter(all => all.Id == this.dragInfo.allocationId)[0])
        );

        switch (direction) {
            case "left":
                if (index <= allocation.right) {
                    allocation.Start_Date__c = start.toJSON().substr(0, 10);
                    allocation.left = index;
                } else {
                    allocation = this.dragInfo.newAllocation;
                }
                break;
            case "right":
                if (index >= allocation.left) {
                    allocation.End_Date__c = end.toJSON().substr(0, 10);
                    allocation.right = index;
                } else {
                    allocation = this.dragInfo.newAllocation;
                }
                break;
            default:
                let deltaIndex = index - this.dragInfo.startIndex;
                let firstSlot = this.times[0];
                let startDate = new Date(firstSlot.start);
                let endDate = new Date(firstSlot.end);

                allocation.left = allocation.left + deltaIndex;
                allocation.right = allocation.right + deltaIndex;

                startDate.setDate(
                    startDate.getDate() + allocation.left * this.dateIncrement
                );
                endDate.setDate(
                    endDate.getDate() + allocation.right * this.dateIncrement
                );

                allocation.Start_Date__c = startDate.toJSON().substr(0, 10);
                allocation.End_Date__c = endDate.toJSON().substr(0, 10);
        }

        this.dragInfo.newAllocation = allocation;
        this.template.querySelector('[data-allocation="' + this.dragInfo.allocationId + '"]').style = this.calcStyle(allocation);
        // this.template.querySelector(
        //   "." + allocation.Id + " .lwc-allocation-label"
        // ).style = this.calcLabelStyle(allocation);
    }
    /*** /Drag/Drop ***/

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

    editAllocationModalSuccess() {
        const startDate = new Date(this.editAllocationData.startDate + "T00:00:00");
        const endDate = new Date(this.editAllocationData.endDate + "T00:00:00");

        this._saveAllocation({
            allocationId: this.editAllocationData.id,
            projectId: this.editAllocationData.projectId,
            startDate:
                startDate.getTime() + startDate.getTimezoneOffset() * 60 * 1000 + "",
            endDate:
                endDate.getTime() + startDate.getTimezoneOffset() * 60 * 1000 + "",
            effort: this.editAllocationData.effort,
            status: this.editAllocationData.status
        })
            .then(() => {
                this.editAllocationData = {};
                this.template.querySelector(".edit-allocation-modal").hide();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: error.body.message,
                        variant: "error"
                    })
                );
            });
    }

    handleMenuDeleteClick(event) {
        this.editAllocationData = {
            id: this.menuData.allocation.Id
        };
        this.template.querySelector(".delete-modal").show();
        this.closeAllocationMenu();
    }

    handleMenuDeleteSuccess() {
        deleteAllocation({
            allocationId: this.editAllocationData.id
        })
            .then(() => {
                this.template.querySelector(".delete-modal").hide();
                this.dispatchEvent(
                    new CustomEvent("refresh", {
                        bubbles: true,
                        composed: true
                    })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: error.body.message,
                        variant: "error"
                    })
                );
            });
    }
}