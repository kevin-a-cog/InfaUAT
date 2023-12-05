/*
 * Name			:	globalScheduler
 * Author		:	Monserrat Pedroza
 * Created Date	: 	7/22/2021
 * Description	:	This LWC creates Appointment Requests and blocks calendars.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		7/22/2021		N/A				Initial version.						 N/A
 Vignesh D              11/24/2021      I2RT-4414       Include email only case contacts    	 T01
 Vignesh D				12/06/2021		I2RT-5110		Select Primary Case Contact by default   T02
 Vignesh D				04/27/2021		I2RT-5749		Added logic for expired token/unexpected T03
 														error when generating zoom meeting.
 */

//Core imports.
import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import uId from '@salesforce/user/Id';

//Utilities.
import { objUtilities } from 'c/globalUtilities';
 
//Apex Controllers.
import getTimeZoneValues from "@salesforce/apex/GlobalSchedulerController.getTimeZoneValues";
import getAvailableSlots from "@salesforce/apex/GlobalSchedulerController.getAvailableSlots"; 
import getRelatedUsers from "@salesforce/apex/GlobalSchedulerController.getRelatedUsers";
import getUserName from "@salesforce/apex/GlobalSchedulerController.getUserName";
import getAppointmentRequestCreated from "@salesforce/apex/GlobalSchedulerController.getAppointmentRequestCreated";
import getIsReadOnly from "@salesforce/apex/GlobalSchedulerController.getIsReadOnly";
import getAppointmentRequestData from "@salesforce/apex/GlobalSchedulerController.getAppointmentRequestData";
import getEventScheduled from "@salesforce/apex/GlobalSchedulerController.getEventScheduled";
import getEmailTemplate from "@salesforce/apex/GlobalSchedulerController.getEmailTemplate";
import getEventDetails from "@salesforce/apex/GlobalSchedulerController.getEventDetails";
import getRecordOwnerValidated from "@salesforce/apex/GlobalSchedulerController.getRecordOwnerValidated";
import getMeetingAccountDetails from "@salesforce/apex/GlobalSchedulerController.getMeetingAccountDetails"; // <T03>
import deleteEvent from "@salesforce/apex/GlobalSchedulerController.deleteEvent"; // <T03>

//Custom Labels.
import Schedule_Created from '@salesforce/label/c.Schedule_Created';
import Select_One_Slot from '@salesforce/label/c.Select_One_Slot';
import Meeting_Scheduled from '@salesforce/label/c.Meeting_Scheduled';
import Select_A_Slot from '@salesforce/label/c.Select_A_Slot';
import Select_A_Contact from '@salesforce/label/c.Select_A_Contact';
import Select_Only_One_Slot from '@salesforce/label/c.Select_Only_One_Slot';
import Scheduler_Control_Today from '@salesforce/label/c.Scheduler_Control_Today';
import Scheduler_Control_Time_Zone from '@salesforce/label/c.Scheduler_Control_Time_Zone';
import Scheduler_Title_Users from '@salesforce/label/c.Scheduler_Title_Users';
import Scheduler_Title_Team_Member from '@salesforce/label/c.Scheduler_Title_Team_Member';
import Scheduler_Title_Attendees from '@salesforce/label/c.Scheduler_Title_Attendees';
import Remove from '@salesforce/label/c.Remove';
import Send_Schedule from '@salesforce/label/c.Send_Schedule';
import Create_Meeting from '@salesforce/label/c.Create_Meeting';
import Insert_Meeting from '@salesforce/label/c.Insert_Meeting';
import Insert_Availability from '@salesforce/label/c.Insert_Availability';
import Scheduler_Title_Case_Contacts from '@salesforce/label/c.Scheduler_Title_Case_Contacts';
import Scheduler_Title_Plan_Contacts from '@salesforce/label/c.Scheduler_Title_Plan_Contacts';
import Scheduler_Title_Other_Contacts from '@salesforce/label/c.Scheduler_Title_Other_Contacts';
import Unavailable_Slots from '@salesforce/label/c.Unavailable_Slots';
import URL_Copied_To_Clipboard from '@salesforce/label/c.URL_Copied_To_Clipboard';
import Owner_Is_Not_User_Or_Account_Missing from '@salesforce/label/c.Owner_Is_Not_User_Or_Account_Missing';
import Scheduler_Expired_Token_Message from '@salesforce/label/c.Scheduler_Expired_Token_Message'; // <T03>
import Scheduler_Unexpected_Error_Message from '@salesforce/label/c.Scheduler_Unexpected_Error_Message'; // <T03>
import Force_com_User_Name from '@salesforce/label/c.Force_com_User_Name';
import Force_com_User_Name_Missing from '@salesforce/label/c.Force_com_User_Name_Missing';
import Name_And_Participants from '@salesforce/label/c.Name_And_Participants';
import Force_com_User_Email from '@salesforce/label/c.Force_com_User_Email';
import Force_com_User_Email_Missing from '@salesforce/label/c.Force_com_User_Email_Missing';

//Class body.
export default class GlobalScheduler extends NavigationMixin(LightningElement) {

	//API variables.
	@api recordId;
	@api boolSendBackResponse;
	@api boolIsSendSchedule;
	@api boolIsCreateInvite;
	@api boolIsPoppedOut;
	@api boolIsExternalSite;

	//Track variables.
	@track strBrowserTimezoneLabel;
	@track lstAvailableSlots;
	@track lstRecordContacts;
	@track lstEmailOnlyCaseContacts; // <T01>

	//Private variables.
	boolShareAsPublic = true;
	boolHasCommunityLink;
	boolIsInQuickAction = false;
	boolDisplayContactsSection;
	boolHasContacts;
	boolHasEmailOnlyCaseContacts;  // <T01>
	boolShowEmailOnlyCaseContacts; // <T01>
	boolHasErrorMessage;
	boolHasAccess;
	boolEventAlreadyCreated;
	boolInitialLoad;
	boolMeetingScheduled;
	boolIsLinkExpired;
	boolIsReadOnly;
	boolIsCaseContact;
	boolIsPlanContact;
	boolHasTeamMembers;
	boolDisableRemove;
	boolRecordIdFound;
	boolDisplaySpinner;
	boolDisplayReauthentication; // <T03>
	intDefaultDurationMinutes;
	strCommunityLink;
	strBodyClasses;
	strCurrentUserId = uId;
	strErrorMessage;
	strSelectedTeamMembers;
	strAvatarURL;
	strRecordId;
	strStart;
	strStop;
	strSelectedTimeZone;
	strExternalCSSBody = "quick-actions-panel schedulerBodyExternal";
	strMeetingAccountRecordId; // <T03>
	strEventId; // <T03>
	datStart;
	datStop;
	objSlotsMap;
	objLooper;
	lstTimeZones;
	lstUsers;
	lstTeamMembers;
	lstSelectedSlots;

