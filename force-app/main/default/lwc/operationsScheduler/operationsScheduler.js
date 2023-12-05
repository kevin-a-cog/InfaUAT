import { LightningElement, api, track, wire } from 'lwc';
import TIME_ZONE from '@salesforce/i18n/timeZone'; 
import { CloseActionScreenEvent } from 'lightning/actions';
import { reduceErrors } from "./operationsSchedulerHelper";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';

//Case Fields
import STATUS from '@salesforce/schema/Case.Status';
import PRIORITY from '@salesforce/schema/Case.Priority';
import ENVIRONMENT from '@salesforce/schema/Case.Environment__c';
import ACTIVITY_TYPE from '@salesforce/schema/Case.Activity_Type__c';

//Custom Labels
import DEBUG from '@salesforce/label/c.Service_Cloud_LWC_Debug_Flag';

//Apex Methods
import rescheduleSession from '@salesforce/apex/OperationsSchedulerController.rescheduleSession';
import getRescheduleSlots from '@salesforce/apex/OperationsSchedulerController.getRescheduleSlots';

const fields = [STATUS,ENVIRONMENT,ACTIVITY_TYPE];
const SCHEDULED_ACTIVITY_TYPE = ['Apply EBF','Restart the services','Change configuration','Migrations'];

//Log to console, only when DEBUG flag is set to "true"
function log(message){
    if(DEBUG !== undefined && DEBUG !== null && DEBUG === 'true'){
        console.log(message);
    }
}

export default class OperationsScheduler extends LightningElement {

    @api recordId;

    @track userTimeZone = TIME_ZONE;
    @track disableSaveCancel = false;
    @track saveInProgress = false;
    @track availableDatesWithSlots;
    @track availableDates;
    @track selectedDate;
    @track availableSlots;
    @track selectedSlot;
    slotStartDT;
    slotEndDT;


    connectedCallback(){
        log('Reschedule Session: '+this.recordId);
        this.clearDateSlotFieldValues();
    }


    /* Wire Adapter methods */
    @wire(getRecord, { recordId: '$recordId', fields })
    relatedMedia({data,error}) {
        if (data) {
            log('Data= '+JSON.stringify(data));
            this.getAvailableSlots();
        } else if (error) {
            log('Error'+JSON.stringify(error));
        }
    }

    /* Custom Methods */
    getAvailableSlots(){
        getRescheduleSlots({ caseId: this.recordId })
            .then(objSlotsMap => {
                try {
                    log('available slots >> '+JSON.stringify(objSlotsMap));
                    this.processAvailableSlots(objSlotsMap);
                } catch (error) {
                    this.showCustomToast('Error', reduceErrors(error), 'error', 'dismissable');
                }
            })
            .catch(error => {
                log('error getting available slots: '+JSON.stringify(error));
                this.showCustomToast('Error', reduceErrors(error), 'error', 'dismissable');
            })
    }

    rescheduleSession(){
        var isValidValue = [...this.template.querySelectorAll('lightning-combobox')]
        .reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
        if (isValidValue){
            this.disableSaveCancel = true;
            this.saveInProgress = true;
            var slot = [];
            slot.push(this.slotStartDT);
            slot.push(this.slotEndDT);
            //call apex class to Reschedule Session
            rescheduleSession({ caseId: this.recordId, slotSelected: slot })
                .then(result => {
                    log('reschedule session: '+result);
                    this.showCustomToast('Success!', 'Your Session has been rescheduled successfully.', 'success', 'dismissable');
                    this.saveInProgress = false;
                    this.cancel();
                    
                })
                .catch(error => {
                    log('reschedule session error: '+JSON.stringify(error));
                    this.showCustomToast('Error', reduceErrors(error), 'error', 'dismissable');
                    this.disableSaveCancel = false;
                    this.saveInProgress = false;
                });
        }
    }

    clearDateSlotFieldValues(){
        this.selectedDate = undefined;
        this.selectedSlot = undefined;
        this.slotStartDT = undefined;
        this.slotEndDT = undefined;
    }

    handleDateSelect(event){
        this.selectedDate = event.detail.value;
        log('Selected Date >> '+event.detail.value);
        let slots = new Array();

        this.availableDatesWithSlots.forEach(objDay => {
            if(objDay.strDate === this.selectedDate){
                objDay.lstSlots.forEach(objSlot => {
                    slots.push({label: objSlot.strSlotLabel, value: objSlot.strId});
                })
            }
        });
        this.availableSlots = slots;
    }

    handleSlotSelect(event){
        this.selectedSlot = event.detail.value;
        log('slotId >> '+event.detail.value);
        this.availableDatesWithSlots.forEach(objDay => {
            objDay.lstSlots.forEach(objSlot => {
                if(objSlot.strId === event.detail.value){
                    this.slotStartDT = objSlot.startDT;
                    this.slotEndDT = objSlot.endDT;
                }
            })
        });
        log('slotStartDateTime >> '+this.slotStartDT);
        log('slotEndDateTime >> '+this.slotEndDT);
    }

    processAvailableSlots(objSlotsMap){
        let boolHasSlots;
        let intIndex = 0;
        let lstAvailableDatesAndSlots = new Array();
        let lstAvailableDates = new Array();

        Object.entries(objSlotsMap).map(objDay => {
            boolHasSlots = false;
			if(typeof objDay[1] !== "undefined" && objDay[1] !== null && objDay[1].length > 0) {
                boolHasSlots = true;
				objDay[1].forEach(objSlot => {
					objSlot.strSlotLabel = (new Intl.DateTimeFormat('en-US', {
						hour: '2-digit', 
						hourCycle: 'h12',
						minute: '2-digit',
						timeZone: TIME_ZONE,
					}).format(new Date(objSlot.startDT)))/*.replace("AM", "").replace("PM", "").replace(" ", "") + " - " + (new Intl.DateTimeFormat('en-US', {
						hour: '2-digit', 
						hourCycle: 'h12',
						minute: '2-digit',
						timeZone: TIME_ZONE,
					}).format(new Date(objSlot.endDT))).toLowerCase()*/;
					objSlot.strId = "" + intIndex;
					intIndex++;
				});
			}

            if(boolHasSlots){
                lstAvailableDatesAndSlots.push({
                    strDate: objDay[0],
                    lstSlots: objDay[1]
                });
                lstAvailableDates.push({
                    label: objDay[0], 
                    value: objDay[0]
                });
            }
        });
        log('objSlotsMap processed >> '+JSON.stringify(objSlotsMap));
        this.availableDatesWithSlots = lstAvailableDatesAndSlots;
        this.availableDates = lstAvailableDates;
        log('processed dates >> '+JSON.stringify(this.availableDates));
    }

    showCustomToast(t, msg, v, mde) {
        const toast = new ShowToastEvent({
            title: t,
            message: msg,
            variant: v,
            mode: mde
        });
        this.dispatchEvent(toast);
    }

    cancel(){
        this.clearDateSlotFieldValues();
        getRecordNotifyChange([{recordId: this.recordId}]);
        this.closeAction();
    }

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}