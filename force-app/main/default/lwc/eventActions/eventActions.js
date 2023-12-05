/*
 * Name			:	EventActions
 * Author		:	Vignesh Divakaran
 * Created Date	: 	10/02/2022
 * Description	:	This LWC is used to display the list of event actions.

 Change History
 *************************************************************************************************************************************
 Modified By			Date			Jira No.		Description							                                       Tag
 *************************************************************************************************************************************
 Vignesh Divakaran		10/02/2022		I2RT-5251		Initial version.					                                       N/A
 Deeksha Shetty         17/10/2022      I2RT-7272       Giving option for the admin/Leader to edit the events without               1
                                                        notifying the user
 Deeksha Shetty         19/01/2023      I2RT-7501       Remove Create event option from Events detail page                          2
 Chetan Shetty          19/01/2023      I2RT-7501       Create/Modify Modal Changes                                                 3
 Deeksha Shetty         14/03/2023      I2RT-7801       Create/Modify Event: Custom error message is not displaying when admin      4
                                                        enter event duration more than 14 days. 
 */

//Core imports.
import { LightningElement, api, track, wire } from 'lwc';
import INFORMATICA_NETWORK_RESOURCE from '@salesforce/resourceUrl/informaticaNetwork';
import getExportToCalendar from "@salesforce/apex/EventDetailController.getExportToCalendar";
import getEventParticipants from "@salesforce/apex/EventDetailController.getEventParticipants";
import { objUtilities } from 'c/globalUtilities';
import addUserToEvent from "@salesforce/apex/helpEventsController.addUserToEvent";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import userId from "@salesforce/user/Id";
import sendMail from "@salesforce/apex/helpEventsController.sendMail";
import findEventStatus from "@salesforce/apex/EventDetailController.findEventStatus";
import DeclineEvent from "@salesforce/apex/helpEventsController.DeclineEvent";
import { getRecord } from 'lightning/uiRecordApi';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import TIMEZONE_FIELD from '@salesforce/schema/User.TimeZoneSidKey';
import ModifyEvent from "@salesforce/apex/helpEventsController.ModifyEvent";
import getEventTypePicklistValues from "@salesforce/apex/helpEventsController.getEventTypePicklistValues";
import saveModifiedEvent from "@salesforce/apex/helpEventsController.saveModifiedEvent";
import deleteEvent from "@salesforce/apex/helpEventsController.deleteEvent";
import CommunityURL from '@salesforce/label/c.IN_CommunityName';
import AccountURL from '@salesforce/label/c.IN_account_login';
import getEventsById from '@salesforce/apex/helpEventsController.getEventsById';
import getmetadatarecords from '@salesforce/apex/helpEventsController.getmetadatarecords';
//Tag 3 Starts
import { loadStyle } from 'lightning/platformResourceLoader';
import IN_StaticResource3 from "@salesforce/resourceUrl/InformaticaNetwork3";
//Tag 3 Ends
//Tag 4 starts
import helpEventDuration from '@salesforce/label/c.helpEventDuration';
//Tag 4 ends

export default class EventActions extends LightningElement {

    //API Variables
    @api recordId;
    recId;
    userId = userId;
    email;

    //Modify Modal
    showModifyModal;
    Subject;
    Location;
    Type;
    StartDateTime;
    EndDateTime;
    Description = "";
    validity = true;
    isDialogVisible = false;
    eventSubject = '';
    @track eventsList = [];

    /* Tag 1 starts */
    showBool = true;
    showSpinner = false;
    userGrpId;
    userTZ;
    notifyUsrMsg;
    toolTipMsg;
    mailhelpText;
    /* Tag 1 ends */

    todaydate;



    //Private Variables
    isLoading;
    showCreateEvent;
    Icons = {
        CreateEvent: INFORMATICA_NETWORK_RESOURCE + '/EventActions/CreateEvent.svg',
        CalenderDownload: INFORMATICA_NETWORK_RESOURCE + '/EventActions/CalenderDownload.svg',
        ExportParticipants: INFORMATICA_NETWORK_RESOURCE + '/EventActions/Export.svg',
    };
    objEventActions = [];

