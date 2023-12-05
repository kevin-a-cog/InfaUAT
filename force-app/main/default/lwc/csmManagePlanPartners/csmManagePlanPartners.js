/*
 * Name			:	managePlanPartners
 * Author		:	Gabriel Coronel
 * Created Date	: 	6/2/2021
 * Description	:	Manage Plan Partners controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Gabriel Coronel		6/2/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import getUnassignedRecords from "@salesforce/apex/CSMManagePlanPartnersController.getUnassignedRecords";
import getAssingedRecords from "@salesforce/apex/CSMManagePlanPartnersController.getAssingedRecords";
import getRecordsDeleted from "@salesforce/apex/CSMManagePlanPartnersController.getRecordsDeleted";
import getRecordsRelated from "@salesforce/apex/CSMManagePlanPartnersController.getRecordsRelated";
import getPlanPartnerRecordType from "@salesforce/apex/CSMManagePlanPartnersController.getPlanPartnerRecordType";

//Custom Labels.
import Refresh_Button from '@salesforce/label/c.Refresh_Button';
import New_Button from '@salesforce/label/c.New_Button';
import Loading from '@salesforce/label/c.Loading';
import Manage_Plan_Partners_Title from '@salesforce/label/c.Manage_Plan_Partners_Title';
import Search_Placeholder from '@salesforce/label/c.Search_Placeholder';
import Assigned from '@salesforce/label/c.Assigned';
import Unassigned from '@salesforce/label/c.Unassigned';
import Cancel_Button from '@salesforce/label/c.Cancel_Button';
import Remove_Button from '@salesforce/label/c.Remove_Button';
import Add_Button from '@salesforce/label/c.Add_Button';

import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import IS_AUTOPILOT from "@salesforce/schema/Plan__c.CSM_isAutoPilot__c";
import STATUS from "@salesforce/schema/Plan__c.Status__c";

import hasCSMPermission from '@salesforce/customPermission/CSMUser';

const fields = [IS_AUTOPILOT,STATUS];

//Class body.
export default class CsmManagePlanPartners extends NavigationMixin(LightningElement) {

	//API variables.
	@api recordId;
    @api isPoppedOut = false;
	@api strDefaultTab;

	//Private variables.
	boolDisplaySpinner;
	strRecordTypeId;
	planRecord;

	//Labels.
	label = {
		Refresh_Button,
		New_Button,
		Loading
	}

	//Feature Configuration.
	objConfiguration = {
		strIconName: "standard:partners",
		strCardTitle: Manage_Plan_Partners_Title,
		strSearchPlaceholder: Search_Placeholder,
		lstTabs: [
			{
				strLabel: Assigned,
				strTitle: Assigned,
				strTabValue: "1",
				strTableClass: "assignedTable",
				strObjectName: "Partner_Relationship__c",
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
				strLabel: Unassigned,
				strTitle: Unassigned,
				strTabValue: "2",
				strTableClass: "unassignedTable",
				strObjectName: "Partner_Relationship__c",
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

	@wire(getRecord, { recordId: "$recordId", fields })
	planRecordDetails({data,error}){
			  if(data){
				  this.planRecord = data;
				  var isAutoPilot = data.fields.CSM_isAutoPilot__c.value;
				  var status = data.fields.Status__c.value;
				  if(isAutoPilot || !hasCSMPermission || status==='Complete'){
					  this.objConfiguration.lstTabs.forEach(tab =>{
						  tab.objParameters.boolHideCheckboxColumn = true;
					  })
				  }else{
					this.objConfiguration.lstTabs.forEach(tab =>{
						tab.objParameters.boolHideCheckboxColumn = false;
					})
				  }
			  }
	  }

	  get showButtons() {
		var isAutopilot = getFieldValue(this.planRecord, IS_AUTOPILOT);	
		const isComplete = getFieldValue(this.planRecord,STATUS)=='Complete';	
		return (hasCSMPermission && !isAutopilot && !this.hideButtons  && !isComplete);
	}

	/*
	 Method Name : connectedCallback
	 Description : This method gets executed on load.
	 Parameters	 : None
	 Return Type : None
	 */
	connectedCallback() {
		this.boolDisplayPopOver = false;
		this.boolDisplaySpinner = true;

		//First we load the list of records.
		this.loadRecords();

		//Now we get the record type id.
		this.getDefaultRecordType();
	}

	/*
	 Method Name : getDefaultRecordType
	 Description : This method returns the default Record Type Id.
	 Parameters	 : None
	 Return Type : None
	 */
	getDefaultRecordType() {
		let objParent = this;
		getPlanPartnerRecordType().then((strResult) => {
			this.strRecordTypeId = strResult;
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
		});
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
		let boolGetAssingedRecords = true;
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

		//Now we fetch the data.
		if(strCurrentTab !== "1") {
			boolGetAssingedRecords = false;
		}
		if(boolGetAssingedRecords==true){
			getAssingedRecords({
				strPlanId: this.recordId
			}).then((objResult) => {

				//We build the tables.
				objParent.objConfiguration.lstTabs.forEach(objTab => {
					if(objTab.strTabValue === strCurrentTab) {
						var updatedRecords=objResult.lstRecords;
						if(objUtilities.isNotNull(updatedRecords)){
							updatedRecords.forEach(record => {
								record.Name=objUtilities.isNotBlank(record.Partner_Account__r.Name) ? record.Partner_Account__r.Name : record.Name;
							});
						}
						objTab.objParameters.lstRecords = updatedRecords;
						objTab.objParameters.lstColumns = objResult.lstColumns;
					}
				});
			}).catch((objError) => {
				objUtilities.processException(objError, objParent);
			}).finally(() => {
				//Finally, we hide the spinner.
				objParent.boolDisplaySpinner = false;
			});
		}else{
			getUnassignedRecords({
				strPlanId: this.recordId,
			}).then((objResult) => {	
				//We build the tables.
				objParent.objConfiguration.lstTabs.forEach(objTab => {
					if(objTab.strTabValue === strCurrentTab) {
						objTab.objParameters.lstRecords = objResult.lstRecords;
						objTab.objParameters.lstColumns = objResult.lstColumns;
					}
				});
			}).catch((objError) => {
				objUtilities.processException(objError, objParent);
			}).finally(() => {
				//Finally, we hide the spinner.
				objParent.boolDisplaySpinner = false;
			});
		}
	}

	/*
	 Method Name : refreshCard
	 Description : This method reloads all the data in the card.
	 Parameters	 : Event, called from popOut, objEvent click event.
	 Return Type : None
	 */
	refreshCard(objEvent) {
		if(typeof objEvent !== "undefined" && objEvent !== null) {
			objEvent.preventDefault();
		}

		//We refresh the Assigned table.
		this.boolDisplaySpinner = true;
		this.template.querySelector('.searchField').value = "";
		this.loadRecords();
		return false;
	}

    /*
	 Method Name : newRecord
	 Description : This method opens a standard page to create a new record.
	 Parameters	 : None
	 Return Type : None
	 */
    newRecord() {
		let strCurrentTab = this.getCurrentTab();
		let strObjectName;
		let objParent = this;

		//First we define on which tab we are.
		this.objConfiguration.lstTabs.forEach(objTab => {
			if(objTab.strTabValue === strCurrentTab) {
				strObjectName = objTab.strObjectName;
			}
		});

		//Now we open the new subtab.
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: strObjectName,
                actionName: "new"
            },
            state : {
                nooverride: "1",
                defaultFieldValues: encodeDefaultFieldValues({
					Plan__c: this.recordId
				}),
				recordTypeId: objParent.strRecordTypeId
            }
        });
    }

	/*
	 Method Name : searchRecord
	 Description : This method searches for records based on a given keyword.
	 Parameters	 : Object, called from searchRecord, objEvent Change event.
	 Return Type : None
	 */
	searchRecord(objEvent) {
		let strCurrentTab = this.getCurrentTab();
		let objParent = this;
		this.objConfiguration.lstTabs.forEach(objTab => {
			if(objTab.strTabValue === strCurrentTab) {
				objParent.template.querySelector('.' + objTab.strTableClass).searchRecord(objEvent);
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
		let objParent = this;
		let objSource;
		let lstRecords = new Array();
		this.boolDisplaySpinner = true;

		//First we create the list of unique ids.
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
		let objParent = this;
		let objSource;
		let lstRecords = new Array();
		this.boolDisplaySpinner = true;

		//First we create the list of unique ids.
		this.objConfiguration.lstTabs.forEach(objTab => {
			if(objTab.strTabValue === strCurrentTab) {
				objSource = objTab.lstSelectedRecords;
			}
		});
		objSource.forEach(objSelectedRecord => {
			lstRecords.push({
				Partner_Account__c: objSelectedRecord.accountId
				//Partner_Account__c:objSelectedRecord.accountId
			});		
		});
		//Now we send the record for Add.
		getRecordsRelated({
			strRecordId: this.recordId,
			lstRecords: lstRecords
		}).then(() => {
			objParent.refreshCard();
		}).catch((objError) => {
			objUtilities.processException(objError, objParent);
			objParent.boolDisplaySpinner = false;
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
}