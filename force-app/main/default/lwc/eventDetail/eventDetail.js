/*
 * Name			:	EventDetail
 * Author		:	Vignesh Divakaran
 * Created Date	: 	09/02/2022
 * Description	:	This LWC is used to display details related to the event.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description							Tag
 **********************************************************************************************************
 Vignesh Divakaran		09/02/2022		I2RT-5251		Initial version.					N/A
 */

//Core imports.
import { LightningElement, api, track } from 'lwc';
import TIME_ZONE from '@salesforce/i18n/timeZone';

//Static Resource
import INFORMATICA_NETWORK_RESOURCE from '@salesforce/resourceUrl/informaticaNetwork';

//Apex Controllers.
import getEvent from "@salesforce/apex/EventDetailController.getEvent";
import likeEvent from "@salesforce/apex/EventDetailController.likeEvent";
import followEvent from "@salesforce/apex/EventDetailController.followEvent";

//Utilities.
import { objUtilities } from 'c/globalUtilities';

export default class EventDetail extends LightningElement {

    //API Variables
    @api recordId;

    //Private Variables
    isLoading;
    Icons = {
        Calender: INFORMATICA_NETWORK_RESOURCE + '/EventDetail/Calender.svg',
        LocationMarker: INFORMATICA_NETWORK_RESOURCE + '/EventDetail/LocationMarker.svg'
    };
    objEvent;
    groupName;
    eventstatus;
    vaUrl;



    @track objEventOptions = [
        {
            name: 'Event Like',
            switch: false, 
            on: {label: 'Liked', key: 'Like', iconName: 'utility:like', variant: 'bare', size: 'large', className: 'event-option-icon-green'}, 
            off: {label: 'Like', key: 'Like', iconName: 'utility:like', variant: 'bare', size: 'large', className: 'event-option-icon-grey'}
        },
        {
            name: 'Event Follow',
            switch: false, 
            on: {label: 'Following', key: 'Follow', iconName: 'utility:add', variant: 'bare', size: 'large', className: 'event-option-icon-orange'}, 
            off: {label: 'Follow', key: 'Follow', iconName: 'utility:add', variant: 'bare', size: 'large', className: 'event-option-icon-grey'}
        },
        // {   name: 'Event Share',
        //     switch: false, 
        //     on: {label: 'Share', key:'Share', iconName: 'utility:share', variant: 'bare', size: 'large', className: 'event-option-icon-grey'}, 
        //     off: {label: 'Share', key:'Share', iconName: 'utility:share', variant: 'bare', size: 'large', className: 'event-option-icon-grey'}
        // }
    ];

    

    /*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
		
		//We initialize the components.
		this.initializeComponent();
	}

    /*
	 Method Name : initializeComponent
	 Description : This method gets executed after load.
	 Parameters	 : None
	 Return Type : None
	 */
    initializeComponent(){
        let objParent = this;

        objParent.isLoading = true;

        if (objParent.recordId) {
            this.recId = objParent.recordId;
            console.log('this.recId in UserId Present=' + JSON.stringify(this.recId));
        }
        else {
            this.recId = window.location.href.toString().split('?id=')[1];
            console.log('this.recId in UserId Absent=' + JSON.stringify(this.recId));
        }

        getEvent({ strRecordId : this.recId})
        .then(objResponse => {
            console.log('Respinse event detail='+JSON.stringify(objResponse));
            if(typeof objResponse === 'object' && Object.keys(objResponse).length > 0){
                let startDateTime = new Date(objResponse.objEvent.StartDateTime);
                let endDateTime = new Date(objResponse.objEvent.EndDateTime);
                let strDateTimeFormatted = ''+
                objParent.dateFormatter(startDateTime, {weekday:'long', month: 'short', day: '2-digit', year: 'numeric'}) +" "+
                objParent.dateFormatter(startDateTime, {hour: '2-digit', hourCycle: 'h12', minute: '2-digit'}) +" to "+
                objParent.dateFormatter(endDateTime, {hour: '2-digit', hourCycle: 'h12', minute: '2-digit', timeZoneName: 'short'});
                
                objResponse.objEvent.eventVisibility = objResponse.objEvent.IsVisibleInSelfService ? 'PUBLIC' : 'PRIVATE';
                objResponse.objEvent.eventDateTimeFormatted = objResponse.FormattedDateTime; // DateTime Format: Monday, Jan 03, 2022 12:00 PM to 2:00 PM PST
                    this.vaUrl = this.validURL(objResponse.objEvent.Location);
                this.groupName = objResponse.groupName;
                this.eventstatus = objResponse.EventStatus;
                objParent.objEvent = objResponse.objEvent;
                objResponse.lstEventOptions.forEach(eventOption => {
                    objParent.eventOptionToggle(eventOption.Name, eventOption.ToggleSwitch);
                });

            }
            else{
                objUtilities.showToast("Error", 'Unable to fetch event.', "error", objParent);
            }
        })
        .catch(objError => {
            objUtilities.processException(objError, objParent);
        })
        .finally(() => {
            objParent.isLoading = false;
		});
    }

