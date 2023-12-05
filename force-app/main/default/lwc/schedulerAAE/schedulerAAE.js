/*
 * Name			:	schedulerAAE
 * Author		:	Vignesh Divakaran
 * Created Date	: 	9/15/2023
 * Description	:	This LWC books timeslots and creates Service Appointments for "Ask An Expert".

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description							Tag
 **********************************************************************************************************
 Vignesh Divakaran		09/15/2023		I2RT-9063		Initial version.					N/A
 Shashikanth			10/18/2023		I2RT-7702		Setting up default Timezone			T01
														to Contact Timezone
 */

//Core imports.
import { LightningElement, api, track } from 'lwc';
import TIME_ZONE from '@salesforce/i18n/timeZone';

//Utilities.
import { objUtilities } from 'c/globalUtilities';
 
//Apex Controllers.
import getTimeZoneValues from "@salesforce/apex/GlobalSchedulerController.getTimeZoneValues";
import getAAETimeSlots from "@salesforce/apex/GlobalSchedulerController.getAAETimeSlots";
import getContactTimezone from "@salesforce/apex/GlobalSchedulerController.getContactTimezone";			//<T01>

//Custom Labels.
import Scheduler_AAE_Title from '@salesforce/label/c.Scheduler_AAE_Title';

//Class body.
export default class SchedulerAAE extends LightningElement {

	//API variables.
	@api strWorkTypeGroupId;
	@api strSelectedTimeSlotAAE;
	@api datTSelectedStartTime;
	@api datTSelectedEndTime;
	@api strSelectedDisplayStartTime;
	@api strSelectedDisplayEndTime

	//Track variables.
	@track strSelectedDate;
	@track objTimeZones;
	@track lstAvailableDays;

	//Private variables.
	boolInitialLoad;
	boolDisplaySpinner;
	boolHasSlots;
	intDaysLimit = 7;
	intCurrentPage;
	intMaxPages;
	strStart;
	strStop;
	strCalendarStart;
	strCalendarStop;
	strStop;
	strSelectedTimeZone;
	datStart;
	datStop;
	lstSelectedSlots;
	lstAllDays;
	lstOriginalSlots;

	//Labels.
	label = {
		Scheduler_AAE_Title
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
	}
	

	/*
	 Method Name : initializeComponent
	 Description : This method gets executed after load.
	 Parameters	 : None
	 Return Type : None
	 */
	initializeComponent() {
		let objParent = this;

		//We now initialize the variables.
		objParent.boolDisplaySpinner = true;
		objParent.objTimeZones = {};
		objParent.strSelectedTimeZone = TIME_ZONE;

		//Now we get the time zones.
		getTimeZoneValues().then((objTimeZones) => {
			objParent.objTimeZones = objTimeZones;
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		});

		//<T01>
		//get contact Timezone for the logged in user.
		getContactTimezone()
		.then(strContactTimezone => {
			objParent.strSelectedTimeZone = !!strContactTimezone ? strContactTimezone : TIME_ZONE;
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		});
		//</T01>
		objParent.loadAvailableSlots();
	}

	/*
	 Method Name : renderedCallback
	 Description : This method gets executed after load.
	 Parameters	 : None
	 Return Type : None
	 */
	renderedCallback() {
		let strComponentName = "c-scheduler-a-a-e";

		//We apply custom styling.
		if(!this.boolInitialLoad) {
			this.boolInitialLoad = true;

			//Now we load the custom general styling.
			this.template.querySelectorAll('.customGeneralCSS').forEach(objElement => {
				objElement.innerHTML = "<style> " + 
						strComponentName + " .slots button, " + strComponentName + " .slots button {" + 
						"	padding-left: 5px !important;" + 
						"	padding-right: 5px !important;" + 
						"	width: 100%;" + 
						"} " + strComponentName + " .calendarButton input, " + strComponentName + " .calendarButton input {" + 
						"	width: 10px;" + 
						"	cursor: pointer;" + 
						"	padding-right: 18px !important;" + 
						"} " + strComponentName + " .calendarButton lightning-button-icon, " + strComponentName + " .calendarButton lightning-button-icon {" + 
						"	width: 10px;" + 
						"	padding-left: 2px;" + 
						"} " + strComponentName + " .slds-has-error .slds-form-element__help {" + 
						"	display: none;" + 
						"} </style>";
			});
		}
    }

