/*
 * Name			:	CsmManageObjectiveProducts
 * Author		:	Deva M
 * Created Date	: 	31/08/2021
 * Description	:	CsmManageObjectiveProducts controller.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Deva M         		31/08/2021		N/A				Initial version.			N/A
 */

//Core imports.
import { LightningElement, api ,wire} from 'lwc';
import { NavigationMixin } from "lightning/navigation";
//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Apex Controllers.
import getRecords from "@salesforce/apex/CSMManageObjectiveProducts.getRecords";

//Custom Labels.
import Refresh_Button from '@salesforce/label/c.Refresh_Button';
import New_Button from '@salesforce/label/c.New_Button';
import Loading from '@salesforce/label/c.Loading';
import Manage_Plan_Objective_Product_Title from '@salesforce/label/c.CSM_Manage_Objective_Product';
import Search_Placeholder from '@salesforce/label/c.CSM_Manage_Objective_Product_Place_Holder';
import Assigned from '@salesforce/label/c.Assigned';
import Unassigned from '@salesforce/label/c.Unassigned';
import Cancel_Button from '@salesforce/label/c.Cancel_Button';
import Remove_Button from '@salesforce/label/c.Remove_Button';

export default class CsmManageObjectiveProducts extends NavigationMixin(LightningElement) {	
	//API variables.
	@api recordId;
	@api strDefaultTab;
	@api objectiveId;
	@api boolPreSelect;

	//Private variables.
	boolDisplaySpinner;
	strRecordTypeId;
	