    //Checks if string is a Valid URL
    validURL(str) {
        var pattern = new RegExp('^(https?:\\/\\/)?' + // protocol
            '((([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.)+[a-z]{2,}|' + // domain name
            '((\\d{1,3}\\.){3}\\d{1,3}))' + // OR ip (v4) address
            '(\\:\\d+)?(\\/[-a-z\\d%_.~+]*)*' + // port and path
            '(\\?[;&a-z\\d%_.~+=-]*)?' + // query string
            '(\\#[-a-z\\d_]*)?$', 'i'); // fragment locator
        return !!pattern.test(str);
    }

    /*
	 Method Name : dateFormatter
	 Description : This method returns the formatted date.
	 Parameters	 : (Date, Object), called from initializeComponent, (date, objFormat)
	 Return Type : String
	 */
    dateFormatter(date, objFormat){
        //Use timezone from salesforce user
        objFormat.timezone = TIME_ZONE;

        return new Intl.DateTimeFormat('en-US', objFormat).format(date); 
    }

    /*
	 Method Name : optionSelected
	 Description : This method routes selected option to the appropriate method.
	 Parameters	 : Object, called from actionSelected, objEvent On click event.
	 Return Type : None
	 */
    optionSelected(objEvent){
        switch (objEvent.currentTarget.dataset.option){
            case 'Like': 
                this.likeEvent('Event Like');
                break;
            case 'Follow':
                this.followEvent('Event Follow');
                break;
            case 'Share':
                //Call logic
                break;
            default:
                //Do nothing
                break;
        }
    }

    /*
	 Method Name : likeEvent
	 Description : This method likes or remove like for the event.
	 Parameters	 : strOption, called from optionSelected, strOption.
	 Return Type : None
	 */
    likeEvent(strOption){
        let objParent = this;
        let strAction = '';

        objParent.objEventOptions.forEach(objEventOption => {
            if(objEventOption.name === strOption){
                strAction = objEventOption.switch ? 'UnLike' : 'Like';
            }
        });

        likeEvent({ recordId : this.recId, action : strAction })
        .then(objResponse => {
            if(typeof objResponse === 'object' && Object.keys(objResponse).length > 0){
                if(objResponse.ToggleSwitch){
                    objParent.eventOptionToggle(objResponse.Name, true);
                }
                else{
                    objParent.eventOptionToggle(objResponse.Name, false);
                }
            }
        })
        .catch(objError => {
            objUtilities.processException(objError, objParent);
        })
    }

    /*
	 Method Name : followEvent
	 Description : This method follows or unfollows the event.
	 Parameters	 : strOption, called from optionSelected, strOption.
	 Return Type : None
	 */
     followEvent(strOption){
        let objParent = this;
        let strAction = '';

        objParent.objEventOptions.forEach(objEventOption => {
            if(objEventOption.name === strOption){
                strAction = objEventOption.switch ? 'UnFollow' : 'Follow';
            }
        });

        followEvent({ recordId : this.recId, action : strAction })
        .then(objResponse => {
            if(typeof objResponse === 'object' && Object.keys(objResponse).length > 0){
                if(objResponse.ToggleSwitch){
                    objParent.eventOptionToggle(objResponse.Name, true);
                }
                else{
                    objParent.eventOptionToggle(objResponse.Name, false);
                }
            }
        })
        .catch(objError => {
            objUtilities.processException(objError, objParent);
        })
     }

    /*
	 Method Name : eventOptionToggle
	 Description : This method toggles the switch for the event option.
	 Parameters	 : (String, Boolean), called from likeEvent, (strOption, boolSwitch).
	 Return Type : None
	 */
    eventOptionToggle(strOption, boolSwitch){
        this.objEventOptions.forEach(objEventOption => {
            if(objEventOption.name === strOption){
                objEventOption.switch = boolSwitch;
            }
        });
    }

}