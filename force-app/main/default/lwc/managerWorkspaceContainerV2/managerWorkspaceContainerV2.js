/*

 Change History
 **********************************************************************************************************
 Modified By		Date		Jira No.	Description													Tag
 **********************************************************************************************************
 NA					NA			N/A			Initial version.											N/A
 Vignesh D			03/28/2023	I2RT-7838	Added CSS to display FTO icon in the background				T01
 Isha Bansal		03/27/2023		I2RT-6727		Added user FTO details for ownership change scenario    T02
  Isha Bansal		04/13/2023		I2RT-6727		Ownership lookup changed to custom lookup    T03
 */

 import { LightningElement, track, wire } from 'lwc';
 import getURLFromMetadata from '@salesforce/apex/CaseController.getTableauDashboardLinks';
 import global_styles from '@salesforce/resourceUrl/gcsSrc';
 import { loadStyle } from 'lightning/platformResourceLoader';
 import FTO_ICON from '@salesforce/resourceUrl/ftoIcon'; //<T01>
 
 //Utilities.
 import { objUtilities } from 'c/globalUtilities';
 
 //Imports.
 import getCount from '@salesforce/apex/GCS_ManagerWorkspaceControllerV2.getCount';
 import getRecordAssigned from '@salesforce/apex/GCS_ManagerWorkspaceControllerV2.getRecordAssigned';
 import getUserPreferences from '@salesforce/apex/GlobalUserPreferencesClass.getUserPreferences';
 import setUserPreferences from '@salesforce/apex/GlobalUserPreferencesClass.setUserPreferences';
 import lookupCombinedSearch from '@salesforce/apex/RaiseHandController.lookupCombinedSearch'; //T03
 
 //Class body.
 export default class ManagerWorkspaceContainerV2 extends LightningElement {
 
	 //User preferences variable.
	 objUserPreferences = new Object();
 
	 @track metadataRecordURL = '';
	 @track
	 stateVariant = {
		 queueVariant: '',
		 allVariant: 'brand',
		 teamsVariant: '',
		 dashboardVariant: ''
	 }
	 channelName = '/data/CaseChangeEvent';
	 raiseHandChannelName = '/data/Raise_Hand__ChangeEvent';
	 urgentRequestChannelName = '/data/Case_Comment__ChangeEvent';
	 subscription = {};
	 raiseHandSubscription = {};
	 urgentRequestSubscription ={};
	 isCaseView = true;
 
	 //Private variables.
	 boolDisplayChangeOwnerLookupField;
	 boolDisplayModalSpinner;
	 boolIsModalOpen = false;
	 boolCustomCSSLoaded;
	 boolIsAutorefreshActive = false;
	 boolWasAutorefreshActive = false;
	 idNewOwner;
	 intAutorefreshCounter = 30;
	 strSelectedTimeframe = "30";
	 strAutorefreshCounterLabel;
	 objInfiniteLoop;
	 lstCustomCSS = new Array();
	 lstSelectedRecords;
	 lstTimeframeOptions;
	// displayftotable=false; // T02 
 
	 //Modal properties.
	 boolIsCustomCellModalPoppedOut = false;
	 boolIsCaseTeamsPoppedOut = false;
	 boolIsCaseQueuesPoppedOut = false;
	 boolIsCollaboratePoppedOut = false;
	 boolIsAttentionRequestPoppedOut = false;
	 boolIsEscalationsPoppedOut = false;
	 get objCustomCellModalProperties() {
		 if(this.boolIsCustomCellModalPoppedOut) {
			 return objUtilities.getPopOutCSSOpen();
		 } else {
			 return objUtilities.getPopOutCSSClosed();
		 }
	 }
	 get objCaseTeamsModalProperties() {
		 if(this.boolIsCaseTeamsPoppedOut) {
			 return objUtilities.getPopOutCSSOpen();
		 } else {
			 return objUtilities.getPopOutCSSClosed();
		 }
	 }
	 get objCaseQueuesModalProperties() {
		 if(this.boolIsCaseQueuesPoppedOut) {
			 return objUtilities.getPopOutCSSOpen();
		 } else {
			 return objUtilities.getPopOutCSSClosed();
		 }
	 }
	 get objCollaborateModalProperties() {
		 if(this.boolIsCollaboratePoppedOut) {
			 return objUtilities.getPopOutCSSOpen();
		 } else {
			 return objUtilities.getPopOutCSSClosed();
		 }
	 }
	 get objAttentionModalProperties() {
		 if(this.boolIsAttentionRequestPoppedOut) {
			 return objUtilities.getPopOutCSSOpen();
		 } else {
			 return objUtilities.getPopOutCSSClosed();
		 }
	 }
	 get objEscalationsModalProperties() {
		 if(this.boolIsEscalationsPoppedOut) {
			 return objUtilities.getPopOutCSSOpen();
		 } else {
			 return objUtilities.getPopOutCSSClosed();
		 }
	 }
 
	 renderedCallback() {
		 let strFullCustomCSS = "";
		 let objParent = this;
		 Promise.all([
		 loadStyle(this, global_styles + '/global.css'),
		 ])
		 .then(() => {
		 console.log("All scripts and CSS are loaded.")
		 })
		 .catch(error => {
		 console.log('Script and CSS not loaded');
		 });
 
		 //Now we render custom CSS to force all the tables to display max 10 rows, and always show scrollbars.
		 if(!this.boolCustomCSSLoaded) {
 
			 //We set the custom CSS.
			 this.lstCustomCSS.push(".autorefreshToggle .slds-checkbox_on, .autorefreshToggle .slds-checkbox_off { display: none !important; }");
			 this.lstCustomCSS.push("lightning-input-field label { display: none !important; }");
			 this.lstCustomCSS.push("lightning-input-field .slds-form-element__control { padding-left: 30%; padding-right: 30%; }");
			 this.lstCustomCSS.push(".timeframePicklist label { display: none; }");
			 this.lstCustomCSS.push(".timeframePicklist .slds-listbox { z-index: 9999999999999; }");
			 this.template.querySelectorAll('.customGeneralCSS').forEach(objElement => {
				 objParent.lstCustomCSS.forEach(strCustomCSS => {
					 strFullCustomCSS += " c-manager-workspace-container-v2 " + strCustomCSS + " ";
				 });
				 objElement.innerHTML = "<style> " + strFullCustomCSS + " </style>";
			 });
			 this.boolCustomCSSLoaded = true;
		 }
	 }
	 
	 /*
	  Method Name : refreshTables
	  Description : This method refreshes all the tables.
	  Parameters	 : None
	  Return Type : None
	  */
	 refreshTables() {
		 this.template.querySelectorAll(".targetTable").forEach(objTable => {
			 objTable.refreshData();
		 });
	 }
	 
	 /*
	  Method Name : activateDeactivateAutorefresh
	  Description : This method activates / deactivates the autorefresh.
	  Parameters	 : None
	  Return Type : None
	  */
	 activateDeactivateAutorefresh() {
		 let objParent = this;
 
		 //Now we get the toggle value.
		 objParent.boolIsAutorefreshActive = !objParent.boolIsAutorefreshActive;
 
		 //Now we save the user selection, fetching first the current data.
		 getUserPreferences().then(objResult => {
			 objResult.objManagerWorkspace.boolAutorefreshActive = objParent.boolIsAutorefreshActive;
 
			 //Now we save the new changes.
			 objParent.objUserPreferences = objResult;
			 setUserPreferences({
				 objRecord: objParent.objUserPreferences
			 });
		 });
	 }
	 
	 get isShowQueue() {
		 return this.stateVariant.queueVariant || this.stateVariant.allVariant;
	 }
 
	 get isShowAll() {
		 return this.stateVariant.allVariant;
	 }
 
	 get isShowTeams() {
		 return this.stateVariant.teamsVariant || this.stateVariant.allVariant;
	 }
 
	 get isShowGEMS() {
		 return this.stateVariant.queueVariant || this.stateVariant.allVariant;
	 }
	 get isShowDashboard() {
		 return this.stateVariant.dashboardVariant;
	 }
	 get isShowCases() {
		 return this.stateVariant.dashboardVariant ? false : true;
	 }
	 get columnSize() {
		 return this.stateVariant.allVariant ? '6' : '12';
	 }
 
	 get header() {
		 return 'Manager Workspace';
	 }
 
	 activeSections = ['Case', 'RaiseHand'];
	 @wire(getURLFromMetadata, { strFilter: "Manager" })
	 metadataRecord({ error, data }) {
		 if (data) {
			 console.log("Watch: metadataRecord data -> " + JSON.stringify(data));
			 this.metadataRecordURL = data;
			 //metadataRecordURL
		 } else if (error) {
			 console.log("Watch: metadataRecord error -> " + JSON.stringify(error));
		 }
	 }
	 // Initializes the component
	 connectedCallback() {
		 let objParent = this;
		 
		 let globalStyle = document.createElement('style');
		 globalStyle.innerHTML = `
		 .slds-icon-action-question-post-action .slds-icon {
			 display: none !important;
		   }
 
		   .slds-icon-action-close .slds-icon {
			 display: none !important;
		   }
 
		   .fillRed svg {
			   fill: #63B8FF	;
		   }
 
		  .login-status.slds-icon_container_circle {
			 width: 10px !important;
			 height: 10px !important;
			 padding: 0;
		   }
 
		   .login-status .slds-icon_container_circle {
			 width: 10px !important;
			 height: 10px !important;
			 padding: 0;
		   }
 
		   .out-of-office{
			 background-image: url("${FTO_ICON}");
			 background-repeat: no-repeat;
			 background-position: center;
		   }
										 `;
		 document.head.appendChild(globalStyle);
 
		 //First we get the subscription record.
		 getUserPreferences().then(objResult => {
 
			 //We store the user preferences.
			 objParent.objUserPreferences = objResult;
 
			 //First we get the picklist values.
			 objParent.lstTimeframeOptions = objResult.lstTimeframes;
 
			 //Now we set the selections.
			 objParent.boolIsAutorefreshActive = objResult.objManagerWorkspace.boolAutorefreshActive;
			 objParent.intAutorefreshCounter = objResult.objManagerWorkspace.intAutorefreshSeconds;
			 objParent.strSelectedTimeframe = "" + objParent.intAutorefreshCounter;
 
			 //Now we set a loop that will refresh everything every 30 seconds.
			 objParent.objInfiniteLoop = setInterval(function() {
				 if(objParent.boolIsAutorefreshActive) {
					 if(objParent.intAutorefreshCounter === 1) {
						 objParent.refreshTables();
						 objParent.intAutorefreshCounter = objParent.objUserPreferences.objManagerWorkspace.intAutorefreshSeconds;
					 } else {
						 objParent.intAutorefreshCounter--;
					 }
					 objParent.strAutorefreshCounterLabel = "Autorefresh in " + objParent.intAutorefreshCounter + " second(s)";
				 } else {
					 objParent.intAutorefreshCounter = objParent.objUserPreferences.objManagerWorkspace.intAutorefreshSeconds;
					 objParent.strAutorefreshCounterLabel = "No autorefresh";
				 }
			 }, 1000);
		 });
	 }
 
	 /*
	  Method Name : changeTimeframe
	  Description : This method updates the selected timeframe.
	  Parameters	 : Object, called from changeTimeframe, objEvent Change event.
	  Return Type : None
	  */
	 changeTimeframe(objEvent) {
		 let intSelection = parseInt(objEvent.currentTarget.value);
		 let objParent = this;
 
		 //We get the user selection.
		 objParent.intAutorefreshCounter = intSelection;
 
		 //Now we save the user selection, fetching first the current data.
		 getUserPreferences().then(objResult => {
			 objResult.objManagerWorkspace.intAutorefreshSeconds = intSelection;
 
			 //Now we save the new changes.
			 objParent.objUserPreferences = objResult;
			 setUserPreferences({
				 objRecord: objParent.objUserPreferences
			 });
		 });
	 }
 
	 disconnectedCallback() {
 
		 //We remove the infinite loop that refreshes the tables.
		 clearInterval(this.objInfiniteLoop);
	 }
 
	 handleClick(event) {
		 switch (event.currentTarget.name) {
			 case "queues":
				 this.stateVariant.queueVariant = "brand";
				 this.stateVariant.allVariant = "";
				 this.stateVariant.teamsVariant = "";
				 this.stateVariant.dashboardVariant = "";
				 break;
			 case "all":
				 this.stateVariant.queueVariant = "";
				 this.stateVariant.allVariant = "brand";
				 this.stateVariant.teamsVariant = "";
				 this.stateVariant.dashboardVariant = "";
				 break;
			 case "teams":
				 this.stateVariant.queueVariant = "";
				 this.stateVariant.allVariant = "";
				 this.stateVariant.teamsVariant = "brand";
				 this.stateVariant.dashboardVariant = "";
				 break;
			 case "dashboard":
				 this.stateVariant.queueVariant = "";
				 this.stateVariant.allVariant = "";
				 this.stateVariant.teamsVariant = "";
				 this.stateVariant.dashboardVariant = "brand";
				 break;
			 default:
				 break;
		 }
	 }
 
	 /*
	  Method Name : childConfiguration
	  Description : This method starts / stops the autorefresh, depending on child instructions.
	  Parameters	 : Object, called from childConfiguration, objEvent Select event.
	  Return Type : None
	  */
	 childConfiguration(objEvent) {
		 switch(objEvent.detail) {
			 case 1:
				 
				 //The user wants to configure a card.
				 this.activeInactiveAutorefresh(false);
			 break;
			 case 2:
				 
				 //The user has finished configuring a card.
				 this.activeInactiveAutorefresh(true);
			 break;
		 }
	 }
 
	 /*
	  Method Name : openModal
	  Description : This method opens the modal.
	  Parameters	 : Object, called from openModal, objEvent Event coming from the child components..
	  Return Type : None
	  */
	 openModal(objEvent) {
		 let objParent = this;
 
		 //Now we set the default values.
		 objParent.boolDisplayModalSpinner = true;
		 objParent.boolIsModalOpen = true;
		 objParent.objModalTable = new Object();
		 objParent.objModalTable.boolEnablePopOver = false;
		 objParent.objModalTable.boolDisplayActions = false;
 
		 //We close all the possible opened modals.
		 objParent.boolIsCaseTeamsPoppedOut = false;
		 objParent.boolIsCaseQueuesPoppedOut = false;
		 objParent.boolIsCollaboratePoppedOut = false;
		 objParent.boolIsAttentionRequestPoppedOut = false;
		 objParent.boolIsEscalationsPoppedOut = false;
		 objParent.template.querySelectorAll(".targetTable").forEach(objComponent => {
			 objComponent.closeModal();
		 });
		 
		 //Now we check if we need to deactivate the autorefresh or not.
		 objParent.activeInactiveAutorefresh(false);
 
		 //Now we load the table.
		 getCount({
			 intQuery: objEvent.detail.intQuery, 
			 strFieldSetName: objEvent.detail.strFieldSetName,
			 strFilterValue: objEvent.detail.strColumn,
			 lstIds: [
				 objEvent.detail.strRow
			 ]
		 }).then((objResult) => {
 
			 //We build the Plan table.
			 objParent.objModalTable.lstRecords = objResult.lstRecords;
			 objParent.objModalTable.lstColumns = objResult.lstColumns;
			 console.log('@@@-----objResult.lstColumns----->>>',objParent.objModalTable);
			 //console.log('@@@-----objResult.lstRecords----->>>', objResult.lstRecords);
		 }).catch((objError) => {
			 objUtilities.processException(objError, objParent);
		 }).finally(() => {
			 objParent.boolDisplayModalSpinner = false;
		 });
	 }
 
	 /*
	  Method Name : closeModal
	  Description : This method closes the modal.
	  Parameters	 : None
	  Return Type : None
	  */
	 cancelOperation() {
		 this.lstSelectedRecords = new Array();
		 if(this.boolDisplayChangeOwnerLookupField) {
			 this.boolDisplayChangeOwnerLookupField = false;
		 } else {
			 this.boolIsModalOpen = false;
		 }
 
		 //Now we reactivate the autorefresh, if needed.
		 this.activeInactiveAutorefresh(true);
	 }
 
	 /*
	  Method Name : executeAction
	  Description : This method executes the corresponding action requested by the Data Tables component.
	  Parameters	 : Object, called from executeAction, objEvent Select event.
	  Return Type : None
	  */
	 executeAction(objEvent) {
		 const { intAction, objPayload } = objEvent.detail;
 
		 //First, we check which event we need to execute.
		 switch(intAction) {
			 case 1:
				 
				 //The user has selected records.
				 this.lstSelectedRecords = objPayload.detail.selectedRows;
			 break;
		 }
	 }
 
	 /*
	  Method Name : autoAssign
	  Description : This method auto assignes the selected records.
	  Parameters	 : None
	  Return Type : None
	  */
	 autoAssign() {
		 let objParent = this;
		 let lstIds = new Array();
		 
		 //First we make sure we have records selected.
		 if(objUtilities.isNotNull(objParent.lstSelectedRecords) && objParent.lstSelectedRecords.length > 0) {
			 objParent.boolDisplayModalSpinner = true;
 
			 //Now we extract the record Ids.
			 objParent.lstSelectedRecords.forEach(objRecord => {
				 lstIds.push(objRecord.Id);
			 });
 
			 //Now we auto assign the record.
			 getRecordAssigned({
				 lstRecordIds: lstIds
			 }).then(() => {
				 objUtilities.showToast("Success", "Records have been auto assigned.", "success", objParent);
				 objParent.cancelOperation();
			 }).catch((objError) => {
				 objUtilities.processException(objError, objParent);
			 }).finally(() => {
				 objParent.boolDisplayModalSpinner = false;
			 });
		 } else {
			 objUtilities.showToast("Warning", "Please select at least one record.", "warning", objParent);
		 }
	 }
 
	 /*
	  Method Name : changeOwner
	  Description : This method starts the "Change Owner" process.
	  Parameters	 : None
	  Return Type : None
	  */
	 changeOwner() {
		 let objParent = this;
		 this.idNewOwner=null; //reset the idnewowner on change owner button click . //T03
		 //First we make sure we have records selected.
		 if(objUtilities.isNotNull(objParent.lstSelectedRecords) && objParent.lstSelectedRecords.length > 0) {
			 objParent.boolDisplayChangeOwnerLookupField = true;
		 } else {
			 objUtilities.showToast("Warning", "Please select at least one record.", "warning", objParent);
		 }
	 }
 
	 /*
	  Method Name : selectNewOwner
	  Description : This method saves the selection of the new owner.
	  Parameters	 : Object, called from selectNewOwner, objEvent Select event.
	  Return Type : None
	  */
	 selectNewOwner(objEvent) {
		 this.idNewOwner = objEvent.target.value;		 
	 }
 
	 /*
	  Method Name : executeOwnerChange
	  Description : This method assignes the selected records to the provided new owner.
	  Parameters	 : None
	  Return Type : None
	  */
	 executeOwnerChange() {
		 let objParent = this;
		 let lstIds = new Array();
		 
		 //First we make sure we have records selected.
		 if(objUtilities.isNotBlank(objParent.idNewOwner)) {
			 objParent.boolDisplayModalSpinner = true;
 
			 //Now we extract the record Ids.
			 objParent.lstSelectedRecords.forEach(objRecord => {
				 lstIds.push(objRecord.Id);
			 });
 
			 //Now we auto assign the record.
			 getRecordAssigned({
				 idNewOwner: objParent.idNewOwner,
				 lstRecordIds: lstIds
			 }).then(() => {
				 objParent.boolDisplayChangeOwnerLookupField = false;
				 objUtilities.showToast("Success", "Records have been assigned.", "success", objParent);
				 objParent.cancelOperation();
			 }).catch((objError) => {
				 objUtilities.processException(objError, objParent);
			 }).finally(() => {
				 objParent.boolDisplayModalSpinner = false;
			 });
		 } else {
			 objUtilities.showToast("Warning", "Please select a new owner.", "warning", objParent);
		 }
	 }
 
	 /*
	  Method Name : activeInactiveAutorefresh
	  Description : This method activates or deactivates the autorefresh, if the user will run specific actions over the cards.
	  Parameters	 : Boolean, called from activeInactiveAutorefresh, boolActivate TRUE if we are allowing the autorefresh.
	  Return Type : None
	  */
	 activeInactiveAutorefresh(boolActivate) {
		 if(boolActivate) {
			 if(this.boolWasAutorefreshActive) {
				 this.boolWasAutorefreshActive = false;
				 this.boolIsAutorefreshActive = true;
			 }
		 } else {
			 if(this.boolIsAutorefreshActive) {
				 this.boolWasAutorefreshActive = true;
				 this.boolIsAutorefreshActive = false;
			 }
		 }
	 }
 
	 /*
	  Method Name : activeInactiveAutorefresh
	  Description : This method activates or deactivates the autorefresh, if the user will run specific actions over the cards.
	  Parameters	 : Boolean, called from activeInactiveAutorefresh, boolActivate TRUE if we are allowing the autorefresh.
	  Return Type : None
	  */
	 activeInactiveAutorefresh(boolActivate) {
		 if(boolActivate) {
			 if(this.boolWasAutorefreshActive) {
				 this.boolWasAutorefreshActive = false;
				 this.boolIsAutorefreshActive = true;
			 }
		 } else {
			 if(this.boolIsAutorefreshActive) {
				 this.boolWasAutorefreshActive = true;
				 this.boolIsAutorefreshActive = false;
			 }
		 }
	 }
 
	 /*
	  Method Name : popOut
	  Description : This method gets executed when the user tries to pop out or pop in the component.
	  Parameters	 : Object, called from popOut, objEvent Event.
	  Return Type : None
	  */
	 popOut(objEvent) {
		 switch(objEvent.currentTarget.dataset.component) {
			 case "Teams":
				 this.boolIsCaseTeamsPoppedOut = !this.boolIsCaseTeamsPoppedOut;
			 break;
			 case "Queues":
				 this.boolIsCaseQueuesPoppedOut = !this.boolIsCaseQueuesPoppedOut;
			 break;
			 case "Collaborate":
				 this.boolIsCollaboratePoppedOut = !this.boolIsCollaboratePoppedOut;
			 break;
			 case "Attention":
				 this.boolIsAttentionRequestPoppedOut = !this.boolIsAttentionRequestPoppedOut;
			 break;
			 case "Escalations":
				 this.boolIsEscalationsPoppedOut = !this.boolIsEscalationsPoppedOut;
			 break;
			 default:
				 this.boolIsCustomCellModalPoppedOut = !this.boolIsCustomCellModalPoppedOut;
		 }
	 }

	   /*
  Method Name : handleCombinedLookupSearch
  Description : This method changes the owner id of the record 
*/ 
handleCombinedLookupSearch(event) { //T03
	const lookupElement = event.target; 
	lookupCombinedSearch(event.detail)
		.then(results => { //apex method result                
			lookupElement.setSearchResults(results); //call method of customlookupfield.
		})
		.catch(error => {
			log('Combined Lookup Failed -> ' + error);
		});
  }
  handleCombinedLookupSelectionChange(event) {      //T03           
	  const selectedId = event.detail?.values().next().value;        
	  this.idNewOwner = selectedId;

	  
  }

  //Getters  
  get booldisplayftotable() { //T03   
    return (objUtilities.isNotBlank(this.idNewOwner) && this.idNewOwner.startsWith('005')); //T03    
  }
 }