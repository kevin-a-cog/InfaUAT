/*
 * Name			:	EventDetail
 * Author		:	Narpavi Prabu
 * Created Date	: 	21/03/2022	
 * Description	:	This LWC is used to create event in user group.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description							                                      Tag
 **********************************************************************************************************
 Narpavi Prabu		  21/03/2022		 		       Initial version.					                                          N/A
 Deeksha Shetty       19/07/2022        I2RT-6706      Notification criteria - Events                                             T1  
 saumya Gaikwad       21/07/2022        I2RT-6757      Chapter leaders should be able to create Events and Announcement
 Deeksha Shetty       17/10/2022        I2RT-7272      Giving option for the admin/Leader to edit the events without              T2
                                                       notifying the user
 Deeksha Shetty       14/03/2023      I2RT-7801        Create/Modify Event: Custom error message is not displaying when admin     T3
                                                        enter event duration more than 14 days.                                                       
 */


//Core imports.
import { LightningElement, wire, api } from 'lwc';
import { objUtilities } from 'c/globalUtilities';
import getEventTypePicklistValues from "@salesforce/apex/helpEventsController.getEventTypePicklistValues";
import createGroupEvent from "@salesforce/apex/helpGroupsController.createGroupEvent";
import sendMailPostEventCreation from "@salesforce/apex/helpGroupsController.sendMailPostEventCreation";
import { getRecord } from 'lightning/uiRecordApi';
import TIMEZONE_FIELD from '@salesforce/schema/User.TimeZoneSidKey';
import userId from "@salesforce/user/Id";
import getmetadatarecords from '@salesforce/apex/helpEventsController.getmetadatarecords';
import CommunityURL from '@salesforce/label/c.IN_CommunityName';
import { loadStyle } from 'lightning/platformResourceLoader';
import IN_StaticResource3 from "@salesforce/resourceUrl/InformaticaNetwork3";
//T3 starts
import helpEventDuration from '@salesforce/label/c.helpEventDuration';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//T3 ends

export default class HelpGroupCreateEvent extends LightningElement {

    //Private Variables
    isLoading;
    objEvent;
    typeOptions;
    todaydate;
    @api selectedpostto;

    //T2 starts here
    showBool = true; 
    validity =true;
    userTZ;
    notifyUsrMsg;
    toolTipMsg;
    mailhelpText;
     //T2 ends here


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
            this.todaydate = new Date();
            console.log(this.selectedpostto);
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

    @wire(getRecord, { recordId: userId, fields: [TIMEZONE_FIELD] })
    userDetails({ error, data }) {
        if (data) {
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
    //T2 starts here
    handleMailNotification(event) {
        this.showBool = event.target.checked;
    }
    //T2 ends here

    /*
     Method Name : createEvent
     Description : This method creates an event.
     Parameters	 : Object, called from createEvent, objEvent On click event.
     Return Type : None
     */
    createEvent(objEvent) {
        let objParent = this;
        console.log(this.selectedpostto);
        console.log(this.selectedpostto);
        var isValidValue = [...this.template.querySelectorAll('lightning-input,lightning-textarea')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);

            if(this.objEvent.Description == undefined || !this.objEvent.Description){
                this.validity = false;
            }
            else{
                this.validity=true;
            }

        if (isValidValue && this.validity) {
            objParent.isLoading = true;
            createGroupEvent({ strEvent: JSON.stringify(objParent.objEvent), grpId: this.selectedpostto })
                .then(result => {
                    if (result) {
                        console.log('result>>>>>', result);
                        objUtilities.showToast("Success", 'Event has been created successfully', "success", objParent);
                        objParent.isLoading = false;

                        //T2 - showBool and event detail redirection
                        window.open(CommunityURL+'eventdetails?id='+result, "_self");                      
                        if (this.showBool) {
                            /** T1 starts here */
                            sendMailPostEventCreation({ groupId: this.selectedpostto, eventId: result, eventAction: 'Insert' })
                                .then((data) => {
                                    console.log('result>>>>>' + data);
                                })
                                .catch((error) => {
                                    console.log('Send Email Error > ', error);
                                })
                            /**T1 Ends here */

                        }
                        objParent.closeModal();
                    }
                })
                .catch(objError => {
                    let errormsg = (objError.body.message.includes('last longer than 14 days')) ? helpEventDuration : objError.body.message; //T3
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
        this.showBool = true;
        this.dispatchEvent(new CustomEvent('close'));
    }
}