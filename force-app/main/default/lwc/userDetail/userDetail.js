/*
Author : balajip
JIRA : I2RT-5093
Desc : To allow GCS Manager/Admin to update the GCS Team of a User

Change History
****************************************************************************************************
ModifiedBy              Date        Jira No.    Tag     Description
****************************************************************************************************
Amit Garg               28/02/2022     I2RT-5099   T01    save Region field with User
Shashikanth Marri       25/04/2023     I2RT-8142   T02    Make Region field mandatory when there is value in GCS Team
Shashikanth Marri       06/20/2023     I2RT-8365   T03    User Profile - Add shift Time Start and End Time
*/

import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

import USER_FIELD_ID from '@salesforce/schema/User.Id';
import USER_FIELD_GCS_TEAM from '@salesforce/schema/User.GCS_Team__c';

import USER_FIELD_REGION from '@salesforce/schema/User.Region__c';//<T01>
//<T03>
import USER_FIELD_TIMEZONE from '@salesforce/schema/User.TimeZoneSidKey';
import USER_FIELD_SHIFT_START_TIME from '@salesforce/schema/User.Shift_Start_Time__c';
import USER_FIELD_SHIFT_END_TIME from '@salesforce/schema/User.Shift_End_Time__c';
//</T03>

import allowGCSTeamUpdate from '@salesforce/apex/UserController.allowGCSTeamUpdate';
import updateUser from '@salesforce/apex/UserController.updateUser';

export default class UserDetail extends LightningElement {
    userRecordTypeId = '012000000000000AAA';

    @api recordId;

    origGCSTeamValue;

    @track gcsTeamOptions = [
        //{label:"None", value:"", selected:true}
    ];
    @track gcsTeamValue = '';
    //<T01>
    @track regionValue = '';
    origRegionValue;
    regionOptions = [];
    //<T01>

    //<T03>
    timeZoneOptions = [];  
    timeZoneValue = '';
    shiftStartTimeValue;
    shiftEndTimeValue;
    origTimeZoneValue = '';
    origShiftStartTimeValue;
    origShiftEndTimeValue;
    //</T03>     

    @track usr;
    @track error;
    @track disabled = false;

    @track spinnerCount = 0;
    
    
    @wire(getPicklistValues, { recordTypeId: '$userRecordTypeId', fieldApiName: USER_FIELD_GCS_TEAM })
    wiredGCSTeamLOV({error, data}){
        if (data) {
            console.log('picklist values >>', JSON.stringify(data));
            this.gcsTeamOptions = this.gcsTeamOptions.concat(data.values);
        } else if (error){
            console.log('error while fetching GCS Team picklist values >>', JSON.stringify(error));
        }
    }
    //<T01>
    @wire(getPicklistValues, { recordTypeId: '$userRecordTypeId', fieldApiName: USER_FIELD_REGION })
    wiredREgionLOV({error, data}){
        if (data) {
            this.regionOptions = this.regionOptions.concat(data.values);
        } else if (error){
            console.log('error while fetching Region picklist values >>', JSON.stringify(error));
        }
    }
    //<T01>

    //<T03>
    @wire(getPicklistValues, { recordTypeId: '$userRecordTypeId', fieldApiName: USER_FIELD_TIMEZONE })
    wiredTimezoneLOV({error, data}){
        if (data) {
            this.timeZoneOptions = this.timeZoneOptions.concat(data.values);
        } else if (error){
            console.log('error while fetching Timezone picklist values >>', JSON.stringify(error));
        }
    }
    //</T03>

    @wire(getRecord, { recordId: '$recordId', fields: [USER_FIELD_ID, USER_FIELD_GCS_TEAM, USER_FIELD_REGION, USER_FIELD_TIMEZONE, USER_FIELD_SHIFT_START_TIME, USER_FIELD_SHIFT_END_TIME] })
    wiredUser({ error, data }) {
        if (data) {
            console.log('user details >>', JSON.stringify(data));
            this.usr = data;
            this.gcsTeamValue = data.fields.GCS_Team__c.value;
            this.regionValue = data.fields.Region__c.value;//<T01>
            this.origGCSTeamValue = this.gcsTeamValue;
            this.origRegionValue = this.regionValue;//<T01>

            //<T03>
            this.shiftStartTimeValue = data.fields.Shift_Start_Time__c.value;
            this.shiftEndTimeValue = data.fields.Shift_End_Time__c.value;
            this.timeZoneValue = data.fields.TimeZoneSidKey.value;

            this.origTimeZoneValue = this.timeZoneValue;
            this.origShiftStartTimeValue =  this.shiftStartTimeValue;
            this.origShiftEndTimeValue = this.shiftEndTimeValue;
            //</T03>
            
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.usr = undefined;
            console.log('error while fetching GCS Team value for the given user >>', JSON.stringify(error));
        }
    }