	//Labels.
	label = {
		Schedule_Created,
		Select_One_Slot,
		Meeting_Scheduled,
		Select_A_Slot,
		Select_A_Contact,
		Select_Only_One_Slot,
		Scheduler_Control_Today,
		Scheduler_Control_Time_Zone,
		Scheduler_Title_Users,
		Scheduler_Title_Team_Member,
		Scheduler_Title_Attendees,
		Remove,
		Send_Schedule,
		Create_Meeting,
		Insert_Meeting,
		Insert_Availability,
		Scheduler_Title_Case_Contacts,
		Scheduler_Title_Plan_Contacts,
		Scheduler_Title_Other_Contacts,
		Unavailable_Slots,
		URL_Copied_To_Clipboard,
		Owner_Is_Not_User_Or_Account_Missing,
    Scheduler_Expired_Token_Message,
		Scheduler_Unexpected_Error_Message,
		Force_com_User_Name,
		Force_com_User_Name_Missing,
		Name_And_Participants,
		Force_com_User_Email,
		Force_com_User_Email_Missing
	};

	//Duration options.
	get lstDurations() {
        return [
            { label: '15 min', value: 15 },
            { label: '30 min', value: 30 },
            { label: '45 min', value: 45 },
			{ label: '60 min', value: 60 }
        ];
    }

	/*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {

		//First we check if we are in an external site.
		if(this.boolIsExternalSite) {
			this.strExternalCSSBody = "quick-actions-panel schedulerBodyExternalSite";
		}
		
		//We initialize the components.
		this.initializeComponent();
	}

    /*
	 Method Name : disconnectedCallback
	 Description : This method gets executed once the component is removed from the DOM.
	 Parameters	 : None
	 Return Type : None
	 */
    disconnectedCallback() {
        clearTimeout(this.objLooper);
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
		this.boolDisplayContactsSection = false;
		this.boolHasContacts = false;
		this.boolHasEmailOnlyCaseContacts = false;  // <T01>
		this.boolShowEmailOnlyCaseContacts = false; // <T01>
		this.boolHasErrorMessage = false;
		this.boolHasAccess = false;
		this.boolEventAlreadyCreated = false;
		this.boolMeetingScheduled = false;
		this.boolIsLinkExpired = false;
		this.boolIsReadOnly = false;
		this.boolHasTeamMembers = false;
		this.boolDisableRemove = true;
		this.boolRecordIdFound = false;
		this.boolDisplaySpinner = true;
		this.boolDisplayReauthentication = false; // <T03>
		this.intDefaultDurationMinutes = 60;
		this.strSelectedTimeZone = TIME_ZONE;
		this.strEventId = ''; // <T03>
		this.lstTimeZones = new Array();
		this.lstAvailableSlots = new Array();
		this.lstUsers = new Array();
		this.lstTeamMembers = new Array();
		this.lstSelectedSlots = new Array();
		this.lstRecordContacts = new Array();
		this.lstEmailOnlyCaseContacts = new Array(); // <T01>

		//We define if we should display the Case Contacts section.
		if(objUtilities.isNull(this.boolSendBackResponse) || this.boolIsCreateInvite || this.boolIsSendSchedule) { //I2RT-4337
			this.boolDisplayContactsSection = true;

			//We define if we should display email only Case Contacts.
			if(this.boolIsCreateInvite){ // <T01>
				this.boolShowEmailOnlyCaseContacts = true;
			}
		}

		//Now we set the initial dates.
		this.updateDates();

		//Now we get the time zones.
		getTimeZoneValues().then((objTimeZones) => {
			Object.entries(objTimeZones).map(objTimeZone => {
				objParent.lstTimeZones.push({
					value: objTimeZone[0],
					label: objTimeZone[1]
				});
			});
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		});

		//Now we adjust the size of the modal.
		this.strBodyClasses = "quick-actions-panel schedulerBody";
		if(objParent.boolIsPoppedOut) {
			this.strBodyClasses += " schedulerBodyPoppedOut";
		}

		//Now we define which id we will send to the backend, to obtain the related users.
		if(objUtilities.isNotBlank(this.recordId)) {
			this.strRecordId = this.recordId;

			//Now we check if this is a read only scenario.
			this.isReadOnly();
		}

		//If the component has been opened from a Quick Action.
		if(objUtilities.isNotNull(objParent.boolSendBackResponse) && objParent.boolSendBackResponse) {
			objParent.boolIsInQuickAction = false;
		} else {
			objParent.boolIsInQuickAction = true;
		}
	}

