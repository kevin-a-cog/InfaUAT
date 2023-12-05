/*
* Name : HelpInternalEventsLanding
* Author : Deeksha Shetty
* Created Date :  Feb 1 2022
* Description : This Component displays Events List for Internal Users.
Change History
 **************************************************************************************************************************
 Modified By            Date            Jira No.            Description                                               Tag
 **************************************************************************************************************************
 Deeksha Shetty        1-Feb-2022     I2RT-5249            Initial version.                                            NA
 Deeksha Shetty        22-Feb-2023                         Prod Issue - Past date validation is not working while      T1
                                                           modifying the event from both internal and external portal.
 Deeksha Shetty       14/03/2023      I2RT-7801            Create/Modify Event: Custom error message is not displaying   T2 
                                                            when admin enter event duration more than 14 days.                                                          
*/

import { LightningElement, wire, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import eventData from '@salesforce/apex/helpInternalEventDetails.eventData';
import createEvent from '@salesforce/apex/helpInternalEventDetails.createEvent';
import getEventTypePicklistValues from "@salesforce/apex/helpEventsController.getEventTypePicklistValues";
//T2 starts
import helpEventDuration from '@salesforce/label/c.helpEventDuration';
//T2 ends



const columns = [
    { label: 'Subject', fieldName: 'Link', type: 'url', typeAttributes: { label: { fieldName: 'Subject' }, target: '_blank' }, hideDefaultActions: true },
    { label: 'Start Date & Time', fieldName: 'StartDateTime', hideDefaultActions: true },
    { label: 'End Date & Time', fieldName: 'EndDateTime', hideDefaultActions: true },
    { label: 'Location', fieldName: 'Location', hideDefaultActions: true },
    { label: 'Type', fieldName: 'Type', hideDefaultActions: true },
    { label: 'Event Type', fieldName: 'EventType', hideDefaultActions: true },
    { label: 'Created By', fieldName: 'CreatedBy', hideDefaultActions: true }
];


export default class HelpInternalEventsLanding extends LightningElement {
    records;
    error;
    sampleUrl = " ";
    showEditModal = false;
    wiredResults;
    draftValues;

    data;
    columns = columns;
    alldata;
    options;
    validity = true;
    typeOptions;

    Subject = "";
    Description = "";
    StartDateTime = "";
    EndDateTime = "";
    Location = "";
    Type = "";
    inputValue;
    todaydate; //T1
    showSpinner = false;



    @wire(eventData)
    imperativeWiring(result) {
        this.wiredResults = result;
        if (result.data) {
            this.data = result.data;
            this.alldata = JSON.parse(JSON.stringify(this.data));
            this.todaydate = new Date();
        }
        else if (result.error) {
        }
    }

    @wire(getEventTypePicklistValues)
    IdeaWiring(result) {
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


    createEvent() {
        this.Subject = "";
        this.Description = "";
        this.StartDateTime = "";
        this.EndDateTime = "";
        this.Location = "";
        this.Type = "";
        this.showEditModal = true;
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
                this.StartDateTime = this.inputValue;
                break;
            case 'EndDateTime':
                this.EndDateTime = this.inputValue;
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

    searchEvent(event) {
        this.searchInput = event.target.value;
        let finalArrayAfterSearch = this.globalsearchIdeas(this.searchInput, this.alldata);
        this.data = finalArrayAfterSearch;
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



    saveEvent() {
        //T1 starts
        var isValidValue = [...this.template.querySelectorAll('lightning-input,lightning-combobox')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
            console.log('isValidValue>>>>>>'+isValidValue)

        //T1 ends

        if (this.Description == undefined || !this.Description) {
            this.validity = false;
        }
        else {
            this.validity = true;
        }

        if (this.validity && isValidValue && this.Subject && this.StartDateTime && this.EndDateTime && this.Location && this.Type) {
            this.showSpinner = true;
            createEvent({ Subject: this.Subject, Description: this.Description, StartDateTime: this.StartDateTime, EndDateTime: this.EndDateTime, Location: this.Location, Type: this.Type })
                .then((result) => {
                    if (result) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success : ',
                                message: 'Event Created Successfully',
                                variant: 'success',
                            }),
                        );
                        this.showSpinner = false;
                        this.handleModalClose();
                        this.inputValue = '';
                        refreshApex(this.wiredResults);
                    }

                })
                .catch((error) => {
                    this.showSpinner = false;
                    let errormsg = (error.body.message.includes('last longer than 14 days')) ? helpEventDuration : error.body.message;//T2
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



    handleModalClose() {
        this.showEditModal = false;
    }

}