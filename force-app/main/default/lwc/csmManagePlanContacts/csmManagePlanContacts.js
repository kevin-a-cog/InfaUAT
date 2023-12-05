/*
 * Name			:	csmmanagePlanContacts
 * Author		:	Manuraj
 * Created Date	: 	07/07/2021
 * Description	:	Manage Plan Contacts controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Manuraj				07/07/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api ,wire} from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import getRecords from "@salesforce/apex/CSMManagePlanContacts.getRecords";
import getRecordsDeleted from "@salesforce/apex/CSMManagePlanContacts.getRecordsDeleted";
import getRecordsRelated from "@salesforce/apex/CSMManagePlanContacts.getRecordsRelated";
import getRecordsUpdated from "@salesforce/apex/CSMManagePlanContacts.getRecordsUpdated";

//Custom Labels.
import Refresh_Button from '@salesforce/label/c.Refresh_Button';
import New_Button from '@salesforce/label/c.New_Button';
import Loading from '@salesforce/label/c.Loading';
import Manage_Plan_Contacts_Title from '@salesforce/label/c.CSM_Manage_Plan_Contacts';
import Search_Placeholder from '@salesforce/label/c.CSM_Plan_Contact_Place_Holder';
import Assigned from '@salesforce/label/c.Assigned';
import Unassigned from '@salesforce/label/c.Unassigned';
import Cancel_Button from '@salesforce/label/c.Cancel_Button';
import Remove_Button from '@salesforce/label/c.Remove_Button';
import Add_Button from '@salesforce/label/c.Add_Button';
import Copy_Email from '@salesforce/label/c.Copy_Email';
import Success from '@salesforce/label/c.Success';
import Error from '@salesforce/label/c.Error';

import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import PLANACCOUNT from "@salesforce/schema/Plan__c.Account__c";
import PLANID from "@salesforce/schema/Plan__c.Id";
import IS_AUTOPILOT from "@salesforce/schema/Plan__c.CSM_isAutoPilot__c";
import STATUS from "@salesforce/schema/Plan__c.Status__c";

import hasCSMPermission from '@salesforce/customPermission/CSMUser';

const fields = [PLANID, PLANACCOUNT,IS_AUTOPILOT,STATUS];

export default class CsmManagePlanContacts extends NavigationMixin(LightningElement) {

	//API variables.
	@api recordId;
    @api isPoppedOut = false;
	@api strDefaultTab;

	//Private variables.
	boolDisplaySpinner;
	strRecordTypeId;
	strClipboard = "";
	planRecord;

	//Labels.
	label = {
		Refresh_Button,
		New_Button,
		Loading,
		Copy_Email,
		Success,
		Error
	}
    

	//Feature Configuration.
	objConfiguration = {
		strIconName: "standard:partners",
		strCardTitle: Manage_Plan_Contacts_Title,
		strSearchPlaceholder: Search_Placeholder,
		lstTabs: [
			{
				strLabel: Assigned,
				strTitle: Assigned,
				strTabValue: "1",
				strTableClass: "assignedTable",
				strObjectName: "Plan_Contact__c",
				objParameters: {
					strTableId: "1",
					lstActionButtons: [{
						strId: "0",
						strVariant: "Neutral",
						strLabel: Copy_Email,
						title: Copy_Email,
						strStyleClasses: "slds-var-m-left_x-small"
					}, {
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
				strObjectName: "Plan_Contact__c",
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

	//Additional Phone Column
	phoneCloumn = {
		boolIsFormula: true,
		fieldName: "Phone",
		label: "Phone",
		objType: {},
		sortable: "true",
		strFieldName: "Name",
		strObjectName: "Plan_Contact__c",
		strParentObject: "Plan_Contact__c",
		type: "phone"
	}
	//Additional Account Type Column
	acctypeCloumn = {
		boolIsFormula: true,
		fieldName: "AccType",
		label: "Account Type",
		objType: {},
		sortable: "true",
		strFieldName: "Name",
		strObjectName: "Plan_Contact__c",
		strParentObject: "Plan_Contact__c",
		type: "text"
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
		  return (hasCSMPermission && !isAutopilot  && !isComplete);
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
		getRecords({
			strPlanId: this.recordId,
			boolGetAssingedRecords: boolGetAssingedRecords,
            supportAcc: getFieldValue(this.planRecord, PLANACCOUNT)
		}).then((objResult) => {

			//We build the tables.
			objParent.objConfiguration.lstTabs.forEach(objTab => {
				if(objTab.strTabValue === strCurrentTab) {
					var updatedRecords=[];
					if(strCurrentTab == "1") {
						//Logic to build to append the parent fields like contact phone for Assigned record						
						if(objUtilities.isNotNull(objResult.lstRecords)){
							objResult.lstRecords.forEach(record => {
								//Restructered the Json to fetch related phone and Name fields
								let preparedContactRecord = record;
								//let accTypevariable = objUtilities.isNotBlank(record.Contact__r.Account.Type) ? record.Contact__r.Account.Type : '';
								//let phoneVariable = objUtilities.isNotBlank(record.Contact__r.Phone) ? record.Contact__r.Phone : '';
								record.Name=objUtilities.isNotBlank(record.Contact_Name__c) ? record.Contact_Name__c : record.Name;
								//preparedContactRecord = { ...preparedContactRecord, Phone: phoneVariable};							
								// and so on for other fields
								updatedRecords.push(preparedContactRecord);
							});
						}
						//objResult.lstColumns.push(this.phoneCloumn);
						//objResult.lstColumns.push(this.acctypeCloumn);
					}else{
						//updatedRecords = objResult.lstRecords;
						//Logic to build to append the parent fields like contact phone for Assigned record						
						if(objUtilities.isNotNull(objResult.lstRecords)){
							objResult.lstRecords.forEach(record => {
								//Restructered the Json to fetch related phone and Name fields
								let preparedContactRecord = record;
								//let accTypevariable = objUtilities.isNotBlank(record.Account.Type) ? record.Account.Type : '';
								//preparedContactRecord = { ...preparedContactRecord, AccType:accTypevariable};							
								// and so on for other fields
								updatedRecords.push(preparedContactRecord);
							});
						}				
						//objResult.lstColumns.push(this.acctypeCloumn);
					}
					objTab.objParameters.lstRecords = updatedRecords ;
					objTab.objParameters.lstColumns = objResult.lstColumns;
					//Now we add inline editing for all the columns.
					objTab.objParameters.lstColumns.forEach(objColumn => {
						if(objColumn.strFieldName==="Role__c" && strCurrentTab == "1"){
							//objColumn.editable = "true";
							var isAutopilot = getFieldValue(this.planRecord, IS_AUTOPILOT);
							let isComplete = getFieldValue(this.planRecord,STATUS)=='Complete';		
							//objColumn.editable = (!hasCSMPermission)?"false":"true";
							objColumn.editable = (!hasCSMPermission || isAutopilot || isComplete)?"false":"true";
						}
						//Rename the Account label for parent 
						if(objColumn.label=="Account ID"){
							objColumn.label='Account';
						}
						if(objColumn.strFieldName=="Contact__r.Phone" || objColumn.strFieldName=="Phone" ){
							objColumn.label='Phone Number';
						}
						if(objColumn.strFieldName=="Name"){
							objColumn.label='Full Name';
						}
						if(objColumn.strFieldName == "Is_Success_Community_User__c" || objColumn.strFieldName == "Recieve_Email__c" ){
							//objColumn.editable = "true";
							var isAutopilot = getFieldValue(this.planRecord, IS_AUTOPILOT);
							let isComplete = getFieldValue(this.planRecord,STATUS)=='Complete';
							objColumn.editable = (!hasCSMPermission || isAutopilot || isComplete)?"false":"true";
							//objColumn.editable = (!hasCSMPermission)?"false":"true";
							objColumn.subtype = "boolean";
							objColumn.type = "custom";
							if(objUtilities.isNull(objColumn.typeAttributes)) {
								objColumn.typeAttributes = new Object();
							}
							objColumn.typeAttributes.subtype = "boolean";
						}
					});
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
			lstRecords.push({
				Id: objSelectedRecord.Id
			});
		});

		//Now we send the record for deletion.
		getRecordsRelated({
			strRecordId: this.recordId,
			lstRecords: lstRecords
		}).then(() => {
			objParent.refreshCard();
		}).catch((objError) => {
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
		console.log('Execute');
        const { intAction, objPayload } = objEvent.detail;
		let strCurrentTab;
		let objParent = this;

		//First, we check which event we need to execute.
		switch(intAction) {
			case 1:
				
				//The user has selected records.
				this.selectRecords(objPayload);
			break;
			case 2:

				//The user has pressed an Action button.
				switch(objPayload.currentTarget.dataset.id) {

					//User wants to copy the selected Contact emails to the clipboard.
					case "0":
						this.copySelectedContactsToClipboard();
					break;

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
				
				//First we prepare the data (inline editing).
				if(objUtilities.isNotNull(objPayload) && objPayload.length > 0) {
					console.log('check');
					let lstRecords = new Array();
					objPayload.forEach(objRecord =>{
						objParent.objConfiguration.lstTabs.forEach(objTab => {
							if(objTab.strTabValue === strCurrentTab) {
								objTab.objParameters.lstRecords.forEach(objExistingRecord =>{
									if(objRecord.Id === objExistingRecord.Id) {
										if(objUtilities.isNotNull(objExistingRecord) && objUtilities.isBlank(objExistingRecord.Role__c)) {
											objUtilities.showToast(objParent.label.Error, 'Please select valid role for Contact','error', objParent);   
										}else{
											lstRecords.push(objRecord);
										}
									}
								});
							}
						});
					});
					if(lstRecords.length>0){
						objParent.boolDisplaySpinner = true;	

						//We save the inline changes.
						getRecordsUpdated({
							lstRecords: lstRecords
						}).then(() => {

							//Now we clean up the draft values.
							objParent.loadRecords();
						}).catch((objError) => {
							objUtilities.processException(objError, objParent);
							objParent.boolDisplaySpinner = false;
						});
					}
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
	 Method Name : copySelectedContactsToClipboard
	 Description : This method copies the selected Contacts to the clipboard.
	 Parameters	 : None
	 Return Type : None
	 */
	copySelectedContactsToClipboard() {
		let strEmails = " ";
		let strCurrentTab;
		let objInputField = this.template.querySelector('.clipboard');

		//We get the current tab.
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

		//Now we extract the values.
		this.objConfiguration.lstTabs.forEach(objTab => {
			if(objTab.strTabValue === strCurrentTab && objUtilities.isNotNull(objTab.lstSelectedRecords)) {
				console.log(JSON.stringify(objTab.lstSelectedRecords));
				objTab.lstSelectedRecords.forEach(objContact => {
					strEmails += objContact.Con_Email__c + "; ";
				});
			}
		});
		objInputField.value = strEmails;
		objInputField.select();
		console.log('testtt>>'+strEmails);
		//document.execCommand('copy');
		document.execCommand('copy', false, strEmails);
	}
}