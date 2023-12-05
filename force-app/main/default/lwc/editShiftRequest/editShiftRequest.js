import { api, LightningElement, track, wire } from 'lwc';

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { deleteRecord } from 'lightning/uiRecordApi';

import Shift_Type_Not_Requiring_Skill from '@salesforce/label/c.Shift_Type_Not_Requiring_Skill';
import Shift_Type_Escalation_Manager from '@salesforce/label/c.Shift_Type_Escalation_Manager';

import createShiftPlanAndRequest from "@salesforce/apex/ShiftManagementController.createShiftPlanAndRequest";

export default class EditShiftRequest extends LightningElement {
    @api shiftRequestId;
    showSpinner = false;

    get shiftTypesNotRequiringSkill() {
        return Shift_Type_Not_Requiring_Skill ? Shift_Type_Not_Requiring_Skill.split(';') : [];
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
    }

    handleClick(event) {
        switch (event.target.name) {
            case 'saveShiftPlan':
                if (this.validateForm()) {
                    this.showSpinner = true;
                    this.createShiftPlan();
                }
                break;
            case 'cancelShiftPlan':
                this.dispatchEvent(new CustomEvent('close', { detail: false }));
                break;

            case 'removeReq':
                this.showSpinner = true;
                deleteRecord(this.shiftRequestId).then(() => {
                    this.showToast(undefined, 'Shift Request has been deleted successfully', undefined);
                    this.dispatchEvent(new CustomEvent('close', { detail: true }));
                    this.showSpinner = false;
                }).catch(error => {
                    console.log('error>>', { ...error })
                    this.showSpinner = true;
                });
                break;
            default:
                break;
        }
    }

    createShiftPlan() {
        let _shiftReqArr = [];

        this.template.querySelectorAll('lightning-record-edit-form').forEach(form => {
            let _request = { Id: this.shiftRequestId };
            form.querySelectorAll('lightning-input-field').forEach(ip => {
                _request[ip.fieldName] = ip.value;
            });
            _shiftReqArr.push(_request);
        });

        createShiftPlanAndRequest({
            lstShiftRequestToUpsert: _shiftReqArr
        }).then(() => {
            this.showToast(undefined, 'Shift Request updated successfully', undefined);
            this.dispatchEvent(new CustomEvent('close', { detail: true }));
            this.showSpinner = false;
        }).catch(err => {
            this.showSpinner = false;
            console.log(JSON.stringify(err))
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating record',
                    message: err.body.message,
                    variant: 'error',
                }),
            );
        });
    }

    validateForm() {
        let isValid = true;

        this.template.querySelectorAll('lightning-input-field').forEach(ip => {
            if (ip.required && !ip.value || (!isNaN(ip.value) && ip.value < 0)) {
                if (ip.fieldName == 'Skill__c') {
                    const allocationType = this.template
                        .querySelectorAll('[data-name="Allocation_Type__c"]')[ip.dataset.ind].value;
                    if (!this.shiftTypesNotRequiringSkill.includes(allocationType)) {
                        isValid = false;
                        ip.classList.add('slds-has-error');
                    } else {
                        ip.classList.remove('slds-has-error');
                    }
                } else {
                    isValid = false;
                    ip.classList.add('slds-has-error');
                }
            } else {
                ip.classList.remove('slds-has-error');
            }
        });

        if (!isValid) {
            this.showToast('', 'Please review the errors on the page', 'error');
        }
        return isValid;
    }

    handleChange(event) {
        switch (event.target.dataset.name) {
            case 'Allocation_Type__c':
                const resourceCountField = this.template.querySelector('[data-name="Resource_Count__c"]');
                if (Shift_Type_Escalation_Manager == event.target.value) {
                    resourceCountField.value = 1;
                    resourceCountField.disabled = true;
                } else {
                    resourceCountField.value = '';
                    resourceCountField.disabled = false;
                }
                break;
            default:
                break;
        }
    }

    showToast(title = '', message, variant = 'success') {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }
}