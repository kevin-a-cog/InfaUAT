// Tejasvi Royal -> I2RT-2682: Weekend/Holiday Support & case Monitoring/Hand-off
// Tejasvi Royal -> I2RT-2634: Weekend/Holiday Support Notifications
// Last Modified Date: 20 August 2021 (Earlier: 8 July 2021)
// Last Modified By: Tejasvi Royal

import { LightningElement, api, track } from 'lwc';
import lookupQueueSearch from '@salesforce/apex/RaiseHandController.lookupQueueSearch';
import lookupCombinedSearch from '@salesforce/apex/RaiseHandController.lookupCombinedSearch';
import calculateWHSupportDateTimes from '@salesforce/apex/RaiseHandController.calculateWHSupportDateTimes';
// DEPRECATED: import lookupUserSearch from '@salesforce/apex/RaiseHandController.lookupUserSearch';
// DEPRECATED: import currentUserDateTime from '@salesforce/apex/RaiseHandController.currentUserDateTime';
// DEPRECATED: import addDaysToDateTime from '@salesforce/apex/RaiseHandController.addDaysToDateTime';
// DEPRECATED: import upcomingWeekendDateTimes from '@salesforce/apex/RaiseHandController.upcomingWeekendDateTimes';
// DEPRECATED: import CASE_FIELD_PRODUCT_QUEUES from '@salesforce/schema/Case.Product_Queues__c';
// DEPRECATED: import { getPicklistValues } from 'lightning/uiObjectInfoApi';

export default class CaseRaiseHandoff extends LightningElement {

    @api recordTypeId;

    @track supportStartDateTime;
    startDate;
    @track supportEndDateTime;
    @track handoffTypeHelp = 'Help Text for selected Handoff/Monitoring Type.';
    @track daysToSupport = '1';
    @track isDirectHandoff = false;
    @track isWeekendHolidayMonitoring = false;
    @track isWHDateTimeNotCustom = true;
    @track isWHDateTimeCustom = false;
    @api classname;
    @api classnamesteps;

    // DEPRECATED: @track handoffQueuePickListValues;
    // DEPRECATED: @track holidayStartDateTime;
    // DEPRECATED: @track holidayEndDateTime;
    // DEPRECATED: @track weekendStartDateTime;
    // DEPRECATED: @track weekendEndDateTime;
    // DEPRECATED: @track daysButtonVariant = "";
    // DEPRECATED: @track isHandoffToUser = false;
    // DEPRECATED: @track isHandoffToQueue = false;
    // DEPRECATED: @track isWeekendMonitoring = false;
    // DEPRECATED: @track isHolidayMonitoring = false;

    @track handoffTypeOptions = [
        { label: 'Live/Queue Handoff', value: 'Live/Queue Handoff' },
        { label: 'Follow the Sun Monitoring', value: 'Follow the Sun Monitoring' },
        { label: 'Weekend/Holiday Monitoring', value: 'Weekend/Holiday Monitoring' }
        // DEPRECATED: { label: 'Live Handoff', value: 'Live Handoff' },
        // DEPRECATED: { label: 'Queue Handoff', value: 'Queue Handoff' },
        // DEPRECATED: { label: 'Monitor Case', value: 'Monitor Case' },
        // DEPRECATED: { label: 'Holiday Monitoring', value: 'Holiday Monitoring' },
        // DEPRECATED: { label: 'Weekend Monitoring', value: 'Weekend Monitoring' }
    ];   

    /* DEPRECATED:
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: CASE_FIELD_PRODUCT_QUEUES })
    handoffQueuePickListValues;*/

    connectedCallback() {
        // DEPRECATED:
        /* upcomingWeekendDateTimes()
            .then(results => {
                //this.weekendStartDateTime = results[0];
                //this.weekendEndDateTime = results[1];
                this.supportStartDateTime = results[0];
                this.supportEndDateTime = results[1];
                
            })
            .catch(error => {
                console.log('Date/Time Retrieval FAILED -> ' + error);
            }); */
    }