	/*
	 Method Name : renderedCallback
	 Description : This method gets executed after load.
	 Parameters	 : None
	 Return Type : None
	 */
	renderedCallback() {

		//We apply custom styling.
		if(!this.boolInitialLoad) {
			this.boolInitialLoad = true;

			//Now we load the custom general styling.
			this.template.querySelectorAll('.customGeneralCSS').forEach(objElement => {
				objElement.innerHTML = "<style> " + 
						"c-globalscheduler .slds-card__body, c-global-scheduler .slds-card__body {" + 
						"	margin-bottom: 0px;" + 
						"} c-globalscheduler .slots button, c-global-scheduler .slots button {" + 
						"	padding-left: 5px !important;" + 
						"	padding-right: 5px !important;" + 
						"	width: 100%;" + 
						"} c-globalscheduler .calendarButton input, c-global-scheduler .calendarButton input {" + 
						"	width: 10px;" + 
						"	cursor: pointer;" + 
						"	padding-right: 18px !important;" + 
						"} c-globalscheduler .calendarButton lightning-button-icon, c-global-scheduler .calendarButton lightning-button-icon {" + 
						"	width: 10px;" + 
						"	padding-left: 2px;" + 
						"} c-globalscheduler .searchPeople lightning-helptext, c-global-scheduler .searchPeople lightning-helptext {" + 
						"	display: none;" + 
						"} c-globalscheduler .addTeam button, c-global-scheduler .addTeam button {"+ 
						"	width: 97%;" + 
						"} c-globalscheduler .teamMember .slds-form-element__label, c-global-scheduler .teamMember .slds-form-element__label, " + 
						" c-globalscheduler .caseContact .slds-form-element__label, c-global-scheduler .caseContact .slds-form-element__label {" + 
						"	width: 100%;" + 
						"} c-globalscheduler .teamMember .slds-checkbox_on, c-globalscheduler .teamMember .slds-checkbox_off, c-global-scheduler " + 
						".teamMember .slds-checkbox_on, c-global-scheduler .teamMember .slds-checkbox_off, " + 
						" c-globalscheduler .caseContact .slds-checkbox_on, c-globalscheduler .caseContact .slds-checkbox_off, c-global-scheduler " + 
						".caseContact .slds-checkbox_on, c-global-scheduler .caseContact .slds-checkbox_off, " + 
						" c-globalscheduler .unavailableToggle .slds-checkbox_on, c-globalscheduler .unavailableToggle .slds-checkbox_off, c-global-scheduler " + 
						".unavailableToggle .slds-checkbox_on, c-global-scheduler .unavailableToggle .slds-checkbox_off, c-global-scheduler .shareAsPublic .slds-checkbox_on, " + 
						"c-global-scheduler .shareAsPublic .slds-checkbox_off {" + 
						"	display: none !important;" + 
						"} c-globalscheduler .quick-actions-panel, c-global-scheduler .quick-actions-panel {" + 
						"	overflow-y: auto;" + 
						"	flex: 1;" + 
						"} c-global-scheduler header {" + 
						"	padding-bottom: 10px;" + 
						"} .modal-container.slds-modal__container {" + 
						"	max-width: 1200px;" + 
						"} c-global-scheduler .unavailable button {" + 
						"	border-color: red;" + 
						"} </style>";
			});

			//Now we load the custom quick action styling.
			this.template.querySelectorAll('.customQuickActionCSS').forEach(objElement => {
				objElement.innerHTML = "<style> " + 
						".modal-container.slds-modal__container { " + 
						"	width: 100% !important; " + 
						"	max-width: inherit; " + 
						"} c-global-scheduler .slds-card__body {" + 
						"	margin: -15px;" + 
						"} </style>";
			});
			
			//Now we load the custom inline styling.
			this.template.querySelectorAll('.customInlineCSS').forEach(objElement => {
				objElement.innerHTML = "<style> " + 
						"c-global-scheduler .slds-card__body {" + 
						"	margin: -15px;" + 
						"} </style>";
			});
		}

		//We capture the record id.
        if(!this.boolRecordIdFound && objUtilities.isBlank(this.strRecordId)) {

			//If we are in a quick action.
			if(this.recordId) {
				this.strRecordId = this.recordId;
			} else if(window.location.href.includes("?id=")) {

				//We are in a community.
				var winLocation =  encodeURI(window.location.href.split("?")[1].replace("id=", ""));
				this.strRecordId =  decodeURI(winLocation);
			}

			//Now we check if this is a read only scenario.
			if(objUtilities.isNotBlank(this.strRecordId)) {
				this.boolRecordIdFound = true;
				this.isReadOnly();
			}
        }
    }

	/*
	 Method Name : isReadOnly
	 Description : This method determines if we should render the component as Read Only.
	 Parameters	 : None
	 Return Type : None
	 */
	isReadOnly() {
		let objParent = this;

		//Now we check if this is a read only scenario.
		getIsReadOnly({
			strRecordId: objParent.strRecordId
		}).then(boolIsReadOnly => {
			objParent.boolIsReadOnly = boolIsReadOnly;

			//Now we render the UI, depending on the scenario.
			if(boolIsReadOnly) {

				//We get the browser timezone.
				objParent.strSelectedTimeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;
				objParent.lstTimeZones.forEach(objRecord => {
					if(objRecord.value === objParent.strSelectedTimeZone) {
						objParent.strBrowserTimezoneLabel = objRecord.label;
					}
				});

				//We display the Case Contacts.
				objParent.boolDisplayContactsSection = true;
				
				//As this is a read-only scenario, we load the data of the Appointment request.
				getAppointmentRequestData({
					strRecordId: objParent.strRecordId,
					browserTimeZone : objParent.strSelectedTimeZone //As part of AR-2841 created parameter to handle locale time issue for plan record.
				}).then(objResponse => {
					objParent.boolHasAccess = objResponse.boolHasAccess;
					objParent.boolIsLinkExpired = objResponse.boolIsLinkExpired;
					objParent.boolEventAlreadyCreated = objResponse.boolEventAlreadyCreated;
					objParent.strErrorMessage = objResponse.strErrorMessage;

					//We check if we have error message.
					if(objUtilities.isBlank(objParent.strErrorMessage)) {
						objParent.boolHasErrorMessage = false;
					} else {
						objParent.boolHasErrorMessage = true;
					}

					//Now we set the data.
					if(!objParent.boolHasErrorMessage) { 

						//The link is still valid.
						objResponse.lstAttendees.forEach(objAttendee => {
							objParent.lstUsers.push({
								strName: objAttendee.User_Name__c,
								strId: objAttendee.User__r.Id
							});
						});
						objParent.objSlotsMap = {... objResponse.mapSlots};

						//Now we extract the duration from one of the slots.
						Object.entries(objParent.objSlotsMap).map(objDay => {
							if(objUtilities.isNotNull(objDay[1]) && objDay[1].length > 0) {
								objDay[1].forEach(objSlot => {
									if(objUtilities.isNotNull(objSlot.intDefaultDurationMinutes)) {
										objParent.intDefaultDurationMinutes = objSlot.intDefaultDurationMinutes;
									}
								});
							}
						});

						//We define the app.
						if(objResponse.strRecordType === "Case") {
							objParent.strSelectedTimeZone = TIME_ZONE;
							objParent.boolIsCaseContact = true;
							objParent.boolIsPlanContact = false;
						} else {
							objParent.boolIsCaseContact = false;
							objParent.boolIsPlanContact = true;
						}

						//Now we process the available slots.
						objParent.processAvailableSlots();

						//Now we extract the records.
						objResponse.lstRecordContacts.forEach(objContact => {
							if(objUtilities.isNotNull(objContact.Contact__r)) {
								objParent.lstRecordContacts.push({
									strName: objContact.Contact__r.Name,
									strId: objContact.Contact__r.Id,
									boolIsActive: false,
									boolIsSupportAccountContact: false
								});
							}
						});
						objResponse.lstSupportAccContacts.forEach(objContact => {
							if(objUtilities.isNotNull(objContact.ContactId)) {
								objParent.lstRecordContacts.push({
									strName: objContact.Contact.Name,
									strId: objContact.ContactId,
									boolIsActive: false,
									boolIsSupportAccountContact: true
								});
							}
						});
						if(objParent.lstRecordContacts.length > 0) {
							objParent.boolHasContacts = true;
						}
	
						//Now we set the date labels.
						objParent.strStart = new Intl.DateTimeFormat('en-US', {
							dateStyle: 'medium',
							timeZone: objParent.strSelectedTimeZone,
						}).format(new Date(objResponse.datTStart));
						objParent.strStop = new Intl.DateTimeFormat('en-US', {
							dateStyle: 'medium',
							timeZone: objParent.strSelectedTimeZone,
						}).format(new Date(objResponse.datTStop));
					}

					//Now we hide the spinner.
					objParent.boolDisplaySpinner = false;
				}).catch((objError) => {
					objUtilities.processException(objError, objParent);
				});
			} else {

				//As it is an internal user, we check if the record owner is a SFDC User and that user has meeting account setup completed.
				getRecordOwnerValidated({
					strRecordId: objParent.strRecordId
				}).then(boolIsValid => {

					//If the owner is valid, we proceed with the flow.
					if(boolIsValid) {

						//Now we load the users.
						objParent.loadUsers();
					} else {

						//The user is not valid, so we throw an error message.
						objUtilities.showToast("Error", objParent.label.Owner_Is_Not_User_Or_Account_Missing, "error", objParent);
						objParent[NavigationMixin.Navigate]({
							type:'standard__recordPage',
							attributes:{
								"recordId": objParent.strRecordId,
								"actionName": "view"
							}
						});
						objParent.dispatchEvent(new CustomEvent("schedulermessage", {
							detail:{
								strHTMLBody: ""
							},
							bubbles: true,
							composed: true
						}));
					}
				}).catch((objError) => {
					objUtilities.processException(objError, objParent);
				});				
			}
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		});
	}