	//Labels.
	label = {
		Refresh_Button,
		New_Button,
		Loading
	}
	//Feature Configuration.
	objConfiguration = {
		strIconName: "standard:products",
		strCardTitle: Manage_Plan_Objective_Product_Title,
		strSearchPlaceholder: Search_Placeholder,
		lstTabs: [
			{
				strLabel: Assigned,
				strTitle: Assigned,
				strTabValue: "1",
				strTableClass: "assignedTable",
				strObjectName: "Objective_Product__c",
				objParameters: {
					strTableId: "1",
					boolDisplayActions:false,
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
				strObjectName: "Related_Account_Plan__c",
				objParameters: {
					boolDisplayActions:false,
					strTableId: "2",
					lstActionButtons: [{
						strId: "1",
						strVariant: "Neutral",
						strLabel: Cancel_Button,
						title: Cancel_Button,
						strStyleClasses: "slds-var-m-left_x-small"
					}, {
						strId: "5",
						strVariant: "Brand",
						strLabel: "Save & Close",
						title: "Save & Close",
						strStyleClasses: "slds-var-m-left_x-small"
					}, {
						strId: "4",
						strVariant: "Brand",
						strLabel: "Save & Add Milestone",
						title: "Save & Add Milestone",
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
		this.boolDisplayPopOver = false;
		this.boolDisplaySpinner = true;

		//First we load the list of records.
		this.loadRecords();

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
				strObjectiveId: this.objectiveId
			}).then((objResult) => {	
				//We build the tables.
				objParent.objConfiguration.lstTabs.forEach(objTab => {
					if(objTab.strTabValue === strCurrentTab) {					
						let updatedRecords=[];
						//Logic to build to append the parent fields like contact phone for Assigned record						
						if(objUtilities.isNotNull(objResult.lstRecords)){				
							objResult.lstRecords.forEach(record => {
								//Restructered the Json to fetch related the fields
								if(objUtilities.isNotNull(record) && strCurrentTab !== "1"){
									record.Name=objUtilities.isNotBlank(record.Name__c) ? record.Name__c : record.Name;
								}
								if(objUtilities.isNotNull(record.Plan_Product_Alias__r) && strCurrentTab === "1"){
									record.Plan_Product_Alias__r.Id=objUtilities.isNotBlank(record.Plan_Product_Alias__r.Name__c) ? record.Plan_Product_Alias__r.Name__c : record.Plan_Product_Alias__c;
								}
								// and so on for other fields
								updatedRecords.push(record);
							});
						}	
						//Set Coloumn properties
						objResult.lstColumns.forEach(objColumn => {						
							if(objColumn.strFieldName==="Name" && objTab.strTabValue==="2"){
								objColumn.label='Product';
								objColumn.typeAttributes.subtype='text';
								objColumn.subtype='text';
							}
							if(objColumn.strFieldName==="Plan_Product_Alias__c" && objTab.strTabValue!=="2"){
								objColumn.label='Product';
								objColumn.typeAttributes.subtype='text';
								objColumn.subtype='text';
							}
							//Specifies the width of a column in pixels and makes the column non-resizable
							objColumn.fixedWidth = "100%";
							objColumn.initialWidth = "100%";
							
						});
						
						objTab.objParameters.lstRecords = updatedRecords;
						objTab.objParameters.lstColumns = objResult.lstColumns;	
						//Preselect all products on create of objective 
						if(objUtilities.isNotNull(objParent.boolPreSelect) && objParent.boolPreSelect===true && strCurrentTab !== "1"){
							objTab.objParameters.boolPreSelectAllCheckboxes=true;
						}						
					}
				});
			}).catch((objError) => {
				objUtilities.processException(objError, objParent);
			}).finally(() => {
	
				//Finally, we hide the spinner.
				objParent.boolDisplaySpinner = false;
			});
		
		/*//Now we fetch the data.
		if(strCurrentTab !== "1") {
			boolGetAssingedRecords = false;
		}else{
			//Now we send the event and clear the selected records
			this.dispatchEvent(new CustomEvent('hidesavebutton', {
				detail: {
					hideSaveTrue: true
				}
			}));
		}
		if(boolGetAssingedRecords === true){
			getRecords({
				strPlanId: this.recordId,
				boolGetAssingedRecords: boolGetAssingedRecords,
				strObjectiveId: this.objectiveId
	
			}).then((objResult) => {
				console.log(JSON.stringify(objResult));
				//We build the tables.
				objParent.objConfiguration.lstTabs.forEach(objTab => {
					if(objTab.strTabValue === strCurrentTab) {
						if(objUtilities.isNull(objResult.lstRecords) || objResult.lstRecords.length<=0){
							//Now we send the event and clear the selected records
							this.dispatchEvent(new CustomEvent('hidesavebutton', {
								detail: {
									hideSaveTrue: true
								}
							}));
						}				
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

		}else{
			getUnassignedRecords({
			strPlanId: this.recordId,
			boolGetAssingedRecords: boolGetAssingedRecords,
			strObjectiveId: this.objectiveId

		}).then((objResult) => {
			console.log(JSON.stringify(objResult));
			//We build the tables.
			objParent.objConfiguration.lstTabs.forEach(objTab => {
				if(objTab.strTabValue === strCurrentTab) {
					if(objUtilities.isNull(objResult.lstRecords) || objResult.lstRecords.length<=0){
						//Now we send the event and clear the selected records
						this.dispatchEvent(new CustomEvent('hidesavebutton', {
							detail: {
								hideSaveTrue: true
							}
						}));
					}				
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
		}*/
	}

	/*
	 Method Name : refreshCard
	 Description : This method reloads all the data in the card.
	 Parameters	 : Event, called from popOut, objEvent click event.
	 Return Type : None
	 */
	@api
	refreshCard(objEvent) {
		if(typeof objEvent !== "undefined" && objEvent !== null) {
			objEvent.preventDefault();
		}
		//Now we send the event and clear the selected records
		this.dispatchEvent(new CustomEvent('selectedrows', {
			detail: {
				selectedRows: undefined
			}
		}));
		//We refresh the Assigned table.
		this.boolDisplaySpinner = true;
		this.template.querySelector('.searchField').value = "";
		this.loadRecords();
		return false;
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
		let objParent = this;		
		//Now we send the event.
		objParent.dispatchEvent(new CustomEvent('selectedrows', {
			detail: {
				selectedRows: objEvent.detail.selectedRows,
				action:(strCurrentTab=="2")?"save":"delete"
			}
		}));
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