    objExportColumns = {
        Labels: ['Name', 'Email'],
        FieldNames: ['Name', 'Email']
    };



    /*
     Method Name : connectedCallback
     Description : This method gets executed on load.
     Parameters	 : None
     Return Type : None
     */
    connectedCallback() {
        //We initialize the components.
        this.initializeComponent();
        this.loadCustomStyle();
        if (this.recId) {
            this.findEventStatus();
        }
    }

    //Style - Tag 3 Starts
    loadCustomStyle() {
        try {
            Promise.all([
                loadStyle(this, IN_StaticResource3 + "/helpEventModal/helpeventmodal.css")
            ])
        } catch (error) {
            Log('error', 'helpEventModal : Method : loadCustomStyle; Error :' + error.message + " : " + error.stack);
        }
    }
    //Style - Tag 3 Ends

    @wire(getRecord, { recordId: userId, fields: [EMAIL_FIELD, TIMEZONE_FIELD] })
    userDetails({ error, data }) {
        if (data) {
            this.email = data.fields.Email.value;
            this.userTZ = '(' + data.fields.TimeZoneSidKey.value + ')';
        } else if (error) {
            console.log('Error=' + error.body);
        }
    }

    @wire(getEventTypePicklistValues)
    IdeaWiring(result) {
        if (result.data) {
            this.todaydate = new Date();
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


    @wire(getmetadatarecords)
    metadataDetails({ error, data }) {
        if (data) {
            this.notifyUsrMsg = data.NotifyUserMsg__c;
            this.toolTipMsg = data.helpTextTZ__c;
            this.mailhelpText = data.MailHelpText__c;

        } else if (error) {
            console.log('Error=' + error.body);
        }
    }

    @wire(getRecord, { recordId: userId, fields: [EMAIL_FIELD, TIMEZONE_FIELD] })
    userDetails({ error, data }) {
        if (data) {
            this.email = data.fields.Email.value;
            this.userTZ = '(' + data.fields.TimeZoneSidKey.value + ')';
        } else if (error) {
            console.log('Error=' + error.body);
        }
    }




    /*
     Method Name : initializeComponent
     Description : This method gets executed after load.
     Parameters	 : None
     Return Type : None
     */
    initializeComponent() {
        let objParent = this;
        objParent.isLoading = false;
        objParent.showCreateEvent = false;
        if (objParent.recordId) {
            this.recId = objParent.recordId;
        }
        else {
            this.recId = window.location.href.toString().split('?id=')[1];
        }
    }



    findEventStatus() {
        findEventStatus({ recId: this.recId })
            .then(result1 => {
                if (result1) {

                    if (result1.ActivityDateStatus == 'Past') {
                        if (userId == undefined) {
                            this.objEventActions = [
                                { actionName: 'Join Event', icon: { src: this.Icons.CreateEvent, alt: 'Join Event' } }
                            ];
                        }
                        else if (result1.EditDeleteDisplay == 'ShowEditDeletePopup') {

                            this.objEventActions = [
                                { actionName: 'Create Event', icon: { src: this.Icons.CreateEvent, alt: 'Create Event' } },
                                { actionName: 'Modify Event', icon: { src: this.Icons.CreateEvent, alt: 'Modify Event' } },
                                { actionName: 'Delete Event', icon: { src: this.Icons.CreateEvent, alt: 'Delete Event' } },
                                { actionName: 'Download Calender', icon: { src: this.Icons.CalenderDownload, alt: 'Calender Download' } },
                                { actionName: 'Export Participants', icon: { src: this.Icons.ExportParticipants, alt: 'Export' } }
                            ];
                        }
                        else if (this.email.includes('informatica.com')) {
                            this.objEventActions = [
                                // { actionName: 'Create Event', icon: { src: this.Icons.CreateEvent, alt: 'Create Event' } },
                                { actionName: 'Download Calender', icon: { src: this.Icons.CalenderDownload, alt: 'Calender Download' } },
                                { actionName: 'Export Participants', icon: { src: this.Icons.ExportParticipants, alt: 'Export' } }
                            ];
                        }
                        else {
                            this.objEventActions = [
                                // { actionName: 'Create Event', icon: { src: this.Icons.CreateEvent, alt: 'Create Event' } },
                                { actionName: 'Download Calender', icon: { src: this.Icons.CalenderDownload, alt: 'Calender Download' } },
                            ];
                        }
                    }
                    else {
                        if (userId == undefined) {
                            this.objEventActions = [
                                { actionName: 'Join Event', icon: { src: this.Icons.CreateEvent, alt: 'Join Event' } }
                            ];
                        }
                        else if (result1.isOwner == 'Owner') {
                            this.objEventActions = [
                                { actionName: 'Create Event', icon: { src: this.Icons.CreateEvent, alt: 'Create Event' } },
                                { actionName: 'Modify Event', icon: { src: this.Icons.CreateEvent, alt: 'Modify Event' } },
                                { actionName: 'Delete Event', icon: { src: this.Icons.CreateEvent, alt: 'Delete Event' } },
                                { actionName: 'Download Calender', icon: { src: this.Icons.CalenderDownload, alt: 'Calender Download' } },
                                { actionName: 'Export Participants', icon: { src: this.Icons.ExportParticipants, alt: 'Export' } }
                            ];
                        }
                        else if (result1.EditDeleteDisplay == 'ShowEditDeletePopup') {

                            this.objEventActions = [
                                { actionName: 'Join Event', icon: { src: this.Icons.CreateEvent, alt: 'Join Event' } },
                                { actionName: 'Create Event', icon: { src: this.Icons.CreateEvent, alt: 'Create Event' } },
                                { actionName: 'Modify Event', icon: { src: this.Icons.CreateEvent, alt: 'Modify Event' } },
                                { actionName: 'Delete Event', icon: { src: this.Icons.CreateEvent, alt: 'Delete Event' } },
                                { actionName: 'Download Calender', icon: { src: this.Icons.CalenderDownload, alt: 'Calender Download' } },
                                { actionName: 'Export Participants', icon: { src: this.Icons.ExportParticipants, alt: 'Export' } }
                            ];
                        }
                        else if (this.email.includes('informatica.com')) {
                            this.objEventActions = [
                                { actionName: 'Join Event', icon: { src: this.Icons.CreateEvent, alt: 'Join Event' } },
                                // { actionName: 'Create Event', icon: { src: this.Icons.CreateEvent, alt: 'Create Event' } },
                                { actionName: 'Download Calender', icon: { src: this.Icons.CalenderDownload, alt: 'Calender Download' } },
                                { actionName: 'Export Participants', icon: { src: this.Icons.ExportParticipants, alt: 'Export' } }
                            ];

                        }
                        else {
                            this.objEventActions = [
                                { actionName: 'Join Event', icon: { src: this.Icons.CreateEvent, alt: 'Join Event' } },
                                // { actionName: 'Create Event', icon: { src: this.Icons.CreateEvent, alt: 'Create Event' } },
                                { actionName: 'Download Calender', icon: { src: this.Icons.CalenderDownload, alt: 'Calender Download' } }

                            ];
                        }

                        if (result1.JoinEventStatus == 'EnableDeclineAction') {
                            if (result1.EditDeleteDisplay == 'ShowEditDeletePopup') {
                                this.objEventActions = [
                                    { actionName: 'Decline Event', icon: { src: this.Icons.CreateEvent, alt: 'Decline Event' } },
                                    { actionName: 'Create Event', icon: { src: this.Icons.CreateEvent, alt: 'Create Event' } },
                                    { actionName: 'Modify Event', icon: { src: this.Icons.CreateEvent, alt: 'Modify Event' } },
                                    { actionName: 'Delete Event', icon: { src: this.Icons.CreateEvent, alt: 'Delete Event' } },
                                    { actionName: 'Download Calender', icon: { src: this.Icons.CalenderDownload, alt: 'Calender Download' } },
                                    { actionName: 'Export Participants', icon: { src: this.Icons.ExportParticipants, alt: 'Export' } }
                                ];
                            }
                            else if (this.email.includes('informatica.com')) {
                                this.objEventActions = [
                                    { actionName: 'Decline Event', icon: { src: this.Icons.CreateEvent, alt: 'Decline Event' } },
                                    // { actionName: 'Create Event', icon: { src: this.Icons.CreateEvent, alt: 'Create Event' } },
                                    { actionName: 'Download Calender', icon: { src: this.Icons.CalenderDownload, alt: 'Calender Download' } },
                                    { actionName: 'Export Participants', icon: { src: this.Icons.ExportParticipants, alt: 'Export' } }
                                ];

                            }
                            else {
                                this.objEventActions = [
                                    { actionName: 'Decline Event', icon: { src: this.Icons.CreateEvent, alt: 'Decline Event' } },
                                    // { actionName: 'Create Event', icon: { src: this.Icons.CreateEvent, alt: 'Create Event' } },
                                    { actionName: 'Download Calender', icon: { src: this.Icons.CalenderDownload, alt: 'Calender Download' } }
                                ];
                            }

                        }
                        else {
                            if (result1.isOwner == 'Owner') {
                                this.objEventActions = [
                                    { actionName: 'Create Event', icon: { src: this.Icons.CreateEvent, alt: 'Create Event' } },
                                    { actionName: 'Modify Event', icon: { src: this.Icons.CreateEvent, alt: 'Modify Event' } },
                                    { actionName: 'Delete Event', icon: { src: this.Icons.CreateEvent, alt: 'Delete Event' } },
                                    { actionName: 'Download Calender', icon: { src: this.Icons.CalenderDownload, alt: 'Calender Download' } },
                                    { actionName: 'Export Participants', icon: { src: this.Icons.ExportParticipants, alt: 'Export' } }
                                ];
                            }
                            else if (result1.EditDeleteDisplay == 'ShowEditDeletePopup') {
                                this.objEventActions = [
                                    { actionName: 'Join Event', icon: { src: this.Icons.CreateEvent, alt: 'Join Event' } },
                                    { actionName: 'Create Event', icon: { src: this.Icons.CreateEvent, alt: 'Create Event' } },
                                    { actionName: 'Modify Event', icon: { src: this.Icons.CreateEvent, alt: 'Modify Event' } },
                                    { actionName: 'Delete Event', icon: { src: this.Icons.CreateEvent, alt: 'Delete Event' } },
                                    { actionName: 'Download Calender', icon: { src: this.Icons.CalenderDownload, alt: 'Calender Download' } },
                                    { actionName: 'Export Participants', icon: { src: this.Icons.ExportParticipants, alt: 'Export' } }
                                ];
                            }
                            else if (this.email.includes('informatica.com')) {
                                this.objEventActions = [
                                    { actionName: 'Join Event', icon: { src: this.Icons.CreateEvent, alt: 'Join Event' } },
                                    // { actionName: 'Create Event', icon: { src: this.Icons.CreateEvent, alt: 'Create Event' } },
                                    { actionName: 'Download Calender', icon: { src: this.Icons.CalenderDownload, alt: 'Calender Download' } },
                                    { actionName: 'Export Participants', icon: { src: this.Icons.ExportParticipants, alt: 'Export' } }
                                ];
                            }
                            else {
                                this.objEventActions = [
                                    { actionName: 'Join Event', icon: { src: this.Icons.CreateEvent, alt: 'Join Event' } },
                                    // { actionName: 'Create Event', icon: { src: this.Icons.CreateEvent, alt: 'Create Event' } },
                                    { actionName: 'Download Calender', icon: { src: this.Icons.CalenderDownload, alt: 'Calender Download' } }
                                ];
                            }
                        }
                    }
                    /* Tag 1 starts */
                    if (result1.UserGroupId) {
                        this.userGrpId = result1.UserGroupId;
                        this.objEventActions = this.objEventActions.filter((item) => item.actionName != 'Create Event'); // Tag 2
                    }
                    /* Tag 1 ends */

                }
            })
            .catch(error => {
                console.log(error.body.message);
            })
    }

    /*
     Method Name : actionSelected
     Description : This method routes selected action to the appropriate method.
     Parameters	 : Object, called from actionSelected, objEvent On click event.
     Return Type : None
     */
    actionSelected(objEvent) {
        switch (objEvent.currentTarget.dataset.action) {
            case 'Join Event':
                this.joinEvent();
                break;
            case 'Decline Event':
                this.declineEvent();
                break;
            case 'Create Event':
                this.openCreateEvent();
                break;
            case 'Modify Event':
                this.modifyEvent();
                break;
            case 'Delete Event':
                this.deleteEvent();
                break;
            case 'Download Calender':
                this.downloadCalender();
                break;
            case 'Export Participants':
                this.exportParticipants();
                break;
            default:
                //Do nothing
                break;
        }
    }

    /*
     Method Name : joinEvent
     Description : This method adds user to the event.
     Parameters	 : None
     Return Type : None
     */


    joinEvent() {
        if (userId == undefined) {
            window.open(AccountURL);
        }
        else {
            let objParent = this;
            if (objParent.recordId) {
                this.recId = objParent.recordId;
            }
            else {
                this.recId = window.location.href.toString().split('?id=')[1];
            }

            let eventId = this.recId;
            let statusmsg;

            getEventsById({ eventId: this.recId })
                .then((result) => {
                    /** START-- adobe analytics */
                    try {
                        util.trackButtonClick('Join Event - ' + result[0].Subject);
                    }
                    catch (ex) {
                        console.error(ex.message);
                    }
                    /** END-- adobe analytics*/
                })
            addUserToEvent({
                eventId: eventId,
                userId: userId
            })
                .then((result) => {
                    statusmsg = result.statusMessage;
                    if (result.returnMessage == 'User Added') {
                        if (this.email.includes('informatica.com')) {
                            this.objEventActions = [
                                { actionName: 'Decline Event', icon: { src: this.Icons.CreateEvent, alt: 'Decline Event' } },
                                // { actionName: 'Create Event', icon: { src: this.Icons.CreateEvent, alt: 'Create Event' } },
                                { actionName: 'Download Calender', icon: { src: this.Icons.CalenderDownload, alt: 'Calender Download' } },
                                { actionName: 'Export Participants', icon: { src: this.Icons.ExportParticipants, alt: 'Export' } }
                            ];
                        }
                        else {
                            this.objEventActions = [
                                { actionName: 'Decline Event', icon: { src: this.Icons.CreateEvent, alt: 'Decline Event' } },
                                // { actionName: 'Create Event', icon: { src: this.Icons.CreateEvent, alt: 'Create Event' } },
                                { actionName: 'Download Calender', icon: { src: this.Icons.CalenderDownload, alt: 'Calender Download' } }
                            ];
                        }

                        sendMail({ userId: userId, eventId: eventId })
                            .then(result1 => {
                                if (result1) {
                                    let res = JSON.stringify(result1);
                                }
                            })
                            .catch(error => {
                                console.log(error.body.message);
                            })
                        // Show toast message 
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success : ',
                                message: statusmsg,
                                variant: 'success',
                            }),
                        );

                    }
                    else if (result.returnMessage == 'Past Event') {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error : ',
                                message: statusmsg,
                                variant: 'Error',
                            }),
                        );


                    }

                })
                .catch((error) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error : ',
                            message: 'Error occurred, please contact system administrator. Error Message: ' + error.body.message,
                            variant: 'error',
                        }),
                    );
                });
        }

    }

    declineEvent() {
        DeclineEvent({ recId: this.recId, userId: userId })
            .then(result1 => {
                if (result1) {
                    let res = JSON.stringify(result1);
                    if (this.email.includes('informatica.com')) {
                        this.objEventActions = [
                            { actionName: 'Join Event', icon: { src: this.Icons.CreateEvent, alt: 'Join Event' } },
                            { actionName: 'Download Calender', icon: { src: this.Icons.CalenderDownload, alt: 'Calender Download' } },
                            { actionName: 'Export Participants', icon: { src: this.Icons.ExportParticipants, alt: 'Export' } }
                        ];
                    }
                    else {
                        this.objEventActions = [
                            { actionName: 'Join Event', icon: { src: this.Icons.CreateEvent, alt: 'Join Event' } },
                            { actionName: 'Download Calender', icon: { src: this.Icons.CalenderDownload, alt: 'Calender Download' } },
                        ];
                    }
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'EVENT DECLINED',
                            message: 'Event Declined!.',
                            variant: 'error',
                        }),
                    );

                    getEventsById({ eventId: this.recId })
                        .then((result) => {
                            /** START-- adobe analytics */
                            try {
                                util.trackButtonClick('Decline Event - ' + result[0].Subject);
                            }
                            catch (ex) {
                                console.error(ex.message);
                            }
                            /** END-- adobe analytics*/
                        })
                }
            })
            .catch(error => {
                console.log(error.body.message);
            })

    }

    /*
     Method Name : openCreateEvent
     Description : This method opens the modal with the required fields to be filled by user.
     Parameters	 : None
     Return Type : None
     */
    openCreateEvent() {
        this.showCreateEvent = true;
    }

    //On click of Modify Event

    modifyEvent() {
        this.showModifyModal = true;
        ModifyEvent({ eventId: this.recId })
            .then(result1 => {
                if (result1) {
                    this.Subject = result1.Subject;
                    this.Location = result1.Location;
                    this.StartDateTime = result1.StartDateTime;
                    this.EndDateTime = result1.EndDateTime;
                    this.Type = result1.Type;
                    this.Description = result1.Description;
                }
            })
            .catch(error => {
                console.log(error.body.message);
            })
    }
    /* Tag 1 starts  */
    handleMailNotification(event) {
        this.showBool = event.target.checked;
    }
    /* Tag 1 ends */



    inputChange(objEvent) {
        let inputValue = objEvent.target.value;

        switch (objEvent.target.name) {
            case 'Subject':
                this.Subject = inputValue;
                break;
            case 'Description':
                this.Description = inputValue;
                break;
            case 'StartDateTime':
                this.StartDateTime = inputValue;
                break;
            case 'EndDateTime':
                this.EndDateTime = inputValue;
                break;
            case 'Location':
                this.Location = inputValue;
                break;
            case 'Type':
                this.Type = inputValue;
                break;
            default:
                //Do nothing
                break;
        }
    }

    saveModifiedEvent() {
        var isValidValue = [...this.template.querySelectorAll('lightning-input,lightning-combobox')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);

        if (!this.Description || this.Description == undefined) {
            this.validity = false;
        }
        else {
            this.validity = true;
        }

        if (this.validity && isValidValue && this.Subject && this.Description && this.StartDateTime && this.EndDateTime && this.Location && this.Type) {
            this.showSpinner = true;
            saveModifiedEvent({
                sub: this.Subject, descrip: this.Description, startdt: this.StartDateTime,
                endt: this.EndDateTime, loc: this.Location, type: this.Type, eventId: this.recId, notifyUser: this.showBool
            })
                .then(result => {
                    if (result) {
                        this.showSpinner = false;
                        this.closeModal();
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success:',
                                message: 'Event Modified!.',
                                variant: 'success',
                            }),
                        );
                        window.open(CommunityURL + 'eventdetails?id=' + result, "_self");
                    }
                })
                .catch(error => {
                    this.showSpinner = false;
                    let errormsg = (error.body.message.includes('last longer than 14 days')) ? helpEventDuration : error.body.message; //Tag 4
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error : ',
                            message: errormsg,
                            variant: 'error',
                        }),
                    );
                    
                })
        }

    }

    deleteEvent() {
        this.isDialogVisible = true;
    }

    handleModalClick(event) {
        if (event.target.name === 'confirmModal') {
            //when user clicks outside of the dialog area, the event is dispatched with detail value  as 1
            if (event.detail !== 1) {
                if (event.detail.status === 'confirm') {
                    let objParent = this;
                    objParent.isLoading = true;
                    deleteEvent({ eventId: this.recId })
                        .then(result1 => {
                            if (result1) {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Success:',
                                        message: 'Event Deleted!.',
                                        variant: 'success',
                                    }),
                                );
                                objParent.isLoading = false;
                                this.isDialogVisible = false;
                                window.open(CommunityURL + 'event-landing', "_self");

                            }
                        })
                        .catch(error => {
                            console.log(error.body.message);
                        })


                } else if (event.detail.status === 'cancel') {
                    this.isDialogVisible = false;
                }
            }
        }

    }



    closeModal() {
        this.showModifyModal = false;
        this.showBool = true;
    }

    /*
     Method Name : closeCreateEvent
     Description : This method closes the modal.
     Parameters	 : None
     Return Type : None
     */
    closeCreateEvent() {
        this.showCreateEvent = false;
    }

    /*
     Method Name : downloadCalender
     Description : This method downloads the ics file for the event.
     Parameters	 : None
     Return Type : None
     */
    downloadCalender() {
        let objParent = this;

        if (objParent.recordId) {
            this.recId = objParent.recordId;
        }
        else {
            this.recId = window.location.href.toString().split('?id=')[1];
        }

        getExportToCalendar({ strRecordId: this.recId })
            .then(objVcalendar => {
                if (typeof objVcalendar === 'object' && objUtilities.isNotBlank(objVcalendar.FileName) && objUtilities.isNotBlank(objVcalendar.FileLink)) {
                    var hiddenElement = document.createElement('a');
                    hiddenElement.href = 'data:text/calendar;charset=utf-8,' + encodeURI(objVcalendar.FileLink);
                    hiddenElement.target = '_self';
                    hiddenElement.download = objVcalendar.FileName + '.ics';
                    document.body.appendChild(hiddenElement);
                    hiddenElement.click();
                }
            })
            .catch(objError => {
                objUtilities.processException(objError, objParent);
            })
    }

    /*
     Method Name : exportParticipants
     Description : This method gets list of all participants of the event, parses and then downloads data as an excel file.
     Parameters	 : None
     Return Type : None
     */
    exportParticipants() {
        let objParent = this;

        if (objParent.recordId) {
            this.recId = objParent.recordId;
        }
        else {
            this.recId = window.location.href.toString().split('?id=')[1];
        }

        getEventParticipants({ strRecordId: this.recId })
            .then(objEventParticipants => {
                if (Array.isArray(objEventParticipants) && objEventParticipants?.length > 0) {
                    let strParsedData = objParent.parseData(objEventParticipants);
                    var hiddenElement = document.createElement('a');
                    hiddenElement.href = 'data:application/vnd.ms-excel,' + encodeURI(strParsedData);
                    hiddenElement.target = '_self';
                    hiddenElement.download = 'Export Participants' + '.xls';
                    document.body.appendChild(hiddenElement);
                    hiddenElement.click();
                }
                else {
                    objUtilities.showToast("Error", 'No Participants to export!', "error", objParent);
                }
            })
            .catch(objError => {
                objUtilities.processException(objError, objParent);
            })
    }

    /*
     Method Name : parseData
     Description : This method parses the data for excel.
     Parameters	 : Object, called from exportParticipants, objData
     Return Type : String
     */
    parseData(objData) {
        let tableData = '<table>';

        this.objExportColumns.Labels.forEach(column => {
            tableData += '<th>' + column + '</th>';
        });

        objData.forEach(row => {
            tableData += '<tr>';
            this.objExportColumns.FieldNames.forEach(field => {
                tableData += '<th>' + (objUtilities.isNotBlank(row[field]) ? row[field] : '') + '</th>'
            });
            tableData += '</tr>';
        });
        tableData += '</table>';

        return tableData;
    }

}