	/*
	 Method Name : loadUsers
	 Description : This method fetches the available users, related to the given record.
	 Parameters	 : None
	 Return Type : None
	 */
	loadUsers() {
		let boolIsActive;
		let objParent = this;

		//Now we get the related users.
		getRelatedUsers({
			strRecordId: this.strRecordId
		}).then(objResult => {

			//First we extract the main user.
			objParent.lstUsers.push({
				strName: objResult.objUser.Name,
				strId: objResult.objUser.Id
			});

			//Now we extract the additional users.
			objResult.lstAdditionalUsers.forEach(objUser => {
				if(objUser.Id !== objResult.objUser.Id) {
					objParent.lstUsers.push({
						strName: objUser.Name,
						strId: objUser.Id
					});
				}
			});

			//Now we extract the Team Members.
			objResult.lstTeamMembers.forEach(objUser => {
				if(objParent.strCurrentUserId === objUser.Id) {
					boolIsActive = true;
				} else {
					boolIsActive = false;
				}
				objParent.lstTeamMembers.push({
					strName: objUser.Name,
					strId: objUser.Id,
					boolIsActive: boolIsActive
				});
			});
			if(objParent.lstTeamMembers.length > 0) {
				objParent.boolHasTeamMembers = true;
			}

			//Now we extract the Record Contacts.
			if(objResult.strRecordType === "Case") {
				objParent.boolShareAsPublic = false;
				objParent.boolIsCaseContact = true;
				objParent.boolIsPlanContact = false;
			} else {
				objParent.boolIsCaseContact = false;
				objParent.boolIsPlanContact = true;
			}
			objResult.lstRecordContacts.forEach(objContact => {
				if(objUtilities.isNotNull(objContact.Contact__r)) {
					let boolStatus = objParent.boolIsCreateInvite && objResult.strPrimaryContactId === objContact.Contact__r.Id ? true : false; // <T02>
					objParent.lstRecordContacts.push({
						strName: objContact.Contact__r.Name,
						strId: objContact.Contact__r.Id,
						boolIsActive: boolStatus, // <T02>
						boolIsSupportAccountContact: false,
						boolDisableRemove: boolStatus // <T02>
					});
				}
			});
			objResult.lstSupportAccContacts.forEach(objContact => {
				if(objUtilities.isNotNull(objContact.ContactId)) {
					objParent.lstRecordContacts.push({
						strName: objContact.Contact.Name,
						strId: objContact.ContactId,
						boolIsActive: false,
						boolIsSupportAccountContact: true
					});
				}
			});
			if(objParent.lstRecordContacts.length > 0) {
				objParent.boolHasContacts = true;
			}
				
			//Now we extract email only Case Contacts. <T01>
			if(objParent.boolShowEmailOnlyCaseContacts){
				objResult.lstEmailOnlyCaseContacts.forEach(objContact => {
					objParent.lstEmailOnlyCaseContacts.push({
						strName: objContact.Email__c,
						strId: objContact.Email__c,
						boolIsActive: false,
						isCaseContact: true
					});
				});
			}
			if(objParent.lstEmailOnlyCaseContacts.length > 0){
				objParent.boolHasEmailOnlyCaseContacts = true;
			}

			//Now we get the available slots.
			objParent.loadAvailableSlots();
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		});
	}

	/*
	 Method Name : loadAvailableSlots
	 Description : This method fetches the available slots from the backend.
	 Parameters	 : None
	 Return Type : None
	 */
	loadAvailableSlots() {
		let objParent = this;
		let objRequest;
		let lstUsers = new Array();

		//First we extract the Ids from the users' list.
		objParent.lstUsers.forEach(objUser => {
			lstUsers.push(objUser.strId);
		});
		
		//Now we prepare the request.
		objRequest = {
			objRequest: {
				lstUsers: lstUsers,
				datStart: objParent.getFormattedDate(objParent.datStart),
				datStop: objParent.getFormattedDate(objParent.datStop),
				strStartTime: "00:00:00",
				strStopTime: "23:59:59",
				strTargetTimezoneSidKey: objParent.strSelectedTimeZone,
				intDefaultDurationMinutes: objParent.intDefaultDurationMinutes,
				intDefaultGapMinutes: 15
			}
		};

		//Now we get the available slots.
		getAvailableSlots(objRequest).then((objSlotsMap) => {
			
			//First we save the data for later.
			objParent.objSlotsMap = {... objSlotsMap};

			//Now we prepare the data for the front-end.
			objParent.processAvailableSlots();
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		}).finally(() => {

			//Now we set the date labels.
			objParent.strStart = new Intl.DateTimeFormat('en-US', {
				dateStyle: 'medium',
				timeZone: objParent.strSelectedTimeZone,
			}).format(new Date(objParent.datStart));
			objParent.strStop = new Intl.DateTimeFormat('en-US', {
				dateStyle: 'medium',
				timeZone: objParent.strSelectedTimeZone,
			}).format(new Date(objParent.datStop));

			//Now we enable/disable the Remove buttons.
			if(objParent.lstUsers.length > 1) {
				objParent.boolDisableRemove = false;
			} else {
				objParent.boolDisableRemove = true;
			}

			//Now we hide the spinner.
			objParent.boolDisplaySpinner = false;
		});
	}