	/*
	 Method Name : loadAvailableSlots
	 Description : This method fetches the available slots from the backend.
	 Parameters	 : None
	 Return Type : None
	 */
	 loadAvailableSlots() {
		let objParent = this;

		//Now we get the available slots.
		getAAETimeSlots({
			strProduct: objParent.strWorkTypeGroupId
		}).then(lstSlots => {
			objParent.lstOriginalSlots = lstSlots;
			objParent.formatSlots();
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		});
	}

	/*
	 Method Name : formatSlots
	 Description : This method prepares the Slots for the UI.
	 Parameters	 : None
	 Return Type : None
	 */
	formatSlots() {
		let strSvSEFormat;
		let strHeader;
		let strCalendarStart;
		let strCalendarStop;
		let datTCalendarNow;
		let datTCalendarStop;
		let objParent = this;
		let objSlotProperties;
		let lstSlotsInSelectedTimeZone = new Array();

		//We set the initial values.
		objParent.intCurrentPage = objParent.intCurrentPage || 1;
		objParent.intMaxPages = 1;
		objParent.strCalendarStart = "";
		objParent.strCalendarStop = "";
		objParent.strStart = "";
		objParent.strStop = "";
		objParent.lstAllDays = new Array();
		objParent.lstAvailableDays = new Array();
		objParent.lstSelectedSlots = new Array();

		//First we convert all the date times to the selected Time Zone.
		if(objUtilities.isNotNull(objParent.lstOriginalSlots) && objParent.lstOriginalSlots.length > 0) {

			//Now we fill the days without slots, finding first the start and stop dates of the calendar.
			strCalendarStart = objParent.lstOriginalSlots[0].datTCalendarStart.replace(".000Z", "");
			strCalendarStop = objParent.lstOriginalSlots[0].datTCalendarStop.replace(".000Z", "");
			datTCalendarNow = objParent.getSunday(new Date(strCalendarStart));
			datTCalendarStop = objParent.getSaturday(new Date(strCalendarStop));

			//Now we fill the calendar.
			while(datTCalendarNow <= datTCalendarStop) {

				//We get the header.
				strHeader = (new Intl.DateTimeFormat("en-US", {
					weekday: "short",
					timeZone: objParent.strSelectedTimeZone,
				}).format(new Date(datTCalendarNow))).toUpperCase() + " " + new Intl.DateTimeFormat("en-US", {
					day: "2-digit",
					timeZone: objParent.strSelectedTimeZone,
				}).format(new Date(datTCalendarNow));

				//We set the limit of the calendar picker.
				strSvSEFormat = new Intl.DateTimeFormat("sv-SE", {
					day: "2-digit",
					month: "2-digit",
					year: "numeric",
					timeZone: objParent.strSelectedTimeZone,
				}).format(new Date(datTCalendarNow));
				if(objUtilities.isBlank(objParent.strCalendarStart)) {
					objParent.strCalendarStart = strSvSEFormat;
					objParent.strSelectedDate = strSvSEFormat;
				}
				objParent.strCalendarStop = strSvSEFormat;

				//Now we add the column.
				objParent.lstAllDays.push({
					boolHasSlots: false,
					intPage: Math.ceil((objParent.lstAllDays.length + 1) / 7),
					strSvSEFormat: strSvSEFormat,
					strHeader: strHeader,
					strLongDate: new Intl.DateTimeFormat("en-US", {
						dateStyle: 'long',
						timeZone: objParent.strSelectedTimeZone,
					}).format(new Date(datTCalendarNow)),
					datTCalendarStart: objParent.lstOriginalSlots[0].datTCalendarStart,
					datTCalendarStop: objParent.lstOriginalSlots[0].datTCalendarStop,
					lstSlots: new Array()
				});

				//Now we move to the next day.
				datTCalendarNow.setDate(datTCalendarNow.getDate() + 1);
			}

			//Now we fetch the existing slots.
			objParent.lstOriginalSlots.forEach(objSlot => {

				//First we get the header.
				strHeader = (new Intl.DateTimeFormat("en-US", {
					weekday: "short",
					timeZone: objParent.strSelectedTimeZone,
				}).format(new Date(objSlot.datTStart))).toUpperCase() + " " + new Intl.DateTimeFormat("en-US", {
					day: "2-digit",
					timeZone: objParent.strSelectedTimeZone,
				}).format(new Date(objSlot.datTStart));

				//Now we get the already saved slots.
				objParent.lstAllDays.forEach(objSavedDay => {
					if(objSavedDay.strHeader === strHeader) {
						lstSlotsInSelectedTimeZone = objSavedDay.lstSlots;
					}
				});

				//Now we create the slot in the corresponding timezone.
				objSlotProperties = {
					strId: objSlot.strRecordId,
					datTOriginalStart: objSlot.datTStart,
					datTOriginalEnd: objSlot.datTStop,
					strStartDateTime: new Intl.DateTimeFormat("en-US", {
						year: "numeric", 
						month: "numeric", 
						day: "numeric", 
						hour: "numeric", 
						minute: "2-digit",
						timeZoneName: "long",
						timeZone: objParent.strSelectedTimeZone
					}).format(new Date(objSlot.datTStart)),
					strEndDateTime: new Intl.DateTimeFormat("en-US", {
						year: "numeric", 
						month: "numeric", 
						day: "numeric", 
						hour: "numeric", 
						minute: "2-digit",
						timeZoneName: "long",
						timeZone: objParent.strSelectedTimeZone
					}).format(new Date(objSlot.datTStop)),
					datTStart: new Intl.DateTimeFormat("en-US", {
						hour: "2-digit", 
						hourCycle: "h12",
						minute: "2-digit",
						timeZone: objParent.strSelectedTimeZone,
					}).format(new Date(objSlot.datTStart)),
					datTStop: new Intl.DateTimeFormat("en-US", {
						hour: "2-digit", 
						hourCycle: "h12",
						minute: "2-digit",
						timeZone: objParent.strSelectedTimeZone,
					}).format(new Date(objSlot.datTStop))
				};
				objSlotProperties.strSlotLabel = objSlotProperties.datTStart.replace("AM", "").replace("PM", "").replace(" ", "") + " - " + objSlotProperties.datTStop.toLowerCase(),
				lstSlotsInSelectedTimeZone.push(objSlotProperties);

				//Now we save the slots.
				objParent.lstAllDays.forEach(objSavedDay => {
					if(objSavedDay.strHeader === strHeader) {
						objSavedDay.lstSlots = lstSlotsInSelectedTimeZone;
						objSavedDay.boolHasSlots = true;
					}
				});
			});

			//Now we set the available pages.
			objParent.intMaxPages = objParent.lstAllDays.length / 7;

			//Now we set the current week.
			objParent.changeCalendarPage(objParent.intCurrentPage);
			objParent.selectSlot(objParent.strSelectedTimeSlotAAE);
			objParent.boolHasSlots = true;
		}
		else {
			objParent.boolHasSlots = false;
          	//Now we hide the spinner.
			objParent.boolDisplaySpinner = false;
		}
	}