    connectedCallback(){
        this.spinnerCount++;
        allowGCSTeamUpdate()
        .then(data => {
      
            this.spinnerCount--;
            console.log('allowGCSTeamUpdate >> ', JSON.stringify(data));
            this.disabled = !data;
        })
        .catch(error => {
            this.spinnerCount--;
            console.log('error while trying to check if the GCS Team update is allowed >> ', JSON.stringify(error));
            this.disabled = true;
        })
    }

    get showSpinner(){
        return this.spinnerCount > 0;
    }

    handleChange(event) {
        
    }

    resetGCSTeam(event){
        this.gcsTeamValue = this.origGCSTeamValue;
        this.template.querySelector("[data-field='GCSTeam']").value = this.gcsTeamValue;
        this.regionValue = this.origRegionValue;//<T01>
        this.template.querySelector("[data-field='Region']").value = this.regionValue;//<T01>

        //<T03>

        this.timeZoneValue = this.origTimeZoneValue;
        this.shiftStartTimeValue = this.origShiftStartTimeValue;
        this.shiftEndTimeValue = this.origShiftEndTimeValue;

        this.template.querySelector("[data-field='TimeZone']").value = this.timeZoneValue;
        this.template.querySelector("[data-field='shiftStartTime']").value = this.shiftStartTimeValue;
        this.template.querySelector("[data-field='shiftEndTime']").value = this.shiftEndTimeValue;

        //</T03>
 
    }

    updateUser(event) {
        const allValid = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputFields) => {
                inputFields.reportValidity();
                return validSoFar && inputFields.checkValidity();
            }, true);

           if(allValid)
           {
               let isShiftTimesValid = this.validateShiftTimes();
                if(!isShiftTimesValid)
                {
                    return;
                }
           }

        if (allValid) {
            let gcsTeamValue = this.template.querySelector("[data-field='GCSTeam']").value;
            let regionValue = this.template.querySelector("[data-field='Region']").value;//<T01>

            //<T03>
            let timeZoneValue = this.template.querySelector("[data-field='TimeZone']").value;
            let shiftStartTimeValue = this.template.querySelector("[data-field='shiftStartTime']").value;
            let shiftEndTimeValue = this.template.querySelector("[data-field='shiftEndTime']").value;

            shiftStartTimeValue = this.getTruncatedTime(shiftStartTimeValue);
            shiftEndTimeValue = this.getTruncatedTime(shiftEndTimeValue);

            //</T03>

            //<T02>
            if(!!gcsTeamValue && (regionValue == null || regionValue == ''))
            {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please select Region.',
                        variant: 'error'
                    })
                );
                return;
            }
            //</T02>

            this.spinnerCount++;
            updateUser({
                userId: this.recordId,
                gcsTeam: gcsTeamValue,
                region: regionValue,//<T01>
                timeZone:timeZoneValue,                     //<T03>
                shiftStartTime: shiftStartTimeValue,        //<T03>
                shiftEndTime: shiftEndTimeValue             //<T03>
                
            })
            .then((result) => {
                if(!result)                     //<T03>
                {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Successfully updated the User!',
                            variant: 'success'
                        })
                    );
                }
                //<T03>
                else
                {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error updating the value!',
                            message: result,
                            variant: 'error'
                        })
                    );
                }
                //</T03>
                this.spinnerCount--;

                // Display fresh data in the form
                return refreshApex(this.usr);
            })
            .catch(error => {
                this.spinnerCount--;

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating the value!',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
        } else {
            // The form is not valid
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Something is wrong',
                    message: 'Check your input and try again.',
                    variant: 'error'
                })
             );
        }
    }

    //<T03>

    validateShiftTimes()
    {
        let shiftStartTimeValue = this.template.querySelector("[data-field='shiftStartTime']").value;
        let shiftEndTimeValue = this.template.querySelector("[data-field='shiftEndTime']").value;
        if(shiftStartTimeValue || shiftEndTimeValue)
        {
            let fieldName = '';
            if(!shiftStartTimeValue)
            {
                fieldName = 'Shift Start Time';
            }
            else if(!shiftEndTimeValue)
            {
                fieldName = 'Shift End Time';
            }

            if(fieldName != '')
            {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please select ' + fieldName + '.',
                        variant: 'error'
                    })
                );
                return false;
            }
        }
        return true;
    }

    getTruncatedTime(timeValue)
    {
        if(timeValue)
        {
            let arrTime = timeValue.split(':');

            if(arrTime.length > 1)
            {
                return arrTime[0] + ':' + arrTime[1];
            }
        }
        return timeValue;
    }
    //</T03>
}