	/*
	 Method Name : processAvailableSlots
	 Description : This method processes the available slots for the front-end.
	 Parameters	 : None
	 Return Type : None
	 */
	processAvailableSlots() {
		let boolHasSlots;
		let intIndex = 0;
		let objParent = this;
		this.lstAvailableSlots = new Array();
		this.lstSelectedSlots = new Array();

		//Now we iterate over the slots.
		Object.entries(this.objSlotsMap).map(objDay => {

			//If we don't have slots, we send the boolean to the front end.
			boolHasSlots = false;
			if(typeof objDay[1] !== "undefined" && objDay[1] !== null && objDay[1].length > 0) {
				boolHasSlots = true;

				//Now we iterate over the slots to prepare the label.
				objDay[1].forEach(objSlot => {
					if(objParent.boolIsExternalSite && objParent.boolIsPlanContact) {
						objSlot.strSlotLabel = (new Intl.DateTimeFormat('en-US', {
							hour: '2-digit', 
							hourCycle: 'h12',
							minute: '2-digit',
							timeZone: objParent.strSelectedTimeZone
						}).format(new Date(objSlot.datTStart))).toLowerCase()+ " - " + (new Intl.DateTimeFormat('en-US', {
							hour: '2-digit', 
							hourCycle: 'h12',
							minute: '2-digit',
							timeZone: objParent.strSelectedTimeZone
						}).format(new Date(objSlot.datTStop))).toLowerCase();
					} else {
						objSlot.strSlotLabel = (new Intl.DateTimeFormat('en-US', {
							hour: '2-digit', 
							hourCycle: 'h12',
							minute: '2-digit'
						}).format(new Date(objSlot.datTStart.replace(".000Z", "")))).toLowerCase()+ " - " + (new Intl.DateTimeFormat('en-US', {
							hour: '2-digit', 
							hourCycle: 'h12',
							minute: '2-digit'
						}).format(new Date(objSlot.datTStop.replace(".000Z", "")))).toLowerCase();
					}
					objSlot.strId = "" + intIndex;
					objSlot.strState = "neutral";
					intIndex++;
				});
			}

			//Now we prepare the day.
			objParent.lstAvailableSlots.push({
				strHeader: objDay[0],
				lstSlots: objDay[1],
				boolHasSlots: boolHasSlots
			});
		});
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
		this.loadAvailableSlots();
	}

	/*
	 Method Name : getFormattedDate
	 Description : This method formats a Date value into string, using yyy-MM-dd format.
	 Parameters	 : Date, called from getFormattedDate, datDate Date value.
	 Return Type : String.
	 */
	getFormattedDate(datDate) {
		let objParent = this;
		return new Intl.DateTimeFormat('sv-SE', {
			day: '2-digit',
			month: '2-digit',
			year: 'numeric',
			timeZone: objParent.strSelectedTimeZone,
		}).format(datDate);
	}

	/*
	 Method Name : moveForward
	 Description : This method moves the calendar to the next 4 days.
	 Parameters	 : None
	 Return Type : None
	 */
	moveForward() {
		this.updateDates(4);
		this.boolDisplaySpinner = true;
		this.loadAvailableSlots();
	}

	/*
	 Method Name : moveBackwards
	 Description : This method moves the calendar to the previous 4 days.
	 Parameters	 : None
	 Return Type : None
	 */
	moveBackwards() {
		this.updateDates(-4);
		this.boolDisplaySpinner = true;
		this.loadAvailableSlots();
	}

	/*
	 Method Name : moveBackwards
	 Description : This method moves the calendar to the previous 4 days.
	 Parameters	 : None
	 Return Type : None
	 */
	updateDates(intDays) {
		let datTemporaryDate;
		let lstParts;
		if(typeof intDays === "string") {
			lstParts = intDays.split('-');
			this.datStart = new Date(lstParts[0], lstParts[1] - 1, lstParts[2]);
		} else if(typeof intDays === "undefined" || intDays === null || intDays === 0) {
			this.datStart = new Date();
		} else {
			datTemporaryDate = new Date(this.datStart);
			this.datStart = datTemporaryDate.setDate(datTemporaryDate.getDate() + intDays);
		}
		datTemporaryDate = new Date(this.datStart);
		this.datStop = datTemporaryDate.setDate(datTemporaryDate.getDate() + 3);
	}

	/*
	 Method Name : setToday
	 Description : This method moves the calendar to today.
	 Parameters	 : None
	 Return Type : None
	 */
	setToday() {
		this.updateDates();
		this.boolDisplaySpinner = true;
		this.loadAvailableSlots();
	}

	/*
	 Method Name : setSpecificDate
	 Description : This method moves the calendar to a specific date.
	 Parameters	 : Object, called from setSpecificDate, objEvent On change event.
	 Return Type : None
	 */
	setSpecificDate(objEvent) {
		this.updateDates(objEvent.target.value);
		this.boolDisplaySpinner = true;
		this.loadAvailableSlots();
	}

	/*
	 Method Name : addLookupUser
	 Description : This method adds a user from the Lookup field to the list of users.
	 Parameters	 : Object, called from addLookupUser, objEvent On change event.
	 Return Type : None
	 */
	addLookupUser(objEvent) {
		let boolAlreadyAdded = false;
		let strUserId = objEvent.target.value;

		//First we reset the 
		this.template.querySelectorAll('lightning-input-field').forEach(objField => {
			objField.reset();
		});

		//First, we confirm this user is not already on the list.
		if(typeof strUserId !== "undefined" && strUserId !== null && strUserId !== "") {
			this.lstUsers.forEach(objUser => {
				if(objUser.strId === strUserId) {
					boolAlreadyAdded = true;
				}
			});
	
			//If the user is new in the list, we get the name.
			if(!boolAlreadyAdded) {
				this.boolDisplaySpinner = true;
				getUserName({
					strRecordId: strUserId
				}).then(strName => {
		
					//Now we add the selected user.
					this.lstUsers.push({
						strName: strName,
						strId: strUserId
					});
		
					//Now we refetch the data.
					this.loadAvailableSlots();
				}).catch((objError) => {
					objUtilities.processException(objError, objParent);
				});
			}
		}
	}

	/*
	 Method Name : removeUser
	 Description : This method removes a user from the list of users.
	 Parameters	 : Object, called from removeUser, objEvent On change event.
	 Return Type : None
	 */
	removeUser(objEvent) {
		this.boolDisplaySpinner = true;

		//First, we remove the selected user.
		this.lstUsers.forEach(function(objUser, intIndex, lstArray) {
			if(objUser.strId === objEvent.currentTarget.dataset.id) {
				lstArray.splice(intIndex, 1);
			}
		});

		//If the user is a Team Member, we toggle the button.
		this.lstTeamMembers.forEach(objUser => {
			if(objUser.strId === objEvent.currentTarget.dataset.id) {
				objUser.boolIsActive = false;
			}
		});

		//Now we refresh the data.
		this.loadAvailableSlots();
	}

