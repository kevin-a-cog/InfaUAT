/*
 * Name			:	globalManageContacts
 * Author		:	Monserrat Pedroza
 * Created Date	: 	8/19/2021
 * Description	:	Global Manage Contacts.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		8/19/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import getRecords from "@salesforce/apex/GlobalManageContactsController.getRecords";
import getRecordsDeleted from "@salesforce/apex/GlobalManageContactsController.getRecordsDeleted";
import getRecordsRelated from "@salesforce/apex/GlobalManageContactsController.getRecordsRelated";
import getRecordsUpdated from "@salesforce/apex/GlobalManageContactsController.getRecordsUpdated";

//Custom Labels.
import Refresh_Button from '@salesforce/label/c.Refresh_Button';
import New_Button from '@salesforce/label/c.New_Button';
import Manage_Contacts_Title from '@salesforce/label/c.Manage_Contacts_Title';
import Assigned_Tab from '@salesforce/label/c.Assigned_Tab';
import Assigned_Tab_Title from '@salesforce/label/c.Assigned_Tab_Title';
import Unassigned_Tab from '@salesforce/label/c.Unassigned_Tab';
import Unassigned_Tab_Title from '@salesforce/label/c.Unassigned_Tab_Title';
import Cancel_Button from '@salesforce/label/c.Cancel_Button';
import Remove_Button from '@salesforce/label/c.Remove_Button';
import Add_Button from '@salesforce/label/c.Add_Button';
import Success from '@salesforce/label/c.Success';
import Records_Removed from '@salesforce/label/c.Records_Removed';
import Records_Added from '@salesforce/label/c.Records_Added';

//Class body.
export default class globalManageContacts extends NavigationMixin(LightningElement) {

	//API variables.
	@api recordId;
    @api isPoppedOut = false;
	@api strDefaultTab;

	//Private variables.
	boolFinishedInitialLoad;
	boolDisplaySpinner;
	strClipboard = "";

	//Labels.
	label = {
		Refresh_Button,
		New_Button,
		Success,
		Records_Removed,
		Cancel_Button,
		Records_Added
	}

	//Feature Configuration.
	objConfiguration = {
		strIconName: "standard:contact",
		strCardTitle: Manage_Contacts_Title,
		lstTabs: [
			{
				strLabel: Assigned_Tab,
				strTitle: Assigned_Tab_Title,
				strTabValue: "1",
				strTableClass: "assignedRecordsTable",
				objParameters: {
					strTableId: "1",
					lstActionButtons: [{
						strId: "1",
						strVariant: "Neutral",
						strLabel: Cancel_Button,
						title: Cancel_Button,
						strStyleClasses: "slds-var-m-left_x-small"
					}, {
						strId: "2",
						strVariant: "Brand",
						strLabel: Remove_Button,
						title: Remove_Button,
						strStyleClasses: "slds-var-m-left_x-small"
					}]
				}
			}, {
				strLabel: Unassigned_Tab,
				strTitle: Unassigned_Tab_Title,
				strTabValue: "2",
				strTableClass: "unassignedRecordsTable",
				objParameters: {
					strTableId: "2",
					lstActionButtons: [{
						strId: "1",
						strVariant: "Neutral",
						strLabel: Cancel_Button,
						title: Cancel_Button,
						strStyleClasses: "slds-var-m-left_x-small"
					}, {
						strId: "4",
						strVariant: "Brand",
						strLabel: Add_Button,
						title: Add_Button,
						strStyleClasses: "slds-var-m-left_x-small"
					}]
				}
			}
		]
	}

	/*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
		this.boolFinishedInitialLoad = false;
		this.boolDisplayPopOver = false;
		this.boolDisplaySpinner = true;

		//Now we load the list of records.
		this.loadRecords();
	}

	/*
	 Method Name : renderedCallback
	 Description : This method gets executed after load.
	 Parameters	 : None
	 Return Type : None
	 */
	renderedCallback() {
		if(!this.boolFinishedInitialLoad) {
			this.boolFinishedInitialLoad = true;

			//Now we include the CSS.
			this.template.querySelector('.customGeneralCSS').innerHTML = "<style> " + 
					"c-global-manage-contacts lightning-card.wrapper > article > .slds-card__header {" + 
					"	display: none;" + 
					"} </style>";
		}
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
	 Method Name : loadRecords
	 Description : This method loads the records on the corresponding table.
	 Parameters	 : None
	 Return Type : None
	 */
	loadRecords() {
		let boolGetAssigned;
		let strCurrentTab;
		let objParent = this;

		//First we prepare the boolean values.
		try {
			strCurrentTab = this.getCurrentTab();
		} catch(objException) {
			if(objUtilities.isNotNull(this.strDefaultTab)) {
				strCurrentTab = "" + this.strDefaultTab;
			}
			if(objUtilities.isBlank(strCurrentTab)) {
				this.objConfiguration.lstTabs.forEach(objTab => {
					if(objUtilities.isBlank(strCurrentTab)) {
						strCurrentTab = objTab.strTabValue;
					}
				});
			}
		}

		//Here we define the specific values per tab.
		if(strCurrentTab === "1") {
			boolGetAssigned = true;
		} else {
			boolGetAssigned = false;
		}
		objParent.strClipboard = "";

		//Now we fetch the data.
		getRecords({
			strRecordId: this.recordId,
			boolGetAssigned: boolGetAssigned
		}).then((objResult) => {

			//We build the tables.
			objParent.objConfiguration.lstTabs.forEach(objTab => {
				if(objTab.strTabValue === strCurrentTab) {
					objTab.objParameters.lstRecords = objResult.lstRecords;
					objTab.objParameters.lstColumns = objResult.lstColumns;

					//Now we add inline editing for all the columns.
					objTab.objParameters.lstColumns.forEach(objColumn => {
						objColumn.editable = "true";
						objColumn.wrapText = "true";
					});

					//Now we save the email addresses for the Copy to clipboard icon.
					if(objUtilities.isNotNull(objResult) && objUtilities.isNotNull(objResult.lstRecords) && objResult.lstRecords.length > 0) {
						objResult.lstRecords.forEach(objRecord => {
							if(objUtilities.isNotBlank(objRecord.Email__c)) {
								objParent.strClipboard += objRecord.Email__c + "; ";
							}
						});
					}
				}
			});
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		}).finally(() => {

			//Finally, we hide the spinner.
			objParent.boolDisplaySpinner = false;
		});
	}

	/*
	 Method Name : refreshCard
	 Description : This method reloads all the data in the card.
	 Parameters	 : Event, called from popOut, objEvent click event.
	 Return Type : None
	 */
	refreshCard(objEvent) {
		if(this.boolFinishedInitialLoad) {
			if(typeof objEvent !== "undefined" && objEvent !== null) {
				objEvent.preventDefault();
			}
	
			//We refresh the Assigned table.
			this.boolDisplaySpinner = true;
			this.loadRecords();
		}
		return false;
	}

    /*
	 Method Name : newRecord
	 Description : This method opens a standard page to create a new record.
	 Parameters	 : None
	 Return Type : None
	 */
    newRecord() {
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: "Engagement_Contacts__c",
                actionName: "new"
            },
            state : {
                nooverride: "1",
				defaultFieldValues: encodeDefaultFieldValues({
					Engagement__c: this.recordId
				})
            }
        });
    }

    /*
	 Method Name : selectRecords
	 Description : This method selects records from the table.
	 Parameters	 : Object, called from selectRecords, objEvent Select event.
	 Return Type : None
	 */
    selectRecords(objEvent) {
		let strCurrentTab = this.getCurrentTab();
		this.objConfiguration.lstTabs.forEach(objTab => {
			if(objTab.strTabValue === strCurrentTab) {
				objTab.lstSelectedRecords = objEvent.detail.selectedRows;
			}
		});
    }

	/*
	 Method Name : handleCancel
	 Description : This method removes the Action panels from the UI.
	 Parameters	 : None
	 Return Type : None
	 */
    handleCancel() {
		let strCurrentTab = this.getCurrentTab();
		let objParent = this;
		this.objConfiguration.lstTabs.forEach(objTab => {
			if(objTab.strTabValue === strCurrentTab) {
				objParent.template.querySelector('.' + objTab.strTableClass).hideActions();
			}
		});
    }

	/*
	 Method Name : removeRecords
	 Description : This method deletes the selected records.
	 Parameters	 : None
	 Return Type : None
	 */
	removeRecords() {
		let strCurrentTab = this.getCurrentTab();
		let objSource;
		let objParent = this;
		let lstRecords = new Array();
		this.boolDisplaySpinner = true;

		//Now we create the list of unique ids.
		this.objConfiguration.lstTabs.forEach(objTab => {
			if(objTab.strTabValue === strCurrentTab) {
				objSource = objTab.lstSelectedRecords;
			}
		});
		objSource.forEach(objSelectedRecord => {
			lstRecords.push({
				Id: objSelectedRecord.Id
			});
		});
		
		//Now we send the record for deletion.
		getRecordsDeleted({
			lstRecords: lstRecords
		}).then(() => {

			//Now we display the success message.
			objUtilities.showToast(objParent.label.Success, objParent.label.Records_Removed, 'success', objParent);

			//We refresh the card.
			objParent.refreshCard();
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		});
	}

	/*
	 Method Name : addRecords
	 Description : This method adds the selected records.
	 Parameters	 : None
	 Return Type : None
	 */
	addRecords() {
		let strCurrentTab = this.getCurrentTab();
		let objSource;
		let objParent = this;
		let lstRecords = new Array();
		this.boolDisplaySpinner = true;

		//First we create the list of unique ids.
		this.objConfiguration.lstTabs.forEach(objTab => {
			if(objTab.strTabValue === strCurrentTab) {
				objSource = objTab.lstSelectedRecords;
			}
		});
		objSource.forEach(objSelectedRecord => {
			lstRecords.push(objSelectedRecord.ContactId);
		});

		//Now we check the original call.
		getRecordsRelated({
			strRecordId: this.recordId,
			lstRecords: lstRecords
		}).then(() => {

			//Now we display the success message.
			objUtilities.showToast(objParent.label.Success, objParent.label.Records_Added, 'success', objParent);

			//We refresh the card.
			objParent.refreshCard();
		}).catch((objError) => {
			objParent.boolDisplaySpinner = false;
			objUtilities.processException(objError, objParent);
		});
	}

	/*
	 Method Name : executeAction
	 Description : This method executes the corresponding action requested by the Data Tables components.
	 Parameters	 : Object, called from executeAction, objEvent Select event.
	 Return Type : None
	 */
	executeAction(objEvent) {
        const { intAction, objPayload } = objEvent.detail;
		let strCurrentTab = this.getCurrentTab();
		let objParent = this;
		let lstAssignedRecords;
		let lstUnassignedRecords;

		//First, we check which event we need to execute.
		switch(intAction) {
			case 1:
				
				//The user has selected records.
				this.selectRecords(objPayload);
			break;
			case 2:

				//The user has pressed an Action button.
				switch(objPayload.currentTarget.dataset.id) {

					//User wants to cancel the table selection.
					case "1":
					case "3":
						this.handleCancel();
					break;

					//User wants to remove a record.
					case "2":
						this.removeRecords();
					break;

					//User wants to add a record.
					case "4":
						this.addRecords();
					break;
				}
			break;
			case 3:
				
				//First we prepare the data (inline editing).
				if(objUtilities.isNotNull(objPayload) && objPayload.length > 0) {
					objParent.boolDisplaySpinner = true;
	
					//We save the inline changes.
					if(strCurrentTab === "1") {
						lstAssignedRecords = objPayload;
					} else {
						lstUnassignedRecords = objPayload;
					}
					getRecordsUpdated({
						lstAssignedRecords: lstAssignedRecords,
						lstUnassignedRecords: lstUnassignedRecords
					}).then(() => {
	
						//Now we clean up the draft values.
						objParent.loadRecords();
					}).catch((objError) => {
						objUtilities.processException(objError, objParent);
						objParent.boolDisplaySpinner = false;
					});
				}
			break;
		}
    }

	/*
	 Method Name : getCurrentTab
	 Description : This method returns the value of the current tab.
	 Parameters	 : None
	 Return Type : String
	 */
	getCurrentTab() {
		return this.template.querySelector('lightning-tabset').activeTabValue;
	}

	/*
	 Method Name : copyToClipboard
	 Description : This method copies the email addresses to the clipboard.
	 Parameters	 : None
	 Return Type : None
	 */
	copyToClipboard() {
		let objParent = this;
		let objInputField = this.template.querySelector('.clipboard');
		objInputField.value = objParent.strClipboard;
		objInputField.select();
		document.execCommand('copy');
	}
}