	/*
	 Method Name : getSunday
	 Description : This method returns the Sunday of the week of the given date.
	 Parameters	 : Date Time, called from getSunday, datTDateToAnalyze Date to analize.
	 Return Type : None
	 */
	getSunday(datTDateToAnalyze) {
		datTDateToAnalyze.setDate(datTDateToAnalyze.getDate() - datTDateToAnalyze.getDay());
		return datTDateToAnalyze;
	}

	/*
	 Method Name : getSaturday
	 Description : This method returns the Saturday of the week of the given date.
	 Parameters	 : Date Time, called from getSaturday, datTDateToAnalyze Date to analize.
	 Return Type : None
	 */
	getSaturday(datTDateToAnalyze) {
		datTDateToAnalyze.setDate(datTDateToAnalyze.getDate() - datTDateToAnalyze.getDay() + 6);
		return datTDateToAnalyze;
	}

	/*
	 Method Name : updateTimeZone
	 Description : This method updates the time zone of the time slots.
	 Parameters	 : Object, called from updateTimeZone, objEvent On change event.
	 Return Type : None
	 */
	updateTimeZone(objEvent) {
		this.boolDisplaySpinner = true;
		this.strSelectedTimeZone = objEvent.detail.value;
		this.formatSlots(JSON.parse(JSON.stringify(this.lstAllDays)));
	}

	/*
	 Method Name : moveForward
	 Description : This method moves the calendar to the next 7 days.
	 Parameters	 : None
	 Return Type : None
	 */
	moveForward() {
		if(this.intCurrentPage + 1 <= this.intMaxPages) {
			this.changeCalendarPage(this.intCurrentPage + 1);
		}
	}