	/*
	 Method Name : toggleTeamMember
	 Description : This method adds/removes a team member from the list of users.
	 Parameters	 : Object, called from toggleTeamMember, objEvent On change event.
	 Return Type : None
	 */
	toggleTeamMember(objEvent) {
		let objNewEvent = {
			target: {
				value: objEvent.target.name
			},
			currentTarget: {
				dataset: {
					id: objEvent.target.name
				}
			}
		}

		//First, we check if the toggle is active or not.
		if(objEvent.target.checked) {

			//If active, we add the user to the list.
			this.addLookupUser(objNewEvent);

			//Finally, we update the list accordingly.
			this.updateTeamMemberList(objEvent.target.checked, objEvent.target.name);
		} else if(!this.boolDisableRemove) {

			//Otherwise, we remove the user from the list.
			this.removeUser(objNewEvent);

			//Finally, we update the list accordingly.
			this.updateTeamMemberList(objEvent.target.checked, objEvent.target.name);
		} else {

			//If there's only one Attendee left, we keep it.
			this.updateTeamMemberList(true, objEvent.target.name);
			this.template.querySelectorAll('.teamMember').forEach(objField => {
				if(objEvent.target.name === objField.name) {
					objField.checked = true;
				}
			});
		}
	}

	/*
	 Method Name : updateTeamMemberList
	 Description : This method updates the status of the Team Members list.
	 Parameters	 : Boolean, called from updateTeamMemberList, boolStatus Status.
	 			   String, called from updateTeamMemberList, strId Record Id.
	 Return Type : None
	 */
	updateTeamMemberList(boolStatus, strId) {
		this.lstTeamMembers.forEach(objUser => {
			if(objUser.strId === strId) {
				objUser.boolIsActive = boolStatus;
			}
		});
	}

	/*
	 Method Name : clickSlot
	 Description : This method updates the status of selected slot / button.
	 Parameters	 : Object, called from updateTeamMemberList, objEvent On click event.
	 Return Type : None
	 */
	clickSlot(objEvent) {
		let objParent = this;

		//First we check across available slots.
		this.lstAvailableSlots.forEach(objDay => {
			objDay.lstSlots.forEach(objSlot => {
				if(objEvent.currentTarget.dataset.id === objSlot.strId) {
					if(objSlot.strState === "brand") {
						objSlot.strState = "neutral";

						//Now we remove the record from the selected slots.
						objParent.lstSelectedSlots.forEach(function(objSlot, intIndex, lstArray) {
							if(objEvent.currentTarget.dataset.startTime === objSlot.Start_Time__c) {
								lstArray.splice(intIndex, 1);
							}
						});
					} else {
						objSlot.strState = "brand";

						//Now we add the record to the selected slots.
						if(objParent.boolIsReadOnly) {
							objParent.lstSelectedSlots = new Array();
							objParent.lstSelectedSlots.push({
								Start_Time__c: objEvent.currentTarget.dataset.startTime,
								Duration__c: objParent.intDefaultDurationMinutes,
								Originally_Available__c: objSlot.boolIsAvailable
							});
						} else {
							objParent.lstSelectedSlots.push({
								Start_Time__c: objEvent.currentTarget.dataset.startTime,
								Duration__c: objParent.intDefaultDurationMinutes,
								Originally_Available__c: objSlot.boolIsAvailable
							});
						}
					}
				} else if(objParent.boolIsReadOnly) {
					objSlot.strState = "neutral";
				}
			});
		});
	}

	/*
	 Method Name : sendSchedule
	 Description : This method creates the Appointment request.
	 Parameters	 : None
	 Return Type : None
	 */
	sendSchedule() {
		let objParent = this;
		let objAppointmentRequest = new Object();
		let lstAttendees = new Array();
		let lstContacts = new Array();
		this.boolDisplaySpinner = true;

		//First we prepare the list of Attendees.
		this.lstUsers.forEach(objUser => {
			lstAttendees.push({
				User__c: objUser.strId
			});
		});

		//Now we make sure the user has selected at least 1 slot.
		if(objParent.lstSelectedSlots.length > 0) {

			//Now we send the data to the backend, to prepare the Appointment Request.
			getAppointmentRequestCreated({
				objRequest: {
					boolSendBackResponse: objParent.boolSendBackResponse,
					boolShareAsPublic: objParent.boolShareAsPublic,
					strRecordId: objParent.strRecordId,
					strOriginalTimezoneSidKey: objParent.strSelectedTimeZone,
					objAppointmentRequest: objAppointmentRequest,
					lstAttendees: lstAttendees,
					lstSlots: objParent.lstSelectedSlots,
				}
			}).then((objCaseComment) => {

				//If we need to send the parent the response.
				if(objParent.boolSendBackResponse) {

					//Now we prepare the selected contacts.
					if(objUtilities.isNotNull(objParent.lstRecordContacts)) {
						objParent.lstRecordContacts.forEach(objContact => {
							if(objContact.boolIsActive) {
								lstContacts.push(objContact.strId);
							}
						});
					}

					//We get the template.
					getEmailTemplate({
						objRequest: {
							strSlotsURL: objCaseComment.Comment__c,
							strRelatedToId: objParent.strRecordId,
							lstContacts: lstContacts
						}
					}).then(strHTMLBody => {

						//We send the message to the parent.
						objParent.dispatchEvent(new CustomEvent("schedulermessage", {
							detail:{
								strHTMLBody: strHTMLBody
							},
							bubbles: true,
							composed: true
						}));
					}).catch((objError) => {
						objUtilities.processException(objError, objParent);
					}).finally(() => {

						//Now we close the quick action.
						objUtilities.showToast("Success", objParent.label.Schedule_Created, "success", objParent);
						objParent[NavigationMixin.Navigate]({
							type:'standard__recordPage',
							attributes:{
								"recordId": objParent.strRecordId,
								"actionName": "view"
							}
						});
					});
				} else {

					//As we don't have to send anything to the parent, we just display the link.
					objUtilities.showToast("Success", objParent.label.Schedule_Created, "success", objParent);
					objParent.boolDisplaySpinner = false;
					objParent.boolHasCommunityLink = true;
					objParent.strCommunityLink = objCaseComment.Comment__c;
				}
			}).catch((objError) => {
				objUtilities.processException(objError, objParent);
				objParent.boolDisplaySpinner = false;
			});
		} else {
			objParent.boolDisplaySpinner = false;
			objUtilities.showToast("Error", objParent.label.Select_One_Slot, "error", objParent);
		}
	}

