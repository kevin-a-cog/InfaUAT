/*

Change History
****************************************************************************************************
ModifiedBy      Date        Jira No.    Tag     Description
****************************************************************************************************
balajip         11/22/2021  I2RT-4425   T01     added option to delete a shift plan
*/

import { api, LightningElement, track } from 'lwc';

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { createRecord, updateRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';

import Shift_Type_Not_Requiring_Skill from '@salesforce/label/c.Shift_Type_Not_Requiring_Skill';
import Shift_Creation_Capture_Business_Hours from '@salesforce/label/c.Shift_Creation_Capture_Business_Hours';

import searchShiftPlan from "@salesforce/apex/ShiftManagementController.searchShiftPlan";
import createShiftPlanAndRequest from "@salesforce/apex/ShiftManagementController.createShiftPlanAndRequest";
import getShiftRequestForShiftPlan from "@salesforce/apex/ShiftManagementController.getShiftRequestForShiftPlan";
import getShiftPlanWithRequests from "@salesforce/apex/ShiftManagementController.getShiftPlanWithRequests";
import deleteShiftPlan from "@salesforce/apex/ShiftManagementController.deleteShiftPlan"; //T01

export default class CreateShiftRequest extends LightningElement {
    @api shiftPlanIdForEdit;
    shiftPlanRadioValue = 'createNew';
    shiftPlanId;
    startDate;
    endDate;
    reqToDelete = [];

    @track showConfirmationModal=false;//T01

    @track spinnerCounter = 1;
    
    get showSpinner(){
        return this.spinnerCounter > 0;
    }

    get shiftTypesNotRequiringSkill() {
        return Shift_Type_Not_Requiring_Skill ? Shift_Type_Not_Requiring_Skill.split(';') : [];
    }

    get shiftReqPlanOptions() {
        return [
            { label: 'Create New', value: 'createNew' },
            { label: 'Use Existing', value: 'useExisting' },

        ];
    }

    get isUseExistingShiftPlan() {
        return this.shiftPlanRadioValue == 'useExisting';
    }

    get showBusinessHoursField(){
        return Shift_Creation_Capture_Business_Hours == '1' ? true: false;
    }

    get maxDate() {
        let today = new Date();
        let month = today.getMonth() + 1;
        let day = today.getDate();
        day = day.toString().length > 1 ? day : `0${day}`;
        month = month.toString().length > 1 ? month : `0${month}`;
        let maxDate = [today.getFullYear(), month, day].join('-');
        return maxDate;
    }

    /*
    @wire(getShiftPlanWithRequests, { shiftPlanId: '$shiftPlanIdForEdit' })
    wiredGetShiftPlanWithRequests(value) {
        // Destructure the provisioned value 
        const { data, error } = value;
    
        if (error) {
            console.log('wiredGetShiftPlanWithRequests ERROR>>>>>', JSON.stringify(error));
        } else if (data) {
            this.processShiftPlanData(value);
        }
    }
    */

    getShiftPlanData(){
        this.spinnerCounter++;
        getShiftPlanWithRequests({ shiftPlanId: this.shiftPlanIdForEdit })
        .then(data => {
            this.processShiftPlanData(data);
            this.spinnerCounter--;
        }).catch(err => {
            console.log('getShiftPlanWithRequests ERROR>>>>>', JSON.stringify(err));
            this.spinnerCounter--;
        });
    }
    
    processShiftPlanData(data){
        if (data.Name) {
            //console.log('wiredGetShiftPlanWithRequests data.Name >> ', data.Name);
            this.template.querySelector('[data-name="Name"]').value = data.Name;
        }
        if (data.Type__c) {
            this.template.querySelector('[data-name="Type__c"]').value = data.Type__c;
        }
        if (data.Business_Hours__c) {
            let inputBusinessHours = this.template.querySelector('[data-name="Business_Hours__c"]');
            if(inputBusinessHours){
                this.template.querySelector('[data-name="Business_Hours__c"]').value = data.Business_Hours__c;
            }
        }
        if (data.Start_Date__c) {
            this.template.querySelector('[data-name="Start_Date__c"]').value = data.Start_Date__c;
        }
        if (data.End_Date__c) {
            this.template.querySelector('[data-name="End_Date__c"]').value = data.End_Date__c;
        }
        if (data.Shift_Requests__r) {
            this.skillRequests = JSON.parse(JSON.stringify(data.Shift_Requests__r));
        }
    }

    getDefaultStartDate() {
        let today = new Date(),
            day = today.getDate(),
            month = today.getMonth() + 1, //January is 0
            year = today.getFullYear();
        if (day < 10) {
            day = '0' + day;
        }
        if (month < 10) {
            month = '0' + month;
        }
        today = year + '-' + month + '-' + day;
        return today;
    }

    getDefaultEndDate() {
        let defaultEndDate = new Date();
        defaultEndDate.setDate(defaultEndDate.getDate() + 1);
        let day = defaultEndDate.getDate(),
            month = defaultEndDate.getMonth() + 1, //January is 0
            year = defaultEndDate.getFullYear();
        if (day < 10) {
            day = '0' + day;
        }
        if (month < 10) {
            month = '0' + month;
        }
        defaultEndDate = year + '-' + month + '-' + day;
        return defaultEndDate;
    }

    connectedCallback() {
        let globalStyle = document.createElement('style');
        globalStyle.innerHTML = `
		.slds-radio {
            display : inline-block !important;
        }

        .remove-request .slds-button {
            background: #cc0000;
        }

        .remove-request .slds-button:hover {
            background: #b30000;
        }

        .remove-request .slds-button svg {
            fill: white;
        }

        .remove-request .slds-button:hover svg {
            fill: white;
        }
                                        `;
        document.head.appendChild(globalStyle);
        this.startDate = this.getDefaultStartDate();
        this.endDate = this.getDefaultEndDate();

        console.log('createShiftRequest, connectedCallback, shiftPlanIdForEdit >> ', this.shiftPlanIdForEdit);
        if(this.shiftPlanIdForEdit){
            this.getShiftPlanData();
        }
        this.spinnerCounter--;
    }

    generateKey(length = 8) {
        const chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
        var result = '';
        for (var i = length; i > 0; --i) result += chars[Math.floor(Math.random() * chars.length)];
        return result;
    }

    @track
    skillRequests = [{
        Skill__c: '',
        Resource_Count__c: '',
        Allocation_Type__c: '',
        isSkillRequired: true
    }];

    get isSkillRequestAvailable() {
        return this.skillRequests.length > 0;
    }

    handleClick(event) {
        switch (event.target.name) {
            case 'addReq':
                this.skillRequests.push({
                    Skill__c: '',
                    Resource_Count__c: '',
                    Allocation_Type__c: '',
                    isSkillRequired: true
                });
                break;
            case 'saveShiftPlan':
                if (this.validateForm()) {
                    this.createShiftPlan();
                }
                break;
            case 'cancelShiftPlan':
                this.dispatchEvent(new CustomEvent('close', { detail: false }));
                break;
            //T01
            case 'removePlan':
                this.showConfirmationModal = true;
                break;
            case 'removeReq':
                let _tmpSkillReqs = this.skillRequests;
                if (_tmpSkillReqs[event.target.dataset.index].Id) {
                    this.reqToDelete.push(_tmpSkillReqs[event.target.dataset.index].Id);
                }
                _tmpSkillReqs.splice(event.target.dataset.index, 1);
                this.skillRequests = _tmpSkillReqs;

                break;
            default:
                break;
        }
    }

    createShiftPlan() {
        const fields = {};
        this.template.querySelectorAll('[data-field="shiftPlanField"]').forEach(ip => {
            fields[ip.name] = ip.value
        });

        const successCallback = res => {
            const planFields = {};
            this.template.querySelectorAll('[data-field="shiftPlanField"]').forEach(ip => {
                planFields[ip.name] = ip.value
            });

            let _shiftReqArr = [];
            this.template.querySelectorAll('lightning-record-edit-form').forEach(form => {
                console.log('createShiftPlan, form.name >>', form.name);
                if(form.name && form.name === 'shiftRequestAdd'){
                    let _request = {
                        Allocation_Type__c : planFields['Type__c'],
                        Business_Hours__c : planFields['Business_Hours__c']
                    };
                    form.querySelectorAll('lightning-input-field').forEach(ip => {
                        _request[ip.fieldName] = ip.value;
                    });
                    if (form.recordId && this.shiftPlanIdForEdit) {
                        _request['Id'] = form.recordId;
                    }
                    _shiftReqArr.push(Object.assign({ Shift_Plan__c: this.shiftPlanIdForEdit ? this.shiftPlanIdForEdit : res.id }, _request));    
                }
            });

            this.spinnerCounter++;
            createShiftPlanAndRequest({
                lstShiftRequestToUpsert: _shiftReqArr,
                lstShiftRequestToDeleteId: this.reqToDelete
            }).then(() => {
                this.showToast(undefined, 'Shift Plan created/updated successfully', undefined);
                this.dispatchEvent(new CustomEvent('close', { detail: true }));
                getRecordNotifyChange([{recordId: this.shiftPlanIdForEdit ? this.shiftPlanIdForEdit : res.id}]);
                this.spinnerCounter--;
            }).catch(err => {
                console.log(JSON.stringify(err))
                this.showToast(undefined, err.body.message, 'error');
                this.spinnerCounter--;
            });
        }

        const errorCallback = error => {
            console.log('ERROR>>>', JSON.parse(JSON.stringify(error)));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        }

        if (this.shiftPlanIdForEdit) {
            fields['Id'] = this.shiftPlanIdForEdit;
            const recordInput = { fields };
            this.spinnerCounter++;
            updateRecord(recordInput)
            .then(successCallback)
            .catch(errorCallback)
            .finally(() => {
                this.spinnerCounter--;
            });
        } else {
            const recordInput = { apiName: 'Shift_Plan__c', fields };
            this.spinnerCounter++;
            createRecord(recordInput)
            .then(successCallback)
            .catch(errorCallback)
            .finally(() => {
                this.spinnerCounter--;
            });
        }
    }

    validateForm() {
        let isValid = true;
        if (this.isUseExistingShiftPlan) {
            if (!this.shiftPlanId) {
                isValid = false;
                this.template.querySelectorAll('c-lookup').forEach(cmp => {
                    cmp.errors = [{ id: 123, message: 'Please select a Shift Plan' }];
                });
            } else {
                this.template.querySelectorAll('c-lookup').forEach(cmp => {
                    cmp.errors = [];
                });
            }
        }
        this.template.querySelectorAll('lightning-input-field').forEach(ip => {
            if (ip.required && !ip.value || (!isNaN(ip.value) && ip.value < 0)) {
                isValid = false;
                ip.classList.add('slds-has-error');
            } else {
                ip.classList.remove('slds-has-error');
            }
        });

        const startDate = this.template.querySelector('[data-name="Start_Date__c"]');
        const endDate = this.template.querySelector('[data-name="End_Date__c"]');
        if (startDate.value > endDate.value) {
            isValid = false;
            startDate.setCustomValidity('Start date should be lesser than End date');
            startDate.reportValidity();
            endDate.setCustomValidity('Start date should be lesser than End date');
            endDate.reportValidity();
        } else {
            startDate.setCustomValidity('');
            startDate.reportValidity();
            endDate.setCustomValidity('');
            endDate.reportValidity();
        }

        this.template.querySelectorAll('[data-field="shiftPlanField"]').forEach(ip => {
            const validity = ip.reportValidity();
            if (isValid) {
                isValid = validity;
            }
        });

        if (!isValid) {
            this.showToast('', 'Please review the errors on the page', 'error');
        }

        if (!this.skillRequests || this.skillRequests.length == 0) {
            isValid = false;
            this.showToast('', 'Please add a Shift Request', 'error');
        }
        return isValid;
    }

    handleChange(event) {
        console.log('handleChange, dataset.name >>', event.target.dataset.name);
        console.log('handleChange, target.name >>', event.target.name);
        switch (event.target.name) {
            case 'radioGroupShiftPlan':
                this.shiftPlanRadioValue = event.target.value;
                this.shiftPlanId = '';
                this.skillRequests = [];
                break;
            default:
                break;
        }

        switch (event.target.dataset.name) {
            case 'Allocation_Type__c':
                this.skillRequests[event.target.dataset.ind].isSkillRequired = !this.shiftTypesNotRequiringSkill.includes(event.target.value);
                break;
            case 'Skill__c':
                /*console.log('handleChange, block for Skill__c, Shift_Type_Escalation_Manager = ', Shift_Type_Escalation_Manager);
                console.log('handleChange, target.value >>', event.target.value);

                const resourceCountField = this.template.querySelectorAll('[data-name="Resource_Count__c"]')[event.target.dataset.ind];
                if (Shift_Type_Escalation_Manager === event.target.value) {
                    resourceCountField.value = 1;
                    resourceCountField.disabled = true;
                } else {
                    resourceCountField.value = '';
                    resourceCountField.disabled = false;
                }*/
                break;
            default:
                break;
        }
    }

    handleSelectionChange(event) {
        if (event.detail[0]) {
            this.shiftPlanId = event.detail[0];
            this.fetchShiftRequest();
        } else {
            this.shiftPlanId = '';
            this.skillRequests = [{
                Skill__c: '',
                Resource_Count__c: '',
                Allocation_Type__c: '',
                isSkillRequired: true
            }];
        }
    }

    fetchShiftRequest() {
        this.spinnerCounter++;
        getShiftRequestForShiftPlan({
            shiftPlanId: this.shiftPlanId
        }).then(res => {
            if (res && res.length) {
                this.skillRequests = [];
                res.forEach(req => {
                    this.skillRequests.push(Object.assign({}, req));
                });
                console.log('this.skillRequests>>', JSON.stringify(this.skillRequests));
            }
            this.spinnerCounter--;
        }).catch(err => {
            console.log('ERR: getShiftRequestForShiftPlan>', JSON.stringify(err));
            this.spinnerCounter--;
        })
    }

    handleSearch(event) {
        //this.spinnerCounter++;
        searchShiftPlan({
            searchText: event.detail.searchTerm
        }).then(result => {
            let shiftPlanInfo = [];

            result.forEach(sp => {
                shiftPlanInfo.push({
                    id: sp.Id,
                    sObjectType: 'Shift_Plan__c',
                    icon: 'custom:custom42',
                    title: sp.Name,
                    subtitle: sp.Start_Date__c + ' - ' + sp.End_Date__c
                    //subtitle: (sp.Skill__c ? sp.Skill__r.Name : '') + (sp.Resource_Count__c ? ' (' + sp.Resource_Count__c + ')' : '')
                });
            });
            this.template.querySelectorAll('c-lookup').forEach(cmp => {
                if (event.detail.key == cmp.customKey) {
                    cmp.setSearchResults(shiftPlanInfo);
                }
            });
            //this.spinnerCounter--;
        }).catch(error => {
            console.log('Error in Search results ---> ' + JSON.stringify(error));
            //this.spinnerCounter--;
        });
    }

    //T01
    deletePlan(){
        this.spinnerCounter++;
        deleteShiftPlan(
            {shiftPlanId : this.shiftPlanIdForEdit}
        ).then(() => {
            this.showToast(undefined, 'Shift Plan deleted successfully!', undefined);
            this.dispatchEvent(new CustomEvent('close', { detail: true }));
            this.spinnerCounter--;
        }).catch(error => {
            console.log('error while trying to delete the shift plan >>', { ...error })
            this.spinnerCounter--;
        });
    }
    
    //T01
    continueDeletePlan(event){
        this.deletePlan();
        this.showConfirmationModal = false;
    }
    
    //T01
    cancelDeletePlan(event){
        this.showConfirmationModal = false;
    }

    showToast(title = '', message, variant = 'success') {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }
}