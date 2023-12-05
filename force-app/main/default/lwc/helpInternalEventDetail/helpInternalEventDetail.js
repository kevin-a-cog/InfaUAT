/*
* Name : HelpInternalEventDetail
* Author : Deeksha Shetty
* Created Date :  Feb 1 2022
* Description : This Component displays event detail for Internal Users.
Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Deeksha Shetty        1-Feb-2022     I2RT-5249            Initial version.                                            NA
 Deeksha Shetty        22-Feb-2023                         Prod Issue - Past date validation is not working while      T1
                                                           modifying the event from both internal and external portal.
 Deeksha Shetty       14/03/2023      I2RT-7801            Create/Modify Event: Custom error message is not displaying when admin        T2
                                                           enter event duration more than 14 days.                                                           
*/

import { LightningElement, wire, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import eventdisplayOnId from '@salesforce/apex/helpInternalEventDetails.eventdisplayOnId';
import modifyEvent from '@salesforce/apex/helpInternalEventDetails.modifyEvent';
import getEventTypePicklistValues from "@salesforce/apex/helpEventsController.getEventTypePicklistValues";
import userId from '@salesforce/user/Id';
//T2 starts
import helpEventDuration from '@salesforce/label/c.helpEventDuration';
//T2 ends

export default class HelpInternalEventDetail extends LightningElement {
    @api recordId;
    records;
    error;
    showButtons = false;
    showEdit = false;
    Subject = "";
    Description = "";
    StartDateTime = "";
    EndDateTime = "";
    Location = "";
    Type = "";
    inputValue;
    typeOptions;
    isInputReadOnly = true;
    validity = true;
    showSpinner = false;
    RealEndDateTime;
    RealStartDateTime;
    CreatedDate;
    LastModifiedDate;
    showDescEdit = false;
    todaydate; //T1

    @wire(getEventTypePicklistValues)
    IdeaWiring(result) {
        this.todaydate = new Date(); //T1
        if (result.data) {
            let categoryFilter = result.data;
            this.typeOptions = categoryFilter.map(item => {
                let idea = {};
                idea.label = item;
                idea.value = item;
                return idea;
            });

        }
        else if (result.error) {
            console.log(JSON.stringify(result.error));
        }
    }


    @wire(eventdisplayOnId, { eventId: '$recordId' })
    imperativeWiring(result) {
        this.wiredResults = result;
        if (result.data) {
            this.records = result.data;
            this.Subject = this.records.Subject;
            this.Description = this.records.Description;
            this.StartDateTime = this.records.StartDateTime;
            this.EndDateTime = this.records.EndDateTime;
            this.RealStartDateTime = this.records.RealStartDateTime;
            this.RealEndDateTime = this.records.RealEndDateTime;
            this.Location = this.records.Location;
            this.Type = this.records.Type;
            this.CreatedDate = this.records.CreatedDate;
            this.LastModifiedDate = this.records.LastModifiedDate;;
            if (this.records.CreatedById == userId) {
                this.showEdit = true;
            }
        }
        else if (result.error) {
            console.log(JSON.stringify(result.error));
        }
    }


    inputChange(event) {
        this.inputValue = event.target.value;
        switch (event.target.name) {
            case 'Subject':
                this.Subject = this.inputValue;
                break;
            case 'Description':
                this.Description = this.inputValue;
                break;
            case 'StartDateTime':
                this.RealStartDateTime = this.inputValue;
                break;
            case 'EndDateTime':
                this.RealEndDateTime = this.inputValue;
                break;
            case 'Location':
                this.Location = this.inputValue;
                break;
            case 'Type':
                this.Type = this.inputValue;
                break;
            default:
                //Do nothing
                break;
        }
    }

    handleEdit() {
        this.isInputReadOnly = false;
        this.showEdit = false;
        this.showButtons = true;
        this.showDescEdit = true;
    }

    handleCancel() {
        location.reload();
    }

    handleRedirection() {
        window.open('/lightning/n/All_Events', "_self");
    }


    handleSave() {
        //T1 starts
        var isValidValue = [...this.template.querySelectorAll('lightning-input,lightning-combobox')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        //T1 Ends

        if (this.Description == undefined || !this.Description) {
            this.validity = false;
        }
        else {
            this.validity = true;
        }

        if (this.validity && isValidValue && this.Subject != "" && this.RealStartDateTime != "" && this.RealEndDateTime != "" && this.Location != "" && this.Type != "") {
            this.showSpinner = true;
            modifyEvent({ eventId: this.recordId, Subject: this.Subject, Description: this.Description, StartDateTime: this.RealStartDateTime, EndDateTime: this.RealEndDateTime, Location: this.Location, Type: this.Type })
                .then((result) => {
                    if (result) {
                        console.log('Success=' + JSON.stringify(result))
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success : ',
                                message: 'Event Modified.',
                                variant: 'success',
                            }),
                        );

                        this.showSpinner = false;
                        refreshApex(this.wiredResults);
                        this.isInputReadOnly = true;
                        this.showEdit = true;
                        this.showButtons = false;
                        this.showDescEdit = false;

                    }

                })
                .catch((error) => {
                    this.showSpinner = false;
                    console.log(error.body);
                    let errormsg = (error.body.message.includes('last longer than 14 days')) ? helpEventDuration : error.body.message; //T2
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error : ',
                            message: errormsg,
                            variant: 'error',
                        }),
                    );
                });
        }
    }

}