	/*
	 Method Name : scheduleEvent
	 Description : This method creates the Appointment request.
	 Parameters	 : None
	 Return Type : None
	 */
	scheduleEvent() {
		let boolShouldContinue = true;
		let strFullName = "";
		let strFullEmail = "";
		let objParent = this;
		let lstAttendees = new Array();
		let lstContacts = new Array();
		let lstEmailOnlyContacts = new Array(); // <T01>
		this.boolDisplaySpinner = true;

		//Now we prepare the Record Contacts.
		this.lstRecordContacts.forEach(objContact => {
			if(objContact.boolIsActive) {
				lstContacts.push(objContact.strId);
			}
		});

		//If we are in a Read Only mode.
		if(objParent.boolIsReadOnly) {

			//Now we make sure the user has selected at least 1 slot.
			if(objParent.lstSelectedSlots.length > 0) {
				if(lstContacts.length > 0) {

						//If we are in a Force.com Site, we make sure the user provided its name.
						if(this.boolIsExternalSite) {
							strFullName = this.template.querySelector('.fullName').value;
							if(objUtilities.isBlank(strFullName)) {
								boolShouldContinue = false;
								objParent.boolDisplaySpinner = false;
								alert(objParent.label.Force_com_User_Name_Missing);
							} else {
								strFullEmail = this.template.querySelector('.fullEmail').value;
								if(objUtilities.isBlank(strFullEmail) || !strFullEmail.match(
										/^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/)) {
									boolShouldContinue = false;
									objParent.boolDisplaySpinner = false;
									alert(objParent.label.Force_com_User_Email_Missing);
								}
							}
						}

						//If we are ready to create the event.
						console.log('timezone>>>>>'+objParent.strSelectedTimeZone);
						if(boolShouldContinue) {
							getEventScheduled({
								objRequest: {
									boolIsReadOnly: true,
									strRecordId: objParent.strRecordId,
									strOriginalTimezoneSidKey: objParent.strSelectedTimeZone,
									strFullName: strFullName,
									strUserEmail: strFullEmail,
									objSlot: objParent.lstSelectedSlots[0],
									lstContacts: lstContacts
								}
							}).then(() => {
								objParent.boolMeetingScheduled = true;
								if(this.boolIsExternalSite) {
									alert(objParent.label.Meeting_Scheduled);
									this.isReadOnly();
								} else {
									objUtilities.showToast("Success", objParent.label.Meeting_Scheduled, "success", objParent);
								}
	
								//I2RT-4565
								//Now we navigate to dashboard
								objParent[NavigationMixin.Navigate]({
									type: 'comm__namedPage',
									attributes: {
										name: 'Home'
									}
								});
							}).catch((objError) => {
								objUtilities.processException(objError, objParent);
							}).finally(() => {
								objParent.boolDisplaySpinner = false;
							});
						}
				} else {
					objParent.boolDisplaySpinner = false;
					if(this.boolIsExternalSite) {
						alert(objParent.label.Select_A_Contact);
					} else {
						objUtilities.showToast("Error", objParent.label.Select_A_Contact, "error", objParent);
					}
				}
			} else {
				objParent.boolDisplaySpinner = false;
				if(this.boolIsExternalSite) {
					alert(objParent.label.Select_A_Slot);
				} else {
					objUtilities.showToast("Error", objParent.label.Select_A_Slot, "error", objParent);
				}
			}
		} else {

			//First we prepare the list of Attendees.
			this.lstUsers.forEach(objUser => {
				lstAttendees.push({
					User__c: objUser.strId
				});
			});

			//Now we prepare Email only Case Contacts. <T01>
			this.lstEmailOnlyCaseContacts.forEach(objContact => {
				if(objContact.boolIsActive) {
					lstEmailOnlyContacts.push(objContact.strId);
				}
			});

			//Now we make sure the user has selected at least 1 slot.
			if(objParent.lstSelectedSlots.length === 1) {
				if(lstContacts.length > 0 || lstEmailOnlyContacts.length > 0){ // <T01>

						//Now we send the data to the backend, to prepare the Appointment Request.
						getEventScheduled({
							objRequest: {
								boolSendBackResponse: objParent.boolSendBackResponse,
								strRecordId: objParent.strRecordId,
								strOriginalTimezoneSidKey: objParent.strSelectedTimeZone,
								lstAttendees: lstAttendees,
								objSlot: objParent.lstSelectedSlots[0],
								lstContacts: lstContacts,
								lstEmailOnlyContacts: lstEmailOnlyContacts // <T01>
							}
						}).then((strEventId) => {

							//If we need to send the parent the response.
							if(objParent.boolSendBackResponse) {

								//First we get the Zoom details.
								objParent.reviewEventDetails(strEventId);
							} else {

								//Now we close the quick action.
								objParent[NavigationMixin.Navigate]({
									type:'standard__recordPage',
									attributes:{
										"recordId": objParent.strRecordId,
										"actionName": "view"
									}
								});
								objUtilities.showToast("Success", objParent.label.Meeting_Scheduled, "success", objParent);
							}
						}).catch((objError) => {
							objUtilities.processException(objError, objParent);
							objParent.boolDisplaySpinner = false;
						});
					}else {
						objParent.boolDisplaySpinner = false;
						objUtilities.showToast("Error", objParent.label.Select_A_Contact, "error", objParent);
					}
			} else {
				objParent.boolDisplaySpinner = false;
				objUtilities.showToast("Error", objParent.label.Select_Only_One_Slot, "error", objParent);
			}
		}
	}

	/*
	 Method Name : reviewEventDetails
	 Description : This method checks an Event record, in a recursive way, so it extracts the Zoom details.
	 Parameters	 : String, called from updateTeamMemberList, strEventId Event Id.
	 Return Type : None
	 */
	reviewEventDetails(strEventId) {
		let objParent = this;
		objParent.objLooper = setTimeout(function() {
			getEventDetails({
				strRecordId: strEventId
			}).then((objEvent) => {

				//If we have Zoom Details.
				if(objUtilities.isNotNull(objEvent) && objUtilities.isNotBlank(objEvent.Location)) {

					//We get the template.
					getEmailTemplate({
						objRequest: {
							strRecordId: strEventId
						}
					}).then(strHTMLBody => {

						//We send the message to the parent.
						objParent.dispatchEvent(new CustomEvent("schedulermessage", {
							detail:{
								strHTMLBody: strHTMLBody
							},
							bubbles: true,
							composed: true
						}));
					}).catch((objError) => {
						objUtilities.processException(objError, objParent);
					}).finally(() => {

						//Now we close the quick action.
						objParent[NavigationMixin.Navigate]({
							type:'standard__recordPage',
							attributes:{
								"recordId": objParent.strRecordId,
								"actionName": "view"
							}
						});
						objUtilities.showToast("Success", objParent.label.Meeting_Scheduled, "success", objParent);
					});
				} else if(objUtilities.isNotNull(objEvent) && objUtilities.isNotBlank(objEvent.Zoom_Error_Status_Code__c)){ // <T03>

					//We check if the zoom token has expired.
					if(objEvent.Zoom_Error_Status_Code__c == '401'){
						objParent.getMeetingAccountDetails();
						objParent.strEventId = strEventId;
						objParent.boolDisplayReauthentication = true;
						objParent.boolDisplaySpinner = false;
					}
					else{
						objParent.deleteEventDetails(strEventId);
						objParent.boolDisplaySpinner = false;
						objUtilities.showToast("Error", objParent.label.Scheduler_Unexpected_Error_Message, "error", objParent);
					}

				} else {
					
					//We check again in 1 second.
					objParent.reviewEventDetails(strEventId);
				}
			}).catch((objError) => {
				objUtilities.processException(objError, objParent);
				objParent[NavigationMixin.Navigate]({
					type:'standard__recordPage',
					attributes:{
						"recordId": objParent.strRecordId,
						"actionName": "view"
					}
				});
				objUtilities.showToast("Success", objParent.label.Meeting_Scheduled, "success", objParent);
			});
		}, 1000);
	}

