/*
 * Name			:	EventDetail
 * Author		:	Vignesh Divakaran
 * Created Date	: 	10/02/2022
 * Description	:	This LWC is used to create event.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description							                                       Tag
 **********************************************************************************************************
 Vignesh Divakaran		10/02/2022		I2RT-5251		Initial version.					                                       N/A
 Deeksha Shetty         23/11/2022      I2RT-7399       Event: Showing Timezone in create/Modify event page                         1
 Deeksha Shetty         14/03/2023      I2RT-7801       Create/Modify Event: Custom error message is not displaying when admin      2
                                                        enter event duration more than 14 days.
 */

//Core imports.
import { LightningElement, wire, api } from 'lwc';
import createEvent from "@salesforce/apex/EventDetailController.createEvent";
import { objUtilities } from 'c/globalUtilities';
import getEventTypePicklistValues from "@salesforce/apex/helpEventsController.getEventTypePicklistValues";
import CommunityURL from '@salesforce/label/c.IN_CommunityName';
import { getRecord } from 'lightning/uiRecordApi';
import TIMEZONE_FIELD from '@salesforce/schema/User.TimeZoneSidKey';
import userId from "@salesforce/user/Id";
import getmetadatarecords from '@salesforce/apex/helpEventsController.getmetadatarecords';
import { loadStyle } from 'lightning/platformResourceLoader';
import IN_StaticResource3 from "@salesforce/resourceUrl/InformaticaNetwork3";
//Tag 2 starts
import helpEventDuration from '@salesforce/label/c.helpEventDuration';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//Tag 2 ends

export default class CreateEvent extends LightningElement {
    validity = true;
    //Private Variables
    isLoading;
    objEvent;
    typeOptions;
    todaydate;

    //T1 starts here
    userTZ;
    notifyUsrMsg;
    toolTipMsg;
    mailhelpText;
    //T1 ends here


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
    }

    //Style
    loadCustomStyle() {
        try {
            Promise.all([
                loadStyle(this, IN_StaticResource3 + "/helpEventModal/helpeventmodal.css")
            ])
        } catch (error) {
            Log('error', 'helpEventModal : Method : loadCustomStyle; Error :' + error.message + " : " + error.stack);
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

    @wire(getRecord, { recordId: userId, fields: [TIMEZONE_FIELD] })
    userDetails({ error, data }) {
        if (data) {
            this.userTZ = '(' + data.fields.TimeZoneSidKey.value + ')';
        } else if (error) {
            console.log('Error=' + error.body);
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
            console.log('Picklistvals=' + JSON.stringify(this.typepicklistfilter));
            this.todaydate = new Date();
        }
        else if (result.error) {
            console.log(JSON.stringify(result.error));
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
        objParent.objEvent = {
            Subject: '',
            Description: '',
            StartDateTime: '',
            EndDateTime: '',
            Location: '',
            Type: ''
        };
    }

    /*
     Method Name : inputChange
     Description : This method updates the user input to the corresponding event fields.
     Parameters	 : Object, called from inputChange, objEvent On change event.
     Return Type : None
     */
    inputChange(objEvent) {
        let inputValue = objEvent.target.value;
        console.log('inputValue=' + JSON.stringify(inputValue));

        switch (objEvent.target.name) {
            case 'Subject':
                this.objEvent.Subject = inputValue;
                break;
            case 'Description':
                this.objEvent.Description = inputValue;
                break;
            case 'StartDateTime':
                this.objEvent.StartDateTime = inputValue;
                break;
            case 'EndDateTime':
                this.objEvent.EndDateTime = inputValue;
                break;
            case 'Location':
                this.objEvent.Location = inputValue;
                break;
            case 'Type':
                this.objEvent.Type = inputValue;
                break;
            default:
                //Do nothing
                break;
        }
    }

    /*
     Method Name : createEvent
     Description : This method creates an event.
     Parameters	 : Object, called from createEvent, objEvent On click event.
     Return Type : None
     */
    createEvent(objEvent) {
        let objParent = this;

        var isValidValue = [...this.template.querySelectorAll('lightning-input,lightning-combobox')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);

        if (this.objEvent.Description == undefined || !this.objEvent.Description) {
            this.validity = false;
        }
        else {
            this.validity = true;
        }

        if (isValidValue && this.validity) {
            objParent.isLoading = true;

            createEvent({ strEvent: JSON.stringify(objParent.objEvent) })
                .then(result => {
                    if (result) {
                        objUtilities.showToast("Success", 'Event has been created successfully', "success", objParent);
                        objParent.isLoading = false;
                        objParent.closeModal();
                        window.open(CommunityURL + 'eventdetails?id=' + result, "_self");
                    }
                })
                .catch(objError => {
                    let errormsg = (objError.body.message.includes('last longer than 14 days')) ? helpEventDuration : objError.body.message; //Tag 2
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error : ',
                            message: errormsg,
                            variant: 'error',
                        }),
                    );
                    objParent.isLoading = false;
                })
        }
    }

    /*
     Method Name : closeModal
     Description : This method closes the modal.
     Parameters	 : None
     Return Type : None
     */
    closeModal() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}