	/*
	 Method Name : moveBackwards
	 Description : This method moves the calendar to the previous 7 days.
	 Parameters	 : None
	 Return Type : None
	 */
	moveBackwards() {
		if(this.intCurrentPage - 1 >= 1) {
			this.changeCalendarPage(this.intCurrentPage - 1);
		}
	}

	/*
	 Method Name : setSpecificDate
	 Description : This method moves the calendar to a specific date.
	 Parameters	 : Object, called from setSpecificDate, objEvent On change event.
	 Return Type : None
	 */
	setSpecificDate(objEvent) {
		let objParent = this;
		objParent.strSelectedDate = objParent.strCalendarStart;
		objParent.lstAllDays.forEach(objSlot => {
			if(objSlot.strSvSEFormat === objEvent.target.value) {
				objParent.changeCalendarPage(objSlot.intPage);
				objParent.strSelectedDate = objSlot.strSvSEFormat;
			}
		});
	}

	/*
	 Method Name : changeCalendarPage
	 Description : This method moves the calendar to a specific page.
	 Parameters	 : Integer, called from changeCalendarPage, intNewPage Page number.
	 Return Type : None
	 */
	changeCalendarPage(intNewPage) {
		let intLimitLow = (this.intDaysLimit * intNewPage) - this.intDaysLimit;
		let intLimitHigh = (this.intDaysLimit * intNewPage);
		let intIndex = 0;
		let objParent = this;
		let objLastSlot;

		//We set the new values.
		objParent.boolDisplaySpinner = true;
		objParent.intCurrentPage = intNewPage;
		objParent.strStart = null;
		objParent.strStop = null;
		objParent.lstAvailableDays = new Array();

		//Set the new slots.
		objParent.lstAllDays.forEach(objSavedDay => {
			if(intIndex >= intLimitLow && intIndex < intLimitHigh) {
				if(objUtilities.isBlank(objParent.strStart)) {
					objParent.strStart = objSavedDay.strLongDate;
				}
				objParent.lstAvailableDays.push(objSavedDay);
				objLastSlot = objSavedDay;
			}
			intIndex++;
		});
		if(objUtilities.isNotNull(objLastSlot)) {
			objParent.strStop = objLastSlot.strLongDate;
		}

		//We remove the spinner.
		setTimeout(function() {
			objParent.boolDisplaySpinner = false;
		}, 800);
	}

	/*
	 Method Name : clickSlot
	 Description : This method updates the status of selected slot / button.
	 Parameters	 : Object, called from clickSlot, objEvent On click event.
	 Return Type : None
	 */
	clickSlot(objEvent) {
		this.selectSlot(objEvent.currentTarget.dataset.id);
	}

	/*
	 Method Name : selectSlot
	 Description : This method updates the status of selected slot / button.
	 Parameters	 : String, called from clickSlot, strId Time Slot AAE record id.
	 Return Type : None
	 */
	selectSlot(strId) {
		let objParent = this;

		if (objUtilities.isNotBlank(strId)) {
			//We set the default values.
			objParent.strSelectedTimeSlotAAE = "";
			objParent.datTSelectedStartTime = "";
			objParent.datTSelectedEndTime = "";

			//Now we check if already selected another slot, so we remove it.
			objParent.lstAvailableDays.forEach(objDay => {
				objDay.lstSlots.forEach(objSlot => {
					if(objSlot.strState === "brand" && objSlot.strId !== strId) {
						objSlot.strState = "neutral";
					}
				});
			});

			//Now we check across available slots.
			objParent.lstAvailableDays.forEach(objDay => {
				objDay.lstSlots.forEach(objSlot => {
					if(objSlot.strId === strId) {
						if(objSlot.strState === "brand") {
							objSlot.strState = "neutral";
						} else {
							objSlot.strState = "brand";
							objParent.strSelectedTimeSlotAAE = strId;
							objParent.datTSelectedStartTime = objSlot.datTOriginalStart;
							objParent.datTSelectedEndTime = objSlot.datTOriginalEnd;
							objParent.strSelectedDisplayStartTime = objSlot.strStartDateTime;
							objParent.strSelectedDisplayEndTime = objSlot.strEndDateTime;
						}
					}
				});
			});
		}
	}

	//Getter methods
	get lstTimezones(){
		let lst = [];
		if(this.objTimeZones){
        	Object.entries(this.objTimeZones).map(objTimeZone => {
				lst.push({
					value: objTimeZone[0],
					label: objTimeZone[1]
				});
			});
        }
		return lst;
	}
}