	/*
	 Method Name : popOut
	 Description : This method gets executed when the user tries to pop out or pop in the component.
	 Parameters	 : Event, called from popOut, objEvent click event.
	 Return Type : None
	 */
	popOut(objEvent) {
		let boolIsPopingOut;

        //First we define the operation.
        switch (objEvent.target.dataset.name) {
            case 'popOut':
                boolIsPopingOut = true;
            break;
            case 'popIn':
                boolIsPopingOut = false;
            break;
        }

		//Now we send the event.
        this.dispatchEvent(new CustomEvent('popout', {
			detail: {
				boolIsPopingOut: boolIsPopingOut
			}
		}));
    }

	/*
	 Method Name : toggleCaseContact
	 Description : This method adds/removes a Case Contact from the list.
	 Parameters	 : Object, called from toggleTeamMember, objEvent On change event.
	 Return Type : None
	 */
	toggleCaseContact(objEvent) {

		//We iterate over the record to set the new value.
		this.lstRecordContacts.forEach(objContact => {
			if(objContact.strId === objEvent.target.name) {
				objContact.boolIsActive = objEvent.target.checked;
			}
		});
	}

	/*
	 Method Name : toggleShareAsPublic
	 Description : This method indicates if the Share Availability links should be a Force.com Site or Community.
	 Parameters	 : Object, called from toggleShareAsPublic, objEvent On change event.
	 Return Type : None
	 */
	toggleShareAsPublic(objEvent) {
		this.boolShareAsPublic = objEvent.target.checked;
	}
  
  /*
	 Method Name : toggleEmailOnlyCaseContact
	 Description : This method adds/removes a email only Case Contact from the list.
	 Parameters	 : Object, called from toggleTeamMember, objEvent On change event.
	 Return Type : None
	 */
	 toggleEmailOnlyCaseContact(objEvent) { // <T01>

		//We iterate over the record to set the new value.
		this.lstEmailOnlyCaseContacts.forEach(objContact => {
			if(objContact.strId === objEvent.target.name) {
				objContact.boolIsActive = objEvent.target.checked;
			}
		});
	}

	/*
	 Method Name : updateDuration
	 Description : This method updates the duration of the meeting.
	 Parameters	 : Object, called from toggleTeamMember, objEvent On change event.
	 Return Type : None
	 */
	updateDuration(objEvent) {
		this.boolDisplaySpinner = true;
		this.intDefaultDurationMinutes = parseInt(objEvent.detail.value);
		this.loadAvailableSlots();
	}

	/*
	 Method Name : toggleUnavailable
	 Description : This method shows/hides unavailable slots.
	 Parameters	 : Object, called from toggleUnavailable, objEvent On change event.
	 Return Type : None
	 */
	toggleUnavailable(objEvent) {
		this.processAvailableSlots();
		if(objEvent.target.checked) {
			this.template.querySelectorAll('.unavailable').forEach(objSlot => {
				objSlot.classList.remove("slds-hide");
			});
		} else {
			this.template.querySelectorAll('.unavailable').forEach(objSlot => {
				objSlot.classList.add("slds-hide");

			});
		}
	}

	/*
	 Method Name : copyToClipboard
	 Description : This method copies the community link to the clipboard.
	 Parameters	 : None
	 Return Type : None
	 */
	copyToClipboard() {
		let objParent = this;
		let objInputField = this.template.querySelector('.clipboard');
		objInputField.value = objParent.strCommunityLink;
		objInputField.select();
		document.execCommand('copy');
		objUtilities.showToast("Success", objParent.label.URL_Copied_To_Clipboard, "success", objParent);
	}

	/*
	 Method Name : getMeetingAccountDetails
	 Description : This method fetches meeting account recordid.
	 Parameters	 : None
	 Return Type : None
	 */
	getMeetingAccountDetails(){ // <T03>
		let objParent = this;
		getMeetingAccountDetails({
			strRecordId: objParent.strRecordId
		}).then((strMeetingAccountId) => {
			if(objUtilities.isNotBlank(strMeetingAccountId)){
				objParent.strMeetingAccountRecordId = strMeetingAccountId;
			}
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		});
	}

	/*
	 Method Name : redirectToMeetingAccount
	 Description : This method navigates user to the meeting account.
	 Parameters	 : None
	 Return Type : None
	 */
	redirectToMeetingAccount(){ // <T03>
		let objParent = this;
		objParent.closeReauthenticationModal();
		objParent[NavigationMixin.Navigate]({
			type:'standard__recordPage',
			attributes:{
				"recordId": objParent.strMeetingAccountRecordId,
				"actionName": "view"
			}
		});
	}

	/*
	 Method Name : closeReauthenticationModal
	 Description : This method closes the Reauthentication modal.
	 Parameters	 : None
	 Return Type : None
	 */
	closeReauthenticationModal(){ // <T03>
		let objParent = this;
		objParent.deleteEventDetails(objParent.strEventId);
		objParent.boolDisplayReauthentication = false;
	}

	/*
	 Method Name : deleteEventDetails
	 Description : This method deletes the Event record.
	 Parameters	 : String, called from reviewEventDetails, closeReauthenticationModal, strEventId Event Id.
	 Return Type : None
	 */
	deleteEventDetails(strEventId){ // <T03>
		let objParent = this;
		if(objUtilities.isNotBlank(strEventId)){
			deleteEvent({
				strRecordId: strEventId
			}).then((boolResult) => {
				if(boolResult){
					objParent.strEventId = '';
				}
			}).catch((objError) => {
				objUtilities.processException(objError, objParent);
			});
		}
	}
}