    handleHandoffTypeChange(event) {
        const handoffType = event.target.value;
        switch (handoffType) {
            case 'Live/Queue Handoff':
                this.handoffTypeHelp = 'Direct Handoff to an Engineer or Queue.';
                this.isDirectHandoff = true;
                this.isFollowTheSunModel = false;
                this.isWeekendHolidayMonitoring = false;
                break;
            case 'Follow the Sun Monitoring':
                this.handoffTypeHelp = 'On-demand Handoff to a Queue if there is any Inbound Activity, while the case is monitored for 16 hours.';
                this.isDirectHandoff = false;
                this.isFollowTheSunModel = true;
                this.isWeekendHolidayMonitoring = false;
                break;
            case 'Weekend/Holiday Monitoring':
                this.handoffTypeHelp = 'Delegating to Weekend/Holiday Support to monitor on specified days.';
                this.isDirectHandoff = false;
                this.isFollowTheSunModel = false;
                this.isWeekendHolidayMonitoring = true;
                this.showWHSupportDateTimes();
                //DEPRECATED: this.callCurrentDTWithAddDays();
                break;
            default:
                break;
        }
        console.log('handoffType -> ' + handoffType);
        this.dispatchEvent(new CustomEvent('handofftypechange', { detail: handoffType }));
    }
    handleQueueLookupSearch(event) {
        const lookupElement = event.target;
        lookupQueueSearch(event.detail)
            .then(results => {
                lookupElement.setSearchResults(results);
            })
            .catch(error => {
                console.log('Queue Lookup Failed -> ' + error);
            });
    }
    handleQueueLookupSelectionChange(event) {
        const selectedQueueId = event.detail.values().next().value;
        console.log('[Child] selectedQueueId -> ' + selectedQueueId);
        this.dispatchEvent(new CustomEvent('lookupqueueselectionchange', { detail: selectedQueueId }));
    }
    handleCombinedLookupSearch(event) {
        const lookupElement = event.target;
        lookupCombinedSearch(event.detail)
            .then(results => {
                lookupElement.setSearchResults(results);
            })
            .catch(error => {
                console.log('Combined Lookup Failed -> ' + error);
            });
    }
    handleCombinedLookupSelectionChange(event) {
        const selectedId = event.detail.values().next().value;
        console.log('[Child] selectedId -> ' + selectedId);
        this.dispatchEvent(new CustomEvent('lookupcombinedselectionchange', { detail: selectedId }));
    }
    handleDaysToSupportChange(event) {
        this.daysToSupport = event.target.label;
        console.log('daysToSupport = ' + this.daysToSupport);

        let buttonGroupElement = this.template.querySelector('lightning-button-group');

        buttonGroupElement.querySelectorAll('lightning-button').forEach(item => item.variant = "neutral");

        event.target.variant = "brand";

        this.showWHSupportDateTimes();
        //DEPRECATED: this.callAddDaysToDT();
    }
    handleWHDateTimeCustomize() {
        this.isWHDateTimeNotCustom = false;
        this.isWHDateTimeCustom = true;
    }
    showWHSupportDateTimes() {
        calculateWHSupportDateTimes({daysToAddStr: this.daysToSupport})
            .then(results => {
                this.supportStartDateTime = results[0];
                this.supportEndDateTime = results[1];
                if (this.supportStartDateTime && this.supportEndDateTime) {
                    this.dispatchEvent(new CustomEvent('supportstartvalue', { detail: this.supportStartDateTime }));
                    this.dispatchEvent(new CustomEvent('supportendvalue', { detail: this.supportEndDateTime }));
                }
            })
            .catch(error => {
                console.log('calculateWHSupportDateTimes -> Support Date/Time Retrieval FAILED -> ' + JSON.stringify(error));
            });
    }
    handleHandoffStartDTChange(event) {
        if(this.startDate == null || this.startDate === undefined){
            this.startDate = this.supportStartDateTime;
        }

        this.supportStartDateTime = event.detail.value;
        console.log('[Child] supportStartDateTime -> ' + this.supportStartDateTime);
        this.dispatchEvent(new CustomEvent('supportstartvalue', { detail: this.supportStartDateTime }));
        let element1 = this.template.querySelector("[data-name = 'handoffenddatetime']");
        let element = this.template.querySelector("[data-name = 'handoffstartdatetime']");
        if (!element.value) {
            element.setCustomValidity("Handoff Start Date/Time is required.");
        }
        else if (this.supportEndDateTime && (new Date(element.value) >= new Date(this.supportEndDateTime))) {
            element.setCustomValidity("Start Date/Time cannot be later than End Date/Time.");
        }else if(new Date(element.value) < new Date(this.startDate)){
            element.setCustomValidity("Start Date/Time cannot be less than Current Date/Time.");
        }
        else {
            element.setCustomValidity("");
            element1.setCustomValidity("");
        }
        element1.reportValidity();
        element.reportValidity();
    }
    handleHandoffEndDTChange(event) {
        this.supportEndDateTime = event.detail.value;
        console.log('[Child] supportEndDateTime -> ' + this.supportEndDateTime);
        this.dispatchEvent(new CustomEvent('supportendvalue', { detail: this.supportEndDateTime }));

        let element = this.template.querySelector("[data-name = 'handoffenddatetime']");
        let element1 = this.template.querySelector("[data-name = 'handoffstartdatetime']");
        
        if (!element.value) {
            element.setCustomValidity("Handoff End Date/Time is required.");
        }
        else if (this.supportStartDateTime && (new Date(element.value) <= new Date(this.supportStartDateTime))) {
                element.setCustomValidity("End Date/Time cannot be earlier than Start Date/Time.");
        }
        else {
            element.setCustomValidity("");
            
            element1.setCustomValidity("");
        }
        element.reportValidity();
        element1.reportValidity();
    }
    handleHandoffCommentsChange(event) {
        const handoffComments = event.detail.value;
        console.log('[Child] handoffComments -> ' + handoffComments);
        this.dispatchEvent(new CustomEvent('handoffcommentschange', { detail: handoffComments }));
    }
    handleHandoffStepsTakenChange(event) {
        const handoffStepsTaken = event.detail.value;
        console.log('[Child] handoffStepsTaken -> ' + handoffStepsTaken);
        this.dispatchEvent(new CustomEvent('handoffstepstakenchange', { detail: handoffStepsTaken }));
    }
    // DEPRECATED FUNCTIONS:
    //-----------------------
    /* handleHandoffUserChange(event) {
        const handoffUser = event.detail.value;
        console.log('[Child] handoffUser -> ' + handoffUser);
        this.dispatchEvent(new CustomEvent('handoffuserchange', { detail: handoffUser }));
    } */
    /* handleUserLookupSearch(event) {
        const lookupElement = event.target;
        lookupUserSearch(event.detail)
            .then(results => {
                lookupElement.setSearchResults(results);
            })
            .catch(error => {
                console.log('User Lookup Failed -> ' + error);
            });
    } */
    /* handleUserLookupSelectionChange(event) {
        const selectedUserId = event.detail.values().next().value;
        console.log('[Child] selectedUserId -> ' + selectedUserId);
        this.dispatchEvent(new CustomEvent('lookupuserselectionchange', { detail: selectedUserId }));
    }  */
    /* callCurrentDTWithAddDays() {
        currentUserDateTime()
            .then(results => {
                this.supportStartDateTime = results;
                if (this.supportStartDateTime) {
                    this.dispatchEvent(new CustomEvent('supportstartvalue', { detail: this.supportStartDateTime }));
                    this.callAddDaysToDT();
                }
            })
            .catch(error => {
                console.log('callCurrentDT -> Date/Time Retrieval FAILED -> ' + JSON.stringify(error));
            });
    } */
    /* callAddDaysToDT() {
        addDaysToDateTime({ userDTStr: this.supportStartDateTime, daysToAddStr: this.daysToSupport })
            .then(results => {
                this.supportEndDateTime = results;
                if (this.supportEndDateTime) {
                    this.dispatchEvent(new CustomEvent('supportendvalue', { detail: this.supportEndDateTime }));
                }
            })
            .catch(error => {
                console.log('callAddDaysToDT -> Date/Time Retrieval FAILED -> ' + JSON.stringify(error));
            });
    } */
}